# Stored Procedures Guide - Summary

> **This is an agent-optimized summary of [stored-procedures-guide.md](../stored-procedures-guide.md).** This summary contains ALL information needed for stored procedure development in Vertica. The full document is for human reference with detailed examples.

---

## Critical Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **ALWAYS use `$$` delimiters** for procedure body | Syntax errors |
| 2 | **ALWAYS declare all variables** in DECLARE block | Runtime errors |
| 3 | **ALWAYS use PERFORM** to discard output for DDL, DML, CALL, COMMIT, ROLLBACK, EXECUTE | Syntax errors |
| 4 | **NEVER use COMMIT inside loops** | Performance degradation |
| 5 | **ALWAYS use error handling**: `GET STACKED DIAGNOSTICS` for details, `SQLSTATE`/`SQLERRM` for basic info, `RAISE EXCEPTION` with format strings | Incomplete error handling |
| 6 | **ALWAYS use FOUND** to check if DML affected rows | Incorrect logic |
| 7 | **NEVER use SAVEPOINT/RELEASE SAVEPOINT/ROLLBACK TO SAVEPOINT** — not supported | Syntax errors |
| 8 | **NEVER use DEFAULT in parameter declarations** — use procedure overloading | Syntax errors |
| 9 | **NEVER use DECIMAL/NUMERIC/NUMBER/MONEY/UUID/GEOGRAPHY/GEOMETRY/ARRAY/ROW/SET as parameter types** | Syntax errors |
| 10 | **ALWAYS use QUOTE_IDENT/QUOTE_LITERAL** for dynamic SQL — prevent SQL injection | Security risk |

### Common Pitfalls
- Forgetting `PERFORM` for DDL/DML when not capturing output
- Using `COMMIT` inside loops or `SAVEPOINT` (not supported)
- Not using `FOUND` to check DML results or `GET STACKED DIAGNOSTICS` for errors
- Using `DEFAULT` in parameters (use overloading) or unsupported types (DECIMAL, UUID, etc.)
- Not using `QUOTE_IDENT`/`QUOTE_LITERAL` for dynamic SQL (SQL injection risk)
- Using `%ROWTYPE` (not supported) or expecting OUT params to modify original variables
- Exceeding 50-level procedure nesting depth

---

## PL/vSQL Fundamentals

### Structure
```sql
CREATE [OR REPLACE] PROCEDURE schema.procedure_name (
    [IN|OUT|INOUT] param_name datatype
)
LANGUAGE plvsql AS
$$
DECLARE
    variable_name datatype [:= default_value];
BEGIN
    -- procedure body
EXCEPTION
    WHEN OTHERS THEN
        -- error handling
END;
$$;
```

### ⚠️ Parameter Type Restrictions

**The following types CANNOT be used as parameters** (can be used as variables):

- DECIMAL, NUMERIC, NUMBER, MONEY
- UUID, GEOGRAPHY, GEOMETRY
- Complex types (ARRAY, ROW, SET)

**Workarounds**:
- Use `FLOAT` for decimal values
- Use `VARCHAR` and cast: `p_param::NUMERIC`
- Use `INTEGER` for fixed-point arithmetic (e.g., cents)

### ⚠️ No DEFAULT Keyword

Vertica does NOT support `DEFAULT` in parameter declarations. Use procedure overloading:

```sql
-- Main procedure with all parameters
CREATE PROCEDURE process_order(p_id INTEGER, p_discount FLOAT, p_priority VARCHAR)
AS $$ ... $$;

-- Overloaded version with defaults
CREATE PROCEDURE process_order(p_id INTEGER)
AS $$
BEGIN
    PERFORM CALL process_order(p_id, 0.1, 'NORMAL');
END;
$$;
```

### Parameter Modes

| Mode | Description | Usage |
|------|-------------|-------|
| `IN` | Input only (default) | Pass values to procedure |
| `OUT` | Output only | Return values via tuple |
| `INOUT` | Both input and output | Pass and return via tuple |

### ⚠️ OUT/INOUT Behavior (Critical for Oracle Migration)

- `CALL proc(args)` returns a **single tuple** with OUT/INOUT values as columns
- **Does NOT modify** original variables (unlike Oracle)
- Use tuple assignment: `v_name, v_salary := CALL get_employee_info(123);`

### Variable Declaration
```sql
DECLARE
    v_name VARCHAR(100) := 'default';
    v_count INTEGER := 0;
    v_date DATE;
    v_max_retries CONSTANT INTEGER := 3;      -- immutable
    v_start_time TIMESTAMP NOT NULL := SYSDATE();  -- cannot be NULL
    v_emp_name employees.name%TYPE;          -- anchor to column type
```

