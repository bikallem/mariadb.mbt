///|
struct MySqlRow(FixedArray[Bytes])

///|
#external
priv type MYSQL_ROW

///|
fn MySqlRow::new(row : MYSQL_ROW, column_count : UInt) -> MySqlRow {
  MySqlRow(moonbit_row_column_values(row, column_count))
}

///|
extern "c" fn moonbit_row_column_values(
  row : MYSQL_ROW,
  count : UInt,
) -> FixedArray[Bytes] = "moonbit_row_column_values"

///|
pub fn MySqlRow::op_get(self : MySqlRow, index : Int) -> String {
  @encoding.decode_lossy(encoding=UTF8, self.0[index])
}

///|
pub fn MySqlRow::get(self : MySqlRow, index : Int) -> String? {
  self.0.get(index).map(@encoding.decode_lossy(encoding=UTF8, _))
}
