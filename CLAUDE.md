# CLAUDE.md - Vertica Expert Skill

This file provides documentation for the Vertica Expert skill to help Claude understand how to use it effectively.

## Overview

The **Vertica Expert** skill is a comprehensive tool for migrating databases from other systems (Oracle, DB2, SQL Server, PostgreSQL, MySQL) to Vertica and implementing machine learning workflows, with a focus on performance optimization and best practices.

## When to Use This Skill

Use this skill when users need help with:

1. **SQL Query Conversion** - Converting queries from other databases to Vertica syntax
2. **Schema Migration** - Converting table definitions, data types, and constraints
3. **Function Mapping** - Finding Vertica equivalents for functions from other databases
4. **Stored Procedure Migration** - Converting PL/SQL, T-SQL, or PL/pgSQL to PL/vSQL
5. **User-Defined SQL Functions Development** - Creating custom functions in SQL
6. **Stored Procedures Development** - Creating stored procedures in PL/vSQL
7. **UDx Development** - Creating custom functions in C++, Python, Java, or R
8. **Projection Design** - Designing optimal projections for query performance
9. **Performance Optimization** - Optimizing queries and database design for Vertica's columnar architecture
10. **Machine Learning** - Implementing in-database ML workflows (regression, classification, clustering, time series)
11. **Data Science** - End-to-end analytics workflows within Vertica

## How to Use This Skill

### Basic Usage Pattern

```
User asks: "Convert [source_db] query to Vertica: [SQL code]"

Claude should:
1. Identify the source database
2. Convert SQL syntax to Vertica
3. Map functions to Vertica equivalents
4. Suggest performance optimizations
5. Provide projection design recommendations if applicable
```

### Machine Learning Usage Pattern

```
User asks: "Implement [ML task] in Vertica using [algorithm]"

Claude should:
1. Identify the appropriate Vertica ML algorithm
2. Provide data preparation guidance
3. Show model training syntax
4. Include evaluation metrics
5. Demonstrate deployment for predictions
```

### Advanced Usage Pattern

```
User asks: "I need to migrate [complex object] from [source_db] to Vertica"

Claude should:
1. Analyze the complexity and requirements
2. Provide step-by-step migration approach
3. Include performance considerations
4. Suggest testing and validation strategies
5. Reference appropriate sections of the skill documentation
```

## Key Reference Files

### 1. Generic Migration Guide (`references/generic-migration-guide.md`) 🚨 **MANDATORY READING**
**USE FOR ALL DATABASE MIGRATIONS** - This is the master reference that defines non-negotiable requirements:
- **Complete Migration Requirements**: ALL objects must be migrated (no selective migration)
- **Sequential Processing**: Process source files in exact order (no skipping or reordering)
- **Object Integrity**: Never break up complete objects or statements
- **One-to-One Conversion**: Tables→Tables, Views→Views, Procedures→Procedures
- **Mandatory Testing**: Test every object individually before considering it migrated
- **No Automation**: Never use scripts or bulk processing
- **Reference Priority**: This guide takes precedence over all other migration guides

### 1.5. OLTP to OLAP Rewrite Guide (`references/oltp-to-olap-rewrite-guide.md`) 🔄 **ESSENTIAL FOR PROCEDURAL CODE**
**USE WHENEVER MIGRATING PROCEDURAL/OLTP CODE** - This guide covers the architectural paradigm shift from row-by-row to set-based processing:
- **5 Rewrite Patterns**: Adjacent DML merging, loop-DML→set-based SQL, cursor→window functions, function-call→join, recursive CTE, etc.
- **Before/After Examples**: Each scenario shows the anti-pattern and the optimized Vertica rewrite
- **Migration Checklist**: Comprehensive checklist to audit migrated code for OLTP anti-patterns
- **Decision Framework**: Flowchart for choosing the right rewrite approach
- **Anti-Pattern Rejection List**: Patterns that should always be flagged and rewritten

### 2. Migration Guides Overview (`references/migration-guides-overview.md`)
Shows the hierarchical relationship between all migration guides and provides usage instructions for each database type.

### 3. Data Types (`references/data-types.md`)
Use when converting table schemas. Contains:
- Complete data type mapping between source databases and Vertica
- Optimization strategies for storage and performance
- Complex types (ARRAY, ROW, SET, spatial)
- Migration examples for each database system

