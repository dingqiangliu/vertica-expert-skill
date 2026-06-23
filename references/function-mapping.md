# Function Mapping Guide

This guide provides comprehensive mapping between common database functions and their Vertica equivalents, along with optimization recommendations.

## String Functions

### Basic String Operations

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| All | CHAR_LENGTH(str) | LENGTH(str) | Alias for LENGTH |
| All | CONCAT(str1, str2, ...) | CONCAT(str1, str2) | String concatenation (Vertica only supports 2 arguments, nest for multiple: `CONCAT(a, CONCAT(b, c))`) |
| All | LENGTH(str) | LENGTH(str) | Character length |
| All | LOWER(str) | LOWER(str) | Case conversion |
| All | str1 \|\| str2 | str1 \|\| str2 | String concatenation operator |
| All | UPPER(str) | UPPER(str) | Case conversion |
| DB2 | LCASE(str) | LOWER(str) | Lowercase conversion |
| DB2 | LOCATE(sub, str) | INSTR(str, sub) | Returns position (note: argument order differs) |
| DB2 | POSSTR(str, sub) | INSTR(str, sub) | Returns position of substring |
| DB2 | STRIP(str) | TRIM(str) | Remove leading/trailing spaces |
| DB2 | SUBSTR(str, start, length) | SUBSTR(str, start, length) | Same syntax |
| DB2 | TRIM(BOTH ' ' FROM str) | TRIM(str) | DB2 supports BOTH/LEADING/TRAILING prefix |
| DB2 | UCASE(str) | UPPER(str) | Uppercase conversion |
| MySQL | REPLACE(string, old, new) | REPLACE(string, old, new) | String replacement |
| Oracle | INITCAP(str) | INITCAP(str) | First letter uppercase |
| Oracle | INSTR(str, substr) | POSITION(substr IN str) | Returns position |
| Oracle | SUBSTR(str, start, length) | SUBSTR(str, start, length) | Same syntax |
| SQL Server | CHARINDEX(substr, str) | POSITION(substr IN str) | ANSI standard |
| SQL Server | LEN(string) | LENGTH(string) | String length in characters |
| SQL Server | str1 + str2 | str1 \|\| str2 | SQL Server uses + for string concatenation |
| SQL Server | SUBSTRING(str, start, length) | SUBSTRING(str FROM start FOR length) | ANSI standard |

### Advanced String Functions

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| DB2 | XMLAGG(XMLELEMENT(...) ORDER BY ...) | LISTAGG(col USING PARAMETERS separator=', ') | Convert XML aggregate to LISTAGG |
| MySQL | GROUP_CONCAT(col) | LISTAGG(col USING PARAMETERS separator=', ') | String aggregation (no direct CONCAT_WS equivalent) |
| Oracle | LISTAGG(col, delim) WITHIN GROUP (ORDER BY col) | LISTAGG(col USING PARAMETERS separator=delim) WITHIN GROUP (ORDER BY col) | Oracle WITHIN GROUP syntax |
| Oracle | LPAD(str, length, pad) | LPAD(str, length, pad) | Left padding |
| Oracle | REGEXP_REPLACE(str, pattern, replacement) | REGEXP_REPLACE(str, pattern, replacement) | Full regex support |
| Oracle | RPAD(str, length, pad) | RPAD(str, length, pad) | Right padding |
| PostgreSQL | FORMAT(format, args...) | *No direct equivalent* | Use CONCAT or string functions |
| PostgreSQL | REGEXP_MATCHES(str, pattern) | REGEXP_SUBSTR(str, pattern) | Extract matches |
| PostgreSQL | STRING_AGG(str, delimiter) | LISTAGG(col USING PARAMETERS separator=delim) | String concatenation |
| SQL Server | ISNUMERIC(str) | REGEXP_LIKE(str, '^[eE0-9.+-]+$') | Matches digits, decimal point, signs, and scientific notation (e/E) |
| SQL Server | PATINDEX(pattern, str) | REGEXP_INSTR(str, pattern) | Pattern matching with regex |
| SQL Server | REPLICATE(str, count) | REPEAT(str, count) | String repetition |

