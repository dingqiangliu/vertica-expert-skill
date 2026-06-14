# User-Defined SQL Functions Guide - Summary

> **This is an agent-optimized summary of [user-defined-sql-functions-guide.md](../user-defined-sql-functions-guide.md).** This summary contains ALL information needed for SQL function development in Vertica. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **ALWAYS use RETURN type** (not RETURNS) | Syntax errors |
| 2 | **ALWAYS use AS BEGIN...END** for function body | Syntax errors |
| 3 | **NEVER use FROM, WHERE, GROUP BY, ORDER BY, LIMIT** in SQL functions | Syntax errors |
| 4 | **NEVER use loops or variable declarations** in SQL functions | Syntax errors |
| 5 | **NEVER use aggregate or analytic functions** in SQL functions | Syntax errors |
| 6 | **ALWAYS use PL/vSQL for complex logic** | Incorrect results |
| 7 | **ALWAYS handle NULL inputs** in your expression | Unexpected results |

#### Function Characteristics

**Volatility** (Vertica auto-infers):
| Type | Description | Example |
|------|-------------|---------|
| `IMMUTABLE` | Same inputs → same result | Mathematical functions |
| `STABLE` | Same within transaction | Functions using `CURRENT_DATE` |
| `VOLATILE` | May differ each call | Functions using `random()` |

**Strictness**:
- **Strict**: Returns NULL when any argument is NULL
- **Non-strict**: May handle NULL arguments differently

### Data Type Support

**Supported**: `INTEGER`, `BIGINT`, `SMALLINT`, `TINYINT`, `NUMERIC`, `DECIMAL`, `FLOAT`, `DOUBLE`, `VARCHAR`, `CHAR`, `LONG VARCHAR`, `DATE`, `TIME`, `TIMESTAMP`, `INTERVAL`, `BOOLEAN`

**NOT Supported**: `ARRAY`, `ROW`, `SET`, user-defined types, spatial types

### Common Pitfalls
- Forcing complex logic into SQL functions (use PL/vSQL instead)
- Not handling NULL inputs in expressions (causes unexpected results)
- Using functions in partition or segmentation clauses (not allowed)

---

## SQL Function Limitations

**Vertica SQL functions can only contain a SINGLE expression.**

- ❌ **Cannot contain**: SQL queries (`FROM`, `WHERE`, `GROUP BY`, etc.), loops, variable declarations, aggregates, multiple statements
- ✅ **Can contain**: Simple expressions, function calls, `CASE`, type conversions, string/math operations
- ❌ **Cannot be used in**: Table partition clauses, projection segmentation clauses

---

## SQL Function Syntax

### Basic Structure
```sql
CREATE [OR REPLACE] FUNCTION schema.function_name (
    param1 datatype,
    param2 datatype
)
RETURN datatype
AS BEGIN
    RETURN (expression);
END;
```

### Example: Simple Calculation
```sql
CREATE FUNCTION calculate_tax(amount NUMERIC, tax_rate NUMERIC)
RETURN NUMERIC
AS BEGIN
    RETURN (amount * tax_rate);
END;
```

### Example: String Manipulation
```sql
CREATE FUNCTION format_name(first_name VARCHAR, last_name VARCHAR)
RETURN VARCHAR
AS BEGIN
    RETURN (first_name || ' ' || last_name);
END;
```

### Example: CASE Expression
```sql
CREATE FUNCTION get_status_label(status_code INTEGER)
RETURN VARCHAR
AS BEGIN
    RETURN (CASE status_code
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'Pending'
        ELSE 'Unknown'
    END);
END;
```

---

## Usage Examples

```sql
-- In SELECT
SELECT order_id, calculate_tax(total_amount, 0.08) AS tax_amount FROM orders;

-- In WHERE
SELECT * FROM orders WHERE calculate_tax(total_amount, 0.08) > 100;

-- In GROUP BY
SELECT get_status_label(status), COUNT(*) FROM orders GROUP BY get_status_label(status);
```

---

## Function Overloading

**Create multiple versions with different parameter types:**

```sql
-- Version 1: INTEGER input
CREATE FUNCTION double_value(x INTEGER)
RETURN INTEGER
AS BEGIN
    RETURN (x * 2);
END;

-- Version 2: NUMERIC input
CREATE FUNCTION double_value(x NUMERIC)
RETURN NUMERIC
AS BEGIN
    RETURN (x * 2);
END;

-- Version 3: VARCHAR input (repeat string)
CREATE FUNCTION double_value(x VARCHAR)
RETURN VARCHAR
AS BEGIN
    RETURN (x || x);
END;
```

---

## Function Management

### Create Function

**Conditional Creation** (IF NOT EXISTS):
```sql
CREATE FUNCTION IF NOT EXISTS function_name(x INT) RETURN INT
AS BEGIN
    RETURN x + 1;
END;
```

### Modify Function
```sql
CREATE OR REPLACE FUNCTION schema.function_name (
    param datatype
)
RETURN datatype
AS BEGIN
    RETURN (expression);
END;
```

### Alter Function
```sql
-- Rename function
ALTER FUNCTION myzeroifnull(x INT) RENAME TO zerowhennull;

-- Move to different schema
ALTER FUNCTION zerowhennull(x INT) SET SCHEMA macros;
```

### Drop Function
```sql
-- Must specify argument types for overloaded functions
DROP FUNCTION IF EXISTS schema.function_name(datatype);

-- Drop from specific schema
DROP FUNCTION macros.zerowhennull(x_INT);
```

### List Functions
```sql
SELECT schema_name, function_name, function_argument_type
FROM user_functions
WHERE function_definition ILIKE 'return%';
```

