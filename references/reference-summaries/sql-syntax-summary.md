# SQL Syntax Reference - Summary

> **This is a condensed version of [sql-syntax-reference.md](../sql-syntax-reference.md).** Load this summary for common syntax questions. Load the full document for complex syntax scenarios.

---

## Vertica SQL Syntax Quick Reference

### Identifiers
- **Max length**: 128 bytes; **Case-insensitive**: `"ABC"` = `ABC` = `abc`
- **Unquoted**: First char = letter/`_`; subsequent = letters/`_`/digits/`
- **Quoted**: `"..."` can contain any character (including spaces, keywords)
- **Reserved keywords**: Avoid or quote; query `KEYWORDS` system table
- **Model names**: Do NOT support `$`, Unicode letters, or quoted identifiers

### PL/vSQL Variables
- Must be valid SQL identifiers (no reserved keywords); support `CONSTANT`, `NOT NULL`, `%TYPE`
- Inner-block variables shadow outer-block; use block labels: `<<outer>> ... outer.var`

### Data Types

| Category | Vertica Types |
|----------|---------------|
| Integer | `INT`, `INTEGER`, `BIGINT`, `SMALLINT`, `TINYINT` |
| Numeric | `NUMERIC`, `DECIMAL`, `FLOAT`, `DOUBLE PRECISION`, `REAL` |
| Character | `VARCHAR(n)`, `CHAR(n)`, `LONG VARCHAR` |
| Date/Time | `DATE`, `TIME`, `TIMESTAMP`, `TIMESTAMPTZ`, `INTERVAL` |
| Boolean | `BOOLEAN` |
| Binary | `BINARY`, `VARBINARY`, `LONG VARBINARY` |
| Spatial | `GEOMETRY`, `GEOGRAPHY` |
| Complex | `ARRAY`, `ROW`, `SET` |

### DDL Syntax

#### CREATE TABLE
```sql
CREATE TABLE [IF NOT EXISTS] schema.table (
    column1 datatype [NOT NULL] [DEFAULT value] [PRIMARY KEY] [ENCODING encoding_type],
    column2 datatype [REFERENCES other_table(column)],
    ...
    [PRIMARY KEY (column_list)],
    [FOREIGN KEY (column) REFERENCES other_table(column)],
    [UNIQUE (column_list)],
    [CHECK (condition)]
) [ORDER BY column_list] [SEGMENTED BY expression ALL NODES]
[PARTITION BY expression] [KSafety {0 | 1}] [PARTITION GROUP {AUTO | SMALL | LARGE}];
```
**ENCODING types**: `RLE`, `DELTA`, `GZIP`, `LZO`, `NONE`

#### CREATE VIEW
```sql
CREATE [OR REPLACE] VIEW schema.view_name AS
SELECT columns FROM table [WHERE conditions];
```

#### CREATE PROCEDURE (PL/vSQL)
```sql
CREATE [OR REPLACE] PROCEDURE schema.procedure_name (
    [IN|OUT|INOUT] param_name datatype [DEFAULT value]
)
LANGUAGE plvsql AS
$$
DECLARE
    variable_name datatype [:= value];
BEGIN
    -- procedure body
END;
$$;
```

#### CREATE FUNCTION (SQL)
```sql
CREATE [OR REPLACE] FUNCTION schema.function_name (
    param_name datatype
)
RETURN datatype
AS BEGIN
    RETURN (expression);
END;
```

#### CREATE FUNCTION (PL/vSQL)
```sql
CREATE [OR REPLACE] FUNCTION schema.function_name (
    param_name datatype
)
RETURN datatype
LANGUAGE plvsql AS
$$
BEGIN
    RETURN (expression);
