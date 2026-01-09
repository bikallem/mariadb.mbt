# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoonBit bindings to MariaDB/MySQL client library. Native-only target using C FFI to wrap libmariadb.

## Build Commands

```bash
moon check          # Type check
moon build          # Build all packages
moon run src/examples/contacts  # Run example (requires MariaDB)
```

## Architecture

### Package Structure

- `src/` - Main library package (`bikallem/mariadb`)
- `src/stmt/` - Prepared statements subpackage (`bikallem/mariadb/stmt`)
- `src/examples/contacts/` - Example application

### FFI Pattern

MoonBit code wraps C functions via `extern "c"` declarations. Each `.mbt` file has a corresponding `.c` file:
- `mysql.mbt` + `mysql.c` - Connection handling
- `mysql_res.mbt` + `mysql_res.c` - Query results
- `mysql_row.mbt` + `mysql_row.c` - Row iteration
- `stmt/mysql_stmt.mbt` + `stmt/mysql_stmt.c` - Prepared statements

C functions use `moonbit_mariadb_` prefix. External types use `#borrow` or `#owned` annotations for memory management.

### Core Types

- `MySql` - Database connection handle
- `MySqlRes` - Query result set
- `MySqlRow` - Single row from result
- `MySqlStmt` - Prepared statement
- `MySqlStmtParam` - Parameter type enum (Int, UInt, String, etc.)

### Error Handling

Errors use `suberror` types that can be raised:
- `Err` - General MySQL errors with message, errno, and source location
- `MySqlStmtError` - Statement-specific errors

### Type Conversions

Result column values use type coercion syntax: `(row[0] : Int)`, `(row[1] : String)`

Parameter values implement `MySqlStmtParamValue` trait for binding to prepared statements.

## Dependencies

- `bikallem/cffi` - Local path dependency for FFI utilities
- `libmariadb` - System library, linked via `-lmariadb`
