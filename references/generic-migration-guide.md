# Generic Database to Vertica Migration Guide

> **This is the MASTER migration guide.** All specific database migration guides (Oracle, DB2, SQL Server, PostgreSQL, MySQL) reference and follow this guide's requirements. **This guide takes precedence over all other migration guides.**

---

## 📋 Table of Contents

1. [Pre-Migration Checklist](#-pre-migration-checklist)
2. [Mandatory Rules Summary](#-mandatory-rules-summary)
3. [Complete Migration Requirement](#1-complete-migration-requirement)
4. [Sequential Processing Requirement](#2-sequential-processing-requirement)
5. [Object Integrity Requirement](#3-object-integrity-requirement)
6. [One-to-One Migration Requirement](#4-one-to-one-migration-requirement)
7. [OLTP-to-OLAP Rewrite Requirement](#5-oltp-to-olap-rewrite-requirement)
8. [Test-First Rule](#6-test-first-rule-mandatory)
9. [Functionality Equivalence Assumption](#7-functionality-equivalence-assumption)
10. [Projection Design Requirement](#8-projection-design-requirement)
11. [Absolutely Prohibited Actions](#-absolutely-prohibited-actions)
12. [Migration Procedure](#-migration-procedure)
13. [Reference Documents](#-reference-documents)
14. [Migration Success Criteria](#-migration-success-criteria)
15. [Troubleshooting](#-troubleshooting)

---

## ✅ Pre-Migration Checklist

Before starting ANY migration, complete ALL of these steps **in order**:

- [ ] **Read this entire guide** from top to bottom — every section
- [ ] **Read the OLTP to OLAP Rewrite Guide** (`oltp-to-olap-rewrite-guide.md`) — essential for procedural code
- [ ] **Read the source-specific migration guide** (oracle-migration.md, sqlserver-migration.md, etc.)
- [ ] **Read the SQL Syntax Reference** (`sql-syntax-reference.md`)
- [ ] **Read the Function Mapping Guide** (`function-mapping.md`)
- [ ] **Read the Data Type Mapping Guide** (`data-type-mapping.md`)
- [ ] **Read the User-Defined SQL Functions Guide** (`user-defined-sql-functions-guide.md`) if migrating functions
- [ ] **Read the Stored Procedures Guide** (`stored-procedures-guide.md`) if migrating procedures
- [ ] **List all migration requirements** from the guides above and present them to the user
- [ ] **Wait for user confirmation** before starting any migration work

> 🚨 **DO NOT read any source files for the migration task until ALL relevant reference documents have been fully read AND the user has confirmed. Both conditions must be met before touching any source file.**

---

## 🚨 Mandatory Rules Summary

**Memorize these. They apply to EVERY migration without exception.**

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **Migrate ALL objects** — no selective migration | Incomplete migration |
| 2 | **Process files in alphabetical order** — one file at a time | Dependency failures |
| 3 | **Process each file top-to-bottom** — never skip or reorder | Broken dependencies |
| 4 | **Keep objects intact** — never split procedures, functions, or statements | Syntax errors |
| 5 | **One-to-one mapping** — tables→tables, views→views, procedures→procedures | Lost functionality |
| 6 | **Rewrite OLTP→OLAP** — eliminate cursors, row-by-row DML, per-row COMMITs | Severe performance degradation |
| 7 | **Preserve ALL logic** — never simplify or remove code during rewrite | Silent data corruption |
| 8 | **Test EVERY object immediately** — MIGRATE→TEST→PASS→APPEND, no exceptions | Undetected failures |
| 9 | **Never use scripts/tools** for bulk conversion or regex replacement | Lost business logic |
| 10 | **Assume Vertica has equivalent functionality** — verify before using workarounds | Unnecessary complexity |
| 11 | **NEVER read the entire source file** — read section-by-section with offset/limit, migrate each object immediately | Context overflow, batch processing |

## 🔒 Critical Constraints

**These are absolute. No exceptions, no excuses.**

- **NEVER use sub-agents.** Perform ALL work in the main session. Sub-agents cannot maintain context across the migration.
- **NEVER complain about task size or token usage.** Token-solvable problems are not real problems.
- **NEVER modify the original file ordering.** Dependencies are already correctly ordered in the source.
- **ALWAYS test immediately** after each migration. No exceptions.
- **ALWAYS verify through testing and consult reference documentation** before giving up on a failed migration.
- **NEVER deviate from any rule** in this guide. Strict and complete adherence is required.
- **NEVER read the entire source file at once.** Use `Read` with `offset` and `limit` to read small sections. Migrate and test each object immediately before reading the next section.
- **NEVER make excuses** such as "the file is large so I need to read it all first" or "let me understand the full context before migrating." These are violations of the per-object workflow. Process top-to-bottom, one object at a time, period.

---

## 1. Complete Migration Requirement

**ALL** database objects MUST be migrated — **NO EXCEPTIONS**:

| Object Type | Action |
|-------------|--------|
| Tables | Migrate with all constraints (PK, FK, UNIQUE, CHECK). Do NOT add `SEGMENTED BY` or `UNSEGMENTED` clauses to CREATE TABLE statements — these are designed separately by Vertica DBA. **Exception**: When migrating from Teradata, convert `PRIMARY INDEX (col)` to `ORDER BY col SEGMENTED BY HASH(col) ALL NODES` — the primary index defines both distribution and sort order |
| Views | Migrate (including materialized views). **Vertica fully supports `ORDER BY` in view definitions, and the sorting takes effect.** Do NOT remove `ORDER BY` from view definitions during migration if `TOP` or `LIMIT` appears together with `ORDER BY`. Some source databases ignore `ORDER BY` in views, so applications use `TOP (100) PERCENT` alongside `ORDER BY` to force it to work — preserve the `ORDER BY` when migrating such views. |
| Stored Procedures | Convert to PL/vSQL |
| Functions | Convert to SQL functions or PL/vSQL procedures |
| DML Statements | Migrate ALL (INSERT, UPDATE, DELETE, MERGE, COMMIT, ROLLBACK) |
| Sequences | **Always preserve** — may be used in unseen locations, never discard |
| Constraints | **MUST** be in DDL: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK |
| Indexes | Comment out (do NOT discard or auto-create projections) |
| Triggers | Convert to stored procedures or application logic |
| Synonyms | Convert to views or direct references |
| Database Links | Convert to external tables or ETL processes |

> ⚠️ **Constraints must NEVER be commented out or dropped.** They must be defined in CREATE TABLE / ALTER TABLE DDL.

---

## 2. Sequential Processing Requirement

**STRICT ORDER PRESERVATION** — process content in exact source file order.

### 🚫 Forbidden Behavior (Anti-Patterns)

The following behaviors are **STRICTLY PROHIBITED**. Do NOT use them as excuses to bypass the per-object migration workflow:

```
❌ NEVER read multiple sections of a source file and then batch-migrate them together.
   Even if you read section-by-section, you MUST migrate and test each object
   immediately after reading it — NOT accumulate multiple objects and migrate them
   in a batch afterward.

❌ NEVER say "the file is large, let me create a more efficient migration strategy."
   There is no "more efficient strategy." The MIGRATE→TEST→PASS→APPEND cycle
   applies to EVERY object regardless of file size.

❌ NEVER use Write tool to create the entire target file at once.
   Use Edit/Append to add each migrated object to the target file one at a time
   after it passes testing.

❌ NEVER say "let me read ahead to understand the full context first."
   Read only what you need for the current object. Process top-to-bottom.
```

### File Reading Rules

- ✅ Read source files **in alphabetical file name order** — one file at a time
- ✅ Use `Read` with `offset` and `limit` to read **one small section at a time** (e.g., `offset=1, limit=50`)
- ✅ After reading a section, **immediately** identify, migrate, test, and append the next complete object
- ✅ Then read the next section. Do NOT read further until the current object is done.
- ✅ **NEVER skip or jump** ahead in the source file
- ✅ **NEVER reorder** objects or statements

### Mandatory Per-Object Workflow

**For EVERY single object, you MUST complete this exact cycle before touching the next object:**

```
1. READ:   Read a small section of the source file (offset=N, limit=50)
2. IDENTIFY: Find the next complete object in this section
           (if incomplete, read more lines until the object is complete)
3. MIGRATE:  Convert the object to Vertica syntax
4. REWRITE:  Rewrite OLTP→OLAP patterns
5. TEST:     Execute the migrated object in Vertica immediately
6. PASS?:    IF test passes → APPEND to target file → go to next object
             IF test fails → fix, retest, then append (document if still failing)
```

**Repeat this cycle for every object in the file. No shortcuts. No batching.**

**Rationale:** Original order ensures dependency resolution. Per-object testing catches errors immediately before they compound. Reading in small chunks prevents the Agent from accumulating multiple objects and batch-processing them.

---

## 3. Object Integrity Requirement

**MAINTAIN OBJECT BOUNDARIES** — never break up complete objects:

- ✅ **NEVER split** stored procedures or functions
- ✅ **NEVER truncate** long DML statements
- ✅ **NEVER break** view definitions
- ✅ **NEVER fragment** table definitions
- ✅ **NEVER interrupt** trigger logic

**Rationale:** Breaking objects leads to syntax errors and dependency issues.

---

## 4. One-to-One Migration Requirement

**PRESERVE OBJECT TYPES** — convert each object to its Vertica equivalent:

| Source Object | Vertica Target |
|---------------|----------------|
| Table | Table (with all constraints) |
| View | View |
| Stored Procedure | PL/vSQL Stored Procedure |
| Function | User-Defined SQL Function **or** PL/vSQL Stored Procedure |
| DML Statement | DML Statement |
| Sequence | Sequence |
| Constraint | Constraint (in DDL) |
| Trigger | Stored Procedure or Application Logic |

> ⚠️ **SQL Server Migration — Schema Prefix Requirement**: When migrating from SQL Server, every `CREATE TABLE`, `CREATE VIEW`, `CREATE PROCEDURE`, and `CREATE FUNCTION` statement **MUST** include the correct schema name prefix. Track `USE` statements throughout the script: once `USE [dbname]` is encountered, all subsequent object definitions must be prefixed with that database name as the schema (e.g., `CREATE TABLE CRM.customers (...)`, `CREATE VIEW ERP.v_orders AS ...`). **If no `USE` statement exists in the script, strip the `dbo.` prefix entirely** — e.g., `CREATE TABLE customers (...)` not `CREATE TABLE dbo.customers (...)`. See [SQL Server Migration Guide](sqlserver-migration.md) for detailed examples.

> ⚠️ **MySQL Migration — Schema Prefix Requirement**: When migrating from MySQL, track `USE database` statements. Once `USE dbname` is encountered, all subsequent `CREATE` objects must be prefixed with that database name as the schema (e.g., `CREATE TABLE CRM.customers (...)`). **If no `USE` statement exists in the script, do NOT add any schema prefix** — use bare object names (e.g., `CREATE TABLE customers (...)`). See [MySQL Migration Guide](mysql-migration.md) for detailed examples.

> ⚠️ **Vertica User-Defined SQL Function Limitation:** Vertica SQL functions can only contain a **single expression**. They **cannot** contain:
> - Complete SQL queries (no `FROM`, `WHERE`, `GROUP BY`, `ORDER BY`, `LIMIT`)
> - Procedural control logic (no loops, variable declarations, conditionals beyond simple `CASE`)
> - Aggregate or analytic functions
>
> If the source function contains full queries or complex procedural logic, convert it to a **PL/vSQL Stored Procedure** or a **UDx (C++, Python, Java, or R)** instead.

---

## 5. OLTP-to-OLAP Rewrite Requirement

**REWRITE PROCEDURAL/OLTP CODE TO SET-BASED SQL.** Migrating syntax is not enough; the processing paradigm must also shift. After one-to-one conversion, review all stored procedures and scripts for OLTP anti-patterns:

### Required Rewrites

| Anti-Pattern | Rewrite To |
|--------------|-----------|
| Cursors / row-by-row processing | Window functions, JOINs, CTEs |
| Loop-INSERTs (one row per iteration) | `INSERT...SELECT` |
| Per-row UPDATEs | Set-based `UPDATE...FROM` |
| Per-row DELETEs | Set-based `DELETE...WHERE EXISTS` |
| Running totals / inter-row comparisons | `SUM() OVER`, `LAG`, `LEAD`, `ROW_NUMBER` |
| COMMIT inside loops | Single COMMIT per batch |
| Iterative hierarchy traversal | Recursive CTEs (`WITH RECURSIVE`) |
| Dynamic SQL for static object names | Static SQL |
| Per-row function calls in SELECT | JOINs to lookup/derived tables |
| Temp tables populated row-by-row | CTEs or derived tables |

### ⚠️ Logic Preservation Requirement

When rewriting, **ALL original logic and functionality MUST be preserved**:

- ✅ **NEVER simplify or remove logic** based on assumptions about data patterns, business rules, or edge cases
- ✅ **PRESERVE ALL conditional branches**, even if they appear redundant
- ✅ **MAINTAIN ALL validation checks and error handling**
- ✅ **KEEP ALL data transformation steps** exactly as originally implemented
- ✅ **RETAIN ALL intermediate calculations** and state tracking logic
- ✅ **PRESERVE ALL edge case handling** for NULL values, empty sets, and boundary conditions
- ✅ **ENSURE functional equivalence** — rewritten code must produce identical results for all possible inputs

### ⚠️ Manual Rewrite Only

The OLTP-to-OLAP rewrite **MUST** be performed **step-by-step and block-by-block** using editor tools. **Strictly PROHIBITED:**

- ❌ **NEVER** use scripts (Python, shell), command-line tools (sed, awk, perl), or bulk-replacement tools
- ❌ **NEVER** rely on regex-based find-and-replace across multiple files or large code blocks
- ❌ **NEVER** batch-rewrite multiple procedures or code blocks in a single pass

**Reference:** Use the [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for detailed rewrite patterns, before/after examples, and a migration checklist.

---

## 6. Test-First Rule (MANDATORY)

**For every object or statement block, you MUST follow this exact sequence:**

| Step | Action | Details |
|------|--------|---------|
| 1. **MIGRATE** | Convert the object/statement to Vertica syntax | Apply one-to-one migration, then rewrite OLTP→OLAP |
| 2. **TEST** | Execute immediately to verify it works | **MUST check complete output logs** — never check only partial output. See test methods below |
| 3. **CHECK LOGS** | **MUST check COMPLETE logs** — never check only partial output | Verify ALL messages, warnings, and errors |
| 4. **PASS** | If test succeeds → proceed to step 5. If test fails → consult reference docs, correct, and retry. If still failing after retry → document failure reason and append failed attempt to target file | Never skip or postpone a test |
| 5. **APPEND** | Only after passing the test, append the migrated content to the target file | Never append untested code |

> 🚨 **NEVER append untested or failing code to the target file without documentation of the failure.**
> 🚨 **ALWAYS check COMPLETE test logs** — partial log checking may miss critical errors or warnings. Verify ALL output including warnings, errors, and execution results.

### Test Methods by Object Type

| Object Type | Test Method | Log Check Requirements |
|-------------|------------|------------------------|
| Table | Execute `CREATE TABLE (...)` directly | Check for WARNING, ERROR messages |
| View | `CREATE VIEW ... AS ...` then `SELECT * FROM view LIMIT 0` | Verify view creation notice and query results |
| Stored Procedure | `CREATE PROCEDURE ...` then `CALL proc(...)` with test parameters | Check procedure creation notice, CALL output, and any RAISE NOTICE messages |
| Function | `CREATE FUNCTION ...` then `SELECT func(...)` with test parameters | Verify function creation notice and return value |
| DML | Execute statement, then verify with `SELECT COUNT(*)` or result check | Check row count affected and any trigger/notice messages |

> 🚨 **CRITICAL**: When using VSQL, always check the COMPLETE output. A successful execution may still contain WARNING or NOTICE messages that indicate potential issues.

### Data Preservation

- ✅ **DO NOT DROP** migrated objects or data after individual testing — subsequent migrations may depend on them
- ✅ Clean up test environment **ONLY AFTER** all source files have been processed

### Failure Handling

- ✅ **NEVER ASSUME** a feature is unsupported — verify from multiple angles before concluding
- ✅ **ALWAYS** consult the vertica-expert skill's reference documentation before giving up
- ✅ **NEVER** postpone or abandon a test
- ✅ **NEVER COMPLAIN** about task size or token usage — token-solvable problems are not real problems

---

## 7. Functionality Equivalence Assumption

**ASSUME VERTICA HAS EQUIVALENT FUNCTIONALITY** — never assume a source database feature is missing:

- ✅ **ALWAYS ASSUME** Vertica has equivalent functionality for any source database feature
- ✅ **NEVER ASSUME** a function, syntax, or feature is unavailable without definitive proof
- ✅ **ALWAYS VERIFY** through testing before concluding functionality doesn't exist
- ✅ **ALWAYS SEARCH** the Vertica documentation and function mapping guides first
- ✅ **PRESERVE** the original functionality intent during conversion

**Rationale:** Vertica follows ANSI SQL standard and has extensive SQL functionality. Assuming features don't exist leads to unnecessary workarounds, reduced performance, and loss of functionality.

---

## 8. Projection Design Requirement

**DO NOT CREATE PROJECTIONS FROM INDEXES OR QUERIES AUTOMATICALLY:**

- ✅ **NEVER** automatically create projections based on source database indexes and queries
- ✅ Projections should be designed separately based on query patterns by Vertica DBA or manually
- ✅ Use `CREATE PROJECTION` statements explicitly when needed
- ✅ **NEVER** add `SEGMENTED BY` or `UNSEGMENTED` clauses to CREATE TABLE statements — Do NOT add `SEGMENTED BY` or `UNSEGMENTED` clauses to CREATE TABLE statements — these are designed separately by Vertica DBA. **Exception**: When migrating from Teradata, convert `PRIMARY INDEX (col)` to `ORDER BY col SEGMENTED BY HASH(col) ALL NODES` — the primary index defines both distribution and sort order

**Rationale:** Index-based projections are often not optimal for Vertica's columnar architecture. Segmentation expressions are projection-specific optimizations that should not be embedded in table DDL by guessing.

---

## 🚫 Absolutely Prohibited Actions

### Selective Migration
```
❌ NEVER skip objects because they "seem unnecessary"
❌ NEVER migrate only "important" tables/views/procedures
❌ NEVER leave out objects based on personal judgment
❌ NEVER assume some objects aren't needed
```

### Sub-Agents
```
❌ NEVER use sub-agents for migration work
❌ ALL work MUST be performed in the main session
✅ Sub-agents cannot maintain migration context and will produce inconsistent results
```

### Automated Bulk Processing
```
❌ NEVER use scripts for bulk conversion
❌ NEVER process multiple objects simultaneously
❌ NEVER rely on regex or pattern matching alone
❌ NEVER use sed/awk/perl/find-replace for code transformation
```

### Order Modification
```
❌ NEVER reorder objects for "better organization"
❌ NEVER group similar objects together
❌ NEVER optimize the migration order
❌ NEVER change the original source sequence
```

### Object Fragmentation
```
❌ NEVER split large stored procedures
❌ NEVER break long SQL statements
❌ NEVER truncate object definitions
❌ NEVER modify object boundaries
❌ NEVER remove or comment out PRIMARY KEY, FOREIGN KEY, UNIQUE, or CHECK constraints
```

### Testing Shortcuts
```
❌ NEVER skip testing for "simple" objects
❌ NEVER assume conversion was successful
❌ NEVER proceed without verification
❌ NEVER mark objects as migrated without successful execution
```

### Unnecessary Dynamic SQL
```
❌ NEVER use EXECUTE or PERFORM EXECUTE for DML/SELECT with static objects
❌ NEVER use EXECUTE or PERFORM EXECUTE for DDL with fixed object names
✅ USE EXECUTE or PERFORM EXECUTE only when identifiers (table/column names) must be dynamic
```

### Query Structure Modification
```
❌ NEVER add table name or alias prefixes to columns that are ambiguous
❌ NEVER reorder columns, tables, or subqueries from their original sequence
✅ KEEP the original order of columns in SELECT clause
✅ KEEP the original order of tables and subqueries in FROM and JOIN clauses
```

### Database-Specific Query Hints
```
❌ Most database-specific query hints (Oracle hints, SQL Server index hints, etc.) do NOT work in Vertica
✅ Comment them out — do NOT delete them, in case they need to be restored for reference
```

### Parameter and Sequence Preservation
```
❌ NEVER remove OUT or INOUT keywords from procedure parameters — this breaks parameter logic and causes runtime failures
❌ NEVER discard the migration of SEQUENCE — it may be used in places you haven't seen yet
```

### Agent Behavior Violations
```
❌ NEVER use sub-agents — perform ALL work in the main session
❌ NEVER complain about task size or token usage — token-solvable problems are not real problems
❌ NEVER deviate from any rule — follow all requirements strictly and completely
❌ NEVER read multiple sections and then batch-migrate — migrate each object immediately after reading
❌ NEVER use Write tool for the entire target file — use Edit/Append per object
❌ NEVER say "let me create a more efficient strategy" — there is none; follow the per-object workflow
```

---

## 📋 Migration Procedure

### Step 1: Load Reference Documents
Read ALL relevant reference documents in their entirety (see [Pre-Migration Checklist](#-pre-migration-checklist)).

### Step 2: List Requirements & Get Confirmation
Before starting, list ALL detailed migration requirements from the guides. **Wait for user confirmation.**

### Step 3: Process Source Files
Follow the **Mandatory Per-Object Workflow** defined in [Section 2](#2-sequential-processing-requirement):
- Read a small section → Identify object → Migrate → Rewrite → Test → Append → Repeat

### Step 4: Full Migration Testing
After ALL source files have been processed (migrated or documented if failed):
1. Clean the test Vertica database
2. Execute ALL migrated target files **in file name order** for a complete integration test
3. Check all error logs and fix issues directly in the target files
4. Verify all objects exist and are functional
5. Fix any errors and re-execute until fully successful

### Step 5: Generate Migration Report
Document:
- Total objects processed
- Objects successfully migrated
- Objects that failed (with reasons and attempted solutions)
- Performance recommendations

---

## 📚 Reference Documents

Read in this order of priority:

| Priority | Document | When to Use |
|----------|----------|-------------|
| 1 | **This Guide** (`generic-migration-guide.md`) | **ALWAYS — first** |
| 2 | **OLTP to OLAP Rewrite Guide** (`oltp-to-olap-rewrite-guide.md`) | Procedural/OLTP code |
| 3 | **Source-specific migration guide** | Database-specific syntax |
| 4 | **SQL Syntax Reference** (`sql-syntax-reference.md`) | Syntax questions |
| 5 | **Function Mapping Guide** (`function-mapping.md`) | Function conversion |
| 6 | **Data Type Mapping Guide** (`data-type-mapping.md`) | Type conversion |
| 7 | **User-Defined SQL Functions Guide** (`user-defined-sql-functions-guide.md`) | SQL function development |
| 8 | **Stored Procedures Guide** (`stored-procedures-guide.md`) | PL/vSQL development |
| 9 | **UDx Development Guide** (`udx-development-guide.md`) | C++/Python/Java/R functions |
| 10 | **Query Optimization** (`query-optimization.md`) | Performance tuning |
| 11 | **Machine Learning Guide** (`machine-learning.md`) | ML workflows |
| 12 | **ML Function Mapping** (`ml-function-mapping.md`) | Cross-platform ML |

---

## 📊 Migration Success Criteria

### Completeness
- [ ] **100%** of source objects processed
- [ ] **100%** of objects tested individually
- [ ] **100%** of objects functional in Vertica
- [ ] **100%** of dependencies satisfied

### Quality
- [ ] No syntax errors in any object
- [ ] No runtime errors during execution
- [ ] Functionality matches source database behavior
- [ ] Procedural/OLTP patterns rewritten to set-based/OLAP style
- [ ] Performance meets or exceeds source database

### Documentation
- [ ] Complete migration log maintained
- [ ] All failures documented with reasons
- [ ] All solutions attempted recorded
- [ ] Final migration file validated

---

## 📋 Migration Checklist

Use this checklist to verify that every migrated object is correct and complete. Each specific database migration guide (SQL Server, Oracle, DB2, MySQL) may add additional database-specific checklist items below these common ones.

### 🚨 Critical Parameter Handling

- [ ] **NEVER remove OUT keywords** from output parameters
- [ ] **NEVER remove INOUT keywords** from input/output parameters
- [ ] **NEVER use DEFAULT syntax** in parameter declarations — use procedure overloading instead
- [ ] Verify all OUT parameters are declared as `OUT param_name TYPE`
- [ ] Verify all INOUT parameters are declared as `INOUT param_name TYPE`
- [ ] IN parameters can omit the IN keyword (it's optional)
- [ ] Implement default parameter values using procedure overloading pattern
- [ ] Test all parameter passing scenarios
- [ ] **Understand OUT/INOUT behavior difference**: Vertica `CALL` returns a **single tuple (record)** — unpack with `var1, var2 := CALL proc(...)`. Unlike the source database, original variables are NOT modified by reference.

### 📋 General Migration Checklist

- [ ] `$$` delimiters added
- [ ] `BEGIN/END` blocks converted to `BEGIN/END;` with `$$` delimiters
- [ ] **Triggers**: Comment out triggers (not supported in Vertica)
- [ ] **Foreign key constraints**: Comment out `ON DELETE CASCADE` (not supported in Vertica)
- [ ] Tables converted with proper data types
- [ ] Parameter modes preserved (critical!)
- [ ] Default parameter values implemented using overloading pattern
- [ ] SQL functions analyzed for optimal migration strategy (subquery vs stored procedure)
- [ ] DML return values captured directly (no source-database-specific row count mechanism needed)
- [ ] MUST use the PERFORM command to discard output (row counts, Tuples/Tuple, status messages) when executing DDL statements (CREATE, ALTER, DROP, TRUNCATE, etc.), COMMIT, ROLLBACK, DML statements (INSERT, UPDATE, DELETE, MERGE), CALL procedure statement, EXECUTE (dynamic SQL) and other SQL statements that you want to execute but don't need to capture the return value from via `:=`, `<-`, `SELECT ... INTO`, or `EXECUTE ... INTO`
- [ ] Exception handling uses SQLSTATE/SQLERRM for basic info; GET STACKED DIAGNOSTICS with DETAIL_TEXT/HINT_TEXT/EXCEPTION_CONTEXT for detailed info
- [ ] All procedures compile without errors
- [ ] Parameter passing tested with various inputs
- [ ] OUT parameters return expected values (as a single tuple/record; unpack with `:= CALL`)
- [ ] Default parameter behavior verified for all calling patterns
- [ ] Performance compared to source database baseline

---

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| OUT/INOUT keywords removed | Always preserve parameter modes exactly |
| Data type mismatches | Use Data Type Mapping Guide for proper mapping |
| Function not found | Use Function Mapping Guide or create custom function |
| Syntax errors after conversion | Reference SQL Syntax Reference |
| Dependency order issues | Maintain exact source file order — never reorder |
| OLTP patterns remaining | Re-read OLTP to OLAP Rewrite Guide |

---

**ALL SPECIFIC MIGRATION GUIDES (Oracle, DB2, SQL Server, PostgreSQL, MySQL) MUST BEGIN WITH A REFERENCE TO THIS GUIDE AND STATE THAT THEY FOLLOW ITS REQUIREMENTS.**

**Failure to follow these requirements will result in incomplete, broken, or non-functional migrations.**

**When in doubt, refer back to this guide first before consulting any other documentation.**
