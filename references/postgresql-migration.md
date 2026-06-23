# PostgreSQL to Vertica Migration Guide

This guide provides comprehensive guidance for migrating PostgreSQL databases to Vertica, including PL/pgSQL to PL/vSQL conversion, SQL syntax differences, and performance optimization strategies.

## 🚨 CRITICAL: MANDATORY COMPLIANCE REQUIREMENTS

**BEFORE STARTING ANY POSTGRESQL MIGRATION, YOU MUST READ AND FOLLOW THE [GENERIC MIGRATION GUIDE](generic-migration-guide.md)**

This PostgreSQL migration guide **MUST BE USED IN CONJUNCTION WITH** the [Generic Migration Guide](generic-migration-guide.md). The generic guide contains **MANDATORY PROCEDURES** that apply to ALL database migrations, including:

- ✅ **COMPLETE migration** of ALL objects (no selective migration allowed)
- ✅ **SEQUENTIAL processing** in exact source file order (no reordering)
- ✅ **ONE-TO-ONE conversion** (tables→tables, procedures→procedures, etc.)
- ✅ **INDIVIDUAL testing** of every object before considering it migrated
- ✅ **NO automated scripts** or bulk processing
- ✅ **PRESERVATION** of all sequences, and dependencies

**FAILURE TO FOLLOW THE GENERIC MIGRATION GUIDE WILL RESULT IN FAILED MIGRATIONS.**

## Reference Documentation (In Priority Order)

1. **[Generic Migration Guide](generic-migration-guide.md)** - **MANDATORY READING** - Contains non-negotiable migration requirements
2. **[OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md)** - **ESSENTIAL** for ALL PostgreSQL migrations (cursors, loops, row-by-row processing)
3. **[SQL Syntax Reference](sql-syntax-reference.md)** - Comprehensive Vertica SQL syntax
4. **[Function Mapping Guide](function-mapping.md)** - Function conversion across databases
5. **[Data Type Mapping Guide](data-type-mapping.md)** - Data type mapping and optimization
6. **[User-Defined SQL Functions Development Guide](user-defined-sql-functions-guide.md)** - Custom SQL functions development
7. **[Stored Procedures Guide](stored-procedures-guide.md)** - PL/vSQL stored procedures development
8. **[UDx Development Guide](udx-development-guide.md)** - Custom functions including SQL functions development

## SQL Syntax Conversion

### Basic SELECT Statement Differences

```sql
-- PostgreSQL
SELECT * FROM employees e, departments d 
WHERE e.dept_id = d.dept_id
LIMIT 10;

-- Vertica (both implicit and explicit JOIN syntax are supported)
SELECT * FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
LIMIT 10;
```

### Auto-increment Columns

```sql
-- PostgreSQL
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (use IDENTITY)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100)
);
```

### DELETE with JOIN

**PostgreSQL** supports `DELETE ... USING` to join tables in a DELETE statement. **Vertica does not** — use `WHERE IN` or `WHERE EXISTS` instead.

```sql
-- ✅ PostgreSQL: DELETE with USING
DELETE FROM orders o
USING customers_to_purge p
WHERE o.customer_id = p.customer_id;

-- ✅ Vertica: DELETE with WHERE IN
DELETE FROM orders
WHERE customer_id IN (SELECT customer_id FROM customers_to_purge);

-- ✅ Vertica: DELETE with WHERE EXISTS (often faster)
DELETE FROM orders
WHERE EXISTS (
    SELECT 1 FROM customers_to_purge p
    WHERE p.customer_id = orders.customer_id
);
```

## Data Type Mappings

> **See [Data Type Mapping Guide](data-type-mapping.md)** for complete data type mappings.
> Load on-demand: `grep -n "^## \|^### " references/data-type-mapping.md` → `Read offset=N limit=M`

## Function Conversions

> **See [Function Mapping Guide](function-mapping.md)** for function conversions across databases.
> Load on-demand: `grep -n "^## \|^### " references/function-mapping.md` → `Read offset=N limit=M`

## PL/pgSQL to PL/vSQL Conversion

### Language-Level Differences

#### PERFORM Statement Requirement
**PostgreSQL**: DDL and DML statements can be used directly in PL/pgSQL.
**Vertica**: Must use `PERFORM` to discard output (row counts, Tuples/Tuple, status messages) for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE and other SQL statements when not capturing return values via `:=`, `<-`, `SELECT ... INTO`, or `EXECUTE ... INTO`.

```sql
-- ❌ PostgreSQL style (won't work in Vertica)
INSERT INTO audit_log VALUES ('Processing started');

-- ✅ Vertica style
PERFORM INSERT INTO audit_log VALUES ('Processing started');
```

#### NULL Coercion Behavior
**PostgreSQL**: NULL can be coerced to FALSE in boolean contexts.
**Vertica**: NULL is not coercible to FALSE by default.

```sql
-- ❌ This will fail in Vertica
IF NULL THEN
    -- BOOLEAN value expected for IF
END IF;

-- ✅ Enable NULL-to-FALSE coercion if needed
ALTER DATABASE DEFAULT SET PLvSQLCoerceNull = 1;
```

#### FOR Loop Keywords
**PostgreSQL**: Standard FOR loops.
**Vertica**: Additional keywords required for specific loop types.

```sql
-- Vertica-specific loop syntax
FOR i IN RANGE 1..10 LOOP                     -- Standard range loop
FOR record IN QUERY SELECT * FROM table LOOP  -- Query loop
FOR record IN CURSOR cur LOOP                 -- Cursor loop
```

### Window Functions

```sql
-- PostgreSQL
SELECT employee_id, salary,
       ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) as rank,
       LAG(salary) OVER (ORDER BY hire_date) as prev_salary
FROM employees;

-- Vertica (same syntax)
SELECT employee_id, salary,
       ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) as rank,
       LAG(salary) OVER (ORDER BY hire_date) as prev_salary
FROM employees;
```

### Common Table Expressions (CTEs)

```sql
-- PostgreSQL
WITH RECURSIVE employee_hierarchy AS (
    SELECT emp_id, manager_id, emp_name, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.manager_id, e.emp_name, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT * FROM employee_hierarchy;

-- Vertica (same syntax)
WITH RECURSIVE employee_hierarchy AS (
    SELECT emp_id, manager_id, emp_name, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.manager_id, e.emp_name, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT * FROM employee_hierarchy;
```

## Index and Constraint Migration

### Primary Keys

```sql
-- PostgreSQL
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL
);

-- Vertica (same syntax)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL
);
```

### Foreign Keys

```sql
-- PostgreSQL
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id)
);

-- Vertica (same syntax)
CREATE TABLE orders (
    order_id IDENTITY PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id)
);
```

### Foreign Key Constraint Limitations

**Critical Limitation**: Vertica does NOT support `ON DELETE CASCADE` for foreign key constraints, which is a key difference from PostgreSQL.

```sql
-- PostgreSQL table with ON DELETE CASCADE
CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders (order_id) ON DELETE CASCADE
);

-- Vertica migration (ON DELETE CASCADE removed and commented)
CREATE TABLE order_items (
    item_id IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
    -- ON DELETE CASCADE (Vertica does not support this option)
);
```

**Alternative Solutions for Cascade Delete**:
1. **Stored Procedures**: Create procedures to handle cascade deletes manually
2. **Application Logic**: Implement cascade logic in application code

### Unique Constraints

```sql
-- PostgreSQL
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE
);

-- Vertica (same syntax)
CREATE TABLE products (
    product_id IDENTITY PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE
);
```

### Check Constraints

```sql
-- PostgreSQL
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    salary NUMERIC(10,2) CHECK (salary > 0)
);

-- Vertica (same syntax)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    salary NUMERIC(10,2) CHECK (salary > 0)
);
```

## Stored Procedure Migration

