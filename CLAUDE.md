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

### 1. Generic Migration Guide 🚨 **MANDATORY READING**
**USE FOR ALL DATABASE MIGRATIONS** - This is the master reference that defines non-negotiable requirements:
- **Complete Migration Requirements**: ALL objects must be migrated (no selective migration)
- **Sequential Processing**: Process source files in exact order (no skipping or reordering)
- **Object Integrity**: Never break up complete objects or statements
- **One-to-One Conversion**: Tables→Tables, Views→Views, Procedures→Procedures
- **Mandatory Testing**: Test every object individually before considering it migrated
- **No Automation**: Never use scripts or bulk processing
- **Reference Priority**: This guide takes precedence over all other migration guides

**Full Document:** [Generic Migration Guide](references/generic-migration-guide.md)
**Summary (for reduced context):** [Generic Migration Summary](references/reference-summaries/generic-migration-summary.md)

### 2. OLTP to OLAP Rewrite Guide 🔄 **ESSENTIAL FOR PROCEDURAL CODE**
**USE WHENEVER MIGRATING PROCEDURAL/OLTP CODE** - This guide covers the architectural paradigm shift from row-by-row to set-based processing:
- **5 Rewrite Patterns**: Adjacent DML merging, loop-DML→set-based SQL, cursor→window functions, function-call→join, recursive CTE, etc.
- **Before/After Examples**: Each scenario shows the anti-pattern and the optimized Vertica rewrite
- **Migration Checklist**: Comprehensive checklist to audit migrated code for OLTP anti-patterns
- **Decision Framework**: Flowchart for choosing the right rewrite approach
- **Anti-Pattern Rejection List**: Patterns that should always be flagged and rewritten

**Full Document:** [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md)
**Summary (for reduced context):** [OLTP to OLAP Summary](references/reference-summaries/oltp-to-olap-summary.md)

### 3. Migration Guides Overview
Shows the hierarchical relationship between all migration guides and provides usage instructions for each database type.

**Document:** [Migration Guides Overview](references/migration-guides-overview.md)

### 4. Data Types
Use when converting table schemas. Contains:
- Complete data type mapping between source databases and Vertica
- Optimization strategies for storage and performance
- Complex types (ARRAY, ROW, SET, spatial)
- Migration examples for each database system

**Full Document:** [Data Types](references/data-types.md)
**Summary (for reduced context):** [Data Types Summary](references/reference-summaries/data-types-summary.md)

### 5. Function Mapping
Use when users need to convert specific functions. Contains:
- 100+ function mappings from Oracle, DB2, SQL Server, PostgreSQL, MySQL
- Aggregate functions (including approximate variants)
- String, date, mathematical, and analytic functions
- Type conversion functions and optimization guidelines

**Full Document:** [Function Mapping](references/function-mapping.md)

### 6. User-Defined SQL Functions
Use when creating or managing User-Defined SQL Functions. Contains comprehensive coverage of:
- **Quick Start**: Basic examples and syntax
- **Complete Reference**: CREATE FUNCTION syntax with all parameters
- **Practical Examples**: Data cleaning, business logic, mathematical functions, date/time utilities
- **Function Management**: Creation, modification, overloading, privileges
- **Performance**: Optimization guidelines and testing strategies
- **Best Practices**: Naming conventions, error handling, documentation
- **Troubleshooting**: Common issues and debugging tips

**Full Document:** [User-Defined SQL Functions](references/user-defined-sql-functions-guide.md)
**Summary (for reduced context):** [User-Defined SQL Functions Summary](references/reference-summaries/user-defined-sql-functions-summary.md)

### 7. Stored Procedures
Use when creating or managing stored procedures in PL/vSQL. Contains:
- **PL/vSQL Fundamentals**: Syntax, variables, control structures
- **Parameter Modes**: IN, OUT, and INOUT parameter usage and examples
- **SQL Command Scope**: Which commands work inside vs outside stored procedures
- **Development Guide**: Complete stored procedure development lifecycle
- **Exception Handling**: Error management with GET STACKED DIAGNOSTICS
- **Transaction Management**: COMMIT, ROLLBACK, and transaction semantics
- **Performance**: Optimization strategies and best practices

**Full Document:** [Stored Procedures](references/stored-procedures-guide.md)
**Summary (for reduced context):** [Stored Procedures Summary](references/reference-summaries/stored-procedures-summary.md)

### 8. UDx Development
Use when developing complex User-Defined Extensions in C++, Python, Java, or R. Contains:
- **Language-Specific Guides**: C++, Python, Java, R development
- **UDx Types**: Scalar, aggregate, analytic, transform, and load functions
- **Development Environment**: Setup and compilation instructions
- **Best Practices**: Performance optimization and security considerations
- **Deployment**: Registration and management of UDx libraries

