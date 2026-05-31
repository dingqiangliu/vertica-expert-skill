# Data Type Mapping and Optimization Guide

This guide provides comprehensive data type mappings from common databases to Vertica, along with optimization recommendations for columnar storage.

## Basic Data Type Mappings

### Numeric Types

#### Integer Types

| Source DB | Type | Vertica Equivalent | Recommendation |
|-----------|------|-------------------|----------------|
| Oracle | NUMBER(≤9 digits) | INTEGER | 4-byte signed integer |
| Oracle | NUMBER(10-18 digits) | BIGINT | 8-byte signed integer |
| Oracle | NUMBER(>18 digits) | NUMBER(p,s), or NUMERIC(p,s) | Variable precision |
| SQL Server | TINYINT | TINYINT | 1-byte unsigned (0-255) |
| SQL Server | SMALLINT | SMALLINT | 2-byte signed integer |
| SQL Server | INT | INTEGER | 4-byte signed integer |
| SQL Server | BIGINT | BIGINT | 8-byte signed integer |
| PostgreSQL | SMALLINT | SMALLINT | 2-byte signed integer |
| PostgreSQL | INTEGER | INTEGER | 4-byte signed integer |
| PostgreSQL | BIGINT | BIGINT | 8-byte signed integer |
| MySQL | TINYINT | TINYINT | 1-byte signed |
| MySQL | SMALLINT | SMALLINT | 2-byte signed |
| MySQL | MEDIUMINT | INTEGER | Use INTEGER |
| MySQL | INT | INTEGER | 4-byte signed |
| MySQL | BIGINT | BIGINT | 8-byte signed |

#### Decimal and Floating Point

| Source DB | Type | Vertica Equivalent | Recommendation |
|-----------|------|-------------------|----------------|
| Oracle | NUMBER(p,s) | NUMBER(p,s), or NUMERIC(p,s) | Same precision/scale |
| Oracle | FLOAT | DOUBLE PRECISION | 8-byte floating point |
| SQL Server | DECIMAL(p,s) | NUMERIC(p,s) | Exact numeric |
| SQL Server | NUMERIC(p,s) | NUMERIC(p,s) | Exact numeric |
| SQL Server | REAL | REAL | 4-byte float |
| SQL Server | FLOAT | DOUBLE PRECISION | 8-byte float |
| PostgreSQL | NUMERIC(p,s) | NUMERIC(p,s) | Exact numeric |
| PostgreSQL | DECIMAL(p,s) | NUMERIC(p,s) | Exact numeric |
| PostgreSQL | REAL | REAL | 4-byte float |
| PostgreSQL | DOUBLE PRECISION | DOUBLE PRECISION | 8-byte float |
| MySQL | DECIMAL(p,s) | NUMERIC(p,s) | Exact numeric |
| MySQL | FLOAT | REAL | 4-byte float |
| MySQL | DOUBLE | DOUBLE PRECISION | 8-byte float |

**Optimization Tips:**
- Use NUMERIC instead of DOUBLE when precision ≤ 18 digits for better compression
- Avoid FLOAT for financial calculations due to precision issues
- Consider INTEGER for counts and IDs when range allows

### Character Types

#### Fixed and Variable Length

| Source DB | Type | Vertica Equivalent | Recommendation |
|-----------|------|-------------------|----------------|
| Oracle | CHAR(n) | CHAR(n) | Fixed length, pad with spaces |
| Oracle | VARCHAR2(n) | VARCHAR2(n), or VARCHAR(n) | Variable length |
| Oracle | CLOB | LONG VARCHAR | Large text (up to 32MB) |
| SQL Server | CHAR(n) | CHAR(n) | Fixed length |
| SQL Server | VARCHAR(n) | VARCHAR(n) | Variable length |
| SQL Server | TEXT | LONG VARCHAR | Large text |
| SQL Server | NVARCHAR(n) | VARCHAR(n) | Vertica is Unicode by default |
| PostgreSQL | CHAR(n) | CHAR(n) | Fixed length |
| PostgreSQL | VARCHAR(n) | VARCHAR(n) | Variable length |
| PostgreSQL | TEXT | LONG VARCHAR | Large text |
| MySQL | CHAR(n) | CHAR(n) | Fixed length |
| MySQL | VARCHAR(n) | VARCHAR(n) | Variable length |
| MySQL | TEXT | LONG VARCHAR | Large text |
| MySQL | MEDIUMTEXT | LONG VARCHAR | Large text |
| MySQL | LONGTEXT | LONG VARCHAR | Very large text |

**Size Limits:**
- VARCHAR: Up to 65,000 characters
- LONG VARCHAR: Up to 32,000,000 characters
- CHAR: Up to 65,000 characters (less efficient than VARCHAR)

**Optimization Tips:**
- Use VARCHAR instead of CHAR for variable-length data
- Consider compression encoding for text columns
- Use appropriate length limits to optimize storage

### Binary Types

