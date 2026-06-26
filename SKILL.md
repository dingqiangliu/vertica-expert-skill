---
name: vertica-expert
description: Comprehensive skill for Vertica database migration and development. Includes SQL syntax reference, custom SQL function development, PL/vSQL stored procedure development, UDx custom function creation (C++, Python, Java, R), in-database machine learning (regression, classification, clustering, time series), performance optimization, and migration from Oracle, DB2, SQL Server, PostgreSQL, MySQL, and Teradata. Use this skill for writing Vertica SQL, developing stored procedures, creating custom functions, implementing machine learning workflows, optimizing performance, or migrating from other databases. Features Multi-Agent Migration Workflow with Manager, Requester, Migrator, and Tester agents for large-scale migrations to ensure rule adherence and context management.
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
- **SEARCH before concluding unsupported**: When a loaded summary doesn't fully cover your scenario, use `grep -rn "keyword" references/ --include="*.md"` to search ALL reference files — the answer is often in a full document section or a different summary
- **Full documents fill the gaps**: Summaries cover ~95% of scenarios. When a summary has the rules but not a complete example, load the relevant full document section with `Read offset=N limit=M` (NOT the entire file)

**Remember: If you can't find a direct equivalent, it doesn't mean it doesn't exist - it means you need to dig deeper into the documentation.**

## 🚫 GLOBAL PROHIBITION: NO FULL FILE READS FOR MIGRATION TASKS 🚫

**⚠️ ABSOLUTE RULE ⚠️**

**For ANY migration task (Oracle, DB2, SQL Server, PostgreSQL, MySQL, Teradata → Vertica):**
- **NEVER READ THE ENTIRE SOURCE FILE IN ONE GO** - this applies to ALL migration workflows
- **NEVER LOAD FULL FILE CONTENT INTO CONTEXT** before understanding the scope

**This rule applies BEFORE entering any migration workflow branch.**

**Enforcement:**
- If user says "migrate", "convert", "transform" + database name → this rule activates immediately
- Violation = reading entire file content at once (instead of using grep for analysis or reading section by section)
- Correct approaches:
  - **General Migration Workflow**: Use grep to analyze, then read section by section
  - **Multi-Agent Workflow**: Requester reads section by section (limit=50), never loads entire file

## Quick Reference

### Database Migration Paths Supported
- **Oracle** → Vertica (PL/SQL to PL/vSQL)
- **DB2** → Vertica (PL/SQL to PL/vSQL)
- **SQL Server** → Vertica (T-SQL to Vertica SQL)
- **PostgreSQL** → Vertica (PL/pgSQL to PL/vSQL)
- **MySQL** → Vertica
- **Teradata** → Vertica (SPL to PL/vSQL, BTEQ to VSQL)
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

**Getting Started:**

