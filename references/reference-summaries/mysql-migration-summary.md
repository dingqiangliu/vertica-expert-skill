# MySQL Migration Guide - Summary

> **This is an agent-optimized summary of [mysql-migration.md](../mysql-migration.md).** This summary contains ALL information needed for MySQL-to-Vertica migration decisions. The full document is for human reference with detailed examples.

---

## Critical Rules & Common Patterns (MANDATORY)

| # | Rule/Pattern | MySQL | Vertica | Violation |
|---|--------------|-------|---------|-----------|
| 1 | OUT/INOUT keywords | `p_param OUT INT` | `OUT p_param INTEGER` (before name) | Runtime failure |
| 2 | Discard output | `CALL proc()` | `PERFORM CALL proc()` | Syntax error |
| 3 | Detailed errors | `GET DIAGNOSTICS` | `GET STACKED DIAGNOSTICS` | Incomplete handling |
| 4 | Check DML rows | `ROW_COUNT` | `FOUND` special variable | Incorrect logic |
| 5 | Basic error info | `CONDITION` | `SQLSTATE`/`SQLERRM` directly | Incomplete handling |
| 6 | Raise exceptions | `SIGNAL` | `RAISE EXCEPTION` | Incomplete handling |
| 7 | Recursive CTEs | `WITH cte AS` | `WITH RECURSIVE cte AS` | Syntax error |
| 8 | Deep hierarchies | Default 1000 | Default 8 — **increase WithClauseRecursionLimit** | Data truncation |
| 9 | DELIMITER | `DELIMITER //` | **Not needed** — remove | Syntax error |
| 10 | Procedure body | `BEGIN...END` | `AS $$ BEGIN...END; $$` | Syntax error |
| 11 | Schema + Search Path | `USE dbname` | **ALWAYS pair**: `CREATE SCHEMA IF NOT EXISTS dbname;` + `SET SEARCH_PATH = dbname, "$user", public, v_catalog, v_monitor, v_internal, v_func, pg_catalog;` | Object not found |
| 12 | Schema prefix tracking | `USE CRM; CREATE TABLE t` | Track USE context, prefix as `CRM.t` | Missing prefix |
| 13 | No USE = no prefix | `CREATE TABLE t` | `CREATE TABLE t` (no prefix) | Wrong prefix |
| 14 | Default parameters | `p_param INT DEFAULT 0` | **Not supported** — use overloading | Syntax error |
| 15 | ON DELETE CASCADE | Supported | **Not supported** — comment out, use procedures | Syntax error |
| 16 | INSERT + CTE order | `WITH cte AS (...) INSERT` | `INSERT WITH cte AS (...)` (**REVERSED**) | Syntax error |
| 17 | CTE variable assignment | `SELECT col INTO @var FROM cte` | `var := WITH cte AS (...) SELECT col` | Syntax error |
| 18 | Identifier case sensitivity | OS-dependent (Linux: sensitive) | **Always case-insensitive** — audit for conflicts | Naming conflicts |
| 19 | IDENTITY gaps | Transactional (InnoDB) | **NOT transactional — gaps can occur** | Unexpected gaps |
| 20 | SAVEPOINT | Supported | **Not supported** | Syntax error |
| 21 | Parameter keywords | `p_count OUT INT` | `OUT p_count INTEGER` (preserve) | Runtime failure |
| 22 | Parameter data types | `NUMERIC` in parameters | Use `INTEGER`/`FLOAT` instead | Type error |
| 23 | Exception handling | `RESIGNAL`/`GET DIAGNOSTICS` | Use `SQLSTATE`/`SQLERRM` directly | Incomplete handling |

### Quick Reference: MySQL → Vertica Patterns