### Variable Declaration Type Restrictions

Vertica PL/vSQL has the following restrictions on variable data types that differ from PL/pgSQL:

| Restriction | PL/pgSQL | Vertica Workaround |
|-------------|----------|--------------------|
| `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` without precision. Default is precision 37, scale 15. |
| `%ROWTYPE` for record variables | ✅ Supported | Not supported. Declare individual variables with `%TYPE` instead. |
| `RECORD` type (anonymous row) | ✅ Supported | Not supported. Declare individual typed variables. |
| `REFCURSOR` | ✅ Supported | Use `refcursor` in DECLARE block. |
| `TRIGGER` type | ✅ Supported | Not supported. Vertica does not support trigger procedures. |
| `ENUM` types | ✅ Supported | Not supported. Use `VARCHAR` with a CHECK constraint. |
| `COMPOSITE` types (CREATE TYPE) | ✅ Supported | Not supported. Use individual scalar variables. |
| `ARRAY` type variables | ✅ Supported | Not supported. Use separate normalized tables. |
| `JSON` / `JSONB` types | ✅ Supported | Not supported. Use `LONG VARCHAR` or Flex Tables. |
| `UUID` type | ✅ Supported | Supported as a variable type (without parameters). |
| `GEOMETRY` / `GEOGRAPHY` (PostGIS) | ✅ Supported | Not supported. Store as `VARCHAR` or `LONG VARBINARY`. |
| `TSVECTOR` / `TSQUERY` (full-text search) | ✅ Supported | Not supported. Use Vertica Text Index instead. |
| `BYTEA` type | ✅ Supported | Maps to `LONG VARBINARY`. |


### Critical Parameter Handling Rules

⚠️ **MOST IMPORTANT**: Never remove OUT/INOUT parameter keywords when migrating from PostgreSQL!

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: In PostgreSQL stored procedures, OUT and INOUT parameters modify the values of variables passed to procedures. In Vertica stored procedures, `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The original input variables remain unchanged.

**How it works in Vertica**:

- `CALL procedure_name(...)` returns a **single tuple (record)** containing all OUT/INOUT values
- Each column in the tuple is named after the corresponding OUT/INOUT parameter
- Use `var1, var2 := CALL proc(...)` to unpack the tuple's columns into variables by position
- The original variables passed to the procedure remain unchanged

**Migration Implication**: When converting PostgreSQL PL/pgSQL stored procedures that rely on OUT parameters to modify calling variables, use tuple unpacking assignment instead:

```sql
CREATE PROCEDURE get_statistics(
    IN data_table VARCHAR,
    OUT row_count BIGINT,
    OUT avg_value DOUBLE PRECISION,
    OUT max_value DOUBLE PRECISION
) AS $$
BEGIN
    EXECUTE 'SELECT COUNT(*), AVG(value), MAX(value) FROM ' || data_table
    INTO row_count, avg_value, max_value;
END;
$$;

-- CALL returns a single tuple: (1000, 42.50, 999.99)
--   column names: row_count, avg_value, max_value
CALL get_statistics('sales_data');

-- Unpack the tuple into variables:
DO $$
DECLARE
    v_count BIGINT;
    v_avg DOUBLE PRECISION;
    v_max DOUBLE PRECISION;
BEGIN
    v_count, v_avg, v_max := CALL get_statistics('sales_data');
    RAISE NOTICE 'Count: %, Avg: %, Max: %', v_count, v_avg, v_max;
END
$$;
```

#### Parameter Mode Conversion Table

**Key Syntax**: Both PostgreSQL and Vertica place parameter modes (IN, OUT, INOUT) **before** the parameter name. The syntax is the same in both systems — the critical rule is to **never remove** the OUT and INOUT keywords during migration.

| PostgreSQL Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|-------------------|---------------------|-------------------|-------|
| `IN p_param VARCHAR` | `p_param VARCHAR` | `p_param VARCHAR` | IN is optional (default) |
| `OUT p_param INTEGER` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT keyword** |
| `INOUT p_param VARCHAR` | `p_param VARCHAR` | `INOUT p_param VARCHAR` | **Must keep INOUT keyword** |

**Why this matters**: Removing OUT/INOUT keywords completely breaks the parameter passing mechanism and will cause runtime errors or incorrect behavior.

#### Migration Checklist for Parameters
- [ ] ✅ Preserve all OUT parameter keywords
- [ ] ✅ Preserve all INOUT parameter keywords
- [ ] ✅ IN keywords are optional (can be omitted)
- [ ] ✅ Test parameter passing with various data types
- [ ] ✅ Verify return value handling
- [ ] ✅ Understand that OUT/INOUT parameters don't modify original variables

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: PostgreSQL supports default parameter values (e.g., `p_param VARCHAR DEFAULT 'value'`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% PostgreSQL compatibility.

#### Best Practice: Procedure Overloading for Default Parameters

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**
> Procedure overloading in Vertica works by matching the **procedure name** plus the parameter signature (number, types, order). Every overloaded variant **must** share the identical procedure name — only the parameter list differs. Using different names defeats the purpose of overloading and breaks call compatibility.

```sql
-- PostgreSQL Original with Default Parameters
CREATE OR REPLACE PROCEDURE process_order(
    IN p_order_id INTEGER,
    IN p_discount NUMERIC DEFAULT 0.1,
    IN p_priority VARCHAR DEFAULT 'NORMAL',
    IN p_notes VARCHAR DEFAULT NULL
) AS $$
BEGIN
    -- Business Logic
    RAISE NOTICE 'Processing order %', p_order_id;
END;
$$ LANGUAGE plpgsql;

-- Vertica Migration: Perfect PostgreSQL Compatibility
-- Step 1: Main procedure with all parameters (no defaults)
-- ⚠️  All overloaded versions below use the SAME name: process_order
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount FLOAT,
    p_priority VARCHAR,
    p_notes VARCHAR
) AS $$
BEGIN
    -- Core business logic here
    RAISE NOTICE 'Processing order: %, discount: %, priority: %, notes: %',
        p_order_id, p_discount, p_priority, p_notes;
END;
$$;

-- Step 2: Overloaded versions (simulate default parameter calls)
-- ⚠️  ALL variants use the SAME name "process_order" — only the parameter COUNT differs
-- Version 1: Only required parameters, all others use defaults
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, 0.1, 'NORMAL', NULL);
END;
$$;

-- Version 2: Partial parameters, remaining use defaults
-- ⚠️  SAME name "process_order" — 2 parameters instead of 4
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount FLOAT
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, p_discount, 'NORMAL', NULL);
END;
$$;

-- Version 3: More parameters, remaining use defaults
-- ⚠️  SAME name "process_order" — 3 parameters instead of 4
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount FLOAT,
    p_priority VARCHAR
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, p_discount, p_priority, NULL);
END;
$$;
```

#### 100% PostgreSQL-Compatible Calling Patterns

```sql
-- All PostgreSQL calling styles work perfectly without modification
CALL process_order(1001);                              -- All defaults: 0.1, 'NORMAL', NULL
CALL process_order(1001, 0.15);                       -- Partial: 0.15, 'NORMAL', NULL
CALL process_order(1001, 0.15, 'HIGH');              -- Partial: 0.15, 'HIGH', NULL
CALL process_order(1001, 0.15, 'HIGH', 'Urgent');    -- No defaults: all explicit