**Document:** [UDx Development](references/udx-development-guide.md)

### 9. Query Optimization
Use when optimizing query performance. Contains:
- Projection design patterns
- Encoding strategies (RLE, DELTA, GZIP, LZO)
- Join optimization techniques
- Resource management and monitoring
- Performance anti-patterns and solutions

**Document:** [Query Optimization](references/query-optimization.md)

### 10. Database-Specific Migration Guides
Each guide contains source-database-specific migration patterns, following the generic migration requirements:

#### Oracle Migration
**Full Document:** [Oracle Migration](references/oracle-migration.md) - PL/SQL to PL/vSQL conversion guide, package migration strategies, stored procedure examples with exception handling
**Summary (for reduced context):** [Oracle Migration Summary](references/reference-summaries/oracle-migration-summary.md)

#### DB2 Migration
**Full Document:** [DB2 Migration](references/db2-migration.md) - PL/SQL to PL/vSQL conversion guide, DB2 module/package migration, sequence handling, MQT to Live Aggregate Projections
**Summary (for reduced context):** [DB2 Migration Summary](references/reference-summaries/db2-migration-summary.md)

#### SQL Server Migration
**Full Document:** [SQL Server Migration](references/sqlserver-migration.md) - T-SQL to Vertica SQL conversion, stored procedure migration with transaction handling
**Summary (for reduced context):** [SQL Server Migration Summary](references/reference-summaries/sqlserver-migration-summary.md)

#### PostgreSQL Migration
**Full Document:** [PostgreSQL Migration](references/postgresql-migration.md) - PL/pgSQL to PL/vSQL conversion, Array and JSON handling, function mapping
**Summary (for reduced context):** [PostgreSQL Migration Summary](references/reference-summaries/postgresql-migration-summary.md)

#### MySQL Migration
**Full Document:** [MySQL Migration](references/mysql-migration.md) - MySQL SQL syntax to Vertica conversion, AUTO_INCREMENT to IDENTITY, storage engine differences
**Summary (for reduced context):** [MySQL Migration Summary](references/reference-summaries/mysql-migration-summary.md)

### 11. Machine Learning
Use for implementing in-database machine learning. Contains:
- Complete coverage of regression, classification, clustering, and time series algorithms
- Data preparation functions (imputation, encoding, outlier detection)
- Model evaluation metrics and validation techniques
- Model management and deployment strategies
- Integration with Python (VerticaPy) and R

**Document:** [Machine Learning](references/machine-learning.md)

### 12. ML Function Mapping
Use for cross-database ML function equivalents. Contains:
- Function mappings between Python (scikit-learn), R, and Vertica SQL
- Data preparation, modeling, and evaluation function equivalents
- Migration examples from popular ML frameworks
- Performance considerations and best practices

**Document:** [ML Function Mapping](references/ml-function-mapping.md)

### 13. Multi-Agent Migration Workflow 🤖 **FOR LARGE-SCALE MIGRATIONS**
**USE FOR COMPLEX MIGRATIONS** - This guide defines a 4-agent architecture to prevent context overflow and ensure rule adherence:

**When to Use:**
- ✅ More than 1 source file
- ✅ Single source file exceeds 200 lines
- ✅ Contains multiple stored procedures or functions
- ✅ Large-scale migrations requiring strict context management

**When NOT to Use:**
- ❌ Only 1 small file
- ❌ Simple table structure migration

**Architecture:**
1. **Manager Agent (Main Session)**: Controls workflow coordination, dispatches tasks, **🚫 NEVER reads source files or migration reference documents**, **STRICTLY VERIFIES** Migrator's unit test and Tester's test results
2. **Requester Agent (Sub-Agent)**: Reads source files section-by-section using `Read(offset=N, limit=50)`, **EXCLUSIVE responsibility for file reading**, groups consecutive DML on same table
3. **Migrator Agent (Sub-Agent)**: **ONLY agent that loads migration reference documents** (basic docs at startup, additional docs on-demand), performs code transformation, unit tests before returning
4. **Tester Agent (Sub-Agent)**: Validates migrated code using unified test method (single VSQL call with autocommit), provides pass/fail feedback with complete logs

**Key Principle:** Only Migrator loads migration reference documents. Manager, Requester, and Tester only read this guide. Manager has NO migration expertise - NEVER provides migration rules or decisions to Migrator.

**Multi-Agent Reference Documents:**
- [Multi-Agent Quick Reference](references/multi-agent-quick-reference.md) - **PRIMARY REFERENCE** - Essential rules, personality traits, constraints, workflows, and verification checklists for all agents
- [Multi-Agent Detailed Guide](references/multi-agent-detailed-guide.md) - **ON-DEMAND ONLY** - Load only for complex scenarios, troubleshooting, or training

