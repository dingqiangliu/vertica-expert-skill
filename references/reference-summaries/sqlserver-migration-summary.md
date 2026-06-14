# SQL Server Migration Guide - Summary

> **This is an agent-optimized summary of [sqlserver-migration.md](../sqlserver-migration.md).** This summary contains ALL information needed for SQL Server-to-Vertica migration decisions. The full document is for human reference with detailed examples.

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
| 8 | **ALWAYS increase WithClauseRecursionLimit** for deep hierarchies (default 8!) | Silent data truncation |
| 9 | **NEVER use @@ROWCOUNT** — use FOUND or separate COUNT query | Syntax errors |
| 10 | **NEVER use square brackets [identifier]** — use double quotes or unquoted | Syntax errors |
| 11 | **NEVER use SET @var = value** — use `var := value` or `var <- value` | Syntax errors |
| 12 | **NEVER use SELECT @var = column FROM table** — use `SELECT column INTO var FROM table` | Syntax errors |
| 13 | **NEVER prefix IDENTITY with INT/INTEGER** — `INT IDENTITY` is syntax error | Syntax errors |
| 14 | **ALWAYS add ON COMMIT PRESERVE ROWS** for SELECT INTO TEMP | Data loss |
| 15 | **NEVER use * in recursive CTE anchor term** | Syntax errors |
| 16 | **ALWAYS use explicit CAST in UNION with mixed types** | Type mismatch errors |
| 17 | **NEVER use dbo. prefix without USE statement** — remove it | Schema errors |
| 18 | **ALWAYS track USE statements** — apply schema prefix to CREATE objects | Schema errors |

### Common Pitfalls
- SQL Server `INT IDENTITY` → **Syntax error**: Use `IDENTITY` alone (standalone type)
- SQL Server `IDENTITY` is transactional; Vertica `IDENTITY` is **NOT** — gaps can occur
- SQL Server `##global_temp` → No equivalent; Vertica global temp data is always session-private
- SQL Server `SELECT INTO #temp` → Must add `ON COMMIT PRESERVE ROWS` or data lost
- SQL Server temp tables don't support `IDENTITY` — use named sequences
- SQL Server recursive CTE default depth 100; Vertica default **8** (silent truncation!)
- SQL Server `WITH cte AS (...)` → Vertica requires `WITH RECURSIVE` for recursive CTEs
- SQL Server `INSERT ... WITH cte` → Vertica: `INSERT` before `WITH` (order reversed)
- SQL Server `SELECT @var = col FROM cte` → Vertica: `var := WITH cte AS (...) SELECT col`
- SQL Server recursive CTE: anchor can use `*`; Vertica anchor **cannot use ***
- SQL Server UNION: implicit type conversion; Vertica UNION: **explicit CAST required**
- SQL Server computed columns (`AS expr`) → Vertica: `DEFAULT USING (expr)`
- SQL Server `JSON_VALUE()`/`OPENJSON()` → Vertica: Flex Tables
- SQL Server `CONTAINS()`/`FREETEXT()` → Vertica: Text Index
- SQL Server `[identifier]` → Vertica: `"identifier"` (square brackets not supported)
- SQL Server `dbo.` prefix → Remove if no `USE`, or replace with database name as schema
- SQL Server `USE [dbname]` → `CREATE SCHEMA` + `SET SEARCH_PATH` (both required)
- SQL Server `ON DELETE CASCADE` → Not supported, comment out
- SQL Server `PIVOT`/`UNPIVOT` → Not supported, rewrite with CASE + aggregate
- SQL Server `TOP n` → Use `LIMIT n`
- SQL Server `OPTION (MAXRECURSION n)` → `ALTER SESSION SET PARAMETER WithClauseRecursionLimit = n`
- SQL Server `WITH (NOLOCK)`/`WITH (INDEX=...)` → Not supported, remove/comment
- SQL Server `PRINT` → `RAISE NOTICE`
- SQL Server `RAISERROR`/`THROW` → `RAISE EXCEPTION`
- SQL Server `TRY...CATCH` → `EXCEPTION WHEN OTHERS THEN`
- SQL Server `ERROR_MESSAGE()`/`ERROR_STATE()` → `SQLERRM`/`SQLSTATE`
- SQL Server `DECIMAL(p,s)` in DECLARE → Vertica `NUMERIC` (without precision, default 37,15)
- SQL Server `MONEY`/`SMALLMONEY` → Use `NUMERIC` instead
- SQL Server `SQL_VARIANT` → Not supported, use `VARCHAR` or separate typed variables
- SQL Server `TABLE` type → Not supported, use temporary tables
- SQL Server `GEOGRAPHY`/`GEOMETRY`/`XML` → Not supported, store as `VARCHAR` or `LONG VARBINARY`
- SQL Server `CURSOR` type → Use `refcursor` or `CURSOR FOR` in DECLARE block
- SQL Server `TIMESTAMP`/`ROWVERSION` → `TIMESTAMP` maps to Vertica `TIMESTAMP`, `ROWVERSION` not supported

