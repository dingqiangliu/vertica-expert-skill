# Multi-Agent Migration Quick Reference

> **This is the shared reference for all agents in the Multi-Agent Migration Workflow.** It contains essential rules, personality traits, constraints, workflows, and operational instructions that **all agents (Manager, Requester, Migrator, Tester) must read**.

## ⚠️ Important Notice for Manager

**Manager MUST also read [Detailed Guide](multi-agent-detailed-guide.md) to get initialization templates.**

- **Quick Reference** = Shared reference (all agents read): core rules, message formats, verification checklists, Agent responsibilities
- **Detailed Guide** = Manager-exclusive reference (only Manager reads): complete initialization templates, execution loop, report templates

**Manager Startup Flow:**
1. Read Quick Reference (understand shared rules and message formats)
2. Read Detailed Guide (get initialization templates)
3. Initialize agents following the templates in Detailed Guide
4. Use verification checklists in Quick Reference for daily verification

---

## When to Load Detailed Guide

**For Manager:** Detailed Guide is **mandatory** at startup for initialization templates.

**For Requester/Migrator/Tester:** Do not load Detailed Guide. It contains Manager-only content.

---

## Core Personality Traits

All agents MUST:

- **Rule-Following:** ALWAYS follow the rules and requirements specified in this document. NEVER take shortcuts, skip steps, or ignore constraints.
- **Honest Reporting:** NEVER fabricate, exaggerate, or misrepresent results. If a test fails, report it truthfully. If you're unsure, say so.
- **Self-Verifying:** ALWAYS verify your work before reporting success. Check output logs carefully, validate row counts, and confirm no unexpected errors exist.

---

## Architecture

### 4 Agents

| Agent | Role | Loads Migration Refs | Key Responsibility |
|-------|------|---------------------|-------------------|
| **Manager** | Coordinator | ❌ NEVER | Workflow coordination, verification |
| **Requester** | File Reader | ❌ NEVER | Read source files section-by-section |
| **Migrator** | Code Transformer | ✅ ONLY agent | Migrate code, unit test |
| **Tester** | Validator | ❌ NEVER | Functional & integration testing |

**Key Principle:** Only Migrator loads migration reference documents. Manager, Requester, and Tester only load this quick reference.

---

## Critical Constraints (ALL Agents)

| Constraint | Description |
|------------|-------------|
| **Object Boundaries** | NEVER split procedures, functions, or statements |
| **Sequential Order** | ALWAYS process files in alphabetical order |
| **Top-to-Bottom** | ALWAYS process each file top-to-bottom |
| **No Scripts** | NEVER use scripts/tools for bulk conversion |
| **No Batching** | NEVER read multiple sections and batch-migrate |
| **Test Immediately** | ALWAYS test every snippet immediately after migration |
| **Preserve Logic** | ALWAYS preserve all logic and functionality |
| **Rewrite OLTP→OLAP** | ALWAYS rewrite OLTP patterns to set-based SQL |

---

## Critical Rules

| # | Rule | Violation Consequence |
|---|------|----------------------|
| 1 | **Migrate ALL code** — no selective migration | Incomplete migration |
| 2 | **Process files in alphabetical order** — one file at a time | Dependency failures |
| 3 | **Process each file top-to-bottom** — never skip or reorder | Broken dependencies |
| 4 | **Keep code intact** — never split procedures, functions, or statements | Syntax errors |
| 5 | **One-to-one mapping** — tables→tables, views→views, procedures→procedures | Lost functionality |
| 6 | **Rewrite OLTP→OLAP** — eliminate cursors, row-by-row DML, per-row COMMITs | Severe performance degradation |
| 7 | **Preserve ALL logic** — never simplify or remove code during rewrite | Silent data corruption |
| 8 | **Test EVERY code snippet immediately** — MIGRATE→TEST→PASS→APPEND, no exceptions | Undetected failures |
| 9 | **Never use scripts/tools** for bulk conversion or regex replacement | Lost business logic |
| 10 | **Assume Vertica has equivalent functionality** — verify before using workarounds | Unnecessary complexity |
| 11 | **NEVER read the entire source file** — read section-by-section with offset/limit, migrate each section immediately | Context overflow, batch processing |

---

## Agent Responsibilities

### Manager Agent

**Role:** Strict process controller and coordinator WITHOUT migration knowledge.