## Date and Time Functions

### Current Date/Time

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| All | CURRENT_DATE | CURRENT_DATE | Date only |
| All | CURRENT_TIMESTAMP | CURRENT_TIMESTAMP | Timestamp with timezone |
| MySQL | CURDATE() | CURRENT_DATE() | Current date |
| MySQL | CURTIME() | CURRENT_TIME() | Current time |
| MySQL | NOW() | NOW() or SYSDATE() | Current date/time |
| MySQL | UTC_DATE() | CURRENT_DATE::DATE AT TIME ZONE 'GMT' | Current date in UTC |
| MySQL | UTC_TIME() | CURRENT_TIME::TIME AT TIME ZONE 'GMT' | Current time in UTC |
| MySQL | UTC_TIMESTAMP() | CURRENT_TIMESTAMP::TIMESTAMP AT TIME ZONE 'GMT' | Current timestamp in UTC |
| Oracle | SYSDATE | SYSDATE() | Date and time |
| PostgreSQL | CURRENT_TIME | CURRENT_TIME | Time only. SQL standard keyword, not a function — no parentheses |
| SQL Server | GETDATE() | GETDATE(), or NOW(), or SYSDATE() | Current timestamp |

### Date Arithmetic

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| All | EXTRACT(YEAR FROM date) | EXTRACT(YEAR FROM date) | Extract date parts |
| DB2 | DAYS_BETWEEN(d1, d2) | d1 - d2 | Returns integer day difference |
| MySQL | DATE_ADD(date, INTERVAL n unit) | date + INTERVAL 'n' unit | Date addition |
| MySQL | DATE_SUB(date, INTERVAL n unit) | date - INTERVAL 'n' unit | Date subtraction |
| MySQL | DATEDIFF(date1, date2) | date1 - date2 | Date difference in days |
| MySQL | FROM_UNIXTIME(n) | TO_TIMESTAMP(n) | Convert Unix timestamp to timestamp |
| MySQL | TIMEDIFF(t1, t2) | t1 - t2 | Time difference |
| MySQL | UNIX_TIMESTAMP(d) | EXTRACT(EPOCH FROM d) | Convert date to Unix timestamp |
| Oracle | ADD_MONTHS(date, n) | ADD_MONTHS(date, n) | Add months to date |
| Oracle | MONTHS_BETWEEN(date1, date2) | MONTHS_BETWEEN(date1, date2) | Month difference |
| PostgreSQL | date + INTERVAL '1 day' | date + INTERVAL '1 day' | Same syntax |
| PostgreSQL | AGE(timestamp) | DATEDIFF('year', timestamp, CURRENT_DATE) | Age calculation |
| SQL Server | DATEADD(interval, n, date) | date + INTERVAL 'n' interval | ANSI standard |
| SQL Server | DATEDIFF(unit, start, end) | EXTRACT(unit FROM end - start) | Date difference |

### Date Formatting

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| MySQL | DATE_FORMAT(d, fmt) | TO_CHAR(d, fmt) | Format date/time. Vertica uses ISO 8601 / ANSI SQL format (e.g. 'YYYY-MM-DD'), not MySQL-style '%Y-%m-%d'. Uppercase 'YYYY'=year, 'MM'=month, 'DD'=day |
| MySQL | STR_TO_DATE(str, fmt) | TO_DATE(str, fmt) | Parse date string. Vertica uses ISO 8601 / ANSI SQL format, not MySQL-style '%Y-%m-%d' |
| MySQL | TIME_FORMAT(t, fmt) | TO_CHAR(t, fmt) | Format time. Vertica uses ISO 8601 / ANSI SQL format, not MySQL-style '%H:%i:%s' |
| Oracle | TO_CHAR(date, format) | TO_CHAR(date, format) | Same function |
| Oracle | TO_DATE(string, format) | TO_DATE(string, format) | Parse date strings |
| PostgreSQL | TO_CHAR(date, format) | TO_CHAR(date, format) | Same function |
| SQL Server | CONVERT(VARCHAR, date, style) | TO_CHAR(date, format) | Use format strings |