---

## Database and Schema Mapping (CRITICAL)

### Rules
- `USE [dbname]` → all following CREATE objects must be prefixed as `dbname.object_name`
- **No `USE` statement** → **remove `dbo.` prefix entirely**. Do NOT preserve `dbo`.
- Replace `USE [dbname]` with **both** (required together):
  1. `CREATE SCHEMA IF NOT EXISTS dbname;`
  2. `SET SEARCH_PATH = dbname, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;`

### Key Differences

| Aspect | SQL Server | Vertica |
|--------|-----------|---------|
| Database | Multiple per instance | Single per instance |
| Default schema | `dbo` | `"$user"` or `public` |
| Object reference | `[database].[schema].[table]` | `[schema].[table]` |

---

## Data Type Mapping: SQL Server → Vertica

| SQL Server | Vertica | Notes |
|------------|---------|-------|
| `INT` | `INTEGER` | Direct mapping |
| `BIGINT` | `BIGINT` | Direct mapping |
| `SMALLINT` | `SMALLINT` | Direct mapping |
| `TINYINT` | `TINYINT` | Direct mapping |
| `DECIMAL(p, s)` | `NUMERIC(p, s)` | Direct mapping |
| `NUMERIC(p, s)` | `NUMERIC(p, s)` | Direct mapping |
| `FLOAT(n)` | `FLOAT` or `DOUBLE PRECISION` | Direct mapping |
| `REAL` | `REAL` or `FLOAT` | Direct mapping |
| `MONEY` | `NUMERIC(19, 4)` | Use NUMERIC for precision |
| `SMALLMONEY` | `NUMERIC(10, 4)` | Use NUMERIC for precision |
| `VARCHAR(n)` | `VARCHAR(n)` | Direct mapping |
| `NVARCHAR(n)` | `VARCHAR(n)` | Vertica uses UTF-8 |
| `CHAR(n)` | `CHAR(n)` | Direct mapping |
| `NCHAR(n)` | `CHAR(n)` | Vertica uses UTF-8 |
| `TEXT` | `LONG VARCHAR` | Max 32MB (deprecated) |
| `NTEXT` | `LONG VARCHAR` | Max 32MB (deprecated) |
| `VARBINARY(n)` | `VARBINARY(n)` | Direct mapping |
| `IMAGE` | `LONG VARBINARY` | Max 32MB (deprecated) |
| `DATETIME` | `TIMESTAMP` | Direct mapping |
| `DATETIME2` | `TIMESTAMP` | Direct mapping |
| `SMALLDATETIME` | `TIMESTAMP` | Direct mapping |
| `DATE` | `DATE` | Direct mapping |
| `TIME` | `TIME` | Direct mapping |
| `DATETIMEOFFSET` | `TIMESTAMPTZ` | Direct mapping |
| `UNIQUEIDENTIFIER` | `VARCHAR(36)` | Store as string |
| `BIT` | `BOOLEAN` | Direct mapping |
| `SQL_VARIANT` | `VARCHAR(8000)` | No direct equivalent |
| `XML` | `LONG VARCHAR` | Store as string |
| `GEOGRAPHY` | `GEOGRAPHY` | Direct mapping |
| `GEOMETRY` | `GEOMETRY` | Direct mapping |

