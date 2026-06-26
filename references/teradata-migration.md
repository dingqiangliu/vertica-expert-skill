# Teradata to Vertica Migration Guide

This guide provides comprehensive guidance for migrating Teradata databases to Vertica, including SQL syntax conversion, stored procedure migration, and performance optimization strategies.

## MANDATORY COMPLIANCE REQUIREMENTS

**BEFORE STARTING ANY TERADATA MIGRATION, YOU MUST READ AND FOLLOW THE [GENERIC MIGRATION GUIDE](generic-migration-guide.md)**

This Teradata migration guide **MUST BE USED IN CONUNCTION WITH** the [Generic Migration Guide](generic-migration-guide.md). The generic guide contains **MANDATORY PROCEDURES** that apply to ALL database migrations, including:

- COMPLETE migration of ALL objects (no selective migration allowed)
- SEQUENTIAL processing in exact source file order (no reordering)
- ONE-TO-ONE conversion (tables→tables, procedures→procedures, etc.)
- INDIVIDUAL testing of every object before considering it migrated
- NO automated scripts or bulk processing
- PRESERVATION of all sequences, and dependencies

**FAILURE TO FOLLOW THE GENERIC MIGRATION GUIDE WILL RESULT IN FAILED MIGRATIONS.**

## Reference Documentation (In Priority Order)

1. **[Generic Migration Guide](generic-migration-guide.md)** - MANDATORY READING
2. **[OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md)** - ESSENTIAL for procedural code
3. **[SQL Syntax Reference](sql-syntax-reference.md)**
4. **[Function Mapping Guide](function-mapping.md)**
5. **[Data Type Mapping Guide](data-type-mapping.md)**
6. **[Stored Procedures Guide](stored-procedures-guide.md)**

## SQL Syntax Conversion

### DATABASE Statement

