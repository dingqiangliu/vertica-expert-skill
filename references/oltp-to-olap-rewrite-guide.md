# OLTP to OLAP SQL Rewrite & Optimization Guide

This guide covers **architectural rewrite patterns** for migrating from OLTP / row-by-row procedural styles to Vertica's columnar OLAP / batch-processing model. It focuses on **scenario-based transformations** that replace iterative, single-row operations with set-based SQL that leverages Vertica's MPP columnar architecture.

## Purpose

Vertica is optimized for **bulk, set-based analytical operations** — not for the row-at-a-time, transaction-per-row patterns common in OLTP databases (Oracle, DB2, SQL Server, PostgreSQL, MySQL). Migrating the SQL syntax is necessary but insufficient; the **processing paradigm** must also shift. This guide provides concrete before/after rewrite patterns for the most common scenarios.

### Key Principles

| Principle | Description |
|-----------|-------------|
| **Set over row** | Process entire datasets in single SQL statements, not row-by-row loops |
| **Bulk over single** | Combine multiple small operations (INSERT, UPDATE) into one bulk operation |
| **SQL over procedural** | Push logic into SQL expressions (JOINs, window functions, CTEs) instead of PL/vSQL loops |
| **Minimize commits** | Reduce unnecessary COMMITs (e.g., per-row or per-batch inside loops); keep COMMIT only where needed for transaction control, batch boundaries, or error recovery |
| **Avoid cursors** | Replace cursor-based iteration with set-based JOINs or analytic functions |

---

## Pattern 1: Adjacent Single-Row DML Statements → Single Bulk Operation

### Problem

Multiple adjacent `INSERT` or `UPDATE` statements target the same table, each operating on one row or one key. Common in ETL scripts and procedure-generated code. Each statement incurs its own transaction overhead, parse/write cycle, and ROS container.

### Anti-Pattern — Multiple Single-Row INSERTs

```sql
INSERT INTO sales_summary (region, total_sales) VALUES ('East', 15000);
INSERT INTO sales_summary (region, total_sales) VALUES ('West', 23000);
INSERT INTO sales_summary (region, total_sales) VALUES ('North', 18000);
INSERT INTO sales_summary (region, total_sales) VALUES ('South', 12000);
```

### Optimized Rewrite — Multi-Row INSERT

```sql
INSERT INTO sales_summary (region, total_sales) VALUES
    ('East', 15000),
    ('West', 23000),
    ('North', 18000),
    ('South', 12000);
```

**Why it's better**: Single parse, single transaction, single bulk write. Vertica's columnar storage benefits enormously from batch writes — fewer ROS containers, less Tuple Mover overhead, better compression.

### Anti-Pattern — Multiple Single-Row UPDATEs

```sql
UPDATE products SET price = price * 1.10 WHERE product_id = 101;
UPDATE products SET price = price * 1.10 WHERE product_id = 102;
UPDATE products SET price = price * 1.15 WHERE product_id = 103;
UPDATE products SET price = price * 1.05 WHERE product_id = 104;
```

### Optimized Rewrite — Set-Based UPDATE

```sql
UPDATE products
SET price = price * CASE product_id
    WHEN 101 THEN 1.10
    WHEN 102 THEN 1.10
    WHEN 103 THEN 1.15
    WHEN 104 THEN 1.05
END
WHERE product_id IN (101, 102, 103, 104);
```

Or, if the update values come from another table or derived source:

```sql
UPDATE products p
SET price = p.price * r.adjustment_factor
FROM price_adjustments r
WHERE p.product_id = r.product_id;
```

**Why it's better**: Single table scan, single transaction. Vertica's UPDATE is a delete+append at the storage level — batching minimizes ROS fragmentation.

---

## Pattern 2: Row-by-Row DML Inside Loops → Set-Based SQL

### Problem

A stored procedure iterates over a range of values, a lookup table, or a cursor, and issues one DML statement (INSERT, UPDATE, DELETE, or MERGE-equivalent) per iteration. This is the single most common and most impactful anti-pattern in OLTP-to-OLAP migration. All variants suffer from N× round-trips and N× transaction overhead.

This pattern has several sub-types depending on the DML verb and the data source. Each sub-type is covered below.

---

### 2A: Loop INSERT Over Generated Values → INSERT...SELECT with generate_series / unnest

A `FOR` loop iterates over a range of values and issues one or more SQL statements per iteration. Common variants:

- **Date range**: `FOR d IN QUERY SELECT generate_series(start_date, end_date, interval)` — iterate over consecutive dates
- **Integer counter**: `FOR i IN RANGE 1..N LOOP` — iterate with an integer counter
- **Discrete values**: `FOR v IN QUERY (SELECT val FROM list) LOOP` — iterate over an arbitrary set of values

