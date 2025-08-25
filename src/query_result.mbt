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
  guard mysql_store_result(mysql).to() is Some(res) else { return None }
  let column_count = mysql_num_fields(res)
  Some(QueryResult::{ res, column_count })
}

///|
extern "c" fn mysql_store_result(mysql : MySql) -> Nullable[MYSQL_RES] = "mysql_store_result"

///|
extern "c" fn mysql_num_fields(res : MYSQL_RES) -> UInt = "mysql_num_fields"

///|
pub fn QueryResult::fetch_row(self : Self) -> QueryResultRow? {
  guard mysql_fetch_row(self.res).to() is Some(row) else { return None }
  Some(QueryResultRow::new(row, self.column_count))
}

///|
extern "c" fn mysql_fetch_row(res : MYSQL_RES) -> Nullable[MYSQL_ROW] = "mysql_fetch_row"

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
