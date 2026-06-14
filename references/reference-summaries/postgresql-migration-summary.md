# PostgreSQL Migration Guide - Summary

> **This is an agent-optimized summary of [postgresql-migration.md](../postgresql-migration.md).** This summary contains ALL information needed for PostgreSQL-to-Vertica migration decisions. The full document is for human reference with detailed examples.

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

### Common Pitfalls (22 items)
- `NUMERIC(p,s)` in DECLARE → `NUMERIC` (default 37,15)
- `%ROWTYPE` → Not supported, use `%TYPE` for individual variables
- `RECORD` type → Not supported, declare individual typed variables
- `REFCURSOR` → Use `refcursor` in DECLARE
- `TRIGGER` type → Not supported
- `ENUM` → Use `VARCHAR` + CHECK constraint
- `COMPOSITE` types → Not supported, use scalar variables
- `ARRAY` type variables → Not supported, use normalized tables
- `JSON`/`JSONB` → Use `LONG VARCHAR` or Flex Tables
- `GEOMETRY`/`GEOGRAPHY` → Store as `VARCHAR`
- `TSVECTOR`/`TSQUERY` → Use Vertica Text Index
- `ON DELETE CASCADE` → Not supported, comment out
- `DELETE ... USING` → Use `WHERE IN` or `WHERE EXISTS`
- `RETURN QUERY` → Use temp tables or cursors
- `GET DIAGNOSTICS ROW_COUNT` → Capture DML return directly
- `NULL` coerced to `FALSE` → Not by default, set `PLvSQLCoerceNull = 1`
- `FOR` loop → Requires keywords: `RANGE`, `QUERY`, `CURSOR`
- `INSERT` with `WITH` → `INSERT` before `WITH`
- `SELECT ... INTO var FROM cte` → `var := WITH cte AS (...) SELECT ...`
- `LIMIT` in recursive CTE → Not allowed, move to outer query
- `CYCLE` clause → Not supported, use manual depth guard
- `SEARCH DEPTH/BREADTH FIRST` → Not supported, use path column

### Recursive CTE Complete Limitations

| Feature | PostgreSQL | Vertica |
|---------|-----------|---------|
| Default recursion depth | **Unlimited** | **8** (`WithClauseRecursionLimit`) |
| `CYCLE` clause | ✅ Auto cycle detection | ❌ Not supported |
| `SEARCH DEPTH/BREADTH FIRST` | ✅ Supported | ❌ Not supported |
| Anchor uses `*` | ✅ Allowed | ❌ Not allowed, explicit columns required |
| Multiple CTE references in recursive term | ✅ Allowed | ❌ Only 1 reference allowed |
| Outer join in recursive term | ✅ Allowed | ❌ Not allowed |
| Subquery referencing CTE in recursive term | ✅ Allowed | ❌ Not allowed |
| `LIMIT`/`ORDER BY` in UNION | ✅ Allowed | ❌ Not allowed |
| **INSERT + CTE order** | `WITH` before `INSERT` | **`INSERT` before `WITH`** |

**Recursion depth setting**:
```sql
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 100;
```

**Manual cycle detection** (remove CYCLE, add `WHERE level < N`):
```sql
WITH RECURSIVE emp_chain AS (
    SELECT employee_id, name, 1 AS level FROM employees WHERE employee_id = 1
    UNION ALL
    SELECT e.employee_id, e.name, ec.level + 1
    FROM employees e JOIN emp_chain ec ON e.manager_id = ec.employee_id
    WHERE ec.level < 50  -- Manual cycle protection
)
SELECT employee_id, name, level FROM emp_chain;
```

**Deep recursion optimization** (>20 levels): `ALTER SESSION SET PARAMETER WithClauseMaterialization = 1;`

### CTE Variable Assignment in Stored Procedures

**PostgreSQL**: `SELECT ... INTO var FROM cte`  
**Vertica**: `var := WITH cte AS (...) SELECT ...`

```sql
-- ✅ Vertica: Direct assignment (recommended)
v_count := WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
            SELECT cnt FROM cte;

-- ✅ Vertica: SELECT INTO + subquery wrapper
SELECT COUNT(*) INTO v_count
FROM (WITH cte AS (SELECT * FROM employees) SELECT * FROM cte) t;
```

