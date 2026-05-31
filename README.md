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
├── demo.md                                 # Demonstration examples
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
│   └── ml-function-mapping.md              # Cross-database ML mapping
```

## Key Features

### 1. Database Migration
- **Generic Migration Requirements** 🚨 **MANDATORY**: Complete migration procedures that apply to ALL database types
- **OLTP to OLAP Rewrite** 🔄 **ESSENTIAL**: 5 rewrite patterns for converting row-by-row procedural code to set-based SQL (adjacent DML merging, loop-DML→set-based, cursor→window functions, etc.)
- **Oracle to Vertica**: PL/SQL to PL/vSQL conversion following generic migration requirements
- **DB2 to Vertica**: PL/SQL to PL/vSQL conversion with DB2-specific features (modules, MQT, special registers) following generic requirements
- **SQL Server to Vertica**: T-SQL to Vertica SQL with stored procedure migration following generic requirements
- **PostgreSQL to Vertica**: PL/pgSQL to PL/vSQL with function mapping following generic requirements
- **MySQL to Vertica**: Schema and query conversion with performance optimization following generic requirements

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
2. **Read Generic Migration Guide** 🚨 **MANDATORY** - Understand all requirements before proceeding
3. **Read OLTP to OLAP Rewrite Guide** 🔄 **ESSENTIAL** - Learn rewrite patterns for procedural/OLTP code
4. **Identify your source database** (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
5. **Process source files sequentially** - never skip or reorder objects
6. **Migrate ALL objects** - tables, views, procedures, functions, DML, sequences
7. **Rewrite procedural code** using OLTP-to-OLAP patterns (cursors→window functions, loops→set-based SQL)
8. **Test each object individually** before considering it migrated
9. **Execute complete migration** and validate all dependencies
10. **Optimize and validate** performance results

### For Vertica Development
1. **Install the skill** using `./install.sh`
2. **Explore reference guides** in the references/ directory
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
1. **Read Generic Migration Guide** 🚨 **MANDATORY FIRST STEP** - Understand all non-negotiable requirements
2. **Read OLTP to OLAP Rewrite Guide** 🔄 **ESSENTIAL** - Understand rewrite patterns for procedural code
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
   Task: Migrate SQL Server database scripts from "examples/sqlserver/" to Vertica, saving results to "examples/vertica/" with identical file names.
   
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
   任务：将 "examples/sqlserver/" 目录下的 SQL Server 数据库脚本迁移到 Vertica，并将结果保存到 "examples/vertica/" 目录，保持文件名一致。
   
   在真正开始执行任务之前，先阅读  vertica-expert skill 提供的与本次任务相关的参考文档，然后详细描述你理解到的这次任务的所有详细要求。最后暂停，等待我的确认。
   ```
- Then：
  
   ```prompt
   一定要牢记这次任务和上述要求。我会严格检查你在这次任务中是否违背了上述要求。
   
   开始执行任务。
   ```

### Large Script Migration Tasks Best Practice

For large database script migrations especially with limit LLM context window, follow this systematic approach:

#### **Step 1: Trigger the skill manually**

```prompt
/vertica-expert
```

#### **Step 2: Execute the real migration task**