---

## Identity Columns (CRITICAL)

### 🚨 Critical Rules
1. **`IDENTITY`/`AUTO_INCREMENT` is a standalone type — do NOT prefix with `INT` or `INTEGER`.** `INT IDENTITY` is a **syntax error**.
2. SQL Server `IDENTITY` is transactional; Vertica `IDENTITY` is **NOT** — gaps can occur.
3. Vertica IDENTITY default cache: **250,000 values per node**.
4. **Temporary tables do NOT support `IDENTITY` or `AUTO_INCREMENT`** — use named sequences.
5. Only **one** IDENTITY/AUTO_INCREMENT column per table.

### Syntax
```sql
-- SQL Server: INT IDENTITY(1,1)
-- Vertica: IDENTITY (standalone type, no INT prefix)
CREATE TABLE employees (emp_id IDENTITY PRIMARY KEY, name VARCHAR(100));

-- Alternative: named sequences (for temp tables or more control)
CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE employees_seq (emp_id INTEGER DEFAULT NEXTVAL('emp_seq'), name VARCHAR(100));
```

---

## Temporary Tables (CRITICAL)

### 🚨 Critical Differences
| Feature | SQL Server `#temp` | SQL Server `##temp` | Vertica Local Temp | Vertica Global Temp |
|---------|------------------|---------------------|--------------------|---------------------|
| Syntax | `#tablename` | `##tablename` | `CREATE LOCAL TEMP TABLE` | `CREATE GLOBAL TEMP TABLE` |
| Data visibility | Session only | **All sessions** ⚠️ | Session only | **Session only** ⚠️ |

**⚠️ No Vertica equivalent** for SQL Server's cross-session `##temp` data sharing.

### ON COMMIT Options (no SQL Server equivalent)
- `ON COMMIT DELETE ROWS` (default): Transaction-scoped — cleared after COMMIT
- `ON COMMIT PRESERVE ROWS`: Session-scoped — persists across transactions

### 🚨 Critical Rules
1. **`SELECT INTO TEMP` does NOT populate by default** — must add `ON COMMIT PRESERVE ROWS`
2. **No `IDENTITY`/`AUTO-INCREMENT`** in temp tables — use named sequences
3. Local temp tables **cannot** specify schema name
4. `ALTER TABLE` not supported on temp tables
5. `SELECT FOR UPDATE` not allowed on temp tables
6. Partitioning not supported for temp tables

### Syntax
```sql
-- SQL Server: SELECT * INTO #temp FROM query;
-- Vertica: Must add ON COMMIT PRESERVE ROWS
SELECT * INTO LOCAL TEMP TABLE temp_table ON COMMIT PRESERVE ROWS FROM query;

-- Alternative: CTE (no temp table needed)
WITH temp AS (SELECT * FROM query) SELECT * FROM temp;
```

---

## T-SQL to PL/vSQL Conversion