END;
$$;
```

### DML Syntax

#### INSERT
```sql
INSERT INTO table (columns) VALUES (values);
INSERT INTO table (columns) SELECT ... FROM ...;
```

#### UPDATE
```sql
UPDATE table SET column = value WHERE condition;
UPDATE table SET column = value FROM other_table WHERE table.id = other_table.id;
```

#### DELETE
```sql
DELETE FROM table WHERE condition;
DELETE FROM table USING other_table WHERE table.id = other_table.id;
```

#### MERGE (UPSERT)
```sql
MERGE INTO target_table t
USING source_table s ON t.key = s.key
WHEN MATCHED THEN UPDATE SET column = s.column
WHEN NOT MATCHED THEN INSERT (columns) VALUES (s.columns);
```

### SELECT Syntax

```sql
SELECT [DISTINCT] columns
FROM table [alias]
[JOIN type JOIN table2 ON condition]
[WHERE conditions]
[GROUP BY columns]
[HAVING conditions]
[ORDER BY columns [ASC|DESC]]
[LIMIT n] [OFFSET n]
[UNION|INTERSECT|EXCEPT SELECT ...];
```

### JOIN Types

#### LATERAL JOIN (Limited Support)

**Supported**: `CROSS JOIN LATERAL` only with UDx functions (e.g., `UNNEST`)

**NOT Supported**: `JOIN LATERAL` with subquery, `LEFT JOIN LATERAL ... ON`, `CROSS APPLY`, `OUTER APPLY`

**Alternatives**:

| LATERAL pattern | Vertica alternative |
|---|---|
| `JOIN LATERAL (SELECT ... LIMIT N)` | `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` |
| `LEFT JOIN LATERAL` with subquery | `LEFT JOIN` with derived table or window function |
| `CROSS APPLY` / `OUTER APPLY` | `JOIN` / `LEFT JOIN` with UDTF or derived table |

#### UDTF JOIN Restrictions

**UDTF** (e.g., `unnest`, `generate_series`) must appear on **right side** of join; cannot be used standalone in `FROM` or with comma-style join

| Join type | Supported |
|---|---|
| `CROSS JOIN`, `JOIN`, `INNER JOIN`, `LEFT JOIN` | ✅ |
| `RIGHT JOIN`, `FULL OUTER JOIN` | ❌ Use subquery-wrapped UDTF + `LEFT JOIN` |

**Replace loop-counter with `generate_series`**:
```sql
-- Instead of: FOR i IN 1..10 LOOP ... END LOOP;
SELECT g.i, COUNT(o.order_id)
FROM (SELECT generate_series(1, 10) AS i) g
LEFT JOIN orders o ON o.user_id = g.i
GROUP BY g.i;
```

### Analytic Functions

```sql
ROW_NUMBER() OVER ([PARTITION BY col] ORDER BY col)
RANK() OVER ([PARTITION BY col] ORDER BY col)
DENSE_RANK() OVER ([PARTITION BY col] ORDER BY col)
SUM(col) OVER ([PARTITION BY col] ORDER BY col [ROWS BETWEEN ...])
AVG(col) OVER ([PARTITION BY col] ORDER BY col)
LAG(col, n, default) OVER (ORDER BY col)
LEAD(col, n, default) OVER (ORDER BY col)
COUNT(*) OVER ([PARTITION BY col] ORDER BY col)
```

### Common Table Expressions (CTE)

```sql
WITH cte_name AS (SELECT ...) SELECT * FROM cte_name;

