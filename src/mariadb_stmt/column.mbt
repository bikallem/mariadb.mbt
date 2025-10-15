///|
pub trait ColumnValue {
  to(value : Bytes) -> Self
}

///|
pub impl ColumnValue for Int with to(value : Bytes) -> Int {
  value[:4].to_int_le()
}

///|
pub impl ColumnValue for UInt with to(value : Bytes) -> UInt {
  value[:4].to_uint_le()
}

///|
pub impl ColumnValue for Int64 with to(value : Bytes) -> Int64 {
  value[:8].to_int64_le()
}

///|
pub impl ColumnValue for Bool with to(value : Bytes) -> Bool {
  value[:4].to_int_le() != 0
}

///|
pub impl ColumnValue for Float with to(value : Bytes) -> Float {
  value[:4].to_float_le()
}

///|
pub impl ColumnValue for Double with to(value : Bytes) -> Double {
  value[:8].to_double_le()
}

///|
pub impl ColumnValue for String with to(value : Bytes) -> String {
  @encoding/utf8.decode_lossy(value)
}

///|
pub impl ColumnValue for Bytes with to(value : Bytes) -> Bytes {
  return value
}