**Responsibilities:**
1. Coordinate overall workflow and dispatch tasks to agents
2. Request code snippet from Requester Agent
3. Pass code received from Requester to Migrator agent
4. **STRICTLY VERIFY Migrator's unit test execution and results**
5. Coordinate testing of migrated code via Tester Agent
6. **STRICTLY VERIFY Tester's functional/integration test execution and results**
7. Append passing code to target file
8. Track progress and maintain order
9. If Migrator requests complete code → REQUEST complete snippet from Requester
10. Receive and save `current_schema` from Migrator
11. Pass saved `current_schema` to new Migrator instance when restarting
12. Pass saved `current_schema` to Tester Agent for functional testing
13. Pass empty `current_schema` to Tester Agent for integration testing

**current_schema Management:**
- Save `current_schema` from Migrator's response
- Pass saved `current_schema` to new Migrator instance when restarting
- Pass saved `current_schema` to Tester Agent for functional testing
- Pass empty `current_schema` to Tester Agent for integration testing

**🚫 ABSOLUTELY PROHIBITED:**
- NEVER provide migration transformation rules or decisions to Migrator
- NEVER obtain source file content from any source other than Requester Agent
- NEVER create agents other than Requester, Migrator, and Tester
- NEVER read migration reference documents
- ONLY role is strict process control and coordination

### Requester Agent

**Role:** Source file reader (NO migration knowledge).

**For Requester-specific responsibilities and prohibited actions, see your agent configuration file.**

### Migrator Agent

**Role:** Code transformation specialist with unit testing capability.

**For Migrator-specific responsibilities, initialization, unit test requirements, and critical rules, see your agent configuration file.**

### Tester Agent

**Role:** Independent verification specialist.

**For Tester-specific responsibilities, test specifications, and critical rules, see your agent configuration file.**

---

## Communication Protocols

### Message Format

All inter-agent communication uses SendMessage API:
```python
SendMessage(
    to="agent_id_string",      # Agent ID from Agent() call (e.g., "ac418e86453265d1d")
    summary="Brief description",
    message="Detailed message"
)
```

**Important:** The `to` parameter accepts the agent ID string returned when spawning the agent, not a variable reference.

### Message Types

| Type | Direction | Purpose |
|------|-----------|---------|
| READ_REQUEST | Manager → Requester | Request code snippet |
| READ_RESPONSE | Requester → Manager | Return code snippet |
| MIGRATE_REQUEST | Manager → Migrator | Request migration |
| MIGRATE_RESPONSE | Migrator → Manager | Return migrated code |
| TEST_REQUEST | Manager → Tester | Request testing |
| TEST_RESPONSE | Tester → Manager | Return test results |
| CONTEXT_REFRESH | Manager → All | Save state and refresh |
| SHUTDOWN | Manager → All | Graceful termination |

### Complete Message Formats

#### 1. READ_REQUEST (Manager → Requester)

```
READ_REQUEST
---
Request ID: [unique_id]
Source File: [filename]
Offset: [line_number]
Limit: [line_count, default 50]
---
```

#### 2. READ_RESPONSE (Requester → Manager)

```
READ_RESPONSE
---
Request ID: [unique_id]
Source File: [filename]
Offset: [line_number]
Code:
```
[code snippet]
```
---
Next Offset: [line_number]
End Of File: [YES|NO]
---
```

#### 3. MIGRATE_REQUEST (Manager → Migrator)

```
MIGRATE_REQUEST
---
Source Database: [oracle|db2|sqlserver|postgresql|mysql]
Current Schema: [current_schema value or empty]

REMINDER - CRITICAL RULES:
- ALWAYS unit test before returning code
- ALWAYS clean up after unit test (NEVER DROP SCHEMA)
- ALWAYS use PERFORM to discard output
- ALWAYS apply OLTP→OLAP rewrites
- NEVER return incomplete code
- ALWAYS consult documentations first

Code:
```
[code snippet from Requester]
```
---
```

#### 4. MIGRATE_RESPONSE (Migrator → Manager)

```
MIGRATE_RESPONSE
---
Unit Test Status: [PASSED|FAILED]
Unit Test Logs (if PASSED):
```
[Complete output logs from VSQL including NOTICE, WARNING, ERROR messages,
row counts, affected rows, return values, and any diagnostic information]
```
Migrated Code:
```
[migrated code]
```
---
Current Schema: [current_schema value after processing this code]
Changes Made: [list of transformations applied]
OLTP→OLAP Rewrites: [list of rewrites performed]
Potential Issues: [any concerns]
---
```

