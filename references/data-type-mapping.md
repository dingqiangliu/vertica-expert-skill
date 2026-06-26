# Data Type Mapping and Optimization Guide

This guide provides comprehensive data type mappings from common databases to Vertica, along with optimization recommendations for columnar storage.

## Basic Data Type Mappings

### Numeric Types

#### Integer Types

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|----------------|
| DB2 | BIGINT | BIGINT | 8-byte integer |
| DB2 | INTEGER | INTEGER | **8 bytes** in Vertica (4-byte in DB2) |
| DB2 | SMALLINT | SMALLINT | **8 bytes** in Vertica (2-byte in DB2) |
| MySQL | BIGINT | BIGINT | 8-byte signed |
| MySQL | INT | INTEGER | 4-byte signed |
| MySQL | MEDIUMINT | INTEGER | Use INTEGER |
| MySQL | SMALLINT | SMALLINT | 2-byte signed |
| MySQL | TINYINT | TINYINT | 1-byte signed |
| Oracle | NUMBER(≤9 digits) | INTEGER | 4-byte signed integer |
| Oracle | NUMBER(10-18 digits) | BIGINT | 8-byte signed integer |
| Oracle | NUMBER(>18 digits) | NUMBER(p,s), or NUMERIC(p,s) | Variable precision |
| PostgreSQL | BIGINT | BIGINT | 8-byte signed integer |
| PostgreSQL | BIGSERIAL | IDENTITY | Auto-incrementing bigint |
| PostgreSQL | INTEGER | INTEGER | 4-byte signed integer |
| PostgreSQL | SERIAL | IDENTITY | Auto-incrementing integer |
| PostgreSQL | SMALLINT | SMALLINT | 2-byte signed integer |
| SQL Server | BIGINT | BIGINT | 8-byte signed integer |
| SQL Server | INT | INTEGER | 4-byte signed integer |
| SQL Server | SMALLINT | SMALLINT | 2-byte signed integer |
| SQL Server | TINYINT | TINYINT | 1-byte unsigned (0-255) |
| Teradata | BYTEINT | INTEGER | 1-byte integer (-128 to 127) |
| Teradata | SMALLINT | SMALLINT | 2-byte signed integer |
| Teradata | INTEGER | INTEGER | 4-byte signed integer |
| Teradata | BIGINT | BIGINT | 8-byte signed integer |