---

#### Date Range Iteration

##### Anti-Pattern

```sql
-- PL/vSQL: iterate over dates, one SELECT + one INSERT per day
DECLARE
    v_date DATE;
    v_count INTEGER;
BEGIN
    FOR v_date IN QUERY
        SELECT generate_series(DATE '2024-01-01', DATE '2024-12-31', INTERVAL '1 day')
    LOOP
        SELECT COUNT(*) INTO v_count
        FROM orders
        WHERE order_date = v_date;

        PERFORM INSERT INTO daily_order_stats (stat_date, order_count)
        VALUES (v_date, v_count);
    END LOOP;
END;
```

##### Optimized Rewrite — Subquery-wrapped generate_series + LEFT JOIN

```sql
-- Prerequisite table creation
CREATE TABLE IF NOT EXISTS daily_order_stats (stat_date DATE, order_count INTEGER);
CREATE TABLE IF NOT EXISTS orders (order_date DATE, order_id INTEGER);

-- Single set-based INSERT...SELECT with GROUP BY
INSERT INTO daily_order_stats (stat_date, order_count)
SELECT order_date, COUNT(*)
FROM orders
WHERE order_date BETWEEN DATE '2024-01-01' AND DATE '2024-12-31'
GROUP BY order_date;
```

To also produce rows for dates with zero orders (the loop generates all dates regardless), wrap `generate_series` in a subquery and use `LEFT JOIN` (Vertica does not support `RIGHT JOIN` with UDTFs):

```sql
INSERT INTO daily_order_stats (stat_date, order_count)
SELECT g.d::DATE, COUNT(o.order_id)
FROM (SELECT generate_series(DATE '2024-01-01', DATE '2024-12-31', INTERVAL '1 day') AS d) g
LEFT JOIN orders o ON o.order_date = g.d
GROUP BY g.d;
```

---

#### Integer Counter Iteration

##### Anti-Pattern

```sql
-- PL/vSQL: iterate 1..N, using counter i to process data
DECLARE
    v_count INTEGER;
BEGIN
    FOR i IN RANGE 1..100 LOOP
        SELECT COUNT(*) INTO v_count
        FROM orders
        WHERE category_id = i;

        PERFORM INSERT INTO category_stats (category_id, order_count)
        VALUES (i, v_count);
    END LOOP;
END;
```

##### Optimized Rewrite — Subquery-wrapped generate_series + LEFT JOIN

```sql
INSERT INTO category_stats (category_id, order_count)
SELECT g.i, COUNT(o.order_id)
FROM (SELECT generate_series(1, 100) AS i) g
LEFT JOIN orders o ON o.category_id = g.i
GROUP BY g.i;
```

---

#### Discrete Value List Iteration

##### Anti-Pattern

```sql
-- PL/vSQL: iterate over a list of status values
DECLARE
    v_status VARCHAR(20);
BEGIN
    FOR v_status IN QUERY
        SELECT 'PENDING' UNION ALL SELECT 'PROCESSING' UNION ALL SELECT 'COMPLETED'
    LOOP
        PERFORM INSERT INTO status_summary (status, total_amount)
        SELECT v_status, SUM(amount)
        FROM transactions
        WHERE status = v_status;
    END LOOP;
END;
```

##### Optimized Rewrite — Subquery-wrapped unnest + LEFT JOIN

```sql
INSERT INTO status_summary (status, total_amount)
SELECT s.status, SUM(t.amount)
FROM (SELECT unnest(ARRAY['PENDING', 'PROCESSING', 'COMPLETED']) AS status) s
LEFT JOIN transactions t ON t.status = s.status
GROUP BY s.status;
```

#### Key Points

| Loop variant | Replacement |
|---|---|
| Date range (`FOR d IN QUERY SELECT generate_series(...)`) | Subquery-wrapped `generate_series` + `LEFT JOIN` |
| Integer counter (`FOR i IN RANGE 1..N`) | Subquery-wrapped `generate_series` + `LEFT JOIN` |
| Discrete values (`FOR v IN (SELECT ...)`) | Subquery-wrapped `unnest(ARRAY[...])` + `LEFT JOIN` |

- `generate_series` and `unnest` are transform (UDTF) functions — they must be used in a JOIN, not standalone in `FROM`
- UDTFs must appear on the **right side** of a join; Vertica only supports INNER and LEFT joins with UDTFs — `RIGHT JOIN` is **not supported**
- When you need to **preserve all UDTF-generated rows** (including those with no match), wrap the UDTF in a subquery on the **left side** of a `LEFT JOIN`
- If the loop counter drives **different logic per iteration**, use `CASE` expressions or `UNION ALL` instead