### 4. Function Mapping (`references/function-mapping.md`)
Use when users need to convert specific functions. Contains:
- 100+ function mappings from Oracle, DB2, SQL Server, PostgreSQL, MySQL
- Aggregate functions (including approximate variants)
- String, date, mathematical, and analytic functions
- Type conversion functions and optimization guidelines

### 5. User-Defined SQL Functions (`references/user-defined-sql-functions-guide.md`)
Use when creating or managing User-Defined SQL Functions. Contains comprehensive coverage of:
- **Quick Start**: Basic examples and syntax
- **Complete Reference**: CREATE FUNCTION syntax with all parameters
- **Practical Examples**: Data cleaning, business logic, mathematical functions, date/time utilities
- **Function Management**: Creation, modification, overloading, privileges
- **Performance**: Optimization guidelines and testing strategies
- **Best Practices**: Naming conventions, error handling, documentation
- **Troubleshooting**: Common issues and debugging tips

### 6. Stored Procedures (`references/stored-procedures-guide.md`)
Use when creating or managing stored procedures in PL/vSQL. Contains:
- **PL/vSQL Fundamentals**: Syntax, variables, control structures
- **Parameter Modes**: IN, OUT, and INOUT parameter usage and examples
- **SQL Command Scope**: Which commands work inside vs outside stored procedures
- **Development Guide**: Complete stored procedure development lifecycle
- **Exception Handling**: Error management with GET STACKED DIAGNOSTICS
- **Transaction Management**: COMMIT, ROLLBACK, and transaction semantics
- **Performance**: Optimization strategies and best practices

### 7. UDx Development (`references/udx-development-guide.md`)
Use when developing complex User-Defined Extensions in C++, Python, Java, or R. Contains:
- **Language-Specific Guides**: C++, Python, Java, R development
- **UDx Types**: Scalar, aggregate, analytic, transform, and load functions
- **Development Environment**: Setup and compilation instructions
- **Best Practices**: Performance optimization and security considerations
- **Deployment**: Registration and management of UDx libraries

### 8. Query Optimization (`references/query-optimization.md`)
Use when optimizing query performance. Contains:
- Projection design patterns
- Encoding strategies (RLE, DELTA, GZIP, LZO)
- Join optimization techniques
- Resource management and monitoring
- Performance anti-patterns and solutions

### 9. Oracle Migration (`references/oracle-migration.md`)
Use specifically for Oracle migrations. Contains:
- PL/SQL to PL/vSQL conversion guide
- Package migration strategies
- Stored procedure examples with exception handling
- Performance optimization for Oracle workloads

### 10. DB2 Migration (`references/db2-migration.md`)
Use specifically for IBM DB2 migrations. Contains:
- PL/SQL to PL/vSQL conversion guide
- DB2 module/package migration strategies
- Sequence handling and identity column conversion
- MQT (Materialized Query Tables) to Live Aggregate Projections
- DB2 special registers and system tables conversion
- Performance optimization for DB2 workloads

### 11. SQL Server Migration (`references/sqlserver-migration.md`)
Use for SQL Server migrations. Contains:
- T-SQL to Vertica SQL conversion patterns
- Data type mappings and optimization strategies
- Stored procedure migration with transaction handling
- Performance optimization for SQL Server workloads

### 12. PostgreSQL Migration (`references/postgresql-migration.md`)
Use for PostgreSQL migrations. Contains:
- PL/pgSQL to PL/vSQL conversion guide
- Array and JSON handling strategies
- Function mapping and type conversions
- Performance optimization for PostgreSQL workloads

### 13. MySQL Migration (`references/mysql-migration.md`)
Use for MySQL migrations. Contains:
- MySQL SQL syntax to Vertica conversion
- AUTO_INCREMENT to IDENTITY conversion
- Storage engine differences and alternatives
- Performance optimization for MySQL workloads

### 13. Machine Learning (`references/machine-learning.md`)
Use for implementing in-database machine learning. Contains:
- Complete coverage of regression, classification, clustering, and time series algorithms
- Data preparation functions (imputation, encoding, outlier detection)
- Model evaluation metrics and validation techniques
- Model management and deployment strategies
- Integration with Python (VerticaPy) and R

### 14. ML Function Mapping (`references/ml-function-mapping.md`)
Use for cross-database ML function equivalents. Contains:
- Function mappings between Python (scikit-learn), R, and Vertica SQL
- Data preparation, modeling, and evaluation function equivalents
- Migration examples from popular ML frameworks
- Performance considerations and best practices

## Common User Requests and Responses