#### Decimal and Floating Point

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|----------------|
| DB2 | DEC(p,s) | NUMERIC(p,s) | Same as DECIMAL |
| DB2 | DECFLOAT | DOUBLE PRECISION | Floating point |
| DB2 | DECIMAL(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| DB2 | DOUBLE PRECISION | DOUBLE PRECISION | 8-byte floating point |
| DB2 | FLOAT | DOUBLE PRECISION | Not supported directly |
| DB2 | NUMERIC(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| DB2 | REAL | REAL | **8 bytes** in Vertica (4-byte in DB2) |
| MySQL | DECIMAL(p,s) | NUMERIC(p,s) | Exact numeric |
| MySQL | DOUBLE | DOUBLE PRECISION | 8-byte float |
| MySQL | FLOAT | REAL | 4-byte float |
| Oracle | FLOAT | DOUBLE PRECISION | 8-byte floating point |
| Oracle | NUMBER(p,s) | NUMBER(p,s), or NUMERIC(p,s) | Same precision/scale |
| PostgreSQL | DECIMAL(p,s) | NUMERIC(p,s) | Exact numeric |
| PostgreSQL | DOUBLE PRECISION | DOUBLE PRECISION | 8-byte float |
| PostgreSQL | NUMERIC(p,s) | NUMERIC(p,s) | Exact numeric |
| PostgreSQL | REAL | REAL | 4-byte float |
| SQL Server | DECIMAL(p,s) | NUMERIC(p,s) | Exact numeric |
| SQL Server | FLOAT | DOUBLE PRECISION | 8-byte float |
| SQL Server | NUMERIC(p,s) | NUMERIC(p,s) | Exact numeric |
| SQL Server | REAL | REAL | 4-byte float |
| Teradata | DECIMAL(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| Teradata | NUMERIC(p,s) | NUMERIC(p,s) | Fixed precision decimal |
| Teradata | FLOAT(n) | DOUBLE PRECISION | Floating point |
| Teradata | REAL | REAL | 4-byte float |
| Teradata | DOUBLE PRECISION | DOUBLE PRECISION | 8-byte float |

**Optimization Tips:**
- Use NUMERIC instead of DOUBLE when precision ≤ 18 digits for better compression
- Avoid FLOAT for financial calculations due to precision issues
- Consider INTEGER for counts and IDs when range allows

### Character Types

#### Fixed and Variable Length

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|----------------|
| DB2 | CHAR(n) | CHAR(n) | Fixed-length character |
| DB2 | CLOB | LONG VARCHAR | Large text (up to 32MB) |
| DB2 | DBCLOB | LONG VARCHAR | Large DBCS text, UTF-8 |
| DB2 | GRAPHIC(n) | CHAR(n) | DBCS character |
| DB2 | VARCHAR(n) | VARCHAR(n) | Variable-length character |
| DB2 | VARCHAR(32672) | VARCHAR(65000) | Adjust to Vertica limits |
| DB2 | VARGRAPHIC(n) | VARCHAR(n) | Variable DBCS |
| MySQL | CHAR(n) | CHAR(n) | Fixed length |
| MySQL | ENUM(...) | VARCHAR(255) | Store as string |
| MySQL | LONGTEXT | LONG VARCHAR | Very large text |
| MySQL | MEDIUMTEXT | LONG VARCHAR | Large text |
| MySQL | TEXT | LONG VARCHAR | Large text |
| MySQL | TINYTEXT | VARCHAR(255) | Small text, max 255 bytes |
| MySQL | VARCHAR(n) | VARCHAR(n) | Variable length |
| Oracle | CHAR(n) | CHAR(n) | Fixed length, pad with spaces |
| Oracle | CLOB | LONG VARCHAR | Large text (up to 32MB) |
| Oracle | NCLOB | LONG VARCHAR | Large text, UTF-8 |
| Oracle | VARCHAR2(n) | VARCHAR2(n), or VARCHAR(n) | Variable length |
| PostgreSQL | CHAR(n) | CHAR(n) | Fixed length |
| PostgreSQL | NAME | VARCHAR(64) | PostgreSQL internal type |
| PostgreSQL | TEXT | LONG VARCHAR | Large text |
| PostgreSQL | VARCHAR(n) | VARCHAR(n) | Variable length |
| SQL Server | CHAR(n) | CHAR(n) | Fixed length |
| SQL Server | NCHAR(n) | CHAR(n) | Unicode, use CHAR in Vertica |
| SQL Server | NVARCHAR(n) | VARCHAR(n) | Vertica is Unicode by default |
| SQL Server | NTEXT | LONG VARCHAR | Deprecated, UTF-8 |
| SQL Server | TEXT | LONG VARCHAR | Large text |
| SQL Server | VARCHAR(n) | VARCHAR(n) | Variable length |
| Teradata | CHAR(n) | CHAR(n) | Fixed length |
| Teradata | VARCHAR(n) | VARCHAR(n) | Variable length |
| Teradata | LONG VARCHAR | LONG VARCHAR | Large text |

**Size Limits:**
- VARCHAR: Up to 65,000 characters
- LONG VARCHAR: Up to 32,000,000 characters
- CHAR: Up to 65,000 characters (less efficient than VARCHAR)

**Optimization Tips:**
- Use VARCHAR instead of CHAR for variable-length data
- Consider compression encoding for text columns
- Use appropriate length limits to optimize storage

### Binary Types

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|----------------|
| DB2 | BINARY(n) | BINARY(n) | Fixed-length binary |
| DB2 | BLOB | LONG VARBINARY | Large binary objects |
| DB2 | VARBINARY(n) | VARBINARY(n) | Variable-length binary |
| MySQL | BINARY(n) | BINARY(n) | Fixed binary |
| MySQL | BLOB | LONG VARBINARY | Large binary |
| MySQL | LONGBLOB | LONG VARBINARY | Very large binary |
| MySQL | MEDIUMBLOB | LONG VARBINARY | Medium binary |
| MySQL | TINYBLOB | VARBINARY(255) | Small binary, max 255 bytes |
| MySQL | VARBINARY(n) | VARBINARY(n) | Variable binary |
| Oracle | BLOB | LONG VARBINARY | Large binary |
| Oracle | RAW(n) | VARBINARY(n) | Binary data |
| PostgreSQL | BYTEA | VARBINARY | Binary data |
| SQL Server | BINARY(n) | BINARY(n) | Fixed binary |
| SQL Server | IMAGE | LONG VARBINARY | Large binary |
| SQL Server | VARBINARY(n) | VARBINARY(n) | Variable binary |
| Teradata | VARBYTE | VARBINARY | Variable-length binary |
| Teradata | BYTE | VARBINARY | Fixed-length binary |
| Teradata | BLOB | LONG VARBINARY | Large binary objects |

**Size Limits:**
- VARBINARY: Up to 65,000 bytes
- LONG VARBINARY: Up to 32,000,000 bytes

### Date and Time Types

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|----------------|
| DB2 | DATE | DATE | Date only |
| DB2 | TIME | TIME | Time only |
| DB2 | TIMESTAMP | TIMESTAMP | Date and time |
| DB2 | TIMESTAMP(p) | TIMESTAMP(p) | Precision matching |
| MySQL | DATE | DATE | Date only |
| MySQL | DATETIME | TIMESTAMP | Date and time |
| MySQL | TIME | TIME | Time only |
| MySQL | TIMESTAMP | TIMESTAMP | Unix timestamp |
| MySQL | YEAR | SMALLINT | Store as smallint |
| Oracle | DATE | TIMESTAMP | Includes time |
| Oracle | TIMESTAMP | TIMESTAMP | Same precision |
| Oracle | TIMESTAMP WITH TIME ZONE | TIMESTAMP WITH TIME ZONE | Timezone aware |
| PostgreSQL | DATE | DATE | Date only |
| PostgreSQL | INTERVAL | INTERVAL | Time intervals |
| PostgreSQL | TIME | TIME | Time only |
| PostgreSQL | TIMESTAMP | TIMESTAMP | Date and time |
| PostgreSQL | TIMESTAMPTZ | TIMESTAMP WITH TIME ZONE | Timezone aware |
| SQL Server | DATE | DATE | Date only |
| SQL Server | DATETIME | TIMESTAMP | Date and time |
| SQL Server | DATETIME2 | TIMESTAMP | High precision |
| SQL Server | SMALLDATETIME | TIMESTAMP | Lower precision |
| SQL Server | TIME | TIME | Time only |
| Teradata | DATE | TIMESTAMP | Teradata DATE includes time component |
| Teradata | TIME(p) | TIME(p) | Time with precision |
| Teradata | TIMESTAMP(p) | TIMESTAMP(p) | Date and time with precision |
| Teradata | INTERVAL | INTERVAL | Time intervals |

**Interval Types:**
- INTERVAL DAY TO SECOND: For time intervals
- INTERVAL YEAR TO MONTH: For year/month intervals

### Boolean Type

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| DB2 | BOOLEAN | BOOLEAN | True/False values |
| MySQL | BOOLEAN | BOOLEAN | Synonym for TINYINT(1) |
| Oracle | NUMBER(1) | BOOLEAN | Convert 0/1 to FALSE/TRUE |
| PostgreSQL | BOOLEAN | BOOLEAN | TRUE/FALSE/UNKNOWN |
| SQL Server | BIT | BOOLEAN | Convert 0/1 to FALSE/TRUE |
| Teradata | BOOLEAN | BOOLEAN | TRUE/FALSE values |

## Advanced Data Types

### UUID Type

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| MySQL | UUID() | UUID | Function result |
| Oracle | SYS_GUID() | UUID | Function result |
| PostgreSQL | UUID | UUID | Standard UUID |
| SQL Server | UNIQUEIDENTIFIER | UUID | Convert format |

### Spatial Types

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| Oracle | SDO_GEOMETRY | GEOMETRY | Convert format |
| PostgreSQL | GEOGRAPHY | GEOGRAPHY | Geographic data |
| PostgreSQL | GEOMETRY | GEOMETRY | Spatial data |
| SQL Server | GEOGRAPHY | GEOGRAPHY | Geographic data |
| SQL Server | GEOMETRY | GEOMETRY | Spatial data |

### Array/Collection Type Mappings

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| DB2 | `ROW` type | `ROW` type | Direct mapping - preserves structured type with named fields |
| MySQL | `SET(...)` | `SET[type]` | Direct mapping - both store unordered unique values |
| Oracle | VARRAY | `ARRAY[type]` | Direct mapping - both are ordered collections with defined limits |
| Oracle | Nested tables | `ARRAY[type]` | Direct mapping - both store unbounded ordered collections |
| PostgreSQL | `ARRAY[type]` | `ARRAY[type]` | Direct mapping - both are ordered collections (1-based index) |
| PostgreSQL | `JSON` array | `ARRAY[type]` | Cast JSON array elements to typed array |
| SQL Server | `TABLE` type (table variables) | `ARRAY[type]` or `ROW` type | ARRAY for simple lists, ROW for structured data |

**Syntax Differences**:
- PostgreSQL `UNNEST`: Use in `FROM` clause, not `SELECT` clause
  - PostgreSQL: `SELECT id, UNNEST(tags) FROM t`
  - Vertica: `SELECT id, tag FROM t, UNNEST(tags) AS tag`

### JSON and Semi-Structured Data

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| MySQL | `JSON` type | Flex Tables or `LONG VARCHAR` | Event data, configurations, dynamic schemas |
| PostgreSQL | `JSON` / `JSONB` | Flex Tables | Dynamic JSON schemas, need to query JSON fields directly |
| SQL Server | JSON functions | Flex Tables | JSON array shredding, `OPENJSON` results |

**When to Use Flex Tables vs LONG VARCHAR**:
- **Flex Tables**: Dynamic schemas, need to query JSON fields, ad-hoc queries
- **LONG VARCHAR**: Simple storage, known structure with application-layer parsing, performance-critical bulk loads

See [CREATE FLEX TABLE](sql-syntax-reference.md#create-flex-table) for complete syntax reference.

### Other Types

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| DB2 | ROWID | VARCHAR(64) | Row identifier |
| DB2 | XML | LONG VARCHAR | Store as text |
| Teradata | `PERIOD(DATE)` / `PERIOD(TIMESTAMP)` | Two columns: `start_col`, `end_col` | No direct type; store period boundaries as separate columns |

## Complex Types (Vertica-Specific)

### ARRAY Type
Vertica supports arrays for storing multiple values in a single column:

```sql
-- Create table with array column
CREATE TABLE products (
    id INTEGER,
    name VARCHAR(100),
    tags ARRAY[VARCHAR(50)],
    prices ARRAY[NUMERIC(10,2)]
);

-- Insert array data
INSERT INTO products VALUES (
    1, 'Laptop', 
    ARRAY['electronics', 'portable', 'computer'],
    ARRAY[999.99, 899.99, 799.99]
);
```

### ROW Type
For structured data with named fields:

```sql
-- Create table with ROW column
CREATE TABLE orders (
    order_id INTEGER,
    customer_info ROW(
        name VARCHAR(100),
        email VARCHAR(100),
        phone VARCHAR(20)
    ),
    shipping_address ROW(
        street VARCHAR(200),
        city VARCHAR(100),
        zip_code VARCHAR(20)
    )
);
```

### SET Type
For unordered collections of unique values:

```sql
-- Create table with SET column
CREATE TABLE users (
    user_id INTEGER,
    username VARCHAR(50),
    permissions SET[VARCHAR(50)]
);

-- Insert data using SET literal syntax
INSERT INTO users VALUES (1, 'admin', SET['read', 'write', 'delete']);
```

## Data Type Optimization Strategies

### 1. Choose Appropriate Precision

```sql
-- Instead of generic NUMERIC
CREATE TABLE transactions (
    amount NUMERIC(18,2)  -- Appropriate precision
);

-- Avoid oversized types
CREATE TABLE user_ids (
    id INTEGER,  -- Instead of BIGINT if < 2B records
    status TINYINT  -- Instead of INTEGER for 0-255 range
);
```

### 2. Use Efficient String Types

```sql
-- Use VARCHAR instead of CHAR for variable length
CREATE TABLE customers (
    name VARCHAR(100),  -- Instead of CHAR(100)
    email VARCHAR(255)
);

-- Use appropriate length limits
CREATE TABLE products (
    sku VARCHAR(20),  -- Not VARCHAR(65000) for SKU
    description VARCHAR(1000)
);
```

### 3. Optimize Date/Time Storage

```sql
-- Use DATE when time not needed
CREATE TABLE events (
    event_date DATE,  -- Instead of TIMESTAMP
    event_time TIME,
    created_at TIMESTAMP
);

-- Consider partitioning by date
CREATE TABLE logs (
    log_date DATE,
    message VARCHAR(1000)
) PARTITION BY log_date;
```

### 4. Handle NULL Values Efficiently

```sql
-- Use NOT NULL when appropriate
CREATE TABLE users (
    id INTEGER NOT NULL,
    username VARCHAR(50) NOT NULL,
    last_login TIMESTAMP  -- Can be NULL
);

-- Consider default values
CREATE TABLE orders (
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Performance Considerations

### Storage Efficiency
1. **Smaller is Better**: Use the smallest data type that meets requirements
2. **Fixed vs Variable**: VARCHAR typically better than CHAR for variable data
3. **Precision Matters**: NUMERIC(10,2) compresses better than DOUBLE

### Query Performance
1. **Predicate Pushdown**: Appropriate data types enable better filtering
2. **Sort Performance**: Smaller data types sort faster
3. **Join Performance**: Matching data types avoid runtime conversions

### Compression Benefits
1. **RLE Encoding**: Works best with low-cardinality columns
2. **Delta Encoding**: Effective for sorted numeric data
3. **LZO/GZIP**: Good for text and large binary data

### Best Practices Summary

1. **Analyze Data Requirements**: Choose types based on actual data ranges
2. **Consider Query Patterns**: Optimize for common WHERE clauses and JOINs
3. **Plan for Growth**: Allow reasonable headroom without over-sizing
4. **Test Performance**: Compare different type choices with real queries
5. **Use Constraints**: NOT NULL and CHECK constraints improve optimization

This guide provides a foundation for effective data type mapping and optimization when migrating to Vertica's columnar storage architecture.