-- Explicit NULLs also work correctly (passed to main procedure)
CALL process_order(1001, NULL, NULL, NULL);          -- All NULLs
```

#### Key Advantages of This Approach

✅ **Perfect Compatibility** - Every PostgreSQL call pattern works unchanged
✅ **Correct NULL Handling** - Explicit NULLs vs defaults are properly distinguished
✅ **Maintainable** - Business logic exists only in main procedure
✅ **Zero Performance Impact** - Overloaded calls have minimal overhead
✅ **Future-Proof** - Easy to modify default values in one place

#### Default Parameter Migration Checklist

- [ ] **Create main procedure** with all parameters (no default syntax)
- [ ] **Create overloaded versions** for each combination of default parameters — ⚠️ **all with the SAME procedure name**
- [ ] **Call main procedure** from overloads with explicit default values
- [ ] **Test all calling patterns** to ensure PostgreSQL compatibility
- [ ] **Document default values** in procedure comments
- [ ] **Handle complex defaults** like `NOW()`, expressions correctly

### Basic Function/Procedure Structure

```sql
-- PostgreSQL
CREATE OR REPLACE FUNCTION get_employee_count(dept_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    emp_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE department_id = dept_id;
    
    RETURN emp_count;
END;
$$ LANGUAGE plpgsql;

-- Vertica PL/vSQL
CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id INTEGER,
    OUT p_count INTEGER
) AS $$
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;
```

### RETURN QUERY Pattern

```sql
-- PostgreSQL
CREATE OR REPLACE FUNCTION get_high_paid_employees(min_salary NUMERIC)
RETURNS SETOF employees AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM employees WHERE salary > min_salary;
END;
$$ LANGUAGE plpgsql;

-- Vertica (use cursors or temporary tables)
CREATE OR REPLACE PROCEDURE get_high_paid_employees(
    p_min_salary INTEGER
) AS $$
BEGIN
    -- Create temporary result table
    CREATE LOCAL TEMP TABLE result_employees ON COMMIT PRESERVE ROWS AS
    SELECT * FROM employees WHERE salary > p_min_salary;
END;
$$;
```

### Transaction Handling

```sql
-- PostgreSQL
BEGIN;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    
    -- Exception handling would be in a function
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;

-- Vertica
BEGIN
    PERFORM UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    PERFORM UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
```

### PERFORM Command Usage in PL/vSQL

In PL/vSQL, the PERFORM command is used to **discard the output** produced by SQL statements. In Vertica, every SQL statement that can execute outside a stored procedure produces a response:

- **DML** (INSERT, UPDATE, DELETE, MERGE) → outputs the number of rows affected
- **SELECT** and **CALL** → outputs `Tuples` or `Tuple`
- **DDL** (CREATE, ALTER, DROP, etc.), **COMMIT**, **ROLLBACK**, and other statements → outputs success/failure messages
- **EXECUTE** (dynamic SQL inside stored procedures) → can execute any of the above dynamic statements, producing the corresponding output (row counts, `Tuples`/`Tuple`, or status messages)

If the output is not captured via `var := SQL_STATEMENT`, `var <- SQL_STATEMENT`, `SELECT ... INTO ...`, or `EXECUTE ... INTO ...`, then `PERFORM` must be prepended to discard it.

#### When to Use PERFORM
- **DDL statements**: CREATE, ALTER, DROP, TRUNCATE, etc.
- **INSERT / UPDATE / DELETE / MERGE statements**: When you don't need the row count
- **SELECT statements**: When you want to discard the Tuples/Tuple output
- **CALL procedure statements**: When discarding the returned tuple
- **COMMIT / ROLLBACK**: When discarding the status message
- **EXECUTE (dynamic SQL)**: When you don't need to capture the result (row counts, Tuples/Tuple, or status messages)
- **Any SQL statement**: When you want to discard the return value

#### PERFORM Examples

```sql
-- Use PERFORM for DDL, DML, CALL, COMMIT, ROLLBACK to discard output
PERFORM INSERT INTO audit_log (message, created_at)
VALUES ('Processing started', SYSDATE());

PERFORM UPDATE employees
SET last_updated = SYSDATE()
WHERE status = 'ACTIVE';

PERFORM DELETE FROM temp_data
WHERE processed_date < CURRENT_DATE - 30;

-- PERFORM with EXECUTE: discards output (row counts, Tuples/Tuple, or status messages) from dynamic SQL
PERFORM EXECUTE 'UPDATE employees SET last_updated = SYSDATE()';
```

#### Checking Results After PERFORM

```sql
-- Use FOUND special variable to check if operation succeeded
PERFORM UPDATE employees SET salary = salary * 1.1;
IF FOUND THEN
    RAISE NOTICE 'Update was successful';
ELSE
    RAISE NOTICE 'No rows were updated';
END IF;

-- Or use separate query to get count if needed
PERFORM INSERT INTO summary_table VALUES ('test');
SELECT COUNT(*) INTO v_count FROM summary_table WHERE name = 'test';
```

#### DML Return Values Difference

**PostgreSQL**: INSERT, UPDATE, DELETE return void.
**Vertica**: INSERT, UPDATE, DELETE return the number of rows affected. You can capture this directly without `GET DIAGNOSTICS`:

```sql
-- Vertica: Capture affected row count directly from DML
DECLARE
    v_count INTEGER;
BEGIN
    v_count := UPDATE customers SET status = 'active';
    RAISE NOTICE 'Updated % rows', v_count;
END;
```

In PostgreSQL, you would use `GET DIAGNOSTICS v_count = ROW_COUNT;` after DML. In Vertica, simply assign the DML result directly.

### Dynamic SQL Execution

```sql
-- PostgreSQL: Execute dynamic SQL and assign result to variable
DO $$
DECLARE
    table_name VARCHAR(100) := 'employees';
    row_count INTEGER;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM ' || table_name INTO row_count;
    RAISE NOTICE 'Row count: %', row_count;
END;
$$;

-- Vertica: Execute dynamic SQL and assign result to variable
DO $$
DECLARE
    table_name VARCHAR(100) := 'employees';
    row_count INTEGER;
BEGIN
    row_count := EXECUTE 'SELECT COUNT(*) FROM ' || table_name;
    RAISE NOTICE 'Row count: %', row_count;
END
$$;
```


### Error Handling and Exceptions

Vertica PL/vSQL provides `SQLSTATE` and `SQLERRM` built-in variables directly in exception handlers. Use `GET STACKED DIAGNOSTICS` only when more detailed error information (such as detail, hint, context) is needed.

> **Note**: Certain SQLSTATE error codes differ between PostgreSQL and Vertica. Review and update exception handling code accordingly during migration.

#### Simple Cases: Use SQLSTATE / SQLERRM Directly

```sql
-- PostgreSQL
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No data found';
    WHEN TOO_MANY_ROWS THEN
        RAISE NOTICE 'Too many rows';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;

-- Vertica: directly use SQLSTATE and SQLERRM variables
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No data found';
    WHEN TOO_MANY_ROWS THEN
        RAISE NOTICE 'Too many rows';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
```

#### Detailed Error Info: Use GET STACKED DIAGNOSTICS

```sql
-- Vertica: use GET STACKED DIAGNOSTICS for detailed error info
EXCEPTION
    WHEN OTHERS THEN
        DECLARE
            v_msg VARCHAR;
            v_detail VARCHAR;
            v_hint VARCHAR;
            v_context VARCHAR;
        BEGIN
            GET STACKED DIAGNOSTICS
                v_msg = MESSAGE_TEXT,
                v_detail = DETAIL_TEXT,
                v_hint = HINT_TEXT,
                v_context = EXCEPTION_CONTEXT;
            RAISE EXCEPTION 'Error: %, Detail: %, Hint: %, Context: %',
                v_msg, v_detail, v_hint, v_context;
        END;
