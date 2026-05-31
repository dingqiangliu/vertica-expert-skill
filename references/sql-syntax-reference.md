# Vertica SQL Syntax Reference

This comprehensive reference covers Vertica SQL syntax for database development, including DDL, DML, queries, and advanced features.

## Identifiers

Identifiers are names of database objects: schemas, tables, projections, columns, functions, stored procedures, variables, and so on.

**Maximum length: 128 bytes** (applies to all basic names including table names, column names, etc.)

### Case Insensitivity

**All identifiers in Vertica are case-insensitive**, whether quoted or unquoted. `"ABC"`, `"ABc"`, `"aBc"`, `ABC`, `ABc`, and `aBc` all refer to the same object. Identives are stored as created (not lowercased), but resolved using case-insensitive comparison. You cannot create two objects whose names differ only by case.

### Unquoted Identifiers

- **First character**: must be a non-Unicode letter (`A–Z`, `a-z`) or underscore (`_`).
- **Subsequent characters**: letters, underscores, digits (`0–9`), Unicode letters, or dollar sign (`$`).
- `$` is not SQL-standard and can cause portability issues; **model names do not support `$` or Unicode letters**.

### Quoted Identifiers

Enclosed in double quotes (`"..."`), can contain any character, including spaces, punctuation, SQL keywords, and pure numeric strings. To include a literal double quote, use two: `""""`. **Model names do not support quoted identifiers.**

### Reserved Keywords

Avoid using reserved keywords as identifiers. If required, enclose them in double quotes. Query the `KEYWORDS` system table for the full list:

```sql
SELECT * FROM KEYWORDS WHERE RESERVED = 'R';
```

### PL/vSQL Variable Names

- Must be valid SQL identifiers (same rules as above).
- Cannot be reserved keywords.
- Cannot duplicate another variable declared in the same block.
- Can use `CONSTANT`, `NOT NULL`, and `%TYPE` attribute:

```sql
DECLARE
    v_count   CONSTANT INT := 100;
    v_name    VARCHAR(50) NOT NULL := 'default';
    v_salary  employees.salary%TYPE;
```

- Variables can have aliases via `ALIAS FOR`.
- Inner-block variables shadow outer-block variables; use block labels to disambiguate: `<<outer_block>> ... outer_block.variable_name`.

## Data Definition Language (DDL)

### CREATE TABLE

```sql
CREATE TABLE [IF NOT EXISTS] table_name (
    column_name data_type [constraints] [ENCODING encoding_type],
    ...
) 
[UNSEGMENTED {HASH | NODE} | SEGMENTED BY HASH(column) ALL NODES]
[ORDER BY column1, column2, ...]
[PARTITION BY expression]
[KSafety {0 | 1}]
[PARTITION GROUP {AUTO | SMALL | LARGE}]
[COMPRESS (column1, column2, ...)];
```

**Examples:**

```sql
-- Basic table with optimized data types
CREATE TABLE customers (
    customer_id INTEGER NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' ENCODING RLE
);

-- Table with partitioning for time-series data
CREATE TABLE web_events (
    event_id BIGINT,
    event_date DATE,
    user_id INTEGER,
    event_type VARCHAR(50) ENCODING RLE,
    session_id VARCHAR(100),
    ip_address VARCHAR(45)
) PARTITION BY event_date;

-- Distributed table with segmentation
CREATE TABLE sales (
    sale_id BIGINT,
    product_id INTEGER,
    customer_id INTEGER,
    sale_date TIMESTAMP,
    amount NUMERIC(10,2),
    region VARCHAR(50) ENCODING RLE
) SEGMENTED BY HASH(product_id) ALL NODES
ORDER BY sale_date, region;
```

#### Table Constraints

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) CHECK (total_amount >= 0),
    status VARCHAR(20) DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

#### Unique Constraints

```sql
-- Column constraint
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Table constraint
CREATE TABLE products (
    product_id INTEGER,
    sku VARCHAR(50),
    name VARCHAR(100),
    PRIMARY KEY (product_id),
    UNIQUE (sku)
);
```

### CREATE FLATTENED TABLE

Flattened tables define columns whose values are computed from expressions that can reference other columns in the same row, other tables, or volatile functions. These columns are physically stored, avoiding repeated join overhead at query time.

**Two constraint types control when the expression is evaluated:**

| Constraint | When evaluated | New rows | Existing rows |
|------------|---------------|----------|---------------|
| `DEFAULT` | INSERT / COPY / column ADD | Auto-populated | Unchanged (use `UPDATE ... SET col = DEFAULT` to refresh) |
| `SET USING` | Only when `REFRESH_COLUMNS()` is called | Set to NULL until refreshed | Updated only via `REFRESH_COLUMNS()` |

**Syntax:**

```sql
CREATE TABLE table_name (
    column_name data_type
        DEFAULT (expression)
        SET USING (expression)
);
```

- `DEFAULT` and `SET USING` can be used independently or together on the same column.
- When both are specified with the same expression, it is equivalent to `DEFAULT USING`.
- Expressions must return a single value (one row, one column) or NULL.

**DEFAULT columns — evaluated at load time:**

```sql
-- Same-row computation
CREATE TABLE orders (
    order_id    IDENTITY PRIMARY KEY,
    quantity    INTEGER NOT NULL,
    unit_price  NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) DEFAULT (quantity * unit_price)
);

-- Cross-table lookup (denormalization)
CREATE TABLE order_fact (
    order_id   INTEGER PRIMARY KEY,
    cid        INTEGER REFERENCES cust_dim(cid),
    cust_name  VARCHAR(20) DEFAULT (
        SELECT name FROM cust_dim WHERE cust_dim.cid = order_fact.cid
    )
);
```

**SET USING columns — refreshed explicitly:**

```sql
-- Time-dependent column (volatile function)
CREATE TABLE person (
    id              IDENTITY PRIMARY KEY,
    name            VARCHAR(50),
    last_update     TIMESTAMP,
    active_in_last_30_days BOOLEAN
        DEFAULT (CURRENT_TIMESTAMP - last_update <= INTERVAL '30 days')
        SET USING  (CURRENT_TIMESTAMP - last_update <= INTERVAL '30 days')
);
```

**DEFAULT USING — both constraints with the same expression:**

```sql
-- Equivalent to specifying both DEFAULT and SET USING separately
CREATE TABLE order_fact (
    order_id   INTEGER PRIMARY KEY,
    cid        INTEGER,
    cust_name  VARCHAR(20) DEFAULT USING (
        SELECT name FROM cust_dim WHERE cust_dim.cid = order_fact.cid
    )
);
```

**Refreshing SET USING columns with REFRESH_COLUMNS():**

```sql
-- Refresh specific columns
SELECT REFRESH_COLUMNS('person', 'active_in_last_30_days');

-- Refresh all SET USING columns on a table
SELECT REFRESH_COLUMNS('order_fact', '');

-- REBUILD mode for large-scale refresh (auto-committed)
SELECT REFRESH_COLUMNS('order_fact', '', 'REBUILD');

-- Partition-based REBUILD (limit to recent partitions)
SELECT REFRESH_COLUMNS('order_fact', 'cust_name', 'REBUILD',
                        '2026-01-01', '2026-05-31');
```

**REFRESH_COLUMNS modes:**

| Mode | Behavior | Commit | Best for |
|------|----------|--------|----------|
| `UPDATE` (default) | Marks old rows deleted, inserts new rows | Requires explicit COMMIT | Small number of changed rows |
| `REBUILD` | Replaces all data in specified columns | Auto-committed | Large-scale refresh, new columns |

**Adding / modifying flattened columns on existing tables:**

```sql
-- Add a new SET USING column
ALTER TABLE person ADD COLUMN is_recent BOOLEAN
    SET USING (CURRENT_TIMESTAMP - last_update <= INTERVAL '7 days');

-- Add a DEFAULT column
ALTER TABLE orders ADD COLUMN tax NUMERIC(10,2)
    DEFAULT (total_price * 0.08);

-- Modify an existing column's SET USING expression
ALTER TABLE person ALTER COLUMN active_in_last_30_days
    SET USING (CURRENT_TIMESTAMP - last_update <= INTERVAL '60 days');

-- Remove the SET USING constraint (column becomes regular, keeps current data)
ALTER TABLE person ALTER COLUMN active_in_last_30_days DROP SET USING;
```

**Key restrictions:**
- SET USING expressions **cannot** use volatile functions (e.g., `RANDOM()`), sequences, or temporary tables.
- SET USING expressions **cannot** reference other SET USING columns in the same table (but CAN reference DEFAULT columns).
- Only one SELECT statement per expression (no UNION / multiple subqueries).
- Aggregate and analytic functions are not allowed in SET USING expressions.
- SET USING columns must **not** appear in any projection's segmentation, sort order, or GROUPED clause — `REFRESH_COLUMNS` will error otherwise.
- Flattened tables cannot be set to IMMUTABLE.
- Complex type columns (ARRAY, ROW, SET) cannot use DEFAULT or SET USING.

### CREATE TEMPORARY TABLE

Vertica supports **local** and **global** temporary tables. Unlike regular tables, temporary table data is always **session-private** — other sessions can never see the data.

