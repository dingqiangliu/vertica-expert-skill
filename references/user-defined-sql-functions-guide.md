# User-Defined SQL Functions Guide

This comprehensive guide covers User-Defined SQL Functions  in Vertica - the simplest way to extend Vertica's functionality with custom SQL expressions.

## Overview

User-Defined SQL Functions allow you to define and store commonly-used SQL expressions as reusable functions. They are ideal for:

- **Simple transformations**: Data cleaning and standardization
- **Business logic**: Encapsulating frequently used calculations
- **Code reuse**: Avoiding repetitive SQL expressions
- **Performance**: Functions are flattened and optimized by the query planner

### When to Use User-Defined SQL Functions

✅ **Perfect for:**
- Simple SQL expressions and calculations
- Data transformation and cleaning
- Business rule encapsulation
- Functions that can be expressed in a single RETURN statement

❌ **Not suitable for:**
- Complex procedural logic requiring loops or conditionals
- Functions needing FROM, WHERE, GROUP BY clauses
- Aggregate or analytic functions
- Complex data types (ARRAY, ROW, SET)

## Quick Start

### Basic Example

```sql
-- Create a simple function to handle NULL values
CREATE FUNCTION myzeroifnull(x INT) RETURN INT
   AS BEGIN
     RETURN (CASE WHEN (x IS NOT NULL) THEN x ELSE 0 END);
   END;

-- Use the function
SELECT myzeroifnull(column_name) FROM table_name;
```

### Function Creation Syntax

```sql
CREATE [ OR REPLACE ] FUNCTION [ IF NOT EXISTS ]
    [[database.]schema.]function_name( [ argname argtype[,...] ] )
    RETURN return_type
    AS
    BEGIN
       RETURN expression;
    END;
```

## Complete Syntax Reference

### CREATE FUNCTION Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `OR REPLACE` | Replace existing function with same name and arguments | Optional |
| `IF NOT EXISTS` | Create only if function doesn't exist | Optional |
| `database.schema` | Database and schema specification | Optional |
| `function_name` | Name following Vertica identifier conventions | Required |
| `argname argtype` | Comma-delimited list of argument names and types | Optional |
| `return_type` | Data type that the function returns | Required |
| `expression` | SQL function body with built-in functions and operators | Required |

### Data Type Support

**Supported Types:**
- INTEGER, BIGINT, SMALLINT, TINYINT
- NUMERIC, DECIMAL, FLOAT, DOUBLE
- VARCHAR, CHAR, LONG VARCHAR
- DATE, TIME, TIMESTAMP, INTERVAL
- BOOLEAN

**NOT Supported:**
- Complex types (ARRAY, ROW, SET)
- User-defined types
- Spatial types

## Function Characteristics

### Volatility Inference

Vertica automatically determines function volatility:

| Volatility | Description | Example |
|------------|-------------|----------|
| **IMMUTABLE** | Always returns same result for same inputs | Mathematical functions |
| **STABLE** | Returns same result within a transaction | Functions using CURRENT_DATE |
| **VOLATILE** | May return different results each call | Functions using random() |

### Strictness

- **Strict functions**: Return NULL when any argument is NULL
- **Non-strict functions**: May handle NULL arguments differently
- Vertica infers strictness from the function body

## Practical Examples

### 1. Data Cleaning Functions

#### NULL Handling

```sql
-- Replace NULL with default value
CREATE FUNCTION null_to_default(value VARCHAR(100), default_val VARCHAR(100))
    RETURN VARCHAR(100)
    AS BEGIN
      RETURN COALESCE(value, default_val);
    END;

-- Usage
SELECT null_to_default(email, 'no-email@example.com') FROM customers;
```

#### String Standardization

```sql
-- Standardize phone number format
CREATE FUNCTION format_phone(phone VARCHAR(20))
    RETURN VARCHAR(14)
    AS BEGIN
      RETURN '(' || SUBSTR(phone, 1, 3) || ') ' ||
             SUBSTR(phone, 4, 3) || '-' || SUBSTR(phone, 7);
    END;

-- Usage
SELECT customer_name, format_phone(phone) FROM customers;
```

### 2. Business Logic Functions

#### Customer Tier Classification

```sql
-- Determine customer tier based on spending
CREATE FUNCTION get_customer_tier(total_spent NUMERIC)
    RETURN VARCHAR(20)
    AS BEGIN
      RETURN CASE
        WHEN total_spent >= 10000 THEN 'Premium'
        WHEN total_spent >= 5000 THEN 'Gold'
        WHEN total_spent >= 1000 THEN 'Silver'
        ELSE 'Standard'
      END;
    END;

-- Usage in customer analysis
SELECT customer_id,
       total_spent,
       get_customer_tier(total_spent) as tier
FROM customer_summary;
```