### Request: Simple Function Conversion
**User**: "What's the Vertica equivalent of Oracle's NVL function?"

**Response**: "In Vertica, use `COALESCE()` instead of Oracle's `NVL()`. Both serve the same purpose, but `COALESCE()` is ANSI standard and preferred. Example: `COALESCE(column_name, 'default_value')`"

### Request: Query Conversion
**User**: "Convert this Oracle query to Vertica: SELECT NVL(name, 'Unknown') FROM users"

**Response**: "Here's the Vertica equivalent: `SELECT COALESCE(name, 'Unknown') FROM users`. I've converted `NVL()` to `COALESCE()`. For optimal performance, consider creating a projection with appropriate encoding for the name column."

### Request: Stored Procedure Migration
**User**: "I need to convert this Oracle PL/SQL procedure to Vertica"

**Response": "I'll help you convert this PL/SQL procedure to Vertica PL/vSQL. Key changes needed:
1. Change `NUMBER` to `INTEGER` or `NUMERIC`
2. Replace `SQL%ROWCOUNT` with `FOUND` special variable or separate count query
3. Change `SYSDATE` to `SYSDATE()`
4. Use `PERFORM` for DDL statements (CREATE, ALTER, DROP, TRUNCATE, etc.) and DML statements (INSERT, UPDATE, DELETE) when not capturing return values
5. Add proper DECLARE block for all variables
6. Update exception handling with `GET STACKED DIAGNOSTICS`
7. Update exception handling syntax

Let me provide the complete conversion..."

### Request: Performance Optimization
**User**: "This query is slow in Vertica, how can I optimize it?"

**Response": "I'll help optimize this query for Vertica's columnar architecture. First, let me analyze the query plan. Key optimization strategies:
1. Design appropriate projections with optimal sort order
2. Use proper encoding for each column
3. Consider live aggregate projections for summary queries
4. Update statistics with ANALYZE_STATISTICS()

Let me provide specific recommendations..."

### Request: User-Defined SQL Function Creation
**User**: "I need to create a function that replaces NULL values with defaults in Vertica"

**Response**: "I'll help you create a User-Defined SQL Function for NULL handling. Here's an example:

```sql
-- Create function to replace NULL with zero
CREATE FUNCTION myzeroifnull(x INT) RETURN INT
   AS BEGIN
     RETURN (CASE WHEN (x IS NOT NULL) THEN x ELSE 0 END);
   END;

-- Usage examples
SELECT myzeroifnull(column_name) FROM table_name;
SELECT COUNT(*) FROM table_name GROUP BY myzeroifnull(column_name);
```

Key points about User-Defined SQL Functions:
1. Use CREATE FUNCTION with RETURN type and BEGIN/END block
2. Can be used anywhere SQL expressions are valid
3. Cannot contain FROM, WHERE, GROUP BY clauses
4. Support function overloading with different argument types
5. Vertica infers volatility (IMMUTABLE, STABLE, VOLATILE) automatically

For more complex logic requiring procedural code, consider C++, Python, Java, or R UDxs instead."

### Request: Machine Learning Implementation
**User**: "How do I implement customer churn prediction in Vertica?"

**Response": "I'll help you implement customer churn prediction using Vertica's in-database machine learning. Here's the complete workflow:
1. Data preparation: Handle missing values and encode categorical features
2. Model training: Use RF_CLASSIFIER for robust classification
3. Model evaluation: Calculate accuracy, precision, recall metrics
4. Deployment: Create prediction views for real-time scoring

Example implementation:
```sql
-- Train churn prediction model
SELECT RF_CLASSIFIER('churn_model', 'customer_data',
    'churned', 'age, income, tenure, support_calls');

-- Make real-time predictions
SELECT customer_id,
       PREDICT_RF_CLASSIFIER(features
           USING PARAMETERS model_name='churn_model')
FROM new_customers;
```

## PERFORM Command Usage in PL/vSQL

The PERFORM command is essential for executing DDL statements (CREATE, ALTER, DROP, TRUNCATE, etc.) and DML statements (INSERT, UPDATE, DELETE, MERGE) in PL/vSQL when you don't need to capture the immediate return value.

### When to Use PERFORM
- **DDL statements**: CREATE, ALTER, DROP, TRUNCATE, etc.
- **INSERT statements**: When you don't need the inserted row count immediately
- **UPDATE statements**: When you don't need the updated row count immediately
- **DELETE statements**: When you don't need the deleted row count immediately
- **MERGE statements**: For data synchronization operations
- **Any SQL statement**: When you want to discard the return value

