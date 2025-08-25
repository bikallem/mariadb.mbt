///|
struct MySqlStmtResultRow(FixedArray[Bytes])

///|
pub fn[T : Column] MySqlStmtResultRow::op_get(
  self : MySqlStmtResultRow,
  index : Int,
) -> T {
  Column::to(self.0[index])
}

///|
pub fn[T : Column] MySqlStmtResultRow::get(
  self : MySqlStmtResultRow,
  index : Int,
) -> T? {
  self.0.get(index).map(Column::to)
}
