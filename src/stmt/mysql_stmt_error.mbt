///|
pub suberror MySqlStmtError {
  MySqlStmtError(String, UInt, String, SourceLoc)
}

///|
pub impl Show for MySqlStmtError with output(self, logger) {
  let MySqlStmtError(msg, errcode, error, loc) = self
  logger.write_string("MySqlStmtError(\{msg}), (\{errcode} \{error}) at \{loc}")
}

///|
#callsite(autofill(loc))
fn MySqlStmtError::new(
  mysql_stmt : MySqlStmt,
  err_msg : String,
  loc~ : SourceLoc,
) -> MySqlStmtError {
  let error = mysql_stmt_error(mysql_stmt).to_bytes()
    |> @encoding/utf8.decode_lossy(_)
  MySqlStmtError(err_msg, mysql_stmt_errno(mysql_stmt), error, loc)
}

///|
#borrow(mysql_stmt)
extern "c" fn mysql_stmt_errno(mysql_stmt : MySqlStmt) -> UInt = "moonbit_mariadb_mysql_stmt_errno"

///|
#borrow(mysql_stmt)
extern "c" fn mysql_stmt_error(mysql_stmt : MySqlStmt) -> Pointer = "moonbit_mariadb_mysql_stmt_error"
