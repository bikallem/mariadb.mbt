///|
/// Trait for MySQL input parameter binding for prepared statements.
pub trait MySqlStmtParamValue {
  value(self : Self) -> (Bytes, Int)
}

///|
pub impl MySqlStmtParamValue for Int with value(self : Int) -> (Bytes, Int) {
  (self.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for UInt with value(self : UInt) -> (Bytes, Int) {
  (self.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for Int64 with value(self : Int64) -> (Bytes, Int) {
  (self.to_le_bytes(), 8)
}

///|
pub impl MySqlStmtParamValue for UInt64 with value(self : UInt64) -> (
  Bytes,
  Int,
) {
  (self.to_le_bytes(), 8)
}

///|
pub impl MySqlStmtParamValue for Bool with value(self : Bool) -> (Bytes, Int) {
  let v = self.to_int()
  (v.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for Float with value(self : Float) -> (Bytes, Int) {
  (self.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for Double with value(self : Double) -> (
  Bytes,
  Int,
) {
  (self.to_le_bytes(), 8)
}

///|
pub impl MySqlStmtParamValue for String with value(self : String) -> (
  Bytes,
  Int,
) {
  let bytes = @encoding/utf8.encode(self)
  (bytes, bytes.length())
}

///|
pub impl MySqlStmtParamValue for Bytes with value(self : Bytes) -> (Bytes, Int) {
  (self, self.length())
}
