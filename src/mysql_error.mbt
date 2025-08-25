///| MySQL error information, including the user error message, mysql error code, and mysql error message.
pub suberror MySqlError (String, UInt, String, SourceLoc)

///|
pub impl Show for MySqlError with output(self, logger) {
  let MySqlError((msg, errcode, error, loc)) = self
  logger.write_string("\{msg} (\{errcode}: \{error}) at \{loc}")
}
