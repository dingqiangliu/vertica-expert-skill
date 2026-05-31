# MySQL to Vertica Migration Guide

This guide provides comprehensive guidance for migrating MySQL databases to Vertica, including SQL syntax conversion, stored procedure migration, and performance optimization strategies.

## 🚨 CRITICAL: MANDATORY COMPLIANCE REQUIREMENTS

**BEFORE STARTING ANY MYSQL MIGRATION, YOU MUST READ AND FOLLOW THE [GENERIC MIGRATION GUIDE](generic-migration-guide.md)**

This MySQL migration guide **MUST BE USED IN CONJUNCTION WITH** the [Generic Migration Guide](generic-migration-guide.md). The generic guide contains **MANDATORY PROCEDURES** that apply to ALL database migrations, including:

- ✅ **COMPLETE migration** of ALL objects (no selective migration allowed)
- ✅ **SEQUENTIAL processing** in exact source file order (no reordering)
- ✅ **ONE-TO-ONE conversion** (tables→tables, procedures→procedures, etc.)
- ✅ **INDIVIDUAL testing** of every object before considering it migrated
- ✅ **NO automated scripts** or bulk processing
- ✅ **PRESERVATION** of all sequences, and dependencies

**FAILURE TO FOLLOW THE GENERIC MIGRATION GUIDE WILL RESULT IN FAILED MIGRATIONS.**

## Database and Schema Mapping

MySQL's `database` and `schema` are the same concept (e.g., `USE database` and `USE schema` are equivalent). Vertica has a single database with multiple schemas. When migrating from MySQL:

- Map each **MySQL database** to a **Vertica schema** with the **exact same name**
- Never rename, merge, or drop database/schema names during migration — changing names will break cross-database references and cause naming conflicts when objects with the same name exist in different source databases
- Use `SET SEARCH_PATH` to control schema resolution order

> ⚠️ **CRITICAL — CREATE SCHEMA AND SET SEARCH_PATH MUST BE DONE TOGETHER**: For every MySQL database being migrated, you **MUST** perform **both** of the following actions **together** — never omit either one:
> 1. `CREATE SCHEMA IF NOT EXISTS <dbname>;` — creates the schema in Vertica
> 2. `SET SEARCH_PATH = <dbname>, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;` — sets the search path so objects in that schema can be resolved without full qualification
>
> **RATIONALE**: These two operations are **inseparable and equally mandatory**. Creating the schema without setting `SEARCH_PATH` means objects inside it cannot be found by unqualified name, causing "object not found" errors. Setting `SEARCH_PATH` without creating the schema means the schema does not exist, causing "schema does not exist" errors. **Always pair them — never do one without the other.**

```sql
-- MySQL: switch to a database
USE CRM;

-- Vertica: create the equivalent schema and set search path
CREATE SCHEMA IF NOT EXISTS CRM;
SET SEARCH_PATH = CRM, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;

-- MySQL: cross-database query
SELECT * FROM CRM.customers c
JOIN ERP.invoices i ON c.customer_id = i.customer_id;

-- Vertica: cross-schema query (within the same database)
SELECT * FROM CRM.customers c
JOIN ERP.invoices i ON c.customer_id = i.customer_id;
```

**Key differences**:

| Aspect | MySQL | Vertica |
|--------|-------|---------|
| Database vs Schema | Same concept | Schema only (single database) |
| Object reference | `database.table` | `schema.table` |
| Schema switching | `USE database` | `SET SEARCH_PATH TO schema, ...` |

### 🚨 USE Statement Tracking — Schema Prefix Rule

**This is the #1 cause of missing schema prefixes in migrated CREATE statements. Read carefully.**

When migrating a MySQL script that contains `USE database` statements, you **MUST** track the current database context and apply it as the schema prefix to **every subsequently created object** (tables, views, procedures, functions, etc.) until the next `USE` statement switches context.

**Rules:**
- When `USE dbname` is encountered → all following `CREATE` objects must be prefixed as `dbname.object_name`
- If **no** `USE` statement exists in the script → **do not add any schema prefix**; use bare object names (e.g., `CREATE TABLE customers (...)` not `CREATE TABLE dbname.customers (...)`)
- Replace `USE dbname` with `CREATE SCHEMA IF NOT EXISTS dbname;` + `SET SEARCH_PATH = dbname, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;` — always pair them together

**Before (MySQL):**
```sql
USE CRM;
CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE VIEW active_customers AS
    SELECT * FROM customers WHERE active = 1;

USE ERP;
CREATE TABLE invoices (
    id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2)
);

USE CRM;
CREATE VIEW v_customer_orders AS
    SELECT * FROM invoices;
```