```prompt
Task: Migrate SQL Server database scripts from "examples/sqlserver/" to Vertica, saving results to "examples/vertica/" with identical file names.

# Core Workflow Rules

## 0. Sequential Processing (STRICT)
- Read ALL reference documents of vertica-expert skill RELEVANT to this migration task in their entirety FIRST before touching any source file.
- Process source files ONE AT TIME in alphabetical file name order.
- Within each source file, read and migrate section by section from top to bottom. Do NOT read the entire file at once.

## 1. Completeness (STRICT)
- Migrate ALL objects: tables, views, stored procedures, functions, DML statements, COMMIT, ROLLBACK, and any other SQL statements.
- Do NOT assume partial migration is acceptable. Zero omissions.

## 2. Integrity (STRICT)
- Preserve the original order of all objects and statements. The source file's ordering already ensures dependencies are listed first.
- Do NOT skip any content when reading source files.
- Do NOT batch-migrate multiple objects or statements together. Migrate one object/statement at a time.
- Do NOT write scripts or use automation to process multiple items. Scripts cannot leverage the vertica-expert skill and are error-prone.

## 3. Object Migration Requirements

### 3.1 One-to-One Mapping
- Table → Table (**MUST preserve all constraints**: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- View → View
- Stored Procedure → Stored Procedure
- Function → Function or Stored Procedure (as appropriate)
- DML Statement → DML Statement

### 3.2 Index Handling
- Do NOT create projections based on indexes. Comment out index creation statements instead.

### 3.3 OLTP-to-OLAP Rewrite (MANDATORY)
After migrating each object or statement block, rewrite procedural/OLTP patterns into set-based/OLAP style:
- Adjacent INSERT statements targeting the same table → Single INSERT...SELECT
- Cursors or ordered row-by-row processing with shared intermediate variables → Set-based processing, window functions, analytic functions, and CTEs for complex multi-step calculations
- Loops → Set-based SQL
- Row-by-row processing → Batch operations
- Per-row COMMIT → Batch COMMIT

> ⚠️ **CRITICAL — LOGIC PRESERVATION**: When rewriting procedural code to set-based style, **PRESERVE ALL original logic and functionality**:
> - **NEVER simplify or remove logic based on assumptions** about data patterns or business rules
> - **PRESERVE ALL conditional branches, validation checks, and edge case handling**
> - **ENSURE functional equivalence** - rewritten code must produce identical results to the original

### 3.4 Testing Requirements (MANDATORY)
Every migrated object MUST be tested immediately after migration. See §4 for specific testing methods. This section highlights universal testing considerations:

**Data Preservation:**
- Do NOT drop migrated objects or data after testing. Subsequent migrations may depend on them.

**Failure Handling:**
- Do NOT assume a feature is unsupported; verify from multiple angles before concluding.
- For detailed failure handling workflow (consult docs, retry, document, etc.), see §4 Test-First Rule below.
- NEVER postpone or abandon a test.

## 4. Test-First Rule (MANDATORY)
**For every object or statement block, you MUST follow this exact sequence:**
1. **MIGRATE**: Convert the object/statement to Vertica syntax.
2. **TEST**: Execute the migrated object/statement immediately to verify it works.
   - DDL: Execute CREATE statement directly.
   - View: Test with `SELECT * FROM view_name LIMIT 0;`.
   - Function/Stored Procedure: Call with appropriate test parameters.
   - DML: Execute and verify row counts/results.
3. **PASS**: Only if the test succeeds, proceed to the next step. If the test fails:
   - Consult the vertica-expert skill's reference documentation.
   - Apply corrections and retry the test.
   - If it still fails after retry, document the failure reason and append the failed attempt to the target file.
4. **APPEND**: Only after passing the test, append the migrated content to the target file.

**NEVER append untested or failing code to the target file without documentation of the failure.**

## 5. Final Steps
- Only AFTER all source files have been processed (migrated or documented if failed), clean up the test database and any intermediate scripts/files.
- Execute ALL migrated target files in file name order for a complete integration test.
- Check all error logs and fix issues directly in the target files.
- Generate a comprehensive migration report documenting successes, failures, and any remaining issues.

# Critical Constraints

- **NEVER use sub-agents.** Perform all work in the main session.
- **NEVER modify the original file ordering.** Dependencies are already correctly ordered.
- **ALWAYS test immediately** after each migration. No exceptions.
- **ALWAYS verify through testing and consult vertica-expert skill reference documentation** before giving up on a failed migration.
- **NEVER complain about task size or token usage.** Token-solvable problems are not real problems.

Follow these requirements strictly and completely. Do NOT deviate from any rule.
```