**Why it's better**: One statement. Vertica parallelizes the scan across nodes. No PL/vSQL overhead, no per-row context switch. Orders of magnitude faster for large N.

---

### 2B: Loop INSERT from a Lookup/Join Table → INSERT...SELECT with JOIN

A loop iterates over a set of parameters or a small lookup table, combining each value with a source table, and inserts results one batch at a time. Unlike 2A (where values are generated by `generate_series` or `unnest`), here the values come from a **subquery or lookup table**.

#### Anti-Pattern

```sql
-- Loop over status values from a lookup table, insert matching aggregates one by one
DECLARE
    v_status VARCHAR(20);
BEGIN
    FOR v_status IN QUERY SELECT status FROM status_lookup LOOP
        PERFORM INSERT INTO status_summary (status, total_amount, record_count)
        SELECT v_status, SUM(amount), COUNT(*)
        FROM transactions
        WHERE status = v_status;
    END LOOP;
END;
```

#### Optimized Rewrite

```sql
-- Single INSERT...SELECT with JOIN to the lookup table
INSERT INTO status_summary (status, total_amount, record_count)
SELECT s.status, SUM(t.amount), COUNT(*)
FROM status_lookup s
JOIN transactions t ON t.status = s.status
GROUP BY s.status;
```

For small static lists, `UNION ALL` inline table or `unnest(ARRAY[...])` also works (see 2A):

```sql
-- Inline table with UNION ALL
INSERT INTO status_summary (status, total_amount, record_count)
SELECT s.status, SUM(t.amount), COUNT(*)
FROM (SELECT 'PENDING' AS status
      UNION ALL SELECT 'PROCESSING'
      UNION ALL SELECT 'COMPLETED'
      UNION ALL SELECT 'FAILED') s
JOIN transactions t ON t.status = s.status
GROUP BY s.status;
```

**Why it's better**: One pass over the source table instead of one pass per loop iteration. Vertica scans `transactions` once, hashes the join, and produces all groups in parallel.

---

### 2C: Temp Table + Loop Population → CTE or Derived Table

A stored procedure creates a temporary table, populates it row-by-row in a loop, then queries it.

#### Anti-Pattern

```sql
CREATE LOCAL TEMP TABLE tmp_status ON COMMIT PRESERVE ROWS AS
    SELECT status FROM transactions WHERE 1 = 0;

-- PL/vSQL: loop to populate temp table row by row
DO $$
DECLARE
    v_status VARCHAR(50);
BEGIN
    FOR v_status IN QUERY SELECT DISTINCT status FROM transactions LOOP
        PERFORM INSERT INTO tmp_status VALUES (v_status);
    END LOOP;
END;
$$;

-- Then use it
SELECT t.status, SUM(amount)
FROM transactions t
JOIN tmp_status s ON s.status = t.status
GROUP BY t.status;
```

#### Optimized Rewrite

```sql
-- Replace with CTE
WITH tmp_status AS (
    SELECT DISTINCT status FROM transactions
)
SELECT t.status, SUM(t.amount)
FROM transactions t
JOIN tmp_status s ON s.status = t.status
GROUP BY t.status;
```

Or simply eliminate the temp table entirely:

```sql
SELECT status, SUM(amount)
FROM transactions
GROUP BY status;
```

**Why it's better**: No temp table creation, no loop overhead, no intermediate materialization. CTEs are inlined and optimized by Vertica's query planner.

---

### 2D: Row-by-Row DELETE Loop → Set-Based DELETE or Partition Drop

A loop deletes rows one key at a time, or deletes from different partitions in sequence.

#### Anti-Pattern

```sql
-- PL/vSQL: row-by-row DELETE in a loop
DO $$
DECLARE
    v_customer_id INTEGER;
BEGIN
    FOR v_customer_id IN QUERY SELECT customer_id FROM customers_to_purge LOOP
        PERFORM DELETE FROM orders WHERE customer_id = v_customer_id;
    END LOOP;
END;
$$;
```

#### Optimized Rewrite

```sql
-- Set-based DELETE with subquery
DELETE FROM orders
WHERE customer_id IN (SELECT customer_id FROM customers_to_purge);
```

Or with EXISTS:

```sql
DELETE FROM orders
WHERE EXISTS (
    SELECT 1 FROM customers_to_purge p
    WHERE p.customer_id = orders.customer_id
);
```

For time-series partitioned tables, **drop entire partitions** instead of deleting rows:

```sql
-- Instead of: DELETE FROM web_events WHERE event_date < '2023-01-01'
SELECT DROP_PARTITIONS('web_events', '2022-01-01', '2022-12-31');
```