## Mathematical Functions

### Basic Math

| Source DB | Function | Vertica Support | Notes |
|-----------|----------|----------------|-------|
| All | ABS(x) | ABS(x) | Absolute value |
| All | CEIL(x) | CEIL(x) | Round up |
| All | FLOOR(x) | FLOOR(x) | Round down |
| All | MOD(x, y) | MOD(x, y) | Modulo operation |
| All | ROUND(x, decimals) | ROUND(x, decimals) | Round to decimals |
| All | TRUNC(x, decimals) | TRUNC(x, decimals) | Truncate decimals |

### Advanced Math

| Source DB | Function | Vertica Support | Notes |
|-----------|----------|----------------|-------|
| All | EXP(x) | EXP(x) | Exponential |
| All | LN(x) | LN(x) | Natural logarithm |
| All | LOG(base, x) | LOG(base, x) | Logarithm |
| All | POWER(x, y) | POWER(x, y) | Exponentiation |
| All | SIN/COS/TAN(x) | SIN/COS/TAN(x) | Trigonometric functions |
| All | SQRT(x) | SQRT(x) | Square root |


## UUID Functions

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| DB2 | GENERATE_UUID() | UUID_GENERATE() | Generate random UUID |
| MySQL | UUID() | UUID_GENERATE() | Generate random UUID |
| PostgreSQL | GEN_RANDOM_UUID() | UUID_GENERATE() | Generate random UUID v4 |
| SQL Server | NEWID() | UUID_GENERATE() | Generate random UUID (GUID) |

## Aggregate Functions

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| All | COUNT(*) | COUNT(*) | Optimized for columnar storage |
| All | COUNT(column) | COUNT(column) | Ignores NULLs automatically |
| All | SUM(column) | SUM(column) | Use NUMERIC for precision > 18 digits |
| All | AVG(column) | AVG(column) | Returns DOUBLE PRECISION |
| All | MIN(column) | MIN(column) | Efficient on sorted projections |
| All | MAX(column) | MAX(column) | Efficient on sorted projections |
| Oracle | MEDIAN(column) | MEDIAN(column), or PERCENTILE_CONT(0.5) | Use analytic function. Must include OVER clause: `MEDIAN(column) OVER ()` |
| SQL Server | STDEV(column) | STDDEV(column) | Sample standard deviation |
| SQL Server | STDEVP(column) | STDDEV_POP(column) | Population standard deviation |
| PostgreSQL | CORR(x,y) | CORR(x,y) | Correlation coefficient |

## Analytic Functions

| Source DB | Function | Vertica Support | Optimization Notes |
|-----------|----------|----------------|-------------------|
| All | CUME_DIST() | CUME_DIST() | Cumulative distribution |
| All | DENSE_RANK() | DENSE_RANK() | No gaps in ranking |
| All | FIRST_VALUE(column) | FIRST_VALUE(column) | First value in window |
| All | LAG(column, n) | LAG(column, n) | Access previous rows |
| All | LAST_VALUE(column) | LAST_VALUE(column) | Last value in window |
| All | LEAD(column, n) | LEAD(column, n) | Access future rows |
| All | NTILE(n) | NTILE(n) | Divide into n buckets |
| All | PERCENT_RANK() | PERCENT_RANK() | Percent rank |
| All | PERCENTILE_CONT(0.5) | PERCENTILE_CONT(0.5) | Continuous percentile. Use WITHIN GROUP syntax: `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY col)` |
| All | PERCENTILE_DISC(0.5) | PERCENTILE_DISC(0.5) | Discrete percentile. Use WITHIN GROUP syntax: `PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY col)` |
| All | RANK() | RANK() | Handles ties correctly |
| All | ROW_NUMBER() | ROW_NUMBER() | Efficient with proper partitioning |

