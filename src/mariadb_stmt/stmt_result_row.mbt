///|
struct StmtResultRow(FixedArray[Bytes])

///|
pub fn[T : Column] StmtResultRow::op_get(
  self : StmtResultRow,
  index : Int,
) -> T {
  Column::to(self.0[index])
}

///|
pub fn[T : Column] StmtResultRow::get(self : StmtResultRow, index : Int) -> T? {
  self.0.get(index).map(Column::to)
}
