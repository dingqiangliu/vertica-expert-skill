# OLTP to OLAP Rewrite Guide - Summary

> **This is an agent-optimized summary of [oltp-to-olap-rewrite-guide.md](../oltp-to-olap-rewrite-guide.md).** This summary contains ALL information needed for OLTP-to-OLAP rewrite decisions. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **NEVER use DML inside loops** — always rewrite to set-based SQL | Severe performance degradation |
| 2 | **NEVER use cursors for data transformation** — use window functions | Severe performance degradation |
| 3 | **NEVER use temp tables populated row-by-row** — use CTEs | Severe performance degradation |
| 4 | **NEVER use per-row function calls in SELECT** — use JOINs | Severe performance degradation |
| 5 | **ALWAYS use MERGE for UPSERT patterns** | Data integrity issues |
| 6 | **ALWAYS use Recursive CTE for hierarchical queries** | Incorrect results |
| 7 | **ALWAYS combine adjacent single-row DML into bulk operations** | Performance degradation |


---

## Pattern 1: Adjacent Single-Row DML → Bulk Operation

### Multiple Single-Row INSERTs → Multi-Row INSERT
```sql
-- Anti-Pattern
INSERT INTO sales_summary (region, total_sales) VALUES ('East', 15000);
INSERT INTO sales_summary (region, total_sales) VALUES ('West', 23000);

-- Optimized
INSERT INTO sales_summary (region, total_sales) VALUES
    ('East', 15000),
    ('West', 23000);
```

### Multiple Single-Row UPDATEs → Set-Based UPDATE
```sql
-- Anti-Pattern
UPDATE products SET price = price * 1.10 WHERE product_id = 101;
UPDATE products SET price = price * 1.10 WHERE product_id = 102;

-- Optimized: CASE-based UPDATE
UPDATE products
SET price = price * CASE product_id
    WHEN 101 THEN 1.10
    WHEN 102 THEN 1.10
END
WHERE product_id IN (101, 102);

-- Alternative: UPDATE...FROM (when values come from another table)
UPDATE products p
SET price = p.price * r.adjustment_factor
FROM price_adjustments r
WHERE p.product_id = r.product_id;
```

---

## Pattern 2: Loop DML → Set-Based SQL

### Loop INSERT → INSERT...SELECT
```sql
-- Anti-Pattern
FOR i IN 1..100 LOOP
    INSERT INTO category_stats (category_id, order_count)
    SELECT i, COUNT(*) FROM orders WHERE category_id = i;
END LOOP;

-- Optimized
INSERT INTO category_stats (category_id, order_count)
SELECT category_id, COUNT(*) FROM orders GROUP BY category_id;
```

### Loop DELETE → Set-Based DELETE or DROP_PARTITIONS
```sql
-- Anti-Pattern
FOR rec IN SELECT customer_id FROM customers_to_purge LOOP
    DELETE FROM orders WHERE customer_id = rec.customer_id;
END LOOP;

-- Optimized: Set-based DELETE
DELETE FROM orders
WHERE customer_id IN (SELECT customer_id FROM customers_to_purge);

-- Alternative: DELETE with EXISTS
DELETE FROM orders
WHERE EXISTS (SELECT 1 FROM customers_to_purge p WHERE p.customer_id = orders.customer_id);

-- Best for time-series partitioned tables: DROP_PARTITIONS (metadata operation, near-instant)
SELECT DROP_PARTITIONS('web_events', '2022-01-01', '2022-12-31');
```

### Row-by-Row UPSERT → MERGE
```sql
-- Anti-Pattern
FOR rec IN SELECT key, value FROM staging_table LOOP
    UPDATE target_table SET value = rec.value WHERE key = rec.key;
    IF NOT FOUND THEN
        INSERT INTO target_table (key, value) VALUES (rec.key, rec.value);
    END IF;
END LOOP;

-- Optimized
MERGE INTO target_table t
USING staging_table s ON t.key = s.key
WHEN MATCHED THEN UPDATE SET value = s.value
WHEN NOT MATCHED THEN INSERT (key, value) VALUES (s.key, s.value);
```

### Row-by-Row Aggregation → GROUP BY
```sql
-- Anti-Pattern: PL/vSQL loop accumulating sums/counts grouped by key
-- Optimized
INSERT INTO region_totals
SELECT region, SUM(amount), COUNT(*)
FROM sales
GROUP BY region;
```

