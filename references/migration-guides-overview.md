# Database Migration Guides Overview

This document provides an overview of all database migration guides and their hierarchical relationship with the mandatory [Generic Migration Guide](generic-migration-guide.md).

## 📋 Migration Guide Hierarchy

### 1. MASTER REFERENCE (MANDATORY)
**[Generic Migration Guide](generic-migration-guide.md)**
- **Status**: 🚨 **REQUIRED READING FOR ALL MIGRATIONS**
- **Purpose**: Defines non-negotiable requirements that apply to ALL database migrations
- **Must be read BEFORE any specific migration guide**
- **Contains**: Complete migration procedures, testing requirements, prohibited actions

### 2. SPECIFIC DATABASE GUIDES (ALL REFERENCE THE GENERIC GUIDE)

#### [Oracle to Vertica Migration Guide](oracle-migration.md)
- **Source**: Oracle Database
- **Focus**: PL/SQL to PL/vSQL conversion, Oracle-specific features
- **Key Topics**: Package migration, sequence handling, trigger conversion
- **References Generic Guide**: ✅ **MANDATORY COMPLIANCE SECTION**

#### [DB2 to Vertica Migration Guide](db2-migration.md)
- **Source**: IBM DB2
- **Focus**: PL/SQL to PL/vSQL conversion, DB2-specific features
- **Key Topics**: Sequence handling, module/package conversion, MQT to Live Aggregate Projections, special registers
- **References Generic Guide**: ✅ **MANDATORY COMPLIANCE SECTION**

#### [SQL Server to Vertica Migration Guide](sqlserver-migration.md)
- **Source**: Microsoft SQL Server
- **Focus**: T-SQL to Vertica SQL conversion
- **Key Topics**: Identity columns, temporary tables, cursor alternatives
- **References Generic Guide**: ✅ **MANDATORY COMPLIANCE SECTION**

#### [PostgreSQL to Vertica Migration Guide](postgresql-migration.md)
- **Source**: PostgreSQL
- **Focus**: PL/pgSQL to PL/vSQL conversion
- **Key Topics**: Array handling, JSON support, sequence conversion
- **References Generic Guide**: ✅ **MANDATORY COMPLIANCE SECTION**

#### [MySQL to Vertica Migration Guide](mysql-migration.md)
- **Source**: MySQL
- **Focus**: MySQL SQL syntax to Vertica conversion
- **Key Topics**: AUTO_INCREMENT to IDENTITY, storage engine differences
- **References Generic Guide**: ✅ **MANDATORY COMPLIANCE SECTION**

## 🔗 Reference Documentation Priority Order

All migration guides follow this documentation priority:

1. **[Generic Migration Guide](generic-migration-guide.md)** - **MANDATORY**
2. **[OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md)** - **ESSENTIAL** for all migrations involving procedural/OLTP code
3. **[SQL Syntax Reference](sql-syntax-reference.md)**
4. **[Function Mapping Guide](function-mapping.md)**
5. **[Data Types](data-types.md)**
6. **[User-Defined SQL Functions Guide](user-defined-sql-functions-guide.md)**
7. **[Stored Procedures Guide](stored-procedures-guide.md)**
8. **[UDx Development Guide](udx-development-guide.md)**

## 🚨 Critical Requirements (From Generic Guide)

All specific migration guides MUST enforce these requirements:

### Complete Migration
- ✅ **ALL** database objects must be migrated
- ✅ No selective migration allowed
- ✅ Everything from tables to triggers to sequences

### Sequential Processing
- ✅ Process source files in exact order (top to bottom)
- ✅ Never skip or reorder objects
- ✅ One object at a time processing

### Object Integrity
- ✅ Never break up complete objects
- ✅ Maintain statement boundaries
- ✅ Preserve all dependencies

### One-to-One Conversion
- ✅ Tables → Tables
- ✅ Views → Views
- ✅ Stored Procedures → Stored Procedures
- ✅ Functions → Functions or Stored Procedures
- ✅ DML → DML

### Mandatory Testing
- ✅ Test EVERY object individually
- ✅ Execute all objects in Vertica
- ✅ Verify functionality before marking as migrated
- ✅ Retain test data for dependencies

### No Automation
- ✅ Never use automated scripts
- ✅ Never batch process objects
- ✅ Manual verification required for all objects

## 📖 Usage Instructions