**Note**: `%TYPE` supported, `%ROWTYPE` is NOT supported.

### Assignment
```sql
v_name := 'value';           -- standard assignment
v_name <- 'value';           -- truncating assignment
SELECT col INTO v_name FROM table WHERE ...;
EXECUTE 'sql' INTO v_name USING params;
```

---

## PERFORM Usage

**🚨 CRITICAL: PERFORM MUST BE USED TO DISCARD OUTPUT! 🚨**

Every embedded SQL statement in a Vertica stored procedure produces a response. Use `PERFORM` to discard output when not capturing results.

### Capture Forms (NO PERFORM needed)

| Capture Form | Example |
|---|---|
| `var := SQL_STATEMENT` | `v_count := UPDATE employees SET salary = salary * 1.1;` |
| `var <- SQL_STATEMENT` | `v_name <- SELECT name FROM employees WHERE id = 1;` |
| `SELECT ... INTO var` | `SELECT name INTO v_name FROM employees WHERE id = 1;` |
| `EXECUTE ... INTO var` | `EXECUTE 'SELECT name FROM employees WHERE id = $1' INTO v_name USING 1;` |

### When to Use PERFORM
- Use `PERFORM` for DDL, DML, CALL, COMMIT, ROLLBACK, and EXECUTE when you don't need to capture the output
- If you're not using one of the capture forms above, you MUST use `PERFORM`

### Key Examples
```sql
PERFORM CREATE TABLE test (id INTEGER);                    -- DDL
PERFORM UPDATE employees SET salary = salary * 1.1;        -- DML
PERFORM CALL my_procedure();                              -- CALL
PERFORM EXECUTE 'UPDATE employees SET ...';                -- Dynamic SQL
```

### Check Results After PERFORM
```sql
PERFORM UPDATE employees SET salary = salary * 1.1;
IF FOUND THEN
    RAISE NOTICE 'Update successful';
END IF;
```

---

## Control Structures

### IF-ELSE
```sql
IF condition THEN
    -- statements
ELSIF condition THEN
    -- statements
ELSE
    -- statements
END IF;
```

### CASE
```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END CASE;
```

### LOOP
```sql
LOOP
    -- statements
    EXIT WHEN condition;
    CONTINUE WHEN condition;  -- skip to next iteration
END LOOP;

FOR i IN 1..10 LOOP
    -- statements
END LOOP;

FOR rec IN SELECT * FROM table LOOP
    -- statements
END LOOP;
```

### WHILE
```sql
WHILE condition LOOP
    -- statements
END LOOP;
```

---

## Exception Handling

### GET STACKED DIAGNOSTICS (CRITICAL)

**Important**: Use `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT` (NOT `PG_EXCEPTION_DETAIL`, etc.)

**Available fields**: `RETURNED_SQLSTATE`, `MESSAGE_TEXT`, `DETAIL_TEXT`, `HINT_TEXT`, `EXCEPTION_CONTEXT`, `COLUMN_NAME`, `CONSTRAINT_NAME`, `DATATYPE_NAME`, `TABLE_NAME`, `SCHEMA_NAME`

```sql
BEGIN
    -- statements
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No data found';
    WHEN TOO_MANY_ROWS THEN
        RAISE NOTICE 'Too many rows';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_sqlstate = RETURNED_SQLSTATE,
            v_message = MESSAGE_TEXT,
            v_detail = DETAIL_TEXT,
            v_hint = HINT_TEXT,
            v_context = EXCEPTION_CONTEXT,
            v_table = TABLE_NAME,
            v_column = COLUMN_NAME;
        RAISE EXCEPTION 'Error: %, Detail: %, Table: %, Column: %',
            v_message, v_detail, v_table, v_column;
END;
```

---

## Transaction Management

### Transaction Behavior

- **Auto-commit/rollback**: Top-level procedures auto-commit on success, auto-rollback on failure
- **Nested procedures**: Do NOT start their own transactions
- **Manual COMMIT**: Persists even if procedure later fails; do NOT use inside loops
- **Maximum nesting depth**: 50 levels (exceeding causes complete rollback)
- **Handled exceptions** → automatic commit; **Unhandled errors** → automatic rollback
- **NEVER use SAVEPOINT/RELEASE/ROLLBACK TO SAVEPOINT** — not supported


### Manual Transaction Control
```sql
BEGIN;
-- statements
PERFORM COMMIT;

BEGIN;
-- statements
PERFORM ROLLBACK;
```

### Important Notes
- Prefer automatic transaction handling, use manual COMMIT sparingly
- Do NOT use COMMIT inside loops — causes severe performance degradation

