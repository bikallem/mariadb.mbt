///| Trait for MySQL input parameter binding for prepared statements.
pub trait ParamValue {
  set_value(self : Self, stmt : Stmt, index : Int) -> Unit
}

///|
pub impl ParamValue for Int with set_value(self : Int, stmt : Stmt, index : Int) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 4)
}

///|
pub impl ParamValue for UInt with set_value(
  self : UInt,
  stmt : Stmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 4)
}

///|
pub impl ParamValue for Int64 with set_value(
  self : Int64,
  stmt : Stmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 8)
}

///|
pub impl ParamValue for UInt64 with set_value(
  self : UInt64,
  stmt : Stmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 8)
}

///|
pub impl ParamValue for Bool with set_value(
  self : Bool,
  stmt : Stmt,
  index : Int,
) -> Unit {
  let v = self.to_int()
  stmt.set_param_value(index, v.to_le_bytes(), 4)
}

///|
pub impl ParamValue for Float with set_value(
  self : Float,
  stmt : Stmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 4)
}

///|
pub impl ParamValue for Double with set_value(
  self : Double,
  stmt : Stmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self.to_le_bytes(), 8)
}

///|
pub impl ParamValue for String with set_value(
  self : String,
  stmt : Stmt,
  index : Int,
) -> Unit {
  let bytes = @encoding.encode(encoding=UTF8, self)
  stmt.set_param_value(index, bytes, bytes.length().reinterpret_as_uint())
}

///|
pub impl ParamValue for Bytes with set_value(
  self : Bytes,
  stmt : Stmt,
  index : Int,
) -> Unit {
  stmt.set_param_value(index, self, self.length().reinterpret_as_uint())
}
