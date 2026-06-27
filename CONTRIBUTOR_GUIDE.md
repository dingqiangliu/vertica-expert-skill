# Contributor Guide - Vertica Expert Skill

> **This document provides detailed procedures for contributors/maintainers.**
> **For core overview, see CLAUDE.md.**

---

## Table of Contents

1. [Synchronization Checklists](#synchronization-checklists)
2. [Version Control Rules](#version-control-rules)
3. [Testing and Validation](#testing-and-validation)
4. [Adding New Database Support](#adding-new-database-support)
5. [Common Tasks](#common-tasks)
6. [FAQ](#faq)
7. [Emergency Procedures](#emergency-procedures)
8. [Best Practices](#best-practices)
9. [Change Log Template](#change-log-template)
10. [Glossary](#glossary)

---

## Synchronization Checklists

### When Updating Level 0 Documents (Workflow)

```
□ Update all Level 1 documents that reference this doc
□ Update all Level 2 documents that reference this doc
□ Update all Level 3 documents that reference this doc
□ Update corresponding Level 5 summary
□ Update agent configurations if workflow changed
□ Test both General and Multi-Agent workflows
□ Test Embedded SQL Script Migration Workflow (if applicable)
□ Verify all cross-references are valid
□ Update statistics in this CLAUDE.md
```

### When Updating Level 1 Documents (Core References)

```
□ Update all Level 2 documents that reference this doc
□ Update all Level 3 documents that reference this doc
□ Update corresponding Level 5 summary
□ Test with examples from examples/
□ Verify Agent Migrator can load updated doc
□ Update statistics in this CLAUDE.md
```

### When Updating Level 2 Documents (Database-Specific)

```
□ Update corresponding Level 5 summary
□ Update examples in examples/[database]/
□ Test migration with updated doc
□ Verify Agent Migrator can load updated doc
```

### When Updating Level 3 Documents (Specialized)

```
□ Update corresponding Level 5 summary
□ Test with relevant examples
□ Verify Agent Migrator can load updated doc
```

### When Updating Level 4 Documents (Agent Configs)

```
□ Test with mock migration task
□ Verify Agent follows documented constraints
□ Check communication protocol still works
□ Verify document loading strategy
```

### When Updating Level 5 Documents (Summaries)

```
□ Verify consistency with parent document
□ Check all references to parent doc are valid
□ Test that Agent can use summary for decisions
```

---

## Version Control Rules

### Commit Message Format

```
[LEVEL-X] Brief description

Examples:
[LEVEL-0] Add new migration rule for cursor handling
[LEVEL-2] Update Oracle PL/SQL conversion examples
[LEVEL-4] Improve Requester agent error handling
[LEVEL-5] Sync generic-migration-summary with parent
```

### Branch Naming

```
feature/doc-add-[database]-support
feature/doc-update-[document-name]
fix/doc-broken-reference
refactor/doc-[optimization-description]
```

### Review Requirements

- All doc changes require testing with examples
- Level 0-2 changes require broader review
- Agent config changes require mock task testing

---

## Testing and Validation

### Document Accuracy Testing

**Test Case Selection**:
1. Pick 3 examples from examples/ directory
2. Apply migration using ONLY the reference docs
3. Verify output matches expected results
4. Check all cross-references work

### Automated Checks

```bash
# Verify all file paths in docs exist
find references -name "*.md" -exec grep -l "references/" {} \; | \
  while read f; do
    grep -o "references/[a-zA-Z-]*\.md" "$f" | while read ref; do
      [ ! -f "$ref" ] && echo "BROKEN: $ref in $f"
    done
  done

# Verify all internal links in CLAUDE.md
grep -o "references/[a-zA-Z-]*\.md" CLAUDE.md | sort -u | while read ref; do
  [ ! -f "$ref" ] && echo "BROKEN: $ref"
done
```

### Agent Configuration Testing

**Test Scenarios**:
1. Run mock migration task with each agent
2. Verify agent loads correct documents
3. Check agent follows documented constraints
4. Validate communication protocol works
5. Test error handling and recovery

---

## Adding New Database Support

### Checklist

```
□ Create [database]-migration.md (follow Level 2 template)
□ Create [database]-migration-summary.md in reference-summaries/
□ Update migration-guides-overview.md (Level 0)
□ Add examples in examples/[database]/
□ Update SKILL.md quick reference section
□ Update this CLAUDE.md statistics and analysis
□ Test migration with new examples
□ Verify Agent Migrator can load new docs
```

### Template for New Database Document

```markdown
# [Database] to Vertica Migration Guide

> **MANDATORY**: Read [Generic Migration Guide](generic-migration-guide.md) FIRST

## Data Type Mapping
> **See [Data Type Mapping Guide](data-type-mapping.md)** for complete data type mappings.
> Load on-demand: `grep -n "^## \|^### " references/data-type-mapping.md` → `Read offset=N limit=M`

## Function Conversions
> **See [Function Mapping Guide](function-mapping.md)** for function conversions across databases.
> Load on-demand: `grep -n "^## \|^### " references/function-mapping.md` → `Read offset=N limit=M`

## SQL Syntax Conversion
Key syntax differences and conversion examples

## Stored Procedure Conversion
[Database] procedural language → PL/vSQL conversion

## Special Features
Database-specific features and handling

## Examples
Migration examples and test cases
```

> **⚠️ CRITICAL: Reference Document Consistency**
> 
> **DO NOT** duplicate content from reference documents in this document:
> - **Data Type Mapping**: All type mappings MUST be centralized in `data-type-mapping.md` (Level 1)
> - **Function Mapping**: All function mappings MUST be centralized in `function-mapping.md` (Level 1)
> 
> This document should ONLY contain:
> - Reference links to `data-type-mapping.md` and `function-mapping.md` (as shown above)
> - Syntax differences (not type or function mappings)
> - Database-specific examples
> 
> **Rationale**: Reference documents are loaded for EVERY migration task. Duplicating
> content wastes context and creates maintenance burden. Centralizing ensures single
> source of truth and easier updates.
> 
> **Summary documents** (`reference-summaries/[database]-migration-summary.md`) should
> only include syntax differences and commands NOT in reference documents.

---

## Common Tasks

### Task: "Add support for new database"

1. Create `[database]-migration.md` in references/ (follow Level 2 template)
2. Create `[database]-migration-summary.md` in reference-summaries/
3. Update `migration-guides-overview.md` (Level 0)
4. Add examples in `examples/[database]/`
5. Update SKILL.md quick reference section
6. Update this CLAUDE.md statistics and analysis
7. Test migration with new examples
8. Verify Agent Migrator can load new docs

### Task: "Update function mapping"

1. Edit `function-mapping.md` (Level 1)
2. Check all 5 database guides for references
3. Update affected examples
4. Update corresponding summary: `reference-summaries/`
5. Test with real migration task
6. Update this CLAUDE.md if scope changed

### Task: "Fix broken cross-reference"

1. Identify broken reference (error message or testing)
2. Locate correct target document
3. Update reference in source document
4. Check all documents that reference same target
5. Run synchronization checklist (Section 4.2)

### Task: "Add new migration rule"

1. Determine rule scope:
   - All databases → Add to generic-migration-guide.md (Level 0)
   - Specific database → Add to database-migration.md (Level 2)
2. Update corresponding summary
3. Update all dependent documents
4. Test with examples
5. Update this CLAUDE.md analysis

---

## FAQ

**Q: Which workflow should I use for testing?**
A: General Workflow for most tests. Use Multi-Agent only when testing agent coordination or large-scale migrations.

**Q: How do I know if my doc changes are correct?**
A: Run the synchronization checklist (Section 4.2) and test with 3 examples from examples/.

**Q: When should I create a summary document?**
A: Always create a summary when adding a new Level 1-3 document. Summaries are mandatory for Level 1-2.

**Q: Can I modify agent configurations?**
A: Yes, but test thoroughly. Agent changes affect Multi-Agent Workflow only. Verify Agent follows documented constraints.

**Q: How do I add a new database?**
A: Follow the checklist in Section 4.5. Create both full document (Level 2) and summary (Level 5).

---

## Emergency Procedures

### Broken Build/Installation

1. Check install.sh for recent changes
2. Verify file paths in SKILL.md
3. Test with fresh Claude Code session
4. Check .claude/ directory for config issues

### Documentation Out of Sync

1. Identify all affected documents
2. Update in dependency order (Level 0 → 1 → 2 → 5)
3. Test critical paths
4. Update this CLAUDE.md statistics

### Context Overflow During Migration

1. Switch to Multi-Agent Workflow
2. Use summary documents instead of full docs
3. Split migration into smaller phases

---

## Best Practices

### Writing Documents for Claude Code

**DO**:
- ✅ Use clear, unambiguous language
- ✅ Provide examples for every rule
- ✅ Include "When to Use" sections
- ✅ Keep summaries focused on decision-making information
- ✅ Use consistent formatting (tables for mappings, lists for rules)

**DON'T**:
- ❌ Use vague language like "might", "could", "sometimes"
- ❌ Include implementation details in summaries
- ❌ Create circular references between documents
- ❌ Assume Claude Code knows context not in the documents

### Modifying SKILL.md

SKILL.md is Claude Code's primary instruction file. When modifying:

1. **Test Thoroughly**: Changes affect Claude Code's behavior
2. **Preserve Structure**: Keep existing section organization
3. **Update References**: Ensure all document references are valid
4. **Version Control**: Document changes in commit messages

### Adding New Features

When adding new capabilities for Claude Code:

1. **Create Documentation First**: Write the reference document before implementation
2. **Add Summary**: Create Agent-optimized summary in reference-summaries/
3. **Update SKILL.md**: Add references to new documents
4. **Add Examples**: Create test cases in examples/
5. **Test with Claude Code**: Verify Claude Code can use the new feature

### Debugging Issues

If Claude Code isn't behaving as expected:

1. **Check Document Loading**: Is Claude Code reading the right documents?
2. **Verify Instructions**: Are your instructions clear and unambiguous?
3. **Test with Examples**: Run the examples to verify expected behavior
4. **Check Cross-References**: Are all referenced documents accessible?
5. **Review Agent Behavior**: If Multi-Agent, check Agent coordination

### Common Pitfalls

**Pitfall 1: Assuming Context**
- ❌ "As mentioned earlier..."
- ✅ Repeat the key information or provide a specific cross-reference

**Pitfall 2: Ambiguous Instructions**
- ❌ "Handle errors appropriately"
- ✅ "Use GET STACKED DIAGNOSTICS to capture error details and RAISE EXCEPTION with SQLERRM"

**Pitfall 3: Missing Examples**
- ❌ Document without examples
- ✅ Include at least 2-3 examples showing input/output

**Pitfall 4: Outdated Summaries**
- ❌ Modifying full document but forgetting summary
- ✅ Always update both full document and summary together

**Pitfall 5: Breaking Cross-References**
- ❌ Renaming files without updating references
- ✅ Use grep to find all references before renaming

---

## Change Log Template

```markdown
## [DATE] - [CHANGE_TYPE]

**Author**: [Name]
**Affected Documents**: [List of files changed]
**Impact Level**: [Major/Minor/Patch]

### Changes Made
- [Describe change 1]
- [Describe change 2]

### Rationale
[Why this change was necessary]

### Migration Steps Required
- [ ] Update dependent documents
- [ ] Run synchronization checklist
- [ ] Test with examples
- [ ] Update statistics

### Validation
- [ ] All cross-references valid
- [ ] Examples pass
- [ ] No content loss
- [ ] Statistics accurate
```

---

## Glossary

| Term | Definition |
|------|------------|
| **Agent** | Claude Code execution unit (Manager, Requester, Migrator, Tester) |
| **Full Document** | Detailed documentation for human readers with examples and explanations |
| **Summary Document** | Agent-optimized documentation containing only decision-making information |
| **General Migration Workflow** | Single-agent workflow for small-medium migrations |
| **Multi-Agent Migration Workflow** | Multi-agent workflow for large-scale migrations |
| **Embedded SQL Script Migration Workflow** | Workflow for Shell/Perl/Python scripts with Here doc embedded SQL. References General Migration Workflow with overrides. |
| **VSQL** | Vertica SQL command-line tool |
| **PL/vSQL** | Vertica's stored procedure language |
| **UDx** | User-Defined Extension (custom functions in C++, Python, Java, R) |
| **Projection** | Vertica's data organization method for columnar storage and MPP architecture, supporting multiple analytical query scenarios on the same table |
| **OLTP** | Online Transaction Processing (row-by-row operations) |
| **OLAP** | Online Analysis Processing (set-based operations) |
| **Level 0-5** | Documentation hierarchy levels (0=highest, 5=lowest) |
| **Manager** | Coordinator agent in Multi-Agent Workflow |
| **Requester** | Agent that reads source files section-by-section |
| **Migrator** | Agent that converts code and loads migration docs |
| **Tester** | Agent that validates migrated code |
| **SendMessage** | Communication protocol between Manager and sub-agents |
| **SEARCH_PATH** | PostgreSQL/Vertica schema search path for object resolution |
| **ANALYZE_STATISTICS** | Vertica command to update table statistics for query optimization |
| **Full Document** | Detailed documentation for human readers (references/*.md) |
| **Summary Document** | Agent-optimized documentation (references/reference-summaries/*.md) |
| **Claude Code** | The AI assistant that uses this skill |
| **Contributor/Maintainer** | Human who works WITH Claude Code to maintain the skill |

---

**Last Updated**: 2026-06-18
**Version**: 1.0
**Maintainer**: Vertica Expert Skill Contributors
