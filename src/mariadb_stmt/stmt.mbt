///| Mariadb prepared statement
struct Stmt {
  mysql_stmt : MYSQL_STMT
  query : String
  param_binds : MYSQL_BIND_ARRAY?
  param_binds_count : UInt
  mut result_binds : MYSQL_BIND_ARRAY?
  mut result_binds_count : UInt
}

///|
#external
priv type MYSQL_STMT

///| MYSQL_BIND* - array of MYSQL_BIND
#external
priv type MYSQL_BIND_ARRAY

///|
typealias @mariadb.MySql

///|
pub fn Stmt::new(
  mysql : MySql,
  query : String,
  param_types~ : Array[ParamType] = [],
) -> Stmt raise {
  let mysql_stmt = mysql_stmt_init(mysql)
  guard mysql_stmt.to() is Some(mysql_stmt) else {
    mysql.fail("Failed to initialize MySQL statement")
  }
  let query_bytes = @encoding.encode(encoding=UTF8, query)
  guard mysql_stmt_prepare(mysql_stmt, query_bytes, query_bytes.length()) == 0 else {
    mysql_stmt.fail("Failed to prepare MySQL statement")
  }
  let param_binds_count = mysql_stmt_param_count(mysql_stmt)
  guard param_binds_count > 0 else {
    return Stmt::{
      mysql_stmt,
      query,
      param_binds: None,
      param_binds_count,
      result_binds: None,
      result_binds_count: 0,
    }
  }
  guard param_binds_count == param_types.length().reinterpret_as_uint() else {
    mysql.fail(
      "Parameter count mismatch: expected \{param_types.length()}, got \{param_binds_count}",
    )
  }
  let mysql_bind = param_types_to_mysql_types_sizes(param_types)
  guard moonbit_stmt_make_binds(
      param_binds_count,
      mysql_bind.sizes,
      mysql_bind.types,
      mysql_bind.unsigned,
    ).to()
    is Some(param_binds) else {
    mysql_stmt_close(mysql_stmt)
    fail("Failed to create MySQL params bind array")
  }
  guard mysql_stmt_bind_param(mysql_stmt, param_binds) == 0 else {
    mysql_stmt_close(mysql_stmt)
    moonbit_free_binds(param_binds, param_binds_count)
    mysql_stmt.fail("Failed to bind parameters to statement")
  }
  Stmt::{
    mysql_stmt,
    query,
    param_binds: Some(param_binds),
    param_binds_count,
    result_binds: None,
    result_binds_count: 0,
  }
}

///|
const LONG : UInt = 0

///|
const ULONG : UInt = 1

///|
const LONGLONG : UInt = 2

///|
const ULONGLONG : UInt = 3

///|
const FLOAT : UInt = 4

///|
const DOUBLE : UInt = 5

///|
const STRING : UInt = 6

///|
const BLOB : UInt = 7

///|
const BOOL : UInt = 8

///|
priv struct StmtBind {
  sizes : FixedArray[UInt]
  types : FixedArray[UInt]
  unsigned : FixedArray[Bool]
}

///|
fn param_types_to_mysql_types_sizes(param_types : Array[ParamType]) -> StmtBind {
  let sizes : FixedArray[UInt] = FixedArray::make(param_types.length(), 0)
  let types : FixedArray[UInt] = FixedArray::make(param_types.length(), 0)
  let unsigned : FixedArray[Bool] = FixedArray::make(
    param_types.length(),
    false,
  )
  for i, param_type in param_types {
    match param_type {
      Int => {
        sizes[i] = 4
        types[i] = LONG
      }
      UInt => {
        sizes[i] = 4
        types[i] = ULONG
        unsigned[i] = true
      }
      Int64 => {
        sizes[i] = 8
        types[i] = LONGLONG
      }
      UInt64 => {
        sizes[i] = 8
        types[i] = ULONGLONG
        unsigned[i] = true
      }
      Float => {
        sizes[i] = 4
        types[i] = FLOAT
      }
      Double => {
        sizes[i] = 8
        types[i] = DOUBLE
      }
      String(max_length) => {
        sizes[i] = max_length
        types[i] = STRING
      }
      Blob(max_length) => {
        sizes[i] = max_length
        types[i] = BLOB
      }
      Bool => {
        sizes[i] = 4
        types[i] = BOOL
      }
    }
  }
  StmtBind::{ sizes, types, unsigned }
}

///|
typealias @c.Nullable

