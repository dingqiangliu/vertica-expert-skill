# CLAUDE.md - Vertica Expert Skill Contributor Guide

> **This file is for contributors/maintainers working WITH Claude Code to understand project architecture, documentation system, and maintenance procedures.**
> **For execution rules Claude Code follows, see SKILL.md. For user-facing usage guide, see README.md.**
> **For detailed procedures, checklists, and best practices, see CONTRIBUTOR_GUIDE.md.**

---

## Part 1: Working with Claude Code

### 1.1 Development Workflow

When you activate the vertica-expert skill for **development and maintenance**, the flow is:

1. Claude Code reads CLAUDE.md (entry point for development)
2. You request changes (e.g., "Add Oracle 23c support")
3. Claude Code reads relevant reference documents (from references/)
4. Claude Code makes changes following your guidance
5. Claude Code updates corresponding summary (reference-summaries/)
6. Claude Code tests with examples (examples/vertica/)
7. You verify the changes work correctly

**Key Difference**: In development workflow, Claude Code is your **collaborator** following your guidance. In migration workflow (SKILL.md), Claude Code is the **executor** following rules.

### 1.2 Setup Requirements

**Create project-level skill symlink** (one-time setup):

```bash
cd /path/to/vertica-expert-skill
mkdir -p .claude/skills
ln -s $(pwd) .claude/skills/vertica-expert
```

**Important**: This symlink is **NOT** committed to git (add to `.gitignore`).

### 1.3 Key Principles

1. **Claude Code is the Executor, You are the Architect** - You define rules and knowledge, Claude Code follows them
2. **Documents are the Interface** - Claude Code reads documents to understand how to behave
3. **Summaries are Critical** - Always create/update summaries when modifying full documents
4. **Examples are Test Cases** - Use examples/ to verify changes work correctly

### 1.4 Common Tasks

- **Modify docs**: Edit references/ → Update summary → Test with Claude Code
- **Add features**: Create doc → Create summary → Update SKILL.md → Add examples
- **Debug issues**: Check doc loading → Verify clarity → Test with examples

For detailed procedures and checklists, see [CONTRIBUTOR_GUIDE.md](CONTRIBUTOR_GUIDE.md).

---

## Part 2: Project Architecture Overview

### 2.1 Core Files

| File | Target Audience | Core Purpose |
|------|----------------|--------------|
| **SKILL.md** | Claude Code Agent | Define workflow execution rules |
| **CLAUDE.md** | Contributors/Maintainers | Explain project architecture for collaboration |
| **README.md** | Users/Contributors | Introduce project features |

### 2.2 Directory Structure

See SKILL.md for complete directory listing with file descriptions.

### 2.3 Key Principles

1. **Progressive Disclosure**: Avoid context overload through layered document loading
2. **Reference-Based Architecture**: Single source of truth with dependency hierarchy
3. **Summary Documents**: Agent-optimized versions reduce context usage by ~70%

---

## Part 3: Documentation System

### 3.1 Documentation Hierarchy

See [Migration Guides Overview](references/migration-guides-overview.md) for complete hierarchy, dependencies, and usage instructions.

### 3.2 Key Points

- **Level 0**: Workflow definitions (generic-migration-guide.md is MANDATORY)
- **Level 1**: Core references (sql-syntax, function-mapping, data-type-mapping) - standalone
- **Level 2**: Database-specific guides (Oracle, DB2, SQL Server, PostgreSQL, MySQL)
- **Level 3**: Specialized references (stored-procedures, UDx, ML)
- **Level 4**: Agent configurations (Multi-Agent Workflow only)
- **Level 5**: Summary documents (Agent-optimized versions)

### 3.3 Dependency Rules

- Level 1 documents are standalone (foundational knowledge)
- Level 2 references both Level 0 and Level 1
- Level 3 documents are standalone but may reference Level 1
- Level 5 documents MUST be synchronized with their parent documents
- Level 4 documents ONLY apply to Multi-Agent Workflow

