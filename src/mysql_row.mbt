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
#alias("_[_]")
pub fn MySqlRow::unsafe_get(self : MySqlRow, index : Int) -> String {
  @encoding/utf8.decode_lossy(self.0[index])
}

///|
pub fn MySqlRow::get(self : MySqlRow, index : Int) -> String? {
  self.0.get(index).map(v => @encoding/utf8.decode_lossy(v))
}
