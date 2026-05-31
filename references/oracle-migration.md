# Oracle to Vertica Migration Guide

This guide provides comprehensive guidance for migrating Oracle databases to Vertica, including SQL syntax conversion, PL/SQL to PL/vSQL migration, and performance optimization strategies.

## 🚨 CRITICAL: MANDATORY COMPLIANCE REQUIREMENTS

**BEFORE STARTING ANY ORACLE MIGRATION, YOU MUST READ AND FOLLOW THE [GENERIC MIGRATION GUIDE](generic-migration-guide.md)**

This Oracle migration guide **MUST BE USED IN CONJUNCTION WITH** the [Generic Migration Guide](generic-migration-guide.md). The generic guide contains **MANDATORY PROCEDURES** that apply to ALL database migrations, including:

- ✅ **COMPLETE migration** of ALL objects (no selective migration allowed)
- ✅ **SEQUENTIAL processing** in exact source file order (no reordering)
- ✅ **ONE-TO-ONE conversion** (tables→tables, procedures→procedures, etc.)
- ✅ **INDIVIDUAL testing** of every object before considering it migrated
- ✅ **NO automated scripts** or bulk processing
- ✅ **PRESERVATION** of all sequences, and dependencies

**FAILURE TO FOLLOW THE GENERIC MIGRATION GUIDE WILL RESULT IN FAILED MIGRATIONS.**

## Function Migration Strategies Overview

This guide covers multiple Oracle function migration approaches:

1. **SQL Function to Subquery Conversion** - For functions used in SELECT statements, convert to LEFT JOIN subqueries for optimal performance
2. **Function to Stored Procedure** - Convert return values to OUT parameters for procedural logic
3. **User-Defined SQL Functions** - For simple transformations that can be expressed in SQL
4. **UDx Development** - For complex logic requiring C++, Python, Java, or R


## SQL Syntax Conversion

### Left Outer Join

```sql
-- Oracle
SELECT * FROM employees e, departments d
WHERE e.dept_id = d.dept_id(+);

-- Vertica (explicit LEFT JOIN)
SELECT * FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

### Right Outer Join

```sql
-- Oracle
SELECT * FROM employees e, departments d
WHERE e.dept_id(+) = d.dept_id;

-- Vertica (explicit RIGHT JOIN)
SELECT * FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```

## Data Type Mappings

### Numeric Types

| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| NUMBER(1-9) | INTEGER | **8 bytes** in Vertica (4-byte integer in Oracle) |
| NUMBER(10-18) | BIGINT | 8-byte integer |
| NUMBER(>18) | NUMBER(p,s), or NUMERIC(p,s) | Variable precision |
| NUMBER(p,s) | NUMBER(p,s), or NUMERIC(p,s) | Same precision/scale |
| FLOAT | DOUBLE PRECISION | 8-byte floating point |

### Character Types

| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| VARCHAR2(n) | VARCHAR2(n), or VARCHAR(n) | Same functionality |
| CHAR(n) | CHAR(n) | Fixed length |
| CLOB | LONG VARCHAR | Up to 32MB |
| NCLOB | LONG VARCHAR | Vertica is Unicode by default |

### Date/Time Types

| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| DATE | TIMESTAMP | Includes time component |
| TIMESTAMP | TIMESTAMP | Same precision |
| TIMESTAMP WITH TIME ZONE | TIMESTAMP WITH TIME ZONE | Timezone support |

### Binary Types

| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| RAW(n) | VARBINARY(n) | Binary data |
| BLOB | LONG VARBINARY | Large binary objects |

## Function Conversions

### String Functions

```sql

```

### Date Functions

```sql

```

### Aggregate Functions

```sql
-- Oracle MEDIAN
SELECT MEDIAN(salary) FROM employees;

-- Vertica MEDIAN (analytic function)
SELECT MEDIAN(salary) OVER ()
FROM employees;

-- Oracle LISTAGG
SELECT LISTAGG(name, ', ') WITHIN GROUP (ORDER BY name)
FROM departments;