#### Tax Calculation

```sql
-- Calculate tax amount
CREATE FUNCTION calculate_tax(amount NUMERIC, rate NUMERIC)
    RETURN NUMERIC(10,2)
    AS BEGIN
      RETURN ROUND(amount * rate / 100, 2);
    END;

-- Usage
SELECT product_name,
       price,
       calculate_tax(price, 8.5) as tax_amount
FROM products;
```

### 3. Mathematical Functions

#### Safe Division

```sql
-- Division with zero handling
CREATE FUNCTION safe_divide(numerator NUMERIC, denominator NUMERIC)
    RETURN NUMERIC(15,6)
    AS BEGIN
      RETURN CASE
        WHEN denominator = 0 THEN 0
        ELSE numerator / denominator
      END;
    END;

-- Usage
SELECT product_id,
       safe_divide(revenue, units_sold) as revenue_per_unit
FROM sales;
```

#### Percentage Calculation

```sql
-- Calculate percentage with rounding
CREATE FUNCTION calculate_percentage(
    numerator NUMERIC,
    denominator NUMERIC,
    decimals INT
)
    RETURN NUMERIC(10,2)
    AS BEGIN
      RETURN CASE
        WHEN denominator = 0 THEN 0
        ELSE ROUND((numerator / denominator) * 100, decimals)
      END;
    END;

-- Use function overloading for default parameter behavior
CREATE FUNCTION calculate_percentage(
    numerator NUMERIC,
    denominator NUMERIC
)
    RETURN NUMERIC(10,2)
    AS BEGIN
      RETURN calculate_percentage(numerator, denominator, 2);
    END;

-- Usage
SELECT product_name,
       calculate_percentage(sales, total_sales) as sales_percentage
FROM product_sales;
```

### 4. Date and Time Functions

#### Date Formatting

```sql
-- Standard date format
CREATE FUNCTION format_date_std(input_date DATE)
    RETURN VARCHAR(10)
    AS BEGIN
      RETURN TO_CHAR(input_date, 'YYYY-MM-DD');
    END;

-- Usage
SELECT order_id,
       format_date_std(order_date) as formatted_date
FROM orders;
```

#### Age Calculation

```sql
-- Calculate age in years
CREATE FUNCTION calculate_age(birth_date DATE)
    RETURN INT
    AS BEGIN
      RETURN DATEDIFF('year', birth_date, CURRENT_DATE);
    END;

-- Usage
SELECT name,
       birth_date,
       calculate_age(birth_date) as age
FROM employees;
```

## Function Management

### Creating and Modifying Functions

#### Basic Creation

```sql
-- Simple function creation
CREATE FUNCTION double_value(x INT) RETURN INT
   AS BEGIN
     RETURN x * 2;
   END;
```

#### Replace Existing Function

```sql
-- Replace function with new implementation
CREATE OR REPLACE FUNCTION double_value(x INT) RETURN INT
   AS BEGIN
     RETURN x * 3;  -- Changed from 2 to 3
   END;
```

#### Conditional Creation

```sql
-- Create only if doesn't exist
CREATE FUNCTION IF NOT EXISTS utility_function(x INT) RETURN INT
   AS BEGIN
     RETURN x + 1;
   END;
```

### Function Overloading

Create multiple versions for different data types:

```sql
-- Integer version
CREATE FUNCTION myzeroifnull(x INT) RETURN INT
   AS BEGIN
     RETURN COALESCE(x, 0);
   END;

-- Numeric version
CREATE FUNCTION myzeroifnull(x NUMERIC) RETURN NUMERIC
   AS BEGIN
     RETURN COALESCE(x, 0);
   END;

-- Both coexist and are called based on argument type
SELECT myzeroifnull(10),      -- Uses INT version
       myzeroifnull(10.5);     -- Uses NUMERIC version
```

### Altering Functions

```sql
-- Rename function
ALTER FUNCTION myzeroifnull(x INT) RENAME TO zerowhennull;

-- Move to different schema
ALTER FUNCTION zerowhennull(x INT) SET SCHEMA macros;
```

### Dropping Functions

```sql
-- Must specify argument types for overloaded functions
DROP FUNCTION zerowhennull(x INT);

-- Drop from specific schema
DROP FUNCTION macros.zerowhennull(x INT);
```