**After (Vertica):**
```sql
CREATE SCHEMA IF NOT EXISTS CRM;
SET SEARCH_PATH = CRM, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;
CREATE TABLE CRM.customers (    -- CRM schema prefix from USE CRM
    id INTEGER PRIMARY KEY,
    name VARCHAR(100)
);
CREATE VIEW CRM.active_customers AS  -- CRM schema prefix from USE CRM
    SELECT * FROM CRM.customers WHERE active = 1;

CREATE SCHEMA IF NOT EXISTS ERP;
SET SEARCH_PATH = ERP, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;
CREATE TABLE ERP.invoices (     -- ERP schema prefix from USE ERP
    id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    amount NUMERIC(10,2)
);

CREATE SCHEMA IF NOT EXISTS CRM;
SET SEARCH_PATH = CRM, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;
CREATE VIEW CRM.v_customer_orders AS  -- CRM schema prefix from USE CRM
    SELECT * FROM ERP.invoices;
```

> 🚨 **COMMON MISTAKE**: Generating `CREATE TABLE customers (...)` without the `CRM.` prefix when `USE CRM` is active, or adding a schema prefix when no `USE` statement exists. **Always track the current USE context and apply the correct schema prefix.**

**Migration notes**:
- **Preserve database/schema names exactly** — always use the same name in Vertica
- Cross-database queries in MySQL become cross-schema queries in Vertica

## Function Migration Strategies Overview

This guide covers multiple MySQL function migration approaches:

1. **SQL Function to Subquery Conversion** - For functions used in SELECT statements, convert to LEFT JOIN subqueries for optimal performance
2. **Function to Stored Procedure** - Convert return values to OUT parameters for procedural logic
3. **User-Defined SQL Functions** - For simple transformations that can be expressed in SQL
4. **UDx Development** - For complex logic requiring C++, Python, Java, or R

## SQL Syntax Conversion

### Basic SELECT Statement Differences

```sql
-- MySQL
SELECT * FROM employees e, departments d 
WHERE e.dept_id = d.dept_id
LIMIT 10;

-- Vertica (both implicit and explicit JOIN syntax are supported)
SELECT * FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
LIMIT 10;
```

### String Concatenation

```sql
-- MySQL
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;
SELECT first_name + ' ' + last_name as full_name FROM employees; -- Only works with numeric coercion

-- Vertica (use || operator or CONCAT)
SELECT first_name || ' ' || last_name as full_name FROM employees;
SELECT CONCAT(first_name, CONCAT(' ', last_name)) as full_name FROM employees;
```

### Date Functions

```sql
-- MySQL
SELECT NOW(), DATE_ADD(hire_date, INTERVAL 6 MONTH)
FROM employees;

-- Vertica
SELECT NOW(), ADD_MONTHS(hire_date, 6)
FROM employees;
```

### Auto-increment Columns

```sql
-- MySQL
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (use IDENTITY)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100)
);
```

### NULL Handling

```sql
-- MySQL
SELECT IFNULL(middle_name, 'N/A') FROM employees;
SELECT COALESCE(middle_name, 'N/A') FROM employees;

-- Vertica (both ISNULL and COALESCE are supported; COALESCE is ANSI standard and preferred)
SELECT ISNULL(middle_name, 'N/A') FROM employees;
SELECT COALESCE(middle_name, 'N/A') FROM employees;
```

## Data Type Mappings

### Numeric Types

