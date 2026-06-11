# Vertica Expert Skill

A comprehensive skill for Vertica database migration, including migration from Oracle, DB2, SQL Server, PostgreSQL, and MySQL, SQL syntax reference, PL/vSQL stored procedure development, UDx custom function creation, in-database machine learning.

## Overview

This skill is distilled from the Vertica product documentation and my memory to provide detailed guidance on:

- **Migration Guides**: Migrate scripts from Oracle, DB2, SQL Server, PostgreSQL, and MySQL to Vertica, including DDL, DML, stored procedures, and queries
- **Stored Procedures  and UDx Development**: Creating custom stored procedures or functions in SQL, C++, and Python
- **Machine Learning**: In-database predictive analytics with regression, classification, clustering, and time series

## Skill Structure

```
vertica-expert-skill/
├── SKILL.md                                # Main skill definition
├── README.md                               # Project overview
├── CLAUDE.md                               # Internal documentation
├── install.sh                              # Installation script
├── uninstall.sh                            # Uninstallation script
├── references/                             # Detailed reference guides
│   ├── sql-syntax-reference.md             # Complete SQL syntax
│   ├── user-defined-sql-functions-guide.md # User-Defined SQL Functions
│   ├── stored-procedures-guide.md          # PL/vSQL development
│   ├── udx-development-guide.md            # Custom function development (C++, Python, Java, R)
│   ├── data-types.md                       # Data type optimization
│   ├── function-mapping.md                 # Function conversion guide
│   ├── query-optimization.md               # Performance optimization
│   ├── migration-guides-overview.md        # Guide hierarchy and usage instructions
│   ├── generic-migration-guide.md          # 🚨 MANDATORY: Master migration requirements
│   ├── oltp-to-olap-rewrite-guide.md       # 🔄 OLTP→OLAP SQL rewrite patterns
│   ├── oracle-migration.md                 # Oracle-specific migration
│   ├── db2-migration.md                    # IBM DB2 migration guide
│   ├── sqlserver-migration.md              # SQL Server migration guide
│   ├── postgresql-migration.md             # PostgreSQL migration guide
│   ├── mysql-migration.md                  # MySQL migration guide
│   ├── machine-learning.md                 # In-database ML algorithms
│   ├── ml-function-mapping.md              # Cross-database ML mapping
│   └── multi-agent-migration-guide.md      # 🤖 Multi-agent migration architecture and workflow templates
├── examples/                               # Examples of other databases
└── slides/                                 # Slides in Python format
```

## Key Features

### 1. Database Migration
- **Generic Migration Requirements** 🚨 **MANDATORY**: [Generic Migration Guide](references/generic-migration-guide.md) - Complete migration procedures that apply to ALL database types
- **OLTP to OLAP Rewrite** 🔄 **ESSENTIAL**: [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md) - 5 rewrite patterns for converting row-by-row procedural code to set-based SQL (adjacent DML merging, loop-DML→set-based, cursor→window functions, etc.)
- **Oracle to Vertica**: [Oracle Migration Guide](references/oracle-migration.md) - PL/SQL to PL/vSQL conversion following generic migration requirements
- **DB2 to Vertica**: [DB2 Migration Guide](references/db2-migration.md) - PL/SQL to PL/vSQL conversion with DB2-specific features (modules, MQT, special registers) following generic requirements
- **SQL Server to Vertica**: [SQL Server Migration Guide](references/sqlserver-migration.md) - T-SQL to Vertica SQL with stored procedure migration following generic requirements
- **PostgreSQL to Vertica**: [PostgreSQL Migration Guide](references/postgresql-migration.md) - PL/pgSQL to PL/vSQL with function mapping following generic requirements
- **MySQL to Vertica**: [MySQL Migration Guide](references/mysql-migration.md) - Schema and query conversion with performance optimization following generic requirements

