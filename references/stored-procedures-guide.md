# Vertica Stored Procedures (PL/vSQL) Guide

This guide covers comprehensive stored procedure development in Vertica using PL/vSQL, including syntax, best practices, and advanced features.

## PL/vSQL Overview

PL/vSQL (Procedural Language/Vertica SQL) is Vertica's procedural language for writing stored procedures. It's based on PostgreSQL's PL/pgSQL and is designed for OLAP workloads.

### Key Characteristics
- **Optimized for analytical processing** rather than OLTP (frequent small transactions can hinder performance)
- **Set-based operations** preferred over row-by-row processing
- **Direct database access** without network overhead
- **Exception handling** with comprehensive error management using GET STACKED DIAGNOSTICS
- **Variable scoping** with block-level visibility
- **PL/pgSQL compatibility** with minor semantic differences
- **Nested procedure support** (up to 50 levels deep) when enabled via configuration

### SQL Command Usage Scope in PL/vSQL

Understanding which SQL commands can be used inside and outside stored procedures is crucial for effective Vertica development:

#### Commands Only Available in PL/vSQL Context

| Command | Purpose | Cannot Use Outside PL/vSQL |
|---------|---------|---------------------------|
| `DECLARE` | Variable declaration | ✅ |
| `BEGIN...END` | Code blocks | ✅ |
| `IF...THEN...END IF` | Conditional logic | ✅ |
| `LOOP...END LOOP` | Looping constructs | ✅ |
| `:=` `<--` | Variable assignment | ✅ |
| `RAISE` | Error handling and messaging | ✅ |
| `EXCEPTION` | Error handling blocks | ✅ |
| `EXECUTE` | Dynamic SQL construction | ✅ |
| `PERFORM` | Execute SQL and discard output (row counts, Tuples/Tuple, status messages) for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE and other SQL statements | ✅ |

#### Commands Available in Both Contexts

| Command | In PL/vSQL | Outside PL/vSQL | Notes |
|---------|------------|-----------------|-------|
| `CALL` | Can call other procedures | ✅ Direct execution | Same syntax |
| `DO` | N/A (not needed) | ✅ Execute anonymous blocks | External only |

## Basic Procedure Structure

### CREATE PROCEDURE Syntax

```sql
CREATE [ OR REPLACE ] PROCEDURE [ IF NOT EXISTS ]
    [[namespace.]schema.]procedure_name(
    [parameter_mode] parameter_name data_type, ...
)
    [ LANGUAGE 'language-name' ]
    [ SECURITY { DEFINER | INVOKER } ]
AS $$
[DECLARE
    variable_declarations;]
BEGIN
    executable_statements;
[EXCEPTION
    exception_handlers;]
END;
$$;
```

**Key Syntax Elements:**
- **OR REPLACE**: Replace existing procedure with [same name plus the parameter signature](#Procedure-Signatures-and-Overloading) (number, types, order)
- **IF NOT EXISTS**: Create only if procedure doesn't exist (cannot use with OR REPLACE)
- **parameter_mode**: IN (default), OUT, or INOUT
- **LANGUAGE**: PLvSQL (default) or PLpgSQL (for compatibility)
- **SECURITY**: DEFINER (creator's privileges) or INVOKER (caller's privileges)

### Simple Example

```sql
CREATE OR REPLACE PROCEDURE log_message(
    p_message VARCHAR,
    p_level VARCHAR
) AS $$
DECLARE
    v_timestamp TIMESTAMP := SYSDATE();
    v_effective_level VARCHAR;
BEGIN
    -- Handle default value logic inside procedure
    v_effective_level := COALESCE(p_level, 'INFO');
    
    PERFORM INSERT INTO application_logs (message, log_level, created_at)
    VALUES (p_message, v_effective_level, v_timestamp);
    
    RAISE NOTICE 'Logged: %', p_message;
END;
$$;
```

## Parameter Types

### ⚠️ Parameter Type Limitations

**The following data types CANNOT be used as stored procedure parameters** (they can only be used as variables inside procedures):

- **DECIMAL**
- **NUMERIC**
- **NUMBER**
- **MONEY**
- **UUID**
- **GEOGRAPHY**
- **GEOMETRY**
- **Complex types** (ARRAY, ROW, SET)

This is a critical limitation that will cause a syntax error if attempted:

```sql
-- ❌ These will NOT work as procedure parameters
CREATE PROCEDURE invalid_example(
    p_decimal_param DECIMAL,      -- Syntax error!
    p_numeric_param NUMERIC,      -- Syntax error!
    p_number_param NUMBER,        -- Syntax error!
    p_money_param MONEY,          -- Syntax error!
    p_uuid_param UUID,            -- Syntax error!
    p_geo_param GEOGRAPHY,        -- Syntax error!
    p_geom_param GEOMETRY         -- Syntax error!
) AS $$
BEGIN
    -- procedure body
END;
$$;
```

**Note**: These type limitations are planned to be addressed in future Vertica releases.

### Workarounds for Unsupported Parameter Types

#### Option 1: Use FLOAT/DOUBLE for Decimal Values

```sql
CREATE PROCEDURE process_salary(
    p_salary_amount FLOAT  -- Use FLOAT instead of NUMERIC(10,2)
) AS $$
DECLARE
    v_salary NUMERIC;  -- Can use NUMERIC in DECLARE section
BEGIN
    v_salary := p_salary_amount::NUMERIC;  -- Cast to NUMERIC for calculations
    -- Rest of procedure logic
END;
$$;
```

#### Option 2: Use INTEGER for Fixed-Point Arithmetic

```sql
CREATE PROCEDURE process_price(
    p_price_cents INTEGER  -- Store as cents (e.g., $10.99 = 1099 cents)
) AS $$
DECLARE
    v_price_dollars NUMERIC;
BEGIN
    v_price_dollars := p_price_cents / 100.0;
    -- Rest of procedure logic
END;
$$;
```

#### Option 3: Pass as VARCHAR and Convert

```sql
CREATE PROCEDURE process_decimal_value(
    p_decimal_str VARCHAR  -- Pass as string
) AS $$
DECLARE
    v_decimal NUMERIC;
BEGIN
    v_decimal := p_decimal_str::NUMERIC;
    -- Rest of procedure logic
END;
$$;
```

**Note**: While these types cannot be used as parameters, they can be freely used within the procedure body for variable declarations and internal calculations.

## Parameter Modes (IN, OUT, INOUT)

Each formal parameter of a stored procedure can be set to one of the following parameter modes. If unspecified, the parameter defaults to IN mode.

### ⚠️ Important Behavior Note for OUT/INOUT Parameters

**How Vertica Returns OUT/INOUT Values**: When a stored procedure has OUT or INOUT parameters, the `CALL` statement returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter value. This is the fundamental mechanism for returning data from Vertica stored procedures.

```sql
-- Procedure with one OUT parameter
CALL sum_procedure(38, 19);
-- Returns one tuple: (57) — a single row, single column

-- Procedure with multiple OUT parameters
CALL get_employee_stats(10);
-- Returns one tuple: (25, 55000.00, 120000.00) — a single row, three columns
-- Column names match the OUT parameter names: emp_count, avg_salary, max_salary
```

- **Tuple/Record Return**: `CALL procedure_name(...)` returns a single tuple (one row) containing all OUT/INOUT values. Each column in the tuple is named after the corresponding OUT/INOUT parameter.
- **No Variable Modification**: Unlike Oracle, these parameters do NOT actually change the values of the variables passed in during the procedure call
- **Original Variables Preserved**: The original input variables remain unchanged after the procedure executes
- **Additional Return Channel**: Think of OUT/INOUT parameters as providing additional ways to return data, not as modifying input variables

This behavior is important to understand when migrating from Oracle or other databases where OUT parameters can modify calling variables.

### 1. IN Parameters (Input - Default)

**IN parameters** are used to pass values into the stored procedure.

- **Default mode**: If no mode is specified, parameters are IN by default
- **Read-only**: IN parameter values cannot be modified within the procedure
- **Required**: Must be provided when calling the procedure
- **Use case**: Passing input data for processing

```sql
CREATE PROCEDURE raiseXY(IN x INT, y VARCHAR) LANGUAGE PLvSQL AS $$
BEGIN
    RAISE NOTICE 'x = %', x;
    RAISE NOTICE 'y = %', y;
END
$$;

-- Call with IN parameters (y defaults to IN)
CALL raiseXY(3, 'some string');
```

### 2. OUT Parameters (Output)

**OUT parameters** are used to return values from the stored procedure.

- **Initialization**: OUT parameters are initialized to NULL when the procedure starts
- **Writable**: Can be assigned values within the procedure
- **Optional in call**: Do not need to provide values when calling
- **Tuple Return**: `CALL` returns a single tuple (record) containing all OUT/INOUT values as named columns
- **Important behavior**: OUT parameters return a tuple but do NOT modify the original variables passed during the procedure call
- **Use case**: Returning computed results or status information

```sql
CREATE PROCEDURE sum_procedure(IN x INT, IN y INT, OUT z INT) LANGUAGE PLvSQL AS $$
BEGIN
    RAISE NOTICE 'This procedure returns the sum of x and y as z:';
    z := x + y;
END
$$;

-- Call with only IN parameters (OUT parameter not provided)
CALL sum_procedure(38, 19);
-- Returns a single tuple: (57) — one row, column name is "z"
```

### 3. INOUT Parameters (Input/Output)

**INOUT parameters** serve as both input and output parameters.

- **Bidirectional**: Accept input values and can return modified values
- **Initialization**: Initialized to the value passed by the caller
- **Modifiable**: Can be changed within the procedure
- **Required**: Must be provided when calling
- **Tuple Return**: `CALL` returns a single tuple (record) containing all OUT/INOUT values as named columns
- **Important behavior**: INOUT parameters return a tuple but do NOT modify the original variables passed during the procedure call (unlike Oracle or other databases)
- **Use case**: Echoing input, in-place transformations

```sql
CREATE PROCEDURE echo(INOUT x INT) LANGUAGE PLvSQL AS $$
BEGIN
    RAISE NOTICE 'This procedure returns its input:';
    -- x can be modified here if needed
    -- x := x * 2; -- Example modification
END
$$;

-- Call with INOUT parameter
CALL echo(19);
-- Returns a single tuple: (19) — one row, column name is "x"
```

### Example: Multiple OUT Parameter Assignment

**How `:= CALL` works**: When a stored procedure has OUT or INOUT parameters, `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The `:=` assignment unpacks the tuple's columns into comma-separated variables by position:

```
var1, var2, var3 := CALL procedure_name(args);
--     ^^^^  ^^^^  ^^^^
--     col1  col2  col3  (based on OUT/INOUT parameter order)
```

This is particularly useful for migrating SQL functions from Oracle or other databases:

```sql
-- Procedure with multiple OUT parameters
CREATE PROCEDURE get_employee_info(
    IN emp_id INTEGER,
    OUT emp_name VARCHAR,
    OUT emp_salary DOUBLE PRECISION,
    OUT status VARCHAR
) AS $$
BEGIN
    SELECT name, salary INTO emp_name, emp_salary 
    FROM employees 
    WHERE employee_id = emp_id;
    
    IF FOUND THEN
        status := 'SUCCESS';
    ELSE
        emp_name := NULL;
        emp_salary := 0;
        status := 'NOT_FOUND';
    END IF;
END;
$$;

-- Usage: Multiple variable assignment from OUT parameters
DO $$
DECLARE
    v_name VARCHAR;
    v_salary DOUBLE PRECISION;
    v_status VARCHAR;
BEGIN
    -- Assign multiple OUT parameters to variables simultaneously
    v_name, v_salary, v_status := CALL get_employee_info(123);
    
    RAISE NOTICE 'Employee: %, Salary: %, Status: %', v_name, v_salary, v_status;
END
$$;
```

**Key Points:**
- `CALL` returns a **single tuple (record)** with one column per OUT/INOUT parameter
- `var1, var2, var3 := CALL proc(...)` **unpacks the tuple** — each variable receives the column value at the corresponding position
- Left-side variables must match the number and types of OUT/INOUT parameters
- Order of variables must correspond to order of OUT/INOUT parameters in procedure definition
- For a single OUT parameter, `var := CALL proc(...)` works directly (one-column tuple → scalar)
- This syntax is ideal for SQL function migration scenarios from Oracle or other databases

### Procedure Signatures and Overloading

A procedure 's signature is defined by the procedure's name and **input parameter types only** (IN and INOUT parameters). OUT parameters are not part of the signature.

```sql
-- Valid overloading: Different input parameter types
CREATE PROCEDURE find_average(IN a INT, IN b INT, IN c INT, OUT avg_result DOUBLE PRECISION) AS $$
BEGIN
    avg_result := (a + b + c) / 3.0;
END;
$$;

CREATE PROCEDURE find_average(IN a FLOAT, IN b FLOAT, IN c FLOAT, OUT avg_result DOUBLE PRECISION) AS $$
BEGIN
    avg_result := (a + b + c) / 3.0;
END;
$$;
```

## Parameter DEFAULT Keyword Limitation and Solution

**Important**: Vertica PL/vSQL does not support the `DEFAULT` keyword in procedure parameter declarations. The following syntax will result in a syntax error:

```sql
-- ❌ This will NOT work in Vertica
CREATE PROCEDURE example_proc(
    p_param1 INT，
    p_param2 VARCHAR DEFAULT 'default_value'  -- Syntax error!
) AS $$
BEGIN
    -- procedure body
END;
$$;
```

**Solution**: Use Procedure Overloading for 100% other databases Compatibility

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**
> Procedure overloading in Vertica works by matching the **procedure name** plus the parameter signature (number, types, order). Every overloaded variant **must** share the identical procedure name — only the parameter list differs. Using different names defeats the purpose of overloading and breaks call compatibility.

Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values:

```sql
-- Main procedure with all parameters
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

-- Overloaded versions for default parameters
-- ⚠️  ALL variants use the SAME name "process_order" — only the parameter COUNT differs
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER
) AS $$
BEGIN
    -- All parameters use defaults: 0.1, 'NORMAL', NULL
    PERFORM CALL process_order(p_order_id, 0.1, 'NORMAL', NULL);