-- Vertica LISTAGG
SELECT LISTAGG(name USING PARAMETERS separator=', ') FROM departments;
```

## PL/SQL to PL/vSQL Migration

### Variable Declaration Type Restrictions

Vertica PL/vSQL has the following restrictions on variable data types that differ from Oracle PL/SQL:

| Restriction | Oracle | Vertica Workaround |
|-------------|--------|--------------------|
| `NUMBER(p,s)` / `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` without precision. Default is precision 37, scale 15. |
| `DECIMAL(p,s)` with precision in DECLARE | ✅ Supported | Declare as `DECIMAL` (same as NUMERIC). |
| `%ROWTYPE` for cursor record variables | ✅ Supported | Not supported. Declare individual variables with `%TYPE` instead. |
| `GEOMETRY` / `GEOGRAPHY` types | ✅ Supported | Not supported. Store as VARCHAR or use multiple scalar variables. |
| Complex types (VARRAY, nested tables) | ✅ Supported | Not supported. Normalize into separate tables or use VARCHAR. |


### Critical Parameter Handling Rules

⚠️ **MOST IMPORTANT**: Never remove OUT/INOUT parameter keywords when migrating from Oracle!

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: Unlike Oracle, where OUT and INOUT parameters modify variables by reference, Vertica's `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. Use `var1, var2 := CALL proc(...)` to unpack the tuple. The original input variables remain unchanged.

**How it works in Vertica**:
- `CALL procedure_name(...)` returns a **single tuple (record)** containing all OUT/INOUT values
- Each column in the tuple is named after the corresponding OUT/INOUT parameter
- Use `var1, var2 := CALL proc(...)` to unpack the tuple's columns into variables by position
- The original variables passed to the procedure remain unchanged

**Migration Implication**: When converting Oracle PL/SQL that relies on OUT parameters to modify calling variables, use tuple unpacking assignment (`var1, var2 := CALL proc(...)`) instead.

#### Parameter Mode Conversion Table

**Key Syntax Difference**: In Oracle, parameter modes (IN, OUT, INOUT) come **after** the parameter name. In Vertica, they come **before** the parameter name.

| Oracle Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|---------------|---------------------|-------------------|-------|
| `p_param IN VARCHAR2` | `p_param VARCHAR` | `p_param VARCHAR` | IN is optional (default) |
| `p_param OUT NUMBER` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT before name** |
| `p_param IN OUT VARCHAR2` | `p_param VARCHAR` | `INOUT p_param VARCHAR` | **Must keep INOUT before name** |

**Why this matters**: Removing OUT/INOUT keywords completely breaks the parameter passing mechanism and will cause runtime errors or incorrect behavior.

**Important Behavior Difference**: In Vertica, `CALL` returns a **single tuple (record)** for OUT/INOUT parameters. These values do NOT modify the original input variables by reference as Oracle does. Use tuple unpacking (`var1, var2 := CALL proc(...)`) to capture the returned values.