**Data Types**:
- `DECIMAL(p,s)` in DECLARE → `NUMERIC` (no precision, default 37,15)
- `ENUM`/`SET`/`JSON`/`GEOMETRY` → Not supported: use `VARCHAR` or `LONG VARCHAR`
- `TINYBLOB`/`MEDIUMBLOB`/`LONGBLOB` → `LONG VARBINARY`
- `YEAR` → `INTEGER` or `DATE`
- `MEDIUMINT` → `INTEGER`
- `TINYINT` → `TINYINT` (same name, same 8 bytes)
- `BIT(n)` → `BIT(n)` or `INTEGER`

**Functions**:
- `IFNULL`/`ISNULL(a)` → `COALESCE`/`a IS NULL`
- `IF(cond, t, f)` → `CASE WHEN cond THEN t ELSE f END`
- `GROUP_CONCAT` → `LISTAGG(col, ',')`
- `LIMIT n, m` → `LIMIT m OFFSET n`
- `NEXTVAL(seq)` → `seq.NEXTVAL`
- `SHOW TABLES` → `SELECT * FROM v_catalog.tables`
- `DESCRIBE table` → `SELECT * FROM v_catalog.columns WHERE table_name = '...'`
- `START TRANSACTION` → `BEGIN`
- `DECLARE HANDLER` → `EXCEPTION WHEN OTHERS THEN`
- `SIGNAL`/`RESIGNAL` → `RAISE EXCEPTION`/`RAISE;`
- `CONDITION` → Use `SQLSTATE` directly

**Not Supported** (remove or comment out):
- `ENGINE=InnoDB`, `CHARSET=utf8`, `COLLATE=utf8_general_ci`
- `LOCK TABLES`/`UNLOCK TABLES`
- `SAVEPOINT`/`RELEASE SAVEPOINT`/`ROLLBACK TO SAVEPOINT`
- `DELETE ... USING` → Use `WHERE IN` or `WHERE EXISTS`
- `INSERT ... ON DUPLICATE KEY UPDATE`/`INSERT IGNORE`/`REPLACE INTO` → Use `MERGE`
- `LIMIT` inside recursive CTE → Move to outer query
- `CYCLE` clause → Use manual depth guard

---

## Data Type Mapping: MySQL → Vertica

| MySQL | Vertica | Notes |
|-------|---------|-------|
| `INT`/`INTEGER`/`BIGINT`/`SMALLINT`/`TINYINT` | Same names | **All 8 bytes in Vertica** (MySQL: 4,2,1 bytes) |
| `MEDIUMINT` | `INTEGER` | MySQL 3 bytes → Vertica 8 bytes |
| `DECIMAL(p,s)`/`NUMERIC(p,s)` | `NUMERIC(p,s)` | In DECLARE: use without precision (default 37,15) |
| `FLOAT`/`REAL` | `REAL`/`FLOAT` | **8 bytes in Vertica** (4 bytes in MySQL) |
| `DOUBLE` | `DOUBLE PRECISION` | 8 bytes |
| `VARCHAR(n)`/`CHAR(n)` | Same names | Direct mapping |
| `TEXT`/`MEDIUMTEXT`/`LONGTEXT` | `LONG VARCHAR` | Max 32MB |
| `TINYTEXT` | `VARCHAR(255)` | Max 255 bytes |
| `VARBINARY(n)` | `VARBINARY(n)` | Direct mapping |
| `BLOB`/`MEDIUMBLOB`/`LONGBLOB` | `LONG VARBINARY` | Max 32MB |
| `TINYBLOB` | `VARBINARY(255)` | Max 255 bytes |
| `DATE`/`TIME` | Same names | Direct mapping |
| `DATETIME`/`TIMESTAMP` | `TIMESTAMP` | Direct mapping |
| `YEAR` | `INTEGER` or `DATE` | No YEAR type in Vertica |
| `JSON`/`ENUM`/`SET`/`GEOMETRY` | `LONG VARCHAR` or `VARCHAR` | Not supported — store as string |
| `BIT(n)` | `BIT(n)` or `INTEGER` | Direct mapping |

---

## SQL Syntax & Function Mapping

**LIMIT**: `LIMIT n, m` (MySQL) → `LIMIT m OFFSET n` (Vertica, no comma syntax)

