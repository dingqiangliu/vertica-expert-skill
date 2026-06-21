# Data Types Guide - Summary

> **This is an agent-optimized summary of [data-types.md](../data-types.md).** This summary contains ALL information needed for data type conversion decisions. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **ALWAYS use NUMERIC(p,s)** for precision numbers (especially financial) | Data loss |
| 2 | **ALWAYS use INTEGER** for whole numbers | Storage inefficiency |
| 3 | **ALWAYS use VARCHAR(n)** for variable-length strings | Syntax errors |
| 4 | **ALWAYS use TIMESTAMP** for date+time | Data loss |
| 5 | **ALWAYS use DATE** for date-only | Storage inefficiency |
| 6 | **ALWAYS use LONG VARCHAR** for large text (>65KB) | Data truncation |
| 7 | **ALWAYS use LONG VARBINARY** for large binary (>65KB) | Data truncation |
| 8 | **NEVER use CHAR** for variable-length data | Storage waste |
| 9 | **ALWAYS specify precision/scale** for NUMERIC (e.g., NUMERIC(18,2)) | Precision loss |
| 10 | **ALWAYS choose smallest type** that meets requirements | Storage waste |

### Size Limits
- **VARCHAR**: 65,000 characters; **LONG VARCHAR**: 32,000,000 characters
- **VARBINARY**: 65,000 bytes; **LONG VARBINARY**: 32,000,000 bytes

### Numeric Type Selection
| Precision | Use |
|-----------|-----|
| ≤ 18 digits | `NUMERIC(p,s)` (better compression) |
| > 18 digits | `DOUBLE PRECISION` |
| Financial calculations | `NUMERIC(p,s)` (never `FLOAT`) |

### Integer Type Selection
| Range | Use |
|-------|-----|
| 0-255 (unsigned) | `TINYINT` |
| -32K to 32K | `SMALLINT` |
| -2B to 2B | `INTEGER` |
| > 2B | `BIGINT` |

### Common Pitfalls
- Using `VARCHAR` without length (defaults to 65000)
- Using `LONG VARCHAR` for small strings
- Using `CLOB`/`TEXT` instead of `LONG VARCHAR` (not supported)
- Using `UUID` type in stored procedure parameters (not supported)

---

## Data Type Mapping: Oracle → Vertica

| Oracle | Vertica | Notes |
|--------|---------|-------|
| `NUMBER(p, s)` | `NUMERIC(p, s)` | Use `NUMERIC` for precision |
| `NUMBER` | `NUMERIC(38, 10)` | Default precision |
| `INTEGER` | `INTEGER` | |
| `VARCHAR2(n)` | `VARCHAR(n)` | |
| `NVARCHAR2(n)` | `VARCHAR(n)` | Vertica uses UTF-8 |
| `CHAR(n)` | `CHAR(n)` | |
| `CLOB` | `LONG VARCHAR` | Max 32MB |
| `NCLOB` | `LONG VARCHAR` | Vertica uses UTF-8 |
| `BLOB` | `LONG VARBINARY` | Max 32MB |
| `RAW(n)` | `VARBINARY(n)` | |
| `LONG RAW` | `LONG VARBINARY` | Max 32MB |
| `DATE` | `TIMESTAMP` | Oracle DATE includes time |
| `TIMESTAMP` | `TIMESTAMP` | |
| `TIMESTAMP WITH TIME ZONE` | `TIMESTAMPTZ` | |
| `TIMESTAMP WITH LOCAL TIME ZONE` | `TIMESTAMPTZ` | |
| `INTERVAL YEAR TO MONTH` | `INTERVAL YEAR TO MONTH` | |
| `INTERVAL DAY TO SECOND` | `INTERVAL DAY TO SECOND` | |
| `BOOLEAN` | `BOOLEAN` | Vertica 9.3+ |

---

## Data Type Mapping: SQL Server → Vertica

