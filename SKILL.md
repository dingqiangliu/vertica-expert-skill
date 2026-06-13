---
name: vertica-expert
description: Comprehensive skill for Vertica database migration and development. Includes SQL syntax reference, custom SQL function development, PL/vSQL stored procedure development, UDx custom function creation (C++, Python, Java, R), in-database machine learning (regression, classification, clustering, time series), performance optimization, and migration from Oracle, DB2, SQL Server, PostgreSQL, and MySQL. Use this skill for writing Vertica SQL, developing stored procedures, creating custom functions, implementing machine learning workflows, optimizing performance, or migrating from other databases. Features Multi-Agent Migration Workflow with Manager, Requester, Migrator, and Tester agents for large-scale migrations to ensure rule adherence and context management.
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
- Identify source database type (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
- Provide original SQL, procedures, or schema definitions
- Specify any performance requirements
- Include data volume and growth expectations

#### When to Use Multi-Agent Migration Workflow
**Use the Multi-Agent Migration Workflow when:**
- ✅ More than 1 source file
- ✅ Single source file exceeds 200 lines
- ✅ Contains multiple stored procedures or functions
- ✅ Single-agent mode frequently violates rules (reading entire files, skipping tests, etc.)
- ✅ Large-scale migrations requiring strict context management

**Do NOT use Multi-Agent Migration Workflow when:**
- ❌ Only 1 small file
- ❌ Simple table structure migration
- ❌ Quick syntax conversion tasks

**Multi-Agent Migration Workflow Overview:**
The Multi-Agent Migration Workflow uses four specialized agents to ensure rule adherence and prevent context overflow:

1. **Manager Agent (Main Session)**: **BASIC PERSONALITY: Strict process controller and coordinator WITHOUT migration knowledge**. **INITIALIZES BACKGROUND AGENTS AT STARTUP (Requester, Migrator, Tester) — agents persist across multiple tasks, communicates via SendMessage**. Controls workflow coordination, determines source database type (as a fact), dispatches tasks to agents (**🚫 ONLY obtains source file content from Requester Agent** — never from any other source), **🔍 STRICTLY VERIFIES Migrator's unit test results** (checks unit test was performed, logs are complete, no anomalies exist; REJECTS and requires redo if verification fails), coordinates testing, **🔍 STRICTLY VERIFIES Tester's functional/integration test results** (checks tests were performed, logs are complete, no anomalies exist, no false positives like errors ignored but reported as PASS; REJECTS and requires redo if verification fails), appends to target file. **ONLY reminds Migrator to unit test, does NOT provide any other migration decisions, rules, or hints.** **🚫 ONLY creates Requester, Migrator, and Tester agents — no other agents allowed.** **🚫 NEVER provides migration transformation rules or decisions to Migrator — Manager has NO migration expertise.** **🚫 NEVER re-spawns agents for each task — use SendMessage to send tasks to existing background agents, only re-initialize if agent crashes or becomes unresponsive.**
2. **Requester Agent (Sub-Agent)**: **Runs in BACKGROUND MODE** — initialized once, persists across multiple tasks, waits for tasks via SendMessage. Reads source files section-by-section (**EXCLUSIVE responsibility for file reading, NO migration knowledge**), **does NOT break objects or statements**, **groups consecutive DML statements on the same table**, **returns source code exactly as-is without any migration decisions or hints**, maintains file reading state across tasks
3. **Migrator Agent (Sub-Agent)**: **Runs in BACKGROUND MODE** — initialized once, persists across multiple tasks, waits for tasks via SendMessage. Receives source database type from Manager (as a fact), **decides which reference documents to load** (basic docs at startup, additional docs on-demand based on code), performs code transformation, applies one-to-one migration and OLTP→OLAP rewrites, unit tests using pre-configured VSQL (do NOT probe or guess VSQL content), reports unit test status with complete logs, cleans up after unit test. **Maintains loaded reference documents across tasks — do NOT reload.**
4. **Tester Agent (Sub-Agent)**: **Runs in BACKGROUND MODE** — initialized once, persists across multiple tasks, waits for tasks via SendMessage. Validates migrated code by executing it in a single VSQL call with autocommit enabled. Uses unified test method for all code: in one VSQL call, enable autocommit, execute code, verify no errors or warnings in logs, confirm data commits. Tests code as-is and reports failures honestly. Includes complete logs after each code snippet passes functional testing. Preserves all migrated objects during functional testing — only deletes test data or temporary objects added by Tester. **Clears test database and re-runs integration test from scratch after Migrator fixes** — when integration test fails and Migrator fixes the migration target files, Tester clears the entire test database and re-runs integration testing from scratch.

**Key Principle:** The **Migrator Agent** receives source database type from Manager (as a fact), **decides which reference documents to load** - basic docs at startup (generic-migration-guide, sql-syntax-reference, function-mapping, data-types), source-specific guide based on source database type, and additional docs on-demand based on code being migrated (e.g., oltp-to-olap-rewrite-guide only when code contains stored procedures). **The Manager, Requester, and Tester agents NEVER read migration reference documents** — they only read the [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md) to understand their roles and the workflow. This separation prevents context overflow and ensures clear role boundaries.

**Background Execution:** All agents (Requester, Migrator, Tester) run in **BACKGROUND MODE** — initialized once at startup, persist across multiple tasks, communicate with Manager via SendMessage. This eliminates repeated initialization overhead (skill loading, document loading, database connection). Manager monitors agent health and only re-initializes if agents crash or become unresponsive.

**Benefits:**

- ✅ Manager maintains workflow discipline without migration context overload
- ✅ Migrator focuses solely on code transformation with basic reference docs loaded at startup and additional docs loaded on-demand
- ✅ Tester provides independent verification of migrated code
- ✅ Each agent has smaller, focused context window
- ✅ Easier to debug and restart specific components
- ✅ **Agents persist across multiple tasks — no repeated initialization overhead**

**Reference Documentation (for Manager, Requester, and Tester - from vertica-expert skill):**
- [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md) - Complete architecture, workflow details, and implementation templates

**🚫 Manager, Requester, and Tester NEVER load these documents** (Migrator Agent only):
- [Generic Migration Guide](references/generic-migration-guide.md)
- [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md)
- Database-specific migration guides (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
- [SQL Syntax Reference](references/sql-syntax-reference.md)
- [Function Mapping Guide](references/function-mapping.md)
- [Data Types](references/data-types.md)
- [Stored Procedures Guide](references/stored-procedures-guide.md)
- [User-Defined SQL Functions Development Guide](references/user-defined-sql-functions-guide.md)

**Quick Start:**
To start a multi-agent migration, provide:
1. Source database type (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
2. Source files list (in dependency order)
3. Target file path
4. Vertica test database connection information (VSQL environment variable encapsulating connection parameters)

The Manager Agent will:
1. Read **ONLY** the [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md)
2. **NOT read migration reference documents** (Generic Migration Guide, OLTP/OLAP Rewrite, database-specific guides)
3. List migration requirements
4. Wait for user confirmation
5. **Initialize Requester, Migrator, and Tester agents ONCE in BACKGROUND MODE** — agents persist across multiple tasks, communicate via SendMessage
6. Execute two-phase migration cycle:

   **Phase 1: Migration & Functional Testing**
   Manager SENDMESSAGE to requester_agent → Requester READS source file (offset=N, limit=50) → RETURNS code snippet → Manager SENDMESSAGE to migrator_agent (with current_schema) → Migrator decides which reference documents to load → Migrator unit tests (up to 10 attempts) → **MANAGER VERIFIES UNIT TEST** → RECEIVE migrated code → Manager SENDMESSAGE to tester_agent (with current_schema) → FUNCTIONAL TEST (single VSQL call: enable autocommit, execute code, verify) → **MANAGER VERIFIES TEST RESULTS** → IF PASS → APPEND → IF FAIL → Manager SENDMESSAGE to migrator_agent to fix → RETEST

   **Phase 2: Integration Testing (after ALL code migrated)**
   Manager SENDMESSAGE to tester_agent: Clear test database completely → Execute ALL migrated files → Run integration test → **MANAGER VERIFIES INTEGRATION TEST** → IF PASS → Migration complete → IF FAIL → Tester reports failures with complete logs → Manager SENDMESSAGE to migrator_agent with error info and ALL migration target files → Migrator analyzes errors and fixes issues → After unit tests pass, Manager SENDMESSAGE to tester_agent to clear test database and re-run integration test → Repeat until integration test passes

#### Multi-Agent Migration Workflow (Recommended for Large Migrations)
**When to use:**
- Source files > 1 file OR
- Single file > 200 lines OR
- Multiple stored procedures/functions OR
- Single-agent approach has demonstrated context overflow issues

**Architecture:**
- **Manager Agent** (main session): **BASIC PERSONALITY: Strict process controller and coordinator WITHOUT migration knowledge**. **INITIALIZES BACKGROUND AGENTS AT STARTUP — agents persist across multiple tasks, communicates via SendMessage**. Controls workflow coordination, dispatches tasks, coordinates testing (**🚫 ONLY obtains source file content from Requester Agent** — never from any other source, **🚫 NEVER reads migration reference documents** — delegated to Migrator Agent, **🚫 ONLY creates Requester, Migrator, and Tester agents** — no other agents allowed, **🚫 NEVER provides migration transformation rules or decisions to Migrator** — Manager has NO migration expertise — see [Complete Migration Requirement](references/generic-migration-guide.md#1-complete-migration-requirement), [Sequential Processing Requirement](references/generic-migration-guide.md#2-sequential-processing-requirement), [Object Integrity Requirement](references/generic-migration-guide.md#3-object-integrity-requirement)), **🚫 NEVER re-spawns agents for each task — use SendMessage to send tasks to existing background agents**)
- **Requester Agent** (sub-agent): **Runs in BACKGROUND MODE** — initialized once, persists across multiple tasks, waits for tasks via SendMessage. Reads source files section-by-section (**EXCLUSIVE responsibility for file reading**), identifies complete objects, maintains file reading state across tasks
- **Migrator Agent** (sub-agent): **Runs in BACKGROUND MODE** — initialized once, persists across multiple tasks, waits for tasks via SendMessage. Loads basic reference docs at startup, loads additional docs on-demand, performs code transformation and unit test using pre-configured VSQL (do NOT probe or guess VSQL content). **Reports unit test status** — includes complete output logs when tests pass. **Cleans up after unit test** — deletes all migrated objects, test data, and temporary objects after unit testing to avoid affecting subsequent functional tests. **Maintains loaded reference documents across tasks — do NOT reload.**
- **Tester Agent** (sub-agent): **Runs in BACKGROUND MODE** — initialized once, persists across multiple tasks, waits for tasks via SendMessage. Independently tests migrated code using pre-configured VSQL (do NOT probe or guess VSQL content), provides pass/fail feedback. **Does NOT modify Manager's code** — tests code as-is and reports failures honestly. **Includes complete logs** — after each code snippet passes functional testing, includes the complete output logs from VSQL. **Preserves all migrated objects** during functional testing — only deletes test data or temporary objects added by Tester. **Clears test database and re-runs integration test from scratch after Migrator fixes** — when integration test fails and Migrator fixes the migration target files, Tester clears the entire test database and re-runs integration testing from scratch.

**Benefits:**
- Prevents context overflow (each agent has focused context)
- Enforces sequential processing rules (Requester specializes in file reading)
- Ensures every object is tested (dedicated Tester Agent)
- Loads reference documents once (Migrator Agent initialization)
- Clear separation of concerns (Manager coordinates, Requester reads, Migrator transforms, Tester validates)

**Reference:** [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md)

## Core Reference Sections

### 🚨 MANDATORY: Generic Migration Requirements (Migrator Agent ONLY)
- [Generic Migration Guide](references/generic-migration-guide.md) - **MANDATORY READING** for Migrator Agent
- [Migration Guides Overview](references/migration-guides-overview.md) - Guide hierarchy and usage instructions

### 🔄 OLTP to OLAP Rewrite (ESSENTIAL for Migrator Agent ONLY)
- [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md) - **ESSENTIAL** for Migrator Agent. Contains 5 rewrite patterns (adjacent DML merging, loop-DML→set-based SQL, cursor→window functions, function-call→join, recursive CTE) with before/after examples and a migration checklist.

### 🤖 Multi-Agent Migration Workflow (ALL Agents)
**For Manager, Requester, and Tester:**
- [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md) - Architecture, workflow details, and implementation templates

**🚫 Manager, Requester, and Tester NEVER load these documents:**
- [Generic Migration Guide](references/generic-migration-guide.md) (Migrator's responsibility)
- [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md) (Migrator's responsibility)
- Database-specific migration guides (Migrator's responsibility)

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
**Single-Agent Migration:**
- [Oracle to Vertica](references/oracle-migration.md) - Oracle migration following generic requirements
- [DB2 to Vertica](references/db2-migration.md) - DB2 migration following generic requirements
- [SQL Server to Vertica](references/sqlserver-migration.md) - SQL Server migration following generic requirements
- [PostgreSQL to Vertica](references/postgresql-migration.md) - PostgreSQL migration following generic requirements
- [MySQL to Vertica](references/mysql-migration.md) - MySQL migration following generic requirements

**Multi-Agent Migration Workflow (ALL Agents):**
- [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md) - Architecture, workflow details, and implementation templates

**🚫 These documents are ONLY loaded by Migrator Agent, NOT by Manager/Requester/Tester:**
- [Generic Migration Guide](references/generic-migration-guide.md)
- [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md)
- Database-specific migration guides
- [SQL Syntax Reference](references/sql-syntax-reference.md)
- [Function Mapping Guide](references/function-mapping.md)
- [Data Types](references/data-types.md)
- [Stored Procedures Guide](references/stored-procedures-guide.md)
- [User-Defined SQL Functions Guide](references/user-defined-sql-functions-guide.md)

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

### Example 5: Database Migration (Single-Agent)
**Input**: Oracle PL/SQL stored procedure for calculating customer lifetime value
**Output**: Converted Vertica PL/vSQL procedure with performance optimizations and best practices

### Example 6: Database Migration (Multi-Agent Workflow)
**Input**: Large Oracle database with 10+ source files, multiple stored procedures, views, and tables
**Output**: Complete migration using Multi-Agent Workflow:
1. Requester Agent reads source files section-by-section in alphabetical order
2. Manager coordinates workflow and dispatches objects to Migrator Agent
3. Migrator Agent transforms each object with basic reference docs loaded at startup and additional docs loaded on-demand
4. Tester Agent validates each migration in test environment
5. Manager appends passing objects to target file
6. Final integration test and migration report

**Process**: REQUEST → Requester READS → IDENTIFY → DISPATCH to Migrator → RECEIVE migrated code → TEST via Tester Agent → PASS → APPEND → REPEAT

### Example 7: Performance Optimization
**Input**: Slow SQL Server query with multiple joins taking 2+ minutes
**Output**: Optimized Vertica query with projection design, encoding strategies, and monitoring recommendations

## Best Practices

### Migration Best Practices
1. **Analyze First**: Use the workload analyzer to understand current performance
2. **Design Projections**: Create optimal projections before loading data
3. **Update Statistics**: Always run ANALYZE_STATISTICS after data loads
4. **Test Incrementally**: Migrate and test in small batches
5. **Monitor Performance**: Use system tables to track query performance

### Multi-Agent Migration Best Practices
1. **Use for Large Migrations**: Apply multi-agent workflow when source files > 1 or single file > 200 lines
2. **Manager Controls Flow**: Manager coordinates workflow and testing, dispatches tasks to Requester and Migrator agents, and coordinates testing via Tester Agent
3. **Requester Reads Source Files**: Requester Agent reads source files section-by-section using Read(offset=N, limit=50), ensuring compliance with [Complete Migration Requirement](references/generic-migration-guide.md#1-complete-migration-requirement), [Sequential Processing Requirement](references/generic-migration-guide.md#2-sequential-processing-requirement), and [Object Integrity Requirement](references/generic-migration-guide.md#3-object-integrity-requirement)
4. **Migrator Loads Reference Docs**: Migrator Agent loads basic reference documents at startup (Generic Migration Guide, SQL Syntax Reference, Function Mapping, Data Types, source-specific guide) and additional documents on-demand based on code being migrated
5. **Migrator Uses Pre-configured VSQL**: Migrator Agent uses the VSQL environment variable directly for unit testing — do NOT probe, inspect, or guess VSQL content
6. **Migrator Reports Unit Test Status**: After each code snippet migration, Migrator reports whether it passed unit testing and includes complete output logs (NOTICE, WARNING, ERROR, row counts, etc.) when tests pass
7. **Migrator Cleans Up After Unit Test**: After completing unit testing, Migrator deletes all migrated objects, test data, and temporary objects to avoid affecting subsequent functional tests
8. **Manager, Requester, and Tester Load Minimal Docs**: These agents **NEVER read migration reference documents** (Generic Migration Guide, OLTP/OLAP Rewrite, database-specific guides). They only read the [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md). Only Migrator Agent loads migration reference documents.
9. **Tester Uses Pre-configured VSQL**: Tester Agent uses the VSQL environment variable directly for testing — do NOT probe, inspect, or guess VSQL content
10. **Tester Does NOT Modify Manager's Code**: Tester Agent tests the code as-is — do NOT modify test code just to make it pass. Test rules must be strictly followed. Report failures honestly with detailed error messages.
11. **Tester Includes Complete Logs**: After each code snippet passes functional testing, Tester includes the complete output logs from VSQL (NOTICE, WARNING, ERROR messages, row counts, affected rows, return values, and any diagnostic information).
12. **Tester Preserves Migrated Objects**: During functional testing, do NOT delete schemas, tables, views, functions, procedures, sequences, or migrated data. These are dependencies for subsequent migrations. Only delete test data or temporary objects added by Tester.
13. **Tester Validates Everything**: Tester Agent tests every object, no skipping
14. **Fix Loop**: If test fails, Migrator fixes and Manager retests (up to 3 attempts)
15. **Document Failures**: Append failed migrations with detailed error documentation
16. **Integration Test Fix Workflow**: When integration test fails: (1) Tester reports failures with complete logs to Manager, (2) Manager forwards error info and ALL migration target files to Migrator, (3) Migrator analyzes errors and fixes issues on relevant target files and runs unit tests, (4) Manager instructs Tester to clear test database and re-run integration test from scratch
17. **Maintain Order**: Process files in alphabetical order, objects in source order
18. **Focused Responsibilities**: Each agent has focused responsibilities - Manager coordinates, Requester reads, Migrator transforms, Tester validates.
19. **Manager Verifies Migrator Unit Test**: Manager STRICTLY verifies Migrator's unit test results before accepting code. Checks: (1) unit test was actually performed, (2) logs are complete (NOTICE, WARNING, ERROR, row counts, return values), (3) no anomalies in logs. If verification fails, Manager REJECTS and requires Migrator to redo.
20. **Manager Verifies Tester Test Results**: Manager STRICTLY verifies Tester's functional/integration test results before appending to target file. Checks: (1) tests were actually performed, (2) logs are complete, (3) no WARNING or ERROR anomalies in logs, (4) no false positives (errors or warnings ignored but reported as PASS). If verification fails, Manager REJECTS and requires Tester to redo.
21. **Schema Prefix Compliance**: Migrator maintains `current_schema` context variable, updates it when encountering `USE dbname` statements, and returns it with migrated code. Manager saves this value and passes it to new Migrator instances when restarting.
22. **Background Agent Execution**: All agents (Requester, Migrator, Tester) run in **BACKGROUND MODE** — initialized once at startup, persist across multiple tasks, communicate with Manager via SendMessage. This eliminates repeated initialization overhead (skill loading, document loading, database connection). Manager monitors agent health and only re-initializes if agents crash or become unresponsive.

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

### Multi-Agent Migration Issues
- **Requester Context Overflow**: Restart Requester Agent with fresh context, reduce section size (limit=50), verify source file is accessible
- **Migrator Context Overflow**: Restart Migrator Agent with fresh context
- **Tester Connection Failure**: Check database connection, recreate Tester Agent
- **Communication Failure**: Retry up to 3 times, Manager takes over if needed
- **Test Failures Loop**: Maximum 3 fix attempts, then document and append with warnings

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
