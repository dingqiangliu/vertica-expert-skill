# Teradata Migration Guide - Summary

> **This is an agent-optimized summary of [teradata-migration.md](../teradata-migration.md).** This summary contains ALL information needed for Teradata-to-Vertica migration decisions. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **NEVER remove OUT/INOUT keywords** from procedure parameters | Runtime failures |
| 2 | **ALWAYS use PERFORM** to discard output for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE | Syntax errors |
| 3 | **ALWAYS use GET STACKED DIAGNOSTICS** for detailed error info | Incomplete error handling |
| 4 | **ALWAYS use FOUND** to check if DML affected rows | Incorrect logic |
| 5 | **ALWAYS use SQLSTATE/SQLERRM** for basic error info | Incomplete error handling |
| 6 | **ALWAYS use AS $$** instead of IS for procedure body | Syntax errors |
| 7 | **ALWAYS rewrite QUALIFY as LIMIT n OVER(...)** | Syntax errors |
| 8 | **ALWAYS rewrite UPDATE/DELETE JOINs** using FROM/WHERE EXISTS | Syntax errors |

### Common Pitfalls
- Teradata `CAST('str' AS DATE FORMAT '...')` → Vertica `TO_DATE('str', '...')`
- Teradata `CAST(num AS FLOAT FORMAT '9(14)')` → Vertica `LPAD(TO_CHAR(num), 14, '0')` or `RPAD`
- Teradata `CHARACTER(str)` → Vertica `LENGTH(str)`
- Teradata `MOD(a, b)` → Vertica `a % b` or `MOD(a, b)`
- Teradata `TOP n` → Vertica `LIMIT n`
- Teradata `CSUM/MSUM/MAVG` → Vertica window functions with `ROWS BETWEEN`
- Teradata `EXPAND ON` → No direct equivalent, use generate_series workaround
- Teradata `PRIMARY INDEX (col)` → Vertica `ORDER BY col SEGMENTED BY HASH(col) ALL NODES`
- Teradata `PARTITION BY RANGE_N(...)` → Vertica `PARTITION BY TRUNC(date, 'MONTH')::DATE` (prefer monthly; daily `TRUNC(date, 'DAY')::DATE` causes too many partitions)
- Teradata `VOLATILE TABLE` → Vertica `LOCAL TEMP TABLE`
- Teradata `REPLACE VIEW ... LOCKING ROW FOR ACCESS` → Vertica `CREATE OR REPLACE VIEW` (remove LOCKING)
- Teradata `TITLE '...'` → Remove, use `COMMENT ON COLUMN` after CREATE
- Teradata `COMPRESS` → Remove (Vertica auto-compresses)
- Teradata `NO FALLBACK/BEFORE/AFTER JOURNAL` → Remove
- Teradata BTEQ `.IF ERRORCODE <> 0 ...` → Use `\set ON_ERROR_STOP ON`
- Teradata BTEQ `.LOGON` → Remove (use VSQL environment variables)
- ⚠️ Teradata `BT;` / `ET;` (SQL abbreviations for `BEGIN TRANSACTION`/`END TRANSACTION`, no dot) → CONVERT to `BEGIN TRANSACTION;` / `COMMIT;`, do NOT delete.
- Teradata `SAMPLE n` (integer) → Vertica `ORDER BY RANDOM() LIMIT n`
- Teradata `SAMPLE n` (decimal 0-1) → Vertica `TABLESAMPLE(n*100)`
- Teradata `TOP n` → Vertica `LIMIT n`
- Teradata `CSUM/MSUM/MAVG` → Vertica window functions with `ROWS BETWEEN`
- Vertica temp tables: add `WHERE 0=1` when cloning from source table

---

## Data Type Mapping

> **See [Data Type Mapping Guide](../data-type-mapping.md)** for complete Teradata data type mappings.
> Load on-demand: `grep -n "^## \|^### " references/data-type-mapping.md` → `Read offset=N limit=M`

---

## SQL Syntax Differences

### QUALIFY → LIMIT OVER
```sql
-- Teradata
SELECT col, ROW_NUMBER() OVER (PARTITION BY dept ORDER BY sal) AS rn
FROM employees QUALIFY rn = 1;

-- Vertica
SELECT col, sal FROM employees
LIMIT 1 OVER(PARTITION BY dept ORDER BY sal);
```

### UPDATE with JOIN
```sql
-- Teradata: UPDATE a FROM table_a a, table_b b SET ... WHERE ...
-- Vertica: UPDATE table_a SET col = b.col FROM table_b b WHERE ...
```