### For Oracle Migrations
```
1. Read [Generic Migration Guide](generic-migration-guide.md) FIRST
2. Read [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for procedural code
3. Then use [Oracle Migration Guide](oracle-migration.md)
4. Follow all mandatory procedures from Generic Guide
5. Apply Oracle-specific conversion rules
6. Rewrite procedural loops/cursors using OLTP-to-OLAP patterns
7. Test every object individually
```

### For DB2 Migrations
```
1. Read [Generic Migration Guide](generic-migration-guide.md) FIRST
2. Read [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for procedural code
3. Then use [DB2 Migration Guide](db2-migration.md)
4. Follow all mandatory procedures from Generic Guide
5. Apply DB2-specific conversion rules
6. Rewrite procedural loops/cursors using OLTP-to-OLAP patterns
7. Test every object individually
```

### For SQL Server Migrations
```
1. Read [Generic Migration Guide](generic-migration-guide.md) FIRST
2. Read [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for procedural code
3. Then use [SQL Server Migration Guide](sqlserver-migration.md)
4. Follow all mandatory procedures from Generic Guide
5. Apply SQL Server-specific conversion rules
6. Rewrite procedural loops/cursors using OLTP-to-OLAP patterns
7. Test every object individually
```

### For PostgreSQL Migrations
```
1. Read [Generic Migration Guide](generic-migration-guide.md) FIRST
2. Read [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for procedural code
3. Then use [PostgreSQL Migration Guide](postgresql-migration.md)
4. Follow all mandatory procedures from Generic Guide
5. Apply PostgreSQL-specific conversion rules
6. Rewrite procedural loops/cursors using OLTP-to-OLAP patterns
7. Test every object individually
```

### For MySQL Migrations
```
1. Read [Generic Migration Guide](generic-migration-guide.md) FIRST
2. Read [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) for procedural code
3. Then use [MySQL Migration Guide](mysql-migration.md)
4. Follow all mandatory procedures from Generic Guide
5. Apply MySQL-specific conversion rules
6. Rewrite procedural loops/cursors using OLTP-to-OLAP patterns
7. Test every object individually
```

## 🔍 Verification Checklist

Before starting any migration, verify:

- [ ] [Generic Migration Guide](generic-migration-guide.md) has been read and understood
- [ ] [OLTP to OLAP Rewrite Guide](oltp-to-olap-rewrite-guide.md) has been read for procedural code migrations
- [ ] All team members are aware of mandatory requirements
- [ ] Testing environment is set up with VSQL
- [ ] Source file processing order is documented
- [ ] All reference documentation is available

## 🚫 Common Violations to Avoid

### Process Violations
- ❌ Skipping objects because they "seem unnecessary"
- ❌ Reordering objects for "better organization"
- ❌ Using automated conversion scripts
- ❌ Batch processing multiple objects
- ❌ Skipping individual object testing

### Technical Violations
- ❌ Removing OUT/INOUT parameter keywords
- ❌ Converting objects to different types
- ❌ Creating projections from indexes or queries automatically
- ❌ Ignoring dependency order
- ❌ Not preserving sequences

## 📞 Support and Troubleshooting

### When Migration Fails
1. **First**: Re-read [Generic Migration Guide](generic-migration-guide.md)
2. **Second**: Check specific database migration guide
3. **Third**: Consult function mapping and data types guides
4. **Fourth**: Review stored procedures guide for PL/vSQL issues

### Common Issues
- **Parameter errors**: Check OUT/INOUT parameter handling
- **Type mismatches**: Use data types guide for mapping
- **Function not found**: Use function mapping guide
- **Syntax errors**: Use SQL syntax reference guide
- **Dependency issues**: Maintain source file order strictly

## 📊 Migration Success Metrics

### Completeness Metrics
- [ ] 100% of source objects processed
- [ ] 100% of objects tested individually
- [ ] 100% of objects functional in Vertica
- [ ] 100% of dependencies satisfied

### Quality Metrics
- [ ] Zero syntax errors
- [ ] Zero runtime errors
- [ ] Functionality matches source behavior
- [ ] Performance meets requirements

### Documentation Metrics
- [ ] Complete migration log maintained
- [ ] All failures documented with reasons
- [ ] All solutions recorded
- [ ] Final migration file validated

---

**REMEMBER**: The [Generic Migration Guide](generic-migration-guide.md) is the foundation that ALL specific migration guides build upon. **Failure to follow its requirements will result in failed migrations.**