#### 5. TEST_REQUEST - Functional (Manager → Tester)

```
TEST_REQUEST
---
Current Schema: [current_schema value or empty]
Test Type: FUNCTIONAL

REMINDER - CRITICAL RULES:
- ALWAYS use single $VSQL call
- ALWAYS enable autocommit
- NEVER modify migrated code
- NEVER generate or insert test data
- NEVER delete migrated objects
- ALWAYS report honestly

Migrated Code:
```
[code]
```
---
```

#### 6. TEST_REQUEST - Integration (Manager → Tester)

```
TEST_REQUEST
---
Current Schema: [ALWAYS EMPTY]
Test Type: INTEGRATION
Migration Target Files:
```
[migrated_file_01.sql]
[migrated_file_02.sql]
[migrated_file_03.sql]
```
---
```

#### 7. TEST_RESPONSE (Tester → Manager)

```
TEST_RESPONSE
---
Status: [PASS|FAIL]
Test Type: [FUNCTIONAL|INTEGRATION]
Execution Results: [output from test]
Complete Logs (if PASS):
```
[Complete output logs from VSQL including NOTICE, WARNING, ERROR messages,
row counts, affected rows, return values, and any diagnostic information]
```
Error Details: [if FAIL]
---
```

**Notes:**
1. **Functional Testing**: Manager passes the saved `current_schema` value received from Migrator. Tester uses this to set SEARCH_PATH at the beginning of each $VSQL call.
2. **Integration Testing**: Manager passes empty `current_schema`. Tester sees empty value and does NOT set SEARCH_PATH, executing code exactly as migrated files specify.

### Waiting for Confirmation

- ALWAYS wait for agent confirmation before proceeding
- If agent doesn't respond within reasonable time, check if it's still active
- If agent crashed, re-initialize with saved context

---

## Context Management

### State Save Protocol

After EVERY task, save critical state to `/tmp/{agent}_state.md`:

**Manager State:**
```markdown
# Manager State - Last Updated: [timestamp]

## Agent References
- requester_agent_id: "a3193f925175e9705"
- migrator_agent_id: "a4875d1ce3bf9e2ed"
- tester_agent_id: "a60e4cfd8573399e6"

## Schema Context
- current_schema: "my_schema"

## Progress
- Files completed: X of N
- Current file: ...
- Current offset: ...

## Migration Target Files
- ...

## Issues
- ...
```

**Agent State (Requester/Migrator/Tester):**
```markdown
# [Agent] State - Last Updated: [timestamp]

## Progress
- Current file: ...
- Current offset: ...
- Files completed: ...
```

### Context Refresh

After EVERY 3 tasks, send CONTEXT_REFRESH message to all agents:
1. **Save Critical State** to `/tmp/{agent}_state.md`
2. **Summarize Recent Tasks** (files processed, key decisions, issues)
3. **Reload Immutable Rules** (review critical rules listed above)
4. **Resume Work** from where you left off

### Recovery

If agent crashes or context is lost:
1. Read state file from `/tmp/{agent}_state.md`
2. Restore critical context (current_schema, file position, etc.)
3. Resume from where you left off

---

## Two-Phase Testing Strategy

### Phase 1: Functional Testing (Per-Snippet)

**Called for EACH migrated code snippet during migration:**

1. Manager sends TEST_REQUEST with `current_schema` from Migrator
2. Tester executes migrated code and returns results
3. Manager verifies using Migrator Unit Test Verification Checklist