**Invalid syntax**: `SELECT ... INTO var WITH CTE ...` (without subquery wrapper)

---

## Data Type Mapping: PostgreSQL → Vertica

### Numeric Types (⚠️ Note storage size differences)

| PostgreSQL | Vertica | Size Difference | Notes |
|------------|---------|-----------------|-------|
| `SMALLINT` | `SMALLINT` | 2→8 bytes | Vertica uses 8 bytes uniformly |
| `INTEGER` | `INTEGER` | 4→8 bytes | Vertica uses 8 bytes uniformly |
| `BIGINT` | `BIGINT` | 8 bytes | Same |
| `NUMERIC(p,s)` | `NUMERIC(p,s)` | Same | Precision preserved |
| `DECIMAL(p,s)` | `NUMERIC(p,s)` | Same | Alias mapping |
| `REAL` | `REAL` | 4→8 bytes | Vertica uses 8 bytes uniformly |
| `DOUBLE PRECISION` | `DOUBLE PRECISION` | 8 bytes | Same |
| `FLOAT` | `DOUBLE PRECISION` | Same | Alias mapping |
| `SERIAL` | `IDENTITY` | - | Auto-increment integer |
| `BIGSERIAL` | `IDENTITY` | - | Auto-increment bigint |

### Character Types

| PostgreSQL | Vertica | Notes |
|------------|---------|-------|
| `VARCHAR(n)` | `VARCHAR(n)` | Max 65000 |
| `CHAR(n)` | `CHAR(n)` | Fixed length |
| `TEXT` | `LONG VARCHAR` | Max 32MB |
| `NAME` | `VARCHAR(64)` | PostgreSQL internal type |

### Date/Time Types

| PostgreSQL | Vertica | Notes |
|------------|---------|-------|
| `DATE` | `DATE` | Same |
| `TIME` | `TIME` | Same |
| `TIMESTAMP` | `TIMESTAMP` | Same |
| `TIMESTAMPTZ` | `TIMESTAMPTZ` | Store as UTC |
| `INTERVAL` | `INTERVAL` | Same |

### Binary & Other Types

| PostgreSQL | Vertica | Notes |
|------------|---------|-------|
| `BYTEA` | `LONG VARBINARY` | Max 32MB |
| `BOOLEAN` | `BOOLEAN` | Same |
| `UUID` | `VARCHAR(36)` | Store as string |
| `JSON` | `LONG VARCHAR` | Store as text |
| `JSONB` | `LONG VARBINARY` | Store as binary |
| `ARRAY` | `ARRAY` | Same |
| `INET` | `VARCHAR(45)` | Store as string |
| `CIDR` | `VARCHAR(49)` | Store as string |
| `MACADDR` | `VARCHAR(17)` | Store as string |
| `XML` | `LONG VARCHAR` | Store as text |
| `POINT` | `GEOMETRY` | Convert to spatial type |
| `LINE` | `GEOMETRY` | Convert to spatial type |
| `POLYGON` | `GEOMETRY` | Convert to spatial type |

### Special Functions

| PostgreSQL | Vertica | Notes |
|------------|---------|-------|
| `GENERATE_SERIES()` | `GENERATE_SERIES()` | Requires pgcompat package |

---

## SQL Syntax Differences

### DELETE with JOIN

**PostgreSQL** supports `DELETE ... USING`; **Vertica does not**. Use `WHERE IN` or `WHERE EXISTS`:
```sql
-- ✅ Vertica: Use WHERE IN
DELETE FROM orders WHERE customer_id IN (SELECT customer_id FROM customers_to_purge);
-- ✅ Vertica: Use WHERE EXISTS (usually faster)
DELETE FROM orders WHERE EXISTS (SELECT 1 FROM customers_to_purge p WHERE p.customer_id = orders.customer_id);
```

### INSERT + CTE Order Reversed

**PostgreSQL**: `WITH` before `INSERT`  
**Vertica**: `INSERT` before `WITH`
```sql
-- ✅ Vertica: INSERT before WITH
INSERT INTO t WITH cte AS (SELECT ...) SELECT * FROM cte;
```