WITH RECURSIVE cte_name AS (
    SELECT ... -- anchor
    UNION ALL
    SELECT ... FROM cte_name WHERE ... -- recursive
)
SELECT * FROM cte_name;
```

**INSERT + WITH Order** (Vertica-specific - INSERT before WITH):
```sql
INSERT INTO target_table WITH cte AS (SELECT col1 FROM source_table) SELECT col1 FROM cte;
```

**Recursive CTE Limits**:
- `WithClauseRecursionLimit`: Default 8 (database/session-level)
- Recursive term can reference CTE only **once**; cannot appear in subquery or outer join
- For deep recursion: Use `/*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/` hint

### Correlated Subquery Restrictions

**NOT SUPPORTED**: Correlated subquery with `DISTINCT`/`GROUP BY`, `NOT IN`, `ALL`, or under `OR`

**Rewrite to JOIN**:
```sql
-- ❌ NOT SUPPORTED: SELECT id, (SELECT MAX(value) FROM t2 WHERE t2.id = t1.id GROUP BY id) FROM t1;
-- ✅ REWRITTEN: SELECT t1.id, t.max_value FROM t1 LEFT JOIN (SELECT id, MAX(value) AS max_value FROM t2 GROUP BY id) t ON t1.id = t;
```

### Temporary Tables

```sql
CREATE [GLOBAL | LOCAL] TEMP[ORARY] TABLE [IF NOT EXISTS] table_name (
    column_name datatype [constraints], ...
) [ON COMMIT {DELETE | PRESERVE} ROWS] [ORDER BY ...] [SEGMENTED BY ...] [NO PROJECTION];
```

| Type | Schema | Visibility | Lifetime |
|------|--------|------------|----------|
| Local | `V_TEMP_SCHEMA` | Creating session | Until session ends |
| Global | `public` | All sessions | Until `DROP TABLE` |

- **ON COMMIT DELETE ROWS** (default): Transaction-scoped; **PRESERVE ROWS**: Session-scoped (required for CTAS)
- **Restrictions**: No `IDENTITY`/`AUTO-INCREMENT`; local temp cannot specify schema

### SEQUENCE and IDENTITY

```sql
CREATE SEQUENCE [IF NOT EXISTS] seq_name
    [INCREMENT [BY] integer] [MINVALUE integer | NO MINVALUE]
    [MAXVALUE integer | NO MAXVALUE] [START [WITH] integer]
    [CACHE integer | NO CACHE] [CYCLE | NO CYCLE];

column_name { IDENTITY | AUTO_INCREMENT } ( [ cache-size | start, increment [, cache-size] ] )
```
- **Default CACHE**: 250,000; **IDENTITY = AUTO_INCREMENT**: Synonyms
- **Restrictions**: Only 1 per table; not allowed in temp tables; values may have gaps

### Transaction Control

```sql
BEGIN;
-- statements
COMMIT;

BEGIN;
-- statements
ROLLBACK;

SAVEPOINT savepoint_name;
ROLLBACK TO SAVEPOINT savepoint_name;
```

### Session Settings

```sql
SET SESSION AUTOCOMMIT TO ON;
SET SESSION AUTOCOMMIT TO OFF;
SET SEARCH_PATH = schema1, schema2, public;
```

---

## PL/vSQL Syntax

### Variable Declaration
```sql
DECLARE
    variable_name datatype [:= default_value];
```

### Assignment
```sql
variable_name := value;           -- standard assignment
variable_name <- value;           -- truncating assignment
SELECT column INTO variable FROM table WHERE ...;
EXECUTE 'sql' INTO variable USING params;
```

### Control Structures

#### IF-ELSE
```sql
IF condition THEN
    -- statements
ELSIF condition THEN
    -- statements
ELSE
    -- statements
END IF;
```

#### LOOP
```sql
LOOP
    -- statements
    EXIT WHEN condition;
END LOOP;

FOR i IN 1..10 LOOP
    -- statements
END LOOP;

FOR rec IN SELECT * FROM table LOOP
    -- statements
END LOOP;
```

#### WHILE
```sql
WHILE condition LOOP
    -- statements
END LOOP;
```

### Exception Handling
```sql
BEGIN
    -- statements
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_message = MESSAGE_TEXT,
            v_detail = PG_EXCEPTION_DETAIL,
            v_hint = PG_EXCEPTION_HINT,
            v_context = PG_EXCEPTION_CONTEXT;
        RAISE NOTICE 'Error: %', v_message;
END;
```

### MERGE Restrictions
- Cannot operate on: `IDENTITY` columns, complex types (ARRAY/SET/ROW), sequence default columns
- Source join column cannot have duplicates; max 831 target columns

### SELECT INTO

```sql
SELECT * INTO TABLE new_table FROM source_table; -- Permanent
SELECT * INTO TEMP TABLE new_temp ON COMMIT PRESERVE ROWS FROM source_table; -- Temp
```
**Restrictions**: Cannot use in subqueries, with CTE, or specify ORDER BY/SEGMENTED BY

### PostgreSQL Compatibility (pgcompat)

**Installation**: `admintools -t install_package -P pgcompat -d <dbname>`

**Key functions**: `generate_series()` (must use in JOIN), `pg_typeof()`, `array_upper()`

**System catalog views**: `pg_type`, `pg_class`, `pg_namespace`, `pg_attribute`, `pg_proc`, `pg_roles`, `pg_user`, `pg_depend`, `pg_description`

### PERFORM (Discard Output)
```sql
PERFORM DDL_STATEMENT;           -- discard row counts, Tuples/Tuple, status messages
PERFORM DML_STATEMENT;           -- discard row counts
PERFORM CALL procedure();        -- discard output
PERFORM EXECUTE 'sql';           -- discard output
```

### RAISE (Messaging)
```sql
RAISE NOTICE 'message %', value;
RAISE WARNING 'message %', value;
RAISE EXCEPTION 'message %', value;
```

---

## When to Load Full Document

Load the full [sql-syntax-reference.md](../sql-syntax-reference.md) when:
- Complex query syntax
- Advanced analytic functions
- Detailed data type information
- Stored procedure development
- Performance optimization
- Troubleshooting syntax errors

---

**For complete syntax reference, see [sql-syntax-reference.md](../sql-syntax-reference.md).**
