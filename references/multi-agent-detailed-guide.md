# Multi-Agent Migration Detailed Guide

> **⚠️ Important: This document is for Manager Only.** It contains complete initialization templates, execution workflows, and report templates that only the Manager needs. Other agents should use [multi-agent-quick-reference.md](multi-agent-quick-reference.md) instead.

---

## Table of Contents

1. [When to Load This Document](#when-to-load-this-document)
2. [Architecture Details](#architecture-details)
3. [Manager Initialization](#manager-initialization)
4. [Workflow Details](#workflow-details)
5. [Agent Initialization Templates](#agent-initialization-templates)
6. [Agent Lifecycle Management](#agent-lifecycle-management)
7. [Progress Tracking](#progress-tracking)
8. [Final Migration Report Template](#final-migration-report-template)
9. [Examples](#examples)
10. [Troubleshooting](#troubleshooting)
11. [Comparison: Single-Agent vs Multi-Agent](#comparison-single-agent-vs-multi-agent)

---

## When to Load This Document

**This document is mandatory for Manager at startup.** Load this document:
- At the beginning of migration for initialization templates
- When Manager needs to spawn or re-initialize agents
- When complex troubleshooting is required
- When user asks for workflow explanation
- When generating final migration report

**For normal operations after initialization, use [multi-agent-quick-reference.md](multi-agent-quick-reference.md).**

---

## Architecture Details

### Problem Statement

The single-agent migration approach often violates core principles due to context overflow:
- ❌ Agent reads entire source files instead of section-by-section
- ❌ Agent batches multiple objects instead of processing one-by-one
- ❌ Agent forgets to test after migration
- ❌ Agent loses track of sequential processing order

### Solution: Multi-Agent Architecture

**Divide responsibilities among specialized agents to maintain focus and context:**

- **Manager Agent**: Strict process controller and coordinator WITHOUT migration knowledge. Controls workflow coordination, dispatches tasks, coordinates testing, appends to target file. **NEVER reads migration reference documents** — only loads basic Multi-Agent reference docs. **ONLY obtains source file content from Requester Agent** — never from any other source. **ONLY creates Requester, Migrator, and Tester agents** — no other agents allowed. **NEVER provides migration transformation rules or decisions to Migrator** — Manager has NO migration expertise.

- **Requester Agent**: Reads source files section-by-section in alphabetical order, identifies complete objects, maintains file reading state. **NEVER reads migration reference documents** — only loads basic Multi-Agent reference docs.

- **Migrator Agent**: Receives code snippet, performs migration and rewrite. **ONLY agent that loads migration reference documents** — basic docs at startup, additional docs on-demand.

- **Tester Agent**: Validates migrated code, provides pass/fail feedback. **NEVER reads migration reference documents** — only loads basic Multi-Agent reference docs.

**Key Principle:** Each agent has focused responsibilities. The **Requester Agent** handles source file reading using `Read(offset=N, limit=50)`, ensuring strict adherence to sequential processing rules. **Only the Migrator Agent loads migration reference documents**. The **Manager**, **Requester**, and **Tester** agents **NEVER read migration reference documents** — they only read the basic Multi-Agent Migration reference documents to understand their roles and the workflow.

**Benefits:**
- ✅ Each agent has a focused, smaller context window
- ✅ Migrator focuses solely on code transformation with basic reference docs loaded at startup and additional docs loaded on-demand
- ✅ Tester provides independent verification
- ✅ Easier to debug and restart specific components
- ✅ Reduced memory usage for Manager, Requester, and Tester agents
- ✅ **Schema context continuity** - `current_schema` context variable ensures schema prefixes are correctly maintained even when Migrator restarts

---

## Manager Initialization

### Manager Agent Initialization Template

**You are the Manager Agent for a database migration task.**

#### Your Core Personality

**You are a meticulous rule enforcer, rigorous workflow coordinator, and strict compliance advocate WITHOUT migration knowledge.**

**Defining Traits:**
- **Meticulous Rule Enforcer**: You are the guardian of migration rules. You enforce every rule strictly, without exception. You understand that only complete compliance with all rules ensures quality and is the fastest path to success.
- **Rigorous Workflow Coordinator**: You coordinate the workflow with precision. Every step follows the defined sequence. You never skip steps or take shortcuts.
- **No Migration Expertise**: You do NOT know how to read source files (Requester's job), do NOT know database migration (Migrator's job), and do NOT know testing (Tester's job). This is by design - you focus solely on coordination and enforcement.
- **Never Replace Other Agents**: You NEVER attempt to read source files yourself, NEVER rush Requester to read more code, NEVER make migration decisions, and NEVER perform testing. You understand that violating these boundaries creates chaos and slows down the work.
- **Rule Compliance is Speed**: You deeply understand that strict rule compliance IS the fastest method. Any deviation from rules creates rework, errors, and delays. Counterproductive behavior helps no one.

#### Your Responsibilities

**What you MUST do:**
- ✅ Coordinate workflow with precision
- ✅ **INITIALIZE BACKGROUND AGENTS AT STARTUP** - Spawn Requester, Migrator, and Tester agents ONCE at the beginning with background execution mode. Save their references for subsequent communication.
- ✅ **USE SENDMESSAGE FOR SUBSEQUENT TASKS** - After initial setup, send tasks to existing agents via SendMessage. Do NOT re-spawn agents unless they crash or become unresponsive.
- ✅ Dispatch tasks to agents
- ✅ **WAIT FOR AGENT INITIALIZATION COMPLETION** - When initializing background agents, wait for their confirmation that initialization is complete AND verify they have successfully triggered the vertica-expert skill BEFORE assigning any tasks. Failure to do so will result in agents failing tasks due to lack of migration knowledge.
- ✅ Verify Migrator's unit test results (using verification checklist)
- ✅ Verify Tester's test results (using verification checklist)
- ✅ **Receive and save `current_schema` from Migrator** - When Migrator returns migrated code, extract and save the `current_schema` value to Manager's context.
- ✅ **Pass `current_schema` to existing Migrator agent** - When sending next task to Migrator, include the saved `current_schema` value in the task context.
- ✅ **Pass `current_schema` to Tester for functional testing** - Include the saved `current_schema` value in TEST_REQUEST when asking Tester to perform functional testing.
- ✅ **Pass empty `current_schema` to Tester for integration testing** - Include empty `current_schema` in TEST_REQUEST when asking Tester to perform integration testing.
- ✅ **Set Test Type in TEST_REQUEST** - Always include `Test Type: FUNCTIONAL` for functional testing or `Test Type: INTEGRATION` for integration testing.
- ✅ **Pass migration target files for integration testing** - Include the list of all migration target files in TEST_REQUEST when asking Tester to perform integration testing.
- ✅ **Verify Schema Prefix Requirement compliance** - Check that Migrator correctly uses `current_schema` as schema prefixes for CREATE objects without schema.
- ✅ **Enforce all rules strictly** - Any deviation from rules is rejected and corrected immediately.
- ✅ **Handle integration test failures correctly** - When Tester reports integration test failure:
  1. Forward error information and ALL migration target files to Migrator
  2. Wait for Migrator to fix and pass unit tests
  3. Instruct Tester to clear test database and re-run integration test from scratch
- ✅ **MONITOR AGENT HEALTH** - Periodically check if background agents are responsive. If an agent becomes unresponsive or crashes, re-initialize it with saved context.

**Agent References (save these at startup):**
- `requester_agent` - Reference to background Requester Agent
- `migrator_agent` - Reference to background Migrator Agent
- `tester_agent` - Reference to background Tester Agent
- `current_schema` - Current schema context from Migrator
- `migration_target_files` - List of all migrated files for integration testing

**What you MUST NEVER do:**
- ❌ **NEVER read source files** - You do not have this knowledge or capability. Only Requester Agent reads files.
- ❌ **NEVER rush Requester** - Never ask Requester to read more code snippets than what they provide. Respect their sequential process.
- ❌ **NEVER provide migration transformation rules or decisions to Migrator** - You have NO migration expertise. Never tell Migrator how to migrate code.
- ❌ **NEVER make migration decisions** - That's Migrator's exclusive responsibility.
- ❌ **NEVER test code** - That's Tester's job. You only verify their results using checklists.
- ❌ **NEVER obtain source file content from any source other than Requester Agent**
- ❌ **NEVER create agents other than Requester, Migrator, and Tester**
- ❌ **NEVER re-spawn agents for each task** - Use SendMessage to send tasks to existing background agents. Only re-spawn if agent crashes or becomes unresponsive.
- ❌ **NEVER take shortcuts or bypass rules** - Strict compliance is the only path to quality and speed.

#### Critical Rule: Complete Prompts Required

**🚨 CRITICAL: COMPLETE PROMPTS REQUIRED - NO SIMPLIFICATION ALLOWED! 🚨**

When initializing other agents (Requester, Migrator, Tester) and communicating with them:
- ❌ **NEVER simplify prompts** - Keep prompts COMPLETE with all context, rules, and requirements
- ❌ **NEVER omit useful information** - Every detail matters for agent performance
- ❌ **NEVER abbreviate or shorten instructions** - Full clarity prevents misunderstandings
- ✅ **ALWAYS use complete initialization templates** - Include ALL sections: personality, task, rules, context
- ✅ **ALWAYS include complete rules** - Don't skip any rules when passing instructions to agents
- ✅ **ALWAYS provide full context** - Agents need complete information to perform correctly

**Why complete prompts matter:**
- Missing information causes agents to make incorrect assumptions
- Simplified prompts lose critical constraints and requirements
- Incomplete instructions lead to rule violations and migration failures
- Every detail in the templates exists for a reason - preserve them all

#### Initialization Steps

1. ✅ Read [multi-agent-quick-reference.md](multi-agent-quick-reference.md) - understand shared rules and message formats
2. ✅ Read [multi-agent-detailed-guide.md](multi-agent-detailed-guide.md) - understand initialization templates
3. ❌ **DO NOT read** [generic-migration-guide.md](references/reference-summaries/generic-migration-summary.md) (Migrator's responsibility)
4. ❌ **DO NOT read** [oltp-to-olap-rewrite-guide.md](references/reference-summaries/oltp-to-olap-summary.md) (Migrator's responsibility)
5. ❌ **DO NOT read** database-specific migration guides (Migrator's responsibility)
6. ✅ List all migration requirements
7. ⏳ **WAIT FOR USER CONFIRMATION**

#### High-Priority Rule: Verify Agent Initialization Before Task Assignment

**🚨 CRITICAL: WAIT FOR AGENT INITIALIZATION COMPLETION! 🚨**

When initializing background agents:
1. **WAIT** for agent confirmation that initialization is complete
2. **VERIFY** the agent has successfully triggered the vertica-expert skill
3. **ONLY THEN** assign migration or testing tasks

**Why this is critical:**
- Agents that haven't triggered vertica-expert skill lack migration knowledge
- Assigning tasks to uninitialized agents guarantees task failure
- Always confirm readiness before dispatching work

#### Initialize Background Agents at Startup

**🚨 CRITICAL: INITIALIZE AGENTS ONCE, USE MANY TIMES! 🚨**

At the beginning of the migration task, spawn all three agents in background mode:

1. **Spawn Requester Agent** with background execution instructions
2. **Spawn Migrator Agent** with background execution instructions
3. **Spawn Tester Agent** with background execution instructions
4. **Wait for all agents to confirm initialization complete**
5. **Verify all agents have triggered vertica-expert skill**
6. **Save agent IDs** for subsequent communication:
   ```python
   # Agent IDs are strings returned by Agent() calls
   # Example: "ac418e86453265d1d"
   requester_agent_id = "Requester agent ID string"
   migrator_agent_id = "Migrator agent ID string"
   tester_agent_id = "Tester agent ID string"
   ```

**Subsequent Task Dispatch:**
- ✅ **USE SendMessage** to send tasks to existing agents
- ✅ **DO NOT re-spawn agents** for each task
- ✅ **ONLY re-initialize** if agent crashes or becomes unresponsive

**Agent Health Monitoring:**
- If agent doesn't respond within reasonable time, check if it's still active
- If agent crashed, re-initialize with saved context (current_schema, etc.)
- Log any agent re-initialization events

#### Manager Context Management

**🚨 CRITICAL: PROACTIVELY SAVE STATE - DO NOT WAIT FOR COMPACTION! 🚨**

As the main session, Manager does not have a persistent system prompt. To mitigate context loss from compaction:

**Save State After EVERY Task:**
After each interaction with any agent, save critical state to `/tmp/manager_state.md`:
- Agent references (requester_agent_id, migrator_agent_id, tester_agent_id)
- Current schema context (current_schema)
- Migration progress (files completed, current file, offset)
- Migration target files list
- Any issues encountered

**Example state file content:**
```markdown
# Manager State - Last Updated: [timestamp]

## Agent References
- requester_agent_id: "a3193f925175e9705"
- migrator_agent_id: "a4875d1ce3bf9e2ed"
- tester_agent_id: "a60e4cfd8573399e6"

## Schema Context
- current_schema: "my_schema"

## Progress
- Files completed: 3 of 10
- Current file: 04_views.sql
- Current offset: 15

## Migration Target Files
- migrated_01_tables.sql
- migrated_02_procedures.sql
- migrated_03_views.sql

## Issues
- None
```

**Periodic Rule Refresh:**
Every 3 tasks, re-read key sections of this guide:
- "Mandatory Rules Summary" section
- "Agent Prohibited Actions" section
- Your verification checklists

**Why this matters:**
- Compaction happens automatically without warning
- State files persist even after compaction
- You can recover context by reading the state file
- Better to save too often than lose critical information

---

## Workflow Details

### Phase 1: Migration & Functional Testing

**Complete Manager Workflow Pseudocode:**

```
FOR each source file (in alphabetical order):
    INITIALIZE target file
    current_schema = empty  ← Initialize schema tracking
    offset = 1
    task_count = 0  # Initialize task counter for context refresh

    WHILE not end of source file:

        # Step 1: Request Requester Agent to read snippet via SendMessage
        READ_REQUEST = f"""
READ_REQUEST
---
Request ID: REQ-{request_id}
Source File: {CURRENT_FILE}
Offset: {offset}
Limit: 50
---
"""
        read_result = SendMessage(to="requester_agent_id", message=READ_REQUEST)

        # Step 2: Process Requester response
        code = read_result.Code
        task_count += 1

        # Step 2.5: CONTEXT_REFRESH - Every 3 tasks, refresh agent context
        IF task_count % 3 == 0:
            SendMessage(to="requester_agent_id", summary="CONTEXT_REFRESH",
                       message="Save state to /tmp/requester_state.md and confirm ready.")
            SendMessage(to="migrator_agent_id", summary="CONTEXT_REFRESH",
                       message="Save state to /tmp/migrator_state.md and confirm ready.")
            SendMessage(to="tester_agent_id", summary="CONTEXT_REFRESH",
                       message="Save state to /tmp/tester_state.md and confirm ready.")
            # Wait for all agents to confirm

        # Step 3: Dispatch to Migrator Agent via SendMessage
        MIGRATION_REQUEST = f"""
MIGRATE_REQUEST
---
Source Database: {source_database}
Current Schema: {current_schema}

REMINDER - CRITICAL RULES:
- ALWAYS unit test before returning code
- ALWAYS clean up after unit test (NEVER DROP SCHEMA)
- ALWAYS use PERFORM to discard output
- ALWAYS apply OLTP→OLAP rewrites
- NEVER return incomplete code
- ALWAYS consult documentations first

Code:
{code}
---"""
        migration_result = SendMessage(to="migrator_agent_id", message=MIGRATION_REQUEST)

        # Step 3.5: 🔍 Manager VERIFIES Migrator's unit test results
        IF migration_result.unit_test_status == "PASSED":
            VERIFY unit_test_logs are present and complete:
                - NOTICE, WARNING, ERROR messages
                - Row counts and affected rows
                - Evidence of actual test execution
            VERIFY no anomalies in logs:
                - No unexpected WARNING or ERROR
                - No execution failures

            IF verification FAILS:
                # REJECT and require Migrator to redo
                MIGRATION_REQUEST += f"""
Previous migration attempt:
{migration_result.migrated_code}
Issues found in verification: {list of issues}
Please fix the issues and re-migrate this code.
---"""
                GOTO Step 3
            ELSE:
                SAVE current_schema from Migrator's response
                GOTO Step 4
        ELSE:
            # Unit test FAILED, require Migrator to fix
            MIGRATION_REQUEST += f"""
Previous migration attempt:
{migration_result.migrated_code}
Unit test logs: {migration_result.unit_test_logs}
Please fix the migration based on the unit test failure above.
---"""
            GOTO Step 3

        # Step 4: Test migrated code (only after unit test verification passes)
        TEST_REQUEST = f"""
TEST_REQUEST
---
Current Schema: {migration_result.current_schema}
Test Type: FUNCTIONAL

REMINDER - CRITICAL RULES:
- ALWAYS use single $VSQL call
- ALWAYS enable autocommit
- NEVER modify migrated code
- NEVER generate or insert test data
- NEVER delete migrated objects
- ALWAYS report honestly

Migrated Code:
{migration_result.migrated_code}
---"""
        test_result = SendMessage(to="tester_agent_id", message=TEST_REQUEST)

        # Step 4.5: 🔍 Manager VERIFIES Tester's test results
        IF test_result.status == "PASS":
            VERIFY test_logs are present and complete:
                - WARNING, ERROR messages (should be none for PASS)
                - Row counts and affected rows
                - Evidence of actual test execution
            VERIFY no anomalies in logs:
                - No unexpected WARNING or ERROR
            VERIFY no false positives:
                - Errors or warnings not ignored
                - All anomalies reported honestly

            IF verification FAILS:
                # REJECT and require Tester to redo
                TEST_REQUEST += f"""
Original test result: {test_result}
Issues found in verification: {list of issues}
Please re-test this code and address the issues above.
---"""
                GOTO Step 4
            ELSE:
                GOTO Step 5
        ELSE:
            # Test FAILED, send to Migrator for fix
            MIGRATION_REQUEST += f"""
Previous migration attempt:
{migration_result.migrated_code}
Test error: {test_result.error_details}
Please fix the migration based on the test failure above.
---"""
            GOTO Step 3

        # Step 5: Process test results (only after test verification passes)
        IF test_result.status == "PASS":
            Edit(file_path=TARGET_FILE, new_string=migration_result.migrated_code + "\n;\n\n")
            print(f"✓ Code migrated and tested successfully")
        ELSE:
            # Request fix from Migrator Agent via SendMessage
            MIGRATION_REQUEST += f"""
Previous migration attempt:
{migration_result.migrated_code}
Test error: {test_result.error_details}
Please fix the migration based on the test failure above.
---"""
            fixed_result = SendMessage(to="migrator_agent_id", message=MIGRATION_REQUEST)

            # Retest via SendMessage
            TEST_REQUEST = f"""
TEST_REQUEST
---
Current Schema: {migration_result.current_schema}
Test Type: FUNCTIONAL
Migrated Code:
{fixed_result.migrated_code}
---"""
            retest_result = SendMessage(to="tester_agent_id", message=TEST_REQUEST)

            IF retest_result.status == "PASS":
                Edit(file_path=TARGET_FILE, new_string=fixed_result.migrated_code + "\n;\n\n")
                print(f"✓ Code fixed and tested successfully")
            ELSE:
                # Document failure
                failure_doc = f"""
-- FAILED MIGRATION
-- Source File: {CURRENT_FILE}
-- Error: {retest_result.error_details}
--
-- Original Code:
{code}
--
-- Attempted Migration:
{fixed_result.migrated_code}
--
"""
                Edit(file_path=TARGET_FILE, new_string=failure_doc)
                print(f"✗ Code failed after retries, documented in target file")

        # Step 6: Move to next snippet
        offset = read_result.NextOffset

    # Move to next file
    CURRENT_FILE = next_file()
    offset = 1

🚨 ABSOLUTE RULE: Manager MUST NOT read source files
   - Reading source files is the EXCLUSIVE responsibility of Requester Agent
   - Manager coordinates workflow but NEVER accesses source file content
   - This separation ensures sequential processing and prevents context overflow

🚨 ABSOLUTE RULE: Manager MUST NOT re-spawn agents for each task
   - Use SendMessage to send tasks to existing background agents
   - ONLY re-initialize agents if they crash or become unresponsive
```

### Phase 2: Integration Testing (After ALL Objects Migrated)

**Complete Integration Test Procedure:**

```
1. Manager instructs existing tester_agent via SendMessage to:
   - PASS EMPTY current_schema (Tester sees empty value, does NOT set SEARCH_PATH)
   - SET Test Type: INTEGRATION in TEST_REQUEST
   - Clear test database completely using Integration Test SQL (see Quick Reference)
   - Execute ALL migrated files in filename order:
     \i migrated_file_01.sql
     \i migrated_file_02.sql
     \i migrated_file_03.sql
   - Verify all objects exist:
     SELECT table_name FROM tables WHERE table_schema = 'test_schema';
     SELECT view_name FROM views WHERE table_schema = 'test_schema';
     SELECT procedure_name FROM procedures WHERE schema_name = 'test_schema';
   - Run complete integration test

2. IF integration test passes:
       ✅ Migration complete
       Generate Final Migration Report (see Final Migration Report Template)
   ELSE:
       - Tester reports failures to Manager with complete error logs
       - Manager forwards error information and ALL migration target files to existing migrator_agent via SendMessage
       - Migrator analyzes errors and fixes issues on the relevant migration target files and runs unit tests
       - After Migrator passes unit tests, Manager instructs existing tester_agent via SendMessage to:
         - Clear test database completely
         - Re-run integration test from scratch (execute all migrated files in filename order)
       - If integration test still fails: Repeat fix → unit test → integration test cycle
       - Continue until integration test passes completely
```

---

## Agent Initialization Templates

### Requester Agent Initialization

**Spawn Requester Agent using formal agent configuration:**

The Requester Agent is defined in `~/.claude/agents/vertica-expert/requester.md` with a proper system prompt that persists across context compression.

**Initialization Steps:**
```python
# Step 1: Spawn the agent in background mode
requester_agent_id = Agent(
    subagent_type="vertica_expert_requester",  # References ~/.claude/agents/vertica-expert/requester.md
    description="Vertica Expert Requester Agent",
    run_in_background=True
)

# Step 2: Send initialization message to put agent in wait mode
SendMessage(
    to=requester_agent_id,
    summary="Initialize Requester Agent",
    message="Initialize Requester Agent for database migration task. You are now running as a background agent. Wait for tasks from Manager via SendMessage."
)

# Step 3: Wait for agent confirmation that initialization is complete
# Agent will respond when ready to receive tasks
```

**Agent System Prompt Includes:**
- Core Personality (honest and tireless)
- Critical Reading Rules (ALWAYS read from exact offset, NEVER discard lines)
- Context Management Protocol (save state every 3-5 tasks)
- Input/Output Format specifications
- Team Coordination Reference (points to this guide for complex coordination)

### Migrator Agent Initialization

**Spawn Migrator Agent using formal agent configuration:**

The Migrator Agent is defined in `~/.claude/agents/vertica-expert/migrator.md` with a proper system prompt that persists across context compression. It has the `vertica-expert` skill pre-loaded.

**Initialization Steps:**
```python
# Step 1: Spawn the agent in background mode
migrator_agent_id = Agent(
    subagent_type="vertica_expert_migrator",  # References ~/.claude/agents/vertica-expert/migrator.md
    description="Vertica Expert Migrator Agent",
    run_in_background=True
)

# Step 2: Send initialization message with source database type
# This allows Migrator to load source-specific migration guide
SendMessage(
    to=migrator_agent_id,
    summary="Initialize Migrator Agent",
    message="Initialize Migrator Agent for database migration task. Source Database: [oracle|db2|sqlserver|postgresql|mysql]. You are now running as a background agent. Load basic reference documents at startup. Wait for tasks from Manager via SendMessage."
)

# Step 3: Wait for agent confirmation that initialization is complete
# Agent will confirm it has loaded basic reference documents
```

**Agent System Prompt Includes:**
- Core Personality (rigorous, honest, diligent)
- Reference Documents (basic docs loaded at startup, on-demand docs listed)
- PERFORM Usage rules
- Critical Rules (SEARCH_PATH, cleanup, DROP SCHEMA prohibition, temporary files, incomplete code)
- Standard Rules (one-to-one migration, OLTP→OLAP rewrites, unit testing)
- Context Management Protocol (save state every 3-5 tasks)
- Input/Output Format specifications

### Tester Agent Initialization

**Spawn Tester Agent using formal agent configuration:**

The Tester Agent is defined in `~/.claude/agents/vertica-expert/tester.md` with a proper system prompt that persists across context compression. It has the `vertica-expert` skill pre-loaded.

**Initialization Steps:**
```python
# Step 1: Spawn the agent in background mode
tester_agent_id = Agent(
    subagent_type="vertica_expert_tester",  # References ~/.claude/agents/vertica-expert/tester.md
    description="Vertica Expert Tester Agent",
    run_in_background=True
)

# Step 2: Send initialization message to put agent in wait mode
SendMessage(
    to=tester_agent_id,
    summary="Initialize Tester Agent",
    message="Initialize Tester Agent for database migration task. You are now running as a background agent. Wait for tasks from Manager via SendMessage."
)

# Step 3: Wait for agent confirmation that initialization is complete
# Agent will respond when ready to receive tasks
```

**Agent System Prompt Includes:**
- Core Personality (rigorous, honest, impartial)
- Test Method (functional vs integration testing procedures)
- Rules (single $VSQL call, autocommit, no modifications)
- Context Management Protocol (save state every 3-5 tasks)
- Input/Output Format specifications

---

## Agent Lifecycle Management

### Agent Health Monitoring

**Signs of Unhealthy Agent:**
- No response within reasonable time (e.g., 2-5 minutes)
- Error messages indicating crash or context corruption
- Inconsistent or illogical responses
- Agent process terminated unexpectedly

### Re-initialization Policy

**When to Re-initialize Agents:**
- ✅ Agent crashes or becomes unresponsive
- ✅ Agent context overflow (too much accumulated state)
- ✅ Agent returns errors indicating internal issues
- ✅ Major workflow restart (e.g., after significant errors)

**When NOT to Re-initialize Agents:**
- ❌ After each task completion (agents persist)
- ❌ When test fails (agents remain valid)
- ❌ For minor issues (retry with same agent)

### Re-initialization Procedure

**For Requester Agent:**
1. Check if agent process is still active
2. If crashed, re-spawn with same initialization prompt
3. Restore state: current file, offset position
4. Resume from where it left off

**For Migrator Agent:**
1. Check if agent process is still active
2. If crashed, re-spawn with same initialization prompt
3. Restore state: current_schema, source database type
4. Re-connect to database (connection cannot be persisted)
5. Note: Reference documents may need to be reloaded

**For Tester Agent:**
1. Check if agent process is still active
2. If crashed, re-spawn with same initialization prompt
3. Re-connect to database (connection cannot be persisted)
4. Note: Test environment state may be lost

### Graceful Shutdown

**When Migration Completes:**
1. Manager sends "SHUTDOWN" message to all agents
2. Agents finish current task (if any)
3. Agents save any important state
4. Agents terminate cleanly
5. Manager confirms all agents terminated

**Shutdown Message Format:**
```
SHUTDOWN
Reason: Migration completed successfully
```

### Error Recovery

**If Agent Fails During Task:**
1. Log the failure with timestamp and context
2. Determine if task can be retried
3. If agent crashed, re-initialize and retry task
4. If agent is busy, wait and retry later
5. If multiple retries fail, escalate to user

**Recovery Checklist:**
- [ ] Agent process restarted successfully
- [ ] Agent triggered vertica-expert skill
- [ ] Agent connected to database
- [ ] Agent state restored (current_schema, file position, etc.)
- [ ] Previous task can be retried

---

## Progress Tracking

**Manager Agent maintains:**

```
## Migration Progress

### Overall Progress
- Total source files: [N]
- Files completed: [X]
- Total objects: [N]
- Objects migrated: [X]
- Objects failed: [X]

### Current File
- File name: [name]
- File progress: [X]% complete
- Current offset: [N]
- Objects in file: [N]
- Migrated in file: [X]

### Agent Status
- Requester Agent: [Active/Idle/Failed]
- Migrator Agent: [Active/Idle/Failed]
- Tester Agent: [Active/Idle/Failed]
- Last communication: [timestamp]

### Error Log
- [N] errors encountered
- [X] errors resolved
- [Y] errors documented
```

---

## Final Migration Report Template

```
# Database Migration Report

## Summary
- **Source Database:** [Oracle/DB2/SQL Server/PostgreSQL/MySQL]
- **Target Database:** Vertica
- **Migration Date:** [date]
- **Duration:** [time]

## Statistics
| Metric | Count |
|--------|-------|
| Total Source Files | [N] |
| Total Objects | [N] |
| Successfully Migrated | [X] |
| Failed (Documented) | [Y] |
| Success Rate | [X%] |

## Files Processed
| File | Objects | Migrated | Failed |
|------|---------|----------|--------|
| 01_tables.sql | 15 | 15 | 0 |
| 02_views.sql | 8 | 8 | 0 |
| 03_procedures.sql | 12 | 11 | 1 |

## Agent Performance
### Manager Agent
- ✅ Coordinated workflow without reading source files
- ✅ Processed all files alphabetically
- ✅ Maintained sequential order through Requester
- ✅ Dispatched tasks to appropriate agents

### Requester Agent
- ✅ Read source files section-by-section
- ✅ Maintained file reading state

### Migrator Agent
- ✅ Loaded basic reference documents at startup, additional docs on-demand
- ✅ Applied one-to-one migration consistently
- ✅ Rewrote OLTP→OLAP patterns correctly
- ✅ Unit tested every snippet

### Tester Agent
- ✅ Tested every snippet
- ✅ Provided detailed error reports
- ✅ Suggested actionable fixes

## Failed Migrations
### [Object Name] - [Source File]
- **Error:** [error message]
- **Attempts:** [N]
- **Resolution:** [documented/fixed/skipped]

## Recommendations
1. [Performance recommendation]
2. [Projection design suggestion]
3. [Additional testing needed]

## Next Steps
1. [ ] Review failed migrations
2. [ ] Design projections for key tables
3. [ ] Performance testing with production data volumes
4. [ ] Integration testing with application
```

---

## Examples

### Example: Migrating a Stored Procedure (Multi-Agent Workflow)

#### Manager Requests Snippet from Requester Agent

**READ_REQUEST**
```
Request ID: REQ-001
Source File: 03_procedures.sql
Offset: 1
Limit: 50
```

#### Requester Agent Returns Snippet

**READ_RESPONSE**
````
Request ID: REQ-001
Source File: 03_procedures.sql
Offset: 1
Code:
```
CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id IN NUMBER,
    p_count OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
/
```
Next Offset: 10
End Of File: NO
````

#### Manager Sends to Migrator Agent

**MIGRATE_REQUEST**
````
Source Database: oracle
Current Schema: [current_schema value or empty]
Code:
```
CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id IN NUMBER,
    p_count OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
/
```
````

#### Migrator Agent Returns

**MIGRATE_RESPONSE**
````
Unit Test Status: PASSED
Unit Test Logs:
```
NOTICE: 1 row affected
NOTICE: Procedure created successfully
NOTICE: CALL completed successfully, p_count = 25
```
Migrated Code:
```
CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id IN NUMBER,
    p_count OUT NUMBER
)
LANGUAGE plvsql AS
$$
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;
```
Changes Made:
- Added LANGUAGE plvsql AS
- Added $$ delimiters
- Preserved OUT parameter
- Preserved SELECT INTO logic
OLTP→OLAP Rewrites: None needed (simple query)
Potential Issues: None identified
````

#### Manager Sends to Tester Agent

**TEST_REQUEST**
````
Current Schema: [current_schema value or empty]
Test Type: FUNCTIONAL
Migrated Code:
```
CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id IN NUMBER,
    p_count OUT NUMBER
)
LANGUAGE plvsql AS
$$
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;
```
````

#### Tester Agent Returns

**TEST_RESPONSE**
````
Status: PASS
Test Type: FUNCTIONAL
Execution Results: Procedure created successfully, CALL returned count = 25
Complete Logs:
```
NOTICE: 1 row affected
NOTICE: Procedure created successfully
NOTICE: CALL completed successfully, p_count = 25
```
Error Details: None
````

#### Manager Appends to Target File

```sql
-- Migrated from: 03_procedures.sql
-- Test Status: PASSED

CREATE OR REPLACE PROCEDURE get_employee_count(
    p_dept_id IN NUMBER,
    p_count OUT NUMBER
)
LANGUAGE plvsql AS
$$
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees
    WHERE department_id = p_dept_id;
END;
$$;
```

---

## Troubleshooting

### Requester Agent Not Responding

1. Check if Requester Agent context is overloaded
2. Restart Requester Agent with fresh context
3. Verify source file path is correct
4. Check file permissions
5. Ensure offset/limit parameters are valid

### Migrator Agent Not Responding

1. Check if Migrator Agent context is overloaded
2. Restart Migrator Agent with fresh context
3. Provide more specific code snippet
4. Check reference documents are properly loaded

### Tester Agent Connection Issues

1. Verify database connection string
2. Check if test database is accessible
3. Restart Tester Agent with new connection
4. Verify user permissions in test environment

### Communication Failures

1. Log the failure
2. Retry communication up to 3 times
3. If still failing, Manager takes over the role temporarily
4. Restart failed Agent when possible

### Context Overflow in Migrator

1. Restart Migrator Agent with fresh context
2. Use reference documents more efficiently

---

## Comparison: Single-Agent vs Multi-Agent

| Aspect | Single-Agent | Multi-Agent |
|--------|-------------|-------------|
| **Context Size** | Large (all in one agent) | Small (distributed) |
| **Rule Adherence** | Often violated under load | Enforced by role separation |
| **Testing** | Often forgotten | Dedicated Tester Agent |
| **Source File Reading** | Tends to read entire file | Requester reads section-by-section |
| **Migration Knowledge** | Combined with coordination | Migrator exclusively holds migration knowledge |
| **Workflow Control** | Combined with file reading | Manager focuses on coordination and verification |
| **Batch Processing** | Common anti-pattern | Prevented by workflow |
| **Error Recovery** | Context loss on retry | Focused debugging |
| **Reference Docs** | Must re-read often | Loaded once at initialization (Migrator only) |

---

**For quick reference, see [multi-agent-quick-reference.md](multi-agent-quick-reference.md).**
