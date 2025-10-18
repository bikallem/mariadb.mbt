///|
pub enum MySqlStmtFetchResult {
  Data(MySqlStmtResultRow)
  Truncated(MySqlStmtResultRow)
  NoData
  Error(String)
}
