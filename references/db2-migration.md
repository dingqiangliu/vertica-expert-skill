# DB2 to Vertica Migration Guide

This guide provides comprehensive guidance for migrating IBM DB2 databases to Vertica, including SQL syntax conversion, PL/SQL to PL/vSQL migration, and performance optimization strategies.

## 🚨 CRITICAL: MANDATORY COMPLIANCE REQUIREMENTS

**BEFORE STARTING ANY DB2 MIGRATION, YOU MUST READ AND FOLLOW THE [GENERIC MIGRATION GUIDE](generic-migration-guide.md)**

This DB2 migration guide **MUST BE USED IN CONJUNCTION WITH** the [Generic Migration Guide](generic-migration-guide.md). The generic guide contains **MANDATORY PROCEDURES** that apply to ALL database migrations, including:

- ✅ **COMPLETE migration** of ALL objects (no selective migration allowed)
- ✅ **SEQUENTIAL processing** in exact source file order (no reordering)
- ✅ **ONE-TO-ONE conversion** (tables→tables, procedures→procedures, etc.)
- ✅ **INDIVIDUAL testing** of every object before considering it migrated
- ✅ **NO automated scripts** or bulk processing
- ✅ **PRESERVATION** of all sequences, and dependencies

**FAILURE TO FOLLOW THE GENERIC MIGRATION GUIDE WILL RESULT IN FAILED MIGRATIONS.**

## Function Migration Strategies Overview

This guide covers multiple DB2 function migration approaches:

1. **SQL Function to Subquery Conversion** - For functions used in SELECT statements, convert to LEFT JOIN subqueries for optimal performance
2. **Function to Stored Procedure** - Convert return values to OUT parameters for procedural logic
3. **User-Defined SQL Functions** - For simple transformations that can be expressed in SQL
4. **UDx Development** - For complex logic requiring C++, Python, Java, or R

## SQL Syntax Conversion

### Basic SELECT Statement Differences

```sql
-- DB2 (using FETCH FIRST)
SELECT * FROM employees e, departments d
WHERE e.dept_id = d.dept_id
FETCH FIRST 10 ROWS ONLY;

-- Vertica (LIMIT clause)
SELECT * FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
LIMIT 10;
```

### String Concatenation

```sql
-- DB2
SELECT CONCAT(first_name, CONCAT(' ', last_name)) as full_name FROM employees;
SELECT first_name || ' ' || last_name as full_name FROM employees;

-- Vertica (use || operator or CONCAT)
SELECT first_name || ' ' || last_name as full_name FROM employees;
SELECT CONCAT(first_name, CONCAT(' ', last_name)) as full_name FROM employees;
```

### Date Functions

```sql
-- DB2
SELECT CURRENT TIMESTAMP, CURRENT DATE FROM sysibm.sysdummy1;
SELECT hire_date + 6 MONTHS FROM employees;

-- Vertica
SELECT CURRENT_TIMESTAMP, CURRENT_DATE;
SELECT hire_date + interval '6 MONTHS' FROM employees;
```

### Identity Columns and Auto-increment

```sql
-- DB2
CREATE TABLE employees (
    emp_id INTEGER GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    emp_name VARCHAR(100)
);

-- DB2 alternative with SEQUENCE
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE employees (
    emp_id INTEGER DEFAULT NEXTVAL FOR emp_seq,
    emp_name VARCHAR(100)
);

-- Vertica (use AUTO_INCREMENT or IDENTITY)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica alternative with SEQUENCE
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE employees (
    emp_id INTEGER DEFAULT emp_seq.NEXTVAL,
    emp_name VARCHAR(100)
);
```

### NULL Handling

```sql
-- DB2
SELECT COALESCE(middle_name, 'N/A') FROM employees;
SELECT VALUE(middle_name, 'N/A') FROM employees; -- DB2-specific
SELECT IFNULL(middle_name, 'N/A') FROM employees; -- DB2 compatibility

-- Vertica (both ISNULL and COALESCE are supported; COALESCE is ANSI standard and preferred)
SELECT ISNULL(middle_name, 'N/A') FROM employees;
SELECT COALESCE(middle_name, 'N/A') FROM employees;
```

### Special Registers and System Tables

```sql
-- DB2
SELECT CURRENT_SCHEMA FROM sysibm.sysdummy1;
SELECT CURRENT TIMESTAMP FROM sysibm.sysdummy1;
SELECT * FROM sysibm.systables WHERE table_type = 'T';

-- Vertica
SELECT CURRENT_SCHEMA;
SELECT CURRENT_TIMESTAMP;
SELECT * FROM v_catalog.tables;
```

## Data Type Mappings

### Numeric Types