### RETURNING Clause

Both support `RETURNING`, but Vertica requires OUT parameters in stored procedures to return results.

### Identifier Case Sensitivity

**PostgreSQL**: Unquoted identifiers case-insensitive; quoted identifiers case-sensitive  
**Vertica**: All identifiers always case-insensitive (quoted or not)

**Impact**: `"MyTable"` and `"mytable"` are different in PostgreSQL but conflict in Vertica  
**Solution**: Audit and rename case-only-differing identifiers; use consistent naming (e.g., `snake_case`); remove unnecessary quotes

---

## PL/pgSQL to PL/vSQL Conversion

### MUST Rules
- Use `AS $$` instead of `AS $$ LANGUAGE plpgsql`
- Use `RETURN type` instead of `RETURNS type`
- Remove `LANGUAGE plpgsql` (Vertica uses PL/vSQL by default)
- Use `DECLARE` block for all variables
- Use `PERFORM` for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE when not capturing output
- Use `var := SQL_STATEMENT` or `var <- SQL_STATEMENT` or `SELECT ... INTO var` or `EXECUTE ... INTO var` to capture output
- Use `FOUND` special variable to check if DML affected rows
- Use `SQLSTATE` and `SQLERRM` directly for basic error info
- Use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` for detailed error info

### Variable Declaration Type Restrictions

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

### Parameter Mode Conversion

**Key Syntax**: Both PostgreSQL and Vertica place parameter modes (IN, OUT, INOUT) **before** the parameter name. The syntax is the same in both systems — the critical rule is to **never remove** the OUT and INOUT keywords during migration.

| PostgreSQL Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|-------------------|---------------------|-------------------|-------|
| `IN p_param VARCHAR` | `p_param VARCHAR` | `p_param VARCHAR` | IN is optional (default) |
| `OUT p_param INTEGER` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT keyword** |
| `INOUT p_param VARCHAR` | `p_param VARCHAR` | `INOUT p_param VARCHAR` | **Must keep INOUT keyword** |

### OUT/INOUT Parameter Behavior in Vertica

**Key Behavioral Difference**: In PostgreSQL stored procedures, OUT and INOUT parameters modify the values of variables passed to procedures. In Vertica stored procedures, `CALL` returns a **single tuple (record)** — one row where each column corresponds to an OUT/INOUT parameter. The original input variables remain unchanged.

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: PostgreSQL supports default parameter values (e.g., `p_param VARCHAR DEFAULT 'value'`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% PostgreSQL compatibility.

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**

### PERFORM Statement Requirement

**PostgreSQL**: DDL and DML statements can be used directly in PL/pgSQL.
**Vertica**: Must use `PERFORM` to discard output (row counts, Tuples/Tuple, status messages) for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE and other SQL statements when not capturing return values.

### NULL Coercion Behavior

**PostgreSQL**: NULL coerced to FALSE  
**Vertica**: NULL not coercible to FALSE by default  
**Fix**: `ALTER DATABASE DEFAULT SET PLvSQLCoerceNull = 1;`

### FOR Loop Keywords

**PostgreSQL**: Standard FOR loops  
**Vertica**: Requires keywords: `RANGE`, `QUERY`, or `CURSOR`
```sql
FOR i IN RANGE 1..10 LOOP                     -- Range loop
FOR record IN QUERY SELECT * FROM table LOOP  -- Query loop
FOR record IN CURSOR cur LOOP                 -- Cursor loop
```

### DML Return Values

**PostgreSQL**: INSERT/UPDATE/DELETE return void  
**Vertica**: Returns affected row count (capture directly, no `GET DIAGNOSTICS` needed)
```sql
v_count := UPDATE customers SET status = 'active';
```

### Dynamic SQL Execution

**PostgreSQL**: `EXECUTE '...' INTO var`  
**Vertica**: `var := EXECUTE '...'`

### RETURN QUERY Pattern

**PostgreSQL**: `RETURN QUERY SELECT ...`  
**Vertica**: Use temp table or cursor
```sql
CREATE PROCEDURE get_high_paid(p_min_salary INTEGER) AS $$
BEGIN
    CREATE LOCAL TEMP TABLE result_employees ON COMMIT PRESERVE ROWS AS
    SELECT * FROM employees WHERE salary > p_min_salary;