### MUST Rules
- Use `AS $$` instead of `AS` for procedure/function body
- Use `DECLARE` block for all variables (no `@` prefix)
- Use `var := value` or `var <- value` for assignment (not `SET @var = value`)
- Use `SELECT column INTO var FROM table` for capturing query results
- Use `PERFORM` for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE when not capturing output
- Use `FOUND` special variable to check if DML affected rows (not `@@ROWCOUNT`)
- Use `SQLSTATE` and `SQLERRM` directly for basic error info
- Use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` for detailed error info

### Variable Declaration Type Restrictions

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

### Parameter Mode Conversion

**Key Syntax Difference**: In SQL Server, `OUTPUT` comes **after** the parameter name. In Vertica, `OUT` comes **before** the parameter name.

| SQL Server Syntax | ❌ Incorrect Vertica | ✅ Correct Vertica | Notes |
|-------------------|---------------------|-------------------|-------|
| `@param INT` | `p_param INTEGER` | `p_param INTEGER` | IN is optional (default) |
| `@param INT OUTPUT` | `p_param INTEGER` | `OUT p_param INTEGER` | **Must keep OUT before name** |
| `@param INT OUTPUT` (read/write) | `p_param INTEGER` | `INOUT p_param INTEGER` | **Must keep INOUT before name** |

**Behavioral Difference**: Unlike SQL Server's `OUTPUT` (modifies variables by reference), Vertica's `CALL` returns a **single tuple** — use `var1, var2 := CALL proc(...)` to unpack. Original input variables remain unchanged.

### Default Parameter Values Migration (CRITICAL)

**IMPORTANT**: SQL Server supports default parameter values (e.g., `@param INT = NULL`), but Vertica's PL/vSQL does NOT support this syntax directly. Use procedure overloading to achieve 100% SQL Server compatibility.

**Solution**: Create a main procedure with all parameters, then create overloaded versions that call the main procedure with default values.

> 🚨 **CRITICAL: All overloaded procedures MUST have the EXACT SAME NAME.**

### Cursor Handling

```sql
-- SQL Server cursor
DECLARE emp_cursor CURSOR FOR SELECT employee_id, salary FROM employees WHERE department_id = 10;
DECLARE @emp_id INT, @salary DECIMAL(10,2);
OPEN emp_cursor;
FETCH NEXT FROM emp_cursor INTO @emp_id, @salary;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Process record
    FETCH NEXT FROM emp_cursor INTO @emp_id, @salary;
END;
CLOSE emp_cursor;
DEALLOCATE emp_cursor;

-- Vertica cursor (recommended: FOR loop handles NOT FOUND automatically)
CREATE OR REPLACE PROCEDURE process_employees()
AS $$
DECLARE
    emp_cursor CURSOR FOR SELECT employee_id, salary FROM employees WHERE department_id = 10;
    v_employee_id INT;
    v_salary DECIMAL;