**Key Differences from Regular Tables**:
- Data is never visible to other sessions (even for global temp tables)
- `IDENTITY` / `AUTO-INCREMENT` columns are **not allowed**
- In **Eon Mode**, K-safety is always 0 (no fault tolerance). In **Enterprise Mode**, temp tables use the system's default K-safety level (typically 1, fault tolerant)
- Local temp tables: definition visible only to creating session, auto-dropped on session end
- Global temp tables: definition visible to all sessions (in `public` schema), persists until explicitly dropped

**Syntax**:

```sql
-- Create with column definitions
CREATE [GLOBAL | LOCAL] TEMP[ORARY] TABLE [IF NOT EXISTS] table_name (
    column_name data_type [constraints],
    ...
)
[ON COMMIT {DELETE | PRESERVE} ROWS]
[ORDER BY column1, column2, ...]
[SEGMENTED BY HASH(column) ALL NODES]
[NO PROJECTION];

-- Create from query (CTAS)
CREATE [GLOBAL | LOCAL] TEMP[ORARY] TABLE table_name
[ON COMMIT PRESERVE ROWS]
AS SELECT ...;

-- SELECT INTO temp table
SELECT * INTO [LOCAL | GLOBAL] TEMP[ORARY] TABLE table_name
[ON COMMIT PRESERVE ROWS]
FROM ...;
```

**Scope Comparison**:

| Property | Local Temp Table | Global Temp Table |
|----------|-----------------|-------------------|
| Schema | `V_TEMP_SCHEMA` namespace | `public` |
| Definition visibility | Creating session only | All sessions |
| Definition lifetime | Until session ends | Until `DROP TABLE` |
| Data visibility | Session-private | Session-private |
| Data lifetime | Session (or transaction, per `ON COMMIT`) | Session (or transaction, per `ON COMMIT`) |

**ON COMMIT Options**:

- `ON COMMIT DELETE ROWS` (default): Data is **transaction-scoped** — cleared after each `COMMIT`
- `ON COMMIT PRESERVE ROWS`: Data is **session-scoped** — persists across transactions

> **CTAS Requirement**: When creating a temp table via `CREATE TABLE AS SELECT` or `SELECT INTO`, you **must** specify `ON COMMIT PRESERVE ROWS`. With the default `ON COMMIT DELETE ROWS`, data is lost at the implicit commit.

**Examples**:

```sql
-- Local temp table (session-scoped data, auto-dropped with session)
CREATE LOCAL TEMP TABLE temp_results (
    id INTEGER,
    name VARCHAR(100)
) ON COMMIT PRESERVE ROWS;

-- Global temp table (definition persists, data is session-private)
CREATE GLOBAL TEMP TABLE shared_temp (
    key_col INTEGER,
    value_col VARCHAR(200)
) ON COMMIT PRESERVE ROWS;

-- Transaction-scoped temp table (data auto-cleared on each COMMIT)
CREATE LOCAL TEMP TABLE temp_txn (a INT, b INT);
INSERT INTO temp_txn VALUES (1, 2);
COMMIT;
SELECT * FROM temp_txn;  -- Returns 0 rows

-- CTAS temp table (must use ON COMMIT PRESERVE ROWS)
CREATE LOCAL TEMP TABLE temp_ctas
ON COMMIT PRESERVE ROWS
AS SELECT * FROM source_table WHERE condition = true;

-- SELECT INTO temp table
SELECT * INTO LOCAL TEMP TABLE temp_select
ON COMMIT PRESERVE ROWS
FROM source_table WHERE condition = true;

-- Global temp table with projection
CREATE GLOBAL TEMP TABLE temp_with_proj (
    id INTEGER,
    data VARCHAR(500)
) ON COMMIT PRESERVE ROWS
ORDER BY id
SEGMENTED BY HASH(id) ALL NODES;
```

**Restrictions**:
- `IDENTITY` and `AUTO-INCREMENT` columns are **not allowed** in temp tables
- Local temp tables **cannot** specify a schema name
- Cannot add projections to a non-empty global temp table with `ON COMMIT PRESERVE ROWS`
- Temp table data is **not visible** through system (virtual) tables
- If a node fails, temp table data is lost and the session must be restarted

### CREATE FLEX TABLE

Flex tables store semi-structured data (e.g., JSON) in an internal VMap format. Column definitions are optional — you can load data without knowing the schema in advance.

```sql
-- Create a basic flex table (no column definitions)
CREATE FLEX TABLE flex_table_name();

-- Create a hybrid flex table with some materialized columns
CREATE FLEX TABLE flex_table_name(
    column1 data_type,
    column2 data_type
);

-- Create from query results (CTAS)
CREATE FLEX TABLE flex_table_name AS SELECT * FROM source_table;

-- Create a temporary flex table
CREATE FLEX LOCAL TEMP TABLE flex_table_name(col INT) ON COMMIT PRESERVE ROWS;
CREATE FLEX GLOBAL TEMP TABLE flex_table_name(col INT) ON COMMIT PRESERVE ROWS;
```

**Default Columns**: Every flex table automatically has:
- `__raw__` (LONG VARBINARY, NOT NULL): stores the raw VMap data (default max 130,000 bytes)
- `__identity__` (IDENTITY): auto-incrementing, used for segmentation when no other columns are defined

**Associated Objects**: Creating a flex table also creates:
- `flex_table_name_keys` table: tracks discovered keys and their data types
- `flex_table_name_view` : default view for querying virtual columns

**Load JSON data**:
```sql
-- Load JSON using the built-in fjsonparser
COPY flex_table_name FROM '/data/file.json' PARSER fjsonparser();

-- Insert explicitly named virtual columns
INSERT INTO flex_table_name("key1", "key2") VALUES ('val1', 'val2');
```

**Discover and query keys**:
```sql
-- Compute all keys from loaded data and build the default view
SELECT compute_flextable_keys_and_build_view('flex_table_name');

-- View discovered keys, frequency, and guessed data types
SELECT * FROM flex_table_name_keys;

-- Query virtual columns (quoted identifiers, case-insensitive)
SELECT "user.name", "user.lang" FROM flex_table_name;

-- Cast virtual columns to appropriate types
SELECT "created_at"::TIMESTAMP, "count"::INT FROM flex_table_name;
```

**Materialize frequently accessed columns**:
```sql
-- Add a real column from a virtual column
ALTER TABLE flex_table_name ADD COLUMN IF NOT EXISTS user_id BIGINT;
UPDATE flex_table_name SET user_id = "user.id"::BIGINT;

-- Or materialize multiple columns at once
SELECT MATERIALIZE_FLEXTABLE_COLUMNS('flex_table_name');
```

**Flex Table Map Functions**:
```sql
-- Check if a key exists
SELECT * FROM flex_table_name WHERE MAPLOOKUP(__raw__, 'key') IS NOT NULL;

-- Get value for a key
SELECT MAPLOOKUP(__raw__, 'key') FROM flex_table_name;

-- Check number of keys
SELECT MAPSIZE(__raw__) FROM flex_table_name;

-- Convert VMap to string for debugging
SELECT MapToString(__raw__) FROM flex_table_name;
```

### CREATE TEXT INDEX

Creates a text index on a text column for efficient keyword search. The text index is a table that is tightly managed with the source table, storing tokenized words from the source table. It supports stemmed search.

```sql
CREATE TEXT INDEX [schema.]txtindex-name
    ON [schema.]source-table (unique-id, text-field [, column-name,...])
    [STEMMER {stemmer-name(stemmer-input-data-type) | NONE}]
    [TOKENIZER tokenizer-name(tokenizer-input-data-type)];
```

**Parameters:**
- `unique-id`: Primary key column of the source table (any data type)
- `text-field`: Column to index (CHAR, VARCHAR, LONG VARCHAR, VARBINARY, LONG VARBINARY)
- `column-name`: Additional unindexed columns to include in the text index
- `STEMMER`: Stemming function (default: `v_txtindex.StemmerCaseInsensitive`)
- `TOKENIZER`: Tokenization function (default: `v_txtindex.StringTokenizer`)

**Preconfigured Stemmer Functions:**

| Stemmer | Description |
|---------|-------------|
| `v_txtindex.StemmerCaseInsensitive(long varchar)` | Case-insensitive, Porter stemming (default) |
| `v_txtindex.StemmerCaseSensitive(long varchar)` | Case-sensitive, Porter stemming |
| `v_txtindex.caseInsensitiveNoStemming(long varchar)` | Case-insensitive, no stemming |
| `STEMMER NONE` | No stemming |

**Preconfigured Tokenizer Functions:**

| Tokenizer | Description |
|-----------|-------------|
| `v_txtindex.StringTokenizer(long varchar)` | Splits on white space (for regular text columns) |
| `v_txtindex.StringTokenizerDelim(long varchar, CHAR(1))` | Splits on specified delimiter character |
| `public.FlexTokenizer(long varbinary)` | For flex table `__raw__` columns |
| `v_txtindex.ICUTokenizer` | Multi-language support via ICU |

**Requirements:**
- Source table must have a primary key column
- Source table must have a projection sorted and segmented by the primary key
- Do not alter the contents or definitions of the text index

**Examples:**

