///|
pub suberror MySqlStmtError (String, UInt, String, SourceLoc)

///|
pub impl Show for MySqlStmtError with output(self, logger) {
  let MySqlStmtError((msg, errcode, error, loc)) = self
  logger.write_string("MySqlStmtError(\{msg}), (\{errcode} \{error}) at \{loc}")
}

///|
#callsite(autofill(loc))
fn MySqlStmtError::new(
  mysql_stmt : MYSQL_STMT,
  err_msg : String,
  loc~ : SourceLoc,
) -> MySqlStmtError {
  let error = @ffi.moonbit_string(mysql_stmt_error(mysql_stmt))
  MySqlStmtError((err_msg, mysql_stmt_errno(mysql_stmt), error, loc))
}

///|
extern "c" fn mysql_stmt_errno(stmt : MYSQL_STMT) -> UInt = "mysql_stmt_errno"

///|
extern "c" fn mysql_stmt_error(stmt : MYSQL_STMT) -> @ffi.CString = "mysql_stmt_error"
