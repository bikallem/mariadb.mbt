///|
struct MySqlStmtResult(Stmt)

///|
pub(all) enum MySqlStmtFetchResult {
  Data(MySqlStmtResultRow)
  NoData // MYSQL_NO_DATA  
}

///|
pub fn MySqlStmtResult::fetch(
  self : MySqlStmtResult,
) -> Result[MySqlStmtFetchResult, MySqlStmtError] {
  guard self.result_binds is Some(result_binds) else { return Ok(NoData) }
  let row = mysql_stmt_fetch(self.mysql_stmt)
  if row == moonbit_MYSQL_NO_DATA() {
    Ok(NoData)
  } else if row == 0 || row == moonbit_MYSQL_DATA_TRUNCATED() {
    let column_values = moonbit_stmt_result_column_values(
      self.mysql_stmt,
      result_binds,
      self.result_binds_count,
    )
    Ok(Data(MySqlStmtResultRow(column_values)))
  } else {
    Err(
      MySqlStmtError::new(
        self.mysql_stmt,
        "Failed to fetch statement result row",
      ),
    )
  }
}

///|
extern "c" fn mysql_stmt_fetch(stmt : MYSQL_STMT) -> Int = "mysql_stmt_fetch"

///|
extern "c" fn moonbit_MYSQL_NO_DATA() -> Int = "moonbit_MYSQL_NO_DATA"

///|
extern "c" fn moonbit_MYSQL_DATA_TRUNCATED() -> Int = "moonbit_MYSQL_DATA_TRUNCATED"

///|
extern "c" fn moonbit_stmt_result_column_values(
  mysql_stmt : MYSQL_STMT,
  binds : MYSQL_BIND_ARRAY,
  count : UInt,
) -> FixedArray[Bytes] = "moonbit_stmt_result_column_values"

///|
pub fn MySqlStmtResult::affected_rows(self : MySqlStmtResult) -> UInt64 {
  mysql_stmt_affected_rows(self.mysql_stmt)
}

///|
extern "c" fn mysql_stmt_affected_rows(stmt : MYSQL_STMT) -> UInt64 = "mysql_stmt_affected_rows"

///|
pub fn MySqlStmtResult::iter(
  self : MySqlStmtResult,
) -> Iter[Result[MySqlStmtResultRow, MySqlStmtError]] {
  Iter::new(fn(
    visit : (Result[MySqlStmtResultRow, MySqlStmtError]) -> IterResult,
  ) {
    loop self.fetch() {
      Ok(Data(row)) => {
        guard visit(Ok(row)) == IterContinue else { break IterEnd }
        continue self.fetch()
      }
      Ok(NoData) => break IterEnd
      Err(err) => {
        let _ = visit(Err(err))
        break IterEnd
      }
    }
  })
}