### 2. Vertica SQL Development
- **Complete SQL Syntax**: DDL, DML, queries, CTEs, window functions
- **Advanced Analytics**: Complex analytical queries and reporting
- **Data Loading**: COPY statements with transformation options
- **Transaction Control**: Complete transaction management

### 3. User-Defined SQL Functions
- **Simple SQL Extensions**: Create reusable SQL expressions with CREATE FUNCTION
- **Data Transformation**: NULL handling, string formatting, mathematical calculations
- **Business Logic**: Encapsulate frequently used calculations and rules
- **Function Management**: Overloading, privileges, and performance optimization
- **Easy Testing**: Comprehensive testing strategies with VSQL

### 4. PL/vSQL Stored Procedure Development
- **Procedure Creation**: Complete PL/vSQL development framework
- **Parameter Handling**: IN, OUT, INOUT parameters with defaults
- **Control Structures**: IF, CASE, loops (FOR, WHILE)
- **Exception Handling**: Comprehensive error management and logging
- **Dynamic SQL**: EXECUTE statements for flexible queries

### 5. Performance Optimization
- **Projection Design**: Order-optimized, aggregate, replicated projections
- **Encoding Strategies**: RLE, DELTA, GZIP, LZO for optimal compression
- **Query Optimization**: Rewriting for columnar performance
- **Resource Management**: Resource pools and workload prioritization
- **Statistics Management**: ANALYZE_STATISTICS best practices

### 6. UDx Custom Function Development
- **Multiple Languages**: C++, Python, Java, R support
- **Function Types**: Scalar, aggregate, analytic, transform functions
- **High Performance**: Optimized C++ implementations
- **Easy Deployment**: Registration and installation procedures

### 7. Machine Learning & Data Science
- **Regression Algorithms**: Linear, XGBoost, Random Forest, SVM, Poisson
- **Classification**: Logistic, XGBoost, Random Forest, Naive Bayes, SVM
- **Clustering**: K-Means, Bisecting K-Means, K-Prototypes
- **Time Series**: Autoregression, Moving Average, ARIMA
- **Data Preparation**: Imputation, encoding, outlier detection, balancing
- **Model Management**: Training, evaluation, deployment, monitoring

## Capabilities

This skill provides comprehensive coverage of:

1. **Database Migration** - Converting Oracle, DB2, SQL Server, PostgreSQL, and MySQL procedures
2. **OLTP to OLAP Rewrite** - Rewriting row-by-row procedural code to set-based SQL for Vertica's columnar architecture
3. **Vertica SQL Development** - Creating complex analytical queries from requirements
4. **PL/vSQL Development** - Building stored procedures with error handling
5. **Query Optimization** - Converting slow queries to high-performance Vertica
6. **UDx Development** - Creating custom aggregate functions in C++
7. **Machine Learning** - Implementing end-to-end ML workflows in Vertica

## Key Benefits

### For Database Developers
- **Automated SQL conversion** with function mapping
- **Performance optimization** recommendations
- **Best practices** for Vertica development

### For Database Administrators
- **Schema optimization** guidance
- **Projection design** strategies
- **Resource management** best practices

### For Data Architects
- **Migration planning** assistance
- **Performance modeling** for Vertica
- **Scalability considerations**

### For Data Scientists
- **In-database ML workflows** without data movement
- **Algorithm selection** and implementation guidance
- **Model deployment** and monitoring strategies

## Getting Started

