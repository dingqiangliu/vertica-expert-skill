---
name: vertica-expert
description: Comprehensive skill for Vertica database migration and development. Includes SQL syntax reference, custom SQL function development, PL/vSQL stored procedure development, UDx custom function creation (C++, Python, Java, R), in-database machine learning (regression, classification, clustering, time series), performance optimization, and migration from Oracle, SQL Server, PostgreSQL, and MySQL. Use this skill for writing Vertica SQL, developing stored procedures, creating custom functions, implementing machine learning workflows, optimizing performance, or migrating from other databases.
---

# Vertica Expert

This skill provides comprehensive guidance for migrating from other database systems to Vertica and optimizing SQL queries, views, stored procedures, custom functions, and machine learning workflows for Vertica's columnar MPP architecture.

## ⚠️ HIGHEST PRIORITY REMINDER

**When migrating from other databases to Vertica: DO NOT EASILY ASSUME functionality is unsupported.**

- **Always first consult the comprehensive reference materials in this skill** before concluding that a feature doesn't exist
- **Always remember and apply checklist**: checklist in any guide is always very important
- **Vertica has extensive capabilities** - many functions and features have different names or syntax than other databases
- **When in doubt, construct simple test examples** to verify functionality using the VSQL testing framework documented in this skill
- **The function mapping guides contain 100+ equivalents** - what seems "unsupported" is often just named differently
- **Performance characteristics differ** - features may exist but work differently due to Vertica's columnar architecture
- **Check all reference sections**: data types, function mapping, stored procedures, UDx development, and ML capabilities

**Remember: If you can't find a direct equivalent, it doesn't mean it doesn't exist - it means you need to dig deeper into the documentation.**

## Quick Reference

### Database Migration Paths Supported
- **Oracle** → Vertica (PL/SQL to PL/vSQL)
- **DB2** → Vertica (PL/SQL to PL/vSQL)
- **SQL Server** → Vertica (T-SQL to Vertica SQL)
- **PostgreSQL** → Vertica (PL/pgSQL to PL/vSQL)
- **MySQL** → Vertica
- **Generic SQL** → Vertica optimizations

### Key Capabilities
- SQL syntax conversion and optimization
- Function mapping and replacement strategies
- Stored procedure migration and rewriting
- User-Defined Function (UDx) development
- Performance tuning and projection design
- Schema optimization for columnar storage
- **Machine Learning**: In-database predictive analytics and model training
- **Data Science**: End-to-end ML workflows within Vertica

## Getting Started

### 1. Vertica SQL Development
For writing new Vertica SQL queries:
- Provide your table schemas and requirements
- Specify performance needs (real-time vs batch)
- Include any existing queries to build upon

### 2. User-Defined SQL Function Development
For creating User-Defined SQL Functions:
- Describe the business logic or transformation needed
- Specify input parameters and their data types
- Define the return type and expected behavior
- Include examples of desired input/output
- Consider NULL handling and edge cases
- For complex logic requiring procedural code, consider stored procedures or UDx instead

User-Defined SQL Functions are ideal for:
- Simple data transformations and calculations
- NULL handling and data standardization
- Business rule encapsulation
- Functions that can be expressed in a single RETURN statement
### 3. Stored Procedure Development

For creating PL/vSQL procedures:
- Describe the business logic requirements
- Specify input/output parameters
- Include performance and error handling needs

### 4. Custom Function Development (UDx)
For developing User-Defined Extensions:
- Specify function type (scalar, aggregate, analytic, transform)
- Choose programming language (C++, Python, Java, R)
- Define input/output data types and requirements
- Consider performance and scalability needs

### 5. Machine Learning & Data Science
For implementing in-database machine learning:
- Specify algorithm type (regression, classification, clustering, time series)
- Provide training data schema and sample size
- Define target variable and feature columns
- Include performance requirements and evaluation metrics

### 6. Performance Optimization
For optimizing existing queries:
- Provide current SQL query and execution time
- Share table schemas, sizes, and data distribution
- Specify performance requirements and SLAs
- Include current projection designs if available

### 7. Database Migration
For migrating from other databases:
- Identify source database type (Oracle, SQL Server, PostgreSQL, MySQL)
- Provide original SQL, procedures, or schema definitions
- Specify any performance requirements
- Include data volume and growth expectations

## Core Reference Sections

### 🚨 MANDATORY: Generic Migration Requirements
- [Generic Migration Guide](references/generic-migration-guide.md) - **MANDATORY READING** for ALL database migrations
- [Migration Guides Overview](references/migration-guides-overview.md) - Guide hierarchy and usage instructions