BEGIN
    FOR v_employee_id, v_salary IN CURSOR emp_cursor LOOP
        -- Process record
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
-- SQL Server
DECLARE @SQL NVARCHAR(1000);
DECLARE @City NVARCHAR(50);
SET @SQL = 'SELECT * FROM Person.Address WHERE City = ''' + @City + '''';
EXEC(@SQL);

-- Vertica (in PL/vSQL)
EXECUTE 'SELECT * FROM Person.Address WHERE City = ?' USING 'London';
```

### Error Handling

```sql
-- SQL Server
RAISERROR('Error message', 16, 1);

-- Vertica
RAISE EXCEPTION 'Error message';
```

### Exception Handling with GET STACKED DIAGNOSTICS

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

---

## Recursive CTE Migration (CRITICAL)

### 🚨 Critical Differences

| Feature | SQL Server | Vertica |
|---------|-----------|---------|
| Syntax | `WITH cte AS (...)` (no RECURSIVE needed) | `WITH RECURSIVE cte AS (...)` (required) |
| **INSERT + CTE order** | `WITH ... INSERT` ❌ | `INSERT ... WITH` ✅ (reversed!) |
| Default recursion depth | 100 (MAXRECURSION hint) | **8** (WithClauseRecursionLimit) ⚠️ |
| `*` in anchor term | ✅ Allowed | ❌ **Not allowed** |
| Multiple CTE refs in recursive term | ✅ Allowed | ❌ **Only 1 reference** |
| Outer join in recursive term | ✅ Allowed | ❌ **Not allowed** |
| Subquery referencing CTE | ✅ Allowed | ❌ **Not allowed** |
| `LIMIT` inside UNION | ✅ Allowed | ❌ **Not allowed** |

### 🚨 Critical Rules
1. **Default depth is 8** — deep hierarchies will be **silently truncated** without error. Use `ALTER SESSION SET PARAMETER WithClauseRecursionLimit = N`
2. **Anchor term cannot use `*`** — must explicitly list all columns
3. **Recursive term restrictions**: only 1 CTE reference, no outer join, no subquery referencing CTE

### CTE Variable Assignment Syntax
```sql
-- SQL Server: SELECT @var = column FROM cte
-- Vertica: var := WITH cte AS (...) SELECT column
v_count := WITH cte AS (SELECT COUNT(*) AS cnt FROM employees) SELECT cnt FROM cte;
```

### Deep Recursion Performance
```sql
-- Enable materialization for deep hierarchies (>20 levels)
ALTER SESSION SET PARAMETER WithClauseMaterialization = 1;
-- Or query hint: WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ RECURSIVE ...
```

---

## UNION Type Consistency (CRITICAL)

**SQL Server**: Implicit type conversion in UNION. **Vertica**: Requires **explicit CAST** for mixed types.

```sql
-- ❌ Vertica: VARCHAR + INTEGER fails
SELECT 'ID001' AS code UNION ALL SELECT 123;

-- ✅ Fix: Explicit CAST
SELECT 'ID001' AS code UNION ALL SELECT CAST(123 AS VARCHAR);
```

**Rule**: If not purely numeric types (INTEGER/NUMERIC/FLOAT) or date/timestamp combinations, use CAST

---

## Common SQL Server Functions → Vertica

| SQL Server | Vertica | Notes |
|------------|---------|-------|
| `ISNULL(a, b)` | `COALESCE(a, b)` | Direct replacement |
| `IIF(cond, t, f)` | `CASE WHEN cond THEN t ELSE f END` | Use CASE |
| `CHOOSE(n, v1, v2)` | `CASE n WHEN 1 THEN v1 WHEN 2 THEN v2 END` | Use CASE |
| `GETDATE()` | `CURRENT_TIMESTAMP` | Direct replacement |
| `GETUTCDATE()` | `GETUTCDATE()` or `CURRENT_TIMESTAMP` | Direct mapping |
| `SYSDATETIME()` | `CURRENT_TIMESTAMP` | Direct replacement |
| `DATEADD(day, n, d)` | `DATEADD(day, n, d)` or `d + INTERVAL 'n day'` | Direct mapping |
| `DATEDIFF(day, d1, d2)` | `DATEDIFF(day, d1, d2)` | Direct mapping |
| `DATEPART(year, d)` | `DATEPART(year, d)` or `EXTRACT(YEAR FROM d)` | Direct mapping |
| `YEAR(d)` | `EXTRACT(YEAR FROM d)` | Use EXTRACT |
| `MONTH(d)` | `EXTRACT(MONTH FROM d)` | Use EXTRACT |
| `DAY(d)` | `EXTRACT(DAY FROM d)` | Use EXTRACT |
| `LEN(str)` | `LENGTH(str)` | Different function |
| `SUBSTRING(str, n, m)` | `SUBSTR(str, n, m)` | Direct mapping |
| `CHARINDEX(sub, str)` | `INSTR(str, sub)` | Different function |
| `PATINDEX(pattern, str)` | `REGEXP_INSTR(str, pattern)` | Use regex |
| `REPLACE(str, old, new)` | `REPLACE(str, old, new)` | Direct mapping |
| `UPPER(str)` | `UPPER(str)` | Direct mapping |
| `LOWER(str)` | `LOWER(str)` | Direct mapping |
| `LTRIM(str)` | `LTRIM(str)` | Direct mapping |
| `RTRIM(str)` | `RTRIM(str)` | Direct mapping |
| `TRIM(str)` | `TRIM(str)` | Direct mapping |
| `CONCAT(a, b)` | `CONCAT(a, b)` or `a || b` | Direct mapping |
| `STR(n, len, dec)` | `TO_CHAR(n, 'fmt')` | Use TO_CHAR |
| `CONVERT(type, expr)` | `CAST(expr AS type)` | Use CAST |
| `CAST(expr AS type)` | `CAST(expr AS type)` | Direct mapping |
| `TRY_CAST(expr AS type)` | `CAST(expr AS type)` | No TRY_CAST |
| `TRY_CONVERT(type, expr)` | `CAST(expr AS type)` | No TRY_CONVERT |
| `ISNUMERIC(str)` | Custom | No direct equivalent |

---

## Computed Columns (CRITICAL)

**SQL Server**: `AS expression` computed columns. **Vertica**: No direct equivalent — use **Flattened Table** with `DEFAULT USING`.

```sql
-- Vertica: Flattened Table with DEFAULT USING
CREATE TABLE orders (
    order_id IDENTITY PRIMARY KEY,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) DEFAULT USING (quantity * unit_price)
);
```

**Key Points**:
- **`DEFAULT`**: Evaluated automatically at INSERT time
- **`SET USING`**: Evaluated only when `REFRESH_COLUMNS()` is called
- `REFRESH_COLUMNS` modes: `UPDATE` (default) vs `REBUILD` (auto-committed)

---

## JSON Support

**SQL Server**: `JSON_VALUE()`, `JSON_QUERY()`, `OPENJSON()`, `FOR JSON`. **Vertica**: No native JSON type — use **Flex Tables**.

```sql
-- Vertica Flex Table
CREATE FLEX TABLE json_events();
COPY json_events FROM '/data/events.json' PARSER fjsonparser();
SELECT compute_flextable_keys_and_build_view('json_events');
SELECT "name" FROM json_events;  -- Query virtual columns directly
```

---

## Full-Text Search

**SQL Server**: `CONTAINS()`, `FREETEXT()`, full-text catalogs. **Vertica**: Use **Text Index**.

```sql
-- Vertica Text Index
CREATE TEXT INDEX articles_text_idx ON articles (id, content);
SELECT * FROM articles WHERE id IN (
    SELECT doc_id FROM articles_text_idx
    WHERE token = v_txtindex.StemmerCaseInsensitive('search term')
);
```

---

## Function Migration Strategies

| Function Type | Recommended Strategy | Rationale |
|---------------|---------------------|-----------|
| Table lookup functions | Subquery with LEFT JOIN | Better performance, set-based |
| Complex business logic | Stored Procedure with OUT | Maintains procedural logic |
| Mathematical calculations | User-Defined SQL Function | Simple, inline execution |
| Multi-statement functions | Stored Procedure with OUT | Preserves logic flow |
| Functions in WHERE | Subquery or CASE | Enables query optimization |

---

## TOP → LIMIT

```sql
-- Vertica
SELECT * FROM employees LIMIT 10;
-- No PERCENT equivalent, use subquery
```

---

## Identifiers: Case Sensitivity & Quoting

**SQL Server**: Depends on collation. **Vertica**: **Always case-insensitive**.

- SQL Server uses **square brackets** (`[identifier]`) — Vertica does **NOT** support them
- Replace `[identifier]` with `"identifier"`. Adopt `snake_case` naming.

---

## Foreign Key Constraint Limitations

**Critical Limitation**: Vertica does **NOT** support `ON DELETE CASCADE` for foreign key constraints.

```sql
-- Vertica: Remove ON DELETE CASCADE and comment
CREATE TABLE order_items (
    item_id IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
    -- ON DELETE CASCADE (Vertica does not support this option)
);
```

**Alternative Solutions**: Stored procedures (manual cascade) or application logic.

---

## When to Load Full Document

This summary contains ALL information needed for SQL Server-to-Vertica migration decisions. The full document is for human reference with detailed examples.

**For complete examples and rationale, see [sqlserver-migration.md](../sqlserver-migration.md).**