**Why it's better**: `DROP_PARTITIONS` is a metadata operation — near-instant, no scan, no ROS impact. Set-based DELETE is a single parallel scan.

---

### 2E: Row-by-Row UPSERT in Loop → Vertica MERGE

Row-by-row "if exists update else insert" logic, often from application code or cursors.

#### Anti-Pattern

```sql
-- PL/vSQL: row-by-row upsert in a loop
DO $$
DECLARE
    v_key INTEGER;
    v_value VARCHAR(100);
BEGIN
    FOR v_key, v_value IN QUERY SELECT key, value FROM staging_table LOOP
        PERFORM UPDATE target_table
        SET value = v_value, updated_at = CURRENT_TIMESTAMP
        WHERE key = v_key;

        IF NOT FOUND THEN
            PERFORM INSERT INTO target_table (key, value, updated_at)
            VALUES (v_key, v_value, CURRENT_TIMESTAMP);
        END IF;
    END LOOP;
END;
$$;
```

#### Optimized Rewrite

```sql
-- Prerequisite table creation
CREATE TABLE IF NOT EXISTS target_table (key INTEGER, value VARCHAR(100), updated_at TIMESTAMP);
CREATE TABLE IF NOT EXISTS staging_table (key INTEGER, value VARCHAR(100));

-- Vertica supports MERGE
MERGE INTO target_table t
USING staging_table s ON t.key = s.key
WHEN MATCHED THEN
    UPDATE SET value = s.value, updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT (key, value, updated_at) VALUES (s.key, s.value, CURRENT_TIMESTAMP);
```

**Why it's better**: Single pass over both tables. Vertica optimizes the merge as a hash or merge join, not N individual lookups.

---

### 2F: Row-by-Row Aggregation in PL/vSQL → INSERT...SELECT with GROUP BY

A procedure reads rows one by one, accumulates sums/counts in variables grouped by some key, then inserts the aggregated results.

#### Anti-Pattern

```sql
DECLARE
    v_current_region VARCHAR(50) := NULL;
    v_total NUMERIC(18,2) := 0;
    v_count INTEGER := 0;
BEGIN
    FOR rec IN QUERY SELECT region, amount FROM sales ORDER BY region LOOP
        IF v_current_region IS NULL THEN
            v_current_region := rec.region;
        END IF;

        IF rec.region <> v_current_region THEN
            PERFORM INSERT INTO region_totals VALUES (v_current_region, v_total, v_count);
            v_total := 0;
            v_count := 0;
            v_current_region := rec.region;
        END IF;

        v_total := v_total + rec.amount;
        v_count := v_count + 1;
    END LOOP;

    -- Don't forget the last group!
    IF v_count > 0 THEN
        PERFORM INSERT INTO region_totals VALUES (v_current_region, v_total, v_count);
    END IF;
END;
```

#### Optimized Rewrite

```sql
INSERT INTO region_totals
SELECT region, SUM(amount), COUNT(*)
FROM sales
GROUP BY region;
```

**Why it's better**: This is what Vertica was built for. Parallel aggregation across all nodes, optimized hash or piped grouping, single bulk insert.

---

### 2G: Dynamic SQL in Loop for Static Objects → Static SQL

A loop builds dynamic SQL strings with different literal values and executes them. This is unnecessary in Vertica and prevents plan caching.

#### Anti-Pattern

```sql
-- PL/vSQL: dynamic SQL in loop for static objects
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN RANGE 1..100 LOOP
        PERFORM EXECUTE 'INSERT INTO partition_' || i || ' SELECT * FROM source WHERE partition_key = ' || i;
    END LOOP;
END;
$$;
```

#### Optimized Rewrite

```sql
-- Single set-based INSERT with partition key routing
INSERT INTO target_table
SELECT *, partition_key
FROM source
WHERE partition_key BETWEEN 1 AND 100;
```

If separate physical tables are truly needed (e.g., legacy partition scheme), consider **Vertica's native partitioning** instead:

```sql
CREATE TABLE measurements (
    sensor_id INTEGER,
    reading_time TIMESTAMP,
    value NUMERIC(18,6)
) PARTITION BY reading_time::DATE;
```

**Why it's better**: Static SQL is parsed once, planned once, and can be cached. Native partitioning handles partition management automatically.

---

## Pattern 3: Ordered Row-by-Row Processing with Shared Variables → Window Functions for Iterations, Nested CTE for Complex Multi-Step Calculations

### Problem

Cursors iterate over ordered rows to perform complex multi-step calculations that require maintaining multiple shared intermediate variables (running totals, previous values, counters, trend indicators) across iterations. Each row's computation depends on both the current row data and accumulated state from previous rows, enabling sophisticated sequential analysis that cannot be expressed in simple set-based operations.

