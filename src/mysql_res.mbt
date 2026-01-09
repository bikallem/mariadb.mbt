///|
type MySqlRes

///|
fn MySqlRes::new(mysql : MySql) -> MySqlRes raise {
  let res = mysql_store_result(mysql)
  guard !res.is_null() else { mysql.fail("Failed to store MySQL result") }
  res.to_external()
}

///|
#borrow(mysql)
extern "c" fn mysql_store_result(mysql : MySql) -> Pointer = "moonbit_mariadb_store_result"

///|
#borrow(res)
pub extern "c" fn MySqlRes::num_fields(res : MySqlRes) -> UInt = "moonbit_mariadb_num_fields"

///|
pub fn MySqlRes::fetch_row(self : MySqlRes) -> MySqlRow? {
  let row = self.mysql_fetch_row()
  guard !row.is_null() else { return None }
  let row : MYSQL_ROW = row.to_external()
  let column_count = self.num_fields()
  let row = MySqlRow(moonbit_row_column_values(row, column_count))
  Some(row)
}

///|
#borrow(self)
extern "c" fn MySqlRes::mysql_fetch_row(self : MySqlRes) -> Pointer = "moonbit_mariadb_mysql_fetch_row"

///|
pub fn MySqlRes::iter(self : MySqlRes) -> Iter[MySqlRow] {
  Iter::new(fn() { self.fetch_row() })
}
