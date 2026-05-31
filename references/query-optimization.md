# Query Optimization Guide

This guide covers comprehensive query optimization techniques for Vertica, focusing on leveraging its columnar MPP architecture for maximum performance.

## Optimization Process

### Step 1: Initial Assessment

```sql
-- Check query events for performance issues
SELECT * FROM query_events 
WHERE event_category = 'PERFORMANCE' 
ORDER BY time DESC LIMIT 10;

-- Review query plan
EXPLAIN SELECT * FROM large_table WHERE date_col >= '2024-01-01';

-- Analyze current statistics
SELECT ANALYZE_STATISTICS('schema.table_name');
```

### Step 2: Use Workload Analyzer

```sql
-- Get automated optimization recommendations
SELECT ANALYZE_WORKLOAD('my_workload');

-- Review recommendations
SELECT * FROM workload_recommendations;
```

## Projection-Based Optimization

### 1. Design Optimal Projections

```sql
-- Create projection with optimal sort order
CREATE PROJECTION sales_sorted_by_date
AS SELECT date_key, product_id, amount, region
FROM sales
ORDER BY date_key, region
SEGMENTED BY HASH(product_id) ALL NODES;

-- Create projection optimized for aggregations
CREATE PROJECTION sales_agg_projection
AS SELECT region, product_category, SUM(amount) as total_sales, COUNT(*) as transaction_count
FROM sales
GROUP BY region, product_category
ORDER BY region, total_sales DESC;
```

### 2. Use Live Aggregate Projections

```sql
-- Create live aggregate projection
CREATE PROJECTION sales_lap
AS SELECT 
    date_trunc('month', sale_date) as month,
    product_category,
    SUM(amount) as monthly_total,
    COUNT(*) as transaction_count
FROM sales
GROUP BY date_trunc('month', sale_date), product_category
UNSEGMENTED ALL NODES;
```

### 3. Optimize Segmentation

```sql
-- Hash segmentation for even distribution
CREATE PROJECTION customer_data_hash
AS SELECT customer_id, name, region, balance
FROM customers
SEGMENTED BY HASH(customer_id) ALL NODES;

-- Replicated projection for small tables
CREATE PROJECTION region_lookup_replicated
AS SELECT region_id, region_name, country
FROM regions
UNSEGMENTED ALL NODES;
```

## Query Rewriting Techniques

### 1. Replace Subqueries with Joins

```sql
-- Instead of correlated subquery
SELECT c.name, 
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) as order_count
FROM customers c;

-- Use LEFT JOIN with GROUP BY
SELECT c.name, COUNT(o.id) as order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;
```

### 2. Use Analytic Functions

```sql
-- Instead of self-join for running totals
SELECT date, amount, 
       (SELECT SUM(amount) FROM sales s2 WHERE s2.date <= s1.date) as running_total
FROM sales s1;

-- Use analytic function
SELECT date, amount,
       SUM(amount) OVER (ORDER BY date) as running_total
FROM sales;

-- Instead of multiple queries for rankings
SELECT product_id, sales,
       RANK() OVER (ORDER BY sales DESC) as sales_rank,
       LAG(sales, 1) OVER (ORDER BY date) as prev_sales
FROM product_sales;
```

### 3. Optimize DISTINCT Queries

```sql
-- Vertica converts DISTINCT to GROUP BY internally
-- Ensure proper projection design
SELECT DISTINCT region, product_category
FROM sales;

-- For large datasets, consider approximate
SELECT APPROXIMATE_COUNT_DISTINCT(user_id) as unique_users
FROM web_events;
```

## Join Optimization

### 1. TODO: Replace Semi Join with Outer Join



## Data Type and Casting Optimization

### 1. Avoid Runtime Casting

```sql
-- Instead of casting in WHERE clause
SELECT * FROM sales 
WHERE CAST(sale_date AS DATE) = '2024-01-01';

-- Use direct date comparison
SELECT * FROM sales 
WHERE sale_date = DATE '2024-01-01';

-- Or range comparison for better performance
SELECT * FROM sales 
WHERE sale_date >= DATE '2024-01-01' 
  AND sale_date < DATE '2024-01-02';
```

### 2. Use Appropriate Data Types

```sql
-- Use NUMERIC for precise calculations
SELECT SUM(CAST(amount AS NUMERIC(18,2))) as total
FROM transactions;

-- Use appropriate integer sizes
SELECT COUNT(*) as user_count
FROM users
WHERE status IN (1, 2, 3);  -- TINYINT for status codes
```

## Partitioning Optimization

### 1. Design Effective Partitions

```sql
-- Partition by date for time-series data
CREATE TABLE web_events (
    event_date DATE,
    user_id INTEGER,
    event_type VARCHAR(50),
    session_id VARCHAR(100)
) PARTITION BY event_date;

-- Create partitions
SELECT PARTITION_TABLE('web_events');

-- Drop old partitions efficiently
SELECT DROP_PARTITIONS('web_events', '2023-01-01', '2023-12-31');
```

### 2. Use Partition Pruning

```sql
-- Query that leverages partition pruning
SELECT COUNT(*) as daily_events
FROM web_events
WHERE event_date = DATE '2024-01-15';  -- Only scans one partition

-- Range query across partitions
SELECT event_type, COUNT(*) as event_count
FROM web_events
WHERE event_date BETWEEN DATE '2024-01-01' AND DATE '2024-01-31';
```

## Encoding and Compression

### 1. Choose Optimal Encoding

