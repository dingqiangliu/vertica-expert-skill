# DB2 Migration Guide - Summary

> **This is an agent-optimized summary of [db2-migration.md](../db2-migration.md).** This summary contains ALL information needed for DB2-to-Vertica migration decisions. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **NEVER remove OUT/INOUT keywords** from procedure parameters | Runtime failures |
| 2 | **ALWAYS use PERFORM** to discard output for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE | Syntax errors |
| 3 | **ALWAYS use GET STACKED DIAGNOSTICS** for detailed error info | Incomplete error handling |
| 4 | **ALWAYS use FOUND** to check if DML affected rows | Incorrect logic |
| 5 | **ALWAYS use SQLSTATE/SQLERRM** for basic error info | Incomplete error handling |
| 6 | **ALWAYS use RAISE EXCEPTION** with format strings | Incomplete error handling |
| 7 | **ALWAYS use WITH RECURSIVE** for recursive CTEs (not just WITH) | Syntax errors |
| 8 | **ALWAYS increase WithClauseRecursionLimit** for deep hierarchies | Silent data truncation |
| 9 | **NEVER use DB2 special registers** (e.g., `CURRENT TIMESTAMP FROM sysibm.sysdummy1`) | Syntax errors |
| 10 | **NEVER use FETCH FIRST n ROWS ONLY** — use `LIMIT n` | Syntax errors |
| 11 | **NEVER use DECLARE HANDLER** — use EXCEPTION block | Syntax errors |
| 12 | **NEVER use DECLARE CONDITION** — use SQLSTATE directly in RAISE EXCEPTION | Syntax errors |

### Common Pitfalls (Additional to Critical Rules)
- DB2 `DECIMAL(p,s)` in DECLARE → Vertica `NUMERIC` without precision (default 37,15)
- DB2 `DECFLOAT`/`GRAPHIC`/`VARGRAPHIC`/`DBCLOB`/`XML`/`ROW` types → Not supported, use `DOUBLE PRECISION`/`VARCHAR`/`LONG VARCHAR`
- DB2 `ON DELETE CASCADE` → Not supported, comment out
- DB2 `PIVOT`/`UNPIVOT` → Not supported, rewrite with CASE + aggregate
- DB2 `CONNECT BY` → Rewrite as `WITH RECURSIVE`
- DB2 `CURRENT TIMESTAMP FROM sysibm.sysdummy1` → Use `NOW()` or `CURRENT_TIMESTAMP`
- DB2 `SQL%ROWCOUNT` → Use `FOUND` or separate COUNT query
- DB2 `INSERT` with `RETURNING` → Use separate INSERT + SELECT
- DB2 `DBMS_OUTPUT.PUT_LINE` → Use `RAISE NOTICE`
- DB2 `LIMIT` inside recursive CTE → Not allowed, move to outer query
- DB2 `CYCLE` clause → Not supported, use manual depth guard
- DB2 `SELECT ... INTO var FROM cte` → Vertica: `var := WITH cte AS (...) SELECT ...`

---

## Data Type Mapping

> **See [Data Type Mapping Guide](../data-type-mapping.md)** for complete data type mappings.
> Load on-demand: `grep -n "^## \|^### " references/data-type-mapping.md` → `Read offset=N limit=M`

---

## SQL Syntax Differences

### SELECT FIRST n ROWS
```sql
-- DB2
SELECT * FROM employees FETCH FIRST 10 ROWS ONLY;

-- Vertica
SELECT * FROM employees LIMIT 10;
```

## Function Conversions

> **See [Function Mapping Guide](../function-mapping.md)** for function conversions across databases.
> Load on-demand: `grep -n "^## \|^### " references/function-mapping.md` → `Read offset=N limit=M`

---

## Stored Procedure Conversion