### Dynamic SQL in Loop for Static Objects → Static SQL
```sql
-- Anti-Pattern: Unnecessary dynamic SQL
FOR i IN RANGE 1..100 LOOP
    PERFORM EXECUTE 'INSERT INTO partition_' || i || ' SELECT * FROM source WHERE partition_key = ' || i;
END LOOP;

-- Optimized: Static SQL with set-based routing
INSERT INTO target_table
SELECT *, partition_key
FROM source
WHERE partition_key BETWEEN 1 AND 100;
```

### Temp Table + Loop → CTE
```sql
-- Anti-Pattern
CREATE TEMP TABLE tmp_status AS SELECT status FROM transactions WHERE 1=0;
FOR rec IN SELECT DISTINCT status FROM transactions LOOP
    INSERT INTO tmp_status VALUES (rec.status);
END LOOP;

-- Optimized
WITH tmp_status AS (
    SELECT DISTINCT status FROM transactions
)
SELECT * FROM tmp_status;
```

### ⚠️ Loop Iteration Patterns (Critical for Agent)

| Loop Variant | Replacement |
|---|---|
| Date range (`FOR d IN QUERY SELECT generate_series(...)`) | Subquery-wrapped `generate_series` + `LEFT JOIN` |
| Integer counter (`FOR i IN RANGE 1..N`) | Subquery-wrapped `generate_series` + `LEFT JOIN` |
| Discrete values (`FOR v IN (SELECT ...)`) | Subquery-wrapped `unnest(ARRAY[...])` + `LEFT JOIN` |

**UDTF Constraints**:
- `generate_series`/`unnest` are transform functions — **must be used in JOIN**, not standalone in `FROM`
- UDTFs must appear on **right side** of join; only **INNER/LEFT** joins supported — `RIGHT JOIN` **not supported**
- To **preserve all UDTF rows**, wrap UDTF in subquery on **left side** of `LEFT JOIN`

---

## Pattern 3: Cursor with State → Window Functions

**⚠️ CTE Layers ≠ Loop Iterations**: Whether 1 flat SELECT or 5 nested CTEs, execution is always a **single parallel scan**. Window functions are the core replacement mechanism, not CTEs.

| Cursor Pattern | Window Function Replacement |
|---|---|
| Running total | `SUM(col) OVER (ORDER BY ...)` |
| Row counter | `ROW_NUMBER() OVER (ORDER BY ...)` |
| Previous row value | `LAG(col, 1) OVER (ORDER BY ...)` |
| Next row value | `LEAD(col, 1) OVER (ORDER BY ...)` |
| Rank within group | `RANK() OVER (PARTITION BY ... ORDER BY ...)` |
| Percentage of total | `col / SUM(col) OVER ()` |
| Moving average | `AVG(col) OVER (ORDER BY ... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` |
| Group sequence | `ROW_NUMBER() OVER (PARTITION BY group_key ORDER BY ...)` |

For complex multi-step calculations with multiple state variables, use **Flat SELECT** (recommended) or **Nested CTEs** (for complex inter-column dependencies, but layers ≠ iterations)

---

## Pattern 4: Per-Row Function Call → JOIN

```sql
-- Anti-Pattern
SELECT order_id, order_date,
       calculate_discount(customer_id, total_amount) AS discount
FROM orders;

-- Optimized
SELECT o.order_id, o.order_date,
       COALESCE(d.discount_rate, 0) * o.total_amount AS discount
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN discount_rules d ON d.customer_tier = c.tier
                          AND o.total_amount >= d.min_amount;
```

---

## Pattern 5: Recursive Traversal → Recursive CTE

```sql
-- Anti-Pattern
-- Iterative level-by-level hierarchy traversal

-- Optimized
WITH RECURSIVE org_tree AS (
    -- Anchor: top-level employees
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: direct reports
    SELECT e.employee_id, e.name, e.manager_id, ot.level + 1
    FROM employees e
    JOIN org_tree ot ON e.manager_id = ot.employee_id
)
SELECT * FROM org_tree ORDER BY level, name;
```

---

## Verification After Rewrite

- [ ] **Row count matches** — Verify set-based result produces same row count as original loop
- [ ] **Data correctness** — Spot-check output values (NULLs, empty groups, boundary rows)
- [ ] **No remaining cursors** — Search for `CURSOR`, `FETCH`, `FOR rec IN` patterns
- [ ] **No remaining loop-DML** — Search for `LOOP` combined with DML in same block

---

**For complete examples and rationale, see [oltp-to-olap-rewrite-guide.md](../oltp-to-olap-rewrite-guide.md).**