```sql
-- Basic text index with default stemmer and tokenizer
CREATE TEXT INDEX t_log_index ON t_log (id, message);

-- Text index with explicit stemmer and tokenizer
CREATE TEXT INDEX idx_100 ON top_100 (id, feedback)
    STEMMER v_txtindex.StemmerCaseInsensitive(long varchar)
    TOKENIZER v_txtindex.StringTokenizer(long varchar);

-- Text index on a flex table (use FlexTokenizer for __raw__)
ALTER TABLE mountains ADD PRIMARY KEY (__identity__);
CREATE TEXT INDEX flex_text_index ON mountains (__identity__, __raw__)
    TOKENIZER public.FlexTokenizer(long varbinary);

-- Text index with no stemming (exact match only)
CREATE TEXT INDEX idx_logs ON sys_logs (id, message)
    STEMMER NONE
    TOKENIZER v_txtindex.StringTokenizer(long varchar);

-- Text index with delimiter-based tokenization
CREATE TEXT INDEX idx_csv ON string_table (id, word)
    TOKENIZER v_txtindex.StringTokenizerDelim(long varchar, ',');
```

**Querying a text index:**

```sql
-- Search for a keyword (case-insensitive with default stemmer)
SELECT * FROM source_table
WHERE id IN (
    SELECT doc_id FROM text_index
    WHERE token = v_txtindex.StemmerCaseInsensitive('search_term')
);

-- Case-sensitive search
SELECT * FROM source_table
WHERE id IN (
    SELECT doc_id FROM text_index
    WHERE token = v_txtindex.StemmerCaseSensitive('SearchTerm')
);

-- Combined search: include and exclude keywords
SELECT * FROM source_table WHERE
    id IN (SELECT doc_id FROM text_index WHERE token = v_txtindex.StemmerCaseInsensitive('warning'))
    AND id IN (SELECT doc_id FROM text_index WHERE token = v_txtindex.StemmerCaseInsensitive('validate'))
    AND NOT (id IN (SELECT doc_id FROM text_index WHERE token = v_txtindex.StemmerCaseInsensitive('exclude_this')));
```

**Drop a text index:**

```sql
DROP TEXT INDEX text_index;
```

**Configuration:**
```sql
-- Set maximum token length (default: 128, max: 65000)
ALTER DATABASE DEFAULT SET PARAMETER TextIndexMaxTokenLength = 760;
```

### DROP TABLE

```sql
-- Basic DROP TABLE
DROP TABLE table_name;

-- Drop table if it exists (no error if table doesn't exist)
DROP TABLE IF EXISTS table_name;

-- Drop table with dependent objects (projections, views, etc.)
DROP TABLE table_name CASCADE;

-- Drop multiple tables
DROP TABLE table1, table2, table3;
```

**CASCADE Option:**
- Use `CASCADE` when the table has dependent objects like projections, views, or foreign key constraints
- Automatically drops all objects that depend on the table
- Essential for Vertica due to its projection-based architecture

**Examples:**
```sql
-- Drop simple table
DROP TABLE temp_data;

-- Drop table with dependencies
DROP TABLE sales CASCADE;  -- Also drops related projections

-- Safe drop with existence check
DROP TABLE IF EXISTS old_customers CASCADE;
```

### CREATE PROJECTION

```sql
CREATE PROJECTION [IF NOT EXISTS] projection_name
AS SELECT column1, column2, ...
FROM table_name
[ORDER BY column1, column2, ...]
[UNSEGMENTED {HASH | NODE} | SEGMENTED BY HASH(column) ALL NODES]
[ENCODING (column1 encoding_type, column2 encoding_type, ...)];
```

**Projection Types:**

```sql
-- Order-optimized projection
CREATE PROJECTION sales_by_date
AS SELECT sale_date, product_id, amount, region
FROM sales
ORDER BY sale_date, region
SEGMENTED BY HASH(product_id) ALL NODES;

-- Aggregate projection for summaries
CREATE PROJECTION sales_monthly_agg
AS SELECT
    date_trunc('month', sale_date) as month,
    region,
    SUM(amount) as total_sales,
    COUNT(*) as transaction_count
FROM sales
GROUP BY date_trunc('month', sale_date), region
UNSEGMENTED ALL NODES;

-- Replicated projection for small lookup tables
CREATE PROJECTION region_lookup
AS SELECT region_id, region_name, country
FROM regions
UNSEGMENTED ALL NODES;
```

### DROP PROJECTION

```sql
-- Drop specific projection
DROP PROJECTION projection_name;

-- Drop projection if it exists
DROP PROJECTION IF EXISTS projection_name;
```

### CREATE VIEW

```sql
CREATE [OR REPLACE] [FORCE] VIEW view_name AS
SELECT ...
[ORDER BY ...];
```

> **ORDER BY in Views**: Vertica **supports** `ORDER BY` in view definitions, and the sorting **takes effect** when the view is queried.

```sql
-- Simple view
CREATE VIEW active_customers AS
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE status = 'ACTIVE';

-- Complex analytical view
CREATE VIEW customer_lifetime_value AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as lifetime_value,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- View with ORDER BY (fully supported, sorting takes effect)
CREATE VIEW top_employees AS
SELECT employee_id, name, salary, department_id
FROM employees
ORDER BY salary DESC
LIMIT 10;
```

### DROP VIEW

```sql
-- Drop specific view
DROP VIEW view_name;

-- Drop view if it exists (no error if view doesn't exist)
DROP VIEW IF EXISTS view_name;

-- Drop view with schema qualification
DROP VIEW schema_name.view_name;

-- Drop multiple views
DROP VIEW view1, view2, view3;
```

### COMMENT Statements

COMMENT statements add, modify, or remove comments on database objects. Each object can have only one comment. Comments are stored in the system table COMMENTS.

```sql
-- Add/modify comment on table
COMMENT ON TABLE [[database.]schema.]table_name IS 'comment_text';

-- Add/modify comment on view
COMMENT ON VIEW [[database.]schema.]view_name IS 'comment_text';

-- Add/modify comment on column
COMMENT ON COLUMN [[database.]schema.]table_name.column_name IS 'comment_text';

-- Add/modify comment on schema
COMMENT ON SCHEMA schema_name IS 'comment_text';

-- Add/modify comment on projection
COMMENT ON PROJECTION [[database.]schema.]projection_name IS 'comment_text';

-- Add/modify comment on function
COMMENT ON FUNCTION [[database.]schema.]function_name(function_args) IS 'comment_text';

-- Remove comment (set to NULL)
COMMENT ON TABLE table_name IS NULL;
```

**Key Features:**
- New comments overwrite existing ones
- Dropping an object automatically drops its comments
- Supports: TABLE, VIEW, COLUMN, SCHEMA, PROJECTION, FUNCTION, CONSTRAINT, SEQUENCE, LIBRARY, NODE

**Examples:**
```sql
-- Add descriptive comments
COMMENT ON TABLE customers IS 'Customer master data with contact information';

COMMENT ON COLUMN customers.email IS 'Primary email address, must be unique';

COMMENT ON COLUMN customers.created_date IS 'Record creation timestamp in UTC';

COMMENT ON VIEW active_customers IS 'Customers with status = ACTIVE for reporting';

COMMENT ON SCHEMA public IS 'Default schema accessible to all users';

COMMENT ON FUNCTION calculate_discount(price NUMERIC, rate NUMERIC) 
    IS 'Returns discounted price: price * (1 - rate)';

-- Remove comments
COMMENT ON TABLE customers IS NULL;
COMMENT ON COLUMN customers.email IS NULL;

-- View all comments
SELECT object_type, object_schema, object_name, child_object, comment 
FROM COMMENTS 
ORDER BY object_type, object_name;

-- View comments for specific table
SELECT * FROM COMMENTS 
WHERE object_type = 'TABLE' AND object_name = 'customers';
```

### SEQUENCE Statements

SEQUENCE objects generate unique numeric values for primary keys and other unique identifiers. Vertica supports both named sequences and IDENTITY column sequences.

```sql
-- Create a named sequence
CREATE SEQUENCE [IF NOT EXISTS] [[database.]schema.]sequence_name
   [INCREMENT [BY] integer]
   [MINVALUE integer | NO MINVALUE]
   [MAXVALUE integer | NO MAXVALUE]
   [START [WITH] integer]
   [CACHE integer | NO CACHE]
   [CYCLE | NO CYCLE];

-- Alter sequence properties
ALTER SEQUENCE [[database.]schema.]sequence_name
    [INCREMENT [BY] integer]
    [MINVALUE integer | NO MINVALUE]
    [MAXVALUE integer | NO MAXVALUE]
    [RESTART [WITH] integer]
    [CACHE integer | NO CACHE]
    [CYCLE | NO CYCLE]
    [RENAME TO new_name]
    [SET SCHEMA new_schema]
    [OWNER TO new_owner];

-- Drop sequence
DROP SEQUENCE [IF EXISTS] [[database.]schema.]sequence_name;

-- Get next sequence value (FUNCTION syntax)
SELECT NEXTVAL('[[database.]schema.]sequence_name');

-- Get next sequence value (PROPERTY syntax - same result)
SELECT [[database.]schema.]sequence_name.NEXTVAL;

-- Get current sequence value (FUNCTION syntax)
SELECT CURRVAL('[[database.]schema.]sequence_name');

-- Get current sequence value (PROPERTY syntax - same result)
SELECT [[database.]schema.]sequence_name.CURRVAL;
```

