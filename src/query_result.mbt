///|
struct QueryResult {
  res : MYSQL_RES
  column_count : UInt
}

///|
#external
priv type MYSQL_RES

///|
fn QueryResult::new(mysql : MySql) -> QueryResult? {
  let res = mysql_store_result(mysql)
  guard !res.is_null() else { return None }
  let res : MYSQL_RES = res.unsafe_cast()
  let column_count = mysql_num_fields(res)
  Some(QueryResult::{ res, column_count })
}

///|
extern "c" fn mysql_store_result(mysql : MySql) -> Pointer = "mysql_store_result"

///|
extern "c" fn mysql_num_fields(res : MYSQL_RES) -> UInt = "mysql_num_fields"

///|
pub fn QueryResult::fetch_row(self : Self) -> QueryResultRow? {
  let row = mysql_fetch_row(self.res)
  guard !row.is_null() else { return None }
  let row : MYSQL_ROW = row.unsafe_cast()
  Some(QueryResultRow::new(row, self.column_count))
}

///|
extern "c" fn mysql_fetch_row(res : MYSQL_RES) -> Pointer = "mysql_fetch_row"

///|
pub fn QueryResult::free_result(self : QueryResult) -> Unit {
  mysql_free_result(self.res)
}

///|
extern "c" fn mysql_free_result(res : MYSQL_RES) = "mysql_free_result"

///|
pub fn QueryResult::iter(self : QueryResult) -> Iter[QueryResultRow] {
  Iter::new(fn(visit : (QueryResultRow) -> IterResult) {
    loop self.fetch_row() {
      Some(row) => {
        guard visit(row) == IterContinue else { break IterEnd }
        continue self.fetch_row()
      }
      None => break IterEnd
    }
  })
}