## Privileges and Access Control

### Required Privileges

| Operation | Required Privileges |
|-----------|--------------------|
| Create function | CREATE privilege on schema |
| Use function | USAGE on schema + EXECUTE on function |
| Alter/Drop function | Superuser or function owner |

### Granting and Revoking Access

```sql
-- Grant execute privileges
GRANT EXECUTE ON FUNCTION myzeroifnull(x INT) TO Fred;
GRANT EXECUTE ON FUNCTION calculate_tax(NUMERIC, NUMERIC) TO analyst_role;

-- Revoke execute privileges
REVOKE EXECUTE ON FUNCTION myzeroifnull(x INT) FROM Fred;
```

## Function Information and Monitoring

### Viewing Function Details

```sql
-- Query system table for function information
SELECT * FROM USER_FUNCTIONS;

-- Check specific function
SELECT * FROM USER_FUNCTIONS WHERE function_name = 'myzeroifnull';

-- Using vsql meta-commands
\df function_name
\df+ function_name  -- Detailed information
```

### Function Information Columns

| Column | Description |
|--------|-------------|
| `schema_name` | Schema containing the function |
| `function_name` | Name of the function |
| `function_return_type` | Data type returned by function |
| `function_argument_type` | Argument names and types |
| `function_definition` | SQL expression in function body |
| `volatility` | IMMUTABLE, STABLE, or VOLATILE |
| `is_strict` | Whether function is strict (returns NULL for NULL input) |

## Integration with Database Objects

### Using Functions in Views

```sql
-- Create function
CREATE FUNCTION double_value(x INT) RETURN INT
   AS BEGIN
     RETURN x * 2;
   END;

-- Create view using the function
CREATE VIEW doubled_sales AS
SELECT product_id, double_value(sales_amount) as doubled_amount
FROM sales;

-- Function body is embedded in view definition
-- When function changes, view should be recreated
CREATE OR REPLACE VIEW doubled_sales AS
SELECT product_id, double_value(sales_amount) as doubled_amount
FROM sales;
```

### Functions in Constraints

```sql
-- Function in CHECK constraint
CREATE TABLE products (
    product_id INT,
    price NUMERIC(10,2),
    discounted_price NUMERIC(10,2),
    CONSTRAINT valid_discount CHECK (
        discounted_price <= calculate_max_discount(price)
    )
);

-- Supporting function
CREATE FUNCTION calculate_max_discount(price NUMERIC)
    RETURN NUMERIC(10,2)
    AS BEGIN
      RETURN price * 0.8;  -- Maximum 20% discount
    END;
```

## Performance Considerations

### Optimization Guidelines

1. **Keep Functions Simple**
   - Simple functions are more likely to be inlined
   - Complex logic may prevent query optimization

2. **Use Appropriate Data Types**
   - Match argument types to column types when possible
   - Avoid unnecessary type conversions

3. **Handle NULLs Efficiently**
   - Use COALESCE instead of CASE WHEN for simple NULL handling
   - Consider strict vs non-strict behavior

4. **Avoid Volatile Functions in WHERE Clauses**
   - Volatile functions may prevent predicate pushdown
   - Use STABLE or IMMUTABLE functions when possible

### Performance Testing

```sql
-- Test function performance
EXPLAIN SELECT myzeroifnull(large_column) FROM big_table;

-- Compare with inline expression
EXPLAIN SELECT COALESCE(large_column, 0) FROM big_table;

-- Monitor function usage
SELECT * FROM user_defined_functions_usage;
```

## Limitations and Restrictions

### SQL Clause Restrictions

❌ **NOT Allowed in Function Body:**
- FROM clause
- WHERE clause
- GROUP BY clause
- ORDER BY clause
- LIMIT clause
- Aggregation functions (SUM, COUNT, AVG, etc.)
- Analytic functions (ROW_NUMBER, LAG, LEAD, etc.)
- Meta-functions

### Usage Restrictions

❌ **Cannot be used in:**
- Table partition clauses
- Projection segmentation clauses
- Certain system contexts

### Data Type Limitations

❌ **Complex types NOT supported:**
- ARRAY types
- ROW types
- SET types
- User-defined types
- Spatial types

## Best Practices

### 1. Naming Conventions