### DELETE with JOIN
```sql
-- Teradata: DELETE a FROM table_a a, table_b b WHERE ...
-- Vertica: DELETE FROM table_a WHERE EXISTS (SELECT 1 FROM table_b WHERE ...)
```

### TOP N
```sql
-- Teradata: SELECT TOP 10 col FROM table
-- Vertica: SELECT col FROM table LIMIT 10
```

### SAMPLE
```sql
-- Teradata: SAMPLE 10 or SAMPLE 0.5
-- Vertica: ORDER BY RANDOM() LIMIT 10  or  TABLESAMPLE(50)
```

---

## Function Conversions

> **See [Function Mapping Guide](../function-mapping.md)** for Teradata function mappings.
> Load on-demand: `grep -n "^## \|^### " references/function-mapping.md` → `Read offset=N limit=M`

---

## DDL Conversion

### CREATE DATABASE → CREATE SCHEMA
```sql
-- Teradata: CREATE DATABASE name FROM SYSDBA AS PERM = ...;
-- Vertica: CREATE SCHEMA IF NOT EXISTS name;
```

### PRIMARY INDEX → ORDER BY + SEGMENTED BY HASH
```sql
-- Teradata: PRIMARY INDEX (col1, col2)
-- Vertica: ORDER BY col1, col2 SEGMENTED BY HASH(col1, col2) ALL NODES
```

### PARTITION BY RANGE_N → PARTITION BY TRUNC
> **⚠️ Vertica prefers monthly partitions.** Daily or smaller granularity leads to excessive partition counts and fragmented data files, degrading performance. Use `TRUNC(date, 'MONTH')::DATE` unless there is a clear business need for daily partitioning.

```sql
-- Teradata: PARTITION BY RANGE_N(date BETWEEN ... EACH INTERVAL '1' DAY)
-- Vertica (preferred): PARTITION BY TRUNC(date, 'MONTH')::DATE
-- Vertica (daily, avoid if possible): PARTITION BY TRUNC(date, 'DAY')::DATE
```

### Volatile Tables (3 patterns)
```sql
-- Pattern 1: AS (SELECT)
-- Teradata: CREATE VOLATILE TABLE t AS (SELECT ...) WITH NO DATA ON COMMIT PRESERVE ROWS
-- Vertica: CREATE LOCAL TEMP TABLE t ON COMMIT PRESERVE ROWS AS (SELECT ... WHERE 0=1)

-- Pattern 2: (columns)
-- Teradata: CREATE VOLATILE TABLE t (col TYPE ...) PRIMARY INDEX (col) ON COMMIT PRESERVE ROWS
-- Vertica: CREATE LOCAL TEMP TABLE t (col TYPE ...) ON COMMIT PRESERVE ROWS ORDER BY col SEGMENTED BY HASH(col) ALL NODES

-- Pattern 3: AS TABLE
-- Teradata: CREATE VOLATILE TABLE t AS source_table WITH NO DATA ON COMMIT PRESERVE ROWS
-- Vertica: CREATE LOCAL TEMP TABLE t ON COMMIT PRESERVE ROWS AS SELECT * FROM source_table WHERE 0=1
```

### VIEW
```sql
-- Teradata: REPLACE VIEW name (cols) AS LOCKING ROW FOR ACCESS SELECT ...
-- Vertica: CREATE OR REPLACE VIEW name (cols) AS SELECT ...  (remove LOCKING ROW FOR ACCESS)
```

### TITLE → COMMENT ON COLUMN
```sql
-- Teradata: col1 CHAR(19) TITLE '备注' NOT NULL
-- Vertica: col1 CHAR(19) NOT NULL  (remove TITLE)
-- After CREATE: COMMENT ON COLUMN schema.table.col1 IS '备注';
```

### COMPRESS → Remove
```sql
-- Teradata: col DECIMAL(18,2) COMPRESS 0.00
-- Vertica: col DECIMAL(18,2)  (automatic compression)
```

### Journal/Fallback → Remove
```sql
-- Teradata: NO FALLBACK, NO BEFORE JOURNAL, NO AFTER JOURNAL, CHECKSUM = DEFAULT
-- Vertica: Remove all these clauses
```

### DEFAULT Position
```sql
-- Teradata: col CHAR(3) NOT NULL DEFAULT '   '
-- Vertica: col CHAR(3) DEFAULT '   ' NOT NULL
```