---

## Part 4: Workflow Architecture

### 4.1 Two Workflows

| Aspect | General Workflow | Multi-Agent Workflow |
|--------|------------------|---------------------|
| **Best For** | Small-medium migrations (<200 lines) | Large-scale migrations (>200 lines) |
| **Agent Count** | 1 (Main Agent) | 4 (Manager + 3 sub-agents) |
| **Context Usage** | Single context | Distributed contexts |

See SKILL.md for detailed workflow selection and execution rules.

### 4.2 Agent Responsibilities (Multi-Agent Workflow Only)

| Agent | Role | Loads Migration Docs | Key Constraint |
|-------|------|---------------------|----------------|
| **Manager** | Coordinator | ❌ NEVER | Verifies results, never reads source files or migration refs |
| **Requester** | File Reader | ❌ NEVER | Reads section-by-section (limit=50), exclusive file reader |
| **Migrator** | Code Transformer | ✅ ONLY agent | Applies migration rules, unit tests before returning |
| **Tester** | Validator | ❌ NEVER | Executes tests, never modifies code |

### 4.3 Communication Protocol

**Message Types**:
- **READ_REQUEST** (Manager → Requester): Request file section
- **READ_RESPONSE** (Requester → Manager): Return code snippet
- **MIGRATION_TASK** (Manager → Migrator): Convert code
- **TEST_REQUEST** (Manager → Tester): Validate functionality

---

## Part 5: Maintenance Guide

### 5.1 Document Update Workflow

1. **Identify Document Level** (0-5)
2. **Make Changes** - Follow existing formatting, preserve cross-references
3. **Synchronize Dependent Documents** - Level 0 → 1 → 2 → 5
4. **Verify and Test** - Run link validation, test with examples

For detailed synchronization checklists, see [CONTRIBUTOR_GUIDE.md](CONTRIBUTOR_GUIDE.md).

### 5.2 Adding New Features

1. Create reference document in references/
2. Create corresponding summary in reference-summaries/
3. Update migration-guides-overview.md (if Level 0-2)
4. Add examples in examples/
5. Test with Claude Code

### 5.3 Key Maintenance Rules

- **Level 0-2**: High impact, requires broad synchronization
- **Level 3**: Medium impact, check dependencies
- **Level 4**: Agent testing required
- **Level 5**: Must sync with parent document

For version control rules, branch naming, and detailed procedures, see [CONTRIBUTOR_GUIDE.md](CONTRIBUTOR_GUIDE.md).

---

## Part 6: Quick Reference

### 6.1 Key Files

**Migration starting point**:
- references/generic-migration-guide.md

**Core references**:
- references/sql-syntax-reference.md
- references/function-mapping.md
- references/data-type-mapping.md

**Database-specific**:
- references/oracle-migration.md
- references/db2-migration.md
- references/sqlserver-migration.md
- references/postgresql-migration.md
- references/mysql-migration.md

**Specialized topics**:
- references/stored-procedures-guide.md
- references/udx-development-guide.md
- references/machine-learning.md

**Agent configurations**:
- agents/requester.md
- agents/migrator.md
- agents/tester.md

**Detailed contributor guide**:
- CONTRIBUTOR_GUIDE.md

### 6.2 Documentation Priority

1. **Generic Migration Guide** - MANDATORY for all migrations
2. **OLTP to OLAP Rewrite Guide** - ESSENTIAL for procedural code
3. **SQL Syntax Reference** - For syntax questions
4. **Function Mapping** - For function replacement
5. **Data Types** - For schema migration

For complete file inventory, common tasks, and FAQ, see [CONTRIBUTOR_GUIDE.md](CONTRIBUTOR_GUIDE.md).

---

**Last Updated**: 2026-06-18
**Version**: 1.0
**Maintainer**: Vertica Expert Skill Contributors