**Date/Time Functions**:
| MySQL | Vertica |
|-------|---------|
| `CURDATE()`/`CURTIME()`/`NOW()`/`SYSDATE()` | `CURRENT_DATE`/`CURRENT_TIME`/`CURRENT_TIMESTAMP` |
| `DATE_ADD(d, INTERVAL n DAY)`/`DATE_SUB(...)` | `d + INTERVAL 'n day'`/`d - INTERVAL 'n day'` |
| `DATE_FORMAT`/`STR_TO_DATE`/`TIME_FORMAT` | `TO_CHAR`/`TO_DATE`/`TO_CHAR` |
| `YEAR(d)`/`MONTH(d)`/`DAY(d)`/`HOUR(d)`/`MINUTE(d)`/`SECOND(d)`/`WEEK(d)`/`QUARTER(d)`/`DAYOFWEEK(d)`/`DAYOFYEAR(d)` | `EXTRACT(UNIT FROM d)` (use `ISODOW` for dayofweek, `DOY` for dayofyear) |
| `TIMEDIFF(t1, t2)` | `t1 - t2` |
| `UTC_DATE()`/`UTC_TIME()`/`UTC_TIMESTAMP()`/`UNIX_TIMESTAMP(d)`/`FROM_UNIXTIME(n)` | Custom (no direct equivalent) |

**String Functions**:
| MySQL | Vertica |
|-------|---------|
| `LOCATE(sub, str)`/`POSITION(sub IN str)`/`LCASE(str)`/`UCASE(str)`/`CHAR(n)` | `INSTR(str, sub)`/`LOWER(str)`/`UPPER(str)`/`CHR(n)` |
| `SUBSTRING(str, n, m)`/`LEFT(str, n)`/`RIGHT(str, n)`/`MID(str, n, m)`/`SPACE(n)` | `SUBSTR(str, n, m)`/`SUBSTR(str, 1, n)`/`SUBSTR(str, -n)`/`LPAD('', n, ' ')` |
| `GROUP_CONCAT(col)`/`CONCAT_WS(sep, a, b)` | `LISTAGG(col, ',')` (no direct equivalent for CONCAT_WS) |
| Others (`LENGTH`/`SUBSTR`/`REPLACE`/`UPPER`/`LOWER`/`TRIM`/`LTRIM`/`RTRIM`/`CONCAT`/`LPAD`/`RPAD`/`REVERSE`/`REPEAT`/`INSTR`/`CHAR_LENGTH`/`BIT_LENGTH`) | Same names (direct mapping) |

---

## AUTO_INCREMENT → IDENTITY

| MySQL | Vertica | Key Difference |
|-------|---------|----------------|
| `id INT AUTO_INCREMENT PRIMARY KEY` | `id IDENTITY(1, 1) PRIMARY KEY` or `id AUTO_INCREMENT PRIMARY KEY` | MySQL: column attribute; Vertica: column constraint. Both `IDENTITY` and `AUTO_INCREMENT` work in Vertica (synonyms). **Gaps can occur in Vertica** (not transactional). |

---

## Index and Constraint Migration

| Aspect | MySQL | Vertica |
|--------|-------|---------|
| Primary Keys | `INT AUTO_INCREMENT PRIMARY KEY` | `IDENTITY PRIMARY KEY` |
| Foreign Keys | `FOREIGN KEY (col) REFERENCES ...` | Same syntax |
| Unique Constraints | `col VARCHAR(50) UNIQUE` | Same syntax |
| `ON DELETE CASCADE` | ✅ Supported | ❌ **Not supported** — comment out, use stored procedures |
| Indexes | MySQL-style indexes | **Don't migrate** — comment out (Vertica uses projections) |

---

## Stored Procedure Conversion