### MUST Rules
- Use `AS $$` instead of `LANGUAGE SQL`
- Use `END;` instead of `END proc_name;`
- Remove `LANGUAGE SQL` (Vertica uses PL/vSQL by default)
- Use `DECLARE` block for all variables
- Use `PERFORM` for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE when not capturing output
- Use `var := SQL_STATEMENT` or `var <- SQL_STATEMENT` or `SELECT ... INTO var` or `EXECUTE ... INTO var` to capture output
- Use `FOUND` special variable to check if DML affected rows
- Use `SQLSTATE` and `SQLERRM` directly for basic error info
- Use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` for detailed error info

### Variable Declaration Type Restrictions

| Restriction | DB2 | Vertica Workaround |
|-------------|-----|--------------------|
| `DECIMAL(p,s)` / `NUMERIC(p,s)` with precision in DECLARE | ✅ Supported | Declare as `NUMERIC` or `DECIMAL` without precision. Default is precision 37, scale 15. |
| `DECFLOAT` type | ✅ Supported | Not supported. Use `DOUBLE PRECISION` or `NUMERIC` instead. |
| `GRAPHIC` / `VARGRAPHIC` / `DBCLOB` types | ✅ Supported | Not supported. Use `VARCHAR` instead. |
| `XML` type | ✅ Supported | Not supported. Use `LONG VARCHAR` or `LONG VARBINARY` instead. |
| `ROW` type (structured) | ✅ Supported | Not supported. Use individual scalar variables. |

### Parameter Mode Conversion (CRITICAL)

**Syntax Difference**: DB2 modes come **after** name; Vertica modes come **before** name.

| DB2 Syntax | ✅ Correct Vertica | Notes |
|------------|-------------------|-------|
| `p_param IN VARCHAR(50)` | `p_param VARCHAR` | IN optional (default) |
| `p_param OUT INTEGER` | `OUT p_param INTEGER` | **Must keep OUT** |
| `p_param INOUT VARCHAR(50)` | `INOUT p_param VARCHAR` | **Must keep INOUT** |

**OUT/INOUT Behavior**: Unlike DB2 (reference passing), Vertica `CALL` returns a **single tuple**. Use tuple unpacking: `var1, var2 := CALL proc(...)`. Original variables **remain unchanged**.

### Recursive CTE Limitations in Vertica

**Recursion Depth**: DB2 unlimited, **Vertica default 8**. Always increase:
```sql
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 100;
```

**Recursive Term Restrictions** (all ❌ in Vertica):
- Anchor term: cannot use `*` (explicit columns required)
- Only **1 CTE reference** allowed (no `JOIN cte a JOIN cte b`)
- No `LEFT JOIN cte` (outer join)
- No subquery referencing CTE (`WHERE id IN (SELECT id FROM cte)`)
- No `FETCH FIRST`/`LIMIT`/`ORDER BY` inside UNION

**CTE Variable Assignment**:
```sql
-- Vertica: var := WITH cte AS (...) SELECT ...
v_count := WITH cte AS (SELECT COUNT(*) cnt FROM employees) SELECT cnt FROM cte;
```

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: DB2 supports default parameter values (e.g., `p_param INTEGER DEFAULT 0`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% DB2 compatibility.

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**

### Exception Handling (CRITICAL)

DB2 SQL PL uses `DECLARE HANDLER` to define exception handlers within stored procedures. Vertica PL/vSQL does **not** support this syntax — instead, it uses an `EXCEPTION` block with `WHEN` clauses.

#### Handler Types Migration

| DB2 Handler | Behavior | Vertica Equivalent |
|-------------|----------|---------------------|
| `EXIT HANDLER` | Executes handler action, then **exits** the declaring BEGIN...END block | `EXCEPTION WHEN OTHERS THEN ...` (ends the block) |
| `CONTINUE HANDLER` | Executes handler action, then **continues** at the next statement | Check `FOUND` variable or use inner `EXCEPTION` block |
| `UNDO HANDLER` | **Rolls back** the entire ATOMIC block, then executes handler | Vertica's automatic transaction rollback on unhandled exceptions |

#### Named Conditions Migration

DB2 SQL PL allows defining **named conditions** that associate a user-friendly name with a specific SQLSTATE value. Vertica PL/vSQL does **not** support this feature.

| DB2 Feature | DB2 Syntax | Vertica Equivalent |
|-------------|-----------|---------------------|
| Declare named condition | `DECLARE name CONDITION FOR SQLSTATE 'xxxxx'` | **Not supported** — use `RAISE EXCEPTION SQLSTATE 'xxxxx'` directly |
| Raise named condition | `SIGNAL name SET MESSAGE_TEXT = '...'` | `RAISE EXCEPTION SQLSTATE 'xxxxx' USING MESSAGE = '...'` |
| Raise unnamed SQLSTATE | `SIGNAL SQLSTATE 'xxxxx' SET MESSAGE_TEXT = '...'` | `RAISE EXCEPTION SQLSTATE 'xxxxx' USING MESSAGE = '...'` |
| Re-raise current exception | `RESIGNAL` | `RAISE;` |
| Transform exception | `RESIGNAL other_name SET MESSAGE_TEXT = '...'` | `RAISE EXCEPTION SQLSTATE 'yyyyy' USING MESSAGE = '...'` |
| Handler for named condition | `DECLARE EXIT HANDLER FOR name` | `EXCEPTION WHEN SQLSTATE 'xxxxx' THEN` |

### Cursor Handling

**Recommended**: Use FOR loop (handles NOT FOUND automatically):
```sql
CREATE OR REPLACE PROCEDURE process_employees()
AS $$
DECLARE
    emp_cursor CURSOR FOR SELECT employee_id, salary FROM employees WHERE department_id = 10;
    v_employee_id INTEGER;
    v_salary NUMERIC;
