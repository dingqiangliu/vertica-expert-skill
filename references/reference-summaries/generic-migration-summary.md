# Generic Migration Guide - Summary

> **This is an agent-optimized summary of [generic-migration-guide.md](../generic-migration-guide.md).** This summary contains ALL information needed for migration decisions. The full document is for human reference with detailed examples.

---

## Core Rules (MANDATORY)

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **Migrate ALL objects** — no selective migration | Incomplete migration |
| 2 | **Process files in alphabetical order** — one file at a time | Dependency failures |
| 3 | **Process each file top-to-bottom** — never skip or reorder | Broken dependencies |
| 4 | **Keep objects intact** — never split procedures, functions, or statements | Syntax errors |
| 5 | **One-to-one mapping** — tables→tables, views→views, procedures→procedures | Lost functionality |
| 6 | **Rewrite OLTP→OLAP** — eliminate cursors, row-by-row DML, per-row COMMITs | Severe performance degradation |
| 7 | **Preserve ALL logic** — never simplify, remove code, or eliminate conditional branches/validation/edge cases | Silent data corruption |
| 8 | **Test EVERY object immediately** — MIGRATE→TEST→PASS→APPEND, no exceptions | Undetected failures |
| 9 | **Never use scripts/tools** for bulk conversion or regex replacement; **MUST rewrite step-by-step using editor tools** | Lost business logic |
| 10 | **Assume Vertica has equivalent functionality** — verify before using workarounds | Unnecessary complexity |
| 11 | **NEVER read the entire source file** — read section-by-section with offset/limit, migrate each object immediately | Context overflow, batch processing |

### Pre-Migration Requirements (CRITICAL)