| SQL Server | Vertica | Notes |
|------------|---------|-------|
| `INT` | `INTEGER` | |
| `BIGINT` | `BIGINT` | |
| `SMALLINT` | `SMALLINT` | |
| `TINYINT` | `TINYINT` | Unsigned 0-255 |
| `DECIMAL(p, s)` | `NUMERIC(p, s)` | |
| `NUMERIC(p, s)` | `NUMERIC(p, s)` | |
| `FLOAT(n)` | `FLOAT` or `DOUBLE PRECISION` | |
| `REAL` | `REAL` or `FLOAT` | |
| `MONEY` | `NUMERIC(19, 4)` | Use NUMERIC for precision |
| `SMALLMONEY` | `NUMERIC(10, 4)` | Use NUMERIC for precision |
| `VARCHAR(n)` | `VARCHAR(n)` | |
| `NVARCHAR(n)` | `VARCHAR(n)` | Vertica uses UTF-8 |
| `CHAR(n)` | `CHAR(n)` | |
| `NCHAR(n)` | `CHAR(n)` | Vertica uses UTF-8 |
| `TEXT` | `LONG VARCHAR` | Max 32MB |
| `NTEXT` | `LONG VARCHAR` | Vertica uses UTF-8 |
| `VARBINARY(n)` | `VARBINARY(n)` | |
| `IMAGE` | `LONG VARBINARY` | Max 32MB |
| `DATETIME` | `TIMESTAMP` | |
| `DATETIME2` | `TIMESTAMP` | |
| `SMALLDATETIME` | `TIMESTAMP` | |
| `DATE` | `DATE` | |
| `TIME` | `TIME` | |
| `DATETIMEOFFSET` | `TIMESTAMPTZ` | |
| `UNIQUEIDENTIFIER` | `UUID` | Not VARCHAR |
| `BIT` | `BOOLEAN` | |
| `SQL_VARIANT` | `VARCHAR(8000)` | No direct equivalent |
| `XML` | `LONG VARCHAR` | Store as string |
| `GEOGRAPHY` | `GEOGRAPHY` | |
| `GEOMETRY` | `GEOMETRY` | |
| `HIERARCHYID` | `LONG VARCHAR` | Store as string |

---

## Data Type Mapping: PostgreSQL → Vertica

| PostgreSQL | Vertica | Notes |
|------------|---------|-------|
| `INTEGER` or `INT` | `INTEGER` | |
| `BIGINT` | `BIGINT` | |
| `SMALLINT` | `SMALLINT` | |
| `NUMERIC(p, s)` | `NUMERIC(p, s)` | |
| `DECIMAL(p, s)` | `NUMERIC(p, s)` | |
| `REAL` | `REAL` or `FLOAT` | |
| `DOUBLE PRECISION` | `DOUBLE PRECISION` | |
| `FLOAT` or `FLOAT(n)` | `FLOAT` or `DOUBLE PRECISION` | |
| `BOOLEAN` | `BOOLEAN` | |
| `VARCHAR(n)` | `VARCHAR(n)` | |
| `CHAR(n)` | `CHAR(n)` | |
| `TEXT` | `LONG VARCHAR` | Max 32MB |
| `CHARACTER VARYING(n)` | `VARCHAR(n)` | |
| `CHARACTER(n)` | `CHAR(n)` | |
| `BYTEA` | `VARBINARY` or `LONG VARBINARY` | See size limits |
| `DATE` | `DATE` | |
| `TIME` | `TIME` | |
| `TIMESTAMP` | `TIMESTAMP` | |
| `TIMESTAMPTZ` | `TIMESTAMPTZ` | |
| `INTERVAL` | `INTERVAL` | |
| `UUID` | `UUID` | Not VARCHAR |
| `JSON` | `LONG VARCHAR` | Store as string |
| `JSONB` | `LONG VARCHAR` | Store as string |
| `ARRAY` | `ARRAY` | |
| `INET` | `VARCHAR(45)` | Store as string |
| `CIDR` | `VARCHAR(49)` | Store as string |
| `MACADDR` | `VARCHAR(17)` | Store as string |
| `XML` | `LONG VARCHAR` | Store as string |
| `POINT` | `GEOMETRY` | Convert to spatial |
| `LINE` | `GEOMETRY` | Convert to spatial |
| `POLYGON` | `GEOMETRY` | Convert to spatial |

---

## Data Type Mapping: MySQL → Vertica