END; $$;
```

### Sequence & Temporary Tables

| Feature | PostgreSQL | Vertica |
|---------|-----------|---------|
| Create sequence | `CREATE SEQUENCE seq_name ...` | Same |
| Next value | `NEXTVAL('seq_name')` | Same |
| Current value | `CURRVAL('seq_name')` | Same |
| Auto-increment | `SERIAL` / `BIGSERIAL` | `IDENTITY` |
| Temp table | `CREATE TEMP TABLE ...` | `CREATE LOCAL TEMP TABLE ...` |
| On commit drop | `ON COMMIT DROP` | `ON COMMIT DROP ROWS` |
| Preserve rows | `ON COMMIT PRESERVE ROWS` | Same |

**Sequence choice**: New tables → `IDENTITY`; preserve existing → `CREATE SEQUENCE`

### Error Handling and Exceptions

**Simple cases**: Use `SQLSTATE` and `SQLERRM` directly
```sql
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
```

**Detailed info**: Use `GET STACKED DIAGNOSTICS`
```sql
EXCEPTION WHEN OTHERS THEN
    DECLARE v_msg VARCHAR; v_detail VARCHAR; v_hint VARCHAR; v_context VARCHAR;
    BEGIN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT, v_detail = DETAIL_TEXT,
                                v_hint = HINT_TEXT, v_context = EXCEPTION_CONTEXT;
        RAISE EXCEPTION 'Error: %, Detail: %, Hint: %, Context: %', v_msg, v_detail, v_hint, v_context;
    END;
```

---

## Common PostgreSQL Functions → Vertica

| PostgreSQL | Vertica | Notes |
|------------|---------|-------|
| `COALESCE(a, b)` | `COALESCE(a, b)` | Direct mapping |
| `NULLIF(a, b)` | `NULLIF(a, b)` | Direct mapping |
| `GREATEST(a, b)` | `GREATEST(a, b)` | Direct mapping |
| `LEAST(a, b)` | `LEAST(a, b)` | Direct mapping |
| `CURRENT_DATE` | `CURRENT_DATE` | Direct mapping |
| `CURRENT_TIME` | `CURRENT_TIME` | Direct mapping |
| `CURRENT_TIMESTAMP` | `CURRENT_TIMESTAMP` | Direct mapping |
| `NOW()` | `CURRENT_TIMESTAMP` | Direct replacement |
| `AGE(d)` | Custom | No direct equivalent |
| `EXTRACT(YEAR FROM d)` | `EXTRACT(YEAR FROM d)` | Direct mapping |
| `DATE_TRUNC('month', d)` | `DATE_TRUNC('month', d)` | Direct mapping |
| `TO_CHAR(d, fmt)` | `TO_CHAR(d, fmt)` | Direct mapping |
| `TO_DATE(str, fmt)` | `TO_DATE(str, fmt)` | Direct mapping |
| `TO_TIMESTAMP(str, fmt)` | `TO_TIMESTAMP(str, fmt)` | Direct mapping |
| `LENGTH(str)` | `LENGTH(str)` | Direct mapping |
| `SUBSTRING(str FROM n FOR m)` | `SUBSTR(str, n, m)` | Different syntax |
| `POSITION(sub IN str)` | `INSTR(str, sub)` | Different function |
| `CONCAT(a, b)` | `CONCAT(a, b)` or `a || b` | Direct mapping |
| `UPPER(str)` | `UPPER(str)` | Direct mapping |
| `LOWER(str)` | `LOWER(str)` | Direct mapping |
| `TRIM(str)` | `TRIM(str)` | Direct mapping |
| `BTRIM(str)` | `TRIM(str)` | Different function |
| `LTRIM(str)` | `LTRIM(str)` | Direct mapping |
| `RTRIM(str)` | `RTRIM(str)` | Direct mapping |
| `REPLACE(str, old, new)` | `REPLACE(str, old, new)` | Direct mapping |
| `REVERSE(str)` | `REVERSE(str)` | Direct mapping |
| `REPEAT(str, n)` | `REPEAT(str, n)` | Direct mapping |
| `LPAD(str, n, pad)` | `LPAD(str, n, pad)` | Direct mapping |
| `RPAD(str, n, pad)` | `RPAD(str, n, pad)` | Direct mapping |
| `STRING_AGG(col, ',')` | `LISTAGG(col, ',')` | Different function |
| `ARRAY_AGG(col)` | Custom | No direct equivalent |
| `JSON_BUILD_OBJECT(...)` | Custom | No direct equivalent |
| `JSON_AGG(col)` | Custom | No direct equivalent |

---

## Function Migration Strategies

### Strategy Selection Guide

| Function Type | Recommended Strategy | Rationale |
|--------------|---------------------|-----------|
| Table lookup | Subquery + LEFT JOIN | Better performance, set-based |
| Complex logic | Stored Procedure + OUT | Preserves procedural logic |
| Mathematical | User-Defined SQL Function | Simple, inline |
| Multi-statement | Stored Procedure + OUT | Preserves logic flow, error handling |
| WHERE clause | Subquery or CASE | Enables query optimization |

### Strategy 1: SQL Function → Subquery

**Conversion**: Function → LEFT JOIN + CASE
```sql
SELECT a.user_id, a.user_name,
       (CASE WHEN au.user_id IS NOT NULL THEN '1' ELSE '0' END) AS is_active