### ON COMMIT PRESERVE ROWS Position
```sql
-- Teradata: CREATE VOLATILE TABLE t (...) PRIMARY INDEX (col) ON COMMIT PRESERVE ROWS
-- Vertica: CREATE LOCAL TEMP TABLE t (...) ON COMMIT PRESERVE ROWS ORDER BY col SEGMENTED BY HASH(col) ALL NODES
```

---

## BTEQ Script Migration

### Perl Wrapper
```perl
# Teradata: open(BTEQ, "| bteq");
# Vertica: open(BTEQ, "| /opt/vertica/bin/vsql");
```

### BTEQ Statements
| BTEQ | Vertica |
|------|---------|
| `.LOGON user/pass` | Remove (use VSQL env vars) |
| `.LOGOFF` | Remove |
| `.QUIT` | Remove |
| `.LABEL` | Remove |
| `.IF ERRORCODE <> 0 ...` / `.if errorcode <> 0 ...` | Remove (use `\set ON_ERROR_STOP ON`) |
| `.WIDTH 256` | Remove |
| `.SPOOL file.log` | `\o file.log` |
| `BEGIN TRANSACTION` / `BT` | `BEGIN TRANSACTION` |
| `END TRANSACTION` / `ET` | `COMMIT` |
| `ROLLBACK` | `ROLLBACK` |

---

## Stored Procedure Conversion

### MUST Rules
- Use `AS $$` instead of `IS` for procedure body
- Use `PERFORM` for DML that doesn't need return value
- Use `var := value` instead of `SET var = value`
- Use `FOR rec IN SELECT ...` instead of manual cursor OPEN/FETCH/CLOSE
- Use `EXCEPTION WHEN OTHERS THEN ... RAISE EXCEPTION` instead of DECLARE HANDLER
- Remove explicit `COMMIT` (Vertica auto-commits or use `PERFORM COMMIT`)
- Teradata `SIGNAL SQLSTATE` → Vertica `RAISE EXCEPTION`
- Teradata `LEAVE` → Vertica `EXIT`
- Teradata `ITERATE` → Vertica `CONTINUE`

### Error Handling
```sql
-- Teradata
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
-- Vertica
EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Error: %', SQLERRM;
```

---

## Migration Checklist

### Critical Parameter Handling
- [ ] NEVER remove OUT/INOUT keywords
- [ ] NEVER use DEFAULT syntax in parameters — use overloading

### Teradata-Specific Items
- [ ] `DATABASE` → `CREATE SCHEMA IF NOT EXISTS`
- [ ] `PRIMARY INDEX` → `ORDER BY ... SEGMENTED BY HASH(...) ALL NODES`
- [ ] `PARTITION BY RANGE_N` → `PARTITION BY TRUNC(date, 'MONTH')::DATE` (prefer monthly; avoid daily `TRUNC(date, 'DAY')::DATE` unless required)
- [ ] `VOLATILE TABLE` → `LOCAL TEMP TABLE` (add WHERE 0=1 for clones)
- [ ] `REPLACE VIEW` → `CREATE OR REPLACE VIEW`
- [ ] `LOCKING ROW FOR ACCESS` removed
- [ ] `TITLE` removed (use COMMENT ON COLUMN after CREATE)
- [ ] `COMPRESS` clauses removed
- [ ] `NO FALLBACK/BEFORE/AFTER JOURNAL/CHECKSUM` removed
- [ ] `CAST AS FORMAT` → `TO_CHAR/TO_DATE`
- [ ] `QUALIFY` → `LIMIT n OVER(...)`
- [ ] `TOP n` → `LIMIT n`
- [ ] `SAMPLE` → `ORDER BY RANDOM() LIMIT n` or `TABLESAMPLE(n*100)`
- [ ] `CSUM/MSUM/MAVG` → Window functions with `ROWS BETWEEN`
- [ ] `MOD(a, b)` → `a % b`
- [ ] `UPDATE/DELETE` JOINs rewritten
- [ ] BTEQ `.IF ERRORCODE` → `\set ON_ERROR_STOP ON`
- [ ] BTEQ `.LOGON` removed

### Critical "Never" Rules
- [ ] Never use Teradata-specific syntax without conversion
- [ ] Never forget WHERE 0=1 when cloning tables
- [ ] Never use MOD without converting to %

---

## When to Load Full Document

Load [teradata-migration.md](../teradata-migration.md) section by section when:
- Summary rules require combination in ways not shown in examples
- Your migration produces TODOs, placeholders, or uncertain logic
- Test results show unexpected behavior
- The code pattern involves 3+ interacting SQL features

How to load: `grep -n "^## \|^### " references/teradata-migration.md` → `Read offset=N limit=M` (load ONLY that section, NOT the entire file).
