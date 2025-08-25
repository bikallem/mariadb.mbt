///|
struct Result {
  res : MYSQL_RES
  column_count : UInt
}

///|
#external
priv type MYSQL_RES

///|
fn Result::new(mysql : MySql) -> Result? {
  guard mysql_store_result(mysql).to() is Some(res) else { return None }
  let column_count = mysql_num_fields(res)
  Some(Result::{ res, column_count })
}

///|
extern "c" fn mysql_store_result(mysql : MySql) -> Nullable[MYSQL_RES] = "mysql_store_result"

///|
extern "c" fn mysql_num_fields(res : MYSQL_RES) -> UInt = "mysql_num_fields"

///|
pub fn Result::fetch_row(self : Self) -> ResultRow? {
  guard mysql_fetch_row(self.res).to() is Some(row) else { return None }
  Some(ResultRow::new(row, self.column_count))
}

///|
extern "c" fn mysql_fetch_row(res : MYSQL_RES) -> Nullable[MYSQL_ROW] = "mysql_fetch_row"

///|
pub fn Result::free_result(self : Result) -> Unit {
  mysql_free_result(self.res)
}

///|
extern "c" fn mysql_free_result(res : MYSQL_RES) = "mysql_free_result"

///|
pub fn Result::iter(self : Result) -> Iter[ResultRow] {
  Iter::new(fn(visit : (ResultRow) -> IterResult) {
    loop self.fetch_row() {
      Some(row) => {
        guard visit(row) == IterContinue else { break IterEnd }
        continue self.fetch_row()
      }
      None => break IterEnd
    }
  })
}