## Type Conversion Functions

### Explicit Casting

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| DB2 | CHAR(expr) | CAST(expr AS VARCHAR) | Convert to string |
| DB2 | DECIMAL(expr, p, s) | CAST(expr AS NUMERIC(p,s)) | Fixed precision decimal conversion |
| DB2 | INTEGER(expr) | CAST(expr AS INTEGER) | Integer conversion |
| DB2 | VALUE(expr, default) | COALESCE(expr, default) | DB2-specific NULL handling |
| MySQL | IFNULL(value, replacement) | COALESCE(value, replacement) | NULL handling |
| Oracle | NVL(a, b) | NVL(a, b), or COALESCE(a, b) | |
| Oracle | TO_CHAR(number) | TO_CHAR(number), or CAST(number AS VARCHAR) | Convert to string |
| Oracle | TO_NUMBER(string) | TO_NUMBER(string), or CAST(string AS NUMERIC) | |
| PostgreSQL | NULLIF(value1, value2) | NULLIF(value1, value2) | Returns NULL if values are equal |
| PostgreSQL | string::INTEGER | string::INTEGER, or CAST(string AS INTEGER) | |
| SQL Server | CAST(string AS INT) | CAST(string AS INT), or CAST(string AS INTEGER) | |
| SQL Server | CONVERT(type, value) | CAST(value AS type) | Type conversion |
| SQL Server | ISNULL(a, b) | ISNULL(a, b), or COALESCE(a, b) | |
| SQL Server | TRY_CAST(expr AS type) | CAST(expr AS type) | No TRY_CAST in Vertica |
| SQL Server | TRY_CONVERT(type, expr) | CAST(expr AS type) | No TRY_CONVERT in Vertica |

### Implicit Conversion Rules

1. **Numeric Promotion**: INTEGER → BIGINT → NUMERIC → DOUBLE
2. **String Concatenation**: Numbers automatically converted to strings
3. **Date Arithmetic**: Compatible date/time types can be combined
4. **Boolean Context**: Non-zero numbers treated as TRUE

## Sequence Functions

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| DB2 | CURRVAL FOR seq_name | CURRVAL('seq_name') | Sequence current value (different syntax) |
| DB2 | NEXT VALUE FOR seq_name | NEXTVAL('seq_name') | Sequence next value (different syntax) |
| DB2 | NEXTVAL FOR sequence_name | NEXTVAL('sequence_name') | Sequence value (different syntax) |
| DB2 | PREVIOUS VALUE FOR seq_name | CURRVAL('seq_name') | Sequence current value (different syntax) |
| MySQL | NEXTVAL(seq) | NEXTVAL('seq') | Sequence next value (function syntax) |
| Oracle | seq.CURRVAL | CURRVAL('seq') | Sequence current value (property syntax) |
| Oracle | seq.NEXTVAL | NEXTVAL('seq') | Sequence next value (property syntax) |
| PostgreSQL | currval('seq') | CURRVAL('seq') | Sequence current value (same syntax) |
| PostgreSQL | nextval('seq') | NEXTVAL('seq') | Sequence next value (same syntax) |
| SQL Server | NEXT VALUE FOR seq_name | NEXTVAL('seq_name') | Sequence next value (different syntax) |

## JSON Functions

Vertica does not have native JSON type support. Use **Vertica Flex Tables** to store and query JSON data. Flex Tables load JSON natively into an internal VMap structure, allowing you to query virtual columns directly without pre-defining a schema.