| DB2 Type | Vertica Type | Notes |
|----------|--------------|-------|
| SMALLINT | SMALLINT | **8 bytes** in Vertica (2-byte integer in DB2) |
| INTEGER | INTEGER | **8 bytes** in Vertica (4-byte integer in DB2) |
| BIGINT | BIGINT | 8-byte integer |
| DECIMAL(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| DECFLOAT | DOUBLE PRECISION | Floating point |
| REAL | REAL | **8 bytes** in Vertica(4-byte2 floating point integer in DB2) |
| DOUBLE | DOUBLE PRECISION | 8-byte floating point |
| DEC(p,s) | NUMERIC(p,s) | Same as DECIMAL |

### Character Types

| DB2 Type | Vertica Type | Notes |
|----------|--------------|-------|
| CHAR(n) | CHAR(n) | Fixed-length character |
| VARCHAR(n) | VARCHAR(n) | Variable-length character |
| VARCHAR(32672) | VARCHAR(65000) | Adjust to Vertica limits |
| CLOB | LONG VARCHAR | Large text (up to 32MB) |
| GRAPHIC(n) | CHAR(n) | DBCS character |
| VARGRAPHIC(n) | VARCHAR(n) | Variable DBCS |
| DBCLOB | LONG VARCHAR | Large DBCS text |

### Date/Time Types

| DB2 Type | Vertica Type | Notes |
|----------|--------------|-------|
| DATE | DATE | Date only |
| TIME | TIME | Time only |
| TIMESTAMP | TIMESTAMP | Date and time |
| TIMESTAMP(p) | TIMESTAMP(p) | Precision matching |

### Binary Types

| DB2 Type | Vertica Type | Notes |
|----------|--------------|-------|
| BINARY(n) | BINARY(n) | Fixed-length binary |
| VARBINARY(n) | VARBINARY(n) | Variable-length binary |
| BLOB | LONG VARBINARY | Large binary objects |

### Other Types

| DB2 Type | Vertica Type | Notes |
|----------|--------------|-------|
| BOOLEAN | BOOLEAN | True/False values |
| XML | LONG VARCHAR | Store as text |
| ROWID | VARCHAR(64) | Row identifier |

## Function Conversions

### String Functions

```sql
-- DB2 SUBSTR
SELECT SUBSTR(name, 1, 10) FROM employees;

-- Vertica SUBSTR (same syntax)
SELECT SUBSTR(name, 1, 10) FROM employees;

-- DB2 LOCATE
SELECT LOCATE('test', description) FROM products;

-- Vertica POSITION
SELECT POSITION('test' IN description) FROM products;

-- DB2 REPLACE (same in Vertica)
SELECT REPLACE(name, 'old', 'new') FROM employees;

-- DB2 UPPER/LOWER (same in Vertica)
SELECT UPPER(name), LOWER(name) FROM employees;

-- DB2 TRIM (same in Vertica)
SELECT TRIM(BOTH ' ' FROM name) FROM employees;

-- DB2 CONCAT (same in Vertica)
SELECT CONCAT(first_name, last_name) FROM employees;
```

### Date Functions

```sql
-- DB2 CURRENT TIMESTAMP
SELECT CURRENT_TIMESTAMP FROM sysibm.sysdummy1;

-- Vertica (same syntax, also NOW())
SELECT NOW();

-- DB2 DATE arithmetic
SELECT hire_date + 30 DAYS FROM employees;
SELECT hire_date - 6 MONTHS FROM employees;

-- Vertica DATE arithmetic
SELECT hire_date + INTERVAL '30 days' FROM employees;
SELECT hire_date - INTERVAL '6 months' FROM employees;

-- DB2 YEAR, MONTH, DAY functions
SELECT YEAR(hire_date), MONTH(hire_date), DAY(hire_date) FROM employees;

-- Vertica (same syntax, also EXTRACT)
SELECT EXTRACT(YEAR FROM hire_date), EXTRACT(MONTH FROM hire_date), EXTRACT(DAY FROM hire_date) FROM employees;

-- DB2 DAYS_BETWEEN (DB2 11.1+)
SELECT DAYS_BETWEEN(CURRENT DATE, hire_date) FROM employees;

-- Vertica DATE difference
SELECT CURRENT_DATE - hire_date FROM employees;
```

### Aggregate Functions

```sql
-- DB2 MEDIAN (DB2 11.1+)
SELECT MEDIAN(salary) FROM employees;

-- Vertica MEDIAN (analytic function)
SELECT MEDIAN(salary) OVER () FROM employees;

-- DB2 LISTAGG
SELECT LISTAGG(name, ', ') WITHIN GROUP (ORDER BY name) FROM departments;

-- Vertica LISTAGG
SELECT LISTAGG(name USING PARAMETERS separator=', ') FROM departments;

-- DB2 XMLAGG (convert to LISTAGG)
SELECT XMLAGG(XMLELEMENT(NAME "e", name) ORDER BY name) FROM employees;

-- Vertica LISTAGG
SELECT LISTAGG(name) FROM employees;
```

### Type Conversion Functions

```sql
-- DB2 CAST
SELECT CAST(salary AS VARCHAR(20)) FROM employees;

-- Vertica CAST (same syntax)
SELECT CAST(salary AS VARCHAR(20)) FROM employees;

-- DB2 DECIMAL
SELECT DECIMAL(salary, 10, 2) FROM employees;

-- Vertica CAST
SELECT CAST(salary AS NUMERIC(10,2)) FROM employees;

-- DB2 CHAR/INTEGER
SELECT CHAR(hire_date) FROM employees;
SELECT INTEGER(salary) FROM employees;

-- Vertica CAST
SELECT CAST(hire_date AS VARCHAR) FROM employees;
SELECT CAST(salary AS INTEGER) FROM employees;
```

## PL/SQL to PL/vSQL Migration

### Variable Declaration Type Restrictions

Vertica PL/vSQL has the following restrictions on variable data types that differ from DB2 SQL PL:

| Restriction | DB2 | Vertica Workaround |
|-------------|-----|--------------------|
| `DECIMAL(p,s)` / `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` or `DECIMAL` without precision. Default is precision 37, scale 15. |
| `DECFLOAT` type | ✅ Supported | Not supported. Use `DOUBLE PRECISION` or `NUMERIC` instead. |
| `GRAPHIC` / `VARGRAPHIC` / `DBCLOB` types | ✅ Supported | Not supported. Use `VARCHAR` instead. |
| `XML` type | ✅ Supported | Not supported. Use `LONG VARCHAR` or `LONG VARBINARY` instead. |
| `ROW` type (structured) | ✅ Supported | Not supported. Use individual scalar variables. |


### Critical Parameter Handling Rules

⚠️ **MOST IMPORTANT**: Never remove OUT/INOUT parameter keywords when migrating from DB2!

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: Unlike DB2, where OUT and INOUT parameters modify variables by reference, Vertica's `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. Use `var1, var2 := CALL proc(...)` to unpack the tuple. The original input variables remain unchanged.

**How it works in Vertica**:
- `CALL procedure_name(...)` returns a **single tuple (record)** containing all OUT/INOUT values
- Each column in the tuple is named after the corresponding OUT/INOUT parameter
- Use `var1, var2 := CALL proc(...)` to unpack the tuple's columns into variables by position
- The original variables passed to the procedure remain unchanged

**Migration Implication**: When converting DB2 PL/SQL that relies on OUT parameters to modify calling variables, use tuple unpacking assignment (`var1, var2 := CALL proc(...)`) instead.

#### Parameter Mode Conversion Table

**Key Syntax Difference**: In DB2, parameter modes (IN, OUT, INOUT) come **after** the parameter name. In Vertica, they come **before** the parameter name.

| DB2 Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|------------|---------------------|-------------------|-------|
| `p_param IN VARCHAR(50)` | `p_param VARCHAR` | `p_param VARCHAR` | IN is optional (default) |
| `p_param OUT INTEGER` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT before name** |
| `p_param INOUT VARCHAR(50)` | `p_param VARCHAR` | `INOUT p_param VARCHAR` | **Must keep INOUT before name** |

**Why this matters**: Removing OUT/INOUT keywords completely breaks the parameter passing mechanism and will cause runtime errors or incorrect behavior.

**Important Behavior Difference**: In Vertica, `CALL` returns a **single tuple (record)** for OUT/INOUT parameters. These values do NOT modify the original input variables by reference as DB2 does. Use tuple unpacking (`var1, var2 := CALL proc(...)`) to capture the returned values.

#### Migration Checklist for Parameters
- [ ] ✅ Preserve all OUT parameter keywords
- [ ] ✅ Preserve all INOUT parameter keywords
- [ ] ✅ IN keywords are optional (can be omitted)
- [ ] ✅ Test parameter passing with various data types
- [ ] ✅ Verify return value handling
- [ ] ✅ Understand that OUT/INOUT parameters don't modify original variables

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: DB2 supports default parameter values (e.g., `p_param INTEGER DEFAULT 0`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% DB2 compatibility.

#### Best Practice: Procedure Overloading for Default Parameters

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**
> Procedure overloading in Vertica works by matching the **procedure name** plus the parameter signature (number, types, order). Every overloaded variant **must** share the identical procedure name — only the parameter list differs. Using different names defeats the purpose of overloading and breaks call compatibility.

```sql
-- DB2 Original with Default Parameters
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount DECIMAL(5,2) DEFAULT 0.1,
    p_priority VARCHAR(20) DEFAULT 'NORMAL',
    p_notes VARCHAR(255) DEFAULT NULL
)
BEGIN
    -- Business logic
    DBMS_OUTPUT.PUT_LINE('Processing order ' || p_order_id);
END;

-- Vertica Migration: Perfect DB2 Compatibility
-- Step 1: Main procedure with all parameters (no defaults)
-- ⚠️  All overloaded versions below use the SAME name: process_order
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount NUMERIC(5,2),
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
    p_discount NUMERIC(5,2)
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, p_discount, 'NORMAL', NULL);
END;
$$;

-- Version 3: More parameters, remaining use defaults
-- ⚠️  SAME name "process_order" — 3 parameters instead of 4
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount NUMERIC(5,2),
    p_priority VARCHAR
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, p_discount, p_priority, NULL);
END;
$$;
```

#### 100% DB2-Compatible Calling Patterns

```sql
-- All DB2 calling styles work perfectly without modification
CALL process_order(1001);                              -- All defaults: 0.1, 'NORMAL', NULL
CALL process_order(1001, 0.15);                       -- Partial: 0.15, 'NORMAL', NULL
CALL process_order(1001, 0.15, 'HIGH');              -- Partial: 0.15, 'HIGH', NULL
CALL process_order(1001, 0.15, 'HIGH', 'Urgent');    -- No defaults: all explicit

-- Explicit NULLs also work correctly (passed to main procedure)
CALL process_order(1001, NULL, NULL, NULL);          -- All NULLs
```

#### Key Advantages of This Approach

✅ **Perfect Compatibility** - Every DB2 call pattern works unchanged
✅ **Correct NULL Handling** - Explicit NULLs vs defaults are properly distinguished
✅ **Maintainable** - Business logic exists only in main procedure
✅ **Zero Performance Impact** - Overloaded calls have minimal overhead
✅ **Future-Proof** - Easy to modify default values in one place

#### Default Parameter Migration Checklist

- [ ] **Create main procedure** with all parameters (no default syntax)
- [ ] **Create overloaded versions** for each combination of default parameters — ⚠️ **all with the SAME procedure name**
- [ ] **Call main procedure** from overloads with explicit default values
- [ ] **Test all calling patterns** to ensure DB2 compatibility
- [ ] **Document default values** in procedure comments
- [ ] **Handle complex defaults** like `CURRENT TIMESTAMP`, expressions correctly

#### Complex Default Value Example

```sql
-- DB2: Complex default expressions
CREATE PROCEDURE generate_report(
    p_start_date DATE DEFAULT CURRENT DATE - 30 DAYS,
    p_end_date DATE DEFAULT CURRENT DATE,
    p_format VARCHAR(10) DEFAULT 'PDF',
    p_include_details INTEGER DEFAULT 1
)
IS
BEGIN
    -- Business logic
END;

-- Vertica: Perfect migration with complex defaults
-- ⚠️  Both procedures use the SAME name: generate_report (overloaded by parameter count)
CREATE OR REPLACE PROCEDURE generate_report(
    p_start_date DATE,
    p_end_date DATE,
    p_format VARCHAR,
    p_include_details INTEGER
) AS $$
BEGIN
    -- Business logic here
    RAISE NOTICE 'Report: % to %, format: %, details: %',
        p_start_date, p_end_date, p_format, p_include_details;
END;
$$;

-- ⚠️  SAME name "generate_report" — 0 parameters instead of 4 (all defaults)
CREATE OR REPLACE PROCEDURE generate_report() AS $$
BEGIN
    PERFORM CALL generate_report(
        CURRENT_DATE - INTERVAL '30 days',  -- Default start date
        CURRENT_DATE,                       -- Default end date
        'PDF',                              -- Default format
        1                                   -- Default include details
    );
END;
$$;
```

### Basic Procedure Structure

```sql
-- DB2 PL/SQL
CREATE OR REPLACE PROCEDURE update_salaries (
    p_dept_id INTEGER,
    p_increase_pct DECIMAL(5,2)
)
    LANGUAGE SQL
BEGIN
    DECLARE v_count INTEGER;

    UPDATE employees
    SET salary = salary * (1 + p_increase_pct/100)
    WHERE department_id = p_dept_id;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    INSERT INTO salary_audit
    VALUES (p_dept_id, p_increase_pct, v_count, CURRENT TIMESTAMP);

    COMMIT;
END;

-- Vertica PL/vSQL
CREATE OR REPLACE PROCEDURE update_salaries (
    p_dept_id INTEGER,           -- IN is optional (default)
    p_increase_pct NUMERIC(5,2)  -- IN is optional (default)
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    PERFORM UPDATE employees
    SET salary = salary * (1 + p_increase_pct/100)
    WHERE department_id = p_dept_id;

    -- Use FOUND to check if update was successful
    IF FOUND THEN
        v_count := (SELECT COUNT(*) FROM employees WHERE department_id = p_dept_id);
    ELSE
        v_count := 0;
    END IF;

    PERFORM INSERT INTO salary_audit
    VALUES (p_dept_id, p_increase_pct, v_count, NOW());

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;
```

### Cursor Handling

```sql
-- DB2 explicit cursor
CREATE OR REPLACE PROCEDURE process_employees()
    LANGUAGE SQL
BEGIN
    DECLARE emp_cursor CURSOR FOR
        SELECT employee_id, salary
        FROM employees
        WHERE department_id = 10;

    DECLARE v_employee_id INTEGER;
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_done INTEGER DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN emp_cursor;

    FETCH_LOOP: LOOP
        FETCH emp_cursor INTO v_employee_id, v_salary;
        IF v_done = 1 THEN
            LEAVE FETCH_LOOP;
        END IF;
        -- Process record
        DBMS_OUTPUT.PUT_LINE(v_employee_id || ': ' || v_salary);
    END LOOP;

    CLOSE emp_cursor;
END;

-- Vertica cursor (similar syntax)
CREATE OR REPLACE PROCEDURE process_employees()
AS $$
DECLARE
    emp_cursor CURSOR FOR
        SELECT employee_id, salary
        FROM employees
        WHERE department_id = 10;
    v_employee_id INTEGER;
    v_salary NUMERIC;
BEGIN
    FOR v_employee_id, v_salary IN CURSOR emp_cursor LOOP
        -- Process record
        RAISE NOTICE '%: %', v_employee_id, v_salary;
    END LOOP;
END;
$$;
```

### Dynamic SQL Execution

```sql
-- DB2: Execute dynamic SQL and assign result to variable
CREATE PROCEDURE get_sequence_value(
    IN sequenceName VARCHAR(100),
    OUT sequenceNo VARCHAR(100)
)
    LANGUAGE SQL
BEGIN
    DECLARE stmt VARCHAR(500);
    SET stmt = 'SELECT CHAR(NEXT VALUE FOR ' || sequenceName || ') FROM sysibm.sysdummy1';
    EXECUTE IMMEDIATE stmt INTO sequenceNo;
END;

-- Vertica: Execute dynamic SQL and assign result to variable
DO $$
DECLARE
    sequenceName VARCHAR(100) := 'EMP_SEQ';
    sequenceNo VARCHAR(100);
BEGIN
    EXECUTE 'SELECT ' || sequenceName || '.NEXTVAL' INTO sequenceNo;
    RAISE NOTICE 'Sequence value: %', sequenceNo;
END
$$;
```

### Exception Handling

DB2 SQL PL uses `DECLARE HANDLER` to define exception handlers within stored procedures. Vertica PL/vSQL does **not** support this syntax — instead, it uses an `EXCEPTION` block with `WHEN` clauses. Understanding the mapping between the two models is critical for correct migration.

#### DB2 Handler Types and Conditions

DB2 supports three handler types and three condition categories:

**Handler Types:**

| DB2 Handler | Behavior | Vertica Equivalent |
|-------------|----------|---------------------|
| `EXIT HANDLER` | Executes handler action, then **exits** the declaring BEGIN...END block | `EXCEPTION WHEN OTHERS THEN ...` (ends the block) |
| `CONTINUE HANDLER` | Executes handler action, then **continues** at the next statement | Check `FOUND` variable or use inner `EXCEPTION` block |
| `UNDO HANDLER` | **Rolls back** the entire ATOMIC block, then executes handler (ATOMIC blocks only) | Vertica's automatic transaction rollback on unhandled exceptions |

**Condition Categories:**

| DB2 Condition | Trigger | SQLCODE / SQLSTATE |
|---------------|---------|---------------------|
| `SQLEXCEPTION` | SQL error (constraint violation, syntax error, etc.) | SQLCODE < 0, SQLSTATE 03xx–99xx |
| `SQLWARNING` | SQL warning (NULL eliminated, truncation, etc.) | SQLCODE > 0 (not 100), SQLSTATE 01xx |
| `NOT FOUND` | No rows returned (FETCH past end, SELECT INTO empty) | SQLCODE 100, SQLSTATE 02000 |

#### Migration Pattern 1: EXIT HANDLER FOR SQLEXCEPTION → EXCEPTION Block

```sql
-- DB2: EXIT HANDLER FOR SQLEXCEPTION
CREATE OR REPLACE PROCEDURE handle_errors()
    LANGUAGE SQL
BEGIN
    DECLARE v_sqlcode INTEGER;
    DECLARE v_sqlstate CHAR(5);
    DECLARE v_msg VARCHAR(1000);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlcode = DB2_RETURNED_SQLCODE,
            v_sqlstate = RETURNED_SQLSTATE,
            v_msg = MESSAGE_TEXT;
        -- Handle error and exit the block
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_msg);
    END;

    -- SQL statements that might cause errors
    INSERT INTO nonexistent_table VALUES (1);
END;

-- Vertica: EXCEPTION block with WHEN OTHERS
CREATE OR REPLACE PROCEDURE handle_errors()
AS $$
DECLARE
    v_error_msg VARCHAR;
    v_error_code VARCHAR;
BEGIN
    -- SQL statements that might cause errors
    PERFORM INSERT INTO nonexistent_table VALUES (1);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_code = RETURNED_SQLSTATE,
            v_error_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Error: % (SQLSTATE: %)', v_error_msg, v_error_code;
END;
$$;
```

#### Migration Pattern 2: CONTINUE HANDLER FOR NOT FOUND → FOUND Variable

```sql
-- DB2: CONTINUE HANDLER FOR NOT FOUND (cursor loop pattern)
CREATE OR REPLACE PROCEDURE process_employees()
    LANGUAGE SQL
BEGIN
    DECLARE v_emp_id INTEGER;
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_done INTEGER DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    DECLARE emp_cursor CURSOR FOR
        SELECT employee_id, salary
        FROM employees
        WHERE department_id = 10;

    OPEN emp_cursor;
    FETCH_LOOP: LOOP
        FETCH emp_cursor INTO v_emp_id, v_salary;
        IF v_done = 1 THEN
            LEAVE FETCH_LOOP;
        END IF;
        DBMS_OUTPUT.PUT_LINE(v_emp_id || ': ' || v_salary);
    END LOOP;
    CLOSE emp_cursor;
END;

-- Vertica: Use FOUND variable or FOR...CURSOR loop (recommended)
CREATE OR REPLACE PROCEDURE process_employees()
AS $$
DECLARE
    emp_cursor CURSOR FOR
        SELECT employee_id, salary
        FROM employees
        WHERE department_id = 10;
    v_employee_id INTEGER;
    v_salary NUMERIC(10,2);
BEGIN
    -- Recommended: FOR loop handles NOT FOUND automatically
    FOR v_employee_id, v_salary IN CURSOR emp_cursor LOOP
        RAISE NOTICE '%: %', v_employee_id, v_salary;
    END LOOP;
END;
$$;

-- Alternative: Manual FETCH with EXIT WHEN NOT FOUND
CREATE OR REPLACE PROCEDURE process_employees_manual()
AS $$
DECLARE
    emp_cursor CURSOR FOR
        SELECT employee_id, salary
        FROM employees
        WHERE department_id = 10;
    v_employee_id INTEGER;
    v_salary NUMERIC(10,2);
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_employee_id, v_salary;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%: %', v_employee_id, v_salary;
    END LOOP;
    CLOSE emp_cursor;
END;
$$;
```

#### Migration Pattern 3: CONTINUE HANDLER FOR NOT FOUND → FOUND Variable (DML Check)

```sql
-- DB2: Check if SELECT INTO found a row
CREATE OR REPLACE PROCEDURE find_employee(
    p_emp_id INTEGER,
    OUT p_found INTEGER
)
    LANGUAGE SQL
BEGIN
    DECLARE v_salary DECIMAL(10,2);

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET p_found = 0;

    SET p_found = 1;
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = p_emp_id;
END;

-- Vertica: Use FOUND special variable
CREATE OR REPLACE PROCEDURE find_employee(
    p_emp_id INTEGER,
    OUT p_found INTEGER
) AS $$
DECLARE
    v_salary NUMERIC(10,2);
BEGIN
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = p_emp_id;

    IF FOUND THEN
        p_found := 1;
    ELSE
        p_found := 0;
    END IF;
END;
$$;
```

#### Migration Pattern 4: EXIT HANDLER FOR SQLWARNING

```sql
-- DB2: EXIT HANDLER FOR SQLWARNING
CREATE OR REPLACE PROCEDURE batch_import(
    OUT p_status VARCHAR(200)
)
    LANGUAGE SQL
BEGIN
    DECLARE v_warn_sqlcode INTEGER;
    DECLARE v_warn_sqlstate CHAR(5);
    DECLARE v_warn_msg VARCHAR(1000);

    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_warn_sqlcode = DB2_RETURNED_SQLCODE,
            v_warn_sqlstate = RETURNED_SQLSTATE,
            v_warn_msg = MESSAGE_TEXT;
        SET p_status = 'WARNING: ' || v_warn_msg;
    END;

    INSERT INTO target_table (name, description)
    SELECT name, description FROM staging_table;

    SET p_status = 'SUCCESS';
END;

-- Vertica: No direct SQLWARNING equivalent; use EXCEPTION block
CREATE OR REPLACE PROCEDURE batch_import(
    OUT p_status VARCHAR
) AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    PERFORM INSERT INTO target_table (name, description)
    SELECT name, description FROM staging_table;

    p_status := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        p_status := 'WARNING: ' || v_error_msg;
END;
$$;
```

#### Migration Pattern 5: Combined Handlers (All Three Conditions)

```sql
-- DB2: Combined handlers for SQLEXCEPTION, SQLWARNING, and NOT FOUND
CREATE OR REPLACE PROCEDURE update_employee_salary(
    p_emp_id INTEGER,
    p_new_salary DECIMAL(10,2),
    OUT p_result VARCHAR(200)
)
    LANGUAGE SQL
BEGIN
    DECLARE v_old_salary DECIMAL(10,2);
    DECLARE v_found INTEGER DEFAULT 0;
    DECLARE v_sqlcode INTEGER;
    DECLARE v_sqlstate CHAR(5);
    DECLARE v_msg VARCHAR(1000);

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    DECLARE CONTINUE HANDLER FOR SQLWARNING
    BEGIN
        INSERT INTO warning_log (emp_id, warning_time, message)
        VALUES (p_emp_id, CURRENT TIMESTAMP, 'Warning during salary update');
    END;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlcode = DB2_RETURNED_SQLCODE,
            v_sqlstate = RETURNED_SQLSTATE,
            v_msg = MESSAGE_TEXT;
        SET p_result = 'ERROR: ' || v_msg;
    END;

    SET v_found = 1;
    SELECT salary INTO v_old_salary
    FROM employees
    WHERE employee_id = p_emp_id;

    IF v_found = 0 THEN
        SET p_result = 'ERROR: Employee not found';
        RETURN;
    END IF;

    UPDATE employees SET salary = p_new_salary
    WHERE employee_id = p_emp_id;

    SET p_result = 'SUCCESS';
END;

-- Vertica: Single EXCEPTION block + FOUND variable
CREATE OR REPLACE PROCEDURE update_employee_salary(
    p_emp_id INTEGER,
    p_new_salary NUMERIC(10,2),
    OUT p_result VARCHAR
) AS $$
DECLARE
    v_old_salary NUMERIC(10,2);
    v_error_msg VARCHAR;
BEGIN
    -- SELECT INTO raises NO_DATA_FOUND if no rows returned
    SELECT salary INTO v_old_salary
    FROM employees
    WHERE employee_id = p_emp_id;

    PERFORM UPDATE employees SET salary = p_new_salary
    WHERE employee_id = p_emp_id;

    p_result := 'SUCCESS';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 'ERROR: Employee not found';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        p_result := 'ERROR: ' || v_error_msg;
END;
$$;
```

#### Migration Pattern 6: UNDO HANDLER → Automatic Transaction Rollback

```sql
-- DB2: UNDO HANDLER (requires ATOMIC block)
CREATE OR REPLACE PROCEDURE atomic_transfer(
    p_from_acct INTEGER,
    p_to_acct INTEGER,
    p_amount DECIMAL(10,2),
    OUT p_status VARCHAR(100)
)
    LANGUAGE SQL
BEGIN
    DECLARE UNDO HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_status = 'FAILED: Transaction rolled back';
    END;

    BEGIN ATOMIC
        UPDATE accounts SET balance = balance - p_amount
        WHERE account_id = p_from_acct;
        UPDATE accounts SET balance = balance + p_amount
        WHERE account_id = p_to_acct;
        SET p_status = 'SUCCESS';
    END;
END;

-- Vertica: Unhandled exception auto-rolls back the transaction
CREATE OR REPLACE PROCEDURE atomic_transfer(
    p_from_acct INTEGER,
    p_to_acct INTEGER,
    p_amount NUMERIC(10,2),
    OUT p_status VARCHAR
) AS $$
BEGIN
    PERFORM UPDATE accounts SET balance = balance - p_amount
    WHERE account_id = p_from_acct;
    PERFORM UPDATE accounts SET balance = balance + p_amount
    WHERE account_id = p_to_acct;

    p_status := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        -- Unhandled exceptions auto-rollback; manual COMMIT persists
        p_status := 'FAILED: Transaction rolled back';
END;
$$;
```

#### Key Differences Summary

| Aspect | DB2 SQL PL | Vertica PL/vSQL |
|--------|------------|-----------------|
| Handler declaration | `DECLARE {EXIT\|CONTINUE\|UNDO} HANDLER FOR condition` | `EXCEPTION WHEN condition THEN ...` |
| Handler scope | Per BEGIN...END block | Per BEGIN...EXCEPTION...END block |
| NOT FOUND | `CONTINUE HANDLER FOR NOT FOUND SET var = val` | `FOUND` special variable or `EXIT WHEN NOT FOUND` |
| SQLEXCEPTION | `EXIT/CONTINUE HANDLER FOR SQLEXCEPTION` | `EXCEPTION WHEN OTHERS THEN` |
| SQLWARNING | `EXIT/CONTINUE HANDLER FOR SQLWARNING` | No direct equivalent; use `WHEN OTHERS` |
| UNDO (rollback) | `UNDO HANDLER` in ATOMIC blocks | Automatic on unhandled exceptions |
| Error info retrieval | `GET DIAGNOSTICS CONDITION 1` | `GET STACKED DIAGNOSTICS` |
| Error code | `SQLCODE` (integer) | `SQLSTATE` (string) |
| Error message | `MESSAGE_TEXT` via GET DIAGNOSTICS | `SQLERRM` or `MESSAGE_TEXT` via GET STACKED DIAGNOSTICS |
| Named conditions | SQLSTATE-based | `NO_DATA_FOUND`, `TOO_MANY_ROWS`, `WHEN OTHERS` |
| Handler priority | NOT FOUND > SQLWARNING > SQLEXCEPTION | WHEN clauses evaluated top-to-bottom |

#### Named Conditions: DECLARE CONDITION FOR SQLSTATE

DB2 SQL PL allows defining **named conditions** that associate a user-friendly name with a specific SQLSTATE value. This is the primary mechanism for handling custom business exceptions in DB2. Vertica PL/vSQL does **not** support this feature.

**DB2 Syntax:**

```sql
DECLARE condition_name CONDITION FOR SQLSTATE 'xxxxx';
```

- `condition_name` — A user-defined identifier (up to 128 characters).
- `'xxxxx'` — A 5-character SQLSTATE value. Use class `45xxx` or `80xxx` for custom business exceptions.
- Scoped to the `BEGIN...END` block where declared (visible in nested inner blocks).

**Common Custom SQLSTATE Ranges:**

| SQLSTATE Range | Class | Typical Use |
|----------------|-------|-------------|
| `45000`–`45999` | 45 | Unhandled user-defined exceptions |
| `80000`–`80999` | 80 | Business rule violations (most common) |

**DB2 SIGNAL / RESIGNAL Statements:**

| Statement | Purpose |
|-----------|---------|
| `SIGNAL name SET MESSAGE_TEXT = '...'` | Raise a named condition with a custom message |
| `SIGNAL SQLSTATE 'xxxxx' SET MESSAGE_TEXT = '...'` | Raise an unnamed SQLSTATE directly |
| `RESIGNAL` | Re-raise the current exception as-is |
| `RESIGNAL name SET MESSAGE_TEXT = '...'` | Transform the current exception into a different named condition |

#### Migration Pattern 7: DECLARE CONDITION + SIGNAL → RAISE EXCEPTION

```sql
-- DB2: Named condition with SIGNAL
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    OUT p_status VARCHAR(50)
)
    LANGUAGE SQL
BEGIN
    DECLARE order_not_found     CONDITION FOR SQLSTATE '80001';
    DECLARE insufficient_stock  CONDITION FOR SQLSTATE '80002';
    DECLARE customer_blocked    CONDITION FOR SQLSTATE '80003';
    DECLARE v_msg               VARCHAR(500);

    DECLARE EXIT HANDLER FOR order_not_found
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT;
        SET p_status = 'NOT_FOUND: ' || v_msg;
    END;

    DECLARE EXIT HANDLER FOR insufficient_stock
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT;
        SET p_status = 'NO_STOCK: ' || v_msg;
    END;

    DECLARE EXIT HANDLER FOR customer_blocked
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT;
        SET p_status = 'BLOCKED: ' || v_msg;
    END;

    -- Business logic
    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id) THEN
        SIGNAL order_not_found
            SET MESSAGE_TEXT = 'Order ' || CHAR(p_order_id) || ' does not exist';
    END IF;

    -- ... more validation ...
    SET p_status = 'SUCCESS';
END;

-- Vertica: RAISE EXCEPTION with SQLSTATE + WHEN SQLSTATE handler
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    OUT p_status VARCHAR
) AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    -- Business logic
    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION SQLSTATE '80001'
            USING MESSAGE = 'Order ' || p_order_id || ' does not exist';
    END IF;

    -- ... more validation ...
    p_status := 'SUCCESS';
EXCEPTION
    WHEN SQLSTATE '80001' THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        p_status := 'NOT_FOUND: ' || v_error_msg;
    WHEN SQLSTATE '80002' THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        p_status := 'NO_STOCK: ' || v_error_msg;
    WHEN SQLSTATE '80003' THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        p_status := 'BLOCKED: ' || v_error_msg;
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        p_status := 'ERROR: ' || v_error_msg;
END;
$$;
```

#### Migration Pattern 8: RESIGNAL → RAISE (Re-throw)

```sql
-- DB2: RESIGNAL to propagate exception to caller
CREATE OR REPLACE PROCEDURE inner_proc()
    LANGUAGE SQL
BEGIN
    DECLARE business_error CONDITION FOR SQLSTATE '80010';
    DECLARE EXIT HANDLER FOR business_error
    BEGIN
        -- Log the error, then re-raise to caller
        INSERT INTO error_log (msg, err_time)
        VALUES ('Business error in inner_proc', CURRENT TIMESTAMP);
        RESIGNAL;  -- Re-raises the same condition
    END;

    -- Some operation that might fail
    SIGNAL business_error SET MESSAGE_TEXT = 'Validation failed';
END;

-- Vertica: RAISE to re-throw in EXCEPTION block
CREATE OR REPLACE PROCEDURE inner_proc() AS $$
BEGIN
    -- Some operation that might fail
    RAISE EXCEPTION SQLSTATE '80010'
        USING MESSAGE = 'Validation failed';
EXCEPTION
    WHEN SQLSTATE '80010' THEN
        -- Log the error, then re-raise to caller
        PERFORM INSERT INTO error_log (msg, err_time)
        VALUES ('Business error in inner_proc', CURRENT_TIMESTAMP);
        RAISE;  -- Re-throws the same exception
END;
$$;
```

#### Migration Pattern 9: RESIGNAL with Transformation → RAISE with Different SQLSTATE

```sql
-- DB2: Transform one condition into another
CREATE OR REPLACE PROCEDURE outer_proc()
    LANGUAGE SQL
BEGIN
    DECLARE data_error    CONDITION FOR SQLSTATE '80020';
    DECLARE system_error  CONDITION FOR SQLSTATE '80021';

    DECLARE EXIT HANDLER FOR data_error
    BEGIN
        -- Transform data_error into system_error for the caller
        RESIGNAL system_error
            SET MESSAGE_TEXT = 'System error due to data issue';
    END;

    -- Some operation
    SIGNAL data_error SET MESSAGE_TEXT = 'Invalid data format';
END;

-- Vertica: Catch one SQLSTATE and RAISE with a different SQLSTATE
CREATE OR REPLACE PROCEDURE outer_proc() AS $$
BEGIN
    -- Some operation
    RAISE EXCEPTION SQLSTATE '80020'
        USING MESSAGE = 'Invalid data format';
EXCEPTION
    WHEN SQLSTATE '80020' THEN
        -- Transform into a different SQLSTATE for the caller
        RAISE EXCEPTION SQLSTATE '80021'
            USING MESSAGE = 'System error due to data issue';
END;
$$;
```

#### Migration Pattern 10: Named Condition Scoping → Nested EXCEPTION Blocks

```sql
-- DB2: Named conditions are visible in nested inner blocks
CREATE OR REPLACE PROCEDURE scoped_demo()
    LANGUAGE SQL
BEGIN
    DECLARE business_error CONDITION FOR SQLSTATE '80001';

    -- Outer handler
    DECLARE EXIT HANDLER FOR business_error
    BEGIN
        -- Catches business_error from anywhere in this block
        INSERT INTO log_table VALUES ('Outer handler caught it');
    END;

    -- Inner block can also see and use business_error
    BEGIN
        DECLARE inner_error CONDITION FOR SQLSTATE '80002';
        -- Both business_error and inner_error are visible here
        SIGNAL business_error;  -- Caught by OUTER handler
    END;
END;

-- Vertica: Nested EXCEPTION blocks with SQLSTATE propagation
CREATE OR REPLACE PROCEDURE scoped_demo() AS $$
BEGIN
    BEGIN
        -- Inner block raises a custom SQLSTATE
        RAISE EXCEPTION SQLSTATE '80001'
            USING MESSAGE = 'Business error';
    EXCEPTION
        WHEN SQLSTATE '80001' THEN
            -- Inner handler catches it
            RAISE NOTICE 'Inner handler caught it';
    END;
END;
$$;

-- Alternative: Let it propagate to outer block
CREATE OR REPLACE PROCEDURE scoped_demo_propagate() AS $$
BEGIN
    BEGIN
        RAISE EXCEPTION SQLSTATE '80001'
            USING MESSAGE = 'Business error';
    END;
    -- No inner handler — exception propagates to outer block
EXCEPTION
    WHEN SQLSTATE '80001' THEN
        PERFORM INSERT INTO log_table VALUES ('Outer handler caught it');
END;
$$;
```

#### Named Condition Migration Summary

| DB2 Feature | DB2 Syntax | Vertica Equivalent |
|-------------|-----------|---------------------|
| Declare named condition | `DECLARE name CONDITION FOR SQLSTATE 'xxxxx'` | **Not supported** — use `RAISE EXCEPTION SQLSTATE 'xxxxx'` directly |
| Raise named condition | `SIGNAL name SET MESSAGE_TEXT = '...'` | `RAISE EXCEPTION SQLSTATE 'xxxxx' USING MESSAGE = '...'` |
| Raise unnamed SQLSTATE | `SIGNAL SQLSTATE 'xxxxx' SET MESSAGE_TEXT = '...'` | `RAISE EXCEPTION SQLSTATE 'xxxxx' USING MESSAGE = '...'` |
| Re-raise current exception | `RESIGNAL` | `RAISE;` |
| Transform exception | `RESIGNAL other_name SET MESSAGE_TEXT = '...'` | `RAISE EXCEPTION SQLSTATE 'yyyyy' USING MESSAGE = '...'` |
| Handler for named condition | `DECLARE EXIT HANDLER FOR name` | `EXCEPTION WHEN SQLSTATE 'xxxxx' THEN` |
| Condition scoping | Visible in declaring block + inner blocks | Nested `EXCEPTION` blocks; propagate by omitting inner handler |
| Custom SQLSTATE range | `45xxx`, `80xxx` | Same ranges work (`RAISE EXCEPTION SQLSTATE '80001'`) |

## Function Migration Strategies

DB2 functions can be migrated to Vertica using multiple approaches. The choice depends on the function's complexity, performance requirements, and usage patterns.

### Strategy 1: SQL Function to Subquery Conversion (Performance-Optimized)

For DB2 SQL functions that can be expressed as a query and are used in SELECT statements, convert them to subqueries with LEFT JOIN for better performance in Vertica's columnar architecture.

```sql
-- DB2 SQL Function and Query
CREATE OR REPLACE FUNCTION ISYSZ(rydm VARCHAR(50))
RETURNS VARCHAR(1)
    LANGUAGE SQL
BEGIN
    DECLARE rynum INTEGER;
    SELECT COUNT(*) INTO rynum FROM qx_user u WHERE u.czry_dm = rydm;
    IF (rynum > 0) THEN
        RETURN '1';
    ELSE
        RETURN '0';
    END IF;
END;

SELECT czry_dm, czry_mc, ISYSZ(czry_dm) AS isysz
FROM dm_czry;

-- Vertica Migration: Convert to LEFT JOIN subquery
SELECT dm_czry.czry_dm, dm_czry.czry_mc,
    (CASE WHEN qx_user.userid IS NOT NULL THEN '1' ELSE '0' END) AS isysz
FROM dm_czry LEFT JOIN qx_user ON dm_czry.czry_dm = qx_user.czry_dm;
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

DB2 functions can be effectively migrated to Vertica stored procedures by converting the return value to an additional OUT parameter. This approach maintains DB2-like semantics while leveraging Vertica's stored procedure capabilities.

#### Key Migration Pattern

**Tuple Unpacking Assignment**: When a stored procedure has OUT or INOUT parameters, `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The `:=` assignment unpacks the tuple's columns into variables by position:

```sql
-- CALL returns a tuple; := unpacks it into variables
var_return := CALL procedure_name([params]);              -- single OUT → scalar
var_out1, var_out2, var_return := CALL procedure_name([params]);  -- multiple OUTs → unpack
```

#### Migration Examples

##### Pattern 1: Simple Function with Return Value

```sql
-- DB2 Function
CREATE OR REPLACE FUNCTION F_GET_JDH()
RETURNS VARCHAR(100)
    LANGUAGE SQL
BEGIN
    DECLARE jdno VARCHAR(100);
    SELECT CSNR INTO jdno FROM XT_XTCS WHERE CSXH = '10001' AND JG_DM = 'PUBLIC';
    RETURN jdno;
END;

-- Usage in DB2
VALUES F_GET_JDH();

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE F_GET_JDH(
    OUT rt VARCHAR(100)
) AS $$
BEGIN
    SELECT CSNR INTO rt FROM XT_XTCS WHERE CSXH = '10001' AND JG_DM = 'PUBLIC';
END;
$$;

-- Usage in Vertica
DO $$
DECLARE
    jdno VARCHAR(100);
BEGIN
    -- Additional OUT Parameter Assignment
    jdno := CALL F_GET_JDH();
    RAISE INFO 'jdno: %', jdno;
END
$$;
```

##### Pattern 2: Function with Input Parameters

```sql
-- DB2 Function
CREATE OR REPLACE FUNCTION F_GET_JD_DM(
    ac_fjd_dm VARCHAR(30),
    ac_jd_mc VARCHAR(50)
)
RETURNS VARCHAR(30)
    LANGUAGE SQL
BEGIN
    DECLARE jdno VARCHAR(30);
    SELECT JD_DM INTO jdno FROM QX_GNMK_TREE
    WHERE FJD_DM = ac_fjd_dm AND JD_MC = ac_jd_mc;
    RETURN jdno;
END;

-- Usage in DB2
VALUES F_GET_JD_DM('0', '系统设置');

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE F_GET_JD_DM(
    ac_fjd_dm VARCHAR,
    ac_jd_mc VARCHAR,
    OUT rt VARCHAR(30)
) AS $$
BEGIN
    SELECT JD_DM INTO rt FROM QX_GNMK_TREE
    WHERE FJD_DM = ac_fjd_dm AND JD_MC = ac_jd_mc;
END;
$$;

-- Usage in Vertica
DO $$
DECLARE
    jdno VARCHAR(30);
BEGIN
    -- Additional OUT Parameter Assignment
    jdno := CALL F_GET_JD_DM('0', '系统设置');
    RAISE INFO 'jdno: %', jdno;
END
$$;
```

##### Pattern 3: Complex Function with Multiple Return Values

```sql
-- DB2 Function
CREATE OR REPLACE FUNCTION get_employee_stats(
    p_dept_id INTEGER
)
RETURNS TABLE (
    emp_count INTEGER,
    avg_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2)
)
    LANGUAGE SQL
BEGIN
    RETURN (
        SELECT COUNT(*), AVG(salary), MAX(salary)
        FROM employees
        WHERE department_id = p_dept_id
    );
END;

-- Usage in DB2
SELECT * FROM TABLE(get_employee_stats(10));

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_employee_stats(
    p_dept_id INTEGER,
    OUT emp_count INTEGER,
    OUT avg_salary NUMERIC(10,2),
    OUT max_salary NUMERIC(10,2)
) AS $$
BEGIN
    SELECT COUNT(*), AVG(salary), MAX(salary)
    INTO emp_count, avg_salary, max_salary
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;

-- Usage in Vertica
DO $$
DECLARE
    v_count INTEGER;
    v_avg NUMERIC(10,2);
    v_max NUMERIC(10,2);
BEGIN
    -- Multiple OUT parameters assignment
    v_count, v_avg, v_max := CALL get_employee_stats(10);
    RAISE INFO 'Count: %, Avg: %, Max: %', v_count, v_avg, v_max;
END
$$;
```

#### Key Benefits of Stored Procedure Approach

1. **DB2-like Semantics**: Maintains familiar variable assignment patterns
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

## Package Migration

### Converting DB2 Modules and Packages

DB2 modules and packages need to be converted to individual procedures/functions in Vertica:

```sql
-- DB2 Module
CREATE MODULE employee_mgmt;

ALTER MODULE employee_mgmt
    ADD PROCEDURE hire_employee(
        p_name VARCHAR(100),
        p_dept_id INTEGER,
        p_salary DECIMAL(10,2)
    );

ALTER MODULE employee_mgmt
    ADD FUNCTION get_employee_count(p_dept_id INTEGER)
    RETURNS INTEGER;

ALTER MODULE employee_mgmt
    ADD PROCEDURE terminate_employee(p_emp_id INTEGER);

-- Vertica (separate procedures)
CREATE OR REPLACE PROCEDURE hire_employee(
    p_name VARCHAR,
    p_dept_id INTEGER,
    p_salary NUMERIC(10,2)
) AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    INSERT INTO employees (name, department_id, salary, hire_date)
    VALUES (p_name, p_dept_id, p_salary, NOW());
END;
$$;

CREATE OR REPLACE FUNCTION get_employee_count(p_dept_id INTEGER)
RETURN INTEGER
AS BEGIN
    RETURN (SELECT COUNT(*) FROM employees WHERE department_id = p_dept_id);
END;

CREATE OR REPLACE PROCEDURE terminate_employee(p_emp_id INTEGER) AS $$
BEGIN
    PERFORM UPDATE employees
    SET termination_date = NOW(), status = 'TERMINATED'
    WHERE employee_id = p_emp_id;
END;
$$;
```

## Common Migration Challenges

### 0. Identifier Case Sensitivity

**Difference**: DB2 unquoted identifiers are case-insensitive (folded to uppercase); quoted identifiers (`"..."`) are **case-sensitive**. Vertica identifiers are **always case-insensitive**, whether quoted or not.

**Impact**: Objects that differ only by case in DB2 (e.g., `"MyTable"` vs `"mytable"`) will **conflict** in Vertica.

**Solution**: Audit for identifiers that differ only by case and rename them. Adopt a consistent naming convention (e.g., `snake_case`). Remove unnecessary double quotes.

```sql
-- DB2: these are two different objects
CREATE TABLE "MyTable" (id INT);
CREATE TABLE "mytable" (id INT);

-- Vertica: the second CREATE will fail — rename one
CREATE TABLE MyTable (id INT);
CREATE TABLE my_table (id INT);  -- renamed to avoid conflict
```

### 1. Sequence Handling

```sql
-- DB2 sequences
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
INSERT INTO employees (id, name) VALUES (NEXTVAL FOR emp_seq, 'John');
INSERT INTO employees (id, name) VALUES (emp_seq.NEXTVAL, 'John');

-- Vertica sequences (same syntax)
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
INSERT INTO employees (id, name) VALUES (emp_seq.NEXTVAL, 'John');

-- Vertica auto-increment
CREATE TABLE employees (
    id AUTO_INCREMENT,
    name VARCHAR(100)
);
INSERT INTO employees (name) VALUES ('John');
```

### 2. Foreign Key Constraint Limitations

**Critical Limitation**: Vertica does NOT support `ON DELETE CASCADE` for foreign key constraints, which is a key difference from DB2.

```sql
-- DB2 table with ON DELETE CASCADE
CREATE TABLE SYSTEM_PERMISSIONS (
    PERMISSION_CODE VARCHAR(256) NOT NULL,
    PERMISSION_NAME VARCHAR(120) DEFAULT 'DEFAULT_PERM' NOT NULL,
    MODULE_CODE VARCHAR(256) NOT NULL,
    DESCRIPTION VARCHAR(256),
    ACTIVE_FLAG CHAR(1) DEFAULT 'Y' NOT NULL,
    PROCESS_TYPE VARCHAR(16) DEFAULT '00' NOT NULL,
    CONSTRAINT PK_SYSTEM_PERMISSIONS PRIMARY KEY (PERMISSION_CODE, MODULE_CODE),
    CONSTRAINT FK_PERM_MODULE FOREIGN KEY (MODULE_CODE)
        REFERENCES SYSTEM_MODULES (MODULE_CODE) ON DELETE CASCADE
);

-- Vertica migration (ON DELETE CASCADE removed and commented)
CREATE TABLE SYSTEM_PERMISSIONS (
    PERMISSION_CODE VARCHAR(256) NOT NULL,
    PERMISSION_NAME VARCHAR(120) DEFAULT 'DEFAULT_PERM' NOT NULL,
    MODULE_CODE VARCHAR(256) NOT NULL,
    DESCRIPTION VARCHAR(256),
    ACTIVE_FLAG CHAR(1) DEFAULT 'Y' NOT NULL,
    PROCESS_TYPE VARCHAR(16) DEFAULT '00' NOT NULL,

    CONSTRAINT PK_SYSTEM_PERMISSIONS PRIMARY KEY (PERMISSION_CODE, MODULE_CODE),
    CONSTRAINT FK_PERM_MODULE FOREIGN KEY (MODULE_CODE) REFERENCES SYSTEM_MODULES (MODULE_CODE)
    -- ON DELETE CASCADE (Vertica does not support this option)
);
```

**Alternative Solutions for Cascade Delete**:
1. **Stored Procedures**: Create procedures to handle cascade deletes manually
2. **Application Logic**: Implement cascade logic in application code

### 3. DB2-Specific Features

#### FETCH FIRST n ROWS ONLY

```sql
-- DB2
SELECT * FROM employees FETCH FIRST 10 ROWS ONLY;
SELECT * FROM employees FETCH FIRST ROW ONLY;

-- Vertica
SELECT * FROM employees LIMIT 10;
SELECT * FROM employees LIMIT 1;
```

#### VALUES Clause

```sql
-- DB2 (used for constants or single-row inserts)
VALUES 1;
VALUES CURRENT TIMESTAMP;
INSERT INTO employees (id, name) VALUES (1, 'John');

-- Vertica (similar usage)
SELECT 1;
SELECT CURRENT_TIMESTAMP;
INSERT INTO employees (id, name) VALUES (1, 'John');
```

#### Special Registers

```sql
-- DB2 special registers
SELECT CURRENT SCHEMA FROM sysibm.sysdummy1;
SELECT CURRENT TIMESTAMP FROM sysibm.sysdummy1;
SELECT CURRENT DATE FROM sysibm.sysdummy1;
SELECT CURRENT TIME FROM sysibm.sysdummy1;

-- Vertica equivalents
SELECT CURRENT_SCHEMA;
SELECT CURRENT_TIMESTAMP;
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
```

#### MATERIALIZED QUERY TABLES (MQT)

```sql
-- DB2 MQT
CREATE TABLE sales_summary AS (
    SELECT product_id, SUM(quantity) as total_quantity, SUM(amount) as total_amount
    FROM sales
    GROUP BY product_id
)
DATA INITIALLY DEFERRED
REFRESH DEFERRED
ENABLE QUERY OPTIMIZATION;

-- Vertica: Use Live Aggregate Projections
CREATE PROJECTION sales_summary AS
SELECT product_id, SUM(quantity) as total_quantity, SUM(amount) as total_amount
FROM sales
GROUP BY product_id
ORDER BY product_id
SEGMENTED BY HASH(product_id) ALL NODES;
```

### 4. Recursive CTE Migration

**Challenge**: DB2 supports standard `WITH RECURSIVE` CTEs that are syntactically close to Vertica, but with notable differences in recursion depth limits and recursive term restrictions.

#### Key Differences at a Glance

| Feature | DB2 | Vertica |
|---------|-----|---------|
| `WITH RECURSIVE` syntax | ✅ Standard | ✅ Standard (identical) |
| **INSERT + CTE order** | **`INSERT` before WITH** (same as Vertica) | **`INSERT` before WITH** |
| Default recursion depth | **Unlimited** (governed by `max_recursive_iterations` in some configurations) | **8** (`WithClauseRecursionLimit`) |
| `*` in anchor term | ✅ Allowed | ❌ **Not allowed** |
| Multiple CTE references in recursive term | ✅ Allowed | ❌ **Only 1 reference** |
| Outer join in recursive term | ✅ Allowed | ❌ **Not allowed** |
| Subquery referencing CTE in recursive term | ✅ Allowed | ❌ **Not allowed** |
| `FETCH FIRST n ROWS` inside UNION | ✅ Allowed | ❌ **Not allowed** |
| Cycle detection | ❌ No built-in | ❌ No built-in |

#### Critical: Recursion Depth Limit

DB2 has no hard default recursion depth limit, while Vertica defaults to **8**. Deep hierarchies will be silently truncated.

```sql
-- DB2: no hard recursion limit
WITH emp_hierarchy (employee_id, manager_id, name, level) AS (
    SELECT employee_id, manager_id, name, 1
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

WITH RECURSIVE emp_hierarchy (employee_id, manager_id, name, level) AS (
    SELECT employee_id, manager_id, name, 1
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;
```

#### Non-Recursive Term Cannot Use `*`

```sql
-- ❌ DB2 allows, but Vertica does NOT
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
-- ❌ DB2: multiple CTE references in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM cte a JOIN cte b ON a.id = b.parent_id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ DB2: outer join in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM employees e
    LEFT JOIN cte ON e.manager_id = cte.id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ DB2: subquery referencing CTE in recursive term
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

#### DB2 `FETCH FIRST n ROWS ONLY` Inside UNION

DB2 allows `FETCH FIRST` inside the recursive term. Vertica does not allow `LIMIT` / `ORDER BY` inside the UNION:

```sql
-- ❌ DB2: FETCH FIRST in recursive term
WITH RECURSIVE cte AS (
    SELECT id, name, 1 AS level FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.name, c.level + 1
    FROM nodes n
    JOIN cte c ON n.parent_id = c.id
    FETCH FIRST 100 ROWS ONLY  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ✅ Vertica: move LIMIT to outer query
WITH RECURSIVE cte AS (
    SELECT id, name, 1 AS level FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.name, c.level + 1
    FROM nodes n
    JOIN cte c ON n.parent_id = c.id
)
SELECT * FROM cte LIMIT 100;
```

#### CTE Variable Assignment in Stored Procedures

**DB2 SQL PL** uses `SELECT ... INTO var FROM cte` to assign CTE results to variables — the `INTO` clause is placed between the select-list and the `FROM` clause. **Vertica PL/vSQL** uses a different syntax: `var := WITH cte AS (...) SELECT ...`, where the entire `WITH ... SELECT` is the expression being assigned. Parentheses are optional:

```sql
-- ✅ DB2 SQL PL: SELECT ... INTO var (INTO between SELECT and FROM)
WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
SELECT cnt INTO v_count FROM cte;

-- ❌ This DB2 syntax does NOT work in Vertica

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

## Common Migration Errors and Solutions

#### Error: Parameter keywords removed
**Problem**: `p_tax OUT DECIMAL(10,2)` becomes `p_tax NUMERIC(10,2)`
**Solution**: Always preserve OUT/INOUT: `OUT p_tax NUMERIC(10,2)`

#### Error: Incorrect data type for parameters
**Problem**: `DECIMAL` type used as parameter
**Solution**: Use `NUMERIC` instead

#### Error: Missing parameter mode specification
**Problem**: `INOUT` parameters converted to plain parameters
**Solution**: Always specify `INOUT` for bidirectional parameters

#### Error: Incorrect exception handling
**Problem**: Using DB2 `DECLARE HANDLER` syntax (e.g., `DECLARE EXIT HANDLER FOR SQLEXCEPTION`, `DECLARE CONTINUE HANDLER FOR NOT FOUND`, `DECLARE UNDO HANDLER`) without adaptation. These constructs do not exist in Vertica PL/vSQL.
**Solution**: Rewrite using Vertica's `EXCEPTION` block model:
- `DECLARE EXIT HANDLER FOR SQLEXCEPTION` → `EXCEPTION WHEN OTHERS THEN ...`
- `DECLARE CONTINUE HANDLER FOR NOT FOUND` → Check `FOUND` special variable or use `EXIT WHEN NOT FOUND` in loops
- `DECLARE EXIT HANDLER FOR SQLWARNING` → `EXCEPTION WHEN OTHERS THEN ...` (no direct equivalent)
- `DECLARE UNDO HANDLER` → Vertica's automatic transaction rollback on unhandled exceptions
- `GET DIAGNOSTICS CONDITION 1` → `GET STACKED DIAGNOSTICS`
- `SQLCODE` → `SQLSTATE` (string format)
- `DB2_RETURNED_SQLCODE` → `RETURNED_SQLSTATE`
See the Exception Handling section above for complete migration patterns and code examples.

#### Error: Named conditions not migrated
**Problem**: Using DB2 `DECLARE condition_name CONDITION FOR SQLSTATE 'xxxxx'` with `SIGNAL` / `RESIGNAL`. These constructs do not exist in Vertica PL/vSQL.
**Solution**: Replace named conditions with direct SQLSTATE-based exception handling:
- `DECLARE name CONDITION FOR SQLSTATE 'xxxxx'` → **Remove** the declaration; use the SQLSTATE code directly
- `SIGNAL name SET MESSAGE_TEXT = '...'` → `RAISE EXCEPTION SQLSTATE 'xxxxx' USING MESSAGE = '...'`
- `SIGNAL SQLSTATE 'xxxxx' SET MESSAGE_TEXT = '...'` → `RAISE EXCEPTION SQLSTATE 'xxxxx' USING MESSAGE = '...'`
- `RESIGNAL` → `RAISE;` (re-throw current exception)
- `RESIGNAL other_name SET MESSAGE_TEXT = '...'` → `RAISE EXCEPTION SQLSTATE 'yyyyy' USING MESSAGE = '...'` (transform)
- `DECLARE EXIT HANDLER FOR name` → `EXCEPTION WHEN SQLSTATE 'xxxxx' THEN`
Custom SQLSTATE codes in the `80xxx` and `45xxx` ranges work the same way in Vertica. See Migration Patterns 7–10 in the Exception Handling section.

#### Error: DB2 special registers not converted
**Problem**: Using `CURRENT TIMESTAMP FROM sysibm.sysdummy1` syntax
**Solution**: Convert to `NOW()` or `CURRENT_TIMESTAMP`

#### Error: FETCH FIRST syntax not converted
**Problem**: Using `FETCH FIRST n ROWS ONLY` syntax
**Solution**: Convert to `LIMIT n`

## DB2 to Vertica Migration Checklist

### 🚨 Critical Parameter Handling

See the [Generic Migration Guide — Critical Parameter Handling](generic-migration-guide.md#-critical-parameter-handling) for the common checklist items. Add DB2-specific items here when needed.

### 📋 General Migration Checklist

See the [Generic Migration Guide — General Migration Checklist](generic-migration-guide.md#-general-migration-checklist) for the common checklist items. The following DB2-specific items also apply:

- [ ] `LANGUAGE SQL` removed (not needed in Vertica)
- [ ] `BEGIN` changed to `AS $$`
- [ ] `END procedure_name;` changed to `END;`
- [ ] **MQT (Materialized Query Tables)**: Convert to Live Aggregate Projections
- [ ] **Modules/Packages**: Convert to individual procedures and functions
- [ ] `DECLARE EXIT HANDLER FOR SQLEXCEPTION` migrated to `EXCEPTION WHEN OTHERS THEN` block
- [ ] `DECLARE CONTINUE HANDLER FOR NOT FOUND` migrated to `FOUND` special variable or `EXIT WHEN NOT FOUND`
- [ ] `DECLARE {EXIT|CONTINUE} HANDLER FOR SQLWARNING` migrated to `EXCEPTION WHEN OTHERS THEN` block
- [ ] `DECLARE UNDO HANDLER` removed (Vertica handles rollback automatically)
- [ ] `GET DIAGNOSTICS CONDITION 1` replaced with `GET STACKED DIAGNOSTICS`
- [ ] `SQLCODE` replaced with `SQLSTATE`
- [ ] `DECLARE CONDITION FOR SQLSTATE` declarations removed (use SQLSTATE codes directly in RAISE EXCEPTION)
- [ ] `SIGNAL name` replaced with `RAISE EXCEPTION SQLSTATE 'xxxxx'`
- [ ] `RESIGNAL` replaced with `RAISE;`
- [ ] `DECLARE HANDLER FOR named_condition` replaced with `EXCEPTION WHEN SQLSTATE 'xxxxx' THEN`
- [ ] DB2 special registers converted to Vertica functions
- [ ] FETCH FIRST syntax converted to LIMIT

### 🚫 Critical "Never" Rules

- [ ] Never use DB2-specific syntax without conversion (e.g., `FETCH FIRST`, `FROM sysibm.sysdummy1`)
- [ ] Never ignore DB2 modules/packages - convert them to individual objects

This comprehensive guide provides the foundation for successful DB2 to Vertica migration, focusing on both syntax conversion and performance optimization.