**Key Parameters:**
- `INCREMENT`: Step value (default: 1, can be negative for descending)
- `MINVALUE/MAXVALUE`: Range boundaries (defaults: 1 to 2^63 for ascending)
- `START`: Initial value (default: minimum for ascending, maximum for descending)
- `CACHE`: Pre-allocated values for performance (default: 250,000)
- `CYCLE`: Whether to wrap around when limits are reached (default: NO CYCLE)

**Examples:**
```sql
-- Create ascending sequence starting at 100
CREATE SEQUENCE order_id_seq START 100;

-- Create descending sequence
CREATE SEQUENCE log_id_seq INCREMENT -1 START 1000000;

-- Create sequence with custom range and cycling
CREATE SEQUENCE temp_id_seq
    MINVALUE 1
    MAXVALUE 1000
    START 1
    CACHE 100
    CYCLE;

-- Create table with sequence
CREATE TABLE orders (
    order_id INTEGER DEFAULT order_id_seq.NEXTVAL PRIMARY KEY,
    customer_id INTEGER,
    order_date TIMESTAMP DEFAULT NOW(),
    total_amount NUMERIC(10,2)
);

-- Get next sequence value (FUNCTION syntax)
SELECT NEXTVAL('order_id_seq');

-- Get next sequence value (PROPERTY syntax - same result)
SELECT order_id_seq.NEXTVAL;

-- Get current sequence value (FUNCTION syntax)
SELECT CURRVAL('order_id_seq');

-- Get current sequence value (PROPERTY syntax - same result)
SELECT order_id_seq.CURRVAL;

-- Insert using sequence default
INSERT INTO orders (customer_id, total_amount)
VALUES (123, 299.99);

-- Alter sequence to restart
ALTER SEQUENCE order_id_seq RESTART WITH 1000;

-- View sequence information
SELECT sequence_schema, sequence_name, current_value, increment_by
FROM sequences
WHERE sequence_name = 'order_id_seq';

-- Drop sequence
DROP SEQUENCE order_id_seq;
```

**IDENTITY and AUTO_INCREMENT Columns:**

`IDENTITY` and `AUTO_INCREMENT` are **synonyms** in Vertica — they are the same column constraint with different names. `IDENTITY` is the Vertica-native keyword; `AUTO_INCREMENT` is supported for MySQL compatibility.

**Syntax:**
```sql
column_name { IDENTITY | AUTO_INCREMENT }
    ( [ cache-size | start, increment [, cache-size] ] )
```

**Arguments:**

| Argument | Description | Default |
|----------|-------------|---------|
| `start` | First value for the column | 1 |
| `increment` | Step value per row insertion (can be negative) | 1 |
| `cache-size` | How many values each node caches per session (0 or 1 disables caching) | 250,000 |

**Examples:**
```sql
-- IDENTITY with defaults (start=1, increment=1, cache=250000)
CREATE TABLE customers (
    customer_id IDENTITY PRIMARY KEY,
    name VARCHAR(100)
);

-- AUTO_INCREMENT (equivalent to IDENTITY)
CREATE TABLE orders (
    order_id AUTO_INCREMENT PRIMARY KEY,
    customer_id INTEGER
);

-- IDENTITY with explicit start and increment
CREATE TABLE products (
    product_id IDENTITY(100, 1) PRIMARY KEY,
    product_name VARCHAR(255)
);

-- IDENTITY with start, increment, and cache size
CREATE TABLE logs (
    log_id IDENTITY(1, 1, 100) PRIMARY KEY,
    message VARCHAR(500)
);

-- AUTO_INCREMENT with explicit parameters
CREATE TABLE items (
    item_id AUTO_INCREMENT(1, 5) PRIMARY KEY,
    item_name VARCHAR(100)
);

-- Insert data (IDENTITY/AUTO_INCREMENT auto-generates the value)
INSERT INTO customers (name) VALUES ('John Doe');
INSERT INTO orders (customer_id) VALUES (123);

-- View the underlying sequence name for an IDENTITY column
SELECT sequence_schema, sequence_name, identity_table_name
FROM sequences
WHERE identity_table_name = 'customers';

-- Inspect IDENTITY sequence properties
SELECT sequence_schema, sequence_name, identity_table_name,
       increment_by, session_cache_count
FROM sequences
WHERE identity_table_name = 'customers';
```

**Underlying Sequence:**

Each IDENTITY/AUTO_INCREMENT column has an automatically created named sequence with the convention `<table>_<col>_seq`. You can manage this sequence with `ALTER SEQUENCE`:

```sql
-- Change the maximum value of an IDENTITY sequence
ALTER SEQUENCE customers_customer_id_seq MAXVALUE 1000000;

-- Restart an IDENTITY sequence
ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1;

-- Get the last value generated for an IDENTITY column
SELECT LAST_INSERT_ID();
```

**Performance Considerations:**
- Default cache size is 250,000 values per node per session for optimal MPP performance
- Sequence values may have **gaps** due to caching and distributed architecture — this is by design

**Restrictions:**
- **Only one** IDENTITY/AUTO_INCREMENT column per table
- **Not allowed** in temporary tables (local or global) — use named sequences instead
- Cannot load or explicitly set values in an IDENTITY column
- Transaction rollback does **not** revert consumed sequence values
- Cannot use NEXTVAL/CURRVAL on IDENTITY/AUTO_INCREMENT sequences in WHERE, GROUP BY, ORDER BY, DISTINCT, UNION, subqueries, or views
- `CURRVAL` requires a prior `NEXTVAL` call in the same session

## Data Manipulation Language (DML)

### INSERT

```sql
-- Standard INSERT
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);

-- INSERT multiple rows at the same time with multiple comma-delimited VALUES lists for better performance
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...)[, (value-list)];

-- INSERT from SELECT
INSERT INTO target_table (column1, column2, ...)
SELECT column1, column2, ...
FROM source_table
WHERE condition;
```

### UPDATE

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;

-- Update with subquery
UPDATE customers
SET last_purchase_date = (
    SELECT MAX(order_date)
    FROM orders
    WHERE orders.customer_id = customers.customer_id
);
```

### DELETE

```sql
DELETE FROM table_name
WHERE condition;

-- Delete with join using EXISTS
DELETE FROM customers
WHERE NOT EXISTS (
    SELECT 1 FROM orders
    WHERE orders.customer_id = customers.customer_id
    AND order_date >= CURRENT_DATE - INTERVAL '1 year'
);
```

### MERGE

```sql
MERGE [ /*+LABEL (label-string)*/ ]
    INTO [[database.|namespace.]schema.]target-table [ [AS] alias ]
    USING source-dataset
    ON join-condition matching-clause[ matching-clause ]
```

**Arguments:**
- `target-table`: Target table, cannot contain complex data type columns
- `source-dataset`: Source data, can be table, view, or subquery
- `join-condition`: Join condition, target table join column should have unique or primary key constraint for optimization
- `matching-clause`: Matching clause, at least one required

**Matching Clauses:**
```sql
-- Update matched rows
WHEN MATCHED [ AND update-filter ] THEN UPDATE
   SET { column = expression }[,...]

-- Insert unmatched rows
WHEN NOT MATCHED [ AND insert-filter ] THEN INSERT
   [ ( column-list ) ] VALUES ( values-list )
```

**Examples:**
```sql
-- Basic merge operation: update visit count, insert new customers
MERGE INTO visits_history h USING visits_daily d
    ON (h.customer_id=d.customer_id AND h.location_name=d.location_name)
    WHEN MATCHED THEN UPDATE SET visit_count = h.visit_count + 1
    WHEN NOT MATCHED THEN INSERT (customer_id, location_name, visit_count)
    VALUES (d.customer_id, d.location_name, 1);

-- Merge with filter conditions
MERGE INTO product_dimension_discontinued tgt
     USING product_dimension src ON tgt.product_key = src.product_key
                                AND tgt.product_version = src.product_version
     WHEN NOT MATCHED AND src.discontinued_flag='1' THEN INSERT VALUES
       (src.product_key, src.product_version, src.sku_number,
        src.category_description, src.product_description);

-- Merge from subquery
MERGE INTO product_dimension tgt
     USING (SELECT (product_key||'.0'||product_version)::numeric(8,2) AS pid, sku_number
     FROM product_dimension) src
     ON tgt.product_key||'.0'||product_version::numeric=src.pid
     WHEN MATCHED THEN UPDATE SET product_ID = src.pid;
```

**Performance Optimization:**
- Include both UPDATE and INSERT clauses
- Target table join column should have primary/unique key constraint
- Avoid using filter conditions when possible
- Both clauses should specify identical source values and all target columns

**Restrictions:**
- ❌ Cannot operate on: IDENTITY columns, complex types (ARRAY/SET/ROW), sequence default columns
- ❌ Source table join column cannot contain duplicate values
- ✅ Maximum 831 target table columns
- Requires SELECT privilege (source data) and INSERT/UPDATE/DELETE privileges (target table)

## Query Language

### SELECT Statement Structure

```sql
[WITH common_table_expression AS (...), ...]
SELECT [DISTINCT] column1, column2, ...
    [, aggregate_function(column) [OVER (window_specification)]]