| Source DB | Function | Vertica Flex Table Equivalent | Notes |
|-----------|----------|------------------------------|-------|
| MySQL | `JSON_EXTRACT(data, '$.name')` | `REGEXP_SUBSTR(data, '"name":"([^"]*)"', 1, 1, '', 1)` | Parse JSON using regex (store as text, parse externally) |
| PostgreSQL | `data @> '{"key":"value"}'` | `MAPLOOKUP(__raw__, 'key') = 'value'` | Use MAPLOOKUP for containment |
| PostgreSQL | `(data->>'age')::INTEGER` | `"age"::INT` | Cast virtual column to appropriate type |
| PostgreSQL | `data->'key'` (get JSON) | `"key"` (virtual column) | Query virtual column directly (returns JSON) |
| PostgreSQL | `data->>'key'` (get text) | `"key"` (virtual column) | Query virtual column directly (returns text) |
| PostgreSQL | `data IS NOT NULL` | `__raw__ IS NOT NULL` | Check raw column for NULL |
| PostgreSQL | `json_array_elements(data)` | *No direct equivalent* | Use Flex Table with UNNEST if needed |
| PostgreSQL | `json_each(data)` | Query `flex_table_keys` table | Discover all keys in JSON |

> **Note**: See [sql-syntax-reference.md#create-flex-table](sql-syntax-reference.md#create-flex-table) for detailed Flex Table usage including CREATE FLEX TABLE, loading JSON data, and querying virtual columns.

## Full-Text Search Functions

Use **Vertica Text Index** for efficient keyword search on text columns. Vertica text indexes use the Porter stemming algorithm and support case-sensitive/insensitive search, combined keyword queries, and exclusion patterns.

| Source DB | Function | Vertica Text Index Equivalent | Notes |
|-----------|----------|------------------------------|-------|
| PostgreSQL | `to_tsquery('english', '!exclude')` (NOT) | `NOT (id IN (SELECT doc_id FROM idx WHERE token = ...))` | Excludes keyword |
| PostgreSQL | `to_tsquery('english', 'search & term')` (AND) | Two `IN (...)` subqueries joined with `AND` | Must contain both keywords |
| PostgreSQL | `to_tsquery('english', 'search \| term')` (OR) | Two `IN (...)` subqueries joined with `OR` | Contains either keyword |
| PostgreSQL | `to_tsvector('english', content) @@ to_tsquery('english', 'term')` | `id IN (SELECT doc_id FROM idx WHERE token = v_txtindex.StemmerCaseInsensitive('term'))` | Basic keyword search |
| PostgreSQL | `ts_rank(tsvector, tsquery)` | Use `COUNT` of matching tokens | No direct ranking equivalent |

> **Note**: See [sql-syntax-reference.md#create-text-index](sql-syntax-reference.md#create-text-index) for detailed Text Index usage including CREATE TEXT INDEX, stemmer options, and query patterns.

## System Information Functions

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| All | DATABASE() | CURRENT_DATABASE | Current database |
| All | SCHEMA() | CURRENT_SCHEMA | Current schema |
| All | SESSION_ID | CURRENT_SESSION | Session identifier |
| All | USER | USER (or CURRENT_USER) | Current user name (USER and CURRENT_USER are synonyms in Vertica) |
| All | VERSION() | VERSION() | Database version |
| DB2 | CURRENT DATE | CURRENT_DATE | Direct mapping |
| DB2 | CURRENT SCHEMA | CURRENT_SCHEMA | Direct mapping |
| DB2 | CURRENT TIME | CURRENT_TIME | Direct mapping |
| DB2 | CURRENT TIMESTAMP | CURRENT_TIMESTAMP | Direct mapping |
| DB2 | CURRENT TIMEZONE | *No direct equivalent* | Returns current timezone setting with SHOW TIME ZONE statement |
| DB2 | CURRENT USER | CURRENT_USER | Direct mapping |

## Conditional Functions

| Source DB | Function | Vertica Equivalent | Notes |
|-----------|----------|-------------------|-------|
| MySQL | IF(cond, t, f) | CASE WHEN cond THEN t ELSE f END | Conditional expression |
