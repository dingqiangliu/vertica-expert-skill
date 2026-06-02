# SQL Server to Vertica Migration Guide

This guide provides comprehensive guidance for migrating SQL Server databases to Vertica, including T-SQL syntax conversion, stored procedure migration, and performance optimization strategies.

## 🚨 CRITICAL: MANDATORY COMPLIANCE REQUIREMENTS

**BEFORE STARTING ANY SQL SERVER MIGRATION, YOU MUST READ AND FOLLOW THE [GENERIC MIGRATION GUIDE](generic-migration-guide.md)**

This SQL Server migration guide **MUST BE USED IN CONJUNCTION WITH** the [Generic Migration Guide](generic-migration-guide.md). The generic guide contains **MANDATORY PROCEDURES** that apply to ALL database migrations, including:

- ✅ **COMPLETE migration** of ALL objects (no selective migration allowed)
- ✅ **SEQUENTIAL processing** in exact source file order (no reordering)
- ✅ **ONE-TO-ONE conversion** (tables→tables, procedures→procedures, etc.)
- ✅ **INDIVIDUAL testing** of every object before considering it migrated
- ✅ **NO automated scripts** or bulk processing
- ✅ **PRESERVATION** of all sequences, and dependencies

**FAILURE TO FOLLOW THE GENERIC MIGRATION GUIDE WILL RESULT IN FAILED MIGRATIONS.**

## Database and Schema Mapping

Vertica does **not** have the concept of multiple databases like SQL Server. A single Vertica database contains multiple schemas. When migrating from SQL Server:

- Map each **SQL Server database** to a **Vertica schema**
- Remove the default `dbo` schema prefix from object names
- Use `SET SEARCH_PATH` to control schema resolution order

> ⚠️ **CRITICAL — CREATE SCHEMA AND SET SEARCH_PATH MUST BE DONE TOGETHER**: For every SQL Server database being migrated, you **MUST** perform **both** of the following actions **together** — never omit either one:
> 1. `CREATE SCHEMA IF NOT EXISTS <dbname>;` — creates the schema in Vertica
> 2. `SET SEARCH_PATH = <dbname>, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;` — sets the search path so objects in that schema can be resolved without full qualification
>
> **RATIONALE**: These two operations are **inseparable and equally mandatory**. Creating the schema without setting `SEARCH_PATH` means objects inside it cannot be found by unqualified name, causing "object not found" errors. Setting `SEARCH_PATH` without creating the schema means the schema does not exist, causing "schema does not exist" errors. **Always pair them — never do one without the other.**

```sql
-- SQL Server: switch to a database
USE [CRM]
GO

-- Vertica: create the equivalent schema and set search path
CREATE SCHEMA IF NOT EXISTS CRM;
SET SEARCH_PATH = CRM, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;

-- SQL Server: reference objects with database and schema qualifiers
SELECT * FROM [CRM].[dbo].[customers];
SELECT * FROM [CRM].[sales].[orders];

-- Vertica: reference objects with schema qualifiers (no database, no dbo)
SELECT * FROM CRM.customers;
SELECT * FROM CRM.orders;  -- sales schema merged into CRM

-- SQL Server: cross-database query
SELECT * FROM [CRM].[dbo].[customers] c
JOIN [ERP].[dbo].[invoices] i ON c.customer_id = i.customer_id;

-- Vertica: cross-schema query (within the same database)
SELECT * FROM CRM.customers c
JOIN ERP.invoices i ON c.customer_id = i.customer_id;
```

**Key differences**:

| Aspect | SQL Server | Vertica |
|--------|-----------|---------|
| Database | Multiple databases per instance | Single database per instance |
| Default schema | `dbo` | `"$user"` (user's personal schema), or `public` schema by default |
| Object reference | `[database].[schema].[table]` | `[schema].[table]` |
| Cross-database query | Supported (3-part name) | N/A — use cross-schema queries instead |
| Schema switching | `USE [database]` | `SET SEARCH_PATH TO schema, ...` |

### 🚨 USE Statement Tracking — Schema Prefix Rule

**This is the #1 cause of missing schema prefixes in migrated CREATE statements. Read carefully.**

When migrating a SQL Server script that contains `USE [database]` statements, you **MUST** track the current database context and apply it as the schema prefix to **every subsequently created object** (tables, views, procedures, functions, etc.) until the next `USE` statement switches context.

**Rules:**
- When `USE [dbname]` is encountered → all following `CREATE` objects must be prefixed as `dbname.object_name`
- If **no** `USE` statement exists in the script → **remove the `dbo` schema prefix entirely** (e.g., `dbo.customers` → just `customers`). Do NOT preserve `dbo` as the schema name.
- Replace `USE [dbname]` with `CREATE SCHEMA IF NOT EXISTS dbname;` followed by `SET SEARCH_PATH = dbname, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;` — both are required together
- The `dbo` schema has no special meaning in Vertica — **always flatten/remove it**

**Before (SQL Server):**
```sql
USE [CRM]
GO
CREATE TABLE customers (        -- belongs to CRM database
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
GO
CREATE VIEW active_customers AS  -- belongs to CRM database
    SELECT * FROM customers WHERE active = 1;
GO

USE [ERP]
GO
CREATE TABLE invoices (         -- belongs to ERP database
    id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2)
);
GO

USE [CRM]
GO
CREATE VIEW v_customer_orders AS  -- belongs to CRM database again
    SELECT * FROM ERP.invoices;
GO
```

**After (Vertica):**
```sql
CREATE SCHEMA IF NOT EXISTS CRM;
SET SEARCH_PATH = CRM, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;
CREATE TABLE CRM.customers (    -- CRM schema prefix from USE [CRM]
    id INTEGER PRIMARY KEY,
    name VARCHAR(100)
);
CREATE VIEW CRM.active_customers AS  -- CRM schema prefix from USE [CRM]
    SELECT * FROM CRM.customers WHERE active = 1;

CREATE SCHEMA IF NOT EXISTS ERP;
SET SEARCH_PATH = ERP, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;
CREATE TABLE ERP.invoices (     -- ERP schema prefix from USE [ERP]
    id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    amount NUMERIC(10,2)
);

CREATE SCHEMA IF NOT EXISTS CRM;
SET SEARCH_PATH = CRM, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;
CREATE VIEW CRM.v_customer_orders AS  -- CRM schema prefix from USE [CRM]
    SELECT * FROM ERP.invoices;
```

> 🚨 **COMMON MISTAKE**: Generating `CREATE TABLE customers (...)` without the `CRM.` prefix. **Every CREATE statement MUST include the schema prefix derived from the most recent `USE [dbname]` statement.**

**Migration notes**:
- **Preserve database names as schema names** — always map each SQL Server database to a Vertica schema with the **exact same name**. Never rename, merge, or drop database names during migration.
- If multiple SQL Server databases need to coexist, create separate schemas in Vertica (one per source database)
- Cross-database queries in SQL Server become cross-schema queries in Vertica (same database, simpler syntax)

## Data Type Mappings

### Numeric Types

| SQL Server Type | Vertica Type | Notes |
|-----------------|--------------|-------|
| TINYINT | TINYINT | `INT`, `INTEGER`, `INT8`, `SMALLINT`, `TINYINT`, and `BIGINT` are all synonyms for the same signed 64-bit integer data type in Vertica |
| SMALLINT | SMALLINT | **8 bytes** in Vertica (2-byte integer in SQL Server) |
| INT | INTEGER | **8 bytes** in Vertica (4-byte integer in SQL Server) |
| BIGINT | BIGINT | 8-byte integer |
| DECIMAL(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| FLOAT | DOUBLE PRECISION | 8-byte floating point |
| REAL | REAL | 4-byte floating point |

### Character Types

| SQL Server Type | Vertica Type | Notes |
|-----------------|--------------|-------|
| CHAR(n) | CHAR(n) | Fixed-length character |
| VARCHAR(n) | VARCHAR(n) | Variable-length character |
| VARCHAR(MAX) | LONG VARCHAR | Large text data |
| TEXT | LONG VARCHAR | Deprecated, use LONG VARCHAR |
| NCHAR(n) | CHAR(n) | Unicode, use CHAR in Vertica |
| NVARCHAR(n) | VARCHAR(n) | Unicode, use VARCHAR in Vertica |

### Date/Time Types

| SQL Server Type | Vertica Type | Notes |
|-----------------|--------------|-------|
| DATE | DATE | Date only |
| TIME | TIME | Time only |
| DATETIME | TIMESTAMP | Date and time |
| DATETIME2 | TIMESTAMP | High precision timestamp |
| SMALLDATETIME | TIMESTAMP | Lower precision timestamp |

### Binary Types

| SQL Server Type | Vertica Type | Notes |
|-----------------|--------------|-------|
| BINARY(n) | BINARY(n) | Fixed-length binary |
| VARBINARY(n) | VARBINARY(n) | Variable-length binary |
| VARBINARY(MAX) | LONG VARBINARY | Large binary data |
| IMAGE | LONG VARBINARY | Deprecated, use LONG VARBINARY |

## SQL Syntax Conversion

### Identity Columns and Auto-increment

```sql
-- SQL Server
CREATE TABLE employees (
    emp_id INT IDENTITY(1,1) PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (IDENTITY, equivalent to AUTO_INCREMENT)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100)
);
```

### Basic SELECT Statement Differences

```sql
-- SQL Server
SELECT TOP 10 * FROM employees e, departments d 
WHERE e.dept_id = d.dept_id;

-- Vertica (LIMIT clause)
SELECT * FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
LIMIT 10;
```
### Common Functions

| SQL Server Function | Vertica Equivalent | Notes |
|---------------------|-------------------|-------|
| GETDATE() | GETDATE(), or NOW() , SYSDATE() | Current date/time |
| DATEADD(unit, n, date) | date + INTERVAL 'n' unit | Date arithmetic |
| DATEDIFF(unit, start, end) | EXTRACT(unit FROM end - start) | Date difference |
| ISNULL(value, replacement) | ISNULL(value, replacement), or COALESCE(value, replacement) | NULL handling |
| LEN(string) | LENGTH(string) | String length |
| SUBSTRING(string, start, length) | SUBSTRING(string, start, length), or SUBSTRING(string FROM start FOR length) | Substring extraction |
| CHARINDEX(substr, string) | INSTR(string, substr), or POSITION(substr IN string) | Find substring |
| UPPER(string) | UPPER(string) | Convert to uppercase |
| LOWER(string) | LOWER(string) | Convert to lowercase |
| REPLACE(string, old, new) | REPLACE(string, old, new) | String replacement |
| CONVERT(type, value) | CAST(value AS type) | Type conversion |

### String Concatenation

```sql
-- SQL Server (multiple options)
SELECT first_name + ' ' + last_name as full_name FROM employees;
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;

-- Vertica (use || operator or CONCAT)
SELECT first_name || ' ' || last_name as full_name FROM employees;
SELECT CONCAT(first_name, CONCAT(' ', last_name)) as full_name FROM employees;
```

### Date Functions

```sql
-- SQL Server
SELECT DATEADD(month, 6, hire_date)
FROM employees;

-- Vertica
SELECT GETDATE(), ADD_MONTHS(hire_date, 6)
FROM employees;
```

### NULL Handling

```sql
-- SQL Server
SELECT ISNULL(middle_name, 'N/A') FROM employees;

-- Vertica (both ISNULL and COALESCE are supported; COALESCE is ANSI standard and preferred)
SELECT ISNULL(middle_name, 'N/A') FROM employees;
SELECT COALESCE(middle_name, 'N/A') FROM employees;
```

## Stored Procedure Migration

### Variable Declaration Type Restrictions

Vertica PL/vSQL has the following restrictions on variable data types that differ from T-SQL:

| Restriction | T-SQL | Vertica Workaround |
|-------------|-------|--------------------|
| `DECIMAL(p,s)` / `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` or `DECIMAL` without precision. Default is precision 37, scale 15. |
| `MONEY` / `SMALLMONEY` types | ✅ Supported | `MONEY` is supported as a variable type (without parameters). `SMALLMONEY` is not supported — use `NUMERIC` instead. |
| `UNIQUEIDENTIFIER` (UUID) | ✅ Supported | `UUID` is supported as a variable type (without parameters). |
| `SQL_VARIANT` type | ✅ Supported | Not supported. Use `VARCHAR` or declare separate typed variables. |
| `TABLE` type (table variables) | ✅ Supported | Not supported. Use temporary tables instead. |
| `GEOGRAPHY` / `GEOMETRY` types | ✅ Supported | Not supported. Store as `VARCHAR` or `LONG VARBINARY`, or use multiple scalar variables. |
| `XML` type | ✅ Supported | Not supported. Use `LONG VARCHAR` or `LONG VARBINARY` instead. |
| `CURSOR` type (variable) | ✅ Supported | Use `refcursor` or `CURSOR FOR` in DECLARE block. |
| `TIMESTAMP` / `ROWVERSION` | ✅ Supported | `TIMESTAMP` maps to Vertica `TIMESTAMP`. `ROWVERSION` is not supported — use `INTEGER` or `BIGINT` with a sequence. |


### Critical Parameter Handling Rules

⚠️ **MOST IMPORTANT**: Never remove OUT/INOUT parameter keywords when migrating from SQL Server!

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: Unlike SQL Server, where `OUTPUT` parameters modify variables by reference, Vertica's `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. Use `var1, var2 := CALL proc(...)` to unpack the tuple. The original input variables remain unchanged.

**How it works in Vertica**:
- `CALL procedure_name(...)` returns a **single tuple (record)** containing all OUT/INOUT values
- Each column in the tuple is named after the corresponding OUT/INOUT parameter
- Use `var1, var2 := CALL proc(...)` to unpack the tuple's columns into variables by position
- The original variables passed to the procedure remain unchanged

**Migration Implication**: When converting T-SQL that relies on OUTPUT parameters to modify calling variables, use tuple unpacking assignment (`var1, var2 := CALL proc(...)`) instead.

#### Parameter Mode Conversion Table

**Key Syntax Difference**: In SQL Server, `OUTPUT` comes **after** the parameter name. In Vertica, `OUT` comes **before** the parameter name.

| SQL Server Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|-------------------|---------------------|-------------------|-------|
| `@param INT` | `p_param INTEGER` | `p_param INTEGER` | IN is optional (default) |
| `@param INT OUTPUT` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT before name** |
| `@param INT OUTPUT` (read/write) | `p_param INTEGER` | `INOUT p_param INTEGER` | **Must keep INOUT before name** |

#### Migration Checklist for Parameters
- [ ] ✅ Preserve all OUT parameter keywords
- [ ] ✅ Preserve all INOUT parameter keywords
- [ ] ✅ IN keywords are optional (can be omitted)
- [ ] ✅ Test parameter passing with various data types
- [ ] ✅ Verify return value handling
- [ ] ✅ Understand that OUT/INOUT parameters don't modify original variables

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: SQL Server supports default parameter values (e.g., `@param INT = NULL`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% SQL Server compatibility.

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**
> Procedure overloading in Vertica works by matching the **procedure name** plus the parameter signature (number, types, order). Every overloaded variant **must** share the identical procedure name — only the parameter list differs.

```sql
-- SQL Server Original with Default Parameters
CREATE PROCEDURE process_order
    @order_id INT,
    @discount FLOAT = 0.1,
    @priority VARCHAR(20) = 'NORMAL',
    @notes VARCHAR(500) = NULL
AS
BEGIN
    -- Business logic
    PRINT 'Processing order ' + CAST(@order_id AS VARCHAR);
END;

-- Vertica Migration: Perfect SQL Server Compatibility
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
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, 0.1, 'NORMAL', NULL);
END;
$$;

CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount FLOAT
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, p_discount, 'NORMAL', NULL);
END;
$$;

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

#### 100% SQL Server-Compatible Calling Patterns

```sql
-- All SQL Server calling styles work perfectly without modification
CALL process_order(1001);                              -- All defaults
CALL process_order(1001, 0.15);                       -- Partial
CALL process_order(1001, 0.15, 'HIGH');              -- Partial
CALL process_order(1001, 0.15, 'HIGH', 'Urgent');    -- All explicit
```

### Basic Procedure Structure

```sql
-- SQL Server
CREATE PROCEDURE GetEmployeeCount
    @dept_id INT,
    @count INT OUTPUT
AS
BEGIN
    SELECT @count = COUNT(*)
    FROM employees
    WHERE department_id = @dept_id;
END;

-- Vertica PL/vSQL
CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id INTEGER,
    OUT p_count INTEGER  -- Note: OUT keyword comes BEFORE parameter name
) AS $$
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;
```

> **Note**: Unlike SQL Server's `OUTPUT` parameters which modify variables by reference, Vertica's `CALL` returns a **single tuple (record)**. Use `var1, var2 := CALL proc(...)` to unpack the tuple's columns into variables by position.

### PERFORM Command Usage in PL/vSQL

In PL/vSQL, the PERFORM command is used to **discard the output** produced by SQL statements. In Vertica, every SQL statement that can execute outside a stored procedure produces a response:

- **DML** (INSERT, UPDATE, DELETE, MERGE) → outputs the number of rows affected
- **SELECT** and **CALL** → outputs `Tuples` or `Tuple`
- **DDL** (CREATE, ALTER, DROP, etc.), **COMMIT**, **ROLLBACK**, and other statements → outputs success/failure messages
- **EXECUTE** (dynamic SQL inside stored procedures) → can execute any of the above dynamic statements, producing the corresponding output (row counts, `Tuples`/`Tuple`, or status messages)

If the output is not captured via `var := SQL_STATEMENT`, `var <- SQL_STATEMENT`, `SELECT ... INTO ...`, or `EXECUTE ... INTO ...`, then `PERFORM` must be prepended to discard it.

**SQL Server**: DDL and DML statements can be used directly in T-SQL stored procedures.
**Vertica**: Must use `PERFORM` to discard output from DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE and other SQL statements.

```sql
-- ❌ SQL Server style (won't work in Vertica)
INSERT INTO audit_log VALUES ('Processing started');

-- ✅ Vertica style
PERFORM INSERT INTO audit_log VALUES ('Processing started');
```

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

**SQL Server**: Use `@@ROWCOUNT` to get affected rows after DML.
**Vertica**: INSERT, UPDATE, DELETE return the number of rows affected directly. You can capture this directly without `GET DIAGNOSTICS`:

```sql
-- Vertica: Capture affected row count directly from DML
DECLARE
    v_count INTEGER;
BEGIN
    v_count := UPDATE customers SET status = 'active';
    RAISE NOTICE 'Updated % rows', v_count;
END;
```

In SQL Server, you would check `@@ROWCOUNT` after DML. In Vertica, simply assign the DML result directly.

### Cursor Handling

```sql
-- SQL Server cursor
DECLARE emp_cursor CURSOR FOR
    SELECT employee_id, salary FROM employees WHERE department_id = 10;
DECLARE @emp_id INT, @salary DECIMAL(10,2);
OPEN emp_cursor;
FETCH NEXT FROM emp_cursor INTO @emp_id, @salary;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Process record
    PRINT CAST(@emp_id AS VARCHAR) + ': ' + CAST(@salary AS VARCHAR);
    FETCH NEXT FROM emp_cursor INTO @emp_id, @salary;
END;
CLOSE emp_cursor;
DEALLOCATE emp_cursor;

-- Vertica cursor (similar syntax)
CREATE OR REPLACE PROCEDURE process_employees()
AS $$
DECLARE
    emp_cursor CURSOR FOR
        SELECT employee_id, salary
        FROM employees
        WHERE department_id = 10;
    v_employee_id INT;
    v_salary DECIMAL;
BEGIN
    FOR v_employee_id, v_salary IN CURSOR emp_cursor LOOP
        -- Process record
        RAISE NOTICE '%: %', v_employee_id, v_salary;
    END LOOP;
END;
$$;
```

### Transaction Handling

```sql
-- SQL Server
BEGIN TRY
    BEGIN TRANSACTION;
    
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Vertica
BEGIN
    PERFORM UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    PERFORM UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
```

### Dynamic SQL Execution

```sql
-- SQL Server: Execute dynamic SQL and assign result to variable
DECLARE @table_name VARCHAR(100) = 'employees';
DECLARE @row_count INT;
EXEC('SELECT @cnt = COUNT(*) FROM ' + @table_name);

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

### Error Handling

```sql
-- SQL Server
RAISERROR('Error message', 16, 1);

-- Vertica
RAISE EXCEPTION 'Error message';
```

### Exception Handling with GET STACKED DIAGNOSTICS

Vertica PL/vSQL provides `SQLSTATE` and `SQLERRM` built-in variables directly in exception handlers. Use `GET STACKED DIAGNOSTICS` only when more detailed error information (such as detail, hint, context) is needed.

#### Simple Cases: Use SQLSTATE / SQLERRM Directly

```sql
-- SQL Server
BEGIN TRY
    -- some operation
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    PRINT 'State: ' + CAST(ERROR_STATE() AS VARCHAR);
    THROW;
END CATCH;

-- Vertica: directly use SQLSTATE and SQLERRM variables
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No data found';
    WHEN TOO_MANY_ROWS THEN
        RAISE NOTICE 'Too many rows';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
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
END;
```

## Function Migration Strategies Overview

This guide covers multiple SQL Server function migration approaches:

1. **SQL Function to Subquery Conversion** - For functions used in SELECT statements, convert to LEFT JOIN subqueries for optimal performance
2. **Function to Stored Procedure** - Convert return values to OUT parameters for procedural logic
3. **User-Defined SQL Functions** - For simple transformations that can be expressed in SQL
4. **UDx Development** - For complex logic requiring C++, Python, Java, or R

## Function Migration Strategies

SQL Server functions can be migrated to Vertica using multiple approaches. The choice depends on the function's complexity, performance requirements, and usage patterns.

### Strategy 1: SQL Function to Subquery Conversion (Performance-Optimized)

For SQL Server scalar or table-valued functions that can be expressed as a query and are used in SELECT statements, convert them to subqueries with LEFT JOIN for better performance in Vertica's columnar architecture.

```sql
-- SQL Server Scalar Function and Query
CREATE FUNCTION dbo.IsActiveUser(@user_id VARCHAR(50))
RETURNS VARCHAR(1)
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM active_users u WHERE u.user_id = @user_id;
    IF (@count > 0)
        RETURN '1';
    RETURN '0';
END;

SELECT user_id, user_name, dbo.IsActiveUser(user_id) AS is_active
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

SQL Server functions can be effectively migrated to Vertica stored procedures by converting the return value to an additional OUT parameter. This approach maintains SQL Server-like semantics while leveraging Vertica's stored procedure capabilities.

#### Key Migration Pattern

**Tuple Unpacking Assignment**: When a stored procedure has OUT or INOUT parameters, `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The `:=` assignment unpacks the tuple's columns into variables by position:

```sql
-- CALL returns a tuple; := unpacks it into variables
var_return := CALL procedure_name([params]);                         -- single OUT → scalar
var_out1, var_out2, var_return := CALL procedure_name([params]);     -- multiple OUTs → unpack
```

#### Migration Examples

##### Pattern 1: Simple Scalar Function with Return Value

```sql
-- SQL Server Function
CREATE FUNCTION dbo.GetConfigValue()
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @value VARCHAR(100);
    SELECT @value = config_value FROM app_config WHERE config_key = 'SYSTEM_NAME';
    RETURN @value;
END;

-- Usage in SQL Server
DECLARE @val VARCHAR(100);
SET @val = dbo.GetConfigValue();
PRINT 'Config value: ' + @val;

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
-- SQL Server Function
CREATE FUNCTION dbo.GetDepartmentName(@dept_id INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @name VARCHAR(100);
    SELECT @name = dept_name FROM departments WHERE department_id = @dept_id;
    RETURN @name;
END;

-- Usage in SQL Server
DECLARE @name VARCHAR(100);
SET @name = dbo.GetDepartmentName(10);
PRINT 'Department: ' + @name;

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

##### Pattern 3: Table-Valued Function with Multiple Return Values

```sql
-- SQL Server Table-Valued Function
CREATE FUNCTION dbo.GetDepartmentStats(@dept_id INT)
RETURNS TABLE
AS
RETURN (
    SELECT COUNT(*) AS emp_count,
           AVG(salary) AS avg_salary,
           MAX(salary) AS max_salary
    FROM employees
    WHERE department_id = @dept_id
);

-- Usage in SQL Server
SELECT * FROM dbo.GetDepartmentStats(10);

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_department_stats(
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

1. **SQL Server-like Semantics**: Maintains familiar variable assignment patterns
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

## Index and Constraint Migration

### Primary Keys

```sql
-- SQL Server
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (same syntax)
CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    emp_name VARCHAR(100)
);
```

### Foreign Keys

```sql
-- SQL Server
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Vertica (same syntax)
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Foreign Key Constraint Limitations

**Critical Limitation**: Vertica does NOT support `ON DELETE CASCADE` for foreign key constraints, which is a key difference from SQL Server.

```sql
-- SQL Server table with ON DELETE CASCADE
CREATE TABLE order_items (
    item_id INT IDENTITY PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
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
-- SQL Server
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE
);

-- Vertica (same syntax)
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE
);
```

## Common Migration Challenges

### 0. Identifiers: Case Sensitivity & Quoting

**Difference**: SQL Server identifier behavior depends on the database collation (default: case-insensitive). Vertica identifiers are **always case-insensitive**, whether quoted or not. Additionally, SQL Server uses **square brackets** (`[identifier]`) for quoting — Vertica does not support them.

**Impact**: Bracket-quoted identifiers must be converted to double quotes. Collations that are case-sensitive in SQL Server will lose that distinction in Vertica.

**Solution**: Replace all `[identifier]` with `"identifier"`. Audit for objects relying on case-sensitive collation and rename if needed. Adopt `snake_case` naming; avoid special characters.

```sql
-- SQL Server: square brackets or double quotes
SELECT [order id], [customer name], [total]
FROM [dbo].[order details]
WHERE [order date] > '2024-01-01';

-- Vertica: double quotes only (square brackets NOT supported)
SELECT "order id", "customer name", "total"
FROM "order details"
WHERE "order date" > '2024-01-01';

-- Better: avoid quoting entirely
SELECT order_id, customer_name, total
FROM order_details
WHERE order_date > '2024-01-01';
```

### 1. Identity Columns
**Challenge**: SQL Server IDENTITY vs Vertica IDENTITY/AUTO_INCREMENT
**Solution**: Use Vertica's IDENTITY or AUTO_INCREMENT (both are equivalent)

Vertica's `IDENTITY` and `AUTO_INCREMENT` are **synonyms** — they are the same column constraint with identical behavior. `IDENTITY` is the Vertica-native keyword; `AUTO_INCREMENT` is supported for cross-database compatibility.

```sql
-- SQL Server
CREATE TABLE employees (
    emp_id INT IDENTITY(1,1) PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (IDENTITY — Vertica-native syntax, seed/step not needed)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (AUTO_INCREMENT — also valid, identical behavior)
CREATE TABLE orders (
    order_id AUTO_INCREMENT PRIMARY KEY,
    customer_id INTEGER
);

-- Vertica with explicit start/increment
CREATE TABLE products (
    product_id IDENTITY(100, 1) PRIMARY KEY,
    product_name VARCHAR(255)
);

-- Vertica alternative using named sequences (for more control)
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE employees_seq (
    emp_id INTEGER DEFAULT NEXTVAL('emp_seq'),
    emp_name VARCHAR(100)
);
```

**Key differences from SQL Server:**
- 🚨 **Vertica `IDENTITY`/`AUTO_INCREMENT` is a standalone data type — do NOT prefix it with `INT` or `INTEGER`.** Writing `INT IDENTITY` or `INTEGER IDENTITY` is a syntax error in Vertica. Use `IDENTITY` alone.
- SQL Server `IDENTITY(1,1)` specifies seed and step; Vertica `IDENTITY` uses defaults (start=1, increment=1) — seed/step rarely needed
- SQL Server IDENTITY is transactional; Vertica IDENTITY is **not** — gaps can occur due to caching and distributed architecture
- Vertica IDENTITY has a default cache of 250,000 values per node for MPP performance; SQL Server has no equivalent
- Only **one** IDENTITY/AUTO_INCREMENT column per table (same as SQL Server)
- **Not allowed** in temporary tables — use named sequences instead

> **Note**: Vertica temp tables do **not** support `IDENTITY` or `AUTO_INCREMENT` columns. Use named sequences instead.

### 2. Temporary Tables
**Challenge**: SQL Server temporary tables (#local_temp, ##global_temp) have different behavior in Vertica

Vertica supports both **Global** and **Local** temporary tables, but with critical differences from SQL Server:

| Feature | SQL Server `#local_temp` | SQL Server `##global_temp` | Vertica Local Temp | Vertica Global Temp |
|---------|-------------------|--------------------|--------------------|--------------------|
| **Syntax** | `#tablename` | `##tablename` | `CREATE LOCAL TEMP TABLE` | `CREATE GLOBAL TEMP TABLE` |
| **Definition visibility** | Session only | All sessions | Session only | All sessions |
| **Data visibility** | Session only | **All sessions** ⚠️ | Session only | **Session only** ⚠️ |
| **Definition lifetime** | Session | Until dropped | Session | Until dropped |

**⚠️ Critical Difference**: In SQL Server, `##global_temp` tables share data **across sessions**. In Vertica, **global temporary table data is ALWAYS private to the session** that inserted it — even though the table definition is globally visible. There is **no Vertica equivalent** of SQL Server's cross-session `##global_temp` data sharing.

**ON COMMIT Options** (no SQL Server equivalent):

- `ON COMMIT DELETE ROWS` (default): Data is **transaction-scoped** — cleared after each COMMIT
- `ON COMMIT PRESERVE ROWS`: Data is **session-scoped** — persists across transactions

```sql
-- SQL Server local temp table
SELECT * INTO #temp_results FROM complex_query;

-- SQL Server global temp table (data shared across sessions!)
SELECT * INTO ##global_temp FROM complex_query;

-- Vertica: Local temp table (definition visible only to current session)
SELECT * INTO LOCAL TEMP TABLE temp_results
ON COMMIT PRESERVE ROWS
FROM complex_query;

-- Vertica: Global temp table (definition visible to all, data private to session)
SELECT * INTO GLOBAL TEMP TABLE temp_results
ON COMMIT PRESERVE ROWS
FROM complex_query;

-- Vertica: Transaction-scoped temp table (data auto-cleared on COMMIT)
SELECT * INTO LOCAL TEMP TABLE temp_txn
FROM (VALUES (1, 2)) AS t(a, b);
COMMIT;
SELECT * FROM temp_txn;  -- Returns 0 rows (data deleted on commit)

-- Vertica: CTE alternative (no temp table needed)
WITH temp_results AS (
    SELECT * FROM complex_query
)
SELECT * FROM temp_results;
```
**Key differences from SQL Server `SELECT INTO #temp`**:

| Aspect | Vertica `SELECT INTO TEMP` | SQL Server `SELECT INTO #temp` |
|--------|---------------------------|-------------------------------|
| Data population | ❌ **Does NOT populate by default** — must add `ON COMMIT PRESERVE ROWS` | ✅ Always populates data |
| ON COMMIT options | `DELETE ROWS` (default) / `PRESERVE ROWS` | No ON COMMIT concept |
| Global temp data sharing | ❌ Data is always session-private | ✅ `##temp` data is shared across sessions |

**Important Restrictions**:

- Vertica temp tables do **not** support `IDENTITY` or `AUTO-INCREMENT` columns
- Local temp tables **cannot** specify a schema name
- For CTAS and SELECT INTO temp tables, you **must** specify `ON COMMIT PRESERVE ROWS` or data is lost at implicit commit
- Temp table data is **not** visible through system (virtual) tables
- `ALTER TABLE` (ADD/DROP/RENAME COLUMN, SET SCHEMA) is not supported on temp tables
- `SELECT FOR UPDATE` is not allowed on temp tables
- Partitioning is not supported for temp tables

### 3. Cursors
**Challenge**: SQL Server cursors are procedural, Vertica prefers set-based operations
**Solution**: Convert to set-based operations using window functions

```sql
-- SQL Server cursor approach (avoid in Vertica)
-- Use window functions instead
SELECT employee_id, salary,
       LAG(salary) OVER (ORDER BY hire_date) as prev_salary,
       LEAD(salary) OVER (ORDER BY hire_date) as next_salary
FROM employees;
```

### 4. Dynamic SQL
**Challenge**: Different syntax for dynamic SQL execution
**Solution**: Use Vertica's EXECUTE statement

```sql
-- SQL Server (Using EXEC Command)
DECLARE @SQL NVARCHAR(1000);
DECLARE @City NVARCHAR(50);
SET @City = 'London';
SET @SQL = 'SELECT * FROM Person.Address WHERE City = ''' + @City + '''';
EXEC(@SQL);

-- SQL Server (Using sp_executesql)
DECLARE @SQL NVARCHAR(1000);
DECLARE @City NVARCHAR(50);
SET @City = 'London';
SET @SQL = 'SELECT * FROM Person.Address WHERE City = @City';
EXEC sp_executesql @SQL, '@City NVARCHAR(50)', @City = @City;

-- Vertica (in PL/vSQL)
EXECUTE 'SELECT * FROM Person.Address WHERE City = ?' USING 'London';
```

### 5. NULL Handling Differences
**Challenge**: SQL Server's ISNULL and COALESCE both work in Vertica, but with subtle differences

**Solution**: Both `ISNULL()` and `COALESCE()` are supported in Vertica. `COALESCE()` is ANSI standard and supports multiple arguments, so it is preferred.

```sql
-- SQL Server ISNULL (only 2 arguments, returns data type of first argument)
SELECT ISNULL(middle_name, 'N/A') FROM employees;

-- SQL Server COALESCE (multiple arguments, ANSI standard)
SELECT COALESCE(middle_name, secondary_name, 'N/A') FROM employees;

-- Vertica: Both ISNULL and COALESCE are supported
SELECT ISNULL(middle_name, 'N/A') FROM employees;  -- Works in Vertica
SELECT COALESCE(middle_name, secondary_name, 'N/A') FROM employees;  -- Preferred
```

### 6. JSON Support
**Challenge**: SQL Server has extensive JSON support with `JSON_VALUE()`, `JSON_QUERY()`, `OPENJSON()`, and `FOR JSON`. Vertica does not have native JSON type support.

**Solution**: Use **Vertica Flex Tables** to store and query JSON data. Flex Tables load JSON natively into an internal VMap structure, allowing you to query virtual columns directly without pre-defining a schema.

```sql
-- SQL Server: Query JSON column
SELECT id,
       JSON_VALUE(data, '$.name') AS name,
       JSON_VALUE(data, '$.age') AS age
FROM json_table
WHERE JSON_VALUE(data, '$.status') = 'active';

-- SQL Server: Shred JSON array
SELECT j.*
FROM json_table
CROSS APPLY OPENJSON(data, '$.items')
WITH (item_id INT, item_name VARCHAR(100)) AS j;

-- Vertica Flex Table equivalent
CREATE FLEX TABLE json_events();
COPY json_events FROM '/data/events.json' PARSER fjsonparser();
SELECT compute_flextable_keys_and_build_view('json_events');

-- Query virtual columns directly
SELECT "name", "age", "status"
FROM json_events
WHERE "status" = 'active';
```

### 7. Full-Text Search
**Challenge**: SQL Server has built-in full-text search with `CONTAINS()`, `FREETEXT()`, and full-text catalogs/indexes.

**Solution**: Use **Vertica Text Index** for efficient keyword search on text columns.

```sql
-- SQL Server: Full-text search
SELECT * FROM articles
WHERE CONTAINS(content, 'search term');

-- SQL Server: Full-text search with ranking
SELECT * FROM articles
WHERE FREETEXT(content, 'search term');

-- Vertica: Create and query text index
CREATE TEXT INDEX articles_text_idx ON articles (id, content);

SELECT * FROM articles
WHERE id IN (
    SELECT doc_id FROM articles_text_idx
    WHERE token = v_txtindex.StemmerCaseInsensitive('search term')
);
```


### 8. Computed Columns
**Challenge**: SQL Server computed columns (`AS expression`) have no direct equivalent in Vertica. They can depend on same-row columns, other tables, volatile functions (e.g., `GETDATE()`), or UDFs — making migration complex.

**Solution**: Migrate all computed columns as **Flattened Table** columns using `DEFAULT` and `SET USING`. This works for every type of computed column: same-row expressions, cross-table lookups, time-dependent logic, and UDF-based computation.

- **`DEFAULT`** — evaluated automatically at INSERT time (or when the column is added). Populates the initial value.
- **`SET USING`** — evaluated only when `REFRESH_COLUMNS()` is explicitly called. Keeps values up to date after source data changes.

```sql
-- SQL Server: simple computed column
CREATE TABLE orders (
    order_id    INT IDENTITY PRIMARY KEY,
    quantity    INT NOT NULL,
    unit_price  NUMERIC(10,2) NOT NULL,
    total_price AS (quantity * unit_price)
);

-- Vertica: Flattened Table with DEFAULT USING
CREATE TABLE orders (
    order_id    IDENTITY PRIMARY KEY,
    quantity    INTEGER NOT NULL,
    unit_price  NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) DEFAULT USING (quantity * unit_price)
);
```

```sql
-- SQL Server: time-dependent computed column
CREATE TABLE person (
    id              INT IDENTITY PRIMARY KEY,
    name            VARCHAR(50),
    last_update     DATETIME,
    active_in_last_30_days AS (
        CASE WHEN DATEDIFF(DAY, last_update, GETDATE()) <= 30 THEN 1 ELSE 0 END
    ) PERSISTED
);

-- Vertica: Flattened Table with DEFAULT USING
CREATE TABLE person (
    id              IDENTITY PRIMARY KEY,
    name            VARCHAR(50),
    last_update     TIMESTAMP,
    active_in_last_30_days BOOLEAN
        DEFAULT USING (CURRENT_TIMESTAMP - last_update <= INTERVAL '30 days')
);
```

**Refreshing SET USING columns:**

```sql
-- Refresh specific columns
SELECT REFRESH_COLUMNS('person', 'active_in_last_30_days');

-- Refresh all SET USING columns on a table
SELECT REFRESH_COLUMNS('person', '');

-- For partitioned tables, limit refresh to recent partitions
SELECT REFRESH_COLUMNS('orders', 'total_price', 'REBUILD',
                        '2026-01-01', '2026-05-31');
```

**REFRESH_COLUMNS modes:**
- **`UPDATE`** (default) — marks old rows as deleted, inserts new rows. Best for small changes. Requires explicit COMMIT.
- **`REBUILD`** — replaces all data in specified columns. Best for large-scale refresh or new columns. Auto-committed.

### 9. PIVOT Operations
**Challenge**: Vertica does **not** support the `PIVOT` operator. SQL Server queries using `PIVOT` must be rewritten.

**Solution**: Replace `PIVOT` with `CASE` expressions inside aggregate functions:

```sql
-- SQL Server PIVOT
SELECT *
FROM (
    SELECT year, quarter, sales
    FROM sales_data
) AS source
PIVOT (
    SUM(sales)
    FOR quarter IN ([Q1], [Q2], [Q3], [Q4])
) AS pvt;

-- Vertica: CASE-based equivalent
SELECT year,
       SUM(CASE WHEN quarter = 'Q1' THEN sales ELSE 0 END) AS Q1_sales,
       SUM(CASE WHEN quarter = 'Q2' THEN sales ELSE 0 END) AS Q2_sales,
       SUM(CASE WHEN quarter = 'Q3' THEN sales ELSE 0 END) AS Q3_sales,
       SUM(CASE WHEN quarter = 'Q4' THEN sales ELSE 0 END) AS Q4_sales
FROM sales_data
GROUP BY year;
```

### 10. UNPIVOT Operations
**Challenge**: Vertica does **not** support the `UNPIVOT` operator. Columns-to-rows transformations require a different approach.

**Solution**: Use one of two rewrite strategies depending on the number of columns:

**Method 1 — `UNION ALL`** (recommended for < 10 columns): Simple, easy to read, good performance.

```sql
-- SQL Server: UNPIVOT
SELECT product_id, month, sales
FROM sales_data
UNPIVOT (
    sales FOR month IN (jan, feb, mar, apr)
) AS unpvt;

-- Vertica: UNION ALL equivalent
SELECT product_id, 'jan' AS month, jan AS sales FROM sales_data
UNION ALL
SELECT product_id, 'feb' AS month, feb AS sales FROM sales_data
UNION ALL
SELECT product_id, 'mar' AS month, mar AS sales FROM sales_data
UNION ALL
SELECT product_id, 'apr' AS month, apr AS sales FROM sales_data;
```

**Method 2 — `CROSS JOIN + CASE`** (better for 10+ columns): More concise, single table scan.

```sql
-- Vertica: CROSS JOIN + CASE
SELECT s.product_id,
       m.month,
       CASE m.month
           WHEN 'jan' THEN s.jan
           WHEN 'feb' THEN s.feb
           WHEN 'mar' THEN s.mar
           WHEN 'apr' THEN s.apr
           WHEN 'may' THEN s.may
           WHEN 'jun' THEN s.jun
       END AS sales
FROM sales_data s
CROSS JOIN (
    SELECT 'jan' AS month UNION ALL
    SELECT 'feb' UNION ALL
    SELECT 'mar' UNION ALL
    SELECT 'apr' UNION ALL
    SELECT 'may' UNION ALL
    SELECT 'jun'
) m;
```

| Method | Best for | Pros | Cons |
|--------|----------|------|------|
| `UNION ALL` | Few columns (< 10) | Simple, easy to read | Verbose with many columns |
| `CROSS JOIN + CASE` | Many columns (10+) | Concise, single table scan | Slightly more complex |

> **Note**: `UNION ALL` (without `DISTINCT`) preserves duplicate rows, matching `UNPIVOT` behavior. If source columns contain `NULL`s, add `WHERE sales IS NOT NULL` to exclude them.

### 11. UNION Type Consistency
**Challenge**: SQL Server performs **implicit type conversion** in UNION operations, but Vertica requires **explicit type consistency** across all UNION branches, even for data type combinations that support implicit conversion in other contexts.

**Solution**: Use explicit CAST operations to ensure all UNION branches have compatible data types.

```sql
-- SQL Server: Implicit conversion works
INSERT INTO test 
SELECT 1 AS id
UNION ALL 
SELECT '2'; -- SQL Server converts '2' to INT automatically

-- Vertica: Explicit CAST required
INSERT INTO test 
SELECT 1 AS id
UNION ALL 
SELECT CAST('2' AS INT); -- Must cast explicitly
```

**Key Finding**: Even data type combinations that support implicit conversion in other SQL contexts (like `SELECT 2 + '2'`) **fail in UNION operations** and require explicit CAST.

**Common scenarios requiring explicit casting:**

```sql
-- String and numeric types (FAILS in Vertica)
SELECT 'ID001' AS code  -- VARCHAR
UNION ALL
SELECT 123;             -- INTEGER - ERROR: For 'UNION', types varchar and int are inconsistent

-- Fixed in Vertica:
SELECT 'ID001' AS code
UNION ALL
SELECT CAST(123 AS VARCHAR);

-- Date and string types (FAILS in Vertica)
SELECT DATE'2024-01-01' AS event_date  -- DATE
UNION ALL
SELECT '2024-01-01';                   -- VARCHAR - ERROR: For 'UNION', types date and varchar are inconsistent

-- Fixed in Vertica:
SELECT DATE'2024-01-01' AS event_date
UNION ALL
SELECT CAST('2024-01-01' AS DATE);

-- Timestamp and string types (FAILS in Vertica)
SELECT TIMESTAMP'2024-01-01' AS ts  -- TIMESTAMP
UNION ALL
SELECT '2024-01-01';                 -- VARCHAR - ERROR: For 'UNION', types timestamp and varchar are inconsistent

-- Fixed in Vertica:
SELECT TIMESTAMP'2024-01-01' AS ts
UNION ALL
SELECT CAST('2024-01-01' AS TIMESTAMP);
```

**Type combinations that work without CAST:**

```sql
-- Numeric types (INTEGER/NUMERIC/FLOAT) - implicit conversion supported
SELECT 1 AS value        -- INTEGER
UNION ALL
SELECT 2.5;             -- NUMERIC - Works fine

-- Date and timestamp - implicit conversion supported  
SELECT DATE'2024-01-01' AS dt          -- DATE
UNION ALL
SELECT TIMESTAMP'2024-01-01 00:00:00'; -- TIMESTAMP - Works fine (DATE->TIMESTAMP)
```

**Important distinction:**
- **Other SQL contexts**: VARCHAR can be implicitly converted to FLOAT, DATE, TIMESTAMP
- **UNION operations**: Require explicit type consistency even for these combinations

**Migration strategy:**
1. **Identify UNION statements** with mixed data types
2. **Use explicit CAST** for any non-numeric type mixing (string/numeric, string/date, etc.)
3. **Test all UNION operations** thoroughly after migration
4. **Remember**: If it's not purely numeric types (INTEGER/NUMERIC/FLOAT) or date/timestamp combinations, use CAST

### 12. Recursive CTE Migration

**Challenge**: SQL Server and Vertica both support standard `WITH RECURSIVE` CTEs, but Vertica has stricter limitations on the recursive term and a much lower default recursion depth.

#### Key Differences at a Glance

| Feature | SQL Server | Vertica |
|---------|-----------|---------|
| Syntax | `WITH cte AS (...)` (no `RECURSIVE` keyword needed) | `WITH RECURSIVE cte AS (...)` (keyword required) |
| **INSERT + CTE order** | **`WITH` before INSERT**: `WITH cte AS (...) INSERT INTO t SELECT ...` | **`INSERT` before WITH**: `INSERT INTO t WITH cte AS (...) SELECT ...` |
| Default recursion depth | 100 (`MAXRECURSION` hint) | **8** (`WithClauseRecursionLimit`) |
| Max recursion depth | 32,767 (with `MAXRECURSION 0` = unlimited) | No hard limit (but resource-bound) |
| `*` in anchor term | ✅ Allowed | ❌ **Not allowed** |
| Multiple CTE references in recursive term | ✅ Allowed | ❌ **Only 1 reference** |
| Outer join in recursive term | ✅ Allowed | ❌ **Not allowed** |
| Subquery referencing CTE in recursive term | ✅ Allowed | ❌ **Not allowed** |
| `ORDER BY` / `LIMIT` inside UNION | ✅ `LIMIT` allowed | ❌ **Not allowed** |
| Cycle detection | ❌ No built-in | ❌ No built-in |

#### Critical: INSERT + CTE Syntax Order Is Reversed

**This is a key syntactic difference that affects every CTE used with INSERT.** In SQL Server, the `WITH` clause comes *before* `INSERT`. In Vertica, `INSERT` comes *before* `WITH`:

```sql
-- ❌ SQL Server syntax (fails in Vertica)
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

This applies to **all** CTEs (both regular and recursive) when used with INSERT:

```sql
-- ❌ SQL Server: WITH before INSERT (recursive CTE)
WITH emp_hierarchy AS (
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

**This is the most common migration issue.** Vertica's default recursion depth is only **8**, compared to SQL Server's default of **100**. Deep hierarchies will be **silently truncated without error**.

```sql
-- SQL Server: default MAXRECURSION is 100
WITH emp_hierarchy AS (
    SELECT employee_id, manager_id, name, 1 AS level
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;
-- OPTION (MAXRECURSION 200);  -- SQL Server way to increase limit

-- Vertica: must set limit explicitly
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

#### Critical: Non-Recursive Term Cannot Use `*`

```sql
-- ❌ SQL Server allows this, but Vertica does NOT
WITH RECURSIVE cte AS (
    SELECT * FROM employees WHERE manager_id IS NULL  -- ERROR in Vertica
    UNION ALL
    SELECT * FROM employees e JOIN cte ON ...
)
SELECT * FROM cte;

-- ✅ Vertica: explicitly list all columns
WITH RECURSIVE cte AS (
    SELECT employee_id, manager_id, name FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.name
    FROM employees e JOIN cte ON e.manager_id = cte.employee_id
)
SELECT * FROM cte;
```

#### Critical: Recursive Term Restrictions

SQL Server allows patterns that Vertica forbids. Common rewrites needed:

```sql
-- ❌ SQL Server: multiple CTE references in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM cte a JOIN cte b ON a.id = b.parent_id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ SQL Server: outer join in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM employees e
    LEFT JOIN cte ON e.manager_id = cte.id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ SQL Server: subquery referencing CTE in recursive term
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

#### SQL Server `MAXRECURSION` Hint → Vertica `WithClauseRecursionLimit`

```sql
-- SQL Server
WITH cte AS (...)
SELECT * FROM cte
OPTION (MAXRECURSION 200);

-- Vertica: set before the query
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 200;
WITH RECURSIVE cte AS (...)
SELECT * FROM cte;
```

#### CTE Variable Assignment in Stored Procedures

**SQL Server** uses `SELECT @var = column FROM cte` to assign CTE results to variables — the variable is assigned directly from the SELECT list, no `INTO` keyword needed. **Vertica** uses a completely different syntax: `var := WITH cte AS (...) SELECT ...`, where the entire `WITH ... SELECT` is the expression being assigned. Parentheses are optional:

```sql
-- ✅ SQL Server: SELECT @var = ... (no INTO, no subquery wrapper needed)
WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
SELECT @count = cnt FROM cte;

-- ❌ This SQL Server syntax does NOT work in Vertica
-- (Vertica has no @var assignment syntax)

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
               SELECT emp_id, manager_id, 1 AS level
               FROM employees WHERE manager_id IS NULL
               UNION ALL
               SELECT e.emp_id, e.manager_id, et.level + 1
               FROM employees e JOIN emp_tree et ON e.manager_id = et.emp_id
           )
           SELECT COUNT(*) FROM emp_tree;
```

> **Note**: `SELECT ... INTO var WITH cTE ...` (without a subquery wrapper) is **not valid** in Vertica. Use `var := WITH ... SELECT ...` instead.

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
**Problem**: `@param INT OUTPUT` becomes `p_param INTEGER`
**Solution**: Always preserve OUT/INOUT: `OUT p_param INTEGER`

#### Error: Incorrect data type for parameters
**Problem**: `NUMERIC` type used as parameter
**Solution**: Use `INTEGER` or `FLOAT` instead

#### Error: Missing parameter mode specification
**Problem**: `OUTPUT` parameters converted to plain parameters
**Solution**: Always specify `OUT` for output parameters

#### Error: Incorrect exception handling
**Problem**: Using T-SQL `ERROR_MESSAGE()`, `ERROR_STATE()` in Vertica
**Solution**: In Vertica, use `SQLSTATE` and `SQLERRM` directly for basic error info. For detailed info, use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT`

## SQL Server to Vertica Migration Checklist

### 🚨 Critical Parameter Handling

See the [Generic Migration Guide — Critical Parameter Handling](generic-migration-guide.md#-critical-parameter-handling) for the common checklist items. Add SQL Server–specific items here when needed.

### 📋 General Migration Checklist

See the [Generic Migration Guide — General Migration Checklist](generic-migration-guide.md#-general-migration-checklist) for the common checklist items. The following SQL Server–specific items also apply:

- [ ] Temp table behavior reviewed (no cross-session data sharing in Vertica)

### 🚫 Critical "Never" Rules

<!-- Add SQL Server–specific "Never" rules here when needed. -->

This comprehensive guide covers the essential aspects of migrating from SQL Server to Vertica, focusing on practical conversion strategies and performance optimization techniques.