> **🔑 Key principle**: The replacement for cursor iterations is **window functions** (`SUM() OVER`, `LAG() OVER`, `ROW_NUMBER() OVER`, etc.). For complex multi-step calculations, **nested CTEs** can be used as a code-organization tool to break logic into readable layers — but CTE layers do **not** represent iterations. Whether you use 1 flat SELECT or 5 nested CTEs, the query still executes as a **single parallel scan**. **The number of CTE layers is unrelated to the number of loop iterations in the original cursor code.**

---

### 3A: Basic Running Calculations

#### Anti-Pattern

```sql
DECLARE
    v_running_total NUMERIC := 0;
    v_prev_date DATE;
    v_gap INTEGER;
    v_order_date DATE;
    v_amount NUMERIC;
BEGIN
    FOR v_order_date, v_amount IN QUERY SELECT order_date, amount FROM orders ORDER BY order_date LOOP
        v_running_total := v_running_total + v_amount;

        IF v_prev_date IS NOT NULL THEN
            v_gap := v_order_date - v_prev_date;
        END IF;

        PERFORM INSERT INTO order_analysis (order_date, amount, running_total, day_gap)
        VALUES (v_order_date, v_amount, v_running_total, v_gap);

        v_prev_date := v_order_date;
    END LOOP;
END;
```

#### Optimized Rewrite — Direct Window Functions

```sql
-- Prerequisite table creation
CREATE TABLE IF NOT EXISTS order_analysis (order_date DATE, amount NUMERIC, running_total NUMERIC, day_gap INTEGER);

INSERT INTO order_analysis (order_date, amount, running_total, day_gap)
SELECT
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date) AS running_total,
    order_date - LAG(order_date) OVER (ORDER BY order_date) AS day_gap
FROM orders;
```

---

### 3B: Complex Multi-Step Calculations with Shared Variables

#### Anti-Pattern

```sql
DECLARE
    v_running_total NUMERIC := 0;
    v_prev_amount NUMERIC := 0;
    v_trend_indicator INTEGER := 0;
    v_cumulative_avg NUMERIC := 0;
    v_row_count INTEGER := 0;
    v_volatility_score NUMERIC := 0;
    v_order_date DATE;
    v_amount NUMERIC;
BEGIN
    FOR v_order_date, v_amount IN QUERY SELECT order_date, amount FROM orders ORDER BY order_date LOOP
        v_row_count := v_row_count + 1;
        v_running_total := v_running_total + v_amount;
        v_cumulative_avg := v_running_total / v_row_count;

        -- Trend calculation (1 if increasing, -1 if decreasing, 0 if stable)
        IF v_amount > v_prev_amount THEN
            v_trend_indicator := 1;
        ELSIF v_amount < v_prev_amount THEN
            v_trend_indicator := -1;
        ELSE
            v_trend_indicator := 0;
        END IF;

        -- Volatility calculation (simplified)
        IF v_row_count > 1 THEN
            v_volatility_score := v_volatility_score + ABS(v_amount - v_prev_amount);
        END IF;

        PERFORM INSERT INTO complex_order_analysis (
            order_date, amount, running_total, cumulative_avg,
            trend_indicator, volatility_score, row_num
        ) VALUES (
            v_order_date, v_amount, v_running_total, v_cumulative_avg,
            v_trend_indicator, v_volatility_score, v_row_count
        );

        v_prev_amount := v_amount;
    END LOOP;
END;
```

#### Optimized Rewrite — Flat Window Functions (Recommended)

> **Key principle: CTE layers ≠ loop iterations.** All window functions in a single SELECT are computed in parallel. No matter how many CTE layers you write, execution is always a **single-pass scan**. CTEs are a code organization tool, not iterations.

The approach below flattens all calculations into a single SELECT. Each column is a window function expression computed simultaneously — **there is no concept of "layers" and no iteration**. Block comments after each expression map it to the corresponding procedural variable from the original cursor code:

```sql
-- Create the target table
CREATE TABLE IF NOT EXISTS complex_order_analysis (
    order_date DATE,
    amount NUMERIC,
    running_total NUMERIC,
    cumulative_avg NUMERIC,
    trend_indicator INTEGER,
    volatility_score NUMERIC,
    row_num INTEGER
);

INSERT INTO complex_order_analysis
SELECT
    order_date,
    amount,
    /*
     * v_row_count := v_row_count + 1;
     */
    ROW_NUMBER() OVER (ORDER BY order_date) AS row_num,
    /*
     * v_running_total := v_running_total + v_amount;
     */
    SUM(amount) OVER (ORDER BY order_date) AS running_total,
    /*
     * v_cumulative_avg := v_running_total / v_row_count;
     */
    AVG(amount) OVER (ORDER BY order_date) AS cumulative_avg,
    /*
     * IF v_amount > v_prev_amount THEN
     *     v_trend_indicator := 1;
     * ELSIF v_amount < v_prev_amount THEN
     *     v_trend_indicator := -1;
     * ELSE
     *     v_trend_indicator := 0;
     * END IF;
     */
    CASE
        WHEN amount > LAG(amount, 1, 0) OVER (ORDER BY order_date) THEN 1
        WHEN amount < LAG(amount, 1, 0) OVER (ORDER BY order_date) THEN -1
        ELSE 0
    END AS trend_indicator,
    /*
     * IF v_row_count > 1 THEN
     *     v_volatility_score := v_volatility_score + ABS(v_amount - v_prev_amount);
     * END IF;
     */
    SUM(
        CASE
            WHEN ROW_NUMBER() OVER (ORDER BY order_date) > 1
            THEN ABS(amount - LAG(amount, 1, 0) OVER (ORDER BY order_date))
            ELSE 0
        END
    ) OVER (ORDER BY order_date) AS volatility_score
FROM orders;
```

#### Alternative: Nested CTEs for Readability

If the calculation logic is very complex with many inter-column dependencies, nested CTEs can be used to organize the logic in layers. **But remember: CTE layers ≠ loop iterations. Execution is still a single scan.** The nested CTE version below has an **similar execution plan** to the flat version above — the key difference is code organization:

```sql
INSERT INTO complex_order_analysis
WITH base_data AS (
    SELECT
        order_date,
        amount,
        /* v_row_count := v_row_count + 1; */
        ROW_NUMBER() OVER (ORDER BY order_date) AS row_num
    FROM orders
),
with_lag_data AS (
    SELECT
        order_date, amount, row_num,
        /*
         * v_prev_amount := v_amount;  (from previous row)
         * LAG returns NULL for the first row, equivalent to v_prev_amount := 0;
         */
        LAG(amount, 1, 0) OVER (ORDER BY order_date) AS prev_amount
    FROM base_data
),
with_running_calc AS (
    SELECT
        order_date, amount, row_num, prev_amount,
        /* v_running_total := v_running_total + v_amount; */
        SUM(amount) OVER (ORDER BY order_date) AS running_total,
        /* v_cumulative_avg := v_running_total / v_row_count; */
        AVG(amount) OVER (ORDER BY order_date) AS cumulative_avg
    FROM with_lag_data
),
with_trend_calc AS (
    SELECT
        order_date, amount, row_num, prev_amount, running_total, cumulative_avg,
        /*
         * IF v_amount > v_prev_amount THEN
         *     v_trend_indicator := 1;
         * ELSIF v_amount < v_prev_amount THEN
         *     v_trend_indicator := -1;
         * ELSE
         *     v_trend_indicator := 0;
         * END IF;
         */
        CASE
            WHEN amount > prev_amount THEN 1
            WHEN amount < prev_amount THEN -1
            ELSE 0
        END AS trend_indicator
    FROM with_running_calc
)
SELECT
    order_date, amount, running_total, cumulative_avg,
    trend_indicator,
    /*
     * IF v_row_count > 1 THEN
     *     v_volatility_score := v_volatility_score + ABS(v_amount - v_prev_amount);
     * END IF;
     */
    SUM(CASE WHEN row_num > 1 THEN ABS(amount - prev_amount) ELSE 0 END)
        OVER (ORDER BY order_date) AS volatility_score,
    row_num
FROM with_trend_calc;
```

**Comparison**:

| Approach | Characteristics | Best For |
|---|---|---|
| **Flat SELECT** (recommended) | All window functions in one SELECT, simplest execution plan | Most scenarios |
| **Nested CTEs** (alternative) | Layered organization, clearer logic flow, but layers ≠ iterations | Complex inter-column dependencies |

**Why it's better**:

1. **Single-pass processing**: Regardless of flat or nested CTE, all window functions are computed in **one parallel scan** — no row-by-row iteration
2. **No cursor overhead**: Eliminates procedural loop and variable assignment costs
3. **CTE layers ≠ loop iterations**: 5 nested CTE layers is still a single scan, not 5 passes — CTEs are logical grouping only; Vertica's query optimizer merges them into one execution plan
4. **Window functions are the core mechanism**: The key replacement is window functions (`SUM() OVER`, `LAG() OVER`, `AVG() OVER`), **not** CTEs — CTEs are just a code organization aid
5. **Better scalability**: Performance scales with data volume rather than degrading linearly like cursors