```sql
-- Use descriptive names
CREATE FUNCTION format_customer_phone(phone VARCHAR(20))
    RETURN VARCHAR(14)
    AS BEGIN
      -- Implementation
    END;

-- Prefix for related functions
CREATE FUNCTION calc_tax_federal(amount NUMERIC) RETURN NUMERIC(10,2);
CREATE FUNCTION calc_tax_state(amount NUMERIC) RETURN NUMERIC(10,2);
CREATE FUNCTION calc_tax_total(amount NUMERIC) RETURN NUMERIC(10,2);
```

### 2. Error Handling

```sql
-- Handle division by zero
CREATE FUNCTION safe_division(a NUMERIC, b NUMERIC)
    RETURN NUMERIC(15,6)
    AS BEGIN
      RETURN CASE
        WHEN b = 0 THEN NULL  -- or 0, depending on requirements
        ELSE a / b
      END;
    END;

-- Handle NULL inputs explicitly
CREATE FUNCTION process_value(value VARCHAR(100))
    RETURN VARCHAR(100)
    AS BEGIN
      RETURN CASE
        WHEN value IS NULL THEN 'N/A'
        WHEN TRIM(value) = '' THEN 'EMPTY'
        ELSE UPPER(TRIM(value))
      END;
    END;
```

### 3. Documentation

```sql
-- Add comments for complex logic
CREATE FUNCTION complex_calculation(x NUMERIC, y NUMERIC, z NUMERIC)
    RETURN NUMERIC(15,6)
    AS BEGIN
      -- This function calculates weighted average with outlier adjustment
      -- Formula: (x * 0.5 + y * 0.3 + z * 0.2) * adjustment_factor
      RETURN (x * 0.5 + y * 0.3 + z * 0.2) * 1.1;
    END;
```

### 4. Testing Strategy

```sql
-- Test basic functionality
SELECT myzeroifnull(10);     -- Expected: 10
SELECT myzeroifnull(NULL);   -- Expected: 0
SELECT myzeroifnull(0);      -- Expected: 0

-- Test with table data
SELECT col1, myzeroifnull(col1) FROM test_table;

-- Test in different contexts
SELECT COUNT(*) FROM test_table GROUP BY myzeroifnull(col1);
SELECT * FROM test_table WHERE myzeroifnull(col1) > 5;

-- Test edge cases
SELECT myzeroifnull('');     -- Empty string handling
```

## Migration Examples

### From Oracle NVL

```sql
-- Oracle: NVL function
-- CREATE FUNCTION nvl_example(value VARCHAR2, default_val VARCHAR2)

-- Vertica equivalent using native COALESCE
SELECT COALESCE(value, default_val) FROM table_name;

-- Or create wrapper function
CREATE FUNCTION nvl_equivalent(value VARCHAR(100), default_val VARCHAR(100))
    RETURN VARCHAR(100)
    AS BEGIN
      RETURN COALESCE(value, default_val);
    END;
```

### From SQL Server ISNULL

```sql
-- SQL Server: ISNULL function
-- ISNULL(column_name, 'default')

-- Vertica equivalent
CREATE FUNCTION isnull_equivalent(value VARCHAR(100), default_val VARCHAR(100))
    RETURN VARCHAR(100)
    AS BEGIN
      RETURN COALESCE(value, default_val);
    END;
```

## Troubleshooting

### Common Issues

1. **Function Not Found**
   ```sql
   -- Error: Function does not exist
   -- Solution: Check argument types match exactly
   SELECT * FROM USER_FUNCTIONS WHERE function_name = 'my_function';
   ```

2. **Permission Denied**
   ```sql
   -- Error: Permission denied
   -- Solution: Grant EXECUTE privilege
   GRANT EXECUTE ON FUNCTION function_name(arg_types) TO user_name;
   ```

3. **Type Mismatch**
   ```sql
   -- Error: No function matches the given name and argument types
   -- Solution: Check function overloading or cast arguments
   SELECT function_name(CAST(value AS expected_type));
   ```

### Debugging Tips

1. **Check Function Definition**
   ```sql
   SELECT function_definition FROM USER_FUNCTIONS
   WHERE function_name = 'problematic_function';
   ```

2. **Verify Function Characteristics**
   ```sql
   SELECT volatility, is_strict FROM USER_FUNCTIONS
   WHERE function_name = 'my_function';
   ```

3. **Test with Simple Cases**
   ```sql
   -- Test with literal values
   SELECT my_function(10);
   SELECT my_function(NULL);
   ```

This comprehensive guide provides everything needed to effectively create, manage, and optimize User-Defined SQL Functions in Vertica for extending database functionality with simple, reusable SQL expressions.