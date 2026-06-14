# Oracle Migration Guide - Summary

> **This is an agent-optimized summary of [oracle-migration.md](../oracle-migration.md).** This summary contains ALL information needed for Oracle-to-Vertica migration decisions. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **NEVER remove OUT/INOUT keywords** from procedure parameters | Runtime failures |
| 2 | **ALWAYS use PERFORM** to discard output for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE | Syntax errors |
| 3 | **ALWAYS use GET STACKED DIAGNOSTICS** for detailed error info | Incomplete error handling |
| 4 | **ALWAYS use FOUND** to check if DML affected rows | Incorrect logic |
| 5 | **NEVER use SQL%ROWCOUNT** — use FOUND or separate COUNT query | Syntax errors |
| 6 | **ALWAYS use SYSDATE()** instead of SYSDATE (with parentheses) | Syntax errors |
| 7 | **ALWAYS use RAISE EXCEPTION** with SQLERRM and SQLSTATE | Incomplete error handling |

### Common Pitfalls
- Oracle `NUMBER(p,s)` in DECLARE → Vertica `NUMERIC` (without precision, default 37,15)
- Oracle `%ROWTYPE` → Not supported, declare individual variables with `%TYPE`
- Oracle `GEOMETRY`/`GEOGRAPHY` → Not supported, store as VARCHAR
- Oracle `VARRAY`, nested tables → Not supported, normalize into separate tables
- Oracle `ON DELETE CASCADE` → Not supported, comment out
- Oracle `PIVOT`/`UNPIVOT` → Not supported, rewrite with CASE + aggregate
- Oracle `CONNECT BY` → Rewrite as `WITH RECURSIVE`
- Oracle `INSERT` with `RETURNING` → Use separate INSERT + SELECT
- Oracle `FOR UPDATE` → Not supported in Vertica
- Oracle `ROWNUM` → Use `LIMIT`
- Oracle `DUAL` table → Not needed in Vertica
- Oracle `DBMS_OUTPUT.PUT_LINE` → Use `RAISE NOTICE`
- Oracle `SQL%ROWCOUNT` → Use `FOUND` or separate COUNT query

---

## Data Type Mapping: Oracle → Vertica

### Numeric Types (Precision-Based Selection)
| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| `NUMBER(1-9)` | `INTEGER` | 8 bytes in Vertica (4-byte in Oracle) |
| `NUMBER(10-18)` | `BIGINT` | 8-byte integer |
| `NUMBER(>18)` | `NUMBER(p,s)` or `NUMERIC(p,s)` | Variable precision |
| `NUMBER(p,s)` | `NUMERIC(p,s)` | Use NUMERIC for precision |
| `NUMBER` | `NUMERIC(38, 10)` | Default precision |
| `FLOAT` | `DOUBLE PRECISION` | 8-byte floating point |

### Character Types
| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| `VARCHAR2(n)` | `VARCHAR2(n)` or `VARCHAR(n)` | Same functionality |
| `NVARCHAR2(n)` | `VARCHAR(n)` | Vertica uses UTF-8 |
| `CHAR(n)` | `CHAR(n)` | Fixed length |
| `CLOB` | `LONG VARCHAR` | Max 32MB |
| `NCLOB` | `LONG VARCHAR` | Vertica uses UTF-8 |

### Date/Time & Binary Types
| Oracle Type | Vertica Type | Notes |
|-------------|--------------|-------|
| `DATE` | `TIMESTAMP` | Oracle DATE includes time |
| `TIMESTAMP` | `TIMESTAMP` | Direct mapping |
| `TIMESTAMP WITH TIME ZONE` | `TIMESTAMPTZ` | Direct mapping |
| `BOOLEAN` | `BOOLEAN` | Direct mapping (Vertica 9.3+) |
| `RAW(n)` | `VARBINARY(n)` | Direct mapping |
| `BLOB` | `LONG VARBINARY` | Max 32MB |

---

## SQL Syntax Conversion

### Left/Right Outer Join
```sql
-- Oracle: (+) syntax
SELECT * FROM employees e, departments d WHERE e.dept_id = d.dept_id(+);

-- Vertica: explicit LEFT JOIN
SELECT * FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

### INSERT + CTE Syntax Order (CRITICAL)
**Oracle**: `WITH ... INSERT` → **Vertica**: `INSERT ... WITH` (reversed order)
```sql
-- ❌ Oracle syntax (fails in Vertica)
WITH cte AS (...) INSERT INTO table SELECT ... FROM cte;