#### Migration Checklist for Parameters
- [ ] ✅ Preserve all OUT parameter keywords
- [ ] ✅ Preserve all INOUT parameter keywords  
- [ ] ✅ IN keywords are optional (can be omitted)
- [ ] ✅ Test parameter passing with various data types
- [ ] ✅ Verify return value handling
- [ ] ✅ Understand that OUT/INOUT parameters don't modify original variables

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: Oracle supports default parameter values (e.g., `p_param IN VARCHAR2 DEFAULT 'value'`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% Oracle compatibility.

#### Best Practice: Procedure Overloading for Default Parameters

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**
> Procedure overloading in Vertica works by matching the **procedure name** plus the parameter signature (number, types, order). Every overloaded variant **must** share the identical procedure name — only the parameter list differs. Using different names defeats the purpose of overloading and breaks call compatibility.

```sql
-- Oracle Original with Default Parameters
CREATE OR REPLACE PROCEDURE process_order(
    p_order_id IN NUMBER,
    p_discount IN NUMBER DEFAULT 0.1,
    p_priority IN VARCHAR2 DEFAULT 'NORMAL',
    p_notes IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    -- Business logic
    DBMS_OUTPUT.PUT_LINE('Processing order ' || p_order_id);
END;
/

-- Vertica Migration: Perfect Oracle Compatibility
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

#### 100% Oracle-Compatible Calling Patterns

```sql
-- All Oracle calling styles work perfectly without modification
CALL process_order(1001);                              -- All defaults: 0.1, 'NORMAL', NULL
CALL process_order(1001, 0.15);                       -- Partial: 0.15, 'NORMAL', NULL
CALL process_order(1001, 0.15, 'HIGH');              -- Partial: 0.15, 'HIGH', NULL
CALL process_order(1001, 0.15, 'HIGH', 'Urgent');    -- No defaults: all explicit

-- Explicit NULLs also work correctly (passed to main procedure)
CALL process_order(1001, NULL, NULL, NULL);          -- All NULLs
```

#### Key Advantages of This Approach

✅ **Perfect Compatibility** - Every Oracle call pattern works unchanged  
✅ **Correct NULL Handling** - Explicit NULLs vs defaults are properly distinguished  
✅ **Maintainable** - Business logic exists only in main procedure  
✅ **Zero Performance Impact** - Overloaded calls have minimal overhead  
✅ **Future-Proof** - Easy to modify default values in one place  

#### Default Parameter Migration Checklist

- [ ] **Create main procedure** with all parameters (no default syntax)
- [ ] **Create overloaded versions** for each combination of default parameters — ⚠️ **all with the SAME procedure name**
- [ ] **Call main procedure** from overloads with explicit default values
- [ ] **Test all calling patterns** to ensure Oracle compatibility
- [ ] **Document default values** in procedure comments
- [ ] **Handle complex defaults** like `SYSDATE`, expressions correctly

#### Complex Default Value Example

```sql
-- Oracle: Complex default expressions
CREATE PROCEDURE generate_report(
    p_start_date DATE DEFAULT TRUNC(SYSDATE) - 30,
    p_end_date DATE DEFAULT TRUNC(SYSDATE),
    p_format VARCHAR2 DEFAULT 'PDF',
    p_include_details NUMBER DEFAULT 1
) AS ...

-- Vertica: Perfect migration with complex defaults
-- ⚠️  Both procedures use the SAME name: generate_report (overloaded by parameter count)
CREATE OR REPLACE PROCEDURE generate_report(
    p_start_date TIMESTAMP,
    p_end_date TIMESTAMP,
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
        TRUNC(SYSDATE()) - 30,  -- Default start date
        TRUNC(SYSDATE()),       -- Default end date
        'PDF',                  -- Default format
        1                       -- Default include details
    );
END;
$$;
```

### Basic Procedure Structure

```sql
-- Oracle PL/SQL
CREATE OR REPLACE PROCEDURE update_salaries (
    p_dept_id IN NUMBER,
    p_increase_pct IN NUMBER
) AS
    v_count NUMBER;
BEGIN
    UPDATE employees 
    SET salary = salary * (1 + p_increase_pct/100)
    WHERE department_id = p_dept_id;
    
    v_count := SQL%ROWCOUNT;
    
    INSERT INTO salary_audit 
    VALUES (p_dept_id, p_increase_pct, v_count, SYSDATE);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Vertica PL/vSQL
CREATE OR REPLACE PROCEDURE update_salaries (
    p_dept_id INTEGER,           -- IN is optional (default)
    p_increase_pct NUMERIC       -- IN is optional (default)
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
    VALUES (p_dept_id, p_increase_pct, v_count, SYSDATE());
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;
```

### Cursor Handling

```sql
-- Oracle explicit cursor
DECLARE
    CURSOR emp_cursor IS 
        SELECT employee_id, salary FROM employees WHERE department_id = 10;
    emp_record emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO emp_record;
        EXIT WHEN emp_cursor%NOTFOUND;
        -- Process record
        DBMS_OUTPUT.PUT_LINE(emp_record.employee_id || ': ' || emp_record.salary);
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

### Dynamic SQL Execution

```sql
-- Oracle: Execute dynamic SQL and assign result to variable
DECLARE
    sequenceName VARCHAR2(100) := 'EMP_SEQ';
    sequenceNo VARCHAR2(100);
BEGIN
    execute immediate 'select to_char(' || sequenceName || '.nextval) from dual' into sequenceNo;
    DBMS_OUTPUT.PUT_LINE('Sequence value: ' || sequenceNo);
END;
/

-- Vertica: Execute dynamic SQL and assign result to variable
DO $$
DECLARE
    sequenceName VARCHAR(100) := 'EMP_SEQ';
    sequenceNo VARCHAR(100);
BEGIN
    sequenceNo := EXECUTE 'select to_char(' || sequenceName || '.nextval)';
    RAISE NOTICE 'Sequence value: %', sequenceNo;
END
$$;
```

### Exception Handling

```sql
-- Oracle
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Too many rows');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);

-- Vertica (directly use SQLSTATE and SQLERRM variables)
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No data found';
    WHEN TOO_MANY_ROWS THEN
        RAISE NOTICE 'Too many rows';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
```

## Function Migration Strategies

Oracle functions can be migrated to Vertica using multiple approaches. The choice depends on the function's complexity, performance requirements, and usage patterns.

### Strategy 1: SQL Function to Subquery Conversion (Performance-Optimized)

For Oracle SQL functions that can be expressed as a query and are used in SELECT statements, convert them to subqueries with LEFT JOIN for better performance in Vertica's columnar architecture.

```sql
-- Oracle SQL Function and Query
CREATE OR REPLACE FUNCTION ISYSZ(rydm IN VARCHAR2)
RETURN VARCHAR2
IS
  rynum INTEGER;
BEGIN
  SELECT COUNT(*) INTO rynum FROM qx_user u WHERE u.czry_dm = rydm;
  IF (rynum > 0) THEN
    RETURN '1';
  ELSE
    RETURN '0';
  END IF;
END ISYSZ;
/

SELECT czry_dm, czry_mc, isysz(czry_dm) AS isysz
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

Oracle functions can be effectively migrated to Vertica stored procedures by converting the return value to an additional OUT parameter. This approach maintains Oracle-like semantics while leveraging Vertica's stored procedure capabilities.

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
-- Oracle Function
CREATE OR REPLACE FUNCTION F_GET_JDH()
RETURN VARCHAR2 IS
  jdno VARCHAR2(100);
BEGIN
    select CSNR into jdno from XT_XTCS where CSXH = '10001' and JG_DM='PUBLIC';

    return jdno;
END;
/

-- Usage in Oracle PL/SQL
DECLARE
  jdno VARCHAR2(100);
BEGIN
	jdno := F_GET_JDH();
	dbms_output.put_line('jdno: %'||jdno);
END;
/

-- Vertica Stored Procedure
CREATE OR REPLACE PROCEDURE F_GET_JDH(
  OUT rt VARCHAR(100)
) AS $$
BEGIN
  SELECT CSNR INTO rt FROM XT_XTCS WHERE CSXH = '10001' AND JG_DM = 'PUBLIC';
END;
$$;

-- Usage in Vertica PL/vSQL
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
-- Oracle Function
CREATE OR REPLACE FUNCTION F_GET_JD_DM(
  ac_fjd_dm VARCHAR2,
  ac_jd_mc VARCHAR2
) RETURN VARCHAR2 IS
  jdno VARCHAR2(30);
BEGIN
  SELECT JD_DM INTO jdno FROM QX_GNMK_TREE
  WHERE FJD_DM = ac_fjd_dm AND JD_MC = ac_jd_mc;
  RETURN jdno;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/

-- Usage in Oracle PL/SQL
DECLARE
  jdno VARCHAR2(30);
BEGIN
	jdno := F_GET_JD_DM('0', '系统设置');
	dbms_output.put_line('jdno: %'||jdno); 
END;
/

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

-- Usage in Vertica PL/vSQL
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
-- Oracle Function
CREATE OR REPLACE FUNCTION get_employee_stats(
  p_dept_id NUMBER
) RETURN SYS_REFCURSOR IS
  emp_cursor SYS_REFCURSOR;
BEGIN
  OPEN emp_cursor FOR
    SELECT COUNT(*) as emp_count,
           AVG(salary) as avg_salary,
           MAX(salary) as max_salary
    FROM employees
    WHERE department_id = p_dept_id;
  RETURN emp_cursor;
END;
/

-- Usage in Oracle PL/SQL
DECLARE
  emp_cursor SYS_REFCURSOR;
  v_count INTEGER;
  v_avg NUMERIC;
  v_max NUMERIC;
BEGIN
emp_cursor := get_employee_stats(10);

LOOP
  FETCH emp_cursor INTO v_count, v_avg, v_max;
  EXIT WHEN emp_cursor%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE('Count: '|| v_count || ', Avg: '|| v_avg || ', Max: '|| v_max);
END LOOP;

CLOSE emp_cursor;
END;
/

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

-- Usage in Vertica PL/vSQL
DO $$
DECLARE
  v_count INTEGER;
  v_avg NUMERIC;
  v_max NUMERIC;
BEGIN
  -- Multiple OUT parameters assignment
  v_count, v_avg, v_max := CALL get_employee_stats(10);
  RAISE INFO 'Count: %, Avg: %, Max: %', v_count, v_avg, v_max;
END
$$;
```

#### Key Benefits of Stored Procedure Approach

1. **Oracle-like Semantics**: Maintains familiar variable assignment patterns
2. **Multiple Return Values**: Supports both OUT parameters and return values
3. **Error Handling**: Enables robust error checking and exception handling
4. **Code Reusability**: Procedures can call other procedures seamlessly
5. **Type Safety**: Compile-time type checking for parameters

### Function Migration Best Practices

**For Subquery Conversion:**
1. **Analyze JOIN cardinality**: Ensure the LEFT JOIN doesn't create performance issues
2. **Test with NULL handling**: Verify behavior matches original function logic
4. **Monitor query plans**: Use EXPLAIN to verify optimal execution

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

### Converting Oracle Packages

Oracle packages need to be converted to individual procedures/functions in Vertica:

```sql
-- Oracle Package
CREATE OR REPLACE PACKAGE employee_mgmt AS
    PROCEDURE hire_employee(
        p_name IN VARCHAR2,
        p_dept_id IN NUMBER,
        p_salary IN NUMBER
    );
    
    FUNCTION get_employee_count(p_dept_id IN NUMBER) RETURN NUMBER;
    
    PROCEDURE terminate_employee(p_emp_id IN NUMBER);
END employee_mgmt;
/

-- Vertica (separate procedures)
CREATE OR REPLACE PROCEDURE hire_employee(
    p_name VARCHAR,
    p_dept_id INTEGER,
    p_salary INTEGER
) AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    INSERT INTO employees (name, department_id, salary, hire_date)
    VALUES (p_name, p_dept_id, p_salary, SYSDATE());
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
    SET termination_date = SYSDATE(), status = 'TERMINATED'
    WHERE employee_id = p_emp_id;
END;
$$;
```

## Common Migration Challenges

### 0. Identifier Case Sensitivity

**Difference**: Oracle unquoted identifiers are case-insensitive (folded to uppercase); quoted identifiers (`"..."`) are case-sensitive. Vertica identifiers are **always case-insensitive**, whether quoted or not.

**Impact**: Objects that differ only by case in Oracle (e.g., `"MyTable"` vs `"mytable"`) will **conflict** in Vertica.

**Solution**: Before migration, audit for identifiers that differ only by case and rename them. Adopt a consistent naming convention (e.g., `snake_case`). Avoid quoted identifiers unless necessary.

```sql
-- Oracle: these are two different objects
CREATE TABLE "MyTable" (id INT);
CREATE TABLE "mytable" (id INT);

-- Vertica: the second CREATE will fail — rename one
CREATE TABLE MyTable (id INT);
CREATE TABLE my_table (id INT);  -- renamed to avoid conflict
```

### 1. Sequence Handling

```sql
-- Oracle sequences
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
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

**Critical Limitation**: Vertica does NOT support `ON DELETE CASCADE` for foreign key constraints, which is a key difference from Oracle.

```sql
-- Oracle table with ON DELETE CASCADE
CREATE TABLE SYSTEM_PERMISSIONS (
    PERMISSION_CODE VARCHAR2(256) NOT NULL,
    PERMISSION_NAME VARCHAR2(120) DEFAULT 'DEFAULT_PERM' NOT NULL,
    MODULE_CODE VARCHAR2(256) NOT NULL,
    DESCRIPTION VARCHAR2(256),
    ACTIVE_FLAG CHAR(1) DEFAULT 'Y' NOT NULL,
    PROCESS_TYPE VARCHAR2(16) DEFAULT '00' NOT NULL,
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

### 3. PIVOT and UNPIVOT Migration

Vertica does **not** support Oracle's `PIVOT` or `UNPIVOT` operators. Rewrite them using standard SQL constructs.

#### UNPIVOT → UNION ALL or CROSS JOIN + CASE

```sql
-- Oracle: UNPIVOT
SELECT product_id, month, sales
FROM sales_data
UNPIVOT (
    sales FOR month IN (jan, feb, mar, apr)
) AS unpvt;

-- Vertica Method 1: UNION ALL (recommended for few columns)
SELECT product_id, 'jan' AS month, jan AS sales FROM sales_data
UNION ALL
SELECT product_id, 'feb' AS month, feb AS sales FROM sales_data
UNION ALL
SELECT product_id, 'mar' AS month, mar AS sales FROM sales_data
UNION ALL
SELECT product_id, 'apr' AS month, apr AS sales FROM sales_data;

-- Vertica Method 2: CROSS JOIN + CASE (better for many columns)
SELECT s.product_id
     , m.month
     , CASE m.month
         WHEN 'jan' THEN s.jan
         WHEN 'feb' THEN s.feb
         WHEN 'mar' THEN s.mar
         WHEN 'apr' THEN s.apr
       END AS sales
FROM sales_data s
CROSS JOIN (
    SELECT 'jan' AS month UNION ALL
    SELECT 'feb' UNION ALL
    SELECT 'mar' UNION ALL
    SELECT 'apr'
) m;
```

#### PIVOT → CASE + Aggregate

```sql
-- Oracle: PIVOT
SELECT *
FROM sales_data
PIVOT (
    SUM(sales) FOR month IN ('jan', 'feb', 'mar', 'apr')
) AS pvt;

-- Vertica: CASE + aggregate
SELECT product_id
     , SUM(CASE WHEN month = 'jan' THEN sales END) AS jan
     , SUM(CASE WHEN month = 'feb' THEN sales END) AS feb
     , SUM(CASE WHEN month = 'mar' THEN sales END) AS mar
     , SUM(CASE WHEN month = 'apr' THEN sales END) AS apr
FROM sales_data
GROUP BY product_id;
```

**Choosing UNPIVOT method**:

| Method | Best for | Pros | Cons |
|--------|----------|------|------|
| `UNION ALL` | Few columns (< 10) | Simple, readable | Verbose with many columns |
| `CROSS JOIN + CASE` | Many columns (10+) | Concise, single scan | Slightly more complex |

**Notes**:
- `UNION ALL` preserves duplicate rows (matching `UNPIVOT` behavior)
- `PIVOT` with `SUM/COUNT/AVG` maps directly to `CASE + GROUP BY`
- For dynamic pivot columns (unknown at design time), use a stored procedure to generate the SQL

### 4. Recursive CTE Migration: CONNECT BY to WITH RECURSIVE

**This is the most significant hierarchical query difference.** Oracle's `CONNECT BY` syntax has **no direct equivalent** in Vertica. You must manually rewrite all hierarchical queries as `WITH RECURSIVE` CTEs.

#### Syntax Mapping Overview

| Oracle CONNECT BY | Vertica WITH RECURSIVE |
|-------------------|----------------------|
| `START WITH condition` | Non-recursive term (anchor) `WHERE condition` |
| `CONNECT BY PRIOR child = parent` | Recursive term `JOIN cte ON ...` |
| `LEVEL` | Manual counter column: `1 AS level` → `eh.level + 1` |
| `SYS_CONNECT_BY_PATH(col, sep)` | Manual string aggregation: `path \|\| sep \|\| col` |
| `CONNECT_BY_ROOT col` | Pass anchor value through each recursion level |
| `NOCYCLE` | ❌ No equivalent — add manual depth limit |
| `ORDER SIBLINGS BY col` | Final `ORDER BY path` |

#### Basic CONNECT BY → WITH RECURSIVE Conversion

```sql
-- ❌ Oracle: CONNECT BY
SELECT employee_id, manager_id, name, LEVEL,
       SYS_CONNECT_BY_PATH(name, '/') AS path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- ✅ Vertica: WITH RECURSIVE
WITH RECURSIVE emp_hierarchy AS (
    -- Anchor: top-level managers (START WITH equivalent)
    SELECT employee_id, manager_id, name,
           1 AS level,
           '/' || name AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: direct reports (CONNECT BY PRIOR equivalent)
    SELECT e.employee_id, e.manager_id, e.name,
           eh.level + 1,
           eh.path || '/' || e.name
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT employee_id, manager_id, name, level, path
FROM emp_hierarchy;
```

#### INSERT + CTE Syntax Order Is Reversed

**This is a key syntactic difference that affects every CTE used with INSERT.** In Oracle, the `WITH` clause comes *before* `INSERT`. In Vertica, `INSERT` comes *before* `WITH`:

```sql
-- ❌ Oracle syntax (fails in Vertica)
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
-- ❌ Oracle: WITH before INSERT (recursive CTE)
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

#### CONNECT BY with NOCYCLE

Oracle's `NOCYCLE` prevents infinite loops from circular references. Vertica has **no `CYCLE` clause**. Add a manual depth guard:

```sql
-- ❌ Oracle: NOCYCLE
SELECT employee_id, name, LEVEL
FROM employees
START WITH employee_id = 1
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;

-- ✅ Vertica: manual depth limit in recursive term
WITH RECURSIVE emp_chain AS (
    SELECT employee_id, name, 1 AS level
    FROM employees
    WHERE employee_id = 1

    UNION ALL

    SELECT e.employee_id, name, ec.level + 1
    FROM employees e
    JOIN emp_chain ec ON e.manager_id = ec.employee_id
    WHERE ec.level < 50   -- manual guard against infinite recursion
)
SELECT employee_id, name, level FROM emp_chain;
```

> **Important**: Also set `WithClauseRecursionLimit` appropriately:
> ```sql
> ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 100;
> ```

#### CONNECT_BY_ROOT (Top-Level Value Propagation)

```sql
-- ❌ Oracle: CONNECT_BY_ROOT
SELECT employee_id, name,
       CONNECT_BY_ROOT name AS top_manager
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- ✅ Vertica: carry anchor value through recursion
WITH RECURSIVE emp_tree AS (
    SELECT employee_id, name, name AS top_manager
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, name, et.top_manager
    FROM employees e
    JOIN emp_tree et ON e.manager_id = et.employee_id
)
SELECT employee_id, name, top_manager FROM emp_tree;
```

#### ORDER SIBLINGS BY → ORDER BY path

```sql
-- ❌ Oracle: ORDER SIBLINGS BY
SELECT employee_id, name, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY name;

-- ✅ Vertica: ORDER BY path (preserves sibling ordering)
WITH RECURSIVE emp_tree AS (
    SELECT employee_id, name, 1 AS level,
           '/' || LPAD(name, 50) AS sort_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, name, et.level + 1,
           et.sort_path || '/' || LPAD(e.name, 50)
    FROM employees e
    JOIN emp_tree et ON e.manager_id = et.employee_id
)
SELECT employee_id, name, level
FROM emp_tree
ORDER BY sort_path;
```

#### Vertica-Specific Restrictions to Remember

When rewriting Oracle CONNECT BY queries, watch for these Vertica recursive CTE limitations:

| Restriction | What to check |
|-------------|---------------|
| No `*` in anchor term | Explicitly list all columns |
| Recursive term can reference CTE only **once** | Cannot self-join the recursive CTE |
| No outer join in recursive term | Rewrite `LEFT JOIN` as `INNER JOIN` + post-processing |
| No subquery in recursive term | Rewrite subquery as a `JOIN` |
| `ORDER BY` / `LIMIT` not allowed inside UNION | Move to outer query |

#### CTE Variable Assignment in Stored Procedures

**Oracle PL/SQL** uses `SELECT ... INTO var FROM cte` to assign CTE results to variables — the `INTO` clause is placed between the select-list and the `FROM` clause. **Vertica PL/vSQL** uses a different syntax: `var := WITH cte AS (...) SELECT ...`, where the entire `WITH ... SELECT` is the expression being assigned. Parentheses are optional:

```sql
-- ✅ Oracle PL/SQL: SELECT ... INTO var (INTO between SELECT and FROM)
WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
SELECT cnt INTO v_count FROM cte;

-- ❌ This Oracle syntax does NOT work in Vertica

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

For recursive CTEs (rewritten from Oracle CONNECT BY), the same rules apply:

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

#### Performance Consideration: Materialization for Deep Hierarchies

If the hierarchy is deep (>20 levels), enable materialization to avoid query rewrite overhead:

```sql
-- Session-level
ALTER SESSION SET PARAMETER WithClauseMaterialization = 1;

-- Or query-level hint
WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ RECURSIVE
    emp_hierarchy AS (...)
SELECT * FROM emp_hierarchy;
```

## Common Migration Errors and Solutions

#### Error: Parameter keywords removed
**Problem**: `p_tax OUT NUMBER` becomes `p_tax INTEGER`
**Solution**: Always preserve OUT/INOUT: `OUT p_tax INTEGER`

#### Error: Incorrect data type for parameters  
**Problem**: `NUMERIC` type used as parameter
**Solution**: Use `INTEGER` or `FLOAT` instead

#### Error: Missing parameter mode specification
**Problem**: `INOUT` parameters converted to plain parameters
**Solution**: Always specify `INOUT` for bidirectional parameters

#### Error: Incorrect exception handling
**Problem**: Using source database error handling syntax (e.g., `SQLERRM`, `GET STACKED DIAGNOSTICS`) without adaptation
**Solution**: In Vertica, use `SQLSTATE` and `SQLERRM` directly for basic error info. For detailed info, use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT`, `COLUMN_NAME`, `CONSTRAINT_NAME`, `TABLE_NAME`, `SCHEMA_NAME`

## Oracle to Vertica Migration Checklist

### 🚨 Critical Parameter Handling

See the [Generic Migration Guide — Critical Parameter Handling](generic-migration-guide.md#-critical-parameter-handling) for the common checklist items. Add Oracle-specific items here when needed.

### 📋 General Migration Checklist

See the [Generic Migration Guide — General Migration Checklist](generic-migration-guide.md#-general-migration-checklist) for the common checklist items. The following Oracle-specific items also apply:

- [ ] `IS` changed to `AS $$`
- [ ] `END procedure_name;` changed to `END;`

### 🚫 Critical "Never" Rules

<!-- Add Oracle-specific "Never" rules here when needed. -->

This comprehensive guide provides the foundation for successful Oracle to Vertica migration, focusing on both syntax conversion and performance optimization.
