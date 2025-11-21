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
  guard value is [i32le(v), ..]
  v
}

///|
pub impl StmtResultColumnValue for UInt with to(value : Bytes) -> UInt {
  guard value is [u32le(v), ..]
  v
}

///|
pub impl StmtResultColumnValue for Int64 with to(value : Bytes) -> Int64 {
  guard value is [i64le(v), ..]
  v
}

///|
pub impl StmtResultColumnValue for Bool with to(value : Bytes) -> Bool {
  guard value is [u32le(v), ..]
  v != 0
}

///|
pub impl StmtResultColumnValue for Float with to(value : Bytes) -> Float {
  guard value is [u32le(v), ..]
  Float::from_uint(v)
}

///|
pub impl StmtResultColumnValue for Double with to(value : Bytes) -> Double {
  guard value is [u64le(u64), ..]
  u64.reinterpret_as_double()
}

///|
pub impl StmtResultColumnValue for String with to(value : Bytes) -> String {
  @encoding/utf8.decode_lossy(value)
}

///|
pub impl StmtResultColumnValue for Bytes with to(value : Bytes) -> Bytes {
  return value
}