-- ✅ Vertica syntax
INSERT INTO table WITH cte AS (...) SELECT ... FROM cte;
```

### PIVOT/UNPIVOT Migration
- **UNPIVOT** → `UNION ALL` (few columns) or `CROSS JOIN + CASE` (many columns)
- **PIVOT** → `CASE + aggregate` with `GROUP BY`

### CONNECT BY → WITH RECURSIVE Mapping
| Oracle | Vertica |
|--------|---------|
| `START WITH condition` | Anchor term `WHERE condition` |
| `CONNECT BY PRIOR child = parent` | Recursive term `JOIN cte ON ...` |
| `LEVEL` | Manual counter: `1 AS level` → `eh.level + 1` |
| `SYS_CONNECT_BY_PATH(col, sep)` | Manual string: `path \|\| sep \|\| col` |
| `CONNECT_BY_ROOT col` | Carry anchor value through recursion |
| `NOCYCLE` | Manual depth limit: `WHERE level < 50` |
| `ORDER SIBLINGS BY col` | Final `ORDER BY path` |

### CTE Variable Assignment (CRITICAL)
**Oracle**: `SELECT ... INTO var FROM cte` → **Vertica**: `var := WITH cte AS (...) SELECT ...`
```sql
-- ✅ Oracle PL/SQL
WITH cte AS (SELECT COUNT(*) AS cnt FROM employees) SELECT cnt INTO v_count FROM cte;

-- ✅ Vertica PL/vSQL
v_count := WITH cte AS (SELECT COUNT(*) AS cnt FROM employees) SELECT cnt FROM cte;
```

---

## PL/SQL to PL/vSQL Conversion

### MUST Rules
- Use `AS $$` instead of `AS` for procedure/function body
- Use `END;` instead of `END proc_name;`
- Use `LANGUAGE plvsql` (optional, default)
- Use `DECLARE` block for all variables
- Use `PERFORM` for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE when not capturing output
- Use `var := SQL_STATEMENT` or `var <- SQL_STATEMENT` or `SELECT ... INTO var` or `EXECUTE ... INTO var` to capture output
- Use `FOUND` special variable to check if DML affected rows
- Use `SQLSTATE` and `SQLERRM` directly for basic error info
- Use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` for detailed error info

### Variable Declaration Type Restrictions

| Restriction | Oracle | Vertica Workaround |
|-------------|--------|--------------------|
| `NUMBER(p,s)` / `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` without precision. Default is precision 37, scale 15. |
| `%ROWTYPE` for cursor record variables | ✅ Supported | Not supported. Declare individual variables with `%TYPE` instead. |
| `GEOMETRY` / `GEOGRAPHY` types | ✅ Supported | Not supported. Store as VARCHAR or use multiple scalar variables. |
| Complex types (VARRAY, nested tables) | ✅ Supported | Not supported. Normalize into separate tables or use VARCHAR. |

### Parameter Mode Conversion

**Key Syntax Difference**: In Oracle, parameter modes (IN, OUT, INOUT) come **after** the parameter name. In Vertica, they come **before** the parameter name.

