# Tmax OpenSQL Orafce
## Introduction
This is the new orafce extension for PostgreSQL. We are diverging from [orafce v4.13.5](https://github.com/orafce/orafce/releases/tag/VERSION_4_13_5) and will implement new features in this repository from now. The new changes will be recorded in [CHANGELOG](CHANGELOG.md).

The documentation on the original orafce features up to version 4.13.5 can be found in the following list:
### Orafce Documentation
- [Chapter 1. Overview](/upstream/doc/orafce_documentation/Orafce_Documentation_01.md)
- [Chapter 2. Notes on Using orafce](/upstream/doc/orafce_documentation/Orafce_Documentation_02.md)
- [Chapter 3. Data Types](/upstream/doc/orafce_documentation/Orafce_Documentation_03.md)
- [Chapter 4. Queries](/upstream/doc/orafce_documentation/Orafce_Documentation_04.md)
- [Chapter 5. SQL Function Reference](/upstream/doc/orafce_documentation/Orafce_Documentation_05.md)
- [Chapter 6. Package Reference](/upstream/doc/orafce_documentation/Orafce_Documentation_06.md)
- [Chapter 7. Transaction Behavior](/upstream/doc/orafce_documentation/Orafce_Documentation_07.md)
### Oracle to PostgreSQL Migration Guide
- [Chapter 0. Preface](/upstream/sql_migration/sql_migration00.md)
- [Chapter 1. Pre-migration Configuration](/upstream/sql_migration/sql_migration01.md)
- [Chapter 2. Migrating Syntax Elements](/upstream/sql_migration/sql_migration02.md)
- [Chapter 3. Migrating Functions](/upstream/sql_migration/sql_migration03.md)
- [Chapter 4. Migrating SQL Statements](/upstream/sql_migration/sql_migration04.md)
- [Chapter 5. Migrating PL/SQL](/upstream/sql_migration/sql_migration05.md)
- [Chapter 6. Notes on Using orafce](/upstream/sql_migration/sql_migration06.md)
- [Appendix A. Correnspondence with Oracle Databases](/upstream/sql_migration/sql_migration07.md)

## Dependencies
- CMake version 3.10 or later
- PostgreSQL server version 10 or later
- PostgreSQL server development files version 10 or later
## Building
```
cmake -S . -B build
cmake --build build
```
## Testing
The new orafce uses pgTAP for tests. Follow the instructions below to test the extension.

### Install pgTAP and its dependencies
```
# Clone source repository
$ git clone https://github.com/theory/pgtap.git

# Build pgTAP
$ cd pgtap
$ make
$ make install
$ make installcheck

# Install Perl parser library for pgTAP
$ cpan TAP::Parser::SourceHandler::pgTAP
```

### Run Tests
```
$ cd orafce
$ pg_prove -U ${username} tests/${feature_set_to_test}/${feature_to_test}.sql
```