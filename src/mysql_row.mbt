///|
struct MySqlRow(FixedArray[Bytes])

///|
#external
priv type MYSQL_ROW

///|
extern "c" fn moonbit_row_column_values(
  row : MYSQL_ROW,
  count : UInt,
) -> FixedArray[Bytes] = "moonbit_row_column_values"

///|
#alias("_[_]")
pub fn[T : ResColumnValue] MySqlRow::unsafe_get(
  self : MySqlRow,
  index : Int,
) -> T raise {
  ResColumnValue::to(self.0[index])
}

///|
pub fn[T : ResColumnValue] MySqlRow::get(self : MySqlRow, index : Int) -> T? {
  self.0.get(index).bind(v => Some(ResColumnValue::to(v)) catch { _ => None })
}

// Column value conversion implementations

///|
pub impl ResColumnValue for Int with to(value : Bytes) -> Int {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_int(v)
}

///|
pub impl ResColumnValue for UInt with to(value : Bytes) -> UInt {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_uint(v)
}

///|
pub impl ResColumnValue for Int64 with to(value : Bytes) -> Int64 {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_int64(v)
}

///|
pub impl ResColumnValue for Bool with to(value : Bytes) -> Bool {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_bool(v)
}

///|
pub impl ResColumnValue for Float with to(value : Bytes) -> Float {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_double(v).to_float()
}

///|
pub impl ResColumnValue for Double with to(value : Bytes) -> Double {
  let v = @encoding/utf8.decode_lossy(value)
  @strconv.parse_double(v)
}

///|
pub impl ResColumnValue for String with to(value : Bytes) -> String {
  @encoding/utf8.decode_lossy(value)
}

///|
pub impl ResColumnValue for Bytes with to(value : Bytes) -> Bytes {
  value
}
