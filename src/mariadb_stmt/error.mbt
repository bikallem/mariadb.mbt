///|
pub suberror StmtError (String, UInt, String, SourceLoc)

///|
pub impl Show for StmtError with output(self, logger) {
  let StmtError((msg, errcode, error, loc)) = self
  logger.write_string("MySqlStmtError(\{msg}), (\{errcode} \{error}) at \{loc}")
}

///|
#callsite(autofill(loc))
fn StmtError::new(
  mysql_stmt : MYSQL_STMT,
  err_msg : String,
  loc~ : SourceLoc,
) -> StmtError {
  let error = mysql_stmt_error(mysql_stmt).to_bytes()
    |> @encoding/utf8.decode_lossy(_)
  StmtError((err_msg, mysql_stmt_errno(mysql_stmt), error, loc))
}

///|
extern "c" fn mysql_stmt_errno(stmt : MYSQL_STMT) -> UInt = "mysql_stmt_errno"

///|
extern "c" fn mysql_stmt_error(stmt : MYSQL_STMT) -> Pointer = "mysql_stmt_error"