FROM all_users a LEFT JOIN active_users au ON a.user_id = au.user_id;
```
**Benefits**: Optimized JOIN, set-based processing, query plan optimization

### Strategy 2: Function → Stored Procedure

**Conversion**: Return value → OUT parameter
```sql
CREATE PROCEDURE get_config_value(OUT rt VARCHAR(100)) AS $$
BEGIN
    SELECT config_value INTO rt FROM app_config WHERE config_key = 'SYSTEM_NAME';
END; $$;

-- Call with tuple unpacking
v_val := CALL get_config_value();
```

**Tuple unpacking**: Single OUT → `var := CALL proc()`; Multiple OUTs → `var1, var2, var3 := CALL proc()`

### Strategy 3: Complex Function (Multiple Returns)

**Conversion**: `RETURNS TABLE` → Multiple OUT parameters
```sql
CREATE PROCEDURE get_dept_stats(
    p_dept_id INTEGER,
    OUT emp_count INTEGER,
    OUT avg_salary NUMERIC(10,2),
    OUT max_salary NUMERIC(10,2)
) AS $$
BEGIN
    SELECT COUNT(*)::INTEGER, AVG(salary), MAX(salary)
    INTO emp_count, avg_salary, max_salary
    FROM employees WHERE department_id = p_dept_id;
END; $$;