| MySQL | Vertica | Notes |
|-------|---------|-------|
| `INT` or `INTEGER` | `INTEGER` | |
| `BIGINT` | `BIGINT` | |
| `SMALLINT` | `SMALLINT` | |
| `TINYINT` | `TINYINT` | |
| `MEDIUMINT` | `INTEGER` | No direct equivalent |
| `DECIMAL(p, s)` | `NUMERIC(p, s)` | |
| `NUMERIC(p, s)` | `NUMERIC(p, s)` | |
| `FLOAT` | `FLOAT` or `REAL` | |
| `DOUBLE` | `DOUBLE PRECISION` | |
| `REAL` | `REAL` or `FLOAT` | |
| `VARCHAR(n)` | `VARCHAR(n)` | |
| `CHAR(n)` | `CHAR(n)` | |
| `TEXT` | `LONG VARCHAR` | Max 32MB |
| `MEDIUMTEXT` | `LONG VARCHAR` | Max 32MB |
| `LONGTEXT` | `LONG VARCHAR` | Max 32MB |
| `TINYTEXT` | `VARCHAR(255)` | Max 255 bytes |
| `VARBINARY(n)` | `VARBINARY(n)` | |
| `BLOB` | `LONG VARBINARY` | Max 32MB |
| `MEDIUMBLOB` | `LONG VARBINARY` | Max 32MB |
| `LONGBLOB` | `LONG VARBINARY` | Max 32MB |
| `TINYBLOB` | `VARBINARY(255)` | Max 255 bytes |
| `DATE` | `DATE` | |
| `TIME` | `TIME` | |
| `DATETIME` | `TIMESTAMP` | |
| `TIMESTAMP` | `TIMESTAMP` | |
| `YEAR` | `SMALLINT` | Store as smallint |
| `JSON` | `LONG VARCHAR` | Store as string |
| `ENUM(...)` | `VARCHAR(255)` | Store as string |
| `SET(...)` | `VARCHAR(255)` | Store as string |
| `BIT(n)` | `BIT(n)` or `INTEGER` | |

---

## Data Type Mapping: DB2 → Vertica

| DB2 | Vertica | Notes |
|-----|---------|-------|
| `INTEGER` | `INTEGER` | |
| `BIGINT` | `BIGINT` | |
| `SMALLINT` | `SMALLINT` | |
| `DECIMAL(p, s)` | `NUMERIC(p, s)` | |
| `DEC(p, s)` | `NUMERIC(p, s)` | |
| `NUMERIC(p, s)` | `NUMERIC(p, s)` | |
| `REAL` | `REAL` or `FLOAT` | |
| `DOUBLE PRECISION` | `DOUBLE PRECISION` | |
| `FLOAT` | `FLOAT` or `DOUBLE PRECISION` | |
| `VARCHAR(n)` | `VARCHAR(n)` | |
| `CHAR(n)` | `CHAR(n)` | |
| `CLOB(n)` | `LONG VARCHAR` | Max 32MB |
| `DBCLOB(n)` | `LONG VARCHAR` | Vertica uses UTF-8 |
| `BLOB(n)` | `LONG VARBINARY` | Max 32MB |
| `BINARY(n)` | `VARBINARY(n)` | |
| `VARBINARY(n)` | `VARBINARY(n)` | |
| `DATE` | `DATE` | |
| `TIME` | `TIME` | |
| `TIMESTAMP` | `TIMESTAMP` | |
| `TIMESTAMP WITH TIME ZONE` | `TIMESTAMPTZ` | |
| `XML` | `LONG VARCHAR` | Store as string |

---

## Complex Types

### ARRAY
```sql
CREATE TABLE t (id INTEGER, tags ARRAY[VARCHAR(50)]);
SELECT tags[1] FROM t;
```

### ROW
```sql
CREATE TABLE t (id INTEGER, address ROW(street VARCHAR(100), city VARCHAR(50)));
SELECT (address).city FROM t;
```

### SET
```sql
CREATE TABLE users (id INTEGER, permissions SET[VARCHAR(50)]);
INSERT INTO users VALUES (1, SET['read', 'write']);
```

### Spatial
```sql
CREATE TABLE spatial_table (id INTEGER, geom GEOMETRY);
CREATE TABLE geo_table (id INTEGER, geog GEOGRAPHY);
```

---

## Type Conversion

**Explicit Cast**: `CAST(col AS type)` or `col::type`

| From | To | Syntax |
|------|-----|--------|
| `VARCHAR` | `INTEGER`/`DATE`/`TIMESTAMP` | `col::type` |
| `INTEGER` | `VARCHAR` | `CAST(col AS VARCHAR)` |
| `DATE`/`TIMESTAMP` | `VARCHAR` | `TO_CHAR(col, 'format')` |

---

## Performance Optimization

### Compression Encoding
| Encoding | Best For |
|----------|----------|
| `RLE` | Low-cardinality columns |
| `DELTA` | Sorted numeric data |
| `LZO`/`GZIP` | Text and large binary data |

### Best Practices
1. Choose types based on actual data ranges, optimize for WHERE/JOINs
2. Use `NOT NULL` and `CHECK` constraints, test with real queries

---

## When to Load Full Document

Load [data-types.md](../data-types.md) section by section when:
- Summary rules require combination in ways not shown in examples
- Your migration produces TODOs, placeholders, or uncertain logic
- Test results show unexpected behavior
- The code pattern involves 3+ interacting SQL features

How to load: `grep -n "^## \|^### " references/data-types.md` → `Read offset=N limit=M` (load ONLY that section, NOT the entire file).
