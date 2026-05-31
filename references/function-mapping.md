# Function Mapping Guide

This guide provides comprehensive mapping between common database functions and their Vertica equivalents, along with optimization recommendations.

## Aggregate Functions

### Standard Aggregates

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| All | COUNT(*) | COUNT(*) | Optimized for columnar storage |
| All | COUNT(column) | COUNT(column) | Ignores NULLs automatically |
| All | SUM(column) | SUM(column) | Use NUMERIC for precision > 18 digits |
| All | AVG(column) | AVG(column) | Returns DOUBLE PRECISION |
| All | MIN(column) | MIN(column) | Efficient on sorted projections |
| All | MAX(column) | MAX(column) | Efficient on sorted projections |
| Oracle | MEDIAN(column) | MEDIAN(column), or PERCENTILE_CONT(0.5) | Use analytic function |
| SQL Server | STDEV(column) | STDDEV(column) | Sample standard deviation |
| SQL Server | STDEVP(column) | STDDEV_POP(column) | Population standard deviation |
| PostgreSQL | CORR(x,y) | CORR(x,y) | Correlation coefficient |

### Approximate Functions (Performance Optimized)

| Function | Vertica Equivalent | Use Case |
|----------|-------------------|----------|
| COUNT(DISTINCT column) | APPROXIMATE_COUNT_DISTINCT(column) | Large datasets, 2-3% error acceptable |
| PERCENTILE(column, 0.95) | APPROXIMATE_PERCENTILE(column USING PARAMETERS percentile=0.95) | Fast percentile calculations |
| MODE(column) | *No direct equivalent* | Use analytic functions with ROW_NUMBER() and COUNT() |

## String Functions

### Basic String Operations

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| Oracle: SUBSTR(str, start, length) | SUBSTR(str, start, length) | Same syntax |
| SQL Server: SUBSTRING(str, start, length) | SUBSTRING(str FROM start FOR length) | ANSI standard |
| All: LENGTH(str) | LENGTH(str) | Character length |
| All: CHAR_LENGTH(str) | LENGTH(str) | Alias for LENGTH |
| Oracle: INSTR(str, substr) | POSITION(substr IN str) | Returns position |
| SQL Server: CHARINDEX(substr, str) | POSITION(substr IN str) | ANSI standard |
| All: UPPER(str) | UPPER(str) | Case conversion |
| All: LOWER(str) | LOWER(str) | Case conversion |
| Oracle: INITCAP(str) | INITCAP(str) | First letter uppercase |

### Advanced String Functions

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| Oracle: REGEXP_REPLACE(str, pattern, replacement) | REGEXP_REPLACE(str, pattern, replacement) | Full regex support |
| PostgreSQL: REGEXP_MATCHES(str, pattern) | REGEXP_SUBSTR(str, pattern) | Extract matches |
| SQL Server: REPLICATE(str, count) | REPEAT(str, count) | String repetition |
| Oracle: LPAD(str, length, pad) | LPAD(str, length, pad) | Left padding |
| Oracle: RPAD(str, length, pad) | RPAD(str, length, pad) | Right padding |
| PostgreSQL: STRING_AGG(str, delimiter) | LISTAGG(str, delimiter) | String concatenation |

## Date and Time Functions

### Current Date/Time

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| All: CURRENT_DATE | CURRENT_DATE | Date only |
| All: CURRENT_TIMESTAMP | CURRENT_TIMESTAMP | Timestamp with timezone |
| Oracle: SYSDATE | SYSDATE() | Date and time |
| SQL Server: GETDATE() | NOW() | Current timestamp |
| PostgreSQL: CURRENT_TIME | CURRENT_TIME | Time only |

### Date Arithmetic

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| Oracle: ADD_MONTHS(date, n) | ADD_MONTHS(date, n) | Add months to date |
| SQL Server: DATEADD(interval, n, date) | date + INTERVAL 'n' interval | ANSI standard |
| PostgreSQL: date + INTERVAL '1 day' | date + INTERVAL '1 day' | Same syntax |
| Oracle: MONTHS_BETWEEN(date1, date2) | MONTHS_BETWEEN(date1, date2) | Month difference |
| All: EXTRACT(YEAR FROM date) | EXTRACT(YEAR FROM date) | Extract date parts |

### Date Formatting

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| Oracle: TO_CHAR(date, format) | TO_CHAR(date, format) | Same function |
| SQL Server: CONVERT(VARCHAR, date, style) | TO_CHAR(date, format) | Use format strings |
| PostgreSQL: TO_CHAR(date, format) | TO_CHAR(date, format) | Same function |
| Oracle: TO_DATE(string, format) | TO_DATE(string, format) | Parse date strings |

## Mathematical Functions

### Basic Math

| Function | Vertica Support | Notes |
|----------|----------------|-------|
| ABS(x) | ABS(x) | Absolute value |
| CEIL(x) | CEIL(x) | Round up |
| FLOOR(x) | FLOOR(x) | Round down |
| ROUND(x, decimals) | ROUND(x, decimals) | Round to decimals |
| TRUNC(x, decimals) | TRUNC(x, decimals) | Truncate decimals |
| MOD(x, y) | MOD(x, y) | Modulo operation |

### Advanced Math