///|
extern "c" fn mysql_stmt_init(mysql : MySql) -> Nullable[MYSQL_STMT] = "mysql_stmt_init"

///|
#borrow(query)
extern "c" fn mysql_stmt_prepare(
  stmt : MYSQL_STMT,
  query : Bytes,
  length : Int,
) -> Int = "mysql_stmt_prepare"

///|
extern "c" fn mysql_stmt_param_count(stmt : MYSQL_STMT) -> UInt = "mysql_stmt_param_count"

///|
extern "c" fn moonbit_stmt_make_binds(
  columns_count : UInt,
  sizes : FixedArray[UInt],
  types : FixedArray[UInt],
  unsigned : FixedArray[Bool],
) -> Nullable[MYSQL_BIND_ARRAY] = "moonbit_stmt_make_binds"

///|
extern "c" fn mysql_stmt_bind_param(
  stmt : MYSQL_STMT,
  param_binds : MYSQL_BIND_ARRAY,
) -> Int = "mysql_stmt_bind_param"

///|
extern "c" fn moonbit_free_binds(
  binds : MYSQL_BIND_ARRAY,
  count : UInt,
) -> Unit = "moonbit_free_binds"

///|
pub fn Stmt::execute(
  self : Self,
  param_values~ : Map[Int, &ParamValue] = {},
  result_column_types~ : Array[ParamType] = [],
) -> StmtResult raise {
  for i, value in param_values {
    value.set_value(self, i)
  }
  if mysql_stmt_execute(self.mysql_stmt) != 0 {
    self.mysql_stmt.fail("Failed to execute statement")
  }
  let result_binds_count = mysql_stmt_field_count(self.mysql_stmt)
  guard result_column_types.length().reinterpret_as_uint() == result_binds_count else {
    self.mysql_stmt.fail("Result parameter types count mismatch")
  }
  let result_binds = if result_binds_count > 0 {
    let mysql_bind = param_types_to_mysql_types_sizes(result_column_types)
    guard moonbit_stmt_make_binds(
        result_binds_count,
        mysql_bind.sizes,
        mysql_bind.types,
        mysql_bind.unsigned,
      ).to()
      is Some(binds) else {
      None
    }
    guard mysql_stmt_bind_result(self.mysql_stmt, binds) == 0 else {
      moonbit_free_binds(binds, result_binds_count)
      self.mysql_stmt.fail("Failed to bind result set")
    }
    Some(binds)
  } else {
    None
  }
  self.result_binds = result_binds
  self.result_binds_count = result_binds_count
  self
}

///|
extern "c" fn mysql_stmt_execute(stmt : MYSQL_STMT) -> Int = "mysql_stmt_execute"

///|
extern "c" fn mysql_stmt_field_count(stmt : MYSQL_STMT) -> UInt = "mysql_stmt_field_count"

///| 
extern "c" fn mysql_stmt_bind_result(
  stmt : MYSQL_STMT,
  param_binds : MYSQL_BIND_ARRAY,
) -> Int = "mysql_stmt_bind_result"

///|
#callsite(autofill(loc))
fn[E] MYSQL_STMT::fail(
  self : MYSQL_STMT,
  err_msg : String,
  loc~ : SourceLoc,
) -> E raise {
  raise StmtError::new(self, err_msg, loc~)
}

///|
pub fn Stmt::close(self : Self) -> Unit {
  if self.param_binds is Some(param_binds) {
    moonbit_free_binds(param_binds, self.param_binds_count)
  }
  if self.result_binds is Some(result_binds) {
    moonbit_free_binds(result_binds, self.result_binds_count)
  }
  mysql_stmt_free_result(self.mysql_stmt)
  mysql_stmt_close(self.mysql_stmt)
}

///|
extern "c" fn mysql_stmt_close(stmt : MYSQL_STMT) -> Unit = "mysql_stmt_close"

///|
extern "c" fn mysql_stmt_free_result(stmt : MYSQL_STMT) -> Unit = "mysql_stmt_free_result"

///|
#inline
fn Stmt::set_param_value(
  self : Self,
  index : Int,
  value : Bytes,
  length : UInt,
) -> Unit {
  guard self.param_binds is Some(param_binds) else {  }
  moonbit_set_param_value(param_binds, index, value, length)
}

///|
#borrow(value)
extern "c" fn moonbit_set_param_value(
  param_binds : MYSQL_BIND_ARRAY,
  index : Int,
  value : Bytes,
  length : UInt,
) -> Unit = "moonbit_set_param_value"
