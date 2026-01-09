///|
/// MySQL error information, including the user error message, mysql error code, and mysql error message.
pub suberror Err {
  Err(String, UInt, String, SourceLoc)
}

///|
pub impl Show for Err with output(self, logger) {
  let Err(msg, errcode, error, loc) = self
  logger.write_string("\{msg} (\{errcode}: \{error}) at \{loc}")
}