This is the single most impactful rewrite pattern for OLTP → OLAP migration, especially for complex iterative calculations.

---

### 3C: Grouped Running Calculations — Partition-Level Sequencing and State

PL/vSQL variables carry state across cursor iterations — comparing current row to previous row, detecting group boundaries, computing streaks, or assigning sequence numbers within groups.

#### Anti-Pattern

```sql
DECLARE
    v_prev_customer INTEGER := NULL;
    v_seq INTEGER := 0;
    v_customer_id INTEGER;
    v_order_date DATE;
BEGIN
    FOR v_customer_id, v_order_date IN QUERY SELECT customer_id, order_date FROM orders ORDER BY customer_id, order_date LOOP
        IF v_customer_id <> v_prev_customer THEN
            v_seq := 0;
        END IF;
        v_seq := v_seq + 1;

        PERFORM INSERT INTO order_sequence VALUES (v_customer_id, v_order_date, v_seq);

        v_prev_customer := v_customer_id;
    END LOOP;
END;
```

#### Optimized Rewrite

```sql
INSERT INTO order_sequence
SELECT customer_id, order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS seq
FROM orders;
```

**Why it's better**: Single scan, single INSERT. Window functions handle partitioning and ordering in parallel across all nodes.

---

### Common Cursor-to-Analytic Mappings

| Cursor Pattern | Window Function Replacement |
|---|---|
| Running total (variable accumulator) | `SUM(col) OVER (ORDER BY ...)` |
| Row counter | `ROW_NUMBER() OVER (ORDER BY ...)` |
| Previous row value | `LAG(col, 1) OVER (ORDER BY ...)` |
| Next row value | `LEAD(col, 1) OVER (ORDER BY ...)` |
| Rank within group | `RANK() OVER (PARTITION BY ... ORDER BY ...)` |
| Percentage of total | `col / SUM(col) OVER ()` |
| Moving average | `AVG(col) OVER (ORDER BY ... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` |
| Group boundary detection + per-group sequence | `ROW_NUMBER() OVER (PARTITION BY group_key ORDER BY ...)` |

---

## Pattern 4: Per-Row Function Call in SELECT → Set-Based JOIN

### Problem

A scalar user-defined function is called once per row in a `SELECT` to compute a derived value. This is the classic OLTP pattern of encapsulating business logic in a per-row function.

### Anti-Pattern

```sql
-- Function called once per row (N rows = N function invocations)
SELECT order_id, order_date,
       calculate_discount(customer_id, total_amount) AS discount
FROM orders;
```

If `calculate_discount` contains its own SQL queries (lookup tables, conditional logic), the cost is N × (function cost).

### Optimized Rewrite: JOIN to a Lookup/Derived Table

```sql
SELECT o.order_id, o.order_date,
       COALESCE(d.discount_rate, 0) * o.total_amount AS discount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN discount_rules d ON d.customer_tier = c.tier
                          AND o.total_amount >= d.min_amount;
```

**Why it's better**: Replaces N function invocations with a single JOIN. Vertica optimizes the join plan as one parallel scan.

---

## Pattern 5: Recursive/Parent-Child Traversal → Recursive CTE

### Problem

OLTP procedures use loops to traverse parent-child hierarchies (org charts, bill of materials), fetching one level at a time.

### Anti-Pattern

```sql
-- DO block: iterative level-by-level hierarchy traversal
DO $$
DECLARE
    v_level INTEGER := 0;
BEGIN
    -- Seed with top-level managers (level 1)
    v_level := 1;
    PERFORM INSERT INTO result
    SELECT employee_id, name, manager_id, v_level
    FROM employees
    WHERE manager_id IS NULL;

    -- Iteratively insert direct reports level by level
    LOOP
        v_level := v_level + 1;
        PERFORM INSERT INTO result
        SELECT e.employee_id, e.name, e.manager_id, v_level
        FROM employees e
        JOIN result r ON e.manager_id = r.employee_id
        WHERE r.level = v_level - 1
          AND e.employee_id NOT IN (SELECT employee_id FROM result);

        EXIT WHEN NOT FOUND;
    END LOOP;
END;
$$;
```

### Optimized Rewrite

```sql
-- Prerequisite table creation
CREATE TABLE IF NOT EXISTS employees (employee_id INTEGER, name VARCHAR(100), manager_id INTEGER);

-- Vertica uses recursive CTEs for hierarchical queries
WITH RECURSIVE org_tree AS (
    -- Anchor: top-level employees (no manager)
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: direct reports
    SELECT e.employee_id, e.name, e.manager_id, ot.level + 1
    FROM employees e
    JOIN org_tree ot ON e.manager_id = ot.employee_id
)
SELECT employee_id, name, manager_id, level
FROM org_tree
ORDER BY level, name;
```

