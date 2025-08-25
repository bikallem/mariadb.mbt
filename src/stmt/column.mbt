///|
trait Column {
  to(value : Bytes) -> Self
}

///|
pub impl Column for Int with to(value : Bytes) -> Int {
  value[:4].to_int_le()
}

///|
pub impl Column for UInt with to(value : Bytes) -> UInt {
  value[:4].to_uint_le()
}

///|
pub impl Column for Int64 with to(value : Bytes) -> Int64 {
  value[:8].to_int64_le()
}

///|
pub impl Column for Bool with to(value : Bytes) -> Bool {
  value[:4].to_int_le() != 0
}

///|
pub impl Column for Float with to(value : Bytes) -> Float {
  value[:4].to_float_le()
}

///|
pub impl Column for Double with to(value : Bytes) -> Double {
  value[:8].to_double_le()
}

///|
pub impl Column for String with to(value : Bytes) -> String {
  @encoding.decode_lossy(encoding=UTF8, value)
}

///|
pub impl Column for Bytes with to(value : Bytes) -> Bytes {
  return value
}