-- Call
v_count, v_avg, v_max := CALL get_dept_stats(10);
```

### Migration Checklist

- [ ] Analyze usage: SELECT, WHERE, or JOIN clauses
- [ ] Assess complexity: simple → subquery, complex → procedure
- [ ] Check if convertible to set operations
- [ ] Verify NULL handling matches
- [ ] Test performance

---

## Array Handling

| PostgreSQL | Vertica |
|-----------|---------|
| `TEXT[]` | `ARRAY[VARCHAR(50)]` |
| `SELECT id, UNNEST(tags) AS tag FROM test_arrays` | `SELECT id, tag FROM test_arrays, UNNEST(tags) AS tag` |

**Note**: Vertica requires `UNNEST` in FROM clause (JOIN), not SELECT clause.

---

## JSON Handling

### PostgreSQL → Vertica Flex Table Mapping

| PostgreSQL | Vertica Flex Table |
|------------|-------------------|
| `data->>'name'` | `"name"` (virtual column) |
| `(data->>'age')::INTEGER` | `"age"::INT` |
| `data @> '{"key":"value"}'` | `MAPLOOKUP(__raw__, 'key') = 'value'` |
| `data IS NOT NULL` | `__raw__ IS NOT NULL` |

### 3-Step Flex Table Migration

**Step 1**: Create flex table
```sql
CREATE FLEX TABLE json_events();  -- Pure flex
CREATE FLEX TABLE json_events(event_type VARCHAR);  -- Hybrid (materialized columns)
```

**Step 2**: Load JSON data
```sql
COPY json_events FROM '/data/events.json' PARSER fjsonparser();
```

**Step 3**: Build view & query virtual columns
```sql
SELECT compute_flextable_keys_and_build_view('json_events');
SELECT "user.name", "event_type" FROM json_events WHERE "created_at"::TIMESTAMP > '2024-01-01';
```

**Optional**: Materialize frequently queried columns for better performance
```sql
SELECT MATERIALIZE_FLEXTABLE_COLUMNS('json_events');
```

---

## Index & Constraint Migration

| Constraint | PostgreSQL | Vertica |
|-----------|-----------|---------|
| Primary Key | `emp_id SERIAL PRIMARY KEY` | `emp_id IDENTITY PRIMARY KEY` |
| Foreign Key | `REFERENCES orders(id) ON DELETE CASCADE` | `REFERENCES orders(id)` (comment out CASCADE) |
| Unique | `product_code VARCHAR(50) UNIQUE` | Same |
| Check | `salary NUMERIC(10,2) CHECK (salary > 0)` | Same |

**ON DELETE CASCADE**: Not supported; use stored procedures or application logic instead.

**PostgreSQL Hints**: Comment out hints (Vertica ignores them)
```sql
SELECT /* IndexScan(employees emp_dept_idx) */ * FROM employees WHERE dept_id = 10;
```

---

## Full-Text Search Migration

### PostgreSQL → Vertica Text Index Mapping

| PostgreSQL | Vertica Text Index |
|------------|-------------------|
| `to_tsvector('english', content) @@ to_tsquery('english', 'term')` | `id IN (SELECT doc_id FROM idx WHERE token = v_txtindex.StemmerCaseInsensitive('term'))` |
| `to_tsquery('english', 'search & term')` (AND) | Two `IN (...)` subqueries joined with `AND` |
| `to_tsquery('english', 'search \| term')` (OR) | Two `IN (...)` subqueries joined with `OR` |
| `to_tsquery('english', '!exclude')` (NOT) | `NOT (id IN (...))` |

### Stemmer Comparison

| Feature | PostgreSQL | Vertica |
|---------|-----------|---------|
| Stemming algorithm | Language-specific dictionaries | Porter stemming algorithm |
| Case-insensitive | `to_tsvector('english', ...)` | `v_txtindex.StemmerCaseInsensitive` (default) |
| Case-sensitive | Not built-in | `v_txtindex.StemmerCaseSensitive` |
| No stemming | `to_tsvector('simple', ...)` | `STEMMER NONE` |

### 2-Step Migration

**Step 1**: Create text index
```sql
CREATE TEXT INDEX articles_text_idx ON articles (id, content);
```

**Step 2**: Query text index
```sql
SELECT * FROM articles
WHERE id IN (SELECT doc_id FROM articles_text_idx
             WHERE token = v_txtindex.StemmerCaseInsensitive('search term'));
