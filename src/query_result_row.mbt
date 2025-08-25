///|
struct QueryResultRow(FixedArray[Bytes])

///|
#external
priv type MYSQL_ROW

///|
fn QueryResultRow::new(row : MYSQL_ROW, column_count : UInt) -> QueryResultRow {
  QueryResultRow(moonbit_row_column_values(row, column_count))
}

///|
extern "c" fn moonbit_row_column_values(
  row : MYSQL_ROW,
  count : UInt,
) -> FixedArray[Bytes] = "moonbit_row_column_values"

///|
pub fn QueryResultRow::op_get(self : QueryResultRow, index : Int) -> String {
  @encoding.decode_lossy(encoding=UTF8, self.0[index])
}

///|
pub fn QueryResultRow::get(self : QueryResultRow, index : Int) -> String? {
  self.0.get(index).map(@encoding.decode_lossy(encoding=UTF8, _))
}
