///|
/// Trait for MySQL input parameter binding for prepared statements.
pub trait MySqlStmtParamValue {
  set_value(self : Self, stmt : MySqlStmt, index : Int) -> Unit
}

///|
pub impl MySqlStmtParamValue for Int with set_value(
  self : Int,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for UInt with set_value(
  self : UInt,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for Int64 with set_value(
  self : Int64,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 8)
}

///|
pub impl MySqlStmtParamValue for UInt64 with set_value(
  self : UInt64,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 8)
}

///|
pub impl MySqlStmtParamValue for Bool with set_value(
  self : Bool,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  let v = self.to_int()
  stmt.set_param_value(index, v.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for Float with set_value(
  self : Float,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 4)
}

///|
pub impl MySqlStmtParamValue for Double with set_value(
  self : Double,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 8)
}

///|
pub impl MySqlStmtParamValue for String with set_value(
  self : String,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  let bytes = @encoding/utf8.encode(self)
  stmt.set_param_value(index, bytes, bytes.length().reinterpret_as_uint())
}

///|
pub impl MySqlStmtParamValue for Bytes with set_value(
  self : Bytes,
  stmt : MySqlStmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self, self.length().reinterpret_as_uint())
}