### PERFORM Examples
```sql
-- Use PERFORM for DDL, DML that doesn't need immediate row count
PERFORM INSERT INTO audit_log (message, created_at) 
VALUES ('Processing started', SYSDATE());

PERFORM UPDATE employees 
SET last_updated = SYSDATE() 
WHERE status = 'ACTIVE';

PERFORM DELETE FROM temp_data 
WHERE processed_date < CURRENT_DATE - 30;
```

### Checking Results After PERFORM
```sql
-- Use FOUND special variable to check if operation succeeded
PERFORM UPDATE employees SET salary = salary * 1.1;
IF FOUND THEN
    RAISE NOTICE 'Update was successful';
ELSE
    RAISE NOTICE 'No rows were updated';
END IF;

-- Or use separate query to get count if needed
PERFORM INSERT INTO summary_table VALUES ('test');
SELECT COUNT(*) INTO v_count FROM summary_table WHERE name = 'test';
```

## Best Practices for Using This Skill

### 1. Progressive Disclosure
- Start with basic conversions
- Add optimization recommendations
- Provide advanced guidance as needed

### 2. Cross-Reference Documentation
- Reference specific sections when providing detailed guidance
- Use the table of contents to help users navigate
- Provide links to relevant examples

### 3. Performance Focus
- Always consider Vertica's columnar architecture
- Recommend projection design for new implementations
- Suggest encoding strategies for optimal compression
- Emphasize statistics management
- Leverage in-database processing for ML workflows

### 4. User-Defined SQL Functions Best Practices
- **Start Simple**: Use SQL functions for simple transformations before complex UDxs
- **Choose Appropriately**: SQL functions for simple expressions, C++/Python/Java/R for complex logic
- **Handle NULLs**: Always consider NULL value handling in function logic
- **Test Thoroughly**: Test with various data types, edge cases, and NULL inputs
- **Manage Dependencies**: Track and update views when modifying functions
- **Use Overloading**: Create multiple versions for different data types when needed

### 5. Transaction Semantics in Stored Procedures
- **Automatic commits**: Top-level procedures auto-commit on success, auto-rollback on failure
- **Manual commits**: COMMIT statements are allowed and persist even if procedure later fails
- **Nested procedures**: Do not start their own transactions
- **Best practice**: Prefer automatic transaction handling, use manual COMMIT sparingly
- **Error handling**: Use GET STACKED DIAGNOSTICS for detailed error information

### 6. PL/vSQL Command Scope Best Practices
- **Understand command limitations**: Know which commands work only in PL/vSQL vs. both contexts
- **PERFORM for DDL, DML**: Use PERFORM for CREATE, ALTER, DROP, TRUNCATE and INSERT, UPDATE, DELETE when discarding row counts
- **RAISE for messaging**: Use RAISE NOTICE/WARNING/EXCEPTION for debugging and error handling
- **Variable assignment**: Use `:=` for regular assignment, `<-` for truncating assignment
- **External alternatives**: Use DO blocks for anonymous PL/vSQL execution outside procedures
- **Dynamic SQL**: Use EXECUTE with proper quoting functions to prevent SQL injection

### 7. Migration Strategy
- Break down complex migrations into manageable steps
- Provide testing recommendations
- Include rollback strategies where appropriate
- Suggest performance benchmarking approaches

## Integration with Other Skills

This skill works well with:
- **Database design skills** for schema optimization
- **Performance analysis skills** for query tuning
- **Code review skills** for validating conversions
- **Testing skills** for migration validation

## Limitations and Considerations

### Skill Limitations
- Focuses on SQL and procedural code conversion
- Does not handle application-level changes
- May not cover extremely database-specific features

### Important Considerations
- Always test converted code thoroughly
- Consider data volume and performance requirements
- Plan for proper statistics management
- Account for Vertica's distributed architecture

## Troubleshooting Common Issues

### Issue: Function Not Found
**Solution**: Check the function mapping guide for alternatives or suggest UDx development

### Issue: Performance Degradation
**Solution**: Review projection design, encoding strategies, and statistics

### Issue: Data Type Incompatibility
**Solution**: Use the data type mapping guide and consider explicit casting

### Issue: Transaction Differences
**Solution**: Explain Vertica's transaction model and provide alternatives

### Issue: ML Model Convergence
**Solution**: Check data quality, adjust algorithm parameters, and verify feature engineering