FROM table1
    [JOIN table2 ON join_condition]
    [LEFT|RIGHT|FULL JOIN table3 ON join_condition]
WHERE condition
GROUP BY column1, column2, ...
HAVING condition
ORDER BY column1 [ASC|DESC], ...
LIMIT count [OFFSET start];
```

### SELECT INTO

`SELECT INTO` creates a new table from query results. It can target either a **regular (permanent) table** or a **temporary table**.

#### SELECT INTO Regular Table

Creates a permanent table. The `TABLE` keyword is optional.

```sql
-- Basic: create permanent table from query
SELECT * INTO TABLE new_table FROM source_table;

-- TABLE keyword is optional
SELECT * INTO new_table FROM source_table;

-- With schema qualification
SELECT * INTO TABLE myschema.new_table FROM source_table;

-- With WHERE filter
SELECT * INTO TABLE filtered_data
FROM source_table
WHERE created_date > CURRENT_DATE - 30;
```

**Restrictions**:
- Subqueries in FROM clause cannot use `SELECT INTO` (ERROR 4831)
- `WITH` clause (CTE) queries cannot use `SELECT INTO` (ERROR 10313)
- `INTO` is only allowed on the first SELECT of `UNION/INTERSECT/EXCEPT` (ERROR 3615)
- Cannot specify `ORDER BY`, `SEGMENTED BY`, or encoding in the INTO clause — use `CREATE TABLE AS SELECT` for those

**SELECT INTO vs CREATE TABLE AS SELECT**:

| Feature | SELECT INTO TABLE | CREATE TABLE AS SELECT |
|---------|-------------------|----------------------|
| Standard | Non-standard extension | SQL standard |
| Column naming | Derived from SELECT output | Supports explicit column list |
| ORDER BY / SEGMENTED BY | ❌ Not supported | ✅ Supported |
| LABEL hint | ❌ Not available | ✅ Supported |
| AT epoch (historical) | ❌ Not available | ✅ Supported |
| ENCODED BY | ❌ Not available | ✅ Supported |

#### SELECT INTO Temporary Table

Creates a temp table. **Critical**: the default `ON COMMIT DELETE ROWS` means data is **discarded at commit** unless you specify `ON COMMIT PRESERVE ROWS`.

```sql
-- ⚠️ WRONG: Data is lost at commit (default ON COMMIT DELETE ROWS)
SELECT * INTO TEMP TABLE new_temp FROM source_table;
-- WARNING 4102: No rows are inserted...

-- ✅ CORRECT: Preserve data across transactions
SELECT * INTO TEMP TABLE new_temp
ON COMMIT PRESERVE ROWS
FROM source_table;

-- Local temp table (definition visible only to current session)
SELECT * INTO LOCAL TEMP TABLE new_local_temp
ON COMMIT PRESERVE ROWS
FROM source_table;

-- Global temp table (definition visible to all, data always session-private)
SELECT * INTO GLOBAL TEMP TABLE new_global_temp
ON COMMIT PRESERVE ROWS
FROM source_table;
```

**Temp table restrictions that apply to SELECT INTO TEMP**:
- `IDENTITY` / `AUTO-INCREMENT` columns are **not allowed**
- Local temp tables **cannot** specify a schema name
- Cannot add projections to a non-empty temp table with `ON COMMIT PRESERVE ROWS`
- Temp table data is **not visible** through system/virtual tables
- `ALTER TABLE` (ADD/DROP/RENAME COLUMN, SET SCHEMA) is not supported
- `SELECT FOR UPDATE` is not allowed
- Partitioning is not supported

### JOIN Types

#### Common JOINs

```sql
-- INNER JOIN
SELECT c.name, o.total
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- LEFT JOIN
SELECT c.name, COALESCE(SUM(o.total), 0) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Multiple JOINs
SELECT
    c.name,
    p.product_name,
    SUM(od.quantity * od.unit_price) as revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY c.customer_id, c.name, p.product_id, p.product_name;
```

#### LATERAL JOIN

Vertica has **limited** `LATERAL` support. `CROSS JOIN LATERAL` with UDx functions (e.g., `UNNEST`) is supported, but `JOIN LATERAL` with subqueries, `LEFT JOIN LATERAL ... ON`, and `CROSS APPLY` / `OUTER APPLY` are **not** supported.

**Supported:**

```sql
-- CROSS JOIN LATERAL with UDx function
SELECT u.name, t.val
FROM users u
CROSS JOIN LATERAL unnest(ARRAY[10, 20, 30]) AS t(val);
```

**Not supported:**

```sql
-- ❌ JOIN LATERAL with subquery
SELECT * FROM users u
JOIN LATERAL (SELECT * FROM orders WHERE user_id = u.id) o ON true;

-- ❌ LEFT JOIN LATERAL with ON clause
SELECT * FROM users u
LEFT JOIN LATERAL unnest(ARRAY[1, 2, 3]) AS t(val) ON true;

-- ❌ CROSS APPLY / OUTER APPLY
SELECT * FROM users u
CROSS APPLY (SELECT * FROM orders WHERE user_id = u.id) o;
```

**Alternatives for common LATERAL patterns:**

| LATERAL pattern | Vertica alternative |
|---|---|
| `JOIN LATERAL (SELECT ... WHERE ... LIMIT N)` | `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` |
| Correlated subquery returning a single value | Scalar subquery: `(SELECT MAX(...) WHERE ...)` |
| `LEFT JOIN LATERAL` with subquery | `LEFT JOIN` with derived table or window function |
| PostgreSQL `LATERAL` unnest | `CROSS JOIN LATERAL unnest(ARRAY[...])` (supported) |
| `CROSS APPLY` / `OUTER APPLY` | `JOIN` / `LEFT JOIN` with UDTF or derived table |

**Example 1 — Top N per group (replacing `JOIN LATERAL (SELECT ... LIMIT N)`):**

```sql
-- Instead of: JOIN LATERAL (SELECT ... ORDER BY amount DESC LIMIT 2) ON true
SELECT name, order_id, amount
FROM (
    SELECT u.name, o.order_id, o.amount,
           ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.amount DESC) AS rn
    FROM users u
    JOIN orders o ON u.id = o.user_id
) t
WHERE rn <= 2
ORDER BY name, amount DESC;
```

**Example 2 — Correlated scalar subquery (replacing `JOIN LATERAL` returning one value):**

```sql
-- Instead of: JOIN LATERAL (SELECT MAX(amount) FROM orders WHERE user_id = u.id) o ON true
SELECT u.name,
       (SELECT MAX(amount) FROM orders WHERE user_id = u.id) AS max_amount
FROM users u;
```

**Example 3 — LEFT JOIN LATERAL with subquery:**

```sql
-- Instead of: LEFT JOIN LATERAL (SELECT ... WHERE user_id = u.id) o ON true
SELECT u.name, o.order_id, o.amount
FROM users u
LEFT JOIN (
    SELECT user_id, order_id, amount,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY amount DESC) AS rn
    FROM orders
) o ON o.user_id = u.id AND o.rn <= 2
ORDER BY u.name, o.amount DESC;
```

**Example 4 — LATERAL UNNEST (supported):**

```sql
-- PostgreSQL: JOIN LATERAL unnest(tags) AS t(tag) ON true
-- Vertica:  CROSS JOIN LATERAL unnest (supported)
SELECT u.name, t.tag
FROM users u
CROSS JOIN LATERAL unnest(ARRAY['tag1', 'tag2', 'tag3']) AS t(tag);
```

#### JOIN with User-Defined Transform Functions (UDTF)

Vertica supports joining tables with transform functions (e.g., `UNNEST`, `generate_series`). The UDTF must appear on the **right side** of the join — placing it on the left causes an internal optimizer error. Multiple UDTFs cannot be joined directly against each other. For `LATERAL` keyword usage with UDTFs, see [LATERAL JOIN](#lateral-join) above.

**Supported join types with UDTFs:**

| Join type | Supported | Notes |
|---|---|---|
| `CROSS JOIN` | ✅ | Cartesian product |
| `JOIN` / `INNER JOIN` | ✅ | Filter during join with `ON` condition |
| `LEFT JOIN` | ✅ | Preserve all left (non-UDTF) rows |
| `RIGHT JOIN` | ❌ | **Not supported** — use subquery-wrapped UDTF + `LEFT JOIN` instead |
| `FULL OUTER JOIN` | ❌ | Not supported |

**Supported patterns:**

```sql
-- 1. CROSS JOIN UDTF (cartesian product)
SELECT u.name, t.val
FROM users u
CROSS JOIN unnest(ARRAY[10, 20, 30]) AS t(val);

-- 2. JOIN UDTF ON true (equivalent to CROSS JOIN)
SELECT u.name, t.val
FROM users u
JOIN unnest(ARRAY[10, 20, 30]) AS t(val) ON true;

-- 3. JOIN UDTF ON condition (filter during join)
SELECT u.name, t.val
FROM users u
JOIN unnest(ARRAY[10, 20, 30]) AS t(val) ON t.val > 15;