- Identify source database type (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
- Provide original SQL, procedures, or schema definitions

> **⚠️ WORKFLOW SELECTION ⚠️**
>
> **Step 0: ANALYZE SOURCE FILES (MANDATORY - ALL WORKFLOWS)**
>
> Before entering ANY migration workflow, you MUST understand the scope:
> ```bash
> # Step 0a: Get file size (acceptable - metadata only)
> wc -l source_file.sql  # Count lines to determine workflow
>
> # Step 0b: Identify object types (DO NOT READ CONTENT)
> grep -n "CREATE" source_file.sql  # Find CREATE statements
> grep -n "CURSOR\|LOOP\|FETCH" source_file.sql  # Find OLTP patterns
> grep -n "INSERT\|UPDATE\|DELETE\|MERGE" source_file.sql  # Find DML types
> ```
>
> **PURPOSE**: Determine WHICH WORKFLOW to use (General or Multi-Agent).
>
> **IMPORTANT**: Step 0 determines the WORKFLOW ONLY, NOT which documents to load.
> - Document loading depends on your ROLE, not file content
> - If you are Manager in Multi-Agent Workflow: Load ONLY multi-agent-migration-guide.md
> - If you are in General Workflow: Load documents as specified in that section
>
> **ACCEPTABLE OUTPUT**:
> - "File has 1000 lines → Use Multi-Agent Workflow (>200 lines)"
> - "File has 150 lines → Use General Migration Workflow (<200 lines)"
> - "File contains tables, views, and stored procedures"
> - "File has cursor loops and row-by-row DML"
> - "File contains INSERT, UPDATE, DELETE statements"
>
> **UNACCEPTABLE ACTIONS**:
> - ❌ Reading the file with Read tool
> - ❌ Loading file content into context
> - ❌ Running `head`, `tail`, `cat`, or any command that displays file content
> - ❌ Analyzing specific table structures or procedure logic
> - ❌ Reading code or business logic
>
> **Default**: General Migration Workflow (Single-Agent) - for small files, simple migrations
>
> **Use Multi-Agent Workflow when**:
> - Explicitly requested
> - Files > 1 file OR single file > 200 lines
>

#### General Migration Workflow (Single-Agent)

**When to Use (Default for ALL migration tasks):**
- **Default workflow** for any database migration task (unless explicitly asking for Multi-Agent)
- Only 1 small file
- Simple table structure migration
- Quick syntax conversion tasks
- Simple stored procedure or function migration

**⚠️ CRITICAL EXECUTION ORDER ⚠️**

**MUST** complete Step 0 (from workflow selection above) **BEFORE** proceeding.

**Process:**
1. **Complete Step 0**: ANALYZE SOURCE FILES (MANDATORY - ALL WORKFLOWS) - see above
2. **Load** basic reference documents at startup (from the vertica-expert skill):
   - [Generic Migration Guide](references/reference-summaries/generic-migration-summary.md) - **MANDATORY**
   - [SQL Syntax Reference](references/reference-summaries/sql-syntax-summary.md)
   - [Function Mapping Guide](references/function-mapping.md)
   - [Data Type Mapping Guide](references/data-type-mapping.md)
   - Source-specific Migration Guide (based on source database type, from the vertica-expert skill):
     - [Oracle Migration Guide](references/reference-summaries/oracle-migration-summary.md)
     - [DB2 Migration Guide](references/reference-summaries/db2-migration-summary.md)
     - [SQL Server Migration Guide](references/reference-summaries/sqlserver-migration-summary.md)
     - [PostgreSQL Migration Guide](references/reference-summaries/postgresql-migration-summary.md)
     - [MySQL Migration Guide](references/reference-summaries/mysql-migration-summary.md)
    - [Teradata Migration Guide](references/reference-summaries/teradata-migration-summary.md)
3. **Load additional documents on-demand** (only when needed, from the vertica-expert skill):
   - [OLTP to OLAP Rewrite Guide](references/reference-summaries/oltp-to-olap-summary.md) — ONLY for stored procedures or adjacent single-row DML
   - [Stored Procedures Guide](references/reference-summaries/stored-procedures-summary.md) — ONLY for stored procedures
   - [User-Defined SQL Functions Guide](references/user-defined-sql-functions-guide.md) — ONLY for user-defined SQL functions
4. **When stuck on a migration problem** (per HIGHEST PRIORITY REMINDER):
   a. **Search all references**: `grep -rn "keyword" references/ --include="*.md"` — finds answers with zero context cost
   b. **If found in a summary**: read that section of the summary
   c. **If found in a full doc**: locate section via `grep -n "^## \|^### " references/<doc>.md`, then load ONLY that section with `Read offset=N limit=M`
   d. **If NOT found anywhere**: test in VSQL to verify whether the feature is truly unsupported
   e. **NEVER give up after checking only one document** — the HIGHEST PRIORITY REMINDER says dig deeper
5. **Read** source files section by section (ONLY after steps 1-4 are complete)
6. **Convert** code following generic migration requirements:
   - One-to-one mapping: tables→tables, views→views, procedures→procedures
   - Rewrite OLTP→OLAP patterns (cursors, row-by-row DML)
   - Preserve ALL logic — never simplify or remove code
7. **Test** each object immediately using single VSQL call with `SET SESSION AUTOCOMMIT TO ON;`
8. **Append** migrated code to target file after test passes
9. **Repeat** for each object: READ → IDENTIFY → MIGRATE → TEST → PASS → APPEND
10. **Clean up** test environment **ONLY AFTER** all source files have been processed

**Key Rules:**
- Keep code intact — NEVER split procedures, functions, or statements
- **DO NOT DROP** migrated objects or data after individual testing — subsequent migrations may depend on them
- Use single $VSQL call with `SET SESSION AUTOCOMMIT TO ON;`
- Check COMPLETE logs (NOTICE, WARNING, ERROR, row counts, return values)
- Process files in alphabetical order, objects in source order (never reorder)
- Report test status with complete logs when tests pass

#### Multi-Agent Migration Workflow

**When to Use:**
- Source files > 1 file OR single file > 200 lines
- Large-scale migrations requiring strict context management

**⚠️ CRITICAL: If you are not clear about your role, you are the Manager agent.**

**Process:**
1. **Confirm** your role (DO NOT SKIP) - answer this question BEFORE doing anything else:
   - Are you coordinating the workflow and verifying results? → **STOP HERE, you are Manager**
   - Are you reading source files section-by-section? → You are Requester
   - Are you transforming code and unit testing? → You are Migrator
   - Are you validating migrated code? → You are Tester
   - **If you cannot clearly identify as Requester/Migrator/Tester, you MUST be Manager**

2. **Analyze** source files (MANAGER ONLY):
   - **Manager**: Complete the shared Step 0 above to determine workflow and documents
   - **Subagents**: DO NOT analyze source files - your config files will be auto-initialized
3. **Read** the Multi-Agent Migration Guide:
   - **Manager**: Read [references/multi-agent-migration-guide.md](references/multi-agent-migration-guide.md) BEFORE spawning any subagents
   - **Subagents**: Your config files are auto-initialized; do NOT read other agents' configs
4. **Commit** to Multi-Agent Workflow (MANAGER ONLY):
   - **Manager**: Once you start Multi-Agent Workflow, you MUST continue with it
   - **NEVER switch to General Migration Workflow** when subagents seem unreliable
   - **Follow Agent Lifecycle Management**: Wait → Retry → Re-initialize → Resume
   - **Direct execution in main session WILL cause context overflow and rule violations**
   - **SAVE STATE after EVERY task** - Save critical state to `manager_state.md` (in current working directory) after each interaction with any agent. Do NOT wait for compaction.
   - **🚨 If subagent reports Fatal API Error (output token limit exceeded, context overflow, agent crash)**: Re-initialize agent immediately. Do NOT retry old agent. Do NOT attempt the task yourself. Spawn fresh agent → send same task → continue.
   - **If subagent reports Temporary API Error (timeout, HTTP 500)**: Retry up to 3 times with same agent, then re-initialize if still failing.

**Your Identity (Manager):**
- Role: Coordinator
- Responsibility: Manage workflow and verify results
- **NO migration knowledge** (by design)
- **NEVER switch to General Migration Workflow** - When subagents are unreliable, follow Agent Lifecycle Management (wait → retry → re-initialize → resume). NEVER execute migration tasks directly in main session.
- **SAVE STATE after EVERY task** - Save critical state to `manager_state.md` (in current working directory) after each interaction with any agent. Do NOT wait for compaction.

---

**Workflow Overview:**
1. Manager coordinates workflow and verifies results
2. Requester reads source files section-by-section
3. Migrator transforms code and unit tests
4. Tester validates functionality

**Agent Responsibilities (each agent reads ONLY its own documents):**

| Agent | Role | Reads | Does NOT Read | State |
|-------|------|-------|---------------|-------|
| **Manager** | Coordinator | [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md) | Migration docs, source files, subagent configs | **Stateful - saves state after EVERY task** |
| **Requester** | File Reader | | Migration docs, other configs | Stateless |
| **Migrator** | Code Transformer | migration docs | Source files, other configs | Stateless |
| **Tester** | Validator | | Migration docs, source files, other configs | Stateless |

**Migrator's Migration Documents (Migrator ONLY, from the vertica-expert skill):**

- **Load at Startup:**
  - [Generic Migration Guide](references/reference-summaries/generic-migration-summary.md) - **MANDATORY**
  - [SQL Syntax Reference](references/reference-summaries/sql-syntax-summary.md)
  - [Function Mapping Guide](references/function-mapping.md)
  - [Data Type Mapping Guide](references/data-type-mapping.md)
  - Source-specific Migration Guide:
    - [Oracle Migration Guide](references/reference-summaries/oracle-migration-summary.md)
    - [DB2 Migration Guide](references/reference-summaries/db2-migration-summary.md)
    - [SQL Server Migration Guide](references/reference-summaries/sqlserver-migration-summary.md)
    - [PostgreSQL Migration Guide](references/reference-summaries/postgresql-migration-summary.md)
    - [MySQL Migration Guide](references/reference-summaries/mysql-migration-summary.md)
    - [Teradata Migration Guide](references/reference-summaries/teradata-migration-summary.md)

- **Load On-Demand:**
  - [OLTP to OLAP Rewrite Guide](references/reference-summaries/oltp-to-olap-summary.md) — ONLY for stored procedures or adjacent single-row DML
  - [Stored Procedures Guide](references/reference-summaries/stored-procedures-summary.md) — ONLY for stored procedures
  - [User-Defined SQL Functions Guide](references/user-defined-sql-functions-guide.md) — ONLY for user-defined SQL functions

**Two-Phase Migration Cycle:**
- **Phase 1**: Requester READS → Migrator TRANSFORMS + unit tests → **MANAGER VERIFIES** → Tester FUNCTIONAL TESTS → **MANAGER VERIFIES** → APPEND (or fix loop)
- **Phase 2**: Tester CLEARS database → EXECUTES all files → INTEGRATION TEST → **MANAGER VERIFIES** → Complete (or fix loop)

**Manager State Management:**
- **Manager saves state after EVERY task** - Save critical state to `manager_state.md` (in current working directory) after each interaction with any agent
- **Do NOT wait for compaction** - Proactively save state to prevent context loss
- **Subagents are stateless** - They do NOT need to save state; Manager handles all state management

**Self-Awareness Check (MANDATORY for Manager)**

If you are the Manager, answer these questions BEFORE proceeding. This is a hard requirement to ensure role clarity:

  **Q1: What is your role?**
  > "I am the Manager agent. My role is to coordinate the workflow and verify results."
  
  **Q2: What are your responsibilities?**
  > "My responsibilities are:
  > - Coordinate workflow and distribute tasks to subagents
  > - Verify test results from Migrator and Tester
  > - Save state to manager_state.md after every task
  > - NEVER read source files or make migration decisions"
  
  **Q3: What are you FORBIDDEN from doing?**
  > "I am forbidden from:
  > - Reading source files (that's Requester's job)
  > - Making migration decisions or transforming code (that's Migrator's job)
  > - Loading migration reference documents (generic-migration-guide, sql-syntax, function-mapping, data-type-mapping, oracle-migration, etc.)
  > - Reading ANY file in references/ or reference-summaries/ EXCEPT multi-agent-migration-guide.md"
  
  **Q4: What is the ONLY reference document you should read?**
  > "I should ONLY read: multi-agent-migration-guide.md"

**If you cannot answer all 4 questions correctly, STOP and re-read the Multi-Agent Migration Workflow section.**

#### Quick Start
Provide: (1) Source database type, (2) Source files list, (3) Target file path

## Core Reference Sections

### Migration Reference Documents

**Generic Migration (MANDATORY for all migrations):**
- [Generic Migration Guide](references/reference-summaries/generic-migration-summary.md) - **MANDATORY READING** - Complete migration requirements, sequential processing, object integrity
- [Migration Guides Overview](references/migration-guides-overview.md) - Guide hierarchy and usage instructions

**Database-Specific Migration:**
- [Oracle Migration Guide](references/reference-summaries/oracle-migration-summary.md) - Oracle PL/SQL to PL/vSQL
- [DB2 Migration Guide](references/reference-summaries/db2-migration-summary.md) - DB2 to Vertica
- [SQL Server Migration Guide](references/reference-summaries/sqlserver-migration-summary.md) - T-SQL to Vertica SQL
- [PostgreSQL Migration Guide](references/reference-summaries/postgresql-migration-summary.md) - PL/pgSQL to PL/vSQL
- [MySQL Migration Guide](references/reference-summaries/mysql-migration-summary.md) - MySQL to Vertica
- [Teradata Migration Guide](references/reference-summaries/teradata-migration-summary.md) - Teradata SPL to PL/vSQL

**OLTP to OLAP Rewrite:**
- [OLTP to OLAP Rewrite Guide](references/reference-summaries/oltp-to-olap-summary.md) - **ESSENTIAL** for stored procedures  or adjacent single-row DML. Contains 5 rewrite patterns with before/after examples

### SQL Development Reference

- [SQL Syntax Reference](references/reference-summaries/sql-syntax-summary.md) - Comprehensive Vertica SQL syntax
- [Data Type Mapping Guide](references/data-type-mapping.md) - Data type mapping and optimization
- [Function Mapping Guide](references/function-mapping.md) - Function conversion across databases

### Programming Reference

**Stored Procedures:**
- [Stored Procedures Guide](references/reference-summaries/stored-procedures-summary.md) - PL/vSQL development

**User-Defined Functions:**
- [User-Defined SQL Functions Guide](references/user-defined-sql-functions-guide.md) - Custom function development in pure SQL
- [UDx Development Guide](references/udx-development-guide.md) - Custom function development in C++, Python, Java or R

### Machine Learning and Optimization

- [Machine Learning Guide](references/machine-learning.md) - In-database ML algorithms and workflows
- [ML Function Mapping](references/ml-function-mapping.md) - Cross-database ML function equivalents
- [Query Optimization](references/query-optimization.md) - Performance tuning strategies

## Examples

1. **Vertica SQL Development**: Analytic queries with proper JOINs and projection recommendations
2. **PL/vSQL Stored Procedures**: Transaction management, logging, and exception handling
3. **Custom UDx Development**: C++ implementations with factory classes and performance optimization
4. **Machine Learning**: Data preparation, XGBoost model training, evaluation, and deployment
5. **Single-Agent Migration**: Oracle PL/SQL to Vertica PL/vSQL conversion
6. **Multi-Agent Migration**: Large-scale migration with coordinated agent workflow
7. **Performance Optimization**: Projection design, encoding strategies, and monitoring

## Best Practices

### Migration Best Practices
1. **Analyze First**: Use the workload analyzer to understand current performance
2. **Design Projections**: Create optimal projections before loading data
3. **Update Statistics**: Always run ANALYZE_STATISTICS after data loads
4. **Test Incrementally**: Migrate and test in small batches
5. **Monitor Performance**: Use system tables to track query performance

### Multi-Agent Migration Workflow Best Practices

**When to Use:**
- Source files > 1 file OR single file > 200 lines
- Single-agent approach has demonstrated context overflow

**Key Principles:**
- Manager coordinates, Requester reads, Migrator transforms, Tester validates
- Migrator loads basic docs at startup, additional docs on-demand
- All agents use single VSQL call with `SET SESSION AUTOCOMMIT TO ON;`
- Manager strictly verifies all test results before proceeding

**Critical Rules:**
- Migrator unit tests every object and includes complete logs
- Tester tests code as-is, never modifies it
- Manager verifies unit tests (logs complete, no anomalies) and functional tests (no errors/warnings, no false positives)
- Migrator cleans up after unit test; Tester preserves migrated objects during functional test
- Tester clears database and re-runs integration test from scratch after fixes
- Process files in alphabetical order, objects in source order
- Fix loop: up to 3 attempts, then document and append with warnings

**For complete details:** See [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md)

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

### Problem-Solving Strategy (When Stuck)

When a migration step fails and the loaded documents don't resolve it:
1. **Search**: `grep -rn "keyword" references/ --include="*.md"` across all reference files
2. **Targeted load**: Use `grep -n "^## \|^### "` to find section line numbers, then `Read offset=N limit=M`
3. **Verify**: Test the solution in VSQL before applying to the migration
4. **Document**: Note which document/section solved the issue for future reference

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

The environment variable `$VSQL` has been set already, which contains the vsql connection parameters. You can leverage $VSQL to run SQL immediately.

**Important Autocommit Behavior**: By default, vsql has **autocommit OFF** for interactive sessions, meaning you must explicitly COMMIT transactions for data modifications to persist. This is different from client libraries which have autocommit ON by default.

To enable autocommit in vsql (recommended for testing):
```sql
SET SESSION AUTOCOMMIT TO ON;
```

To disable autocommit (vsql default behavior):
```sql
SET SESSION AUTOCOMMIT TO OFF;
```

**Important Session Behavior**: Each `$VSQL -c` command creates a new session. For data persistence across multiple commands, either:

1. Use explicit COMMIT statements in DML commands, or
2. Use here document syntax for multi-statement transactions

**Quick Test Pattern:**
```bash
$VSQL<<-'EOF'
SET SESSION AUTOCOMMIT TO ON;
-- Your SQL here
EOF
```

**Key Rules:**
- Use single $VSQL call with `SET SESSION AUTOCOMMIT TO ON;`
- For multi-statement transactions, use here document syntax (avoids escaping `$` and `"`)
- Enable autocommit for testing: `SET SESSION AUTOCOMMIT TO ON;`

**Common VSQL Commands:**
```bash
# Check object availability
$VSQL -c "\dn schema_name"      # Schema
$VSQL -c "\dt table_name"      # Table
$VSQL -c "\dt view_name"       # View
$VSQL -c "\dj projection_name"  # Projection
$VSQL -c "\df function_name"   # Function

# Run SQL file
$VSQL -f script.sql

# Interactive mode
$VSQL

# Enable timing
$VSQL -i
```

**Testing Methods:**

```bash
# Method 1: Individual commands with explicit COMMIT
$VSQL -c "CREATE TABLE test (id INTEGER, name VARCHAR(50));"
$VSQL -c "INSERT INTO test VALUES (1, 'example'); COMMIT;"
$VSQL -c "SELECT * FROM test;"
$VSQL -c "DROP TABLE test CASCADE;"

# Method 2: Multi-statement transaction (Recommended)
$VSQL<<-'EOF'
SET SESSION AUTOCOMMIT TO ON;
CREATE TABLE test (id INTEGER, name VARCHAR(50));
INSERT INTO test VALUES (1, 'example');
SELECT * FROM test;
DROP TABLE test CASCADE;
EOF

# Test stored procedures
$VSQL<<-'EOF'
CREATE OR REPLACE PROCEDURE test_proc() AS $$
BEGIN
    RAISE NOTICE 'Test successful';
END;
$$
EOF
$VSQL -c "CALL test_proc();"
$VSQL -c "DROP PROCEDURE test_proc();"
```

**VSQL Options:**
- Run SQL file: `$VSQL -f script.sql`
- Enable timing: `$VSQL -i`


### Clean Test Database (REQUIRED for Tester subagent)

Use this PL/vSQL anonymous block to drop all user-created objects (procedures, functions, views, tables, sequences). Excludes system schemas.

```bash
$VSQL<<-'EOF'
DO $$
DECLARE sql varchar;
BEGIN
  FOR sql IN QUERY
    -- drop all user stored procedures
    SELECT 'DROP PROCEDURE IF EXISTS '||schema_name||'.'||procedure_name||'('|| procedure_arguments||');' as sql FROM user_procedures WHERE schema_name NOT IN ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    UNION ALL
    -- drop all user SQL functions
    SELECT 'DROP FUNCTION IF EXISTS '||schema_name||'.'||function_name||'('||function_argument_type||');' FROM user_functions WHERE schema_name NOT IN ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog') and function_name NOT IN ('isOrContains') and  function_definition ilike 'return%'
    UNION ALL
    -- drop all user views
    SELECT 'DROP VIEW IF EXISTS '||table_schema||'.'||table_name||' CASCADE;' FROM views WHERE table_schema NOT IN ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    UNION ALL
    -- drop all user tables
    SELECT 'DROP TABLE IF EXISTS '||table_schema||'.'||table_name||' CASCADE;' FROM tables WHERE table_schema NOT IN ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    UNION ALL
    -- drop all user sequences
    SELECT 'DROP SEQUENCE IF EXISTS '||sequence_schema||'.'||sequence_name||';' FROM sequences WHERE sequence_schema NOT IN ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog')
    -- drop all user schemas
    UNION ALL
    SELECT 'DROP SCHEMA IF EXISTS '||schema_name||';' FROM schemata WHERE schema_name NOT IN ('v_internal', 'v_catalog', 'v_monitor', 'v_secret_managers', 'v_internal_tables', 'v_func','v_txtindex','pg_catalog', 'public')
  LOOP
    RAISE NOTICE '%', sql;
    PERFORM EXECUTE sql;
  END LOOP;
END;
$$;
EOF
```

**Notes:**

- Uses `CASCADE` for tables and views to handle dependencies.
- `RAISE NOTICE` prints each DROP statement before execution.
- Excludes the `isOrContains` built-in function.
- Only drops SQL functions (identified by `function_definition ILIKE 'return%'`), not C++/Java UDx functions.