---

## Dynamic SQL

### EXECUTE
```sql
EXECUTE 'SELECT * FROM table WHERE id = $1' USING param;
EXECUTE 'UPDATE table SET col = $1 WHERE id = $2' USING value, id;
```

### Safe Dynamic SQL

**Always use QUOTE_IDENT for identifiers, QUOTE_LITERAL for strings:**

```sql
v_sql := 'SELECT COUNT(*) FROM ' || QUOTE_IDENT(p_schema) || '.' || QUOTE_IDENT(p_table);
EXECUTE v_sql INTO v_count;

v_sql := 'SELECT * FROM docs WHERE content LIKE ' || QUOTE_LITERAL('%' || p_search || '%');
```

---

## Cursor Operations

### Cursor Types

**Bound cursor** (with fixed SQL):
```sql
DECLARE
    cur_cursor CURSOR FOR SELECT * FROM table;
    cur_with_params CURSOR (param INTEGER) FOR SELECT * FROM table WHERE id = param;
```

**Unbound cursor** (refcursor, bind later):
```sql
DECLARE
    dynamic_cursor refcursor;
BEGIN
    OPEN dynamic_cursor FOR SELECT * FROM customers WHERE status = 'ACTIVE';
    -- or with dynamic SQL:
    OPEN dynamic_cursor FOR EXECUTE 'SELECT * FROM ' || QUOTE_IDENT(p_table);
```

### FOR Loop (Recommended - Auto-manages cursor)
```sql
FOR v_id, v_name, v_email IN CURSOR customer_cursor LOOP
    RAISE NOTICE 'Customer: % (%)', v_name, v_email;
END LOOP;
```

### Manual Cursor Operations
```sql
DECLARE
    cur_cursor CURSOR FOR SELECT * FROM table;
    v_id INTEGER;
    v_name VARCHAR;
BEGIN
    OPEN cur_cursor;
    LOOP
        v_id, v_name := FETCH cur_cursor;  -- tuple assignment
        EXIT WHEN NOT FOUND;
        -- process
    END LOOP;
    CLOSE cur_cursor;
```

### Advanced Operations
- `MOVE cursor_name;` — advance without retrieving data
- `CONTINUE WHEN condition;` — skip to next iteration in FOR loops
- `EXIT WHEN condition;` — exit loop early

---

## RAISE Statements

### RAISE Levels

| Level | Purpose |
|-------|---------|
| `LOG` | Send to vertica.log |
| `INFO` | Print INFO in vsql |
| `NOTICE` | Print NOTICE in vsql (default for info) |
| `WARNING` | Print WARNING in vsql |
| `EXCEPTION` | Throw catchable exception (default for errors) |

### RAISE Examples
```sql
RAISE NOTICE 'Processing % rows', row_count;
RAISE WARNING 'Potential issue detected';
RAISE EXCEPTION 'Error: %', value;
RAISE EXCEPTION 'Invalid id: %', v_id;
```

### ASSERT (Debugging)
```sql
ASSERT condition [, message];

-- Examples
ASSERT (SELECT COUNT(*) FROM products) > 0, 'products table is empty';
ASSERT p_amount > 0, 'Amount must be positive';
```

**Note**: ASSERT checking can be disabled with `PLpgSQLCheckAsserts = 0`.

---

## DO Blocks (Anonymous Procedures)

**For testing and one-time execution (no parameters, no return values):**

```sql
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM employees;
    RAISE NOTICE 'Total employees: %', v_count;
END;
$$;
```

**Use cases**: Testing, one-time data fixes, migration validation

## Common Patterns

### Returning Multiple Values
```sql
CREATE PROCEDURE get_stats(
    OUT p_count INTEGER,
    OUT p_total NUMERIC
) AS $$
BEGIN
    SELECT COUNT(*), SUM(amount) INTO p_count, p_total FROM orders;
END;
$$;

-- Call
SELECT count, total FROM get_stats();
```

### Validation and Error Handling
```sql
CREATE PROCEDURE update_salary(p_emp_id INTEGER, p_raise NUMERIC) AS $$
BEGIN
    IF p_raise < 0 THEN
        RAISE EXCEPTION 'Raise cannot be negative: %', p_raise;
    END IF;

    IF p_raise > 50 THEN
        RAISE WARNING 'Large raise: %%', p_raise;
    END IF;

    -- proceed with update
END;
$$;
```

---

## When to Load Full Document

This summary contains ALL information needed for stored procedure development in Vertica. The full document is for human reference with detailed examples.

**For complete examples and rationale, see [stored-procedures-guide.md](../stored-procedures-guide.md).**
