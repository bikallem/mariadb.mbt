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
pub fn[T : Column] MySqlRow::op_get(self : MySqlRow, index : Int) -> T {
  Column::to(self.0[index])
}

///|
pub fn[T : Column] MySqlRow::get(self : MySqlRow, index : Int) -> T? {
  self.0.get(index).map(Column::to)
}
