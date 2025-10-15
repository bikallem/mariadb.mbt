///|
struct StmtResultRow(FixedArray[Bytes])

///|
#alias("_[_]")
pub fn[T : Column] StmtResultRow::unsafe_get(
  self : StmtResultRow,
  index : Int,
) -> T {
  Column::to(self.0[index])
}

///|
pub fn[T : Column] StmtResultRow::get(self : StmtResultRow, index : Int) -> T? {
  self.0.get(index).map(Column::to)
}