**MUST Rules**:
- Use `AS $$ BEGIN...END; $$` (not `BEGIN...END`)
- Remove `DELIMITER` and `LANGUAGE plpgsql` (not needed in Vertica)
- Use `DECLARE` block for all variables
- Use `PERFORM` for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE when not capturing output
- Capture output: `var := SQL_STATEMENT` / `var <- SQL_STATEMENT` / `SELECT ... INTO var` / `EXECUTE ... INTO var`
- Use `FOUND` to check if DML affected rows
- Use `SQLSTATE`/`SQLERRM` directly for basic error info
- Use `GET STACKED DIAGNOSTICS` with `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` for detailed info

**Variable Declaration Restrictions**:
| MySQL Type | Vertica Workaround |
|------------|--------------------|
| `DECIMAL(p,s)`/`NUMERIC(p,s)` with precision | Declare as `NUMERIC` without precision (default 37,15) |
| `ENUM`/`SET`/`JSON`/`GEOMETRY`/`POINT`/`LINESTRING`/`POLYGON` | Not supported: use `VARCHAR` or `LONG VARCHAR` |
| `TINYBLOB`/`MEDIUMBLOB`/`LONGBLOB` | Maps to `LONG VARBINARY` |
| `YEAR` | Use `INTEGER` or `DATE` |

### Parameter Mode Conversion

**Syntax Difference**: MySQL: modes **after** name (`p_param OUT INT`). Vertica: modes **before** name (`OUT p_param INTEGER`).

| MySQL | ❌ Incorrect | ✅ Correct Vertica |
|-------|--------------|-------------------|
| `p_param IN VARCHAR` | `p_param VARCHAR` | `p_param VARCHAR` (IN optional) |
| `p_param OUT INT` | `p_param INTEGER` | `OUT p_param INTEGER` |
| `p_param INOUT VARCHAR` | `p_param VARCHAR` | `INOUT p_param VARCHAR` |

**OUT/INOUT Behavior**: MySQL modifies original variables. **Vertica returns a tuple** — use tuple unpacking:
```sql
var_return := CALL proc([params]);                    -- single OUT → scalar
var_out1, var_out2, var_return := CALL proc([params]); -- multiple OUTs → unpack
```

### Default Parameter Values (CRITICAL)

**MySQL**: `p_param INT DEFAULT 0` ✅ Supported. **Vertica**: ❌ Not supported — **use procedure overloading**.

**Solution**: Main procedure (all params) + overloaded versions (SAME name, different param counts).
```sql
-- Main: CREATE OR REPLACE PROCEDURE proc_name(p_order_id INTEGER, p_discount FLOAT, ...) AS $$ ... $$;
-- Overload 1: CREATE OR REPLACE PROCEDURE proc_name(p_order_id INTEGER) AS $$ BEGIN PERFORM CALL proc_name(p_order_id, 0.1, ...); END; $$;
-- Overload 2: CREATE OR REPLACE PROCEDURE proc_name(p_order_id INTEGER, p_discount FLOAT) AS $$ BEGIN ... END; $$;
```
> 🚨 **All overloaded procedures MUST have the EXACT SAME NAME.**

### Transaction Handling
```sql
-- MySQL: START TRANSACTION; ... COMMIT;
-- Vertica: BEGIN ... EXCEPTION WHEN OTHERS THEN RAISE; END; (use PERFORM for DML)
```

### Error Handling
```sql
-- MySQL: DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
-- Vertica: EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE; END;
```

### Cursors
```sql
-- MySQL: DECLARE cur CURSOR FOR ...; OPEN cur; FETCH cur INTO ...; CLOSE cur;
-- Vertica: DECLARE CURSOR cur IS ...; BEGIN FOR rec IN cur LOOP ... END LOOP; END;
```

### Dynamic SQL
```sql
-- MySQL: SET @sql = ...; PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- Vertica: DO $$ DECLARE ... BEGIN var := EXECUTE 'SELECT ...' || table_name; END $$;
```

---

## Function Migration Strategies