```

## Function Migration Strategies Overview

This guide covers multiple PostgreSQL function migration approaches:

1. **SQL Function to Subquery Conversion** - For functions used in SELECT statements, convert to LEFT JOIN subqueries for optimal performance
2. **Function to Stored Procedure** - Convert return values to OUT parameters for procedural logic
3. **User-Defined SQL Functions** - For simple transformations that can be expressed in SQL
4. **UDx Development** - For complex logic requiring C++, Python, Java, or R

## Function Migration Strategies

PostgreSQL functions can be migrated to Vertica using multiple approaches. The choice depends on the function's complexity, performance requirements, and usage patterns.

### Strategy 1: SQL Function to Subquery Conversion (Performance-Optimized)

For PostgreSQL SQL functions that can be expressed as a query and are used in SELECT statements, convert them to subqueries with LEFT JOIN for better performance in Vertica's columnar architecture.

```sql
-- PostgreSQL SQL Function and Query
CREATE OR REPLACE FUNCTION is_active_user(p_user_id VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM active_users u WHERE u.user_id = p_user_id;
    IF (v_count > 0) THEN
        RETURN '1';
    ELSE
        RETURN '0';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT user_id, user_name, is_active_user(user_id) AS is_active
FROM all_users;

-- Vertica Migration: Convert to LEFT JOIN subquery
SELECT a.user_id, a.user_name,
  (CASE WHEN au.user_id IS NOT NULL THEN '1' ELSE '0' END) AS is_active
FROM all_users a LEFT JOIN active_users au ON a.user_id = au.user_id;
```

**Benefits of Subquery Approach:**

- **Better Performance**: Leverages Vertica's optimized JOIN operations
- **Set-Based Processing**: Eliminates row-by-row function calls
- **Performance Optimization**: Allows Vertica to optimize the entire query plan

**Best Use Cases:**

- Functions that query other tables
- Functions that can be expressed as a query
- Functions used in SELECT clauses with table data
- Performance-critical queries

### Strategy 2: Function to Stored Procedure Migration

PostgreSQL functions can be effectively migrated to Vertica stored procedures by converting the return value to an additional OUT parameter. This approach maintains PostgreSQL-like semantics while leveraging Vertica's stored procedure capabilities.

#### Key Migration Pattern

**Tuple Unpacking Assignment**: When a stored procedure has OUT or INOUT parameters, `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The `:=` assignment unpacks the tuple's columns into variables by position:

```sql
-- CALL returns a tuple; := unpacks it into variables
var_return := CALL procedure_name([params]);                         -- single OUT → scalar
var_out1, var_out2, var_return := CALL procedure_name([params]);     -- multiple OUTs → unpack
```

#### Migration Examples

##### Pattern 1: Simple Function with Return Value

```sql
-- PostgreSQL Function
CREATE OR REPLACE FUNCTION get_config_value()
RETURNS VARCHAR AS $$
DECLARE
    v_value VARCHAR(100);
BEGIN
    SELECT config_value INTO v_value FROM app_config WHERE config_key = 'SYSTEM_NAME';
    RETURN v_value;
END;
$$ LANGUAGE plpgsql;

-- Usage in PostgreSQL
DO $$
DECLARE
    v_val VARCHAR(100);
BEGIN
    v_val := get_config_value();
    RAISE NOTICE 'Config value: %', v_val;
END;
$$;

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_config_value(
    OUT rt VARCHAR(100)
) AS $$
BEGIN
    SELECT config_value INTO rt FROM app_config WHERE config_key = 'SYSTEM_NAME';
END;
$$;

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
    v_val VARCHAR(100);
BEGIN
    v_val := CALL get_config_value();
    RAISE INFO 'Config value: %', v_val;
END
$$;
```

##### Pattern 2: Function with Input Parameters

```sql
-- PostgreSQL Function
CREATE OR REPLACE FUNCTION get_department_name(
    p_dept_id INTEGER
) RETURNS VARCHAR AS $$
DECLARE
    v_name VARCHAR(100);
BEGIN
    SELECT dept_name INTO v_name FROM departments WHERE department_id = p_dept_id;
    RETURN v_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Usage in PostgreSQL
DO $$
DECLARE
    v_name VARCHAR(100);
BEGIN
    v_name := get_department_name(10);
    RAISE NOTICE 'Department: %', v_name;
END;
$$;

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_department_name(
    p_dept_id INTEGER,
    OUT rt VARCHAR(100)
) AS $$
BEGIN
    SELECT dept_name INTO rt FROM departments WHERE department_id = p_dept_id;
END;
$$;

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
    v_name VARCHAR(100);
BEGIN
    v_name := CALL get_department_name(10);
    RAISE INFO 'Department: %', v_name;
END
$$;
```

##### Pattern 3: Complex Function with Multiple Return Values

```sql
-- PostgreSQL Function (returning SETOF or TABLE)
CREATE OR REPLACE FUNCTION get_department_stats(
    p_dept_id INTEGER
) RETURNS TABLE(emp_count INTEGER, avg_salary NUMERIC, max_salary NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*)::INTEGER, AVG(salary), MAX(salary)
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$ LANGUAGE plpgsql;

-- Usage in PostgreSQL
SELECT * FROM get_department_stats(10);

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_department_stats(
    p_dept_id INTEGER,
    OUT emp_count INTEGER,
    OUT avg_salary NUMERIC(10,2),
    OUT max_salary NUMERIC(10,2)
) AS $$
BEGIN
    SELECT COUNT(*)::INTEGER, AVG(salary), MAX(salary)
    INTO emp_count, avg_salary, max_salary
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
    v_count INTEGER;
    v_avg NUMERIC;
    v_max NUMERIC;
BEGIN
    v_count, v_avg, v_max := CALL get_department_stats(10);
    RAISE INFO 'Count: %, Avg: %, Max: %', v_count, v_avg, v_max;
END
$$;
```

#### Key Benefits of Stored Procedure Approach

1. **PostgreSQL-like Semantics**: Maintains familiar variable assignment patterns
2. **Multiple Return Values**: Supports both OUT parameters and return values
3. **Error Handling**: Enables robust error checking and exception handling
4. **Code Reusability**: Procedures can call other procedures seamlessly
5. **Type Safety**: Compile-time type checking for parameters

### Function Migration Best Practices

**For Subquery Conversion:**
1. **Analyze JOIN cardinality**: Ensure the LEFT JOIN doesn't create performance issues
2. **Test with NULL handling**: Verify behavior matches original function logic
3. **Monitor query plans**: Use EXPLAIN to verify optimal execution

**For Stored Procedure Migration:**

1. **Handle NOT FOUND cases explicitly** using the FOUND special variable
2. **Use DO blocks for testing** and standalone execution of migrated functions
3. **Declare all variables** in the DECLARE section before use
4. **Test variable assignments thoroughly** after migration

### Choosing the Right Migration Strategy

| Function Type | Recommended Strategy | Rationale |
|---------------|---------------------|-----------|
| Table lookup functions | Subquery with LEFT JOIN | Better performance, set-based processing |
| Complex business logic | Stored Procedure with OUT | Maintains procedural logic, easier migration |
| Mathematical calculations | User-Defined SQL Function | Simple conversion, inline execution |
| Multi-statement functions | Stored Procedure with OUT | Preserves logic flow, error handling |
| Functions in WHERE clauses | Subquery or CASE expressions | Enables query optimization |

**Migration Decision Checklist:**
- [ ] **Analyze function usage**: Check if used in SELECT, WHERE, or JOIN clauses
- [ ] **Consider complexity**: Simple lookups → subquery, complex logic → procedures

## Performance Optimization

### Query Optimization Strategies

1. **Update Statistics**: Use Vertica's statistics management
   ```sql
   SELECT ANALYZE_STATISTICS('table_name');
   ```

2. **Handling PostgreSQL Analytic Functions with Projection Design**

```sql
-- PostgreSQL analytic query
SELECT employee_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank,
       LAG(salary, 1) OVER (ORDER BY hire_date) as prev_salary
FROM employees;

-- Vertica (same syntax, and can boost performance with proper projection design)
CREATE PROJECTION employees_analytic
AS SELECT employee_id, department_id, salary, hire_date
FROM employees
ORDER BY department_id, salary DESC, hire_date
SEGMENTED BY HASH(employee_id) ALL NODES;
```

3. **Converting PostgreSQL Hints**

Most PostgreSQL hints do not work for Vertica, so just comment them out.

```sql
-- PostgreSQL hints
SELECT /*+ IndexScan(employees emp_dept_idx) */ *
FROM employees
WHERE department_id = 10;

-- Vertica comments hints out
SELECT /* IndexScan(employees emp_dept_idx) */ *
FROM employees
WHERE department_id = 10;
```

## Common Migration Challenges

### 0. Identifier Case Sensitivity

**Difference**: PostgreSQL unquoted identifiers are case-insensitive (folded to lowercase); quoted identifiers (`"..."`) are **case-sensitive**. Vertica identifiers are **always case-insensitive**, whether quoted or not.

**Impact**: Objects that differ only by case in PostgreSQL (e.g., `"MyTable"` vs `"mytable"`) will **conflict** in Vertica.

**Solution**: Audit for identifiers that differ only by case and rename them. Adopt a consistent naming convention (e.g., `snake_case`). Remove unnecessary double quotes.

```sql
-- PostgreSQL: these are two different objects
CREATE TABLE "MyTable" (id INT);
CREATE TABLE "mytable" (id INT);

-- Vertica: the second CREATE will fail — rename one
CREATE TABLE MyTable (id INT);
CREATE TABLE my_table (id INT);  -- renamed to avoid conflict
```

### 1. Sequences
**Challenge**: PostgreSQL sequences vs Vertica IDENTITY columns
**Solution**: Convert to IDENTITY or use sequences

```sql
-- PostgreSQL
CREATE SEQUENCE emp_seq;
CREATE TABLE employees (
    emp_id INTEGER DEFAULT NEXTVAL('emp_seq'),
    emp_name VARCHAR(100)
);

-- Vertica alternatives
-- Option 1: IDENTITY (preferred)
CREATE TABLE employees (
    emp_id IDENTITY,
    emp_name VARCHAR(100)
);

-- Option 2: Sequence (if needed)
CREATE SEQUENCE emp_seq;
CREATE TABLE employees (
    emp_id INTEGER DEFAULT NEXTVAL('emp_seq'),
    emp_name VARCHAR(100)
);
```

### 2. Temporary Tables
**Challenge**: PostgreSQL temporary tables have session scope
**Solution**: Use Vertica's local temporary tables

```sql
-- PostgreSQL
CREATE TEMP TABLE temp_results AS
SELECT * FROM complex_query;

-- Vertica
CREATE LOCAL TEMP TABLE temp_results AS
SELECT * FROM complex_query;
```

### 3. Arrays
**Challenge**: PostgreSQL has rich array support
**Solution**: Use Vertica's ARRAY type or normalize data. See [Array/Collection Type Mappings](data-type-mapping.md#arraycollection-type-mappings) for complete migration patterns.

```sql
-- PostgreSQL
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100),
    employee_ids INTEGER[]
);

-- Vertica options
-- Option 1: Use ARRAY type
CREATE TABLE departments (
    dept_id IDENTITY PRIMARY KEY,
    dept_name VARCHAR(100),
    employee_ids ARRAY[INTEGER]
);

-- Option 2: Normalize (preferred for large datasets)
CREATE TABLE department_employees (
    dept_id INTEGER,
    emp_id INTEGER,
    PRIMARY KEY (dept_id, emp_id)
);
```

### 4. JSON Support

**Challenge**: PostgreSQL has extensive JSON/JSONB support with rich query operators (`->`, `->>`, `#>`, etc.) and functions (`json_each`, `json_array_elements`, etc.). Vertica does not have native JSON type support.

**Solution**: Use **Vertica Flex Tables** to store and query JSON data. Flex Tables load JSON natively into an internal VMap structure, allowing you to query virtual columns directly without pre-defining a schema. For known JSON structures, you can also materialize frequently accessed keys as real columns (hybrid table).

See [JSON and Semi-Structured Data](data-type-mapping.md#json-and-semi-structured-data) for decision guidance and [CREATE FLEX TABLE](sql-syntax-reference.md#create-flex-table) for complete syntax reference.

#### Step 1: Create a flex table

```sql
-- Pure flex table (no column definitions needed)
CREATE FLEX TABLE json_events();

-- Hybrid flex table with some known columns materialized
CREATE FLEX TABLE json_events(
    event_type VARCHAR,
    created_at TIMESTAMP
);
```

#### Step 2: Load JSON data

```sql
-- Load JSON using the built-in fjsonparser
COPY json_events FROM '/data/events.json' PARSER fjsonparser();

-- Or load from another table's JSON column
INSERT INTO json_events(col) SELECT json_col FROM source_table;
```

#### Step 3: Compute keys and build a view

```sql
-- Discover all keys in the loaded JSON data
SELECT compute_flextable_keys_and_build_view('json_events');
-- View: json_events_view is ready for querying

-- Inspect discovered keys and their data types
SELECT * FROM json_events_keys;
```

#### Step 4: Query JSON data using virtual columns

```sql
-- Query virtual columns directly (quoted identifiers, case-insensitive)
SELECT "user.name", "user.lang", "event_type", "created_at"
FROM json_events;

-- Cast virtual columns to appropriate types
SELECT "created_at"::TIMESTAMP, "retweet_count"::INT
FROM json_events
ORDER BY "created_at"::TIMESTAMP DESC;

-- Aggregate functions on virtual columns
SELECT "user.lang", COUNT(*), AVG(LENGTH("text"))::INT
FROM json_events
GROUP BY "user.lang"
ORDER BY 2 DESC;
```

#### Step 5: Materialize frequently accessed columns (optional)

```sql
-- Promote frequently queried virtual columns to real columns for better performance
ALTER TABLE json_events ADD COLUMN IF NOT EXISTS user_id BIGINT;
UPDATE json_events SET user_id = "user.id"::BIGINT;

-- Or materialize multiple columns at once
SELECT MATERIALIZE_FLEXTABLE_COLUMNS('json_events');
```

#### PostgreSQL to Vertica JSON Query Mapping

| PostgreSQL | Vertica Flex Table |
|------------|-------------------|
| `data->>'name'` (get text) | `"name"` (virtual column) |
| `data->'name'` (get JSON) | `"name"` (virtual column, returns text) |
| `(data->>'age')::INTEGER` | `"age"::INT` (cast virtual column) |
| `data @> '{"key":"value"}'` | `MAPLOOKUP(__raw__, 'key') = 'value'` |
| `json_each(data)` | Query `flex_table_keys` table |
| `data IS NOT NULL` | `__raw__ IS NOT NULL` |

```sql
-- PostgreSQL: Query nested JSON with containment operator
SELECT data->'user'->>'name' AS name
FROM json_table
WHERE data @> '{"status": "active"}';

-- Vertica Flex Table equivalent
SELECT "user.name" AS name
FROM json_events
WHERE status = 'active';
```

### 5. Recursive CTE Migration

**Challenge**: PostgreSQL and Vertica both support standard `WITH RECURSIVE` CTEs with nearly identical syntax, but Vertica has stricter limitations on the recursive term and a much lower default recursion depth.

#### Key Differences at a Glance

| Feature | PostgreSQL | Vertica |
|---------|-----------|---------|
| `WITH RECURSIVE` syntax | ✅ Standard | ✅ Standard (identical) |
| Default recursion depth | **Unlimited** | **8** (`WithClauseRecursionLimit`) |
| `CYCLE` clause | ✅ `CYCLE id SET is_cycle USING path` | ❌ **Not supported** |
| `SEARCH DEPTH/BREADTH FIRST` | ✅ `SEARCH DEPTH FIRST BY col SET order` | ❌ **Not supported** |
| `*` in anchor term | ✅ Allowed | ❌ **Not allowed** |
| Multiple CTE references in recursive term | ✅ Allowed | ❌ **Only 1 reference** |
| Outer join in recursive term | ✅ Allowed | ❌ **Not allowed** |
| Subquery referencing CTE in recursive term | ✅ Allowed | ❌ **Not allowed** |
| `LIMIT` / `ORDER BY` inside UNION | ✅ Allowed | ❌ **Not allowed** |
| **INSERT + CTE order** | **`WITH` before INSERT**: `WITH cte AS (...) INSERT INTO t SELECT ...` | **`INSERT` before WITH**: `INSERT INTO t WITH cte AS (...) SELECT ...` |

#### Critical: INSERT + CTE Syntax Order Is Reversed

**This is a key syntactic difference that affects every CTE used with INSERT.** In PostgreSQL, the `WITH` clause comes *before* `INSERT`. In Vertica, `INSERT` comes *before* `WITH`:

```sql
-- ❌ PostgreSQL syntax (fails in Vertica)
WITH emp_count AS (
    SELECT dept_id, COUNT(*) AS cnt
    FROM employees
    GROUP BY dept_id
)
INSERT INTO dept_summary
SELECT dept_id, cnt FROM emp_count;

-- ✅ Vertica syntax: INSERT first, then WITH
INSERT INTO dept_summary
WITH emp_count AS (
    SELECT dept_id, COUNT(*) AS cnt
    FROM employees
    GROUP BY dept_id
)
SELECT dept_id, cnt FROM emp_count;
```

This also applies to recursive CTEs:

```sql
-- ❌ PostgreSQL: WITH before INSERT
WITH RECURSIVE emp_hierarchy AS (
    SELECT employee_id, manager_id, 1 AS level
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
INSERT INTO hierarchy_table
SELECT * FROM emp_hierarchy;

-- ✅ Vertica: INSERT before WITH RECURSIVE
INSERT INTO hierarchy_table
WITH RECURSIVE emp_hierarchy AS (
    SELECT employee_id, manager_id, 1 AS level
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;
```

> **Note**: When using `SELECT` alone (without `INSERT`), both databases use the same order: `WITH cte AS (...) SELECT * FROM cte`. The difference only appears when combining `INSERT` with a CTE.

#### Critical: Recursion Depth Limit

**This is the most common migration issue.** PostgreSQL has no recursion depth limit by default, while Vertica defaults to **only 8**. Deep hierarchies will be **silently truncated without error**.

```sql
-- PostgreSQL: no depth limit by default
WITH RECURSIVE emp_hierarchy AS (
    SELECT employee_id, manager_id, name, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;

-- Vertica: must increase the limit
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 100;

WITH RECURSIVE emp_hierarchy AS (
    SELECT employee_id, manager_id, name, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;
```

#### Critical: `CYCLE` Clause Not Supported

PostgreSQL's `CYCLE` clause provides automatic cycle detection. Vertica has **no equivalent**. You must handle cycles manually:

```sql
-- ❌ PostgreSQL: automatic cycle detection
WITH RECURSIVE emp_chain AS (
    SELECT employee_id, name, 1 AS level
    FROM employees
    WHERE employee_id = 1
    UNION ALL
    SELECT e.employee_id, e.name, ec.level + 1
    FROM employees e
    JOIN emp_chain ec ON e.manager_id = ec.employee_id
)
CYCLE employee_id SET is_cycle USING path
SELECT * FROM emp_chain WHERE NOT is_cycle;

-- ✅ Vertica: manual depth guard
WITH RECURSIVE emp_chain AS (
    SELECT employee_id, name, 1 AS level
    FROM employees
    WHERE employee_id = 1
    UNION ALL
    SELECT e.employee_id, e.name, ec.level + 1
    FROM employees e
    JOIN emp_chain ec ON e.manager_id = ec.employee_id
    WHERE ec.level < 50   -- manual guard against circular references
)
SELECT employee_id, name, level FROM emp_chain;
```

#### Critical: `SEARCH DEPTH/BREADTH FIRST` Not Supported

PostgreSQL supports explicit traversal order control. Vertica does not:

```sql
-- ❌ PostgreSQL: depth-first ordering
WITH RECURSIVE emp_tree AS (
    SELECT employee_id, name
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name
    FROM employees e
    JOIN emp_tree et ON e.manager_id = et.employee_id
)
SEARCH DEPTH FIRST BY employee_id SET ordercol
SELECT * FROM emp_tree ORDER BY ordercol;

-- ✅ Vertica: simulate depth-first via path column
WITH RECURSIVE emp_tree AS (
    SELECT employee_id, name,
           '/' || LPAD(employee_id::VARCHAR, 10) AS sort_path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name,
           et.sort_path || '/' || LPAD(e.employee_id::VARCHAR, 10)
    FROM employees e
    JOIN emp_tree et ON e.manager_id = et.employee_id
)
SELECT employee_id, name FROM emp_tree ORDER BY sort_path;
```

#### Non-Recursive Term Cannot Use `*`

```sql
-- ❌ PostgreSQL allows, but Vertica does NOT
WITH RECURSIVE cte AS (
    SELECT * FROM employees WHERE manager_id IS NULL  -- ERROR in Vertica
    UNION ALL
    SELECT * FROM employees e JOIN cte ON ...
)
SELECT * FROM cte;

-- ✅ Explicit column list required in Vertica
WITH RECURSIVE cte AS (
    SELECT employee_id, manager_id, name
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name
    FROM employees e JOIN cte ON e.manager_id = cte.employee_id
)
SELECT * FROM cte;
```

#### Recursive Term Restrictions

```sql
-- ❌ PostgreSQL: multiple CTE references in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM cte a JOIN cte b ON a.id = b.parent_id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ PostgreSQL: outer join in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM employees e
    LEFT JOIN cte ON e.manager_id = cte.id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ PostgreSQL: subquery referencing CTE in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM employees e
    WHERE e.id IN (SELECT id FROM cte)  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ✅ Vertica: rewrite subquery as JOIN
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM employees e
    JOIN cte ON e.id = cte.id
)
SELECT * FROM cte;
```

#### CTE Variable Assignment in Stored Procedures

**PostgreSQL PL/pgSQL** uses `SELECT ... INTO var FROM cte` to assign CTE results to variables. **Vertica PL/vSQL** uses a different syntax: `var := WITH cte AS (...) SELECT ...`, where the entire `WITH ... SELECT` is the expression being assigned. Parentheses are optional:

```sql
-- ❌ PostgreSQL PL/pgSQL syntax (fails in Vertica)
SELECT cnt INTO v_count FROM (
    WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
    SELECT cnt FROM cte
);

-- ✅ Vertica syntax 1: direct assignment (preferred)
v_count := WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
            SELECT cnt FROM cte;

-- ✅ Vertica syntax 2: with parentheses
v_count := (
    WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
    SELECT cnt FROM cte
);

-- ✅ Vertica syntax 3: SELECT INTO with subquery wrapper
SELECT COUNT(*) INTO v_count
FROM (WITH cte AS (SELECT * FROM employees) SELECT * FROM cte) t;
```

For recursive CTEs, the same rules apply:

```sql
-- ✅ Vertica: assign recursive CTE result to variable
v_count := WITH RECURSIVE emp_tree AS (
               SELECT employee_id, manager_id, 1 AS level
               FROM employees WHERE manager_id IS NULL
               UNION ALL
               SELECT e.employee_id, e.manager_id, et.level + 1
               FROM employees e JOIN emp_tree et ON e.manager_id = et.employee_id
           )
           SELECT COUNT(*) FROM emp_tree;
```

> **Note**: `SELECT ... INTO var WITH CTE ...` (without a subquery wrapper) is **not valid** in Vertica. Use `var := WITH ... SELECT ...` instead.

#### Performance Consideration: Materialization for Deep Recursion

```sql
-- Enable materialization for deep hierarchies (>20 levels)
ALTER SESSION SET PARAMETER WithClauseMaterialization = 1;

-- Or use query-level hint
WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ RECURSIVE
    emp_hierarchy AS (...)
SELECT * FROM emp_hierarchy;
```

### 6. Full-Text Search

**Challenge**: PostgreSQL has built-in full-text search with `to_tsvector()`, `to_tsquery()`, and the `@@` operator, supporting language-specific stemming, ranking (`ts_rank`), and weighted search.

**Solution**: Use **Vertica Text Index** for efficient keyword search on text columns. Vertica text indexes use the Porter stemming algorithm and support case-sensitive/insensitive search, combined keyword queries, and exclusion patterns.

See [CREATE TEXT INDEX](sql-syntax-reference.md#create-text-index) for complete syntax reference.

#### Step 1: Create a text index

```sql
-- Create a text index with default case-insensitive stemmer
CREATE TEXT INDEX articles_text_idx ON articles (id, content);

-- Create with case-sensitive stemmer (for exact case matching)
CREATE TEXT INDEX articles_text_cs_idx ON articles (id, content)
    STEMMER v_txtindex.StemmerCaseSensitive(long varchar)
    TOKENIZER v_txtindex.StringTokenizer(long varchar);

-- Create with no stemming (exact word match only)
CREATE TEXT INDEX articles_text_exact_idx ON articles (id, content)
    STEMMER NONE
    TOKENIZER v_txtindex.StringTokenizer(long varchar);
```

> **Prerequisites**: The source table must have a primary key, and a projection sorted and segmented by that key.

#### Step 2: Query the text index

```sql
-- PostgreSQL: Full-text search with language-specific stemming
SELECT * FROM articles
WHERE to_tsvector('english', content) @@ to_tsquery('english', 'search term');

-- Vertica: Search text index (case-insensitive with default stemmer)
SELECT * FROM articles
WHERE id IN (
    SELECT doc_id FROM articles_text_idx
    WHERE token = v_txtindex.StemmerCaseInsensitive('search term')
);

-- Case-sensitive search
SELECT * FROM articles
WHERE id IN (
    SELECT doc_id FROM articles_text_cs_idx
    WHERE token = v_txtindex.StemmerCaseSensitive('Search Term')
);
```

#### Step 3: Advanced queries (include/exclude keywords)

```sql
-- PostgreSQL: Weighted full-text search with ranking
SELECT *, ts_rank(to_tsvector('english', content), to_tsquery('english', 'search & term')) AS rank
FROM articles
WHERE to_tsvector('english', content) @@ to_tsquery('english', 'search & term')
ORDER BY rank DESC;

-- Vertica: Combined keyword search (AND / OR / NOT)
SELECT * FROM articles WHERE
    -- Must contain both 'search' AND 'term'
    id IN (SELECT doc_id FROM articles_text_idx WHERE token = v_txtindex.StemmerCaseInsensitive('search'))
    AND id IN (SELECT doc_id FROM articles_text_idx WHERE token = v_txtindex.StemmerCaseInsensitive('term'));

-- Vertica: Search with exclusion (contains 'search' but NOT 'exclude')
SELECT * FROM articles WHERE
    id IN (SELECT doc_id FROM articles_text_idx WHERE token = v_txtindex.StemmerCaseInsensitive('search'))
    AND NOT (id IN (SELECT doc_id FROM articles_text_idx WHERE token = v_txtindex.StemmerCaseInsensitive('exclude')));
```

#### PostgreSQL to Vertica Full-Text Search Mapping

| PostgreSQL | Vertica Text Index |
|------------|-------------------|
| `to_tsvector('english', content) @@ to_tsquery('english', 'term')` | `id IN (SELECT doc_id FROM idx WHERE token = v_txtindex.StemmerCaseInsensitive('term'))` |
| `to_tsquery('english', 'search & term')` (AND) | Two `IN (...)` subqueries joined with `AND` |
| `to_tsquery('english', 'search \| term')` (OR) | Two `IN (...)` subqueries joined with `OR` |
| `to_tsquery('english', '!exclude')` (NOT) | `NOT (id IN (...))` |
| `ts_rank(tsvector, tsquery)` | No direct equivalent; use `COUNT` of matching tokens |
| `to_tsvector('english', content)` with stemming | Default `StemmerCaseInsensitive` handles stemming |
| `plainto_tsquery('english', 'search term')` | Search each word separately with `AND` |
| `phraseto_tsquery('english', 'search term')` | No direct equivalent; use `LIKE '%search term%'` |

#### Stemmer Behavior Comparison

| Feature | PostgreSQL | Vertica |
|---------|-----------|---------|
| Stemming algorithm | Language-specific dictionaries | Porter stemming algorithm |
| Case-insensitive | `to_tsvector('english', ...)` | `v_txtindex.StemmerCaseInsensitive` (default) |
| Case-sensitive | Not built-in | `v_txtindex.StemmerCaseSensitive` |
| No stemming | `to_tsvector('simple', ...)` | `STEMMER NONE` |
| Multi-language | Multiple dictionaries | `v_txtindex.ICUTokenizer` with locale |

#### Performance Considerations

- Text index adds overhead to DML operations (INSERT/UPDATE/DELETE) due to background index sync
- Regular queries on the source table are not affected
- For frequently queried text columns, the performance gain from text index outweighs the DML overhead
- Use `STEMMER NONE` for exact match scenarios to reduce index size
- For flex table text columns, use `public.FlexTokenizer(long varbinary)` with the `__raw__` column

```sql
-- Token length configuration (default: 128, max: 65000)
ALTER DATABASE DEFAULT SET PARAMETER TextIndexMaxTokenLength = 760;
```

## Migration Best Practices

### 1. Assessment Phase
- **Analyze PostgreSQL schema complexity** and identify conversion challenges
- **Document PostgreSQL-specific features** that need alternative approaches
- **Catalog all SQL functions** and determine optimal migration strategy (subquery vs stored procedure)
- **Identify function usage patterns** in SELECT, WHERE, and JOIN clauses for subquery conversion opportunities

### 2. Conversion Phase
- **Perform one-to-one migration**, that is, tables are migrated to tables, views to views, stored procedures to PL/vSQL stored procedures, functions to User-Defined SQL functions or PL/vSQL stored procedures, and DML statements to DML statements.
- **Test each component** before moving to the next

### 3. Optimization Phase
- **Bulk Insert** with multiple comma-delimited VALUES lists for better performance
- **Favor batch/set-based processing** operations over iterative row processing to maximize performance
- **Update statistics** after data migration

### 4. Common Pitfalls to Avoid
- **Don't use PostgreSQL-style indexing** - Just comment them out
- **Avoid excessive procedural logic** - prefer set-based operations
- **Don't ignore data type precision** - affects storage and performance (e.g., INTEGER is 8 bytes in Vertica vs 4 bytes in PostgreSQL)
- **Don't forget to update statistics** - critical for query optimization
- **NEVER remove OUT/INOUT keywords** - this breaks parameter logic completely
- **NEVER use DEFAULT syntax** in parameter declarations - use procedure overloading instead
- **Replace direct DML with PERFORM** - Vertica requires PERFORM for DDL (CREATE, ALTER, DROP, TRUNCATE, etc.) and DML (INSERT/UPDATE/DELETE/MERGE) in PL/vSQL to ignore rows number affected
- **Review NULL handling** - Vertica does not coerce NULL to FALSE by default; set `PLvSQLCoerceNull = 1` if needed
- **Use correct FOR loop keywords** - Vertica requires QUERY, CURSOR, or RANGE keywords in FOR loops
- **Capture DML return values directly** - Vertica DML returns affected row count; no need for `GET DIAGNOSTICS ... ROW_COUNT`
- **Test transaction behavior** - Vertica commits before procedure execution; plan accordingly
- **Check parameter types** - DECIMAL, NUMERIC, NUMBER, MONEY, UUID are not supported as parameter types

### 5. Common Migration Errors and Solutions

#### Error: Parameter keywords removed
**Problem**: `p_count OUT INTEGER` becomes `p_count INTEGER`
**Solution**: Always preserve OUT/INOUT: `OUT p_count INTEGER`

#### Error: Incorrect data type for parameters
**Problem**: `NUMERIC` type used as parameter
**Solution**: Use `INTEGER` or `FLOAT` instead

#### Error: Missing parameter mode specification
**Problem**: `INOUT` parameters converted to plain parameters
**Solution**: Always specify `INOUT` for bidirectional parameters

#### Error: Incorrect exception handling
**Problem**: Using `PG_EXCEPTION_DETAIL`, `PG_EXCEPTION_HINT`, `PG_EXCEPTION_CONTEXT` (PostgreSQL names) in Vertica
**Solution**: In Vertica, use `SQLSTATE` and `SQLERRM` directly for basic error info. For detailed info, use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` (not the PostgreSQL variants)

## Tools and Utilities

### Data Migration
```sql
-- Use COPY command for bulk data loading
COPY employees FROM '/path/to/employees.csv' 
DELIMITER ',' SKIP 1;
```

### Schema Validation
```sql
-- Compare row counts
SELECT 'source' as source, COUNT(*) as count FROM pg_employees
UNION ALL
SELECT 'target' as source, COUNT(*) as count FROM vertica_employees;
```

## Troubleshooting

### Common Issues
1. **Data Type Mismatches**: Check precision and scale differences
2. **Performance Degradation**: Review projection design and statistics
3. **Function Incompatibilities**: Use function mapping guide for alternatives
4. **Transaction Differences**: Understand Vertica's transaction model

## Example Migration Workflow

### Step 1: Schema Assessment
```sql
-- Document current PostgreSQL schema
SELECT table_name, column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

### Step 2: Schema Conversion
```sql
-- Convert to Vertica schema
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    hire_date DATE,
    salary NUMERIC(10,2),
    dept_id SMALLINT
);
```

### Step 3: Data Migration
```sql
-- Bulk load data
COPY employees FROM '/data/employees.csv' 
DELIMITER ',' ENCLOSED BY '"' SKIP 1;
```

### Step 4: Code Migration

Simple function to procedure conversion:

```sql
-- Convert functions to procedures
CREATE OR REPLACE PROCEDURE update_salary(
    p_emp_id INTEGER,
    p_new_salary INTEGER
) AS $$
BEGIN
    PERFORM UPDATE employees
    SET salary = p_new_salary
    WHERE emp_id = p_emp_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee % not found', p_emp_id;
    END IF;
END;
$$;
```

Complete PL/pgSQL to PL/vSQL migration example:

```sql
-- PostgreSQL PL/pgSQL
CREATE FUNCTION process_data(p_id INTEGER) RETURNS VOID AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Direct INSERT (PostgreSQL style)
    INSERT INTO log_table VALUES (p_id, 'Processing');

    -- NULL comparison (PostgreSQL style)
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'ID cannot be null';
    END IF;

    UPDATE main_table SET processed = TRUE WHERE id = p_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
END;
$$ LANGUAGE plpgsql;

-- Vertica PL/vSQL (migrated)
CREATE PROCEDURE process_data(p_id INTEGER) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Use PERFORM for DDL, DML
    PERFORM INSERT INTO log_table VALUES (p_id, 'Processing');

    -- Explicit NULL check (or set PLvSQLCoerceNull = 1)
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'ID cannot be null';
    END IF;

    -- Capture affected rows directly
    v_count := UPDATE main_table SET processed = TRUE WHERE id = p_id;
END;
$$;
```

### Step 5: Performance Optimization
```sql
-- Update statistics
SELECT ANALYZE_STATISTICS('employees');
```

## PostgreSQL to Vertica Migration Checklist

### 🚨 Critical Parameter Handling

- [ ] **NEVER remove OUT keywords** from output parameters
- [ ] **NEVER remove INOUT keywords** from input/output parameters
- [ ] **NEVER use DEFAULT syntax** in parameter declarations - use procedure overloading instead
- [ ] Verify all OUT parameters are declared as `OUT param_name TYPE`
- [ ] Verify all INOUT parameters are declared as `INOUT param_name TYPE`
- [ ] IN parameters can omit the IN keyword (it's optional)
- [ ] Implement default parameter values using procedure overloading pattern
- [ ] Test all parameter passing scenarios
- [ ] **Understand OUT/INOUT behavior difference**: Vertica `CALL` returns a **single tuple (record)** — unpack with `var1, var2 := CALL proc(...)`. Unlike PostgreSQL, original variables are NOT modified by reference.

### 📋 General Migration Checklist

- [ ] `$$` delimiters used correctly (both PostgreSQL and Vertica use them)
- [ ] `LANGUAGE plpgsql` removed (not needed in Vertica)
- [ ] **Triggers**: Comment out triggers (not supported in Vertica)
- [ ] **Foreign key constraints**: Comment out `ON DELETE CASCADE` (not supported in Vertica)
- [ ] Tables converted with proper data types (note: INTEGER is 8 bytes in Vertica)
- [ ] Parameter modes preserved (critical!)
- [ ] Default parameter values implemented using overloading pattern
- [ ] SQL functions analyzed for optimal migration strategy (subquery vs stored procedure)
- [ ] NULL handling reviewed (PLvSQLCoerceNull set if needed)
- [ ] FOR loops updated with required keywords (QUERY, CURSOR, RANGE)
- [ ] DML return values captured directly (no GET DIAGNOSTICS ROW_COUNT needed)
- [ ] MUST use the PERFORM command to discard output (row counts, Tuples/Tuple, status messages) when executing DDL statements (CREATE, ALTER, DROP, TRUNCATE, etc.), COMMIT, ROLLBACK, DML statements (INSERT, UPDATE, DELETE, MERGE), CALL procedure statement, EXECUTE (dynamic SQL) and other SQL statements that you want to execute but don't need to capture the return value from via `:=`, `<-`, `SELECT ... INTO`, or `EXECUTE ... INTO`
- [ ] Exception handling uses SQLSTATE/SQLERRM for basic info; GET STACKED DIAGNOSTICS with DETAIL_TEXT/HINT_TEXT/EXCEPTION_CONTEXT for detailed info
- [ ] SQLSTATE code differences between PostgreSQL and Vertica reviewed
- [ ] All procedures compile without errors
- [ ] Parameter passing tested with various inputs
- [ ] OUT parameters return expected values (as a single tuple/record; unpack with `:= CALL`)
- [ ] Default parameter behavior verified for all calling patterns
- [ ] Transaction behavior tested (Vertica commits before procedure execution)
- [ ] Performance compared to PostgreSQL baseline

### 🚫 Critical "Never" Rules

- [ ] Never remove OUT or INOUT keywords from parameters - this will break the logic and cause runtime failures.
- [ ] Never discard the migration of SEQUENCE, it may be used in places you haven't seen yet
- [ ] Never use EXECUTE or PERFORM EXECUTE for DML or SELECT statements — use variables directly in value positions of DML or SELECT statements  if required
- [ ] Never use EXECUTE or PERFORM EXECUTE for DDL with fixed object names — use PERFORM directly

This comprehensive guide covers the essential aspects of migrating from PostgreSQL to Vertica, focusing on practical conversion strategies and performance optimization techniques.
