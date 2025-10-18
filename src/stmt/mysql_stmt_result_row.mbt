///|
struct MySqlStmtResultRow(FixedArray[Bytes])

///|
#alias("_[_]")
pub fn[T : StmtResultColumnValue] MySqlStmtResultRow::unsafe_get(
  self : MySqlStmtResultRow,
  index : Int,
) -> T raise {
  self.0
  .get(index)
  .map(StmtResultColumnValue::to)
  .unwrap_or_else(() => fail(
    "Failed to get column value at index " + index.to_string(),
  ))
}

///|
pub fn[T : StmtResultColumnValue] MySqlStmtResultRow::get(
  self : MySqlStmtResultRow,
  index : Int,
) -> T? {
  self.0.get(index).map(StmtResultColumnValue::to) catch {
    _ => None
  }
}

///|
pub impl StmtResultColumnValue for Int with to(value : Bytes) -> Int {
  value[:4].to_int_le()
}

///|
pub impl StmtResultColumnValue for UInt with to(value : Bytes) -> UInt {
  value[:4].to_uint_le()
}

///|
pub impl StmtResultColumnValue for Int64 with to(value : Bytes) -> Int64 {
  value[:8].to_int64_le()
}

///|
pub impl StmtResultColumnValue for Bool with to(value : Bytes) -> Bool {
  value[:4].to_int_le() != 0
}

///|
pub impl StmtResultColumnValue for Float with to(value : Bytes) -> Float {
  value[:4].to_float_le()
}

///|
pub impl StmtResultColumnValue for Double with to(value : Bytes) -> Double {
  value[:8].to_double_le()
}

///|
pub impl StmtResultColumnValue for String with to(value : Bytes) -> String {
  @encoding/utf8.decode_lossy(value)
}

///|
pub impl StmtResultColumnValue for Bytes with to(value : Bytes) -> Bytes {
  return value
}