| Oracle Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|---------------|---------------------|-------------------|-------|
| `p_param IN VARCHAR2` | `p_param VARCHAR` | `p_param VARCHAR` | IN is optional (default) |
| `p_param OUT NUMBER` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT before name** |
| `p_param IN OUT VARCHAR2` | `p_param VARCHAR` | `INOUT p_param VARCHAR` | **Must keep INOUT before name** |

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: Unlike Oracle, where OUT and INOUT parameters modify variables by reference, Vertica's `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. Use `var1, var2 := CALL proc(...)` to unpack the tuple. The original input variables remain unchanged.

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: Oracle supports default parameter values (e.g., `p_param IN VARCHAR2 DEFAULT 'value'`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% Oracle compatibility.

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**

### Cursor Handling
```sql
-- Oracle: explicit cursor with OPEN/FETCH/CLOSE
DECLARE
    CURSOR emp_cursor IS SELECT employee_id, salary FROM employees WHERE department_id = 10;
    emp_record emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO emp_record;
        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;
    CLOSE emp_cursor;
END;

-- Vertica: FOR loop with CURSOR (simpler)
CREATE OR REPLACE PROCEDURE process_employees()
AS $$
DECLARE
    emp_cursor CURSOR FOR SELECT employee_id, salary FROM employees WHERE department_id = 10;
    v_employee_id INT;
    v_salary DECIMAL;
BEGIN
    FOR v_employee_id, v_salary IN CURSOR emp_cursor LOOP
    END LOOP;
END;
$$;
```

### Dynamic SQL Execution
```sql
-- Oracle
execute immediate 'select to_char(' || sequenceName || '.nextval) from dual' into sequenceNo;

-- Vertica
sequenceNo := EXECUTE 'select to_char(' || sequenceName || '.nextval)';
```

---

## Common Oracle Functions → Vertica

| Oracle | Vertica | Notes |
|--------|---------|-------|
| `NVL(a, b)` | `COALESCE(a, b)` | Direct replacement |
| `NVL2(a, b, c)` | `CASE WHEN a IS NOT NULL THEN b ELSE c END` | Use CASE |
| `DECODE(a, b, c, d)` | `CASE WHEN a = b THEN c ELSE d END` | Use CASE |
| `SYSDATE` | `CURRENT_DATE` | Direct replacement |
| `SYSTIMESTAMP` | `CURRENT_TIMESTAMP` | Direct replacement |
| `ADD_MONTHS(d, n)` | `ADD_MONTHS(d, n)` | Direct mapping |
| `MONTHS_BETWEEN(d1, d2)` | `MONTHS_BETWEEN(d1, d2)` | Direct mapping |
| `NEXT_DAY(d, day)` | `NEXT_DAY(d, day)` | Direct mapping |
| `LAST_DAY(d)` | `LAST_DAY(d)` | Direct mapping |
| `TRUNC(d, fmt)` | `TRUNC(d, fmt)` | Direct mapping |
| `ROUND(d, fmt)` | `ROUND(d, fmt)` | Direct mapping |
| `INSTR(str, sub)` | `INSTR(str, sub)` | Direct mapping |
| `SUBSTR(str, n, m)` | `SUBSTR(str, n, m)` | Direct mapping |
| `LENGTH(str)` | `LENGTH(str)` | Direct mapping |
| `UPPER(str)` | `UPPER(str)` | Direct mapping |
| `LOWER(str)` | `LOWER(str)` | Direct mapping |
| `TRIM(str)` | `TRIM(str)` | Direct mapping |
| `REPLACE(str, old, new)` | `REPLACE(str, old, new)` | Direct mapping |
| `TO_CHAR(d, fmt)` | `TO_CHAR(d, fmt)` | Direct mapping |
| `TO_DATE(str, fmt)` | `TO_DATE(str, fmt)` | Direct mapping |
| `TO_NUMBER(str, fmt)` | `TO_NUMBER(str, fmt)` | Direct mapping |

---

## Exception Handling

### MUST Rules
- Use `SQLSTATE` and `SQLERRM` directly for basic error info
- Use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` for detailed info
- Use `RAISE EXCEPTION` with format strings: `RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;`
- Use `WHEN OTHERS THEN` for catch-all handler

### Exception Handling Examples
```sql
-- Simple cases: use SQLSTATE/SQLERRM directly
-- Oracle: DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
-- Vertica:
EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE NOTICE 'No data found';
    WHEN TOO_MANY_ROWS THEN RAISE NOTICE 'Too many rows';
    WHEN OTHERS THEN RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;

-- Detailed error info: use GET STACKED DIAGNOSTICS
EXCEPTION
    WHEN OTHERS THEN
        DECLARE v_msg VARCHAR; v_detail VARCHAR; v_hint VARCHAR; v_context VARCHAR;
        BEGIN
            GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT, v_detail = DETAIL_TEXT,
                                   v_hint = HINT_TEXT, v_context = EXCEPTION_CONTEXT;
            RAISE EXCEPTION 'Error: %, Detail: %, Hint: %, Context: %', v_msg, v_detail, v_hint, v_context;
        END;
```

---

## Function Migration Strategies

| Function Type | Recommended Strategy | Rationale |
|---------------|---------------------|-----------|
| Table lookup functions | Subquery with LEFT JOIN | Better performance, set-based processing |
| Complex business logic | Stored Procedure with OUT | Maintains procedural logic, easier migration |
| Mathematical calculations | User-Defined SQL Function | Simple conversion, inline execution |
| Multi-statement functions | Stored Procedure with OUT | Preserves logic flow, error handling |
| Functions in WHERE clauses | Subquery or CASE expressions | Enables query optimization |

---

## Package Migration

Oracle packages combine related procedures and functions. In Vertica, convert to individual procedures/functions:

### MUST Rules
- Convert each package procedure to a standalone procedure
- Convert each package function to a standalone function or procedure with OUT parameter
- Use schema to group related objects (e.g., `my_package.proc1` → `CREATE PROCEDURE my_package.proc1()`)
- Package-level variables → Use session-level temporary tables or application context
- Package initialization code → Use separate initialization procedure

### Tuple Unpacking Assignment
When a stored procedure has OUT or INOUT parameters, `CALL` returns a **single tuple (record)**. Use `:=` to unpack:
```sql
var_return := CALL procedure_name([params]);              -- single OUT → scalar
var_out1, var_out2, var_return := CALL procedure_name([params]);  -- multiple OUTs → unpack
```

---

## Sequence Migration

| Oracle | Vertica |
|--------|---------|
| `seq_name.NEXTVAL` | `NEXTVAL('seq_name')` |
| `seq_name.CURRVAL` | `CURRVAL('seq_name')` |
| `NOCACHE` | `NO CACHE` |
| `NOCYCLE` | `NO CYCLE` |

---

## ROWNUM → LIMIT

### Oracle
```sql
SELECT * FROM employees WHERE ROWNUM <= 10;
```

### Vertica
```sql
SELECT * FROM employees LIMIT 10;
```

---

## DUAL Table

### Oracle
```sql
SELECT SYSDATE FROM dual;
SELECT 1 + 1 FROM dual;
```

### Vertica
```sql
SELECT SYSDATE;
SELECT 1 + 1;
-- No DUAL table needed
```

---

## Identifier Case Sensitivity

**Oracle**: Unquoted identifiers are case-insensitive (folded to uppercase); quoted identifiers are case-sensitive.
**Vertica**: Identifiers are **always case-insensitive** (quoted or unquoted).

**Impact**: Objects differing only by case in Oracle (e.g., `"MyTable"` vs `"mytable"`) will **conflict** in Vertica.
**Solution**: Audit and rename before migration. Adopt consistent naming convention (e.g., `snake_case`).

---

## Common Migration Errors

| Error | Cause | Solution |
|-------|-------|----------|
| Parameter keywords removed | `p_tax OUT NUMBER` → `p_tax INTEGER` | Always preserve OUT/INOUT: `OUT p_tax INTEGER` |
| Incorrect data type for parameters | `NUMERIC` type as parameter | Use `INTEGER` or `FLOAT` instead |
| Missing parameter mode | `INOUT` → plain parameter | Always specify `INOUT` for bidirectional parameters |
| Incorrect exception handling | Using Oracle syntax directly | Use `SQLSTATE`/`SQLERRM` directly; `GET STACKED DIAGNOSTICS` for details |

---

## MERGE Statement

**Key Difference**: Oracle uses `SET t.value = s.value` (table alias required), Vertica uses `SET value = s.value` (no alias).
```sql
-- Oracle
MERGE INTO target_table t USING source_table s ON (t.id = s.id)
WHEN MATCHED THEN UPDATE SET t.value = s.value
WHEN NOT MATCHED THEN INSERT (id, value) VALUES (s.id, s.value);

-- Vertica (remove table alias in SET)
MERGE INTO target_table t USING source_table s ON t.id = s.id
WHEN MATCHED THEN UPDATE SET value = s.value
WHEN NOT MATCHED THEN INSERT (id, value) VALUES (s.id, s.value);
```

---

## When to Load Full Document

This summary contains ALL information needed for Oracle-to-Vertica migration decisions. The full document is for human reference with detailed examples.

**For complete examples and rationale, see [oracle-migration.md](../oracle-migration.md).**