### 🔄 OLTP to OLAP Rewrite (ESSENTIAL for ALL Migrations)
- [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md) - **ESSENTIAL** for ALL database migrations. Contains 5 rewrite patterns (adjacent DML merging, loop-DML→set-based SQL, cursor→window functions, function-call→join, recursive CTE) with before/after examples and a migration checklist.

### SQL Syntax and Development
- [SQL Syntax Reference](references/sql-syntax-reference.md) - Comprehensive Vertica SQL syntax
- [Data Types](references/data-types.md) - Data type mapping and optimization
- [Function Mapping Guide](references/function-mapping.md) - Function conversion across databases

### User-Defined SQL Functions and Programming

- [User-Defined SQL Functions Development Guide](references/user-defined-sql-functions-guide.md) - Custom function development in pure SQL

### Stored Procedures and Programming

- [Stored Procedures Guide](references/stored-procedures-guide.md) - PL/vSQL development

### User-Defined Functions and Programming

- [UDx Development Guide](references/udx-development-guide.md) - Custom function development in C++, Python, Java or R

### Machine Learning and Data Science
- [Machine Learning Guide](references/machine-learning.md) - In-database ML algorithms and workflows
- [ML Function Mapping](references/ml-function-mapping.md) - Cross-database ML function equivalents

### Performance and Optimization
- [Query Optimization](references/query-optimization.md) - Performance tuning strategies

### Migration and Conversion (All Follow Generic Migration Requirements)
- [Oracle to Vertica](references/oracle-migration.md) - Oracle migration following generic requirements
- [DB2 to Vertica](references/db2-migration.md) - DB2 migration following generic requirements
- [SQL Server to Vertica](references/sqlserver-migration.md) - SQL Server migration following generic requirements
- [PostgreSQL to Vertica](references/postgresql-migration.md) - PostgreSQL migration following generic requirements
- [MySQL to Vertica](references/mysql-migration.md) - MySQL migration following generic requirements

## Examples

### Example 1: Vertica SQL Development
**Input**: Need to create a complex analytical query for customer segmentation
**Output**: Optimized SQL using analytic functions, proper JOINs, and projection recommendations

### Example 2: PL/vSQL Stored Procedure Development
**Input**: Business requirement for automated monthly reporting with error handling
**Output**: Complete PL/vSQL procedure with transaction management, logging, and exception handling

### Example 3: Custom UDx Development
**Input**: Need for a custom aggregate function to calculate weighted averages
**Output**: C++ UDx implementation with factory class, performance optimization, and usage examples

### Example 4: Machine Learning Implementation
**Input**: Customer churn prediction using historical data
**Output**: Complete ML pipeline with data preparation, XGBoost model training, evaluation, and deployment

### Example 5: Database Migration
**Input**: Oracle PL/SQL stored procedure for calculating customer lifetime value
**Output**: Converted Vertica PL/vSQL procedure with performance optimizations and best practices

### Example 6: Performance Optimization
**Input**: Slow SQL Server query with multiple joins taking 2+ minutes
**Output**: Optimized Vertica query with projection design, encoding strategies, and monitoring recommendations

## Best Practices

### Migration Best Practices
1. **Analyze First**: Use the workload analyzer to understand current performance
2. **Design Projections**: Create optimal projections before loading data
3. **Update Statistics**: Always run ANALYZE_STATISTICS after data loads
4. **Test Incrementally**: Migrate and test in small batches
5. **Monitor Performance**: Use system tables to track query performance

### Machine Learning Best Practices
1. **Data Quality**: Ensure clean, properly formatted training data
2. **Feature Engineering**: Create meaningful features for model performance
3. **Model Validation**: Use cross-validation and proper train/test splits
4. **Performance Monitoring**: Track model accuracy and drift over time
5. **Resource Management**: Use appropriate resource pools for ML workloads

### Optimization Best Practices
1. **Use Appropriate Encoding**: Match encoding schemes to data characteristics
2. **Design for Columnar**: Structure queries to leverage columnar storage
3. **Leverage Analytic Functions**: Replace procedural logic with set-based operations
4. **Optimize Data Types**: Use the smallest appropriate data type
5. **Regular Maintenance**: Update statistics and monitor query events

## Tools and Utilities

This skill provides comprehensive reference documentation and examples for all Vertica development and migration tasks.

## Troubleshooting

### Common Migration Issues
- **Data Type Mismatches**: Check type compatibility and use explicit casting
- **Performance Degradation**: Review query plans and projection design
- **Function Incompatibilities**: Use the function mapping guide for alternatives
- **Transaction Issues**: Understand Vertica's transaction model differences

