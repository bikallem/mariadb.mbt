///|
pub trait ColumnValue {
  to(value : Bytes) -> Self raise
}

///|
pub impl ColumnValue for Int with to(value : Bytes) -> Int {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_int(v)
}

///|
pub impl ColumnValue for UInt with to(value : Bytes) -> UInt {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_uint(v)
}

///|
pub impl ColumnValue for Int64 with to(value : Bytes) -> Int64 {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_int64(v)
}

///|
pub impl ColumnValue for Bool with to(value : Bytes) -> Bool {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_bool(v)
}

///|
pub impl ColumnValue for Float with to(value : Bytes) -> Float {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_double(v).to_float()
}

///|
pub impl ColumnValue for Double with to(value : Bytes) -> Double {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_double(v)
}

///|
pub impl ColumnValue for String with to(value : Bytes) -> String {
  @encoding/utf8.decode_lossy(value)
}

///|
pub impl ColumnValue for Bytes with to(value : Bytes) -> Bytes {
  value
}