**DO NOT read any source files until ALL conditions are met:**
1. Read ALL relevant reference documents (see [Reference Documents](#reference-documents))
2. List ALL migration requirements to user
3. **Wait for user confirmation** before starting any migration work

### Critical Constraints (ABSOLUTE)

- **NEVER use sub-agents** — perform ALL work in the main session
- **NEVER complain about task size or token usage**
- **NEVER modify the original file ordering**
- **ALWAYS test immediately** — **check COMPLETE logs** (not partial)
- **ALWAYS verify through testing and consult reference documentation** before giving up
- **NEVER deviate from any rule** in this guide
- **NEVER read the entire source file at once** — use `Read` with `offset` and `limit`
- **NEVER make excuses** for reading full files or batch processing
- **NEVER append untested or failing code** to target file without documenting the failure

### Failure Handling (MANDATORY)

When test fails: **NEVER ASSUME** unsupported — verify → consult docs → retry → if still failing, **document and append** to target file. **NEVER abandon a test.**

---

## Object Type Requirements

| Object Type | Action |
|-------------|--------|
| Tables | Migrate with all constraints (PK, FK, UNIQUE, CHECK). **Comment out `ON DELETE CASCADE` (not supported in Vertica)**. Do NOT add `SEGMENTED BY` or `UNSEGMENTED` clauses to CREATE TABLE statements — these are designed separately by Vertica DBA. **Exception**: Teradata `PRIMARY INDEX` → `ORDER BY col SEGMENTED BY HASH(col) ALL NODES` |
| Views | Migrate (including materialized views). **Preserve `ORDER BY` when `TOP` or `LIMIT` appears with `ORDER BY`** |
| Stored Procedures | Convert to PL/vSQL |
| Functions | **SQL functions = SINGLE EXPRESSION ONLY** (no queries/loops). Complex logic → PL/vSQL procedure or UDx |
| DML Statements | Migrate ALL (INSERT, UPDATE, DELETE, MERGE, COMMIT, ROLLBACK). **Capture return values directly** (no source-specific row count mechanisms) |
| Sequences | **Always preserve** — may be used in unseen locations |
| Constraints | **MUST** be in DDL: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK |
| Indexes | Comment out (do NOT discard or auto-create projections) |
| Triggers | **Comment out** (not supported in Vertica) |
| Synonyms | Convert to views or direct references |
| Database Links | Convert to external tables or ETL processes |

> ⚠️ **Constraints must NEVER be commented out or dropped.**

### Database-Specific Requirements

| Database | Rule |
|----------|------|
| **SQL Server** | Track `USE [dbname]` → prefix objects with database name as schema; No `USE` → strip `dbo.` prefix |
| **MySQL** | Track `USE database` → prefix objects with database name as schema; No `USE` → bare object names |

---

## Sequential Processing Rules

### Forbidden Behaviors (Anti-Patterns)
```
❌ NEVER read multiple sections of a source file and then batch-migrate them together
❌ NEVER say "the file is large, let me create a more efficient migration strategy"
❌ NEVER use Write tool to create the entire target file at once — use Edit/Append per object
❌ NEVER say "let me read ahead to understand the full context first"
```

### File Reading Rules
- ✅ Read source files **in alphabetical file name order** — one file at a time
- ✅ Use `Read` with `offset` and `limit` to read **one small section at a time** (e.g., `offset=1, limit=50`)
- ✅ After reading a section, **immediately** identify, migrate, test, and append the next complete object
- ✅ Then read the next section. Do NOT read further until the current object is done.
- ✅ **NEVER skip or jump** ahead in the source file
- ✅ **NEVER reorder** objects or statements

### Mandatory Per-Object Workflow
```
1. READ:   Read a small section of the source file (offset=N, limit=50)
2. IDENTIFY: Find the next complete object in this section
3. MIGRATE:  Convert the object to Vertica syntax
4. REWRITE:  Rewrite OLTP→OLAP patterns
5. TEST:     Execute the migrated object in Vertica immediately
6. PASS?:    IF test passes → APPEND to target file → go to next object
             IF test fails → fix, retest, then append
```

### Data Preservation During Testing
- ✅ **DO NOT DROP** migrated objects or data after individual testing — subsequent migrations may depend on them
- ✅ Clean up test environment **ONLY AFTER** all source files have been processed

---

## Test Methods by Object Type

| Object Type | Test Method | Log Check Requirements |
|-------------|------------|------------------------|
| Table | Execute `CREATE TABLE (...)` directly | Check for WARNING, ERROR messages |
| View | `CREATE VIEW ... AS ...` then `SELECT * FROM view LIMIT 0` | Verify view creation notice and query results |
| Stored Procedure | `CREATE PROCEDURE ...` then `CALL proc(...)` with test parameters | Check procedure creation notice, CALL output, and any RAISE NOTICE messages |
| Function | `CREATE FUNCTION ...` then `SELECT func(...)` with test parameters | Verify function creation notice and return value |
| DML | Execute statement, then verify with `SELECT COUNT(*)` or result check | Check row count affected and any trigger/notice messages |

> 🚨 **CRITICAL:** When using VSQL, always check the COMPLETE output. A successful execution may still contain WARNING or NOTICE messages that indicate potential issues.

---

## OLTP-to-OLAP Rewrite Patterns

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

---

## Absolutely Prohibited Actions

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
❌ NEVER use DEFAULT in parameter declarations — use procedure overloading instead
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

## Migration Procedure

### Step 1: Load Reference Documents
Read ALL relevant reference documents in priority order (see [Reference Documents](#reference-documents)).

### Step 2: List Requirements & Get Confirmation
List requirements & get user confirmation.

### Step 3: Process Source Files
Follow **Mandatory Per-Object Workflow**: Read section → Identify object → Migrate → Rewrite → Test → Append → Repeat.

### Step 4: Full Migration Testing
After ALL source files processed:
1. Clean test Vertica database
2. Execute ALL migrated target files **in file name order**
3. Check all error logs and fix issues
4. Verify all objects exist and are functional
5. Re-execute until fully successful

### Step 5: Generate Migration Report
Document:
- Total objects processed
- Objects successfully migrated
- Objects that failed (with reasons and attempted solutions)
- Performance recommendations

---

## Reference Documents (Priority Order)

| Priority | Document | When to Use |
|----------|----------|-------------|
| 1 | **This Guide** | ALWAYS — first |
| 2 | **OLTP to OLAP Rewrite Guide** | Procedural/OLTP code |
| 3 | **Source-specific migration guide** | Database-specific syntax |
| 4 | **SQL Syntax Reference** | Syntax questions |
| 5 | **Function Mapping Guide** | Function conversion |
| 6 | **Data Type Mapping Guide** | Type mapping and optimization |
| 7 | **User-Defined SQL Functions Guide** | SQL function development |
| 8 | **Stored Procedures Guide** | PL/vSQL development |
| 9 | **UDx Development Guide** | C++/Python/Java/R functions |
| 10 | **Query Optimization** | Performance tuning |

---

## Troubleshooting Guide

| Problem | Solution |
|---------|----------|
| OUT/INOUT keywords removed | Always preserve parameter modes exactly |
| Data type mismatches | Use Data Type Mapping Guide for proper mapping |
| Function not found | Use Function Mapping Guide or create custom function |
| Syntax errors / OLTP patterns remaining | Reference SQL Syntax / OLTP to OLAP Rewrite Guide |
| Dependency order issues | Maintain exact source file order — never reorder |

---

## Migration Success Criteria

- [ ] **100%** objects processed, tested individually, functional in Vertica, dependencies satisfied
- [ ] No syntax/runtime errors; functionality matches source; OLTP rewritten; performance meets/exceeds
- [ ] Complete migration log; all failures documented with reasons; final file validated

---

## When to Load Full Document

Load [generic-migration-guide.md](../generic-migration-guide.md) section by section when:
- Summary rules require combination in ways not shown in examples
- Your migration produces TODOs, placeholders, or uncertain logic
- Test results show unexpected behavior
- The code pattern involves 3+ interacting SQL features

How to load: `grep -n "^## \|^### " references/generic-migration-guide.md` → `Read offset=N limit=M` (load ONLY that section, NOT the entire file).
