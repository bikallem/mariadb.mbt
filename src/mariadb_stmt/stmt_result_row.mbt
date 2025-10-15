///|
struct StmtResultRow(FixedArray[Bytes])

///|
#alias("_[_]")
pub fn[T : ColumnValue] StmtResultRow::unsafe_get(
  self : StmtResultRow,
  index : Int,
) -> T {
  ColumnValue::to(self.0[index])
}

///|
pub fn[T : ColumnValue] StmtResultRow::get(
  self : StmtResultRow,
  index : Int,
) -> T? {
  self.0.get(index).map(ColumnValue::to)
}