**Reference Document Summaries (Reduced Context):**
- `references/reference-summaries/` directory contains condensed versions of large reference documents
- Use these summaries to reduce context usage during migrations
- Load full documents only when summary is insufficient

**Summary Files:**
- Core Documents: `generic-migration-summary.md`, `sql-syntax-summary.md`, `data-types-summary.md`, `oltp-to-olap-summary.md`
- Stored Procedures and Functions: `stored-procedures-summary.md`, `user-defined-sql-functions-summary.md`
- Database-Specific: `oracle-migration-summary.md`, `db2-migration-summary.md`, `sqlserver-migration-summary.md`, `postgresql-migration-summary.md`, `mysql-migration-summary.md`
- **Note:** `function-mapping.md` is used directly (no summary needed - already concise)

**Agent Configuration Files:**
- [Requester Agent](agents/requester.md) - Source file reader configuration
- [Migrator Agent](agents/migrator.md) - Code transformer configuration
- [Tester Agent](agents/tester.md) - Test validator configuration

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
4. Use `PERFORM` to discard output (row counts, Tuples/Tuple, status messages) for DDL, DML, CALL, COMMIT, ROLLBACK, and EXECUTE when not capturing return values
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
- **PERFORM to discard output**: Use PERFORM for DDL, DML, CALL, COMMIT, ROLLBACK, and EXECUTE when discarding output (row counts, Tuples/Tuple, status messages)
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

The environment variable `VSQL` should encapsulate connection parameters:
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

### Reference Document Summaries

The `references/reference-summaries/` directory contains condensed versions of large reference documents. These summaries are designed to reduce context overhead for 128K context LLMs.

**Usage Rule:**
- **Agent configurations and Multi-Agent Quick Reference MUST reference summary versions** (e.g., `reference-summaries/generic-migration-summary.md`)
- **DO NOT reference full documents** (e.g., `generic-migration-guide.md`) in agent configurations or quick reference
- Load full documents only when summary is insufficient for complex scenarios

**Maintenance Rule:**
When a detailed reference document is updated, you MUST synchronize the corresponding summary document.

**File Correspondence (9 summaries):**

**Core Documents:**
- `generic-migration-summary.md` ← `generic-migration-guide.md`
- `sql-syntax-summary.md` ← `sql-syntax-reference.md`
- `data-types-summary.md` ← `data-types.md`
- `oltp-to-olap-summary.md` ← `oltp-to-olap-rewrite-guide.md`

**Stored Procedures and Functions:**
- `stored-procedures-summary.md` ← `stored-procedures-guide.md`
- `user-defined-sql-functions-summary.md` ← `user-defined-sql-functions-guide.md`

**Database-Specific Migration Guides:**
- `oracle-migration-summary.md` ← `oracle-migration.md`
- `db2-migration-summary.md` ← `db2-migration.md`
- `sqlserver-migration-summary.md` ← `sqlserver-migration.md`
- `postgresql-migration-summary.md` ← `postgresql-migration.md`
- `mysql-migration-summary.md` ← `mysql-migration.md`

**Summary Content Guidelines:**
- Include key mappings and most frequently used rules
- Use compact table format for quick reference
- Include all information needed for migration decisions
- Remove verbose examples and redundant content
- Target: ~10-20% of original document size
- **Exception:** Some concise reference documents (like `function-mapping.md`) are used directly without summaries

### Summary Version Update Principles

**Document Positioning:**
- **Full documents** are for humans, containing detailed examples and explanations
- **Summary versions** are for agents, containing only agent decision-making information

**What Summaries MUST Include:**
1. Core rules (MUST/MUST NEVER)
2. Key constraints
3. Important concepts
4. Common pitfalls
5. Key points
6. Function mapping tables
7. Data type mapping tables
8. Important syntax
9. Common complex scenario handling

**What Summaries Should Exclude:**
1. Examples (example code) — full documents have hyperlinks
2. Repetitive content (multiple emphases on the same point)
3. Detailed explanations (if core rules are already clear)
4. Background introduction (if not important for migration decisions)
5. Human-readable explanations

**What Summaries Can Reference:**
- Detailed examples via hyperlinks to full documents
- Complex examples via hyperlinks
- Background introduction via hyperlinks
- Detailed explanations via hyperlinks

**Maintenance Rule:**
- Every time a full document is updated, check if the summary version needs to sync
- If the full document adds new rules or constraints, the summary version must sync add
- If the full document adds new examples, the summary version doesn't need to sync (agents don't need)
- If the full document adds new detailed explanations, the summary version doesn't need to sync (agents don't need)

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