### Issue: ML Memory Errors
**Solution**: Increase resource pool memory, reduce dataset size, or optimize feature selection

### Issue: PL/vSQL Command Scope Error
**Solution**: Verify command usage context - PERFORM, RAISE, and variable assignments only work in PL/vSQL. Use DO blocks for testing outside procedures.

### Issue: EXECUTE Command Confusion
**Solution**: Distinguish between external EXECUTE (prepared statements) and PL/vSQL EXECUTE (dynamic SQL). Use appropriate syntax for each context.

## Version Compatibility

This skill covers Vertica versions 9.x through 24.x. When providing specific guidance, consider:
- Eon Mode features for newer versions
- Deprecated features and their replacements
- New function additions in recent releases

## Example Workflows

### Workflow 1: Simple Query Conversion
1. Identify source database and query
2. Convert syntax using function mapping guide
3. Suggest performance optimizations
4. Provide testing recommendations

### Workflow 2: Complete Database Migration
1. Analyze source schema complexity
2. Plan migration strategy
3. Convert DDL (tables, indexes, constraints)
4. Transform SQL queries and stored procedures
5. Design optimal projections
6. Test and optimize performance

### Workflow 3: Performance Optimization
1. Analyze current query performance
2. Review query plan and execution statistics
3. Design appropriate projections
4. Implement encoding strategies
5. Update statistics and retest

### Workflow 4: Machine Learning Implementation
1. Define ML problem (regression, classification, clustering, time series)
2. Prepare training data with feature engineering
3. Select appropriate Vertica ML algorithm
4. Train model using in-database functions
5. Evaluate model performance with built-in metrics
6. Deploy model for production predictions

### Workflow 5: PL/vSQL Command Scope Troubleshooting
1. Identify whether command is PL/vSQL-specific or shared
2. For PL/vSQL-only commands (PERFORM, RAISE, etc.): ensure usage within stored procedures
3. For shared commands (CALL, DO, EXECUTE): verify correct context and syntax
4. Use DO blocks for testing PL/vSQL code outside procedures
5. Convert external SQL to appropriate PL/vSQL constructs when migrating to procedures

## Testing Vertica SQL and Stored Procedures

This skill provides comprehensive Vertica SQL statements and stored procedures that can be tested using the VSQL command-line tool.

### VSQL Testing Setup

The environment variable `VSQL` should contain the vsql connection parameters:
```bash
export VSQL='/opt/vertica/bin/vsql -h hostname -p 5433 -U username -w password dbname'
```

**Important Autocommit Behavior**: By default, vsql has **autocommit OFF** for interactive sessions, meaning you must explicitly COMMIT transactions for data modifications to persist. This is different from client libraries which have autocommit ON by default.

To enable autocommit in vsql (recommended for testing):
```sql
SET SESSION AUTOCOMMIT TO ON;
```

To disable autocommit (vsql default behavior):
```sql
SET SESSION AUTOCOMMIT TO OFF;
```

For testing scripts, it's recommended to either:
1. Enable autocommit at the start: `SET SESSION AUTOCOMMIT TO ON;`
2. Include explicit COMMIT statements after data modifications
3. Execute related statements (INSERT/SELECT) in the same $VSQL command

### VSQL Command Reference

From ~/Downloads/vertica_doc/, key vsql usage patterns:

- **Execute single command or  single-line SQL**: `$VSQL -c "SELECT VERSION();"`

- **Execute multi-line SQL**: Use here document to avoid escaping special characters like `$` and `"`:

  ```bash
  $VSQL<<-'EOF'
  SQL1;
  SQL2;
  ...
  EOF
  ```

- **Run SQL file**: `$VSQL -f script.sql`

- **Interactive mode**: `$VSQL` (then enter SQL statements)

- **Enable timing**: `$VSQL -i` (shows query execution time)

- **Check availability of a schema**: `$VSQL -c "\dn schema_name"`

- **Check availability of a table**: `$VSQL -c "\dt table_name"`

- **Check availability of a view**: `$VSQL -c "\dt view_name"`

- **Check availability of a projection**: `$VSQL -c "\dj projection_name"`

- **Check availability of a function**: `$VSQL -c "\df function_name"`

  # Check availability of a function
  $VSQL -c "\df *function_name*"

### Example Test Commands