### Check Function Details
```sql
-- Query system table
SELECT * FROM USER_FUNCTIONS WHERE function_name = 'my_function';

-- Using vsql meta-commands
\df function_name
\df+ function_name  -- Detailed information
```

**USER_FUNCTIONS Table Columns**:
| Column | Description |
|--------|-------------|
| `schema_name` | Schema containing the function |
| `function_name` | Name of the function |
| `function_return_type` | Data type returned |
| `function_argument_type` | Argument names and types |
| `function_definition` | SQL expression in function body |
| `volatility` | IMMUTABLE, STABLE, or VOLATILE |
| `is_strict` | Whether function returns NULL for NULL input |

### Privileges

| Operation | Required Privileges |
|-----------|--------------------|
| Create function | `CREATE` privilege on schema |
| Use function | `USAGE` on schema + `EXECUTE` on function |
| Alter/Drop function | Superuser or function owner |

```sql
-- Grant execute privileges
GRANT EXECUTE ON FUNCTION myzeroifnull(x INT) TO Fred;
GRANT EXECUTE ON FUNCTION calculate_tax(NUMERIC, NUMERIC) TO analyst_role;

-- Revoke execute privileges
REVOKE EXECUTE ON FUNCTION myzeroifnull(x INT) FROM Fred;
```

---

## Common Use Cases

```sql
-- Data Cleaning
CREATE FUNCTION clean_phone(phone VARCHAR) RETURN VARCHAR
AS BEGIN RETURN (REGEXP_REPLACE(phone, '[^0-9]', '')); END;

-- Business Logic
CREATE FUNCTION is_eligible_for_discount(total_purchases NUMERIC) RETURN BOOLEAN
AS BEGIN RETURN (total_purchases > 1000); END;

-- Date Utilities
CREATE FUNCTION get_quarter(d DATE) RETURN INTEGER
AS BEGIN RETURN (EXTRACT(MONTH FROM d) - 1) / 3 + 1); END;

-- Type Conversion
CREATE FUNCTION safe_to_integer(str VARCHAR) RETURN INTEGER
AS BEGIN RETURN (CASE WHEN str ~ '^[0-9]+$' THEN str::INTEGER ELSE 0 END); END;
```

---

## When to Use PL/vSQL Instead

**Use PL/vSQL stored procedures when:**
- Function needs multiple statements
- Function needs loops or complex logic
- Function needs to query other tables
- Function needs exception handling
- Function needs transaction control

**Example: PL/vSQL Function**
```sql
CREATE FUNCTION get_employee_count(p_dept_id INTEGER)
RETURN INTEGER
LANGUAGE plvsql AS
$$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE department_id = p_dept_id;
    RETURN v_count;
END;
$$;
```

## Integration with Database Objects

### Functions in Views
```sql
-- Function body is embedded in view definition
CREATE VIEW doubled_sales AS
SELECT product_id, double_value(sales_amount) as doubled_amount
FROM sales;

-- When function changes, view should be recreated
CREATE OR REPLACE VIEW doubled_sales AS
SELECT product_id, double_value(sales_amount) as doubled_amount
FROM sales;
```

### Functions in CHECK Constraints
```sql
CREATE TABLE products (
    product_id INT,
    price NUMERIC(10,2),
    discounted_price NUMERIC(10,2),
    CONSTRAINT valid_discount CHECK (
        discounted_price <= calculate_max_discount(price)
    )
);

CREATE FUNCTION calculate_max_discount(price NUMERIC)
RETURN NUMERIC(10,2)
AS BEGIN
    RETURN price * 0.8;  -- Maximum 20% discount
END;
```

---

## Performance & Best Practices

1. **Keep functions simple** — single expression, more likely to be inlined
2. **Match argument types to column types** — avoid unnecessary type conversions
3. **Use COALESCE for simple NULL handling** — instead of CASE WHEN
4. **Avoid VOLATILE functions in WHERE clauses** — prevents predicate pushdown
5. **Use meaningful names** — describe what the function does (e.g., `format_customer_phone`)
6. **Use overloading** — create multiple versions for different types
7. **Grant appropriate privileges** — ensure users have EXECUTE permission
8. **Use naming conventions** — prefix related functions (e.g., `calc_tax_federal`, `calc_tax_state`)

```sql
-- Test function performance
EXPLAIN SELECT myzeroifnull(large_column) FROM big_table;
EXPLAIN SELECT COALESCE(large_column, 0) FROM big_table;
```

---

## Migration Examples

### Oracle NVL / SQL Server ISNULL → Vertica
```sql
-- Use native COALESCE
SELECT COALESCE(value, default_val) FROM table_name;

-- Or create wrapper function
CREATE FUNCTION nvl_equivalent(value VARCHAR(100), default_val VARCHAR(100))
RETURN VARCHAR(100)
AS BEGIN RETURN COALESCE(value, default_val); END;
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Function Not Found | Argument types don't match | Check exact parameter types in USER_FUNCTIONS |
| Permission Denied | Missing EXECUTE privilege | `GRANT EXECUTE ON FUNCTION function_name(arg_types) TO user_name;` |
| Type Mismatch | No matching overload | Check function overloading or cast arguments |

```sql
-- Debug: Check function definition
SELECT function_definition FROM USER_FUNCTIONS WHERE function_name = 'problematic_function';

-- Debug: Verify function characteristics
SELECT volatility, is_strict FROM USER_FUNCTIONS WHERE function_name = 'my_function';

-- Debug: Test with simple cases
SELECT my_function(10);
SELECT my_function(NULL);
```

## When to Load Full Document

This summary contains ALL information needed for SQL function development in Vertica. The full document is for human reference with detailed examples.

**For complete examples and rationale, see [user-defined-sql-functions-guide.md](../user-defined-sql-functions-guide.md).**
