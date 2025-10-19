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
  let params_count = param_types.length().reinterpret_as_uint()
  guard params_count > 0 else { return mysql_stmt }
  let (sizes, types, unsigned) = params_to_mysql_binds(param_types)
  guard mysql_stmt.stmt_bind_params(params_count, sizes, types, unsigned) == 0 else {
    mysql_stmt.fail("Failed to initialize MySQL statement binds")
  }
  mysql_stmt
}

///|
#owned(mysql)
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
// #borrow(self)
// extern "c" fn MySqlStmt::stmt_param_count(self : MySqlStmt) -> UInt = "moonbit_mariadb_mysql_stmt_param_count"

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
  params_count : UInt,
  sizes : FixedArray[UInt],
  types : FixedArray[UInt],
  unsigned : FixedArray[Bool],
) -> Int = "moonbit_mariadb_stmt_bind_params"

///|
pub fn MySqlStmt::execute(
  self : MySqlStmt,
  param_values? : Map[Int, &MySqlStmtParamValue] = {},
  result_field_types? : Array[MySqlStmtParam] = [],
) -> Unit raise {
  for i, value in param_values {
    let (value_bytes, value_length) = value.value()
    self.set_param_value(i, value_bytes, value_length.reinterpret_as_uint())
  }
  if mysql_stmt_execute(self) != 0 {
    self.fail("Failed to execute MySQL statement")
  }
  let result_field_count = mysql_stmt_field_count(self)
  guard result_field_count > 0 else { return }
  guard result_field_count.reinterpret_as_int() == result_field_types.length() else {
    self.fail("Result field types count mismatch")
  }
  let (sizes, types, unsigned) = params_to_mysql_binds(result_field_types)
  guard self.stmt_bind_results(result_field_count, sizes, types, unsigned) == 0 else {
    self.fail("Failed to bind statement result fields")
  }
}

///|
#borrow(self, value)
extern "c" fn MySqlStmt::set_param_value(
  self : MySqlStmt,
  index : Int,
  value : Bytes,
  length : UInt,
) -> Unit = "moonbit_mariadb_stmt_set_param_value"

///|
#borrow(mysql_stmt)
extern "c" fn mysql_stmt_execute(mysql_stmt : MySqlStmt) -> Int = "moonbit_mariadb_mysql_stmt_execute"

///|
#borrow(mysql_stmt)
extern "c" fn mysql_stmt_field_count(mysql_stmt : MySqlStmt) -> UInt = "moonbit_mariadb_mysql_stmt_field_count"

///|
#borrow(self, sizes, types, unsigned)
extern "c" fn MySqlStmt::stmt_bind_results(
  self : MySqlStmt,
  result_field_count : UInt,
  sizes : FixedArray[UInt],
  types : FixedArray[UInt],
  unsigned : FixedArray[Bool],
) -> Int = "moonbit_mariadb_stmt_bind_results"

///|
pub fn MySqlStmt::fetch(self : MySqlStmt) -> MySqlStmtFetchResult {
  let fetch_result = self.stmt_fetch()
  if fetch_result == mysql_no_data() {
    MySqlStmtFetchResult::NoData
  } else if fetch_result == mysql_data_truncated() {
    let column_values = self.stmt_result_column_values()
    MySqlStmtFetchResult::Truncated(MySqlStmtResultRow(column_values))
  } else if fetch_result == 0 {
    let column_values = self.stmt_result_column_values()
    MySqlStmtFetchResult::Data(MySqlStmtResultRow(column_values))
  } else {
    let error = mysql_stmt_error(self).to_bytes()
      |> @encoding/utf8.decode_lossy(_)
    MySqlStmtFetchResult::Error("Failed to fetch statement result: " + error)
  }
}

///|
#borrow(mysql_stmt)
extern "c" fn MySqlStmt::stmt_fetch(mysql_stmt : MySqlStmt) -> Int = "moonbit_mariadb_mysql_stmt_fetch"

///|
extern "c" fn mysql_no_data() -> Int = "moonbit_mariadb_stmt_mysql_no_data"

///|
extern "c" fn mysql_data_truncated() -> Int = "moonbit_mariadb_stmt_mysql_data_truncated"

///|
#borrow(mysql_stmt)
extern "c" fn MySqlStmt::stmt_result_column_values(
  mysql_stmt : MySqlStmt,
) -> FixedArray[Bytes] = "moonbit_mariadb_stmt_result_column_values"