**Rule**: Teradata uses `DATABASE` to define a database (equivalent to Vertica's `SCHEMA`). Convert `CREATE DATABASE ... FROM ... AS PERM = ...` to `CREATE SCHEMA IF NOT EXISTS ...`. Remove `FROM`, `PERM`, and `SPOOL` clauses — Vertica manages storage automatically.

```sql
-- Teradata
CREATE DATABASE RECRM FROM SYSDBA AS PERM = 5368709120, SPOOL = 5368709120;

-- Vertica
CREATE SCHEMA IF NOT EXISTS RECRM;
```

### QUALIFY Clause (Top-k Query)

**Rule**: Teradata's `QUALIFY` filters window function results. Rewrite as Vertica's Top-k query using `LIMIT n OVER(...)` — no need to explicitly compute `ROW_NUMBER`. The `PARTITION BY` and `ORDER BY` from the `QUALIFY` clause move directly into the `OVER(...)` clause, and the filter condition becomes the `LIMIT n` value.

```sql
-- Teradata
SELECT col, ROW_NUMBER() OVER (PARTITION BY dept ORDER BY sal) AS rn
FROM employees
QUALIFY rn = 1;

-- Vertica Top-k query (no ROW_NUMBER needed)
SELECT col, sal
FROM employees
LIMIT 1 OVER(PARTITION BY dept ORDER BY sal);
```

### TOP N Clause

**Rule**: Teradata's `SELECT TOP n` limits rows before `ORDER BY`. Vertica's `LIMIT n` limits rows after `ORDER BY`. If the Teradata query has no `ORDER BY`, the semantics are equivalent. If it has `ORDER BY`, the Vertica `LIMIT` produces the same result.

```sql
-- Teradata
SELECT TOP 10 col FROM table;

-- Vertica
SELECT col FROM table LIMIT 10;
```

### SAMPLE Clause

**Rule**: Teradata's `SAMPLE n` has two forms: integer (n rows) and decimal (percentage). For integer n > 0, use `ORDER BY RANDOM() LIMIT n`. For decimal 0 < n < 1, use `TABLESAMPLE(n*100)`.

```sql
-- Teradata (integer: n rows)
SELECT col FROM table SAMPLE 10;
-- Teradata (decimal: percentage)
SELECT col FROM table SAMPLE 0.5;

-- Vertica (integer > 0: use ORDER BY RANDOM() + LIMIT)
SELECT col FROM table ORDER BY RANDOM() LIMIT 10;
-- Vertica (0 < n < 1: use TABLESAMPLE)
SELECT col FROM table TABLESAMPLE(50);
```

### UPDATE with JOIN

**Rule**: Teradata's `UPDATE a FROM table_a a, table_b b SET ... WHERE ...` uses an implicit join in the `FROM` clause. Vertica requires explicit join syntax: move the source table to `UPDATE ... SET ... FROM ... WHERE ...`. The target table goes directly after `UPDATE`.

```sql
-- Teradata
UPDATE a
FROM table_a a, table_b b
SET a.col = b.col
WHERE a.id = b.id;

-- Vertica
UPDATE table_a
SET col = b.col
FROM table_b b
WHERE table_a.id = b.id;
```

### DELETE with JOIN

**Rule**: Teradata's `DELETE a FROM table_a a, table_b b WHERE ...` deletes rows matching the join. Vertica does not support `DELETE` with `FROM` join syntax. Rewrite using a subquery with `EXISTS` or `IN`.

```sql
-- Teradata
DELETE a
FROM table_a a, table_b b
WHERE a.id = b.id;

-- Vertica (rewrite as subquery with EXISTS)
DELETE FROM table_a
WHERE EXISTS (SELECT 1 FROM table_b WHERE table_a.id = table_b.id);
-- Alternative: WHERE IN
DELETE FROM table_a
WHERE id IN (SELECT id FROM table_b);
```

### MOD Operator

**Rule**: Teradata's `exp1 MOD exp2` is an arithmetic operator. Vertica supports both `exp1 % exp2` (operator form) and `MOD(exp1, exp2)` (function form). Either is acceptable; prefer `%` for consistency with other databases.

```sql
-- Teradata
SELECT 35 MOD 30;

-- Vertica
SELECT 35 % 30;
-- or
SELECT MOD(35, 30);
```

### Teradata OLAP Functions (CSUM, MSUM, MAVG)

**Rule**: Teradata's `CSUM`, `MSUM`, and `MAVG` are specialized OLAP functions for cumulative and moving aggregations. Convert to standard SQL window functions with explicit `ROWS BETWEEN` frame specifications:
- `CSUM(col, order)` → `SUM(col) OVER (ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`
- `MSUM(col, n, order)` → `SUM(col) OVER (ORDER BY ... ROWS BETWEEN n-1 PRECEDING AND CURRENT ROW)`
- `MAVG(col, n, order)` → `AVG(col) OVER (ORDER BY ... ROWS BETWEEN n-1 PRECEDING AND CURRENT ROW)`

```sql
-- Teradata: Cumulative Sum
SELECT CSUM(sales, month) FROM monthly_data;

-- Teradata: Moving Sum (last 3 rows)
SELECT MSUM(sales, 3, month) FROM monthly_data;

-- Teradata: Moving Average (last 3 rows)
SELECT MAVG(sales, 3, month) FROM monthly_data;

-- Vertica: Use standard SQL window functions
SELECT SUM(sales) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM monthly_data;
SELECT SUM(sales) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) FROM monthly_data;
SELECT AVG(sales) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) FROM monthly_data;
```

### EXPAND ON (Time Series)

**Rule**: Teradata's `EXPAND ON` generates rows from period boundaries (time series expansion). Vertica has no direct equivalent. Use `generate_series()` with date arithmetic as a workaround. This is an approximation — verify the output matches the original logic.

```sql
-- Teradata: Expand time series with period boundaries
SELECT * FROM table
EXPAND ON period_col AS new_col FOR new_duration;

-- Vertica: No direct equivalent
-- Workaround: Use Vertica's TIMESTAMP functions and generate series
SELECT start_time + (interval '1' hour * generate_series) AS expanded_time
FROM table, generate_series(0, duration_hours - 1);
```

### CAST with FORMAT

**Rule**: Teradata's `CAST(x AS DATE FORMAT '...')` and `CAST(x AS FLOAT FORMAT '...')` use Teradata-specific format strings. Convert to Vertica's standard functions:
- `CAST(str AS DATE FORMAT 'fmt')` → `TO_DATE(str, 'fmt')`
- `CAST(num AS FLOAT FORMAT '9(n)')` → `TO_CHAR(num, '999...9')` (n digits)

```sql
-- Teradata
CAST('18991231' AS DATE FORMAT 'YYYYMMDD')
CAST(col AS FLOAT FORMAT '9(14)')

-- Vertica
TO_DATE('18991231', 'YYYYMMDD')
TO_CHAR(col, '99999999999999')
```

### Volatile Tables (Three Patterns)

**Rule**: Teradata's `VOLATILE TABLE` is a session-scoped temporary table. Convert to Vertica's `LOCAL TEMP TABLE`. There are three common patterns:

**Pattern 1: CREATE VOLATILE TABLE AS (SELECT)** — Clone structure without data. Add `WHERE 0=1` to the `SELECT` to avoid copying rows.

**Pattern 2: CREATE VOLATILE TABLE (columns)** — Define schema explicitly. Convert `PRIMARY INDEX` to `ORDER BY` + `SEGMENTED BY HASH`. Move `ON COMMIT PRESERVE ROWS` to immediately after the table name.

**Pattern 3: CREATE VOLATILE TABLE AS TABLE** — Clone from existing table. Convert to `CREATE LOCAL TEMP TABLE ... AS SELECT * FROM source WHERE 0=1`.

```sql
-- Pattern 1: CREATE VOLATILE TABLE AS (SELECT)
-- Teradata
CREATE VOLATILE MULTISET TABLE tmp_table
AS (SELECT * FROM source_table)
WITH NO DATA
ON COMMIT PRESERVE ROWS;

-- Vertica
CREATE LOCAL TEMP TABLE tmp_table
ON COMMIT PRESERVE ROWS
AS (SELECT * FROM source_table WHERE 0=1);

-- Pattern 2: CREATE VOLATILE TABLE (columns)
-- Teradata
CREATE VOLATILE MULTISET TABLE tmp_table (
    col1 CHAR(19) NOT NULL,
    col2 DECIMAL(18,2)
)
PRIMARY INDEX (col1)
ON COMMIT PRESERVE ROWS;

-- Vertica
CREATE LOCAL TEMP TABLE tmp_table (
    col1 CHAR(19) NOT NULL,
    col2 DECIMAL(18,2)
)
ON COMMIT PRESERVE ROWS
ORDER BY col1
SEGMENTED BY HASH (col1) ALL NODES;

-- Pattern 3: CREATE VOLATILE TABLE AS TABLE
-- Teradata
CREATE VOLATILE MULTISET TABLE tmp_table
AS source_table
WITH NO DATA
ON COMMIT PRESERVE ROWS;

-- Vertica
CREATE LOCAL TEMP TABLE tmp_table
ON COMMIT PRESERVE ROWS
AS SELECT * FROM source_table WHERE 0=1;
```

### REPLACE VIEW

**Rule**: Teradata's `REPLACE VIEW ... AS LOCKING ROW FOR ACCESS SELECT ...` includes a locking clause for concurrent access. Vertica does not support `LOCKING ROW FOR ACCESS`. Convert to `CREATE OR REPLACE VIEW` and remove the locking clause.

```sql
-- Teradata
REPLACE VIEW schema.view_name (col1, col2)
AS LOCKING ROW FOR ACCESS
SELECT col1, col2 FROM table;

-- Vertica
CREATE OR REPLACE VIEW schema.view_name (col1, col2)
AS SELECT col1, col2 FROM table;
```

### PARTITION BY RANGE_N

**Rule**: Teradata's `PARTITION BY RANGE_N(col BETWEEN start AND end EACH INTERVAL ...)` defines range partitions with explicit boundaries. Convert to Vertica's `PARTITION BY TRUNC(date, 'MONTH')::DATE` for monthly partitions, or `PARTITION BY TRUNC(date, 'DAY')::DATE` for daily partitions. Remove `NO RANGE OR UNKNOWN` — Vertica handles NULL partitions automatically.

> **⚠️ IMPORTANT: Vertica prefers monthly partitions.** Partitioning by day or smaller granularity can easily lead to excessive partition counts and too many fragmented data files, significantly degrading query performance and storage efficiency. Unless there is a clear business requirement (e.g., managing data lifecycle independently per day), prefer `TRUNC(date, 'MONTH')::DATE` for monthly partitions.

```sql
-- Teradata
PARTITION BY RANGE_N(report_date BETWEEN DATE '1980-01-01' AND DATE '2100-12-31' EACH INTERVAL '1' DAY, NO RANGE OR UNKNOWN)

-- Vertica
PARTITION BY TRUNC(report_date, 'MONTH')::DATE
-- or for daily: PARTITION BY TRUNC(report_date, 'DAY')::DATE
```

### TITLE Attribute

**Rule**: Teradata's `TITLE 'text'` on a column provides a description inline in the DDL. Vertica does not support `TITLE`. Remove it from the `CREATE TABLE` statement and add a separate `COMMENT ON COLUMN` statement after table creation.

```sql
-- Teradata
CREATE TABLE test (
    col1 CHAR(19) TITLE '协议编号' NOT NULL
);

-- Vertica (remove TITLE, add COMMENT after CREATE)
CREATE TABLE test (
    col1 CHAR(19) NOT NULL
);
COMMENT ON COLUMN test.col1 IS '协议编号';
```

### ON COMMIT PRESERVE ROWS Position

**Rule**: In Teradata, `ON COMMIT PRESERVE ROWS` appears at the end of the `CREATE VOLATILE TABLE` statement. In Vertica, it must appear immediately after the table name (or column list) in `CREATE LOCAL TEMP TABLE`. If the table has a `PRIMARY INDEX`, remove it and add `ORDER BY` + `SEGMENTED BY HASH` after `ON COMMIT PRESERVE ROWS`.

```sql
-- Teradata
CREATE VOLATILE TABLE tmp_table (...)
PRIMARY INDEX (col)
ON COMMIT PRESERVE ROWS;

-- Vertica
CREATE LOCAL TEMP TABLE tmp_table (...)
ON COMMIT PRESERVE ROWS
ORDER BY col
SEGMENTED BY HASH (col) ALL NODES;
```

### DEFAULT Clause Position

**Rule**: In Teradata, `DEFAULT` can appear after `NOT NULL`. In Vertica, `DEFAULT` must appear before `NOT NULL`. Reorder the clauses accordingly.

```sql
-- Teradata
Currency_Cd CHAR(3) NOT NULL DEFAULT '   '

-- Vertica
Currency_Cd CHAR(3) DEFAULT '   ' NOT NULL
```

## Data Type Mapping

> **See [Data Type Mapping Guide](data-type-mapping.md)** for complete data type mappings.
> Load on-demand: `grep -n "^## \|^### " references/data-type-mapping.md` → `Read offset=N limit=M`

## Function Conversions

> **See [Function Mapping Guide](function-mapping.md)** for function conversions across databases.
> Load on-demand: `grep -n "^## \|^### " references/function-mapping.md` → `Read offset=N limit=M`

## BTEQ Script Migration

### Perl Script Wrapper

**Rule**: Teradata BTEQ scripts are typically invoked from Perl scripts via `open(BTEQ, "| bteq")`. Change the command to `/opt/vertica/bin/vsql` and replace BTEQ-specific control statements with VSQL equivalents. Add `\set ON_ERROR_STOP ON` at the top of the VSQL script to handle errors (replacing `.IF ERRORCODE` logic).

```perl
# Teradata BTEQ
open(BTEQ, "| bteq");
print BTEQ <<ENDOFINPUT;
.LOGON user/password
...
ENDOFINPUT;

# Vertica VSQL
open(BTEQ, "| /opt/vertica/bin/vsql");
print BTEQ <<ENDOFINPUT;
\\set ON_ERROR_STOP ON
...
ENDOFINPUT;
```

### BTEQ Special Statements

**Rule**: BTEQ control statements (dot-prefixed commands) have no direct VSQL equivalent. Remove `.LOGON`, `.LOGOFF`, `.QUIT`, `.LABEL`, and `.WIDTH` entirely. Replace `.IF ERRORCODE` with the VSQL setting `\set ON_ERROR_STOP ON`.

**Transaction control**: `BT`/`ET` are SQL abbreviations for `BEGIN TRANSACTION`/`END TRANSACTION` — all are standard SQL with no dot prefix. These must be CONVERTED to Vertica equivalents, not deleted.

| Statement | Vertica Equivalent | Notes |
|-----------|-------------------|-------|
| `.LOGON user/password` | Delete | Use VSQL env vars (`VSQL_HOST`, `VSQL_PORT`, `VSQL_USER`, `VSQL_PASSWORD`) |
| `.LOGOFF` | Delete | Not needed |
| `.QUIT ...` | Delete | Not needed |
| `.LABEL ...` | Delete | Not needed |
| `.IF ERRORCODE <> 0 THEN .GOTO ERRORQUIT` | Delete | Use `\set ON_ERROR_STOP ON` at script top |
| `.if errorcode <> 0 THEN .quit ...` | Delete | Use `\set ON_ERROR_STOP ON` at script top |
| `.WIDTH 256` | Delete | Not needed |
| `.SPOOL file.log` | `\o file.log` | Output redirection |
| `BEGIN TRANSACTION` / `BT` | `BEGIN TRANSACTION` | ⚠️ CONVERT — do NOT delete |
| `END TRANSACTION` / `ET` | `COMMIT` | ⚠️ CONVERT — do NOT delete |
| `ROLLBACK` | `ROLLBACK` | ⚠️ CONVERT — do NOT delete |

## Stored Procedure Migration

> **Note**: In earlier Vertica versions (before PL/vSQL support), stored procedures were not supported. For modern Vertica, use PL/vSQL syntax.

### Key Syntax Differences

**Rule**: Teradata SPL and Vertica PL/vSQL share similar procedural concepts but have critical syntax differences:

1. **Procedure header**: `REPLACE PROCEDURE name (IN param TYPE)` → `CREATE OR REPLACE PROCEDURE name (param TYPE)`. Keep `OUT`/`INOUT` keywords in the parameter list (Vertica uses them to define parameter direction); `IN` can be omitted as it is the default.
2. **Body delimiter**: `BEGIN ... END` → `AS $$ ... BEGIN ... END; $$;`
3. **Variable assignment**: `SET var = value` → `var := value`
4. **DML execution**: Use `PERFORM` for `UPDATE`, `DELETE`, `INSERT`, `COMMIT`, `ROLLBACK` when the result is not needed.
5. **Error handling**: `EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;` → `EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Error: %', SQLERRM;`
6. **COMMIT**: Remove explicit `COMMIT` — Vertica auto-commits at the end of the procedure unless inside an explicit transaction block.
7. **SIGNAL**: `SIGNAL SQLSTATE 'XXXXX' SET MESSAGE_TEXT = '...'` → `RAISE EXCEPTION '...'`
8. **LEAVE**: `LEAVE label` → `EXIT`
9. **ITERATE**: `ITERATE label` → `CONTINUE`

```sql
-- Teradata SPL
REPLACE PROCEDURE proc_name (IN param1 INTEGER, OUT param2 INTEGER)
BEGIN
    DECLARE var1 VARCHAR(30);
    SET var1 = 'value';
    SET param2 = 0;

    DECLARE cur CURSOR FOR SELECT col FROM table;
    OPEN cur;
    FETCH cur INTO var1;
    CLOSE cur;

    UPDATE table SET col = var1 WHERE id = param1;
    SET param2 = SQLCODE;
    COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            SET param2 = SQLCODE;
            ROLLBACK;
            RAISE;
END;

-- Vertica PL/vSQL
CREATE OR REPLACE PROCEDURE proc_name (param1 INTEGER, OUT param2 INTEGER)
AS $$
DECLARE
    var1 VARCHAR(30);
BEGIN
    var1 := 'value';
    param2 := 0;

    FOR rec IN SELECT col FROM table LOOP
        var1 := rec.col;
    END LOOP;

    PERFORM UPDATE table SET col = var1 WHERE id = param1;
    param2 := 0;

EXCEPTION
    WHEN OTHERS THEN
        param2 := SQLCODE;
        RAISE EXCEPTION 'Error: %', SQLERRM;
END;
$$;
```

### Cursor Handling

**Rule**: Teradata uses explicit `DECLARE CURSOR`, `OPEN`, `FETCH`, `CLOSE` with `cur%NOTFOUND` for cursor iteration. Vertica PL/vSQL supports the same pattern but also provides a simpler `FOR rec IN SELECT ...` loop that automatically handles cursor lifecycle. Prefer the `FOR` loop unless you need explicit cursor control.

```sql
-- Teradata: Manual cursor
DECLARE cur CURSOR FOR SELECT col FROM table;
OPEN cur;
LOOP
    FETCH cur INTO var;
    EXIT WHEN cur%NOTFOUND;
END LOOP;
CLOSE cur;

-- Vertica: FOR loop (recommended)
FOR var IN SELECT col FROM table LOOP
    -- Process record
END LOOP;
```

## Special Features

### Primary Index → ORDER BY + SEGMENTED BY HASH

**Rule**: Teradata's `PRIMARY INDEX (col)` defines the distribution and sort order of data across nodes. Convert to Vertica's `ORDER BY col SEGMENTED BY HASH(col) ALL NODES`. The PI columns become both the `ORDER BY` and `SEGMENTED BY HASH` columns. If the PI has multiple columns, include all of them in both clauses.

```sql
-- Teradata
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE
)
PRIMARY INDEX (customer_id);

-- Vertica
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE
)
ORDER BY customer_id
SEGMENTED BY HASH (customer_id) ALL NODES;
```

### SET/MULTISET Tables

**Rule**: Teradata distinguishes `SET TABLE` (unique rows enforced) from `MULTISET TABLE` (duplicates allowed). Vertica does not have this distinction — all tables allow duplicates unless a `UNIQUE` constraint is defined. Convert both to plain `CREATE TABLE`. If the original was a `SET TABLE`, add a `UNIQUE` constraint on the appropriate columns.

```sql
-- Teradata
CREATE SET TABLE unique_data (...);      -- Enforces uniqueness
CREATE MULTISET TABLE duplicate_ok (...); -- Allows duplicates

-- Vertica (no distinction)
CREATE TABLE unique_data (...);
CREATE TABLE duplicate_ok (...);
```

### Referential Integrity

**Rule**: Both Teradata and Vertica support foreign key constraints (`REFERENCES`). However, Vertica does not support `ON DELETE CASCADE`, `ON DELETE SET NULL`, or `ON UPDATE CASCADE`. Remove these clauses and comment them out. The base `REFERENCES` constraint is kept.

```sql
-- Teradata
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Vertica (ON DELETE CASCADE not supported, comment out)
CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER REFERENCES customers(customer_id)
    -- ON DELETE CASCADE (Vertica does not support this option)
);
```

### COLLECT STATISTICS

**Rule**: Teradata's `COLLECT STATISTICS` gathers optimizer statistics on a table or column. Vertica's equivalent is `ANALYZE_STATISTICS('table_name')`. Run this after large data loads.

```sql
-- Teradata
COLLECT STATISTICS table_name;

-- Vertica
SELECT ANALYZE_STATISTICS('table_name');
```

### Compression (MVC)

**Rule**: Teradata's `COMPRESS` clause (Multi-Value Compression) specifies default values for columns to save space. Vertica uses automatic compression (encoding) on all columns — encoding methods have no direct mapping to Teradata, so remove all `COMPRESS` clauses from the DDL.

```sql
-- Teradata
col1 DECIMAL(18,2) COMPRESS 0.00,
col2 CHAR(3) COMPRESS ('000','836','840')

-- Vertica: Remove COMPRESS, Vertica auto-compresses
col1 DECIMAL(18,2),
col2 CHAR(3)
```

### 9.99 Format Handling

Teradata's `CAST(... AS FORMAT '-----------------9.99')` pattern formats numbers with fixed decimal places and padding. Vertica's `TO_CHAR` with format strings achieves the same result.

```sql
-- Teradata
SELECT CAST(CAST(ZEROIFNULL(-31714.95) AS FORMAT '-----------------9.99') AS VARCHAR(18));

-- Vertica
SELECT TO_CHAR(CAST(ZEROIFNULL(-31714.95) AS NUMERIC(18,2)));
```

### Number Padding as Strings

Teradata's `CAST(... AS FLOAT FORMAT '9(14)')` pattern pads numbers with leading/trailing zeros when converting to string. Vertica has no `FORMAT` pattern for this — use `LPAD`/`RPAD` with `TO_CHAR`.

```sql
-- Teradata: left-pad number with zeros to 14 characters
SELECT CAST(CAST(3406225365 AS FLOAT FORMAT '9(14)') AS CHAR(14));

-- Vertica (left pad with zeros)
SELECT LPAD(TO_CHAR(3406225365), 14, '0');

-- Vertica (right pad with zeros)
SELECT RPAD(TO_CHAR(3406225365), 14, '0');
```

### PERIOD Type

Teradata's `PERIOD(DATE)` / `PERIOD(TIMESTAMP)` represents a time interval with explicit start and end boundaries. Vertica has no direct `PERIOD` type — use two columns (`start_col`, `end_col`) to store period boundaries.

**Type mapping**:
```sql
-- Teradata
valid_period PERIOD(DATE)

-- Vertica
valid_start DATE,
valid_end DATE
```

**Typical operations**:

```sql
-- Teradata: Create period from literals
SELECT PERIOD(DATE '2023-01-01', DATE '2023-12-31');

-- Vertica: Insert as two columns
INSERT INTO t (valid_start, valid_end) VALUES (DATE '2023-01-01', DATE '2023-12-31');


-- Teradata: Extract start/end from period
START(valid_period), END(valid_period)

-- Vertica: Direct column access
valid_start, valid_end


-- Teradata: Period intersection (overlap check)
p1 P_INTERSECT p2

-- Vertica: Overlap condition
WHERE t1.valid_start < t2.valid_end AND t1.valid_end > t2.valid_start;


-- Teradata: Period contains
p1 P_CONTAINS p2

-- Vertica: Contains condition
WHERE p1.valid_start <= p2.valid_start AND p1.valid_end >= p2.valid_end;


-- Teradata: Period overlaps
p1 P_OVERLAPS p2

-- Vertica: Overlap condition
WHERE p1.valid_start < p2.valid_end AND p1.valid_end > p2.valid_start;
```

## Examples

### ORDER BY with SELECT DISTINCT

```sql
-- Teradata
SELECT DISTINCT CAST(B.Sys_Org_Id AS VARCHAR(9)), col2
FROM table_a A
INNER JOIN table_b B ON A.id = B.id
ORDER BY A.Internal_Org_Id;

-- Vertica (wrap in subquery, DISTINCT outside)
SELECT DISTINCT * FROM (
    SELECT CAST(B.Sys_Org_Id AS VARCHAR(9)), col2
    FROM table_a A
    INNER JOIN table_b B ON A.id = B.id
    ORDER BY A.Internal_Org_Id
) AS alias_name;
```

### Full DDL Migration Example

```sql
-- Teradata
CREATE MULTISET TABLE RECRM.RECRM_IC_ACCOUNT (
    CM_POSTING_ACCT_NMBR VARCHAR(25) TITLE '入帐账号',
    CM_ORG_NMBR CHAR(3) TITLE '币种',
    report_date DATE FORMAT 'YYYY-MM-DD' TITLE '报告期' NOT NULL,
    CM_CRLIMIT DECIMAL(18,2) TITLE '信用额度' COMPRESS 0.00
)
PRIMARY INDEX (CM_POSTING_ACCT_NMBR, CM_ORG_NMBR)
PARTITION BY RANGE_N(report_date BETWEEN DATE '1980-01-01' AND DATE '2100-12-31' EACH INTERVAL '1' DAY);

-- Vertica
CREATE TABLE RECRM.RECRM_IC_ACCOUNT (
    CM_POSTING_ACCT_NMBR VARCHAR(25),
    CM_ORG_NMBR CHAR(3),
    report_date DATE NOT NULL,
    CM_CRLIMIT DECIMAL(18,2)
)
ORDER BY CM_POSTING_ACCT_NMBR, CM_ORG_NMBR
SEGMENTED BY HASH (CM_POSTING_ACCT_NMBR, CM_ORG_NMBR) ALL NODES
PARTITION BY TRUNC(report_date, 'DAY')::DATE;

COMMENT ON COLUMN RECRM.RECRM_IC_ACCOUNT.CM_POSTING_ACCT_NMBR IS '入帐账号';
COMMENT ON COLUMN RECRM.RECRM_IC_ACCOUNT.CM_ORG_NMBR IS '币种';
COMMENT ON COLUMN RECRM.RECRM_IC_ACCOUNT.report_date IS '报告期';
COMMENT ON COLUMN RECRM.RECRM_IC_ACCOUNT.CM_CRLIMIT IS '信用额度';
```

## Common Migration Challenges

### 1. Identifier Case Sensitivity

**Difference**: Teradata unquoted identifiers are case-insensitive (folded to uppercase); quoted identifiers are case-sensitive. Vertica identifiers are **always case-insensitive**.

**Solution**: Audit for identifiers that differ only by case and rename them.

```sql
-- Teradata: these are two different objects
CREATE TABLE "MyTable" (id INT);
CREATE TABLE "mytable" (id INT);

-- Vertica: the second CREATE will fail — rename one
CREATE TABLE MyTable (id INT);
CREATE TABLE my_table (id INT);  -- renamed to avoid conflict
```

### 2. Macros

**Difference**: Teradata macros are precompiled SQL templates. Vertica does not support macros directly.

**Solution**: Rewrite macros as stored procedures with `OUT` parameters or views.

```sql
-- Teradata Macro: No parameters → use view in Vertica
REPLACE MACRO get_active_customers() AS (
    SELECT * FROM customers WHERE active = 1;
);

-- Vertica: Rewrite as view
CREATE OR REPLACE VIEW get_active_customers AS
    SELECT * FROM customers WHERE active = 1;


-- Teradata Macro: Parameterized single-row lookup → use OUT parameter
REPLACE MACRO get_customer_info(customer_id INTEGER) AS (
    SELECT customer_name, email FROM customers WHERE id = :customer_id;
);

-- Vertica: Use multiple OUT parameters for multi-column lookup
CREATE OR REPLACE PROCEDURE get_customer_info(
    customer_id INTEGER,
    customer_name OUT VARCHAR(100),
    email OUT VARCHAR(200)
)
AS $$
BEGIN
    SELECT c.customer_name, c.email
    INTO customer_name, email
    FROM customers c WHERE c.id = customer_id;
END;
$$;

-- Call: CALL get_customer_info(123, NULL, NULL);
```

## Teradata to Vertica Migration Checklist

### Critical Parameter Handling
- [ ] NEVER remove OUT/INOUT keywords from procedure parameters
- [ ] NEVER use DEFAULT syntax in parameter declarations — use procedure overloading
- [ ] Verify tuple unpacking assignment works correctly

### General Migration Checklist
- [ ] `DATABASE` statements converted to `CREATE SCHEMA`
- [ ] `PRIMARY INDEX` converted to `ORDER BY ... SEGMENTED BY HASH(...) ALL NODES`
- [ ] `PARTITION BY RANGE_N` converted to `PARTITION BY TRUNC(date)::DATE`
- [ ] `VOLATILE TABLE` converted to `LOCAL TEMP TABLE`
- [ ] `LOCKING ROW FOR ACCESS` removed from views
- [ ] `TITLE` attributes removed (use COMMENT ON COLUMN)
- [ ] `COMPRESS` clauses removed (Vertica auto-compresses)
- [ ] `NO FALLBACK/BEFORE/AFTER JOURNAL` removed
- [ ] `CAST(... AS FORMAT '...')` converted to `TO_CHAR/TO_DATE`
- [ ] `QUALIFY` converted to `LIMIT n OVER(...)`
- [ ] `SAMPLE` converted to `ORDER BY RANDOM() LIMIT n` or `TABLESAMPLE`
- [ ] `UPDATE/DELETE` with JOIN rewritten
- [ ] `MOD` operator converted to `%` or `MOD()`
- [ ] BTEQ `.IF ERRORCODE` replaced with `\set ON_ERROR_STOP ON`
- [ ] BTEQ `.LOGON` removed (use VSQL environment variables)

### Critical "Never" Rules
- [ ] Never use Teradata-specific syntax without conversion
- [ ] Never ignore SET/MULTISET distinction (document it)
- [ ] Never use `MOD(a, b)` without converting to `a % b`
- [ ] Never forget to add `WHERE 0=1` when creating temp tables from source