```

**Prerequisites**: Source table must have primary key; projection sorted and segmented by that key.

---

## Migration Checklist

### 🚨 Critical Parameter Handling (see Critical Rules #1, #2, #8)

- [ ] **NEVER remove OUT/INOUT keywords** (see Critical Rules #1)
- [ ] **NEVER use DEFAULT syntax** — use procedure overloading (see Critical Rule #8, PL/vSQL section)
- [ ] Verify OUT parameters: `OUT param_name TYPE`; INOUT: `INOUT param_name TYPE`; IN is optional
- [ ] Implement default values using overloading pattern
- [ ] Test all parameter passing scenarios
- [ ] **OUT/INOUT behavior**: `CALL` returns single tuple — unpack with `var1, var2 := CALL proc(...)`. Original variables NOT modified.

### 📋 General Migration Checklist

- [ ] `$$` delimiters correct; `LANGUAGE plpgsql` removed
- [ ] **Triggers**: Comment out (not supported)
- [ ] **Foreign keys**: Comment out `ON DELETE CASCADE` (not supported)
- [ ] Tables converted with proper data types (INTEGER = 8 bytes in Vertica)
- [ ] Parameter modes preserved; default values via overloading
- [ ] SQL functions analyzed for optimal strategy (subquery vs stored procedure)
- [ ] NULL handling reviewed (set `PLvSQLCoerceNull = 1` if needed)
- [ ] FOR loops use required keywords (QUERY, CURSOR, RANGE)
- [ ] DML return values captured directly (no `GET DIAGNOSTICS ROW_COUNT`)
- [ ] **PERFORM** used for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE to discard output
- [ ] Exception handling: `SQLSTATE`/`SQLERRM` for basic; `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`/`HINT_TEXT`/`EXCEPTION_CONTEXT` for detailed
- [ ] SQLSTATE code differences reviewed

### 🚫 Critical "Never" Rules (see Critical Rules #1, #2)

- [ ] Never remove OUT/INOUT keywords
- [ ] Never discard SEQUENCE migration (may be used elsewhere)
- [ ] Never use `EXECUTE`/`PERFORM EXECUTE` for DML/SELECT — use variables directly
- [ ] Never use `EXECUTE`/`PERFORM EXECUTE` for DDL with fixed names — use `PERFORM` directly

### Common Migration Errors

| Error | Problem | Solution |
|-------|---------|----------|
| Parameter keywords removed | `OUT INTEGER` → `INTEGER` | Always preserve OUT/INOUT |
| Incorrect parameter type | `NUMERIC` as parameter | Use `INTEGER` or `FLOAT` |
| Missing INOUT specification | `INOUT` → plain | Always specify `INOUT` |
| Incorrect exception handling | Using `PG_EXCEPTION_DETAIL` etc. | Use `SQLSTATE`/`SQLERRM`; `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`/`HINT_TEXT`/`EXCEPTION_CONTEXT` |

---

## Performance Optimization

### Projection Design for Analytic Functions

```sql
CREATE PROJECTION employees_analytic AS
SELECT employee_id, department_id, salary, hire_date
FROM employees
ORDER BY department_id, salary DESC, hire_date
SEGMENTED BY HASH(employee_id) ALL NODES;
```

### Statistics & Bulk Insert

```sql
SELECT ANALYZE_STATISTICS('table_name');  -- After data migration
INSERT INTO employees (emp_name, salary) VALUES ('John', 50000), ('Jane', 60000), ('Bob', 55000);
```

---

## Migration Best Practices

### Phases

1. **Assessment**: Analyze schema complexity; catalog functions; identify PostgreSQL-specific features
2. **Conversion**: One-to-one migration (tables→tables, procedures→PL/vSQL, functions→UDF/procedures); test each component
3. **Optimization**: Bulk inserts; set-based processing over row-by-row; update statistics

### Common Pitfalls to Avoid

- Don't use PostgreSQL-style indexing — comment out
- Avoid excessive procedural logic — prefer set-based operations
- Don't ignore data type precision (INTEGER = 8 bytes in Vertica, 4 bytes in PostgreSQL)
- Don't forget to update statistics — critical for query optimization
- **NEVER remove OUT/INOUT keywords** — breaks parameter logic
- **NEVER use DEFAULT syntax** — use procedure overloading
- **Replace direct DML with PERFORM** — required in PL/vSQL
- **Review NULL handling** — set `PLvSQLCoerceNull = 1` if needed
- **Use correct FOR loop keywords** — QUERY, CURSOR, or RANGE required
- **Capture DML return values directly** — no `GET DIAGNOSTICS ROW_COUNT` needed
- **Test transaction behavior** — Vertica commits before procedure execution
- **Check parameter types** — DECIMAL, NUMERIC, NUMBER, MONEY, UUID not supported as parameter types

---

## When to Load Full Document

This summary contains ALL information needed for PostgreSQL-to-Vertica migration decisions. The full document is for human reference with detailed examples.

**For complete examples and rationale, see [postgresql-migration.md](../postgresql-migration.md).**