```bash
# Test basic connectivity
$VSQL -c "SELECT VERSION(), CURRENT_DATE, USER;"

# Test table operations
$VSQL -c "CREATE TABLE test (id INTEGER, name VARCHAR(50));"
$VSQL -c "INSERT INTO test VALUES (1, 'example');"
$VSQL -c "SELECT * FROM test;"

# Test stored procedure creation
$VSQL<<-'EOF'
CREATE OR REPLACE PROCEDURE test_proc() AS $$
BEGIN
    RAISE NOTICE 'Test procedure executed';
END;
$$
EOF

# Call stored procedure
$VSQL -c "CALL test_proc();"

# Test analytic functions
$VSQL<<-'EOF'
SELECT id, name,
       ROW_NUMBER() OVER (ORDER BY id) as row_num
FROM test;
EOF

# Test error handling in procedures
$VSQL<<-'EOF'
CREATE OR REPLACE PROCEDURE test_error() AS $$
DECLARE
    v_error_msg VARCHAR;
BEGIN
    -- Intentionally cause an error
    PERFORM INSERT INTO nonexistent_table VALUES (1);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Caught error: %', v_error_msg;
END;
$$
EOF

# Test function mapping (Oracle NVL to Vertica COALESCE)
$VSQL -c "SELECT COALESCE(NULL, 'default_value') as result;"

# Enable autocommit for testing (recommended)
$VSQL -c "SET SESSION AUTOCOMMIT TO ON;"

# Test statistics
$VSQL -c "SELECT ANALYZE_STATISTICS('test');"


# List all ML models in the database
$VSQL -c "SELECT model_name, model_type, owner_name, create_time, size FROM V_CATALOG.MODELS;"

# Find specific ML model
$VSQL -c "SELECT * FROM V_CATALOG.MODELS WHERE model_name = 'your_model_name';"

# Delete a single ML model
$VSQL -c "DROP MODEL model_name;"

# Delete multiple ML models
$VSQL -c "DROP MODEL model1, model2, model3;"
```

### Clean Test Database

Use this PL/vSQL anonymous block to drop all user-created objects (procedures, functions, views, tables, sequences) from the database. Excludes system schemas (`v_txtindex`, `v_catalog`, `v_monitor`, `v_func`, `pg_catalog`).

```sql
$VSQL<<-'EOF'
do $$
declare sql varchar;
begin
  for sql in query
    -- drop all user stored procedures
    select 'drop procedure if exists '||schema_name||'.'||procedure_name||'('|| procedure_arguments||');' as sql from user_procedures where schema_name not in ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    union all
    -- drop all user SQL functions
    select 'drop function if exists '||schema_name||'.'||function_name||'('||function_argument_type||');' from user_functions where schema_name not in ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog') and function_name not in ('isOrContains') and  function_definition ilike 'return%'
    union all
    -- drop all user views
    select 'drop view if exists '||table_schema||'.'||table_name||' cascade;' from views where table_schema not in ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    union all
    -- drop all user tables
    select 'drop table if exists '||table_schema||'.'||table_name||' cascade;' from tables where table_schema not in ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    union all
    -- drop all user sequences
    select 'drop sequence if exists '||sequence_schema||'.'||sequence_name||';' from sequences where sequence_schema not in ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    -- drop all user schemas
    union all
    select 'drop schema if exists '||schema_name||';' from schemata where schema_name not in ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog', 'public')
    
  loop
    raise notice '%', sql; perform execute sql;
  end loop;
end;
$$;
EOF
```

**Notes:**
- Uses `CASCADE` for tables and views to handle dependencies.
- The `RAISE NOTICE` prints each DROP statement before executing it, so you can see what was cleaned.
- Excludes the `isOrContains` built-in function from being dropped.
- Only drops SQL functions (identified by `function_definition ILIKE 'return%'`), not C++/Java UDx functions.

### Testing Features Covered

All examples in this skill can be tested using VSQL:

- **Basic SQL**: Table creation, data insertion, SELECT queries
- **Analytic Functions**: Window functions, running totals, LAG/LEAD
- **Function Mapping**: COALESCE (Oracle NVL equivalent), data type conversions
- **Stored Procedures**: PL/vSQL procedures with proper exception handling
- **Error Handling**: GET STACKED DIAGNOSTICS for error information retrieval
- **Performance**: Projection creation with encoding strategies (RLE, DELTA, GZIP)
- **Migration Examples**: Converted SQL from Oracle, DB2, SQL Server, PostgreSQL, MySQL
- **Data Types**: Optimal type selection for Vertica's columnar storage