| Source DB | Type | Vertica Equivalent | Recommendation |
|-----------|------|-------------------|----------------|
| Oracle | RAW(n) | VARBINARY(n) | Binary data |
| Oracle | BLOB | LONG VARBINARY | Large binary |
| SQL Server | BINARY(n) | BINARY(n) | Fixed binary |
| SQL Server | VARBINARY(n) | VARBINARY(n) | Variable binary |
| SQL Server | IMAGE | LONG VARBINARY | Large binary |
| PostgreSQL | BYTEA | VARBINARY | Binary data |
| MySQL | BINARY(n) | BINARY(n) | Fixed binary |
| MySQL | VARBINARY(n) | VARBINARY(n) | Variable binary |
| MySQL | BLOB | LONG VARBINARY | Large binary |

**Size Limits:**
- VARBINARY: Up to 65,000 bytes
- LONG VARBINARY: Up to 32,000,000 bytes

### Date and Time Types

| Source DB | Type | Vertica Equivalent | Recommendation |
|-----------|------|-------------------|----------------|
| Oracle | DATE | TIMESTAMP | Includes time |
| Oracle | TIMESTAMP | TIMESTAMP | Same precision |
| Oracle | TIMESTAMP WITH TIME ZONE | TIMESTAMP WITH TIME ZONE | Timezone aware |
| SQL Server | DATE | DATE | Date only |
| SQL Server | TIME | TIME | Time only |
| SQL Server | DATETIME | TIMESTAMP | Date and time |
| SQL Server | DATETIME2 | TIMESTAMP | High precision |
| SQL Server | SMALLDATETIME | TIMESTAMP | Lower precision |
| PostgreSQL | DATE | DATE | Date only |
| PostgreSQL | TIME | TIME | Time only |
| PostgreSQL | TIMESTAMP | TIMESTAMP | Date and time |
| PostgreSQL | TIMESTAMPTZ | TIMESTAMP WITH TIME ZONE | Timezone aware |
| MySQL | DATE | DATE | Date only |
| MySQL | TIME | TIME | Time only |
| MySQL | DATETIME | TIMESTAMP | Date and time |
| MySQL | TIMESTAMP | TIMESTAMP | Unix timestamp |

**Interval Types:**
- INTERVAL DAY TO SECOND: For time intervals
- INTERVAL YEAR TO MONTH: For year/month intervals

### Boolean Type

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| PostgreSQL | BOOLEAN | BOOLEAN | TRUE/FALSE/UNKNOWN |
| MySQL | BOOLEAN | BOOLEAN | Synonym for TINYINT(1) |
| SQL Server | BIT | BOOLEAN | Convert 0/1 to FALSE/TRUE |
| Oracle | NUMBER(1) | BOOLEAN | Convert 0/1 to FALSE/TRUE |

## Advanced Data Types

### UUID Type

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| PostgreSQL | UUID | UUID | Standard UUID |
| SQL Server | UNIQUEIDENTIFIER | UUID | Convert format |
| MySQL | UUID() | UUID | Function result |
| Oracle | SYS_GUID() | UUID | Function result |

### Spatial Types

| Source DB | Type | Vertica Equivalent | Notes |
|-----------|------|-------------------|-------|
| PostgreSQL | GEOMETRY | GEOMETRY | Spatial data |
| PostgreSQL | GEOGRAPHY | GEOGRAPHY | Geographic data |
| SQL Server | GEOMETRY | GEOMETRY | Spatial data |
| SQL Server | GEOGRAPHY | GEOGRAPHY | Geographic data |
| Oracle | SDO_GEOMETRY | GEOMETRY | Convert format |

### Complex Types (Vertica-Specific)

#### ARRAY Type
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

#### ROW Type
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

#### SET Type
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

## Migration Examples

### Oracle to Vertica

```sql
-- Oracle
CREATE TABLE employees (
    emp_id NUMBER(6),
    emp_name VARCHAR2(100),
    hire_date DATE,
    salary NUMBER(10,2),
    dept_id NUMBER(3)
);

-- Vertica (optimized)
CREATE TABLE employees (
    emp_id INTEGER,
    emp_name VARCHAR(100),
    hire_date DATE,
    salary NUMERIC(10,2),
    dept_id SMALLINT
);
```

### SQL Server to Vertica

```sql
-- SQL Server
CREATE TABLE products (
    product_id INT IDENTITY(1,1),
    product_name NVARCHAR(255),
    price DECIMAL(10,2),
    created_date DATETIME DEFAULT GETDATE()
);

-- Vertica (optimized)
CREATE TABLE products (
    product_id INTEGER AUTO_INCREMENT,
    product_name VARCHAR(255),
    price NUMERIC(10,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### PostgreSQL to Vertica

```sql
-- PostgreSQL
CREATE TABLE orders (
    order_id SERIAL,
    customer_id INTEGER,
    order_date TIMESTAMP WITH TIME ZONE,
    total_amount NUMERIC(12,2),
    status TEXT
);

-- Vertica (optimized)
CREATE TABLE orders (
    order_id INTEGER AUTO_INCREMENT,
    customer_id INTEGER,
    order_date TIMESTAMP WITH TIME ZONE,
    total_amount NUMERIC(12,2),
    status VARCHAR(50)
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
