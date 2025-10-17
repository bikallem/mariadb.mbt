///|
type MySqlStmt

///|
pub fn stmt_prepare(
  mysql : MySql,
  query : String,
  param_types? : Array[MySqlStmtParam] = [],
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
fn params_to_mysql_binds(
  param_types : Array[MySqlStmtParam],
) -> (FixedArray[UInt], FixedArray[UInt], FixedArray[Bool]) {
  let sizes : Array[UInt] = []
  let types : Array[UInt] = []
  let unsigned : FixedArray[Bool] = FixedArray::make(
    param_types.length(),
    false,
  )
  for i, param_type in param_types {
    match param_type {
      Int => {
        sizes.push(4)
        types.push(mysql_type_long())
      }
      UInt => {
        sizes.push(4)
        types.push(mysql_type_long())
        unsigned[i] = true
      }
      Int64 => {
        sizes.push(8)
        types.push(mysql_type_longlong())
      }
      UInt64 => {
        sizes.push(8)
        types.push(mysql_type_longlong())
        unsigned[i] = true
      }
      Float => {
        sizes.push(4)
        types.push(mysql_type_float())
      }
      Double => {
        sizes.push(8)
        types.push(mysql_type_double())
      }
      String(max_length) => {
        sizes.push(max_length)
        types.push(mysql_type_string())
      }
      Blob(max_length) => {
        sizes[i] = max_length
        types.push(mysql_type_blob())
      }
      Bool => {
        sizes[i] = 4
        types.push(mysql_type_long())
      }
    }
  }
  (FixedArray::from_array(sizes), FixedArray::from_array(types), unsigned)
}

///|
extern "c" fn mysql_type_long() -> UInt = "moonbit_mariadb_mysql_type_long"

///|
extern "c" fn mysql_type_longlong() -> UInt = "moonbit_mariadb_mysql_type_longlong"

///|
extern "c" fn mysql_type_float() -> UInt = "moonbit_mariadb_mysql_type_float"

///|
extern "c" fn mysql_type_double() -> UInt = "moonbit_mariadb_mysql_type_double"

///|
extern "c" fn mysql_type_string() -> UInt = "moonbit_mariadb_mysql_type_string"

///|
extern "c" fn mysql_type_blob() -> UInt = "moonbit_mariadb_mysql_type_blob"

///|
#borrow(self, sizes, types, unsigned)
extern "c" fn MySqlStmt::stmt_bind_params(
  self : MySqlStmt,
  columns_count : UInt,
  sizes : FixedArray[UInt],
  types : FixedArray[UInt],
  unsigned : FixedArray[Bool],
) -> Bool = "moonbit_mariadb_stmt_bind_params"