Or in Chinese if you prefer:
```prompt
任务：将 "examples/sqlserver/" 目录下的 SQL Server 数据库脚本迁移到 Vertica，并将结果保存到 "examples/vertica/" 目录，保持文件名一致。

# 核心工作流规则

## 0. 顺序处理（严格执行）
- 在开始处理任何源文件之前，先逐篇完整阅读 vertica-expert skill 中与本次迁移任务相关的所有参考文档，每篇文档都要从头读到尾。
- 按源文件名字母顺序逐个处理源文件。
- 在每个源文件内部，从上到下逐段读取和迁移。严禁一次性读取整个文件。

## 1. 完整性（严格执行）
- 迁移所有对象：表、视图、存储过程、函数、DML 语句、COMMIT、ROLLBACK 以及任何其他 SQL 语句。
- 不要假设可以只迁移部分对象。零遗漏。

## 2. 保持原序（严格执行）
- 保留所有对象和语句的原始顺序。源文件中的顺序已经确保了依赖对象在前面。
- 读取源文件时不要跳过任何内容。
- 不要批量迁移多个对象或语句。一次只迁移一个对象/语句。
- 不要写脚本或使用自动化工具批量处理。脚本无法利用 vertica-expert skill，且容易出错。

## 3. 对象迁移要求

### 3.1 一对一映射
- 表 → 表（**必须保留所有约束**：主键约束、外键约束、唯一性约束、Check约束）
- 视图 → 视图
- 存储过程 → 存储过程
- 函数 → 函数或存储过程（视情况而定）
- DML 语句 → DML 语句

### 3.2 索引处理
- 不要根据索引为表创建 projection。将创建索引的语句注释掉即可。

### 3.3 OLTP 到 OLAP 改写（强制要求）
迁移每个对象或语句块后，将过程式/OLTP 模式改写为基于集合/OLAP 风格：
- 针对同一表的连续多行 INSERT 语句 → 单个 INSERT...SELECT
- 游标或带共享中间变量的有序逐行处理 → 集合处理，窗口函数、分析函数和 CTE 用于复杂多步计算
- 循环 → 基于集合的 SQL
- 逐行处理 → 批量操作
- 逐行 COMMIT → 批量 COMMIT

> ⚠️ **关键要求 — 逻辑保持**: 将过程式代码改写为基于集合风格时，**保持所有原始逻辑和功能**：
> - **切勿基于假设简化或删除逻辑**，包括数据模式或业务规则相关的假设
> - **保持所有条件分支、验证检查和边界情况处理**
> - **确保功能等价性** - 改写后的代码必须为所有可能的输入产生与原始代码相同的结果

### 3.4 测试要求（强制要求）
每个迁移后的对象必须在迁移后立即测试，具体测试方式见下文 §4。本节强调测试中的通用注意事项：

**数据保留：**
- 测试后不要删除迁移的对象或数据。后续迁移可能依赖它们。

**失败处理：**
- 不要轻易怀疑某个特性不被支持，要先从多个角度测试验证。
- 具体的失败处理流程（查阅文档、重试、记录原因等）见下文 §4 测试优先规则。
- 永远不要推迟或放弃测试。

## 4. 测试优先规则（强制要求）
**对于每个对象或语句块，必须严格按照以下顺序执行：**
1. **迁移**：将对象/语句转换为 Vertica 语法。
2. **测试**：立即执行迁移后的对象/语句以验证其正确性。
   - DDL：直接执行 CREATE 语句。
   - 视图：使用 `SELECT * FROM view_name LIMIT 0;` 测试。
   - 函数/存储过程：使用适当的测试参数调用。
   - DML：执行并验证行数/结果。
3. **通过**：只有测试成功后才继续下一步。如果测试失败：
   - 查阅 vertica-expert skill 的参考文档。
   - 修正后重试测试。
   - 如果重试后仍然失败，记录失败原因并将失败的尝试附加到目标文件。
4. **追加**：只有通过测试后，才将迁移内容附加到目标文件。

**永远不要将未测试或测试失败的代码附加到目标文件（除非已记录失败原因）。**

## 5. 最终步骤
- 只有在所有源文件都已处理完毕后（迁移成功或已记录失败原因），才清理测试数据库以及任何中间脚本/文件。
- 按文件名顺序执行所有迁移后的目标文件，进行完整的集成测试。
- 检查所有错误日志并直接在目标文件中修复问题。
- 生成完整的迁移报告，记录成功、失败及遗留问题。

# 关键约束

- **永远不要使用子 agent。** 所有工作在主任务会话中完成。
- **永远不要修改原始文件顺序。** 依赖关系已经正确排序。
- **每次迁移后必须立即测试。** 没有例外。
- **放弃前必须测试验证和查阅 vertica-expert skill 参考文档。**
- **永远不要抱怨任务规模或 token 消耗。** 能用 token 解决的问题不是真正的问题。

严格并完整地遵循以上要求，任何情况下都不得偏离。
```