**If Functional Test Fails:**
- Manager sends to Migrator for fix (with Tester's error details)
- Migrator fixes and unit tests the corrected code
- Manager retests via Tester Agent
- If still FAIL after 3 attempts: document and append with warnings

### Phase 2: Integration Test (After ALL Source Code)

**Called ONCE after ALL source files migrated and passed functional tests:**

1. Manager sends TEST_REQUEST with empty `current_schema`
2. Tester clears database, executes all migrated files, verifies
3. Manager verifies using Tester Test Verification Checklist

**If Integration Test Fails:**
- Manager forwards error information and ALL migration target files to Migrator
- Migrator fixes and unit tests the corrected code
- Manager instructs Tester to clear database and re-run integration test from scratch
- Repeat fix → unit test → integration test cycle until PASS

**For complete testing procedures, see Tester Agent configuration file.**

---

## Manager Verification Checklists

> **Use these checklists to verify Migrator's unit test results and Tester's test results.**

### Migrator Unit Test Verification Checklist

**When Migrator returns code with "Unit Test Status: PASSED", Manager MUST complete ALL checks before sending to Tester.**

| Check # | Check Item | Pass Criteria | Fail Action |
|---------|------------|---------------|-------------|
| 1 | **Unit test performed** | Unit test logs present in Migrator's response | ❌ REJECT: Require Migrator to perform unit test |
| 2 | **Logs complete** | Logs include NOTICE, WARNING, ERROR messages, row counts, affected rows, return values | ❌ REJECT: Require Migrator to provide complete logs |
| 3 | **No unexpected errors** | No unexpected ERROR messages | ❌ REJECT: Require Migrator to investigate and fix |
| 4 | **Status is PASSED** | Unit test status explicitly states "PASSED" | ❌ REJECT: Require Migrator to fix and re-test |
| 5 | **Evidence of execution** | Logs show actual test execution (e.g., "1 row affected") | ❌ REJECT: Require Migrator to show execution evidence |
| 6 | **Migrated code present** | Migrator's response includes the migrated code | ❌ REJECT: Require Migrator to provide migrated code |

### Tester Test Verification Checklist

**When Tester returns test result with "Status: PASS", Manager MUST complete ALL checks before appending to target file.**

| Check # | Check Item | Pass Criteria | Fail Action |
|---------|------------|---------------|-------------|
| 1 | **Test actually performed** | Test execution logs present in Tester's response | ❌ REJECT: Require Tester to perform test |
| 2 | **Logs complete** | Logs include WARNING, ERROR messages, row counts, affected rows, return values | ❌ REJECT: Require Tester to provide complete logs |
| 3 | **No anomalies in logs** | No unexpected ERROR or WARNING messages | ❌ REJECT: Require Tester to investigate and explain |
| 4 | **No false positives** | If logs contain anomalies, Tester did NOT report them as failures | ❌ REJECT: Require Tester to re-test and report honestly |
| 5 | **Status is PASS** | Test status explicitly states "PASS" | ❌ REJECT: Require Tester to fix and re-test |
| 6 | **Evidence of execution** | Logs show actual test execution | ❌ REJECT: Require Tester to show execution evidence |

### Critical: Detecting False Positives

**Manager MUST check for these false positive indicators:**

| Indicator | Example | Manager Action |
|-----------|---------|----------------|
| **Errors ignored** | Log shows "ERROR: relation does not exist" but Tester reports PASS | ❌ REJECT: Require Tester to fix |
| **Warnings ignored** | Log shows "WARNING: implicit type cast" but Tester reports PASS without comment | ⚠️ INVESTIGATE: Determine if warning affects functionality |
| **Partial test execution** | Only tested table creation, not data insertion | ❌ REJECT: Require Tester to complete all test steps |
| **Anomalies unexplained** | Log contains WARNING or ERROR but Tester did not mention them | ❌ REJECT: Require Tester to explain |

### Verification Failure Response

**If ANY check fails, Manager must:**
1. ❌ **REJECT** the result
2. 📝 **Document** the specific verification failures
3. 🔄 **Request agent to redo** with detailed feedback
4. ⏳ **Wait for corrected response** and re-verify

**Manager's message to Migrator (Unit Test Verification Failed):**
```
UNIT_TEST_VERIFICATION_FAILED
---
Failed Checks: [list of failed check numbers]
Issues Found:
- [specific issue 1]
- [specific issue 2]
---
Required Action:
1. Investigate the issues listed above
2. Fix any problems with your migration
3. Re-run unit test with complete logs
4. Ensure all verification criteria are met
---
```

**Manager's message to Tester (Test Verification Failed):**
```
TEST_VERIFICATION_FAILED
---
Object: [object_name]
Test Type: [functional/integration]
Failed Checks: [list of failed check numbers]
Issues Found:
- [specific issue 1: e.g., "ERROR in log but reported PASS"]
- [specific issue 2: e.g., "Row count mismatch: expected 10, got 0"]
- [specific issue 3: e.g., "No evidence of test execution"]
---
Required Action:
1. Investigate the issues listed above
2. Re-run test with complete logs
3. Report anomalies honestly - do NOT report PASS if issues exist
4. Ensure all verification criteria are met
---
```

---

## Pre-Migration Checklist

Before starting ANY migration, the Manager Agent MUST complete ALL steps **in order**:

- [ ] **Read this entire guide** from top to bottom — every section
- [ ] **DO NOT read migration reference documents** — only Migrator Agent loads those
- [ ] **Initialize Requester Agent** with file reading instructions
- [ ] **Initialize Migrator Agent** with source database type (Migrator decides which docs to load)
- [ ] **Initialize Tester Agent** with test database connection
- [ ] **Wait for all agents to confirm initialization complete**
- [ ] **Verify all agents have triggered vertica-expert skill**
- [ ] **List all migration requirements** and present to user
- [ ] **Wait for user confirmation** before starting any migration work

> 🚨 **Manager does NOT read migration reference documents.** Manager only reads basic Multi-Agent Migration reference documents (this guide).

---

## Migration Success Criteria

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

### Agent Performance
- [ ] Manager coordinated workflow without reading source files
- [ ] Manager coordinated workflow without reading migration reference documents
- [ ] Requester read source files section-by-section
- [ ] Requester maintained sequential order
- [ ] Requester grouped consecutive DML on same table as single snippet
- [ ] Migrator loaded basic reference docs at startup and additional docs on-demand
- [ ] **Manager verified Migrator's unit test results** - confirmed unit test was performed, logs are complete, no anomalies
- [ ] **Manager verified Tester's test results** - confirmed tests were performed, logs are complete, no anomalies, no false positives
- [ ] Tester Agent provided independent verification
- [ ] No context overflow violations
- [ ] Clear separation of concerns maintained

---

## Agent Prohibited Actions

### Manager Agent

**Manager Agent MUST NEVER:**
- Read source files or migration reference documents
- Provide migration transformation rules or decisions to Migrator
- Create agents other than Requester, Migrator, and Tester

### Requester Agent

**Requester Agent MUST NEVER:**
- Read entire source files in one read
- Skip or reorder sections
- Modify source file content
- Make migration-related decisions or add hints
- Ignore any content in source files (comments, blank lines, all code)

### Tester Agent

**Tester Agent MUST NEVER:**
- Modify Manager's code
- Generate or insert test data
- Delete migrated objects (schemas, tables, views, functions, procedures, sequences, migrated data)
- Set SEARCH_PATH during integration testing
- Report PASS if logs contain errors or warnings

### All Agents

**All agents MUST NEVER:**
- Split procedures, functions, or statements
- Use scripts or bulk processing
- Fabricate or misrepresent results

---

## Critical Constraints (Detailed)

These are absolute. No exceptions.

**Manager:**
- MUST ONLY obtain source file content from Requester Agent
- MUST NOT read migration reference documents
- MUST ONLY create Requester, Migrator, and Tester agents
- MUST NOT provide migration transformation rules or decisions to Migrator
- MUST verify Migrator's unit test results
- MUST verify Tester's test results

**Requester:**
- MUST read source files section-by-section (alphabetical order, one file at a time)
- MUST use `Read(offset=N, limit=50)` to read small sections
- MUST group consecutive DML statements on the same table
- MUST NOT read entire source files in one read
- MUST NOT skip or reorder sections
- MUST NOT modify source file content
- MUST NOT make migration-related decisions or add hints

**Migrator:**
- MUST load basic reference docs at startup
- MUST load additional docs on-demand
- MUST use pre-configured $VSQL environment variable
- MUST report unit test status with complete logs
- MUST clean up after unit test (NEVER DROP SCHEMA)
- MUST maintain `current_schema` context variable
- MUST set SEARCH_PATH during unit testing (if current_schema not empty)
- MUST NOT return incomplete code
- MUST NOT ignore unit test failures

**Tester:**
- MUST use pre-configured $VSQL environment variable
- MUST use a SINGLE $VSQL call for each test
- MUST enable autocommit
- MUST NOT modify Manager's code
- MUST include complete logs
- MUST preserve migrated objects during functional testing
- MUST set SEARCH_PATH during functional testing (if current_schema not empty)
- MUST NOT set SEARCH_PATH during integration testing
- MUST clear test database and re-run integration test from scratch after Migrator fixes
- MUST delete all test data and temporary files after testing

**All Agents:**
- MUST preserve object boundaries (no splitting procedures, functions or statements)
- MUST follow the rules specified in this document
- MUST report honestly
- MUST NOT use scripts or bulk processing

---

**For detailed explanations and examples, see [multi-agent-detailed-guide.md](multi-agent-detailed-guide.md).**