END;
$$;

-- ⚠️  SAME name "process_order" — 2 parameters instead of 4
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount FLOAT
) AS $$
BEGIN
    -- Partial defaults: 'NORMAL', NULL
    PERFORM CALL process_order(p_order_id, p_discount, 'NORMAL', NULL);
END;
$$;

-- Usage examples (100% Oracle and other databases compatible)
-- CALL process_order(1001);                    -- All defaults
-- CALL process_order(1001, 0.15);             -- Partial defaults  
-- CALL process_order(1001, 0.15, 'HIGH');     -- Partial defaults
-- CALL process_order(1001, 0.15, 'HIGH', 'Urgent'); -- No defaults
```

**Key Advantages:**
✅ **Perfect Oracle and  Other Databases Compatibility** - All Oracle calling patterns work unchanged  
✅ **Correct NULL Handling** - Explicit NULLs vs defaults are properly distinguished  
✅ **Maintainable** - Business logic exists only in main procedure  

## Embedded SQL and PERFORM Command

In PL/vSQL, the PERFORM command is used to **discard the output** produced by SQL statements. In Vertica, every SQL statement that can execute outside a stored procedure produces a response:

- **DML** (INSERT, UPDATE, DELETE, MERGE) → outputs the number of rows affected
- **SELECT** and **CALL** → outputs `Tuples` or `Tuple`
- **DDL** (CREATE, ALTER, DROP, etc.), **COMMIT**, **ROLLBACK**, and other statements → outputs success/failure messages
- **EXECUTE** (dynamic SQL inside stored procedures) → can execute any of the above dynamic statements, producing the corresponding output (row counts, `Tuples`/`Tuple`, or status messages)

**Why errors occur**: PL/vSQL does not have a "standalone SQL statement" syntax. Every embedded SQL must appear in one of two positions: on the right-hand side of an assignment (`var := SQL`), or after `PERFORM` (`PERFORM SQL`). When a SQL keyword appears in any other position, the parser interprets it as an identifier (variable name) and expects an assignment operator, producing:

```
syntax error, unexpected <keyword>, expecting := or <-
```

**Resolution** — two syntactic positions for embedded SQL:

If the output is not captured via one of the following assignment forms, `PERFORM` must be prepended to discard it:

| Capture Form | Example |
|---|---|
| `var := SQL_STATEMENT` | `v_count := UPDATE employees SET salary = salary * 1.1;` |
| `var <- SQL_STATEMENT` | `v_name <- SELECT name FROM employees WHERE id = 1;` |
| `SELECT ... INTO ...` | `SELECT name INTO v_name FROM employees WHERE id = 1;` |
| `EXECUTE ... INTO ...` | `EXECUTE 'SELECT name FROM employees WHERE id = $1' INTO v_name USING 1;` |

**When none of these capture forms is used, `PERFORM` is required.**

### When to Use PERFORM

Use PERFORM for:
- DDL statements (CREATE, ALTER, DROP, TRUNCATE, etc.)
- INSERT statements when you don't need the inserted row count
- UPDATE statements when you don't need the updated row count
- DELETE statements when you don't need the deleted row count
- MERGE statements for data synchronization
- CALL procedure statements
- COMMIT
- ROLLBACK
- EXECUTE (dynamic SQL) when you don't need to capture the result
- Any SQL statement where you want to discard the return value

### PERFORM Syntax

```sql
PERFORM statement;
PERFORM expression;
```

### Examples of PERFORM Usage

```sql
CREATE PROCEDURE process_data() AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Use PERFORM for DDL, DML statements when row count not needed immediately
    PERFORM INSERT INTO audit_log (message, created_at) 
    VALUES ('Processing started', SYSDATE());
    
    PERFORM UPDATE employees 
    SET last_updated = SYSDATE() 
    WHERE status = 'ACTIVE';
    
    PERFORM DELETE FROM temp_data 
    WHERE processed_date < CURRENT_DATE - 30;
    
    -- Get row count after PERFORM if needed
    SELECT COUNT(*) INTO v_count FROM employees WHERE status = 'ACTIVE';
    
    RAISE NOTICE 'Processed % records', v_count;
END;
$$;
```

### PERFORM vs Direct Assignment

```sql
CREATE PROCEDURE demonstrate_differences() AS $$
DECLARE
    v_result INTEGER;
    v_count INTEGER;
    v_name VARCHAR;
