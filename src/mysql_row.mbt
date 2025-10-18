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
pub fn[T : ColumnValue] MySqlRow::unsafe_get(
  self : MySqlRow,
  index : Int,
) -> T raise {
  ColumnValue::to(self.0[index])
}

///|
pub fn[T : ColumnValue] MySqlRow::get(self : MySqlRow, index : Int) -> T? {
  self.0.get(index).bind(v => Some(ColumnValue::to(v)) catch { _ => None })
}

// Column value conversion implementations

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