BEGIN
    FOR v_employee_id, v_salary IN CURSOR emp_cursor LOOP
        -- Process record
    END LOOP;
END;
$$;
```

### Dynamic SQL Execution

**Key Difference**: DB2 uses `EXECUTE IMMEDIATE stmt INTO var`; Vertica uses `EXECUTE 'stmt' INTO var` (statement as string directly).

### Special Registers (sysibm.sysdummy1)

**DB2** uses `sysibm.sysdummy1` to query system information:
```sql
-- DB2
SELECT CURRENT SCHEMA FROM sysibm.sysdummy1;
SELECT CURRENT TIMESTAMP FROM sysibm.sysdummy1;
SELECT CURRENT DATE FROM sysibm.sysdummy1;
SELECT CURRENT TIME FROM sysibm.sysdummy1;
```

**Vertica** (no table needed):
```sql
-- Vertica
SELECT CURRENT_SCHEMA;
SELECT CURRENT_TIMESTAMP;
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
```

> **Note**: See [Function Mapping Guide](../function-mapping.md) for complete DB2 function mappings.

---

## Identity Columns

| DB2 | Vertica |
|-----|---------|
| `id INTEGER GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1)` | `id IDENTITY(1, 1)` |

---

## MQT → Live Aggregate Projections

| DB2 | Vertica |
|-----|---------|
| `CREATE TABLE ... AS (SELECT ... GROUP BY ...) DATA INITIALLY DEFERRED REFRESH DEFERRED` | `CREATE PROJECTION ... AS SELECT ... GROUP BY ... ORDER BY ...` |
| `REFRESH TABLE sales_summary` | Automatic refresh with Live Aggregate Projections |

---

## Identifier Case Sensitivity

**DB2**: Unquoted identifiers are **case-insensitive** (folded to uppercase); quoted identifiers (`"..."`) are **case-sensitive**.

**Vertica**: Identifiers are **always case-insensitive** (quoted or not).

**Impact**: Objects differing only by case in DB2 (e.g., `"MyTable"` vs `"mytable"`) will **conflict** in Vertica.

**Solution**: Audit for case-only-differing identifiers and rename them. Adopt consistent naming (e.g., `snake_case`). Remove unnecessary double quotes.

---

## Package/Module Migration

DB2 modules/packages must be converted to **individual procedures/functions** in Vertica:

```sql
-- DB2 Module
CREATE MODULE employee_mgmt;
ALTER MODULE employee_mgmt ADD PROCEDURE hire_employee(...);
ALTER MODULE employee_mgmt ADD FUNCTION get_employee_count(...) RETURNS INTEGER;

-- Vertica: Separate procedures
CREATE OR REPLACE PROCEDURE hire_employee(...) AS $$ ... $$;
CREATE OR REPLACE FUNCTION get_employee_count(p_dept_id INTEGER) RETURN INTEGER
AS BEGIN RETURN (SELECT COUNT(*) FROM employees WHERE department_id = p_dept_id); END;
```

---

## Function Migration Strategies

### Strategy 1: SQL Function → Subquery (Performance-Optimized)
For functions in SELECT that query other tables:
```sql
-- DB2: Function with table lookup
CREATE FUNCTION ISYSZ(rydm VARCHAR(50)) RETURNS VARCHAR(1) ...

