///|
type MySqlStmt

///|
pub fn stmt_prepare(
  mysql : MySql,
  query : String,
  param_types? : Array[MySqlStmtParamType] = [],
) -> MySqlStmt raise {
  let mysql_stmt = mysql_stmt_init(mysql)
  guard (mysql_stmt.to_option() : MySqlStmt?) is Some(mysql_stmt) else {
    mysql.fail("Failed to initialize MySQL statement")
  }
  let query = @encoding/utf8.encode(query)
  guard mysql_stmt_prepare(mysql_stmt, query, query.length()) == 0 else {
    mysql_stmt.fail("Failed to prepare MySQL statement")
  }
  let params_count = mysql_stmt_param_count(mysql_stmt)
  guard params_count > 0 else { return mysql_stmt }
  guard params_count == param_types.length().reinterpret_as_uint() else {
    mysql.fail(
      "Parameter count mismatch: expected \{param_types.length()}, got \{params_count}",
    )
  }
  let (sizes, types, unsigned) = params_to_mysql_binds(param_types)
  guard mysql_stmt.stmt_bind_params(params_count, sizes, types, unsigned) else {
    mysql_stmt.fail("Failed to initialize MySQL statement binds")
  }
  mysql_stmt
}

///|
#borrow(mysql)
extern "c" fn mysql_stmt_init(mysql : MySql) -> Pointer = "moonbit_mariadb_mysql_stmt_init"

///|
#borrow(mysql_stmt, query)
extern "c" fn mysql_stmt_prepare(
  mysql_stmt : MySqlStmt,
  query : Bytes,
  length : Int,
) -> Int = "moonbit_mariadb_mysql_stmt_prepare"

///|
#callsite(autofill(loc))
fn[E] MySqlStmt::fail(
  self : MySqlStmt,
  err_msg : String,
  loc~ : SourceLoc,
) -> E raise {
  raise MySqlStmtError::new(self, err_msg, loc~)
}

///|
#borrow(mysql_stmt)
extern "c" fn mysql_stmt_param_count(mysql_stmt : MySqlStmt) -> UInt = "moonbit_mariadb_mysql_stmt_param_count"

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
fn params_to_mysql_binds(
  param_types : Array[MySqlStmtParamType],
) -> (FixedArray[UInt], FixedArray[UInt], FixedArray[Bool]) {
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
  (sizes, types, unsigned)
}

///|
#borrow(self, sizes, types, unsigned)
extern "c" fn MySqlStmt::stmt_bind_params(
  self : MySqlStmt,
  columns_count : UInt,
  sizes : FixedArray[UInt],
  types : FixedArray[UInt],
  unsigned : FixedArray[Bool],
) -> Bool = "moonbit_mariadb_stmt_bind_params"