### For Database Migration
1. **Install the skill** using `./install.sh`
2. **Read [Generic Migration Guide](references/generic-migration-guide.md)** (from vertica-expert skill) 🚨 **MANDATORY** - Understand all requirements before proceeding
3. **Read [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md)** (from vertica-expert skill) 🔄 **ESSENTIAL** - Learn rewrite patterns for procedural/OLTP code
4. **Identify your source database** (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
5. **Process source files sequentially** - never skip or reorder objects
6. **Migrate ALL objects** - tables, views, procedures, functions, DML, sequences
7. **Rewrite procedural code** using OLTP-to-OLAP patterns (cursors→window functions, loops→set-based SQL)
8. **Test each object individually** before considering it migrated
9. **Execute complete migration** and validate all dependencies
10. **Optimize and validate** performance results

### For Vertica Development
1. **Install the skill** using `./install.sh`
2. **Explore vertica-expert skill's reference guides** in the references/ directory
3. **Use provided examples** as templates for your development
4. **Apply best practices** for optimal performance
5. **Test with your data** and iterate as needed

### For Machine Learning
1. **Install the skill** using `./install.sh`
2. **Choose your ML algorithm** (regression, classification, clustering, time series)
3. **Prepare your training data** with appropriate features
4. **Train and evaluate models** using Vertica's in-database functions
5. **Deploy models** for real-time or batch predictions

## Best Practices

### Migration Process
1. **Read [Generic Migration Guide](references/generic-migration-guide.md)** 🚨 **MANDATORY FIRST STEP** - Understand all non-negotiable requirements
2. **Read [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md)** 🔄 **ESSENTIAL** - Understand rewrite patterns for procedural code
3. **Assess** your current database complexity and dependencies
4. **Plan** your migration strategy following sequential processing requirements
5. **Convert** ALL objects (tables, views, procedures, functions, DML) one-to-one
6. **Rewrite** procedural code using OLTP-to-OLAP patterns (cursors→window functions, loop-DML→set-based SQL)
7. **Test** every object individually before considering it migrated
8. **Execute** complete migration and validate all dependencies
9. **Optimize** for Vertica's columnar architecture
10. **Validate** performance against baselines

### Common Migration Tasks

For common database script migrations , follow this simple approach:

#### **Step 1: Trigger the skill manually**

```prompt
/vertica-expert
```

#### **Step 2: Execute the real migration task**

- First：
   ```prompt
   Task: Migrate Oracle database scripts from "examples/oracle/" to Vertica, saving results to "examples/vertica/" with identical file names.
   
   Before actually starting the task, please read the reference documents related to this task provided by vertica-expert skill, and then provide a detailed description of all the specific requirements you have understood for this task. Finally, pause and wait for my confirmation.
   ```
- Then：
   ```prompt
   Be sure to keep this task and the aforementioned requirements firmly in mind. I will rigorously inspect whether you have violated these requirements during this task.
   
   Start the task.
   ```

Or in Chinese if you prefer:

- First：
   ```prompt
   任务：将 "examples/oracle/" 目录下的 Oracle 数据库脚本迁移到 Vertica，并将结果保存到 "examples/vertica/" 目录，保持文件名一致。
   
   在真正开始执行任务之前，先阅读  vertica-expert skill 提供的与本次任务相关的参考文档，然后详细描述你理解到的这次任务的所有详细要求。最后暂停，等待我的确认。
   ```
- Then：
  
   ```prompt
   一定要牢记这次任务和上述要求。我会严格检查你在这次任务中是否违背了上述要求。
   
   开始执行任务。
   ```

### 🤖 Multi-Agent Migration Workflow

**⚠️ PREREQUISITE: Enable Background Agent Support**

Before using this workflow, you may need set the environment variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to enable background agent execution and SendMessage communication for better experience:

**Option 1: Set in `~/.claude/settings.json`** (Recommended)
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Option 2: Set in profile before start claude**

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

📖 **Documentation:** For more details on background agent execution and SendMessage API, see [Claude Code Sub-Agents Documentation](https://code.claude.com/docs/en/sub-agents#resume-subagents)

---

**When to Use:** Multiple source files, or single file >200 lines, or multiple stored procedures/functions, or large-scale migrations requiring strict context management

**When NOT to Use:** Single small file, simple table structure migration

**4-Agent Architecture:**

| Agent | Role | Key Constraint |
|-------|------|----------------|
| **Manager** (main session) | **INITIALIZES BACKGROUND AGENTS AT STARTUP**, coordinates workflow, **strictly verifies** Migrator/Tester results, appends to target, **communicates via SendMessage** | 🚫 **NEVER reads source files or migration references** — only reads [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md), **NEVER re-spawns agents for each task** |
| **Requester** (sub-agent) | **Runs in BACKGROUND MODE** — initialized once, persists across tasks. Reads source files section-by-section using `Read(offset=N, limit=50)`, identifies complete objects | 🚫 **EXCLUSIVE file reader** — no migration knowledge, returns code as-is |
| **Migrator** (sub-agent) | **Runs in BACKGROUND MODE** — initialized once, persists across tasks. Performs code transformation, unit tests before returning | 🚫 **ONLY agent** that loads migration reference documents |
| **Tester** (sub-agent) | **Runs in BACKGROUND MODE** — initialized once, persists across tasks. Validates migrated code in single VSQL call with autocommit | 🚫 **ONLY reads** [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md) |

**Workflow Loop:**

```
Phase 1: Migration & Functional Testing (per source file, alphabetical order)
  Manager SENDMESSAGE to requester_agent → Requester READS section (offset=N, limit=50) → RETURNS code snippet
  → Manager SENDMESSAGE to migrator_agent → MIGRATES + unit tests (up to 10 attempts)
  → 🔍 MANAGER VERIFIES unit test (logs complete, no anomalies, status PASSED)
  → Manager SENDMESSAGE to tester_agent → FUNCTIONAL TEST (single VSQL call, autocommit, verify no errors)
  → 🔍 MANAGER VERIFIES test results (logs complete, no false positives)
  → PASS → APPEND to target file
  → FAIL → Manager SENDMESSAGE to migrator_agent to fix → RETEST

Phase 2: Integration Testing (after ALL objects migrated)
  Manager SENDMESSAGE to tester_agent: clears test database completely → executes ALL files in order → runs integration test
  → PASS → ✅ Migration complete
  → FAIL → Tester reports failures with complete logs → Manager SENDMESSAGE to migrator_agent with error info and ALL target files → Migrator analyzes errors and fixes issues → Manager SENDMESSAGE to tester_agent to clear test database and re-run integration test → Repeat until pass
```

**Manager's Strict Limits:**
- ✅ **ONLY obtains source code from Requester** — never reads files directly
- ✅ **ONLY creates Requester, Migrator, Tester agents** — no other agents allowed
- ✅ **ONLY provides process control** — NEVER gives migration rules/decisions to Migrator
- ✅ **VERIFICATION, not migration expertise** — verifies test logs, not code correctness
- ✅ **ONLY re-initializes agents if they crash** — uses SendMessage for all subsequent tasks

**Benefits:** Focused context windows · Clear separation of concerns · Dual verification ensures quality · Two-phase testing · Easy debugging · **Agents persist across tasks — no repeated initialization overhead**

**Quick Start:**
```prompt
Task: Please use the Multi-Agent Migration Workflow to migrate [source_db] scripts from "[source_path]" to Vertica, saving results to "[target_path]" with identical file names.

You are the Manager agent. Before starting, wait for my confirmation.
```

Example:
```prompt
Task: Please use the Multi-Agent Migration Workflow to migrate SQL Server database scripts from "examples/sqlserver/*.sql" to Vertica, saving results to "examples/vertica/" with identical file names.

You are the Manager agent. Before starting, wait for my confirmation.
```

Then monitor and frequently remind the Manager:
```prompt
/loop 5m You are the Manager agent. Remember:
1. Never tell Migrator how to migrate, he is the expert of migration, not you.
2. Never tell Tester how to test, he is the expert of testing, not you.
3. Don't disclose the source and target files to anyone.
4. Don't forget your context management duty, include sending SendMessage CONTEXT_REFRESH to subagents.
5. Use SendMessage for all subsequent tasks. If you lose the IDs of the subagents, just look for them it in the place where Claude stores subagent information.
```

**Reference Documentation:**

- **Manager/Requester/Tester read:** [Multi-Agent Migration Guide](references/multi-agent-migration-guide.md)
- **Migrator only:** [Generic Migration Guide](references/generic-migration-guide.md), [OLTP to OLAP Rewrite Guide](references/oltp-to-olap-rewrite-guide.md), database-specific guides, and all other references

**Manager Verification Checklist:**
1. **Migrator's Unit Test:** Performed? Logs complete? No WARNING/ERROR anomalies? Status PASSED?
2. **Tester's Test Results:** Performed? Logs complete? No false positives? Status genuinely PASS?

### Vertica Development

1. **Design for columnar storage** from the beginning
2. **Use appropriate data types** for optimal compression
3. **Create projections** that match query patterns
4. **Implement proper encoding** for each column type
5. **Update statistics regularly** after data changes

### Performance Tuning

1. **Design projections first** before loading data
2. **Use appropriate encoding** for each column
3. **Update statistics regularly** after data changes
4. **Monitor query performance** using system tables
5. **Iterate on optimization** based on actual usage

### Machine Learning Implementation
1. **Prepare data** with feature engineering and cleaning
2. **Select algorithm** based on your use case
3. **Train models** using in-database functions
4. **Evaluate performance** with built-in metrics
5. **Deploy for production** with real-time scoring

## Testing SQL and Stored Procedures

All SQL examples and stored procedures provided by this skill can be tested using the VSQL command-line tool.

### VSQL Testing Setup

The environment variable `VSQL` encapsulates the vsql connection parameters:
```bash
export VSQL='/opt/vertica/bin/vsql -h hostname -p 5433 -U username -w password dbname'
```

**Important Autocommit Behavior**: By default, vsql has **autocommit OFF** for interactive sessions. For testing, either:
- Enable autocommit: `SET SESSION AUTOCOMMIT TO ON;`
- Include explicit COMMIT statements after data modifications

**Important Session Behavior**: Each `$VSQL -c` command creates a new session. For data persistence across multiple commands, either:

1. Use explicit COMMIT statements in DML commands, or
2. Use here document syntax for multi-statement transactions

**Checking Object Availability:**

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

**Single-line SQL commands:**
```bash
$VSQL -c "SELECT VERSION();"
```

**Multi-line SQL (recommended for stored procedures and complex queries):**
```bash
$VSQL<<-'EOF'
CREATE OR REPLACE PROCEDURE example_proc() AS $$
BEGIN
    -- Your PL/vSQL code here
    RAISE NOTICE 'Test procedure executed';
END;
$$
EOF
```

**Key Benefits of Here Document:**
- Avoid escaping special characters like `$` and `"`
- Maintain SQL code formatting and readability
- Ideal for stored procedures with `$$` delimiters

## Support and Resources

- **Reference Documentation**: comprehensive guides including mandatory Generic Migration Guide and OLTP-to-OLAP Rewrite Guide
- **Migration Hierarchy**: Clear documentation structure with Generic Guide as foundation
- **Installation Tools**: Easy setup and configuration scripts
- **Best Practices**: Proven patterns for development, optimization, and ML
- **Troubleshooting**: Common issues and solutions for all use cases
- **Examples**: 100+ practical examples across development, migration, and ML

This skill provides everything needed for successful Vertica database migration, development, and machine learning with optimal performance outcomes.

## How to Generate the Slides

The `slides/` directory contains Python scripts that generate slides using `python-pptx`. Before running them, make sure the required Python package is installed:

```bash
# Check dependency
python3 -c "import pptx; print('python-pptx', pptx.__version__)"
# If missing:
pip install python-pptx

# Generate the presentation
python3 slides/vertica_expert_overview.py
```

The generated `.pptx` file will be saved in the `slides/` directory.
