///|
/// Trait for MySQL input parameter binding for prepared statements.
pub trait MySqlStmtParamValue {
  value(self : Self) -> (Bytes, Int)
}

///|
pub impl MySqlStmtParamValue for Int with value(self : Int) -> (Bytes, Int) {
  (
    [
      (self & 0xFF).to_byte(),
      ((self >> 8) & 0xFF).to_byte(),
      ((self >> 16) & 0xFF).to_byte(),
      ((self >> 24) & 0xFF).to_byte(),
    ],
    4,
  )
}

///|
pub impl MySqlStmtParamValue for UInt with value(self : UInt) -> (Bytes, Int) {
  (
    [
      (self & 0xFF).to_byte(),
      ((self >> 8) & 0xFF).to_byte(),
      ((self >> 16) & 0xFF).to_byte(),
      ((self >> 24) & 0xFF).to_byte(),
    ],
    4,
  )
}

///|
pub impl MySqlStmtParamValue for Int64 with value(self : Int64) -> (Bytes, Int) {
  (
    [
      (self & 0xFF).to_byte(),
      ((self >> 8) & 0xFF).to_byte(),
      ((self >> 16) & 0xFF).to_byte(),
      ((self >> 24) & 0xFF).to_byte(),
      ((self >> 32) & 0xFF).to_byte(),
      ((self >> 40) & 0xFF).to_byte(),
      ((self >> 48) & 0xFF).to_byte(),
      ((self >> 56) & 0xFF).to_byte(),
    ],
    8,
  )
}

///|
pub impl MySqlStmtParamValue for UInt64 with value(self : UInt64) -> (
  Bytes,
  Int,
) {
  (
    [
      (self & 0xFF).to_byte(),
      ((self >> 8) & 0xFF).to_byte(),
      ((self >> 16) & 0xFF).to_byte(),
      ((self >> 24) & 0xFF).to_byte(),
      ((self >> 32) & 0xFF).to_byte(),
      ((self >> 40) & 0xFF).to_byte(),
      ((self >> 48) & 0xFF).to_byte(),
      ((self >> 56) & 0xFF).to_byte(),
    ],
    8,
  )
}

///|
pub impl MySqlStmtParamValue for Bool with value(self : Bool) -> (Bytes, Int) {
  let v = self.to_int()
  (
    [
      (v & 0xFF).to_byte(),
      ((v >> 8) & 0xFF).to_byte(),
      ((v >> 16) & 0xFF).to_byte(),
      ((v >> 24) & 0xFF).to_byte(),
    ],
    4,
  )
}

///|
pub impl MySqlStmtParamValue for Float with value(self : Float) -> (Bytes, Int) {
  let bits = self.reinterpret_as_int()
  (
    [
      (bits & 0xFF).to_byte(),
      ((bits >> 8) & 0xFF).to_byte(),
      ((bits >> 16) & 0xFF).to_byte(),
      ((bits >> 24) & 0xFF).to_byte(),
    ],
    4,
  )
}

///|
pub impl MySqlStmtParamValue for Double with value(self : Double) -> (
  Bytes,
  Int,
) {
  let bits = self.reinterpret_as_int64()
  (
    [
      (bits & 0xFF).to_byte(),
      ((bits >> 8) & 0xFF).to_byte(),
      ((bits >> 16) & 0xFF).to_byte(),
      ((bits >> 24) & 0xFF).to_byte(),
      ((bits >> 32) & 0xFF).to_byte(),
      ((bits >> 40) & 0xFF).to_byte(),
      ((bits >> 48) & 0xFF).to_byte(),
      ((bits >> 56) & 0xFF).to_byte(),
    ],
    8,
  )
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