#### **Tips for Success:**

1. **Use regular reminders** to maintain focus:
```prompt
/loop 5m Do you still remember the initial task and requirements? Retell them in detail.
Check carefully, there are still migration tasks missed. Migrate the missed or unfinished tasks one by one. Remember:
- Do NOT complain about task size or token usage. Token-solvable problems are not real problems.
- Do NOT use sub-agents. Do NOT write scripts to batch-migrate multiple objects or statements.
- Do NOT change the original file ordering. Dependencies are already correctly ordered.
- Migrate ALL objects or statements, including simple ones like COMMIT and ROLLBACK.
- After migrating each object or statement block, rewrite procedural/OLTP patterns (cursors, loops, row-by-row processing, per-row COMMIT) into set-based/OLAP style.
- Follow the Test-First Rule: MIGRATE → TEST → PASS → APPEND. Test each object immediately after migration.
- Do NOT drop migrated objects or test data after testing. Subsequent migrations may depend on them.
- Do NOT assume a feature is unsupported; verify from multiple angles before concluding.
- NEVER give up. If a test fails, verify through testing and consult vertica-expert skill reference documentation before giving up.
```

Or in Chinese if you prefer:
```prompt
/loop 5m 还记得最开始的任务和要求吗？详细复述一遍。
仔细检查下，还有迁移任务没完成呢。一个一个地迁移未完成的任务。要记住：
- 不要抱怨任务规模或 token 消耗。能用 token 解决的问题不是真正的问题。
- 千万不要启用子 agent，也不要写脚本来批量迁移多个对象或语句。
- 不要修改原始文件顺序。依赖关系已经正确排序。
- 所有对象或语句都要迁移，包括 COMMIT 和 ROLLBACK 这样的简单命令。
- 每个对象或语句块迁移后，将过程式/OLTP 模式（游标、循环、逐行处理、逐行 COMMIT）改写为基于集合/OLAP 风格。
- 遵循测试优先规则：迁移 → 测试 → 通过 → 追加。每个对象迁移后立即测试。
- 测试后不要删除迁移的对象或测试数据。后续迁移可能依赖它们。
- 不要轻易怀疑某个特性不被支持，要先从多个角度测试验证。
- 永远不要放弃。如果测试失败，必须测试验证和查阅 vertica-expert skill 参考文档后再决定是否放弃。
```

2. **Manage context size** to prevent API errors:
```prompt
/loop 10m /compact
```

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

The environment variable `VSQL` should contain the vsql connection parameters:
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

- **Reference Documentation**: 17 comprehensive guides including mandatory Generic Migration Guide and OLTP-to-OLAP Rewrite Guide
- **Migration Hierarchy**: Clear documentation structure with Generic Guide as foundation
- **Installation Tools**: Easy setup and configuration scripts
- **Best Practices**: Proven patterns for development, optimization, and ML
- **Troubleshooting**: Common issues and solutions for all use cases
- **Examples**: 100+ practical examples across development, migration, and ML

This skill provides everything needed for successful Vertica database migration, development, and machine learning with optimal performance outcomes.