### Machine Learning Issues
- **Model Convergence**: Check data quality and adjust algorithm parameters
- **Memory Errors**: Increase resource pool memory for large datasets
- **Performance Issues**: Optimize data projections and feature selection
- **Prediction Accuracy**: Validate model assumptions and feature engineering

### Performance Issues
- **Slow Queries**: Check for missing statistics, suboptimal projections
- **Memory Issues**: Review resource pool settings and query complexity
- **Data Skew**: Use directed queries and review segmentation strategies

## System Tables Reference

Key system tables for monitoring and troubleshooting:

- `v_catalog.tables` - Table metadata
- `v_catalog.views` - View information
- `v_catalog.columns` - Column information
- `v_catalog.user_procedures` - User procedure information including stored procedures
- `v_monitor.query_events` - Query performance events
- `v_monitor.query_profiles` - Detailed query execution information
- `v_monitor.projection_storage` - Projection storage and usage

## Testing SQL and Stored Procedures

All SQL examples and stored procedures in this skill can be tested using the VSQL command-line tool.

### VSQL Testing Setup

The environment variable `VSQL` has been set already, which contains the vsql connection parameters. You can leverage VSQL to run SQL immediately.

**Important Autocommit Behavior**: By default, vsql has **autocommit OFF** for interactive sessions. For testing, either:

- Enable autocommit: `SET SESSION AUTOCOMMIT TO ON;`
- Include explicit COMMIT statements after data modifications

**Important Session Behavior**: Each `$VSQL -c` command creates a new session. For data persistence across multiple commands, either:

1. Use explicit COMMIT statements in DML commands, or
2. Use here document syntax for multi-statement transactions

#### **Checking Object Availability:**

- Schema: `$VSQL -c "\dn schema_name"`
- Table: `$VSQL -c "\dt table_name"`
- View: `$VSQL -c "\dt view_name"`
- Projection: `$VSQL -c "\dj projection_name"`
- Function: `$VSQL -c "\df function_name"`

**Additional VSQL Options:**

- Run SQL file: `$VSQL -f script.sql`
- Interactive mode: `$VSQL`
- Enable timing: `$VSQL -i`

### VSQL Testing Methods

#### Method 1: Individual Commands with Explicit COMMIT

```bash
# Test connectivity
$VSQL -c "SELECT VERSION(), CURRENT_DATE, USER;"

# Test table creation
$VSQL -c "CREATE TABLE test_migration (id INTEGER, name VARCHAR(50));"

# Test data insertion with explicit COMMIT
$VSQL -c "INSERT INTO test_migration VALUES (1, 'test'); COMMIT;"

# Test data retrieval
$VSQL -c "SELECT * FROM test_migration;"

# Clean up
$VSQL -c "DROP TABLE test_migration CASCADE;"
```

#### Method 2: Multi-Statement Transaction (Recommended)

```bash
# Test complete workflow in single session
$VSQL<<-'EOF'
SET SESSION AUTOCOMMIT TO ON;

# Test table creation
CREATE TABLE test_migration (id INTEGER, name VARCHAR(50));

# Test data insertion
INSERT INTO test_migration VALUES (1, 'test');

# Test data retrieval
SELECT * FROM test_migration;

# Clean up
DROP TABLE test_migration CASCADE;
EOF

# Test stored procedures
$VSQL<<-'EOF'
CREATE OR REPLACE PROCEDURE test_migration_proc() AS $$
BEGIN
    RAISE NOTICE 'Migration test successful';
END;
$$
EOF

# Call procedure
$VSQL -c "CALL test_migration_proc();"

# Clean up procedure
$VSQL -c "DROP PROCEDURE test_migration_proc();"
```

**Key Benefits of Here Document Syntax:**
- Avoid escaping special characters like `$` and `"`
- Maintain SQL code formatting and readability
- Ideal for stored procedures with `$$` delimiters
- Allows multiple statements in a single session
- Autocommit settings persist across all statements

### Clean Test Database

Use this PL/vSQL anonymous block to drop all user-created objects (procedures, functions, views, tables, sequences). Excludes system schemas.

```bash
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
    raise notice '%', sql;
    perform execute sql;
  end loop;
end;
$$;
EOF
```

**Notes:**

- Uses `CASCADE` for tables and views to handle dependencies.
- `RAISE NOTICE` prints each DROP statement before execution.
- Excludes the `isOrContains` built-in function.
- Only drops SQL functions (identified by `function_definition ILIKE 'return%'`), not C++/Java UDx functions.

## Version Compatibility

This skill covers Vertica versions 9.x through 24.x, with specific notes for:
- **Eon Mode** features and considerations
- **New function additions** in recent versions
- **Deprecated features** and migration paths
- **Performance improvements** in newer releases

For specific version-related questions, always specify your Vertica version for the most accurate guidance.