| Function Type | Strategy | Example |
|---------------|----------|---------|
| Table lookups | **Subquery with LEFT JOIN** | `SELECT u.id, (CASE WHEN au.id IS NOT NULL THEN 1 ELSE 0 END) FROM users u LEFT JOIN active_users au ON u.id = au.id` |
| Complex logic | **Stored Procedure with OUT** | `CREATE OR REPLACE PROCEDURE get_name(p_id INTEGER, OUT rt VARCHAR) AS $$ BEGIN SELECT name INTO rt FROM employees WHERE id = p_id; END; $$;` — Usage: `emp_name := CALL get_name(1001);` |
| Math calculations | **User-Defined SQL Function** | Simple inline execution |
| Multi-statement | **Stored Procedure with OUT** | Preserves logic flow |
| In WHERE clauses | **Subquery or CASE** | Enables optimization |

**Decision**: Simple lookups → subquery; complex logic → procedures; analyze usage (SELECT/WHERE/JOIN) and complexity.

---

### Recursive CTE Migration

| Feature | MySQL 8.0+ | Vertica |
|---------|-----------|---------|
| Default depth | **1000** | **8** — **must increase WithClauseRecursionLimit** |
| `*` in anchor | ✅ | ❌ Explicit columns required |
| Multiple CTE refs in recursive term | ✅ | ❌ **Only 1 reference** |
| Outer join in recursive term | ✅ | ❌ **Not allowed** |
| Subquery referencing CTE | ✅ | ❌ **Rewrite as JOIN** |
| `LIMIT` inside recursive term | ✅ | ❌ **Move to outer query** |
| Cycle detection | ❌ | ❌ Use manual depth guard |
| **INSERT + CTE order** | **`WITH` before INSERT** | **`INSERT` before WITH** (REVERSED) |

**INSERT + CTE Reversal**:
```sql
-- MySQL: WITH cte AS (...) INSERT INTO t SELECT ... FROM cte;
-- Vertica: INSERT INTO t WITH cte AS (...) SELECT ... FROM cte;
```

**MySQL 5.7 and Earlier**: No recursive CTE support — stored procedures, nested sets, or app-side recursion should all be rewritten as `WITH RECURSIVE`.

**Deep Recursion** (>20 levels): `ALTER SESSION SET PARAMETER WithClauseMaterialization = 1;` or query hint `WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ RECURSIVE ...`

---

## Common MySQL Functions → Vertica

| MySQL | Vertica | Notes |
|-------|---------|-------|
| `IFNULL(a, b)`/`ISNULL(a)` | `COALESCE(a, b)`/`a IS NULL` | ANSI standard |
| `IF(cond, t, f)` | `CASE WHEN cond THEN t ELSE f END` | Use CASE |
| `NULLIF`/`GREATEST`/`LEAST`/`ABS`/`CEIL`/`FLOOR`/`ROUND`/`MOD`/`POWER`/`SQRT`/`PI`/`SIGN`/`BIT_LENGTH` | Same names | Direct mapping |
| `CEILING(n)`/`TRUNCATE(n, m)`/`RAND()`/`CHAR(n)`/`ORD(str)` | `CEIL(n)`/`TRUNC(n, m)`/`RANDOM()`/`CHR(n)` | Different names |
| `CONV`/`HEX`/`UNHEX`/`BIN`/`OCT` | Custom | No direct equivalent |
| `CHAR_LENGTH(str)` | `LENGTH(str)` | Direct mapping |

**FULLTEXT Index**: `MATCH(content) AGAINST('term')` → `content ILIKE '%term%'` (or use Vertica Text Indexes)

**JSON Functions**: `JSON_EXTRACT(data, '$.name')` → `REGEXP_SUBSTR(data, '"name":"([^"]*)"', 1, 1, '', 1)` (store as text, parse with regex)

---

---

## When to Load Full Document

This summary contains ALL information needed for MySQL-to-Vertica migration decisions. The full document is for human reference with detailed examples.

**For complete examples and rationale, see [mysql-migration.md](../mysql-migration.md).**
