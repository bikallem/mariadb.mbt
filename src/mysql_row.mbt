///|
struct MySqlRow(FixedArray[Bytes])

///|
#external
priv type MYSQL_ROW

///|
extern "c" fn moonbit_row_column_values(
  row : MYSQL_ROW,
  count : UInt,
) -> FixedArray[Bytes] = "moonbit_row_column_values"

///|
#alias("_[_]")
pub fn[T : ColumnValue] MySqlRow::unsafe_get(
  self : MySqlRow,
  index : Int,
) -> T raise {
  ColumnValue::to(self.0[index])
}

///|
pub fn[T : ColumnValue] MySqlRow::get(self : MySqlRow, index : Int) -> T? {
  self.0.get(index).bind(v => Some(ColumnValue::to(v)) catch { _ => None })
}