| MySQL Type | Vertica Type | Notes |
|------------|--------------|-------|
| TINYINT | TINYINT | `INT`, `INTEGER`, `INT8`, `SMALLINT`, `TINYINT`, and `BIGINT` are all synonyms for the same signed 64-bit integer data type in Vertica |
| SMALLINT | SMALLINT | **8 bytes** in Vertica (2-byte integer in MySQL) |
| MEDIUMINT | INTEGER | **8 bytes** in Vertica (3-byte in MySQL) |
| INT | INTEGER | **8 bytes** in Vertica (4-byte integer in MySQL) |
| BIGINT | BIGINT | 8-byte integer |
| DECIMAL(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| FLOAT | REAL | **8 bytes** in Vertica (4-byte floating point in MySQL) |
| DOUBLE | DOUBLE PRECISION | 8-byte floating point |

### Character Types

| MySQL Type | Vertica Type | Notes |
|------------|--------------|-------|
| CHAR(n) | CHAR(n) | Fixed-length character |
| VARCHAR(n) | VARCHAR(n) | Variable-length character |
| TINYTEXT | VARCHAR(255) | Small text, use VARCHAR |
| TEXT | LONG VARCHAR | Medium text |
| MEDIUMTEXT | LONG VARCHAR | Large text |
| LONGTEXT | LONG VARCHAR | Very large text |

### Date/Time Types

| MySQL Type | Vertica Type | Notes |
|------------|--------------|-------|
| DATE | DATE | Date only |
| TIME | TIME | Time only |
| DATETIME | TIMESTAMP | Date and time |
| TIMESTAMP | TIMESTAMP | Unix timestamp |
| YEAR | INTEGER | Store as integer |

### Binary Types

| MySQL Type | Vertica Type | Notes |
|------------|--------------|-------|
| BINARY(n) | BINARY(n) | Fixed-length binary |
| VARBINARY(n) | VARBINARY(n) | Variable-length binary |
| TINYBLOB | VARBINARY(255) | Small binary |
| BLOB | LONG VARBINARY | Medium binary |
| MEDIUMBLOB | LONG VARBINARY | Large binary |
| LONGBLOB | LONG VARBINARY | Very large binary |

### Other Types

| MySQL Type | Vertica Type | Notes |
|------------|--------------|-------|
| ENUM | VARCHAR | Store as string |
| SET | VARCHAR | Store as comma-separated string |
| JSON | LONG VARCHAR | Store as text |
| BOOLEAN | BOOLEAN | True/False values |

## SQL Syntax Differences

### Common Functions

| MySQL Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| NOW() | NOW() or SYSDATE() | Current date/time |
| CURDATE() | CURRENT_DATE() | Current date |
| CURTIME() | CURRENT_TIME() | Current time |
| DATE_ADD(date, INTERVAL n unit) | date + INTERVAL 'n' unit | Date arithmetic |
| DATE_SUB(date, INTERVAL n unit) | date - INTERVAL 'n' unit | Date subtraction |
| DATEDIFF(date1, date2) | date1 - date2 | Date difference in days |
| IFNULL(value, replacement) | COALESCE(value, replacement) | NULL handling |
| LENGTH(string) | LENGTH(string) | String length in bytes |
| CHAR_LENGTH(string) | LENGTH(string) | String length in characters |
| SUBSTRING(string, start, length) | SUBSTRING(string, start, length), or SUBSTRING(string FROM start FOR length) | Substring extraction |
| LOCATE(substr, string) | INSTR(string, substr), POSITION(substr IN string) | Find substring |
| UPPER(string) | UPPER(string) | Convert to uppercase |
| LOWER(string) | LOWER(string) | Convert to lowercase |
| REPLACE(string, old, new) | REPLACE(string, old, new) | String replacement |
| CAST(value AS type) | CAST(value AS type) | Type conversion |

### LIMIT and OFFSET

```sql
-- MySQL
SELECT * FROM employees LIMIT 10 OFFSET 20;
SELECT * FROM employees LIMIT 20, 10; -- Alternative syntax

-- Vertica (same syntax)
SELECT * FROM employees LIMIT 10 OFFSET 20;
```

### INSERT with AUTO_INCREMENT

```sql
-- MySQL
INSERT INTO employees (emp_name, salary) VALUES ('John Doe', 50000);
-- emp_id is auto-generated

-- Vertica
INSERT INTO employees (emp_name, salary) VALUES ('John Doe', 50000);
-- emp_id is auto-generated with IDENTITY
```

### INSERT IGNORE and ON DUPLICATE KEY UPDATE

```sql
-- MySQL
INSERT IGNORE INTO employees (emp_id, emp_name) VALUES (1, 'John');
INSERT INTO employees (emp_id, emp_name) VALUES (1, 'John')
ON DUPLICATE KEY UPDATE emp_name = 'John';

-- Vertica (use conditional logic)
-- Option 1: Check existence first
INSERT INTO employees (emp_id, emp_name)
SELECT 1, 'John'
WHERE NOT EXISTS (SELECT 1 FROM employees WHERE emp_id = 1);

-- Option 2: Use MERGE statement
MERGE INTO employees e
USING (SELECT 1 as emp_id, 'John' as emp_name) s
ON e.emp_id = s.emp_id
WHEN MATCHED THEN
    UPDATE SET emp_name = s.emp_name
WHEN NOT MATCHED THEN
    INSERT (emp_id, emp_name) VALUES (s.emp_id, s.emp_name);
```

### GROUP_CONCAT

```sql
-- MySQL
SELECT dept_id, GROUP_CONCAT(emp_name SEPARATOR ', ') as employees
FROM employees
GROUP BY dept_id;

-- Vertica (use LISTAGG)
SELECT dept_id, LISTAGG(emp_name::VARCHAR) as employees
FROM employees
GROUP BY dept_id;
```

## Stored Procedure Migration

### Variable Declaration Type Restrictions

Vertica PL/vSQL has the following restrictions on variable data types that differ from MySQL stored procedures:

| Restriction | MySQL | Vertica Workaround |
|-------------|-------|--------------------|
| `DECIMAL(p,s)` / `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` or `DECIMAL` without precision. Default is precision 37, scale 15. |
| `ENUM` type | ✅ Supported | Not supported. Use `VARCHAR` with a CHECK constraint. |
| `SET` type | ✅ Supported | Not supported. Use `VARCHAR` or a separate normalized table. |
| `JSON` type | ✅ Supported | Not supported. Use `LONG VARCHAR` or Flex Tables. |
| `GEOMETRY` / `POINT` / `LINESTRING` / `POLYGON` (spatial) | ✅ Supported | Not supported. Store as `VARCHAR` or `LONG VARBINARY`. |
| `TINYBLOB` / `MEDIUMBLOB` / `LONGBLOB` | ✅ Supported | Maps to `LONG VARBINARY`. |
| `TINYINT` | ✅ Supported | Maps to `TINYINT` (same name, same 8-byte integer in Vertica). |
| `YEAR` type | ✅ Supported | Not supported. Use `INTEGER` or `DATE`. |


### Critical Parameter Handling Rules

⚠️ **MOST IMPORTANT**: Never remove OUT/INOUT parameter keywords when migrating from MySQL!

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: Unlike MySQL, where OUT and INOUT parameters can modify the values of variables passed to stored procedures, Vertica's `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The original input variables remain unchanged.

**How it works in Vertica**:
- `CALL procedure_name(...)` returns a **single tuple (record)** containing all OUT/INOUT values
- Each column in the tuple is named after the corresponding OUT/INOUT parameter
- Use `var1, var2 := CALL proc(...)` to unpack the tuple's columns into variables by position
- The original variables passed to the procedure remain unchanged

**Migration Implication**: When converting MySQL stored procedures that rely on OUT parameters to modify calling variables, use tuple unpacking assignment (`var1, var2 := CALL proc(...)`) instead.

#### Parameter Mode Conversion Table

**Key Syntax Difference**: In MySQL, parameter modes (IN, OUT, INOUT) come **after** the parameter name. In Vertica, they come **before** the parameter name.

| MySQL Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|--------------|---------------------|-------------------|-------|
| `p_param IN VARCHAR` | `p_param VARCHAR` | `p_param VARCHAR` | IN is optional (default) |
| `p_param OUT INT` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT before name** |
| `p_param INOUT VARCHAR` | `p_param VARCHAR` | `INOUT p_param VARCHAR` | **Must keep INOUT before name** |

**Why this matters**: Removing OUT/INOUT keywords completely breaks the parameter passing mechanism and will cause runtime errors or incorrect behavior.

#### Migration Checklist for Parameters
- [ ] ✅ Preserve all OUT parameter keywords
- [ ] ✅ Preserve all INOUT parameter keywords
- [ ] ✅ IN keywords are optional (can be omitted)
- [ ] ✅ Test parameter passing with various data types
- [ ] ✅ Verify return value handling
- [ ] ✅ Understand that OUT/INOUT parameters don't modify original variables

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: MySQL supports default parameter values (e.g., `p_param INT DEFAULT 0`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% MySQL compatibility.

#### Best Practice: Procedure Overloading for Default Parameters

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**
> Procedure overloading in Vertica works by matching the **procedure name** plus the parameter signature (number, types, order). Every overloaded variant **must** share the identical procedure name — only the parameter list differs. Using different names defeats the purpose of overloading and breaks call compatibility.

```sql
-- MySQL Original with Default Parameters
CREATE PROCEDURE process_order(
    IN p_order_id INT,
    IN p_discount FLOAT DEFAULT 0.1,
    IN p_priority VARCHAR(20) DEFAULT 'NORMAL',
    IN p_notes VARCHAR(255) DEFAULT NULL
)
BEGIN
    -- Business logic
    SELECT CONCAT('Processing order ', p_order_id) AS message;
END;

-- Vertica Migration: Perfect MySQL Compatibility
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
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id INTEGER,
    p_discount FLOAT
) AS $$
BEGIN
    PERFORM CALL process_order(p_order_id, p_discount, 'NORMAL', NULL);
END;
$$;

-- Version 3: More parameters, remaining use defaults
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

#### 100% MySQL-Compatible Calling Patterns

```sql
-- All MySQL calling styles work perfectly without modification
CALL process_order(1001);                              -- All defaults: 0.1, 'NORMAL', NULL
CALL process_order(1001, 0.15);                       -- Partial: 0.15, 'NORMAL', NULL
CALL process_order(1001, 0.15, 'HIGH');              -- Partial: 0.15, 'HIGH', NULL
CALL process_order(1001, 0.15, 'HIGH', 'Urgent');    -- No defaults: all explicit
```

#### Default Parameter Migration Checklist

- [ ] **Create main procedure** with all parameters (no default syntax)
- [ ] **Create overloaded versions** for each combination of default parameters — ⚠️ **all with the SAME procedure name**
- [ ] **Call main procedure** from overloads with explicit default values
- [ ] **Test all calling patterns** to ensure MySQL compatibility
- [ ] **Document default values** in procedure comments

### Basic Procedure Structure

```sql
-- MySQL
DELIMITER //
CREATE PROCEDURE GetEmployeeCount(IN dept_id INT, OUT emp_count INT)
BEGIN
    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE department_id = dept_id;
END //
DELIMITER ;

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

### Transaction Handling

```sql
-- MySQL
START TRANSACTION;
    UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    
    -- Error handling in application layer

-- Vertica
BEGIN
    PERFORM UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
    PERFORM UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
    
    EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
```

### Error Handling

```sql
-- MySQL
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    RESIGNAL;
END;

-- Vertica (directly use SQLSTATE and SQLERRM variables)
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
```

### Cursors

```sql
-- MySQL
DECLARE emp_cursor CURSOR FOR SELECT emp_id, salary FROM employees;
OPEN emp_cursor;
FETCH emp_cursor INTO emp_id_var, salary_var;
CLOSE emp_cursor;

-- Vertica (convert to set-based operations when possible)
-- For cases where cursor is necessary:
DECLARE
    CURSOR emp_cursor IS SELECT emp_id, salary FROM employees;
BEGIN
    FOR emp_record IN emp_cursor LOOP
        -- Process each record
    END LOOP;
END;
```

### Dynamic SQL Execution

```sql
-- MySQL: Execute dynamic SQL and assign result to variable
SET @sql = CONCAT('SELECT COUNT(*) INTO @cnt FROM ', table_name);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Vertica: Execute dynamic SQL and assign result to variable
DO $$
DECLARE
    table_name VARCHAR(100) := 'employees';
    row_count INTEGER;
BEGIN
    row_count := EXECUTE 'SELECT COUNT(*) FROM ' || table_name;
    RAISE NOTICE 'Count: %', row_count;
END
$$;
```

## Function Migration Strategies

MySQL stored functions can be migrated to Vertica using multiple approaches. The choice depends on the function's complexity, performance requirements, and usage patterns.

### Strategy 1: SQL Function to Subquery Conversion (Performance-Optimized)

For MySQL SQL functions that can be expressed as a query and are used in SELECT statements, convert them to subqueries with LEFT JOIN for better performance in Vertica's columnar architecture.

```sql
-- MySQL Stored Function and Query
CREATE FUNCTION is_active_user(user_id INT) RETURNS TINYINT
READS SQL DATA
BEGIN
    DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count FROM active_users u WHERE u.id = user_id;
    IF (user_count > 0) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;

SELECT id, name, is_active_user(id) AS is_active FROM users;

-- Vertica Migration: Convert to LEFT JOIN subquery
SELECT u.id, u.name,
  (CASE WHEN au.id IS NOT NULL THEN 1 ELSE 0 END) AS is_active
FROM users u LEFT JOIN active_users au ON u.id = au.id;
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

MySQL stored functions can be effectively migrated to Vertica stored procedures by converting the return value to an additional OUT parameter. This approach maintains MySQL-like semantics while leveraging Vertica's stored procedure capabilities.

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
-- MySQL Function
CREATE FUNCTION get_company_name() RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE company_name VARCHAR(100);
    SELECT name INTO company_name FROM companies WHERE id = 1;
    RETURN company_name;
END;

-- Usage in MySQL
SET @name = get_company_name();

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_company_name(
    OUT rt VARCHAR(100)
) AS $$
BEGIN
    SELECT name INTO rt FROM companies WHERE id = 1;
END;
$$;

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
    company_name VARCHAR(100);
BEGIN
    company_name := CALL get_company_name();
    RAISE INFO 'Company: %', company_name;
END
$$;
```

##### Pattern 2: Function with Input Parameters

```sql
-- MySQL Function
CREATE FUNCTION get_employee_name(emp_id INT) RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE emp_name VARCHAR(100);
    SELECT name INTO emp_name FROM employees WHERE id = emp_id;
    RETURN emp_name;
END;

-- Usage in MySQL
SET @name = get_employee_name(1001);

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_employee_name(
    p_emp_id INTEGER,
    OUT rt VARCHAR(100)
) AS $$
BEGIN
    SELECT name INTO rt FROM employees WHERE id = p_emp_id;
END;
$$;

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
    emp_name VARCHAR(100);
BEGIN
    emp_name := CALL get_employee_name(1001);
    RAISE INFO 'Employee: %', emp_name;
END
$$;
```

##### Pattern 3: Complex Function with Multiple Return Values

```sql
-- MySQL Function (returns result set)
CREATE FUNCTION get_dept_stats(dept_id INT)
RETURNS TABLE(emp_count INT, avg_salary DECIMAL(10,2))
READS SQL DATA
BEGIN
    RETURN (
        SELECT COUNT(*), AVG(salary)
        FROM employees
        WHERE department_id = dept_id
    );
END;

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE get_dept_stats(
    p_dept_id INTEGER,
    OUT emp_count INTEGER,
    OUT avg_salary NUMERIC(10,2)
) AS $$
BEGIN
    SELECT COUNT(*), AVG(salary)
    INTO emp_count, avg_salary
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
    v_count INTEGER;
    v_avg NUMERIC;
BEGIN
    v_count, v_avg := CALL get_dept_stats(10);
    RAISE INFO 'Count: %, Avg: %', v_count, v_avg;
END
$$;
```

#### Key Benefits of Stored Procedure Approach

1. **MySQL-like Semantics**: Maintains familiar variable assignment patterns
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
-- MySQL
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
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
-- MySQL
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Vertica (same syntax)
CREATE TABLE orders (
    order_id IDENTITY PRIMARY KEY,
    customer_id INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Unique Constraints

```sql
-- MySQL
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE
);

-- Vertica (same syntax)
CREATE TABLE products (
    product_id IDENTITY PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE
);
```

### Foreign Key Constraint Limitations

**Critical Limitation**: Vertica does NOT support `ON DELETE CASCADE` for foreign key constraints, which is a key difference from MySQL.

```sql
-- MySQL table with ON DELETE CASCADE
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Vertica migration (ON DELETE CASCADE removed and commented)
CREATE TABLE orders (
    order_id IDENTITY PRIMARY KEY,
    customer_id INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    -- ON DELETE CASCADE (Vertica does not support this option)
);
```

**Alternative Solutions for Cascade Delete**:
1. **Stored Procedures**: Create procedures to handle cascade deletes manually
2. **Application Logic**: Implement cascade logic in application code

### Indexes

**Don't use MySQL-style indexing** - Just comment them out

## Common Migration Challenges

### 0. Identifier Case Sensitivity

**Difference**: MySQL identifier case sensitivity depends on the **operating system** and `lower_case_table_names` setting (Linux: typically case-sensitive; Windows: case-insensitive). Vertica identifiers are **always case-insensitive**, whether quoted or not.

**Impact**: Objects that differ only by case on a Linux MySQL instance will **conflict** in Vertica. Conversely, case differences that were silently collapsed on Windows MySQL may behave differently.

**Solution**: Audit for identifiers that differ only by case and rename them. Adopt a consistent `snake_case` naming convention. Use backticks (MySQL) → double quotes (Vertica) if quoting is needed.

```sql
-- MySQL (Linux): these can be two different objects
CREATE TABLE MyTable (id INT);
CREATE TABLE mytable (id INT);

-- Vertica: the second CREATE will fail — rename one
CREATE TABLE MyTable (id INT);
CREATE TABLE my_table (id INT);  -- renamed to avoid conflict
```

### 1. AUTO_INCREMENT vs IDENTITY
**Challenge**: MySQL AUTO_INCREMENT vs Vertica IDENTITY
**Solution**: Convert to IDENTITY or AUTO_INCREMENT (both are equivalent in Vertica)

Vertica's `IDENTITY` and `AUTO_INCREMENT` are **synonyms** — they produce identical behavior. `IDENTITY` is the Vertica-native keyword; `AUTO_INCREMENT` is supported for MySQL compatibility.

```sql
-- MySQL
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100)
);

-- Vertica (both syntaxes are equivalent)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,          -- Vertica-native syntax
    emp_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id AUTO_INCREMENT PRIMARY KEY,  -- MySQL-compatible syntax
    customer_id INTEGER
);
```

**Key differences from MySQL:**
- MySQL `AUTO_INCREMENT` is a column attribute; Vertica `IDENTITY`/`AUTO_INCREMENT` is a column constraint
- MySQL allows only one AUTO_INCREMENT column per table; same in Vertica
- MySQL AUTO_INCREMENT is transactional (InnoDB); Vertica IDENTITY is **not** — gaps can occur
- Vertica IDENTITY has a default cache of 250,000 values per node for MPP performance; MySQL has no equivalent cache concept

### 2. Storage Engines
**Challenge**: MySQL storage engines (InnoDB, MyISAM) don't exist in Vertica
**Solution**: Vertica uses columnar storage by default

```sql
-- MySQL (storage engine specification)
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100)
) ENGINE=InnoDB;

-- Vertica (no engine specification needed)
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    emp_name VARCHAR(100)
);
```

### 3. FULLTEXT Indexes
**Challenge**: MySQL FULLTEXT indexes for text search
**Solution**: Use application-level search or external search engines

```sql
-- MySQL
SELECT * FROM articles
WHERE MATCH(content) AGAINST('search term');

-- Vertica (use LIKE or external search)
SELECT * FROM articles
WHERE content ILIKE '%search term%';
```

### 4. ENUM and SET Types
**Challenge**: MySQL ENUM and SET types
**Solution**: Convert to VARCHAR with check constraints

```sql
-- MySQL
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('active', 'inactive', 'terminated')
);

-- Vertica
CREATE TABLE employees (
    emp_id IDENTITY PRIMARY KEY,
    status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'terminated'))
);
```

### 5. JSON Functions
**Challenge**: MySQL JSON functions
**Solution**: Store as text and parse in application layer

```sql
-- MySQL
SELECT JSON_EXTRACT(data, '$.name') as name
FROM json_table;

-- Vertica (store as text, parse externally)
SELECT 
    REGEXP_SUBSTR(data, '"name":"([^"]*)"', 1, 1, '', 1) as name
FROM json_table;
```

### 6. Sequence Handling

```sql
-- MySQL sequences (MySQL 8.0+)
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
INSERT INTO employees (id, name) VALUES (NEXTVAL(emp_seq), 'John');

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

### 7. Stored Functions vs Procedures
**Challenge**: MySQL stored functions return values
**Solution**: Use Vertica procedures with OUT parameters

```sql
-- MySQL
CREATE FUNCTION get_employee_count(dept_id INT) RETURNS INT
READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*) FROM employees WHERE department_id = dept_id);
END;

-- Vertica
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

### 8. Recursive CTE Migration

**Challenge**: MySQL 8.0+ supports standard `WITH RECURSIVE` CTEs, but with significant syntax and behavioral differences from Vertica. Note that MySQL versions **before 8.0 do not support recursive CTEs at all** — hierarchical data was typically handled via application logic, stored procedures, or the nested set model.

#### Key Differences at a Glance

| Feature | MySQL 8.0+ | Vertica |
|---------|-----------|---------|
| `WITH RECURSIVE` syntax | ✅ Standard | ✅ Standard (identical) |
| Default recursion depth | **1000** (`cte_max_recursion_depth`) | **8** (`WithClauseRecursionLimit`) |
| `UNION` vs `UNION ALL` | Both supported | Both supported |
| `*` in anchor term | ✅ Allowed | ❌ **Not allowed** |
| Multiple CTE references in recursive term | ✅ Allowed | ❌ **Only 1 reference** |
| Outer join in recursive term | ✅ Allowed | ❌ **Not allowed** |
| Subquery referencing CTE in recursive term | ✅ Allowed | ❌ **Not allowed** |
| `LIMIT` inside recursive term | ✅ Allowed | ❌ **Not allowed** inside UNION |
| Cycle detection | ❌ No built-in | ❌ No built-in |
| **INSERT + CTE order** | **`WITH` before INSERT**: `WITH cte AS (...) INSERT INTO t SELECT ...` | **`INSERT` before WITH**: `INSERT INTO t WITH cte AS (...) SELECT ...` |

#### Critical: INSERT + CTE Syntax Order Is Reversed

**This is a key syntactic difference that affects every CTE used with INSERT.** In MySQL, the `WITH` clause comes *before* `INSERT`. In Vertica, `INSERT` comes *before* `WITH`:

```sql
-- ❌ MySQL syntax (fails in Vertica)
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
-- ❌ MySQL: WITH before INSERT
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

MySQL's default recursion depth is **1000**, far higher than Vertica's default of **8**. Queries that work in MySQL may be silently truncated in Vertica.

```sql
-- MySQL: default cte_max_recursion_depth = 1000
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
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 1000;

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

> **Note for pre-MySQL 8.0**: If the source database is MySQL 5.7 or earlier, recursive CTEs were not supported. Hierarchical queries were typically implemented via:
> - **Stored procedures** with loops — rewrite as `WITH RECURSIVE`
> - **Nested set model** (left/right values) — rewrite as `WITH RECURSIVE`
> - **Adjacency list with application-side recursion** — rewrite as `WITH RECURSIVE`
>
> All of these patterns can be replaced with standard `WITH RECURSIVE` in Vertica.

#### Non-Recursive Term Cannot Use `*`

```sql
-- ❌ MySQL allows, but Vertica does NOT
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
-- ❌ MySQL: multiple CTE references in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM cte a JOIN cte b ON a.id = b.parent_id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ MySQL: outer join in recursive term
WITH RECURSIVE cte AS (
    SELECT ... UNION ALL
    SELECT ... FROM employees e
    LEFT JOIN cte ON e.manager_id = cte.id  -- ERROR in Vertica
)
SELECT * FROM cte;

-- ❌ MySQL: subquery referencing CTE in recursive term
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

#### MySQL `LIMIT` in Recursive Term

MySQL allows `LIMIT` inside the recursive part of a CTE. Vertica does not allow `LIMIT` or `ORDER BY` inside the UNION:

```sql
-- ❌ MySQL: LIMIT in recursive term
WITH RECURSIVE cte AS (
    SELECT id, name, 1 AS level FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.name, c.level + 1
    FROM nodes n
    JOIN cte c ON n.parent_id = c.id
    LIMIT 100  -- ERROR in Vertica
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

**MySQL** uses `SELECT col INTO @var FROM cte` (with `INTO` between `SELECT` and `FROM`) or `SELECT @var := col FROM cte` to assign CTE results to variables. **Vertica PL/vSQL** uses a different syntax: `var := WITH cte AS (...) SELECT ...`, where the entire `WITH ... SELECT` is the expression being assigned. Parentheses are optional:

```sql
-- ✅ MySQL syntax 1: SELECT col INTO @var
WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
SELECT cnt INTO @count FROM cte;

-- ✅ MySQL syntax 2: SELECT @var := col
WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
SELECT @count := cnt FROM cte;

-- ❌ These MySQL syntaxes do NOT work in Vertica

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
**Problem**: `p_count OUT INT` becomes `p_count INTEGER`
**Solution**: Always preserve OUT/INOUT: `OUT p_count INTEGER`

#### Error: Incorrect data type for parameters
**Problem**: `NUMERIC` type used as parameter
**Solution**: Use `INTEGER` or `FLOAT` instead

#### Error: Missing parameter mode specification
**Problem**: `INOUT` parameters converted to plain parameters
**Solution**: Always specify `INOUT` for bidirectional parameters

#### Error: Incorrect exception handling
**Problem**: Using source database error handling syntax (e.g., `RESIGNAL`, `GET STACKED DIAGNOSTICS`) without adaptation
**Solution**: In Vertica, use `SQLSTATE` and `SQLERRM` directly for basic error info. For detailed info, use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT`, `COLUMN_NAME`, `CONSTRAINT_NAME`, `TABLE_NAME`, `SCHEMA_NAME`

## MySQL to Vertica Migration Checklist

### 🚨 Critical Parameter Handling

See the [Generic Migration Guide — Critical Parameter Handling](generic-migration-guide.md#-critical-parameter-handling) for the common checklist items. Add MySQL-specific items here when needed.

### 📋 General Migration Checklist

See the [Generic Migration Guide — General Migration Checklist](generic-migration-guide.md#-general-migration-checklist) for the common checklist items. The following MySQL-specific items also apply:

- [ ] `BEGIN...END` blocks converted to `AS $$...$$` delimiters
- [ ] `DELIMITER` statements removed (not needed in Vertica)

### 🚫 Critical "Never" Rules

<!-- Add MySQL-specific "Never" rules here when needed. -->

This comprehensive guide covers the essential aspects of migrating from MySQL to Vertica, focusing on practical conversion strategies and performance optimization techniques.