BEGIN
    -- Direct assignment: captures return value (number of rows affected)
    v_result := UPDATE employees SET salary = salary * 1.1;
    RAISE NOTICE 'Updated % employees', v_result;
    
    -- PERFORM: executes DML statement but discards row count output
    PERFORM UPDATE employees SET last_updated = SYSDATE();
    
    -- SELECT ... INTO: captures query result, no PERFORM needed
    SELECT name INTO v_name FROM employees WHERE id = 1;
    
    -- EXECUTE ... INTO: captures dynamic SQL result, no PERFORM needed
    EXECUTE 'SELECT name FROM employees WHERE id = $1' INTO v_name USING 1;
    
    -- PERFORM EXECUTE: executes dynamic SQL but discards output (row counts, Tuples/Tuple, or status messages)
    PERFORM EXECUTE 'UPDATE employees SET last_updated = SYSDATE()';
    
    -- Get row count separately if needed
    SELECT COUNT(*) INTO v_count FROM employees;
    RAISE NOTICE 'Total % rows', v_count;
END;
$$;
```

## Dynamic SQL with EXECUTE Command

The EXECUTE command allows you to dynamically construct and execute SQL statements during runtime. This is essential for flexible stored p
rocedures that need to adapt to different scenarios.

### EXECUTE Command Syntax

```sql
EXECUTE command_expression [ INTO target [, ...] ] [ USING expression [, ...] ];
```

- `command_expression`: A SQL expression that evaluates to a string literal containing the SQL statement
- `INTO`: Optional clause to assign query results to variables (for SELECT statements)
- `USING`: Optional clause to pass parameters safely (referenced as $1, $2, etc. in the SQL string)

> **Note**: `INTO` must come before `USING` when both are present.

### Parameter Substitution vs String Concatenation

**✅ Recommended: Parameter Substitution (Better Readability & Security)**
```sql
-- Clear, readable, and secure
PERFORM EXECUTE 'SELECT * FROM users WHERE id = $1 AND status = $2'
USING user_id, 'ACTIVE';
```

**❌ Not Recommended: String Concatenation (Poor Readability & Security Risk)**
```sql
-- Hard to read, error-prone, vulnerable to SQL injection
v_sql := 'SELECT * FROM users WHERE id = ' || user_id ||
         ' AND status = ''' || status_value || '''';
PERFORM EXECUTE v_sql;
```

### EXECUTE with Parameter Substitution Examples

```sql
CREATE PROCEDURE search_employees(
    p_department VARCHAR,
    p_min_salary NUMERIC,
    p_name_pattern VARCHAR
)
LANGUAGE PLvSQL AS $$
DECLARE
    v_sql VARCHAR(1000) := 'SELECT id, name, department, salary FROM employees WHERE 1=1';
    v_id INTEGER;
    v_name VARCHAR(100);
    v_department VARCHAR(100);
    v_salary NUMERIC;
BEGIN
    -- Build dynamic WHERE clause with parameter placeholders
    IF p_department IS NOT NULL THEN
        v_sql := v_sql || ' AND department = $1';
    END IF;

    IF p_min_salary IS NOT NULL THEN
        v_sql := v_sql || ' AND salary >= $2';
    END IF;

    IF p_name_pattern IS NOT NULL THEN
        v_sql := v_sql || ' AND name LIKE $3';
    END IF;

    v_sql := v_sql || ' ORDER BY salary DESC';

    -- Execute with appropriate parameters based on conditions
    IF p_department IS NOT NULL AND p_min_salary IS NOT NULL AND p_name_pattern IS NOT NULL THEN
        FOR v_id, v_name, v_department, v_salary IN EXECUTE v_sql USING p_department, p_min_salary, p_name_pattern
        LOOP
            RAISE NOTICE 'Employee: % (%, $%)', v_name, v_department, v_salary;
        END LOOP;
    ELSIF p_department IS NOT NULL AND p_min_salary IS NOT NULL THEN
        FOR v_id, v_name, v_department, v_salary IN EXECUTE v_sql USING p_department, p_min_salary
        LOOP
            RAISE NOTICE 'Employee: % (%, $%)', v_name, v_department, v_salary;
        END LOOP;
    ELSIF p_department IS NOT NULL THEN
        FOR v_id, v_name, v_department, v_salary IN EXECUTE v_sql USING p_department
        LOOP
            RAISE NOTICE 'Employee: % (%, $%)', v_name, v_department, v_salary;
        END LOOP;
    ELSE
        FOR v_id, v_name, v_department, v_salary IN EXECUTE v_sql
        LOOP
            RAISE NOTICE 'Employee: % (%, $%)', v_name, v_department, v_salary;
        END LOOP;
    END IF;
END;
$$;
```

### EXECUTE with INTO and USING (Dynamic SQL with Parameter Binding)

When you need to execute a dynamic SELECT with parameters and capture the result, combine `INTO` and `USING`:

```sql
-- Assign result to variable with parameter binding
EXECUTE 'SELECT name FROM users WHERE user_id = $1' INTO v_name USING v_id;

-- Alternative: use := assignment with EXECUTE ... USING
v_name := EXECUTE 'SELECT name FROM users WHERE user_id = $1' USING v_id;

-- Multiple output columns
EXECUTE 'SELECT name, salary FROM employees WHERE id = $1'
    INTO v_name, v_salary
    USING v_id;

-- Multiple parameters
EXECUTE 'SELECT name FROM employees WHERE department = $1 AND salary > $2'
    INTO v_name
    USING p_dept, p_min_salary;
```

Key rules:
- Use `$1`, `$2`, etc. as placeholders (not `?`)
- `INTO` must come before `USING`
- `var := EXECUTE 'sql' USING var` is also valid syntax

### EXECUTE with PERFORM

Use PERFORM with EXECUTE when you don't need to capture the result:

```sql
CREATE PROCEDURE update_employee_emails(
    p_department VARCHAR,
    p_email_domain VARCHAR
)
LANGUAGE PLvSQL AS $$
DECLARE
    v_sql VARCHAR(1000);
BEGIN
    -- Build dynamic UPDATE statement
    v_sql := 'UPDATE employees SET email = name || $1 WHERE department = $2';

    -- Use PERFORM to execute and discard the row count
    PERFORM EXECUTE v_sql USING p_email_domain, p_department;

    RAISE NOTICE 'Updated employee emails for department: %', p_department;
END;
$$;
```

### Safe Dynamic Object Names with QUOTE_IDENT

When you need to use dynamic table or column names, use QUOTE_IDENT to prevent SQL injection:

```sql
CREATE PROCEDURE dynamic_table_count(
    p_schema VARCHAR,
    p_table VARCHAR
)
LANGUAGE PLvSQL AS $$
DECLARE
    v_sql VARCHAR(1000);
    v_count INTEGER;
BEGIN
    -- Safely build SQL with dynamic identifiers
    v_sql := 'SELECT COUNT(*) FROM ' || QUOTE_IDENT(p_schema) || '.' || QUOTE_IDENT(p_table);

    EXECUTE v_sql INTO v_count;

    RAISE NOTICE 'Table %.% has % rows', p_schema, p_table, v_count;
END;
$$;
```

### Safe String Literals with QUOTE_LITERAL

When you must concatenate string values into SQL, use QUOTE_LITERAL:

```sql
CREATE PROCEDURE safe_string_search(
    p_search_term VARCHAR
)
LANGUAGE PLvSQL AS $$
DECLARE
    v_sql VARCHAR(1000);
    v_count INTEGER;
BEGIN
    -- Safe string literal handling
    v_sql := 'SELECT COUNT(*) FROM documents WHERE content LIKE ' ||
             QUOTE_LITERAL('%' || p_search_term || '%');

    EXECUTE v_sql INTO v_count;

    RAISE NOTICE 'Found % documents containing: %', v_count, p_search_term;
END;
$$;
```

### EXECUTE with Error Handling

Always wrap dynamic SQL in exception handlers when dealing with potentially invalid objects:

```sql
CREATE PROCEDURE safe_dynamic_query(
    p_table_name VARCHAR
)
LANGUAGE PLvSQL AS $$
DECLARE
    v_sql VARCHAR(1000);
    v_count INTEGER;
    v_error_msg VARCHAR;
BEGIN
    -- Build dynamic query
    v_sql := 'SELECT COUNT(*) FROM ' || QUOTE_IDENT(p_table_name);

    BEGIN
        EXECUTE v_sql INTO v_count;
        RAISE NOTICE 'Table % has % rows', p_table_name, v_count;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
            RAISE NOTICE 'Error querying table %: %', p_table_name, v_error_msg;
    END;
END;
$$;
```

### Best Practices for EXECUTE Command

1. **Prefer Parameter Substitution**: Always use `USING` clause with $1, $2 placeholders instead of string concatenation
2. **Combine INTO with USING for Parameterized SELECT**: When a dynamic SELECT needs both parameter binding and result capture, prefer `var := EXECUTE 'sql $1' USING val;` over `EXECUTE 'sql $1' INTO var USING val;`. Both are valid, but `var :=` assignment is more consistent with standard PL/vSQL variable assignment patterns.
3. **Use QUOTE_IDENT for Identifiers**: When building dynamic table/column names, always use QUOTE_IDENT()
3. **Use QUOTE_LITERAL for Strings**: When concatenating string values, use QUOTE_LITERAL() for safety
4. **Validate Input Parameters**: Check parameters before using them in dynamic SQL
5. **Handle Errors Gracefully**: Wrap dynamic SQL in exception handlers
6. **Test Thoroughly**: Dynamic SQL can be harder to debug, so test all code paths
7. **Consider Performance**: Parameterized queries can reuse execution plans more effectively
8. **Document Dynamic SQL**: Comment complex dynamic SQL construction for maintainability

## Prefer Static SQL Over Dynamic SQL

For better readability and maintainability, avoid `EXECUTE` whenever possible. DML and SELECT statements support variables and parameters directly — no `EXECUTE` needed. The only difference between `:=` and `PERFORM` is whether you capture the row count; variable usage is the same in both:

```sql
CREATE OR REPLACE PROCEDURE adjust_salary(
    p_emp_id INTEGER,
    p_raise_pct FLOAT
)
AS $$
DECLARE
    v_count INTEGER;
    v_min_raise FLOAT := 0.05;
BEGIN
    -- := captures the row count
    v_count := UPDATE employees
               SET salary = salary * (1 + GREATEST(p_raise_pct, v_min_raise))
               WHERE id = p_emp_id;

    -- PERFORM discards the row count; variables work identically
    PERFORM INSERT INTO audit_log (emp_id, action)
    VALUES (p_emp_id, 'RAISE');
END;
$$;
```

DDL statements define schema objects whose names are known at write time. They do not need variables in identifier positions, and therefore do not need `EXECUTE`:

```sql
CREATE OR REPLACE PROCEDURE setup_tables()
AS $$
BEGIN
    PERFORM CREATE TABLE IF NOT EXISTS staging_data (
        id INTEGER, payload VARCHAR(1000)
    );
    PERFORM CREATE TABLE IF NOT EXISTS audit_log (
        id INTEGER, message VARCHAR(500)
    );
END;
$$;
```

Use `PERFORM EXECUTE` only when an **identifier** (table name, column name, etc.) must be determined at runtime — the one case where static SQL cannot substitute a variable:

```sql
CREATE OR REPLACE PROCEDURE add_column_dynamic(
    p_table VARCHAR, p_column VARCHAR, p_type VARCHAR
)
AS $$
BEGIN
    PERFORM EXECUTE 'ALTER TABLE ' || QUOTE_IDENT(p_table)
                 || ' ADD COLUMN ' || QUOTE_IDENT(p_column) || ' ' || p_type;
END;
$$;
```

### Summary

| Scenario | Approach |
|----------|----------|
| DML / SELECT with variables in value positions | Direct variables (`:=` or `PERFORM`) |
| DDL with fixed object names | Direct `PERFORM CREATE / ALTER / DROP ...` |
| Dynamic identifiers (table/column names) | `PERFORM EXECUTE '...' \|\| QUOTE_IDENT(var)` |

## Variable Declaration and Usage

PL/vSQL uses block scope for variables, which must be declared in a DECLARE block immediately after the AS $$ and before the BEGIN statement.

### Variable Declaration Syntax

```sql
variable_name [CONSTANT] data_type [NOT NULL] [:= expression];
```

### Key Rules for Variables

1. **DECLARE Block Required**: All variables must be declared in a DECLARE block
2. **Sequential Declaration**: Variables are declared sequentially and can reference previously declared variables
3. **Initialization**: Variables can be initialized with := or DEFAULT
4. **Default Value**: Uninitialized variables default to NULL
5. **CONSTANT**: CONSTANT variables can only be set during initialization
6. **NOT NULL**: NOT NULL variables must be initialized and cannot be assigned NULL

### Supported Data Types

PL/vSQL supports all **non-complex** scalar data types for variable declarations. Most types accept optional precision/length parameters, **except** DECIMAL, NUMERIC, NUMBER, MONEY, and UUID which must be declared without parameters (see [Parameter Types](#parameter-types) for the full list of type limitations and workarounds).

| Category | Types | Precision / Length Support |
|----------|-------|:--------------------------|
| **Integer** | INTEGER, BIGINT, SMALLINT, TINYINT, INT8 | — |
| **Exact Numeric** | DECIMAL, NUMERIC, NUMBER | ❌ must be declared without precision/scale |
| **Approximate Numeric** | FLOAT(n), DOUBLE PRECISION, REAL, FLOAT8 | ✅ FLOAT accepts precision |
| **Character** | CHAR(n), VARCHAR(n), LONG VARCHAR | ✅ CHAR and VARCHAR accept length |
| **Binary** | BINARY(n), VARBINARY(n), LONG VARBINARY | ✅ BINARY and VARBINARY accept length |
| **Boolean** | BOOLEAN | — |
| **Date/Time** | DATE, TIME(n), TIMESTAMP(n), TIME(n) WITH TIMEZONE, TIMESTAMP(n) WITH TIMEZONE, INTERVAL, INTERVAL DAY TO SECOND, INTERVAL YEAR TO MONTH | ✅ TIME and TIMESTAMP accept fractional seconds precision |
| **UUID** | UUID | ❌ must be declared without parameters |
| **Money** | MONEY | ❌ must be declared without parameters |

**Types NOT supported as variables:**
- GEOMETRY, GEOGRAPHY — spatial types are entirely excluded
- Complex types (ARRAY, ROW, SET)

> **Note**: `NUMERIC`, `DECIMAL`, `NUMBER`, and `MONEY` share the same underlying type but differ in default precision/scale: `NUMERIC` (37,15), `DECIMAL` (37,15), `NUMBER` (38,0 — integer only), `MONEY` (18,4). For source databases using `NUMBER` with decimals, use `NUMERIC` or `DECIMAL` to preserve fractional digits.

### Basic Variable Declarations

```sql
CREATE PROCEDURE calculate_metrics() AS $$
DECLARE
    -- Scalar variables with initialization
    v_total_revenue INTEGER := 0;
    v_order_count INTEGER DEFAULT 0;
    v_process_date DATE := CURRENT_DATE;
    v_status VARCHAR(20);

    -- Boolean variable
    v_process_complete BOOLEAN := FALSE;

    -- Constant variable (immutable)
    v_max_retries CONSTANT INTEGER := 3;

    -- NOT NULL variable (must be initialized)
    v_start_time TIMESTAMP NOT NULL := SYSDATE();

    -- Variable referencing another (sequential declaration)
    v_end_time TIMESTAMP := v_start_time + INTERVAL '1 hour';

    -- Column type anchoring with %TYPE
    v_employee_name employees.name%TYPE;

    -- Alias (alternate name for same variable)
    v_total ALIAS FOR v_total_revenue;
BEGIN
    RAISE NOTICE 'Processing started at: %', v_start_time;
END;
$$;
```

**%TYPE attribute**: Anchor a variable's type to a table column. This keeps the variable in sync if the column type changes:

```sql
DECLARE
    v_name employees.name%TYPE;       -- Matches employees.name data type
    v_salary employees.salary%TYPE;   -- Matches employees.salary data type
```

> **Note**: Only `%TYPE` is supported. `%ROWTYPE` is **not** available in PL/vSQL.

**Aliases**: An alias is an alternate name for the same variable (not a copy):

```sql
DECLARE
    x INT := 3;
    y ALIAS FOR x;
BEGIN
    y := 5;  -- x is now also 5
    RAISE INFO 'x = %, y = %', x, y;
END;
```

### Variable Scoping and Block Structure

PL/vSQL uses block scope where variables declared in inner blocks shadow those in outer blocks:

```sql
CREATE PROCEDURE nested_blocks_example() AS $$
DECLARE
    v_outer_var VARCHAR := 'outer';
BEGIN
    RAISE NOTICE 'Outer variable: %', v_outer_var;
    
    -- Inner block with its own variables
    DECLARE
        v_inner_var VARCHAR := 'inner';
        v_outer_var VARCHAR := 'shadowed';  -- Shadows outer variable
    BEGIN
        RAISE NOTICE 'Inner variables: %, %', v_inner_var, v_outer_var;
        -- To access outer variable: OUTER_BLOCK.v_outer_var
    END;
    
    RAISE NOTICE 'Back to outer: %', v_outer_var;
END;
$$;
```

### Variable Assignment

```sql
CREATE PROCEDURE variable_assignment_example() AS $$
DECLARE
    v_counter INTEGER := 0;
    v_message VARCHAR(100);
    v_current_date DATE;
BEGIN
    -- Direct assignment
    v_counter := 100;
    v_message := 'Processing complete';
    v_current_date := CURRENT_DATE;
    
    -- Assignment from query result
    SELECT COUNT(*) INTO v_counter FROM employees;
    
    -- Assignment from expression
    v_counter := v_counter * 2;
    
    RAISE NOTICE 'Counter: %, Message: %, Date: %', 
        v_counter, v_message, v_current_date;
END;
$$;
```

### Best Practices for Variable Usage

1. **Always Use DECLARE Block**: Every procedure that uses variables must have a DECLARE block
2. **Initialize Variables**: Always initialize variables to avoid NULL-related issues
3. **Use Descriptive Names**: Use meaningful variable names with consistent naming conventions
4. **Declare Error Variables**: Always declare variables for error handling at the top level
5. **Choose Appropriate Data Types**: Use the most appropriate data type for your data
6. **Use CONSTANT for Immutable Values**: Mark variables as CONSTANT when they shouldn't change
7. **Handle NULLs Explicitly**: Use NOT NULL constraint when NULL values are not acceptable

```sql
-- ✅ Good: Proper variable declaration and usage
CREATE PROCEDURE good_example(p_employee_id INTEGER) AS $$
DECLARE
    v_employee_count INTEGER := 0;
    v_error_message VARCHAR(500);
    v_processing_date CONSTANT DATE := CURRENT_DATE;
    v_required_value INTEGER NOT NULL := 100;
BEGIN
    SELECT COUNT(*) INTO v_employee_count 
    FROM employees 
    WHERE department_id = p_employee_id;
    
    RAISE NOTICE 'Found % employees', v_employee_count;
    
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
        RAISE EXCEPTION 'Error processing department %: %', p_employee_id, v_error_message;
END;
$$;

-- ❌ Bad: Missing DECLARE block and improper syntax
CREATE PROCEDURE bad_example(p_employee_id IN INTEGER) AS $$
    v_count INTEGER;  -- Missing DECLARE block
BEGIN
    -- This will cause syntax errors
END;
$$;

## Cursor Management

Cursors in PL/vSQL allow you to process query results row by row, providing fine-grained control over data processing. They are essential for scenarios requiring row-by-row operations, complex business logic, or when working with dynamic SQL.

### Cursor Types

#### 1. Bound Cursors
Bound cursors are declared with a specific SQL statement and can include parameters for filtering:

```sql
-- Basic bound cursor
DECLARE
    customer_cursor CURSOR FOR SELECT customer_id, name, email FROM customers;

-- Bound cursor with parameters
sales_cursor CURSOR (min_amount INTEGER) FOR 
    SELECT order_id, customer_id, total_amount 
    FROM orders 
    WHERE total_amount >= min_amount;
```

#### 2. Unbound Cursors
Unbound cursors are declared as `refcursor` type and bound to SQL statements later:

```sql
DECLARE
    dynamic_cursor refcursor;
BEGIN
    -- Bind and open later
    OPEN dynamic_cursor FOR SELECT * FROM customers WHERE status = 'ACTIVE';
```

### Cursor Operations

#### Declaration
```sql
-- Bound cursor with parameters
cursor_name CURSOR (param1 type1, param2 type2) FOR SELECT_statement;

-- Unbound cursor
cursor_name refcursor;
```

#### Opening Cursors
```sql
-- Open bound cursor with parameters
OPEN cursor_name(value1, value2);
OPEN cursor_name(param1 := value1, param2 := value2);

-- Open unbound cursor
OPEN cursor_name FOR SELECT_statement;
OPEN cursor_name FOR EXECUTE dynamic_sql_string;
```

#### Fetching Data
```sql
-- FETCH retrieves current row and advances cursor
var1, var2, var3 := FETCH cursor_name;

-- FOUND special variable indicates success
IF FOUND THEN
    -- Row was retrieved successfully
    RAISE NOTICE 'Processing row: %, %, %', var1, var2, var3;
ELSE
    -- Cursor is past end of result set
    RAISE NOTICE 'No more rows';
END IF;
```

#### Moving Cursor Position
```sql
-- MOVE advances cursor without retrieving data
MOVE cursor_name;
RAISE NOTICE 'Cursor moved, FOUND=%', FOUND;
```

#### Closing Cursors
```sql
CLOSE cursor_name;
-- Cursors are automatically closed when they go out of scope
```

### Cursor Loops

#### FOR Loop with Cursor (Recommended)
The FOR loop automatically opens the cursor, fetches rows, and closes the cursor:

```sql
CREATE PROCEDURE process_active_customers()
AS $$
DECLARE
    customer_cursor CURSOR FOR 
        SELECT customer_id, name, email 
        FROM customers 
        WHERE status = 'ACTIVE';
    
    v_customer_id INTEGER;
    v_name VARCHAR;
    v_email VARCHAR;
BEGIN
    FOR v_customer_id, v_name, v_email IN CURSOR customer_cursor LOOP
        RAISE NOTICE 'Processing customer: % (%)', v_name, v_email;
        -- Process each customer
    END LOOP;
END;
$$;
```

#### Manual Loop with FETCH
For more control, use manual FETCH operations:

```sql
CREATE PROCEDURE manual_cursor_processing()
AS $$
DECLARE
    customer_cursor CURSOR FOR SELECT customer_id, name FROM customers;
    v_customer_id INTEGER;
    v_name VARCHAR;
BEGIN
    OPEN customer_cursor;
    
    LOOP
        v_customer_id, v_name := FETCH customer_cursor;
        EXIT WHEN NOT FOUND;
        
        RAISE NOTICE 'Processing customer ID: %', v_customer_id;
        -- Additional processing logic
    END LOOP;
    
    CLOSE customer_cursor;
END;
$$;
```

### Advanced Cursor Examples

#### Parameterized Cursor with Exception Handling
```sql
CREATE PROCEDURE process_orders_by_amount(
    p_min_amount INTEGER,
    p_max_amount INTEGER
)
AS $$
DECLARE
    order_cursor CURSOR (min_amt INTEGER, max_amt INTEGER) FOR
        SELECT order_id, customer_id, total_amount, order_date
        FROM orders
        WHERE total_amount BETWEEN min_amt AND max_amt
        ORDER BY order_date DESC;
    
    v_order_id INTEGER;
    v_customer_id INTEGER;
    v_total_amount INTEGER;
    v_order_date DATE;
    v_error_msg VARCHAR;
BEGIN
    FOR v_order_id, v_customer_id, v_total_amount, v_order_date 
    IN CURSOR order_cursor(p_min_amount, p_max_amount) LOOP
        
        BEGIN
            -- Process each order with individual error handling
            PERFORM INSERT INTO order_audit (
                order_id, customer_id, amount, audit_date, status
            ) VALUES (
                v_order_id, v_customer_id, v_total_amount, SYSDATE(), 'PROCESSED'
            );
            
            RAISE NOTICE 'Processed order %: $%', v_order_id, v_total_amount;
            
        EXCEPTION
            WHEN OTHERS THEN
                GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
                RAISE WARNING 'Failed to process order %: %', v_order_id, v_error_msg;
                -- Continue processing other orders
        END;
    END LOOP;
END;
$$;
```

#### Nested Cursors
```sql
CREATE PROCEDURE process_department_employees()
AS $$
DECLARE
    dept_cursor CURSOR FOR 
        SELECT department_id, department_name 
        FROM departments 
        WHERE active = TRUE;
    
    emp_cursor CURSOR (dept_id INTEGER) FOR
        SELECT employee_id, name, salary
        FROM employees
        WHERE department_id = dept_id
        AND status = 'ACTIVE';
    
    v_dept_id INTEGER;
    v_dept_name VARCHAR;
    v_emp_id INTEGER;
    v_emp_name VARCHAR;
    v_salary INTEGER;
    v_emp_count INTEGER;
BEGIN
    FOR v_dept_id, v_dept_name IN CURSOR dept_cursor LOOP
        RAISE NOTICE 'Processing department: %', v_dept_name;
        v_emp_count := 0;
        
        FOR v_emp_id, v_emp_name, v_salary IN CURSOR emp_cursor(v_dept_id) LOOP
            v_emp_count := v_emp_count + 1;
            RAISE NOTICE '  Employee %: % ($%)', v_emp_id, v_emp_name, v_salary;
        END LOOP;
        
        RAISE NOTICE 'Department %: % employees processed', v_dept_name, v_emp_count;
    END LOOP;
END;
$$;
```

#### Dynamic SQL with Unbound Cursors
```sql
CREATE PROCEDURE dynamic_cursor_query(
    p_table_name VARCHAR,
    p_column_name VARCHAR,
    p_filter_value VARCHAR
)
AS $$
DECLARE
    dynamic_cursor refcursor;
    v_sql VARCHAR(1000);
    v_id INTEGER;
    v_name VARCHAR;
    v_error_msg VARCHAR;
BEGIN
    -- Build dynamic query safely
    v_sql := 'SELECT id, name FROM ' || QUOTE_IDENT(p_table_name) || 
             ' WHERE ' || QUOTE_IDENT(p_column_name) || ' = $1';
    
    BEGIN
        OPEN dynamic_cursor FOR EXECUTE v_sql USING p_filter_value;
        
        LOOP
            FETCH dynamic_cursor INTO v_id, v_name;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE 'Found: ID=%, Name=%', v_id, v_name;
        END LOOP;
        
        CLOSE dynamic_cursor;
        
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
            RAISE EXCEPTION 'Dynamic query failed: %', v_error_msg;
    END;
END;
$$;
```

### Cursor with Loop Control Statements

```sql
CREATE PROCEDURE selective_processing()
AS $$
DECLARE
    data_cursor CURSOR FOR 
        SELECT id, value, category 
        FROM data_table 
        ORDER BY id;
    
    v_id INTEGER;
    v_value INTEGER;
    v_category VARCHAR;
    v_processed_count INTEGER := 0;
BEGIN
    FOR v_id, v_value, v_category IN CURSOR data_cursor LOOP
        -- Skip certain categories
        IF v_category = 'IGNORED' THEN
            CONTINUE;
        END IF;
        
        -- Process valid records
        v_processed_count := v_processed_count + 1;
        RAISE NOTICE 'Processing ID %: % (%)', v_id, v_value, v_category;
        
        -- Exit after processing 100 records
        IF v_processed_count >= 100 THEN
            RAISE NOTICE 'Reached processing limit of 100 records';
            EXIT;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Total records processed: %', v_processed_count;
END;
$$;
```

### Best Practices for Cursor Usage

1. **Prefer FOR Loops**: Use FOR loops with cursors for simpler, cleaner code
2. **Use Parameters**: Parameterize bound cursors for flexibility and reusability
3. **Handle Exceptions**: Always include exception handling in cursor loops
4. **Close Explicitly**: While cursors auto-close, explicitly close them when done
5. **Check FOUND**: Always check the FOUND variable after FETCH operations
6. **Avoid Nested Loops**: Minimize deeply nested cursor loops for performance
7. **Use Dynamic SQL Safely**: When using dynamic SQL, always use QUOTE_IDENT and parameter substitution
8. **Consider Alternatives**: Evaluate if set-based operations can replace cursor loops

### Performance Considerations

- **Set-based vs Row-by-row**: Prefer set-based operations over cursors when possible
- **Cursor Overhead**: Cursors have overhead; use them only when row-by-row processing is necessary
- **Memory Usage**: Large result sets in cursors consume memory
- **Locking**: Cursors may hold locks on underlying tables
- **Statistics**: Ensure statistics are up-to-date for optimal cursor performance

## Control Structures

### IF Statements
```sql
CREATE PROCEDURE evaluate_performance(
    p_employee_id INTEGER
) AS $$
DECLARE
    v_sales_total INTEGER;
    v_target INTEGER := 100000;
    v_rating VARCHAR;
BEGIN
    SELECT COALESCE(SUM(sales_amount), 0)
    INTO v_sales_total
    FROM sales
    WHERE employee_id = p_employee_id
    AND sale_date >= ADD_MONTHS(SYSDATE(), -12);
    
    IF v_sales_total >= v_target * 1.2 THEN
        p_rating := 'EXCELLENT';
    ELSIF v_sales_total >= v_target THEN
        p_rating := 'GOOD';
    ELSIF v_sales_total >= v_target * 0.8 THEN
        p_rating := 'SATISFACTORY';
    ELSE
        p_rating := 'NEEDS IMPROVEMENT';
    END IF;
END;
$$;
```

### CASE Statements
```sql
CREATE PROCEDURE set_pricing_tier(
    IN p_customer_id INTEGER,
    OUT p_tier VARCHAR
) AS $$
    v_total_spent NUMERIC;
BEGIN
    SELECT COALESCE(SUM(order_total), 0)
    INTO v_total_spent
    FROM orders
    WHERE customer_id = p_customer_id;
    
    CASE
        WHEN v_total_spent >= 100000 THEN
            p_tier := 'PLATINUM';
        WHEN v_total_spent >= 50000 THEN
            p_tier := 'GOLD';
        WHEN v_total_spent >= 10000 THEN
            p_tier := 'SILVER';
        ELSE
            p_tier := 'BRONZE';
    END CASE;
END;
$$;
```

### Loops

#### FOR Loop
```sql
CREATE PROCEDURE process_monthly_reports(
    p_months INTEGER
) AS $$
    v_month_counter INTEGER;
    v_start_date DATE;
BEGIN
    FOR v_month_counter IN RANGE 1..p_months LOOP
        v_start_date := ADD_MONTHS(TRUNC(SYSDATE(), 'MM'), -v_month_counter + 1);
        
        -- Process each month
        INSERT INTO monthly_summaries (
            summary_month,
            total_revenue,
            order_count
        )
        SELECT
            v_start_date,
            SUM(total_amount),
            COUNT(*)
        FROM orders
        WHERE order_date >= v_start_date
        AND order_date < ADD_MONTHS(v_start_date, 1);
        
        RAISE NOTICE 'Processed month: %', v_start_date;
    END LOOP;
END;
$$;
```

#### WHILE Loop
```sql
CREATE PROCEDURE batch_process_orders(
    p_batch_size INTEGER
) AS $$
    v_processed_count INTEGER := 0;
    v_total_count INTEGER;
    v_remaining_count INTEGER;
BEGIN
    -- Get total count
    SELECT COUNT(*) INTO v_total_count
    FROM orders
    WHERE processed_flag = FALSE;
    
    v_remaining_count := v_total_count;
    
    WHILE v_remaining_count > 0 LOOP
        -- Process batch
        UPDATE orders
        SET processed_flag = TRUE,
            processed_date = SYSDATE()
        WHERE order_id IN (
            SELECT order_id
            FROM orders
            WHERE processed_flag = FALSE
            LIMIT p_batch_size
        );
        
        PERFORM INSERT INTO summary_table (processed_date, record_count) VALUES (SYSDATE(), (SELECT COUNT(*) FROM processed_records WHERE processed_date = SYSDATE()));
        v_processed_count := (SELECT COUNT(*) FROM processed_records WHERE processed_date = SYSDATE());
        v_remaining_count := v_remaining_count - v_processed_count;
        
        RAISE NOTICE 'Processed % orders, % remaining', v_processed_count, v_remaining_count;
        
        -- Small delay to prevent overwhelming the system
        PERFORM select sleep(1);
    END LOOP;
END;
$$;
```

## Exception Handling

### RAISE Statement

The RAISE statement is used for error handling and messaging in PL/vSQL:

```sql
RAISE [ level ] 'format' [, arg_expression [, ... ]] [ USING option = expression [, ... ] ];
RAISE [ level ] condition_name [ USING option = expression [, ... ] ];
RAISE [ level ] SQLSTATE 'sql-state' [ USING option = expression [, ... ] ];
RAISE [ level ] USING option = expression [, ... ];
```

**RAISE Levels:**
- **LOG**: Sends message to `vertica.log`
- **INFO**: Prints INFO message in vsql
- **NOTICE**: Prints NOTICE in vsql (default for informational messages)
- **WARNING**: Prints WARNING in vsql
- **EXCEPTION**: Throws catchable exception (default)

```sql
-- Informational messages
RAISE NOTICE 'Processing % rows', row_count;
RAISE INFO 'Debug: value = %', variable_value;
RAISE WARNING 'Potential issue detected';

-- Error handling
RAISE EXCEPTION 'Invalid input parameter';
RAISE EXCEPTION 'Value % is out of range', input_value;
```

### ASSERT Statement

ASSERT is a debugging feature that checks whether a condition is true:

```sql
ASSERT condition [, message ];
```

```sql
-- Check that a table has data
ASSERT (SELECT COUNT(*) FROM products) > 0, 'products table is empty';

-- Validate input parameters
ASSERT p_amount > 0, 'Amount must be positive';
```

**Note**: ASSERT checking can be disabled by setting `PLpgSQLCheckAsserts = 0`.

### Special Variables for Error Handling

When handling exceptions, Vertica provides these built-in variables for basic error information:

- **SQLSTATE**: The SQL state code of the exception (e.g., `22012` for division by zero)
- **SQLERRM**: The primary error message text

For more detailed error information (detail, hint, context, column, constraint, table, schema), use `GET STACKED DIAGNOSTICS`.

```sql
CREATE PROCEDURE error_handling_example() AS $$
DECLARE
    v_error_code VARCHAR;
    v_error_message VARCHAR;
BEGIN
    -- Some operation that might fail
    PERFORM 1/0;  -- Division by zero
    
EXCEPTION
    WHEN OTHERS THEN
        -- Use special variables
        v_error_code := SQLSTATE;
        v_error_message := SQLERRM;
        
        RAISE WARNING 'Error %: %', v_error_code, v_error_message;
END;
$$;
```

### GET STACKED DIAGNOSTICS for Detailed Error Information

For comprehensive error information, use `GET STACKED DIAGNOSTICS`. The following diagnostic items are available:

| Item | Description |
|------|-------------|
| `RETURNED_SQLSTATE` | SQLSTATE error code of the exception |
| `MESSAGE_TEXT` | Text of the exception's primary message |
| `DETAIL_TEXT` | Text of the exception's detail message, if any |
| `HINT_TEXT` | Text of the exception's hint message, if any |
| `EXCEPTION_CONTEXT` | Description of the call stack at the time of the exception |
| `COLUMN_NAME` | Name of the column related to the exception |
| `CONSTRAINT_NAME` | Name of the constraint related to the exception |
| `DATATYPE_NAME` | Name of the data type related to the exception |
| `TABLE_NAME` | Name of the table related to the exception |
| `SCHEMA_NAME` | Name of the schema related to the exception |

> **Note**: `GET STACKED DIAGNOSTICS` must be called from inside an EXCEPTION block.

```sql
CREATE PROCEDURE detailed_error_example() AS $$
DECLARE
    v_sqlstate VARCHAR;
    v_message VARCHAR;
    v_detail VARCHAR;
    v_hint VARCHAR;
    v_context VARCHAR;
    v_table VARCHAR;
    v_schema VARCHAR;
    v_column VARCHAR;
    v_constraint VARCHAR;
    v_datatype VARCHAR;
BEGIN
    -- Operation that might fail
    PERFORM DELETE FROM nonexistent_table;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_sqlstate = RETURNED_SQLSTATE,
            v_message = MESSAGE_TEXT,
            v_detail = DETAIL_TEXT,
            v_hint = HINT_TEXT,
            v_context = EXCEPTION_CONTEXT,
            v_table = TABLE_NAME,
            v_schema = SCHEMA_NAME,
            v_column = COLUMN_NAME,
            v_constraint = CONSTRAINT_NAME,
            v_datatype = DATATYPE_NAME;

        RAISE WARNING 'Error: %, Detail: %, Hint: %, Context: %',
            v_message, v_detail, v_hint, v_context;
        RAISE WARNING 'Location: schema=%, table=%, column=%, constraint=%, type=%',
            v_schema, v_table, v_column, v_constraint, v_datatype;
END;
$$;
```

## Transaction Semantics

Understanding transaction behavior in Vertica stored procedures is crucial for proper data management.

### Automatic Transaction Handling

Vertica handles transactions automatically for stored procedures:

- **Top-level procedures**: Automatically commit on success, rollback on failure
- **Nested procedures**: Do not start their own transactions (inherit parent transaction)
- **Before execution**: Any ongoing transaction is committed before the procedure starts
- **Depth limit rollback**: If nested procedures exceed the 50-level depth limit, the entire operation is rolled back

### Manual COMMIT Usage

You can manually commit changes within a stored procedure:

- **Allowed**: COMMIT statements are permitted in stored procedures
- **Persistence**: Manually committed changes persist even if the procedure later fails
- **Use case**: Useful for partial commits when you want some changes to persist despite later failures
- **Best practice**: Prefer automatic transaction handling; use manual COMMIT sparingly

### Nested Procedure Transactions

When a stored procedure calls another stored procedure:

- The top-level procedure manages the transaction
- Nested procedures do not start their own transactions
- All procedures in the call chain share the same transaction context

```sql
CREATE PROCEDURE top_level_proc() AS $$
DECLARE
    v_result INTEGER;
BEGIN
    PERFORM INSERT INTO log_table VALUES ('Top level started', SYSDATE());
    -- Call another procedure (nested call)
    v_result := (SELECT some_function());  -- Function call example
    PERFORM INSERT INTO log_table VALUES ('Top level completed', SYSDATE());
    -- Entire transaction commits or rolls back together
END;
$$;

-- Note: Direct procedure calls from within procedures use CALL statement
-- when called from external context, but internal calls may use different syntax
```

### Key Transaction Rules

1. **Automatic commits**: Top-level procedures auto-commit on success, auto-rollback on failure
2. **Nested procedures**: Do not start their own transactions
3. **Manual commits**: COMMIT statements persist changes even if procedure later fails
4. **No explicit ROLLBACK**: Use exception handling instead of ROLLBACK statements
5. **Handled exceptions**: Result in automatic commit of successful operations
6. **Unhandled errors**: Cause automatic rollback of the entire procedure's transaction
7. **Depth limits**: Exceeding 50 nested levels causes complete rollback

### Transaction Behavior Examples

```sql
-- Example 1: Automatic commit on success
CREATE PROCEDURE auto_commit_example() AS $$
BEGIN
    PERFORM INSERT INTO audit_log VALUES ('Processing started', SYSDATE());
    PERFORM UPDATE customers SET last_updated = SYSDATE();
    -- If this procedure completes successfully, changes are auto-committed
END;
$$;

-- Example 2: Manual commit for partial persistence
CREATE PROCEDURE manual_commit_example() AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    PERFORM INSERT INTO stage_table VALUES (1, 'initial_data');
    PERFORM COMMIT;  -- This data persists even if procedure later fails
    
    PERFORM INSERT INTO stage_table VALUES (2, 'more_data');
    -- If an error occurs here, only this insert is rolled back
    -- The first insert (id=1) remains committed
    
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Error occurred, but first insert persists: %', v_error_msg;
END;
$$;

-- Example 3: Exception handling affects transaction outcome
CREATE PROCEDURE exception_behavior_example() AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    PERFORM INSERT INTO test_table VALUES (1, 'test');
    
    -- Unhandled error → automatic rollback of entire procedure
    PERFORM INSERT INTO nonexistent_table VALUES (1);
    
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Error handled: %', v_error_msg;
        -- Handled exception → automatic commit of successful operations
END;
$$;
```

## Nested Stored Procedures

Vertica supports calling stored procedures from within other stored procedures, known as nested stored procedures. This powerful feature enables modular design and code reuse.

### Overview

**Nested stored procedures** allow you to call one stored procedure from within another, creating a hierarchy of procedure calls:

- **Top-level procedure**: Called directly by a user (with CALL or DO) or trigger
- **Nested procedure**: Called from within another stored procedure
- **Call depth**: Maximum nesting level is 50

### Configuration Requirements

Nested stored procedures must be explicitly enabled at the database level (`EnableNestedStoredProcedures = 1`). See [Transaction Semantics](#transaction-semantics) for transaction behavior details.

### Basic Nested Procedure Example

```sql
-- Create a child procedure
CREATE OR REPLACE PROCEDURE child_proc(IN p_value INTEGER)
LANGUAGE PLvSQL AS $$
BEGIN
    PERFORM INSERT INTO audit_log (message, created_at)
    VALUES ('Child processing: ' || p_value, CURRENT_TIMESTAMP);
    
    RAISE NOTICE 'Child procedure executed with value: %', p_value;
END;
$$;

-- Create a parent procedure that calls the child
CREATE OR REPLACE PROCEDURE parent_proc(IN p_base_value INTEGER)
LANGUAGE PLvSQL AS $$
BEGIN
    -- Parent procedure logic
    PERFORM INSERT INTO audit_log (message, created_at)
    VALUES ('Parent started with: ' || p_base_value, CURRENT_TIMESTAMP);
    
    RAISE NOTICE 'Parent: Calling child procedure';
    
    -- Call the nested procedure
    PERFORM CALL child_proc(p_base_value * 10);
    
    RAISE NOTICE 'Parent: Child procedure completed';
    
    -- More parent logic
    PERFORM INSERT INTO audit_log (message, created_at)
    VALUES ('Parent finished', CURRENT_TIMESTAMP);
END;
$$;

-- Execute the parent procedure
CALL parent_proc(42);
```

### Multi-level Nesting

```sql
-- Level 1 procedure
CREATE OR REPLACE PROCEDURE level1_proc(IN p_value INTEGER)
LANGUAGE PLvSQL AS $$
BEGIN
    RAISE NOTICE '=== LEVEL 1 START (value: %) ===', p_value;
    PERFORM CALL level2_proc(p_value * 10);
    RAISE NOTICE '=== LEVEL 1 END ===';
END;
$$;

-- Level 2 procedure
CREATE OR REPLACE PROCEDURE level2_proc(IN p_value INTEGER)
LANGUAGE PLvSQL AS $$
BEGIN
    RAISE NOTICE '  LEVEL 2 START (value: %)', p_value;
    PERFORM CALL level3_proc(p_value * 10);
    RAISE NOTICE '  LEVEL 2 END';
END;
$$;

-- Level 3 procedure
CREATE OR REPLACE PROCEDURE level3_proc(IN p_value INTEGER)
LANGUAGE PLvSQL AS $$
BEGIN
    RAISE NOTICE '    LEVEL 3 PROCESSING (value: %)', p_value;
    -- Perform complex business logic here
END;
$$;

-- Execute the chain
CALL level1_proc(5);  -- Results in: 5 → 50 → 500
```

### Error Handling in Nested Procedures

```sql
CREATE OR REPLACE PROCEDURE safe_parent_proc() AS $$
DECLARE
    v_error_msg VARCHAR;
    v_error_code VARCHAR;
BEGIN
    PERFORM INSERT INTO transaction_log VALUES ('Parent start');
    
    BEGIN
        -- Call nested procedure that might fail
        PERFORM CALL risky_child_proc();
        
        PERFORM INSERT INTO transaction_log VALUES ('Both procedures succeeded');
        
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS 
                v_error_code = RETURNED_SQLSTATE,
                v_error_msg = MESSAGE_TEXT;
            
            RAISE NOTICE 'Nested procedure failed: % (%)', v_error_msg, v_error_code;
            PERFORM INSERT INTO error_log VALUES (v_error_msg, v_error_code, CURRENT_TIMESTAMP);
    END;
    
    RAISE NOTICE 'Parent procedure completed';
END;
$$;

CREATE OR REPLACE PROCEDURE risky_child_proc() AS $$
BEGIN
    PERFORM INSERT INTO transaction_log VALUES ('Child start');
    
    -- Simulate a business rule validation
    IF 1 = 1 THEN  -- Replace with actual business logic
        RAISE EXCEPTION 'Business rule violation: Invalid operation';
    END IF;
    
    PERFORM INSERT INTO transaction_log VALUES ('Child success');
END;
$$;
```

### Parameter Passing in Nested Calls

```sql
-- Parent procedure with multiple parameter modes
CREATE OR REPLACE PROCEDURE complex_parent(
    IN p_input_val INTEGER,
    INOUT p_inout_val VARCHAR(100),
    OUT p_output_val INTEGER
) AS $$
DECLARE
    v_local_val INTEGER := 100;
BEGIN
    -- Modify INOUT parameter
    p_inout_val := 'Processed: ' || p_inout_val;
    
    -- Call child with different parameter combinations
    PERFORM CALL child_with_params(
        p_input_val,      -- Pass IN parameter
        v_local_val,      -- Pass local variable
        p_output_val      -- Pass OUT parameter
    );
    
    RAISE NOTICE 'Child returned: %', p_output_val;
END;
$$;

CREATE OR REPLACE PROCEDURE child_with_params(
    IN p_param1 INTEGER,
    IN p_param2 INTEGER,
    OUT p_result INTEGER
) AS $$
BEGIN
    p_result := p_param1 + p_param2;
END;
$$;
```

### Best Practices for Nested Procedures

#### 1. Design Principles
- **Modularity**: Break complex logic into smaller, focused procedures
- **Single Responsibility**: Each procedure should have one clear purpose
- **Reusability**: Design procedures to be reusable across different contexts
- **Depth Management**: Avoid excessive nesting (recommended max: 5-7 levels)

#### 2. Error Handling
- **Consistent Strategy**: Use uniform error handling across all procedures
- **Meaningful Messages**: Provide clear, actionable error messages
- **Error Propagation**: Decide whether to handle errors locally or propagate them
- **Logging**: Log errors at appropriate levels for debugging

#### 3. Performance Considerations
- **Minimize Nesting**: Each level adds overhead
- **Batch Operations**: Reduce the number of procedure calls for bulk operations
- **Parameter Efficiency**: Use appropriate parameter types and avoid unnecessary data copying
- **Transaction Scope**: Keep transactions as short as possible

#### 4. Security
- **Privilege Management**: Ensure callers have EXECUTE permission on all nested procedures
- **SECURITY Mode**: Choose between DEFINER and INVOKER based on requirements
- **Input Validation**: Validate parameters at each level when necessary

### Common Use Cases

#### 1. Modular Business Logic
```sql
CREATE PROCEDURE process_customer_order(IN p_order_id INTEGER) AS $$
BEGIN
    PERFORM CALL validate_order(p_order_id);
    PERFORM CALL check_inventory(p_order_id);
    PERFORM CALL calculate_totals(p_order_id);
    PERFORM CALL update_inventory(p_order_id);
    PERFORM CALL generate_invoice(p_order_id);
    PERFORM CALL send_confirmation(p_order_id);
END;
$$;
```

#### 2. Data Processing Pipelines
```sql
CREATE PROCEDURE etl_pipeline(IN p_source_table VARCHAR, IN p_target_table VARCHAR) AS $$
BEGIN
    PERFORM CALL extract_data(p_source_table);
    PERFORM CALL transform_data();
    PERFORM CALL validate_data();
    PERFORM CALL load_data(p_target_table);
    PERFORM CALL create_statistics(p_target_table);
END;
$$;
```

#### 3. Error Recovery and Retry Logic
```sql
CREATE PROCEDURE resilient_operation() AS $$
DECLARE
    v_attempts INTEGER := 0;
    v_max_attempts INTEGER := 3;
BEGIN
    WHILE v_attempts < v_max_attempts LOOP
        BEGIN
            v_attempts := v_attempts + 1;
            PERFORM CALL critical_operation();
            EXIT;  -- Success, exit loop
        EXCEPTION
            WHEN OTHERS THEN
                IF v_attempts = v_max_attempts THEN
                    RAISE;  -- Re-throw on final attempt
                END IF;
                PERFORM select sleep(1);  -- Wait before retry
        END;
    END LOOP;
END;
$$;
```

### Limitations and Considerations

1. **Configuration Dependency**: Requires explicit database configuration
2. **Call Depth Limit**: Maximum 50 levels of nesting
3. **Debugging Complexity**: Stack traces can be complex with deep nesting
4. **Performance Overhead**: Each call level adds execution overhead
5. **Transaction Management**: All levels share the same transaction context
6. **Privilege Requirements**: Callers need permissions on all nested procedures

### Troubleshooting

#### Common Issues
- **Permission Denied**: Ensure EXECUTE permission on all procedures in the call chain
- **Configuration Not Enabled**: Verify `EnableNestedStoredProcedures = 1`
- **Call Depth Exceeded**: Reduce nesting levels or refactor logic
- **Transaction Conflicts**: Review transaction boundaries and COMMIT usage

#### Diagnostic Queries
```sql
-- Check nested stored procedure configuration
SELECT * FROM v_catalog.configuration_parameters 
WHERE parameter_name = 'EnableNestedStoredProcedures';

-- Monitor procedure execution
SELECT * FROM v_monitor.procedure_calls 
ORDER BY start_timestamp DESC;
```

Nested stored procedures are a powerful feature that enables building complex, modular, and maintainable database applications in Vertica. When used appropriately, they can significantly improve code organization and reusability while maintaining data consistency through unified transaction management.

## DO Blocks (Anonymous Procedures)

A DO block is an anonymous code block that executes PL/vSQL code without creating a named stored procedure. **Except for not being able to accept parameters or return values like stored procedures, DO blocks are identical to stored procedures** in terms of syntax, capabilities, and the commands they support.

### Key Characteristics

- **No parameters**: DO blocks cannot accept IN, OUT, or INOUT parameters
- **No return values**: DO blocks cannot return values to the caller
- **Same syntax**: Uses the same `DECLARE`, `BEGIN`, `EXCEPTION`, `END` structure
- **Same commands**: Supports `PERFORM`, `RAISE`, variable assignment, loops, conditionals, etc.
- **One-time execution**: Executed immediately and not stored in the database
- **External context only**: Cannot be used inside a stored procedure (use nested `BEGIN...END` blocks instead)

### Syntax

```sql
DO $$
[DECLARE
    variable_declarations;]
BEGIN
    executable_statements;
[EXCEPTION
    exception_handlers;]
END;
$$;
```

### Simple Example

```sql
DO $$
DECLARE
    v_count INTEGER;
    v_name VARCHAR(100);
BEGIN
    -- Query data
    SELECT COUNT(*) INTO v_count FROM employees;
    RAISE NOTICE 'Total employees: %', v_count;

    -- Perform DML operations
    PERFORM INSERT INTO audit_log (message, created_at)
    VALUES ('Employee count checked', SYSDATE());

    -- Conditional logic
    IF v_count > 100 THEN
        RAISE NOTICE 'Large organization detected';
    END IF;
END;
$$;
```

### Use Cases

1. **Testing and debugging**: Quickly test PL/vSQL logic without creating a permanent procedure
2. **One-time data fixes**: Execute ad-hoc data corrections or maintenance tasks
3. **Administrative scripts**: Run batch operations without persisting procedure definitions
4. **Prototyping**: Validate logic before encapsulating it in a named stored procedure
5. **Migration validation**: Test migrated code from other databases before wrapping it in a procedure

### DO Block with Exception Handling

```sql
DO $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    -- Attempt an operation that might fail
    PERFORM INSERT INTO nonexistent_table VALUES (1);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Caught error: %', v_error_msg;
END;
$$;
```

### DO Block with Loops and Dynamic SQL

```sql
DO $$
DECLARE
    table_name VARCHAR(100);
    row_count INTEGER;
BEGIN
    FOR table_name IN QUERY SELECT table_name FROM tables WHERE table_schema = 'public' LOOP
        row_count := EXECUTE 'SELECT COUNT(*) FROM ' || table_name;
        RAISE NOTICE 'Table % has % rows', table_name, row_count;
    END LOOP;
END;
$$;
```

### Comparison: Stored Procedure vs DO Block

All capabilities are identical except:

| Feature | Stored Procedure | DO Block |
|---------|-----------------|----------|
| Named / Persistent | ✅ Yes | ❌ No (anonymous) |
| Parameters (IN/OUT/INOUT) | ✅ Yes | ❌ No |
| Callable by applications / other procedures | ✅ Yes | ❌ No |

## Best Practices

### 1. Performance Optimization

Vertica is optimized for **set-based, bulk analytical operations** — not for row-by-row OLTP patterns. When writing stored procedures, always prefer set-based SQL over procedural loops. The [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) covers the most impactful rewrite patterns:

| Pattern | Anti-Pattern | Replacement |
|---------|-------------|-------------|
| **Adjacent DML merging** | Multiple single-row INSERT/UPDATE statements | Single bulk INSERT...VALUES or UPDATE...CASE |
| **Loop DML → set-based SQL** | INSERT/UPDATE/DELETE inside FOR loops | INSERT...SELECT, DELETE...WHERE IN, MERGE INTO |
| **Cursor → window functions** | Row-by-row cursor with shared variables | SUM() OVER, LAG() OVER, ROW_NUMBER() OVER |
| **Per-row function call → JOIN** | Scalar function called N times in SELECT | JOIN to lookup/derived table |
| **Per-row COMMIT** | COMMIT inside a loop | Single implicit commit or batch-boundary COMMIT |

See the [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for complete before/after examples and a migration checklist.

This comprehensive guide provides everything needed to develop robust, efficient stored procedures in Vertica for various use cases beyond simple migration scenarios.