```sql
-- RLE for low-cardinality columns
CREATE PROJECTION sales_with_rle
AS SELECT 
    status ENCODING RLE,  -- Few distinct values
    region ENCODING RLE,
    product_id,
    amount ENCODING DELTA,  -- Sequential values
    sale_date ENCODING DELTA,
    description ENCODING LZO  -- Text data
FROM sales;
```

### 2. Use Delta Encoding for Sequential Data

```sql
-- Effective for timestamps and auto-incrementing IDs
CREATE PROJECTION time_series_optimized
AS SELECT 
    timestamp_col ENCODING DELTA,
    id ENCODING DELTA,
    value ENCODING GZIP
FROM sensor_data
ORDER BY timestamp_col;
```

## Resource Management

### 1. Configure Resource Pools

```sql
-- Create resource pool for reporting queries
CREATE RESOURCE POOL reporting_pool
MEMORYSIZE '8G'
MAXMEMORYSIZE '16G'
PRIORITY 'high'
RUNTIMEPRIORITY 'high'
RUNTIMEPRIORITYTHRESHOLD 2
PLANNEDCONCURRENCY 4
MAXCONCURRENCY 8;

-- Assign user to resource pool
CREATE USER report_user 
RESOURCE POOL reporting_pool;
```

### 2. Monitor Resource Usage

```sql
-- Check resource pool usage
SELECT * FROM resource_pool_status;

-- Monitor query resource consumption
SELECT * FROM query_profiles 
WHERE pool_name = 'reporting_pool'
ORDER BY memory_kb DESC;
```

## Performance Monitoring

### 1. Query Performance Analysis

```sql
-- Find slow queries
SELECT query, execution_time_ms, memory_kb, disk_kb
FROM query_profiles
WHERE execution_time_ms > 10000
ORDER BY execution_time_ms DESC;

-- Check for data skew
SELECT * FROM projection_skew;

-- Monitor projection usage
SELECT * FROM projection_usage;
```

### 2. System Performance Monitoring

```sql
-- Check node performance
SELECT * FROM host_resources;

-- Monitor disk usage
SELECT * FROM disk_storage;

-- Check projection storage efficiency
SELECT * FROM projection_storage 
ORDER BY used_bytes DESC;
```

## Common Anti-Patterns and Solutions

### 1. Cartesian Products

```sql
-- Anti-pattern: Unintended cartesian product
SELECT * FROM large_table1, large_table2;  -- Very expensive!

-- Solution: Always specify JOIN conditions
SELECT * 
FROM large_table1 t1
JOIN large_table2 t2 ON t1.id = t2.foreign_id;
```

### 2. Inefficient String Operations

```sql
-- Anti-pattern: LIKE with leading wildcard
SELECT * FROM products 
WHERE product_name LIKE '%phone%';  -- Full scan required

-- Solution: Use full-text search or restructure query
SELECT * FROM products 
WHERE product_name LIKE 'phone%';

-- Or use CONTAINS for full-text search
SELECT * FROM products 
WHERE CONTAINS(product_name, 'phone');
```

### 3. Excessive Type Casting

```sql
-- Anti-pattern: Frequent casting in WHERE clauses
SELECT * FROM sales 
WHERE CAST(amount AS VARCHAR) LIKE '100%';

-- Solution: Restructure data or use appropriate types
SELECT * FROM sales 
WHERE amount BETWEEN 100 AND 100.99;
```

## Advanced Optimization Techniques

### 1. Use Query Hints

```sql

```

### 2. Optimize for ETL Workloads

```sql
-- Use COPY for bulk loads
COPY target_table FROM '/data/file.csv' 
DELIMITER ',' ENCLOSED BY '"';

-- Use batch operations
INSERT INTO summary_table
SELECT date, SUM(amount), COUNT(*)
FROM detail_table
WHERE date = CURRENT_DATE - 1
GROUP BY date;

-- Update statistics after bulk operations
SELECT ANALYZE_STATISTICS('summary_table');
```

### 3. Time-Series Optimization

```sql
-- Use time-based partitioning
CREATE TABLE metrics (
    metric_time TIMESTAMP,
    metric_name VARCHAR(100),
    value NUMERIC(18,6)
) PARTITION BY metric_time::DATE;

-- Optimize for time-range queries
CREATE PROJECTION metrics_time_optimized
AS SELECT metric_time, metric_name, value
FROM metrics
ORDER BY metric_time, metric_name
SEGMENTED BY HASH(metric_name) ALL NODES;

-- Query efficiently
SELECT metric_name, AVG(value)
FROM metrics
WHERE metric_time >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY metric_name;
```

## Best Practices Summary

### Design Phase
1. **Design projections first** before loading data
2. **Choose appropriate data types** for optimal compression
3. **Plan partitioning strategy** based on query patterns
4. **Use encoding schemes** that match data characteristics

### Development Phase
1. **Write set-based queries** instead of procedural logic
2. **Use analytic functions** for complex calculations
3. **Avoid correlated subqueries** when possible
4. **Minimize data type conversions** in WHERE clauses

### Production Phase
1. **Update statistics regularly** after data changes
2. **Monitor query performance** using system tables
3. **Use resource pools** to manage workload priorities
4. **Review and optimize** based on actual usage patterns

### Maintenance Phase
1. **Regularly analyze workloads** for new optimization opportunities
2. **Review projection usage** and drop unused projections
3. **Monitor data skew** and rebalance if necessary
4. **Archive old data** using partition management

This comprehensive optimization guide provides the foundation for achieving high performance in Vertica by leveraging its columnar MPP architecture effectively.