| Function | Vertica Support | Notes |
|----------|----------------|-------|
| POWER(x, y) | POWER(x, y) | Exponentiation |
| SQRT(x) | SQRT(x) | Square root |
| LOG(base, x) | LOG(base, x) | Logarithm |
| LN(x) | LN(x) | Natural logarithm |
| EXP(x) | EXP(x) | Exponential |
| SIN/COS/TAN(x) | SIN/COS/TAN(x) | Trigonometric functions |


## UUID Functions

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| SQL Server: NEWID() | UUID_GENERATE() | Generate random UUID (GUID) |
| MySQL: UUID() | UUID_GENERATE() | Generate random UUID |
| PostgreSQL: GEN_RANDOM_UUID() | UUID_GENERATE() | Generate random UUID v4 |
| DB2: GENERATE_UUID() | UUID_GENERATE() | Generate random UUID |



## Analytic Functions

### Window Functions

| Function | Vertica Support | Optimization Notes |
|----------|----------------|-------------------|
| ROW_NUMBER() | ROW_NUMBER() | Efficient with proper partitioning |
| RANK() | RANK() | Handles ties correctly |
| DENSE_RANK() | DENSE_RANK() | No gaps in ranking |
| LEAD(column, n) | LEAD(column, n) | Access future rows |
| LAG(column, n) | LAG(column, n) | Access previous rows |
| FIRST_VALUE(column) | FIRST_VALUE(column) | First value in window |
| LAST_VALUE(column) | LAST_VALUE(column) | Last value in window |

### Statistical Functions

| Function | Vertica Support | Notes |
|----------|----------------|-------|
| CUME_DIST() | CUME_DIST() | Cumulative distribution |
| NTILE(n) | NTILE(n) | Divide into n buckets |
| PERCENT_RANK() | PERCENT_RANK() | Percent rank |
| PERCENTILE_CONT(0.5) | PERCENTILE_CONT(0.5) | Continuous percentile |
| PERCENTILE_DISC(0.5) | PERCENTILE_DISC(0.5) | Discrete percentile |

## Type Conversion Functions

### Explicit Casting

| Source Function | Vertica Equivalent | Notes |
|----------------|-------------------|-------|
| Oracle: TO_NUMBER(string) | TO_NUMBER(string), or CAST(string AS NUMERIC) | |
| SQL Server: CAST(string AS INT) | CAST(string AS INT), or CAST(string AS INTEGER) | |
| PostgreSQL: string::INTEGER | string::INTEGER, or CAST(string AS INTEGER) | |
| Oracle: TO_CHAR(number) | TO_CHAR(number), or CAST(number AS VARCHAR) | Convert to string |
| Oracle: NVL(a, b) | NVL(a, b), or COALESCE(a, b) | |
| SQL Server: ISNULL(a, b) | ISNULL(a, b), or COALESCE(a, b) | |

### Implicit Conversion Rules

1. **Numeric Promotion**: INTEGER → BIGINT → NUMERIC → DOUBLE
2. **String Concatenation**: Numbers automatically converted to strings
3. **Date Arithmetic**: Compatible date/time types can be combined
4. **Boolean Context**: Non-zero numbers treated as TRUE

## System Functions

### Information Functions

| Function | Vertica Equivalent | Purpose |
|----------|-------------------|---------|
| USER | CURRENT_USER | Current user name |
| DATABASE() | CURRENT_DATABASE | Current database |
| SCHEMA() | CURRENT_SCHEMA | Current schema |
| VERSION() | VERSION() | Database version |
| SESSION_ID | CURRENT_SESSION | Session identifier |

### Management Functions

| Function Category | Key Functions | Purpose |
|------------------|---------------|---------|
| Statistics | ANALYZE_STATISTICS, PURGE_STATISTICS | Query optimization |
| Monitoring | GET_NUM_NODES, GET_CLUSTER_SIZE | Cluster information |
| Configuration | SET_CONFIG_PARAMETER, RESET_CONFIG_PARAMETER | System settings |
| Storage | GET_PARTITIONS, PURGE_PARTITION | Data management |

## Performance Recommendations

### Function Usage Guidelines

1. **Use Approximate Functions** for large datasets:
   ```sql
   -- Prerequisite table
   CREATE TABLE IF NOT EXISTS large_table (user_id INTEGER);
   
   -- Instead of COUNT(DISTINCT user_id)
   SELECT APPROXIMATE_COUNT_DISTINCT(user_id) FROM large_table;
   ```

2. **Leverage Analytic Functions** instead of self-joins:
   ```sql
   -- Prerequisite table
   CREATE TABLE IF NOT EXISTS sample_table (id INTEGER, value NUMERIC);
   
   -- Instead of self-join for previous value
   SELECT id, value, LAG(value, 1) OVER (ORDER BY id) as prev_value
   FROM sample_table;
   ```

3. **Use Proper Data Types** for optimal performance:
   ```sql
   -- Prerequisite table
   CREATE TABLE IF NOT EXISTS transactions (amount NUMERIC);
   
   -- Use NUMERIC for precise calculations
   SELECT AVG(CAST(amount AS NUMERIC(18,2))) FROM transactions;
   ```

4. **Minimize Type Conversions** in WHERE clauses:
   ```sql
   -- Avoid: WHERE CAST(date_col AS DATE) = '2024-01-01'
   -- Use: WHERE date_col = DATE '2024-01-01'
   ```

### Function Performance Characteristics

- **IMMUTABLE**: Same output for same input, can be optimized
- **STABLE**: Same output within transaction, good for optimization
- **VOLATILE**: May return different values, limits optimization

Check function volatility to understand optimization potential.