**Why it's better**: Single query, single execution plan. No iterative inserts, no repeated scans. Vertica's recursive CTE is the standard ANSI SQL approach for hierarchical traversal.

---

## Migration Checklist

Use this checklist to audit migrated code for OLTP anti-patterns. Each item should be checked against every stored procedure, script, and query being migrated.

### Row-by-Row Processing

- [ ] **No DML inside loops** — Replace all `FOR rec IN cursor LOOP ... INSERT/UPDATE/DELETE/MERGE` with set-based SQL (Pattern 2)
- [ ] **No dynamic SQL for static objects** — Remove unnecessary `EXECUTE` in loops; use static SQL with parameters (Pattern 2G)

### Set-Based Rewrite

- [ ] **Adjacent single-row DML → bulk statement** — Combine adjacent `INSERT INTO t VALUES (...)` into one `INSERT INTO t VALUES (...), (...), (...)`, and multiple single-row UPDATEs into one `UPDATE` with `CASE` or `UPDATE...FROM` (Pattern 1)
- [ ] **Cursor carrying state across rows → window functions** — Replace accumulator variables with `SUM() OVER (ORDER BY ...)`, `prev_value` variables with `LAG(col) OVER (...)`, and counter variables with `ROW_NUMBER() OVER (...)` (Pattern 3)
- [ ] **Loop aggregating by key → GROUP BY** — Replace group-accumulation loops with `INSERT...SELECT ... GROUP BY` (Pattern 2F)
- [ ] **Temp table + loop population → CTE** — Replace with `WITH` clause or derived table (Pattern 2C)
- [ ] **Per-row function call in SELECT → JOIN** — Replace N function invocations with a set-based JOIN (Pattern 4)

### Transaction and Batch

- [ ] **MERGE/UPSERT → Vertica MERGE** — Replace IF-EXISTS-UPDATE-ELSE-INSERT loops with `MERGE INTO` (Pattern 2E)
- [ ] **Hierarchical traversal → Recursive CTE** — Replace level-by-level loops with `WITH RECURSIVE` CTE (Pattern 5)

### Anti-Patterns to Flag and Reject

- [ ] ❌ **Any `LOOP` containing `INSERT`, `UPDATE`, `DELETE`, or `MERGE`** — Almost always rewriteable as set-based SQL (Pattern 2)
- [ ] ❌ **Any `EXECUTE` (dynamic SQL) with static table/column names** — Use static SQL with parameters (Pattern 2G)
- [ ] ❌ **Any cursor used solely for data transformation** — Replace with `INSERT...SELECT` or window functions (Patterns 2, 3)
- [ ] ❌ **Any temp table populated row-by-row then read** — Replace with CTE or single query (Pattern 2C)
- [ ] ❌ **Any scalar function called per row that queries other tables** — Rewrite as JOIN (Pattern 4)

### Verification After Rewrite

- [ ] **Row count matches** — Verify the set-based result produces the same number of rows as the original loop
- [ ] **Data correctness** — Spot-check output values against original logic, especially edge cases (NULLs, empty groups, boundary rows)
- [ ] **No remaining cursors** — Search all migrated code for `CURSOR`, `FETCH`, `FOR rec IN` patterns
- [ ] **No remaining loop-DML** — Search for `LOOP` combined with `INSERT`, `UPDATE`, `DELETE` in the same block

---

## Decision Framework

When you encounter a pattern in source code, use this decision tree:

```
Is it a loop that processes rows?
├── YES → Does the loop body contain DML (INSERT/UPDATE/DELETE/MERGE)?
│         ├── YES → REWRITE to set-based SQL (Pattern 2)
│         └── NO → Does the loop carry state between iterations?
│                   ├── YES → REWRITE to window functions (Pattern 3)
│                   └── NO → Can the loop body be expressed as a single SQL?
│                             ├── YES → REWRITE to set-based SQL (Pattern 2)
│                             └── NO → Consider UDx (C++/Python) for complex logic
└── NO → Are there multiple adjacent single-row DML statements?
          ├── YES → COMBINE into bulk operations (Pattern 1)
          └── NO → Is there a per-row function call in SELECT?
                    ├── YES → REWRITE to JOIN (Pattern 4)
                    └── NO → Is it hierarchical/recursive traversal?
                              ├── YES → REWRITE to Recursive CTE (Pattern 5)
                              └── NO → Review for other anti-patterns
```

---

**Remember**: The goal is not to eliminate all PL/vSQL — stored procedures are valuable for orchestration, error handling, and transaction control. The goal is to **push data manipulation into set-based SQL** and reserve procedural logic for flow control that cannot be expressed declaratively.