-- 4. LEFT JOIN UDTF ON true (preserve all left rows)
SELECT u.name, t.val
FROM users u
LEFT JOIN unnest(ARRAY[10, 20, 30]) AS t(val) ON true;

-- 5. LEFT JOIN UDTF ON condition
SELECT u.id, t.val
FROM users u
LEFT JOIN unnest(ARRAY[10, 20, 30]) AS t(val) ON t.val > 15
ORDER BY u.id;

-- 6. JOIN generate_series ON condition (replace loop-counter pattern)
SELECT g.i, o.order_id
FROM orders o
JOIN generate_series(1, 100) AS g(i) ON o.user_id = g.i;

-- 7. CROSS JOIN generate_series (standalone with dummy table)
SELECT g.i
FROM (SELECT 1 AS d) t
CROSS JOIN generate_series(1, 10) AS g(i);

-- 8. CROSS JOIN LATERAL UDTF (explicit LATERAL keyword — see LATERAL JOIN above)
SELECT u.name, t.val
FROM users u
CROSS JOIN LATERAL unnest(ARRAY[10, 20, 30]) AS t(val);

-- 9. Subquery-wrapped UDTF + LEFT JOIN (preserve all UDTF rows)
--    Use this when the UDTF result must be the driving table
SELECT g.d::DATE, COUNT(o.order_id)
FROM (SELECT generate_series(DATE '2024-01-01', DATE '2024-01-31', INTERVAL '1 day') AS d) g
LEFT JOIN orders o ON o.order_date = g.d
GROUP BY g.d;

-- 10. Subquery-wrapped unnest + LEFT JOIN (preserve all array values)
SELECT s.status, SUM(t.amount)
FROM (SELECT unnest(ARRAY['PENDING', 'PROCESSING', 'COMPLETED']) AS status) s
LEFT JOIN transactions t ON t.status = s.status
GROUP BY s.status;
```

**Not supported:**

```sql
-- ❌ UDTF on the left side of join — internal optimizer error
SELECT g.i, u.name
FROM generate_series(1, 3) AS g(i)
JOIN users u ON u.id = g.i;

-- ❌ RIGHT JOIN with UDTF — unsupported join type
SELECT g.i, u.name
FROM users u
RIGHT JOIN generate_series(1, 3) AS g(i) ON u.id = g.i;

-- ❌ Multiple UDTFs joined together — error
SELECT g.i, t.val
FROM generate_series(1, 3) AS g(i)
CROSS JOIN unnest(ARRAY[10, 20]) AS t(val);

-- ❌ Comma-style join with UDTF — error
SELECT u.name, t.val
FROM users u, unnest(ARRAY[10, 20, 30]) AS t(val);

-- ❌ Standalone UDTF in FROM — error
SELECT * FROM unnest(ARRAY[10, 20, 30]) AS t(val);
```

**Replacing loop-counter patterns with `generate_series`:**

When the loop drives aggregation per group (e.g., per category, per date), use `GROUP BY` directly — no UDTF needed:

```sql
-- Anti-pattern: loop N times with counter variable
-- FOR i IN 1..10 LOOP
--     INSERT INTO result SELECT * FROM data WHERE category = i;
-- END LOOP;

-- Optimized: set-based GROUP BY
INSERT INTO result
SELECT category, COUNT(*), SUM(amount)
FROM data
WHERE category BETWEEN 1 AND 10
GROUP BY category;
```

When you need to **preserve all generated values** (including those with no matching data), wrap the UDTF in a subquery and use `LEFT JOIN`:

```sql
-- Preserve all generated series values (e.g., all dates, all categories)
INSERT INTO daily_stats (stat_date, order_count)
SELECT g.d::DATE, COUNT(o.order_id)
FROM (SELECT generate_series(DATE '2024-01-01', DATE '2024-01-31', INTERVAL '1 day') AS d) g
LEFT JOIN orders o ON o.order_date = g.d
GROUP BY g.d;

-- Preserve all unnest array values
INSERT INTO status_summary (status, total_amount)
SELECT s.status, SUM(t.amount)
FROM (SELECT unnest(ARRAY['PENDING', 'PROCESSING', 'COMPLETED']) AS status) s
LEFT JOIN transactions t ON t.status = s.status
GROUP BY s.status;
```

> **Important**: Do NOT use `RIGHT JOIN` with UDTFs — Vertica only supports INNER and LEFT joins with transform functions. Wrapping the UDTF in a subquery and placing it on the left side of a `LEFT JOIN` achieves the same result.

### Subqueries

```sql
-- Scalar subquery
SELECT name, 
       (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id) as order_count
FROM customers c;

-- EXISTS subquery
SELECT name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.total_amount > 1000
);

-- IN subquery
SELECT product_name
FROM products
WHERE category_id IN (
    SELECT category_id
    FROM categories
    WHERE department = 'Electronics'
);

-- Correlated subquery
SELECT p.product_name,
       p.price,
       (SELECT AVG(price) FROM products WHERE category_id = p.category_id) as avg_category_price
FROM products p;
```

**⚠️ Restriction: Correlated Subqueries**

Vertica does **not** support correlated subqueries in the following contexts:

**1. Correlated subqueries containing `DISTINCT` or `GROUP BY`** (applies to scalar subqueries, `IN`, `EXISTS`, etc.):

```sql
-- ❌ NOT SUPPORTED: Scalar correlated subquery with GROUP BY
SELECT id
     , (SELECT MAX(t2.value) FROM t2 WHERE t2.id = t1.id GROUP BY t2.id) AS max_value
FROM t1;
-- ERROR: Correlated subquery with distinct/group by is not supported

-- ✅ REWRITTEN: Scalar → LEFT JOIN with a derived table
SELECT t1.id, t.max_value
FROM t1
LEFT JOIN (SELECT id, MAX(value) AS max_value FROM t2 GROUP BY id) t ON t1.id = t.id;
```

```sql
-- ❌ NOT SUPPORTED: IN + correlated subquery + GROUP BY
SELECT c.name FROM customers c
WHERE c.id IN (
    SELECT o.customer_id FROM orders o
    WHERE o.customer_id = c.id GROUP BY o.customer_id
);
-- ERROR: Correlated subquery with distinct/group by is not supported

-- ✅ REWRITTEN: IN → JOIN with a derived table
SELECT c.name
FROM customers c
JOIN (
    SELECT customer_id, MAX(amount) AS max_amount
    FROM orders GROUP BY customer_id
) o ON o.customer_id = c.id;
```

```sql
-- ❌ NOT SUPPORTED: EXISTS + correlated subquery + GROUP BY
SELECT c.name FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.id GROUP BY o.customer_id
);
-- ERROR: Correlated subquery with distinct/group by is not supported

-- ✅ REWRITTEN: EXISTS → JOIN with a derived table
SELECT c.name
FROM customers c
JOIN (
    SELECT customer_id, MAX(amount) AS max_amount
    FROM orders GROUP BY customer_id
) o ON o.customer_id = c.id;
```

**2. Correlated subqueries with `NOT IN`**:

```sql
-- ❌ NOT SUPPORTED: NOT IN + correlated subquery
SELECT c.name FROM customers c
WHERE c.id NOT IN (
    SELECT o.customer_id FROM orders o
    WHERE o.customer_id = c.id
);
-- ERROR: Correlated subquery with NOT IN is not supported

-- ✅ REWRITTEN: NOT IN → LEFT JOIN WHERE NULL
SELECT c.name
FROM customers c
LEFT JOIN (SELECT DISTINCT customer_id FROM orders) o ON o.customer_id = c.id
WHERE o.customer_id IS NULL;

-- ✅ ALTERNATIVE: NOT EXISTS (correlated, no GROUP BY — supported)
SELECT c.name FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.id
);
```

**3. Other restrictions:**
- Correlated subquery expressions under `OR` are not supported
- Correlated subqueries with `ALL` are not supported

For all cases, consider rewriting as `JOIN` or `LEFT JOIN` operations.

## Advanced SQL Features

### Common Table Expressions (CTEs)

```sql
-- Simple CTE
WITH monthly_sales AS (
    SELECT
        date_trunc('month', order_date) as month,
        SUM(total_amount) as monthly_total
    FROM orders
    GROUP BY date_trunc('month', order_date)
)
SELECT month, monthly_total
FROM monthly_sales
WHERE monthly_total > (
    SELECT AVG(monthly_total) FROM monthly_sales
);

-- Multiple CTEs referencing each other
WITH
    regional_sales (region, total_sales) AS (
        SELECT sd.store_region, SUM(of.total_order_cost)
        FROM store.store_dimension sd
        JOIN store.store_orders_fact of ON sd.store_key = of.store_key
        GROUP BY store_region
    ),
    top_regions AS (
        SELECT region, total_sales
        FROM regional_sales
        ORDER BY total_sales DESC LIMIT 3
    )
SELECT * FROM top_regions;
```

#### CTE Syntax Rule: `WITH` Clause Is a Unit That Immediately Precedes the Statement

**The `WITH` clause (and `WITH RECURSIVE`) must appear immediately before the statement that uses it, forming an inseparable unit.** This applies to both regular CTEs and recursive CTEs.

When combined with `INSERT`, the `INSERT` keyword comes first, followed immediately by the `WITH` clause:

```sql
-- ✅ Correct: INSERT comes first, WITH immediately follows
INSERT INTO target_table
WITH cte AS (
    SELECT col1, col2 FROM source_table
)
SELECT col1, col2 FROM cte;