-- Vertica: LEFT JOIN subquery
SELECT dm.czry_dm, dm.czry_mc,
       (CASE WHEN u.userid IS NOT NULL THEN '1' ELSE '0' END) AS isysz
FROM dm_czry dm LEFT JOIN qx_user u ON dm.czry_dm = u.czry_dm;
```

### Strategy 2: Function → Stored Procedure (OUT Parameter)
For complex logic:
```sql
-- DB2: CREATE FUNCTION ... RETURN value
-- Vertica: CREATE PROCEDURE ... (OUT rt VARCHAR)
-- Usage: jdno := CALL proc_name();
```

### Strategy Selection Guide
| Function Type | Recommended Strategy |
|---------------|---------------------|
| Table lookup functions | Subquery with LEFT JOIN |
| Complex business logic | Stored Procedure with OUT |
| Mathematical calculations | User-Defined SQL Function |
| Multi-statement functions | Stored Procedure with OUT |
| Functions in WHERE clauses | Subquery or CASE |

---

## Common Migration Errors

| Error | Cause | Solution |
|-------|-------|----------|
| Parameter keywords removed | `p_tax OUT DECIMAL` → `p_tax NUMERIC` | Always preserve OUT/INOUT: `OUT p_tax NUMERIC` |
| Incorrect data type | `DECIMAL` type as parameter | Use `NUMERIC` instead |
| DECLARE HANDLER not migrated | Using DB2 handler syntax | Use `EXCEPTION WHEN OTHERS THEN` |
| Named conditions not migrated | Using `DECLARE CONDITION` | Use SQLSTATE directly in `RAISE EXCEPTION` |
| Special registers not converted | `CURRENT TIMESTAMP FROM sysibm.sysdummy1` | Use `NOW()` or `CURRENT_TIMESTAMP` |
| FETCH FIRST not converted | Using `FETCH FIRST n ROWS ONLY` | Use `LIMIT n` |
| CTE recursion too deep | Default limit 8 in Vertica | `ALTER SESSION SET WithClauseRecursionLimit = N` |

---

## Migration Checklist

### Critical Parameter Handling
- [ ] ✅ Preserve all OUT/INOUT parameter keywords
- [ ] ✅ Test parameter passing with various data types
- [ ] ✅ Verify tuple unpacking assignment works correctly

### DB2-Specific Items
- [ ] `LANGUAGE SQL` removed
- [ ] `BEGIN` changed to `AS $$`
- [ ] `END proc_name;` changed to `END;`
- [ ] MQT converted to Live Aggregate Projections
- [ ] Modules/Packages converted to individual procedures/functions
- [ ] `DECLARE HANDLER` migrated to `EXCEPTION` blocks
- [ ] `GET DIAGNOSTICS CONDITION 1` → `GET STACKED DIAGNOSTICS`
- [ ] `SQLCODE` → `SQLSTATE`
- [ ] `SIGNAL name` → `RAISE EXCEPTION SQLSTATE 'xxxxx'`
- [ ] `RESIGNAL` → `RAISE;`
- [ ] Special registers converted (no `FROM sysibm.sysdummy1`)
- [ ] `FETCH FIRST` → `LIMIT`
- [ ] `ON DELETE CASCADE` removed and commented
- [ ] Recursive CTE depth limit increased if needed

### Critical "Never" Rules
- [ ] Never use DB2-specific syntax without conversion
- [ ] Never ignore DB2 modules/packages

---

## When to Load Full Document

Load [db2-migration.md](../db2-migration.md) section by section when:
- Summary rules require combination in ways not shown in examples
- Your migration produces TODOs, placeholders, or uncertain logic
- Test results show unexpected behavior
- The code pattern involves 3+ interacting SQL features

How to load: `grep -n "^## \|^### " references/db2-migration.md` → `Read offset=N limit=M` (load ONLY that section, NOT the entire file).