-- ✅ Correct: WITH RECURSIVE immediately follows INSERT
INSERT INTO target_table
WITH RECURSIVE cte AS (
    SELECT id, parent_id, 1 AS level FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.parent_id, c.level + 1
    FROM nodes n JOIN cte c ON n.parent_id = c.id
)
SELECT * FROM cte;

-- ❌ Wrong: WITH before INSERT (this is valid in Oracle/PostgreSQL/SQL Server/MySQL, but NOT in Vertica)
WITH cte AS (...)
INSERT INTO target_table SELECT * FROM cte;

-- ❌ Wrong: do not separate WITH from the statement that uses it
WITH cte AS (SELECT * FROM source_table)
-- ... other statements in between ...
SELECT * FROM cte;
```

> **Cross-database note**: Vertica and DB2 use `INSERT INTO ... WITH ... SELECT`, where `INSERT` comes before `WITH`. All other major databases (Oracle, PostgreSQL, SQL Server, MySQL) use `WITH ... INSERT INTO ... SELECT`, where `WITH` comes before `INSERT`. When migrating from those databases to Vertica, the `INSERT` and `WITH` keywords must be swapped.

> **Note**: The same `INSERT + WITH` ordering applies when using the `/*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/` hint:
> ```sql
> INSERT INTO target_table
> WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ RECURSIVE cte AS (...)
> SELECT * FROM cte;
> ```

#### Assigning CTE Results to Variables in PL/vSQL

Inside stored procedures and DO blocks, there are two ways to assign CTE results to variables:

**Method 1 — Direct assignment (preferred): `var := WITH ... SELECT ...`**

The `WITH` clause can be used directly as the right-hand side of a PL/vSQL assignment. Parentheses around the expression are optional. This works for both regular CTEs and `WITH RECURSIVE` CTEs:

```sql
-- ✅ Without parentheses (cleaner)
v_count := WITH RECURSIVE emp_tree AS (
               SELECT emp_id, manager_id, 1 AS level
               FROM employees WHERE manager_id IS NULL
               UNION ALL
               SELECT e.emp_id, e.manager_id, et.level + 1
               FROM employees e JOIN emp_tree et ON e.manager_id = et.emp_id
           )
           SELECT COUNT(*) FROM emp_tree;

-- ✅ With parentheses (also valid)
v_count := (
    WITH cte AS (SELECT COUNT(*) AS cnt FROM employees)
    SELECT cnt FROM cte
);
```

**Method 2 — SELECT INTO with subquery wrapper: `SELECT ... INTO var FROM (WITH ... SELECT ...) t`**

When using `SELECT INTO` syntax, the CTE **must** be wrapped in a subquery:

```sql
-- ✅ Correct: CTE wrapped in subquery
SELECT COUNT(*) INTO v_count
FROM (
    WITH RECURSIVE emp_tree AS (
        SELECT emp_id, manager_id, 1 AS level
        FROM employees WHERE manager_id IS NULL
        UNION ALL
        SELECT e.emp_id, e.manager_id, et.level + 1
        FROM employees e
        JOIN emp_tree et ON e.manager_id = et.emp_id
    )
    SELECT * FROM emp_tree
) t;
```

> **Note**: `SELECT ... INTO var WITH CTE ...` (without subquery wrapper) is **not valid** in Vertica. Use either `var := WITH ... SELECT ...` or `SELECT ... INTO var FROM (WITH ... SELECT ...) t`.

### Recursive CTEs (WITH RECURSIVE)

A `WITH RECURSIVE` clause iterates over its own output through repeated execution of a `UNION` or `UNION ALL` query. Recursive queries are useful for self-referential data such as manager-subordinate hierarchies or tree-structured taxonomies.

**Syntax:**

```sql
WITH [ /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ ] RECURSIVE
   cte_name [ (column_alias, ...) ] AS (
      non-recursive-term          -- Base case (anchor query)
      UNION [ ALL ]
      recursive-term              -- Recursive case (references cte_name)
)
```

**How it works:**
1. The **non-recursive term** (anchor) executes first and populates the CTE result set.
2. The **recursive term** iteratively queries the CTE's own output.
3. Recursion continues until the configured `WithClauseRecursionLimit` is reached, or the last iteration returns no rows.
4. All iteration results are combined and returned to the primary query.

**Configuration Parameter — `WithClauseRecursionLimit`:**

| Property | Value |
|----------|-------|
| Default | 8 |
| Scope | Database-level / Session-level |
| Note | No hard upper limit; high values can exhaust system resources |

```sql
-- Set recursion depth at session level
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 4;

-- Restore default
ALTER SESSION CLEAR PARAMETER WithClauseRecursionLimit;
```

**Example 1 — Generate a number sequence:**

```sql
ALTER SESSION SET PARAMETER WithClauseRecursionLimit = 4;

WITH RECURSIVE nums (n) AS (
    SELECT 1              -- Anchor: start from 1
    UNION ALL
    SELECT n + 1 FROM nums -- Recursive: increment by 1
)
SELECT n FROM nums;
 -- Result: 1, 2, 3, 4, 5
```

With the default limit of 8, this produces 9 rows (1 through 9).

**Example 2 — Employee-manager hierarchy traversal:**

Given a `personnel.employees` table with `emp_id`, `fname`, `lname`, `leader_id` (manager reference):

```sql
-- Find all employees who report directly/indirectly to 'Eric Redfield'
WITH RECURSIVE managers (employeeID, employeeName, sectionID, section, lead, leadID)
AS (
    -- Anchor: start with the target manager
    SELECT emp_id, fname || ' ' || lname, section_id, section_name,
           section_leader, leader_id
    FROM personnel.employees
    WHERE fname || ' ' || lname = 'Eric Redfield'

    UNION

    -- Recursive: find all employees whose leader is in the current result set
    SELECT e.emp_id, e.fname || ' ' || e.lname,
           e.section_id, e.section_name, e.section_leader, e.leader_id
    FROM personnel.employees e
    JOIN managers m ON m.employeeID = e.leader_id
)
SELECT employeeID, employeeName, lead AS "Reports to", section, leadID
FROM managers
ORDER BY sectionID, employeeName;
```

**Execution flow for the hierarchy example:**
1. Anchor query finds Eric Redfield (emp_id = 28).
2. First recursion finds employees whose `leader_id = 28` (direct reports: Nathan Ferguson, Benjamin Glover).
3. Second recursion finds employees whose `leader_id` matches the previous results (indirect reports).
4. Continues until no more matches are found or the recursion limit is reached.

**Example 3 — Employee hierarchy starting from a lower-level manager:**

```sql
-- Find all reports for 'Richard Chan' (fewer levels in the chain)
WITH RECURSIVE managers (employeeID, employeeName, sectionID, section, lead, leadID)
AS (
    SELECT emp_id, fname || ' ' || lname, section_id, section_name,
           section_leader, leader_id
    FROM personnel.employees
    WHERE fname || ' ' || lname = 'Richard Chan'

    UNION

    SELECT e.emp_id, e.fname || ' ' || e.lname,
           e.section_id, e.section_name, e.section_leader, e.leader_id
    FROM personnel.employees e
    JOIN managers m ON m.employeeID = e.leader_id
)
SELECT employeeID, employeeName, lead AS "Reports to", section
FROM managers
ORDER BY sectionID, employeeName;
```

**Restrictions:**

| Restriction | Details |
|-------------|---------|
| Non-recursive term | Cannot use `*` wildcard or `MATCH_COLUMNS()` function |
| Recursive term | Can reference the target CTE only **once** |
| Recursive reference | Cannot appear in an **outer join** |
| Recursive reference | Cannot appear in a **subquery** |
| UNION options | `ORDER BY`, `LIMIT`, and `OFFSET` are not supported inside the UNION |
| Statement types | Only `SELECT` and `INSERT` are supported (no `UPDATE` / `DELETE`) |

**Materialization for Deep Recursion:**

By default, Vertica rewrites recursive CTEs into subqueries (inline expansion). For deep recursion, this causes significant overhead. Enable materialization to store intermediate results in local temporary tables:

```sql
-- Option 1: Session-level configuration
ALTER SESSION SET PARAMETER WithClauseMaterialization = 1;

-- Option 2: Query-level hint
WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ RECURSIVE
    employee_hierarchy AS (
        SELECT employee_id, manager_id, name, 1 AS level
        FROM employees
        WHERE manager_id IS NULL
        UNION ALL
        SELECT e.employee_id, e.manager_id, e.name, eh.level + 1
        FROM employees e
        JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
    )
SELECT * FROM employee_hierarchy ORDER BY level, name;
```

| Approach | Behavior | Best For |
|----------|----------|----------|
| Inline expansion (default) | Rewrites as nested subqueries | Shallow recursion |
| Materialization | Stores intermediate results in temp tables | Deep recursion |

> **Tip:** If materialization is not possible, set the resource pool's `EXECUTIONPARALLELISM` to 1 to improve throughput for recursive queries.

### Window Functions

```sql
-- Ranking functions
SELECT
    product_name,
    price,
    RANK() OVER (ORDER BY price DESC) as price_rank,
    DENSE_RANK() OVER (ORDER BY price DESC) as dense_rank,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as category_rank
FROM products;

-- Analytic functions
SELECT
    sale_date,
    amount,
    SUM(amount) OVER (ORDER BY sale_date) as running_total,
    AVG(amount) OVER (PARTITION BY date_trunc('month', sale_date)) as monthly_avg,
    LAG(amount, 1) OVER (ORDER BY sale_date) as prev_amount,
    LEAD(amount, 1) OVER (ORDER BY sale_date) as next_amount
FROM sales;

-- Window framing
SELECT
    sale_date,
    amount,
    AVG(amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) as moving_avg_5day
FROM sales;
```

### Conditional Logic

```sql
-- CASE expressions
SELECT
    customer_id,
    total_orders,
    CASE
        WHEN total_orders >= 100 THEN 'VIP'
        WHEN total_orders >= 50 THEN 'Premium'
        WHEN total_orders >= 10 THEN 'Regular'
        ELSE 'New'
    END as customer_tier
FROM customer_summary;

-- DECODE function (Oracle compatibility)
SELECT
    product_id,
    DECODE(category_id,
        1, 'Electronics',
        2, 'Clothing',
        3, 'Books',
        'Other'
    ) as category_name
FROM products;
```

## PostgreSQL Compatibility (pgcompat)

Vertica's `pgcompat` extension package provides PostgreSQL-compatible functions, types, and system catalog views. **It is not installed by default.**

**Installation:**

```bash
# Install pgcompat package
admintools -t install_package -P pgcompat -d <dbname>
```

**Best practice — add `pg_catalog` to all users' search_path especially for vsql client:**

```sql
-- Append pg_catalog schema to default search_path of all users
DO $$
DECLARE
  usr VARCHAR;
  path VARCHAR;
BEGIN
  FOR usr, path IN QUERY SELECT user_name, search_path FROM users LOOP
      IF position('pg_catalog' in lower(path)) <= 0 THEN
        RAISE NOTICE 'ALTER USER % search_path %, pg_catalog', usr, path;
        EXECUTE 'ALTER USER ' || QUOTE_IDENT(usr) || ' search_path ' || path || ', pg_catalog';
      END IF;
  END LOOP;
END;
$$;
```

The library is `pg_catalog.PGCompatLib` and all objects reside in the `pg_catalog` schema.

### `generate_series()` — Generate Sequences

`generate_series` is a **transform function** that returns a sequence of values. It must be used in a `JOIN` (it cannot appear standalone in `FROM`). It must be on the **right side** of the join — placing it on the left causes an internal optimizer error.

**Signatures:**

| Signature | Description |
|---|---|
| `generate_series(int, int)` | Integer sequence from start to stop, step 1 |
| `generate_series(int, int, int)` | Integer sequence with custom step |
| `generate_series(numeric, numeric)` | Numeric sequence, step 1 |
| `generate_series(numeric, numeric, numeric)` | Numeric sequence with custom step |
| `generate_series(timestamp, timestamp, interval)` | Timestamp sequence |
| `generate_series(timestamptz, timestamptz, interval)` | Timestamptz sequence |

**Usage patterns:**

```sql
-- Standalone: CROSS JOIN with a dummy table
SELECT g.i
FROM (SELECT 1 AS d) t
CROSS JOIN generate_series(1, 10) AS g(i);

-- CROSS JOIN with a real table (cartesian product)
SELECT u.name, g.i
FROM users u
CROSS JOIN generate_series(1, 3) AS g(i);

-- INNER JOIN with ON condition (replaces loop-by-counter pattern)
SELECT u.name, g.i
FROM users u
JOIN generate_series(1, 3) AS g(i) ON u.id = g(i);

-- Aggregation: replace loop accumulation
SELECT g.i, COUNT(o.order_id) AS order_count
FROM (select generate_series(1, 3) AS i) g
LEFT JOIN orders o ON o.user_id = g.i
GROUP BY g.i
ORDER BY g.i;

-- Timestamp series: generate one row per day
SELECT g.ts::DATE AS day
FROM (SELECT 1 AS d) t
CROSS JOIN generate_series(
    TIMESTAMP '2026-01-01',
    TIMESTAMP '2026-01-31',
    INTERVAL '1 day'
) AS g(ts);
```

**Replacing loop-counter patterns:**

```sql
-- Anti-pattern: loop N times with counter variable
-- FOR i IN 1..10 LOOP
--     INSERT INTO result SELECT * FROM data WHERE category = i;
-- END LOOP;

-- Optimized: JOIN generate_series
INSERT INTO result
SELECT d.*
FROM data d
JOIN generate_series(1, 10) AS g(i) ON d.category = i;
```

**Restrictions:**

- Cannot be used standalone in `FROM`: `SELECT * FROM generate_series(1, 10)` → error
- Must appear on the **right side** of a join; left-side placement causes an internal optimizer error
- Requires `JOIN` or `CROSS JOIN` syntax — comma-style join does not work

### Other pgcompat Functions

| Function | Description |
|---|---|
| `pg_typeof(value)` | Returns the data type name of a value as text |
| `obj_description(oid, catalog)` | Returns the comment for a database object (dummy implementation) |
| `pg_get_expr(expr, pretty)` | Decompiles an expression (dummy implementation) |
| `pg_get_partkeydef(oid)` | Returns partition key definition (dummy implementation) |
| `array_upper(array, dim)` | Returns the upper bound of an array dimension |
| `format_type(type_oid, typmod)` | Formats a type name with its modifier |

```sql
-- pg_typeof
SELECT pg_typeof(42);        -- returns 'int'
SELECT pg_typeof('hello');   -- returns 'varchar'

-- array_upper
SELECT array_upper(ARRAY[1,2,3], 1);  -- returns 3
```

### `pg_catalog` System Catalog Views

pgcompat creates PostgreSQL-compatible views in the `pg_catalog` schema. These are useful when migrating PostgreSQL queries that reference system catalogs.

| View | Description |
|---|---|
| `pg_type` | Data types |
| `pg_class` | Tables, views, sequences, indexes |
| `pg_namespace` | Schemas |
| `pg_attribute` | Table columns |
| `pg_proc` | Functions and procedures |
| `pg_roles` | Roles and users |
| `pg_user` | Database users |
| `pg_depend` | Object dependencies |
| `pg_description` | Object comments |
| `pg_attrdef` | Column defaults |
| `pg_range` | Range types (empty/dummy) |
| `pg_enum` | Enum types (empty/dummy) |
| `pg_stat_activity` | Current session activity |
| `pg_shdescription` | Shared descriptions (empty/dummy) |

```sql
-- List all user tables (PostgreSQL-compatible)
SELECT n.nspname, c.relname
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r' AND n.nspname = 'public';

-- List columns for a table (PostgreSQL-compatible)
SELECT attname, atttypid::regtype
FROM pg_catalog.pg_attribute
WHERE attrelid = 'my_table'::regclass AND attnum > 0;
```

### pgcompat Types

| Type | Description |
|---|---|
| `pg_catalog.text` | Alias for `varchar` |
| `pg_catalog.regclass` | Object identifier type (used for casting to reference catalog entries) |

```sql
-- Cast table name to regclass to get its OID
SELECT 'my_table'::regclass::int;
```

---

## Data Loading

### COPY Statement

```sql
-- Load from file
COPY table_name FROM '/path/to/file.csv'
DELIMITER ','
ENCLOSED BY '"'
SKIP 1;  -- Skip header row

-- Load with transformations
COPY customers FROM '/path/to/customers.csv'
DELIMITER ','
NULL 'NULL'
DIRECT  -- Load directly to ROS
AS
    customer_id,
    first_name,
    last_name,
    email,
    created_date AS created_date::DATE,
    status AS COALESCE(status, 'ACTIVE')
;
```

### Bulk Operations

```sql
-- Bulk INSERT using UNION ALL
INSERT INTO target_table
SELECT 1, 'John' UNION ALL
SELECT 2, 'Jane' UNION ALL
SELECT 3, 'Bob';

-- INSERT with RETURNING
INSERT INTO logs (message, log_level, created_at)
VALUES ('Application started', 'INFO', NOW())
RETURNING log_id, created_at;
```

## Transaction Control

```sql
-- Explicit transaction
BEGIN;
INSERT INTO accounts (account_id, balance) VALUES (1, 1000);
INSERT INTO transactions (account_id, amount, type) VALUES (1, 1000, 'DEPOSIT');
COMMIT;

-- Transaction with savepoint
BEGIN;
INSERT INTO orders (customer_id, total) VALUES (123, 500);
SAVEPOINT order_created;
INSERT INTO order_details (order_id, product_id, quantity) VALUES (currval('orders_order_id_seq'), 456, 2);
-- If error occurs:
ROLLBACK TO SAVEPOINT order_created;
-- Or commit if successful:
COMMIT;
```

This comprehensive SQL syntax reference provides the foundation for writing effective Vertica queries beyond migration scenarios, covering all aspects of database development from basic operations to advanced features.