///|
#external
type MySql

///|
/// Connect to MySQL with the given credentials. It sets the resulting connection 
/// character set to `utf8mb4`.
pub fn connect(
  host~ : String,
  port? : UInt,
  user~ : String,
  password~ : String,
  database~ : String,
  unix_socket? : String,
  client_flag? : ClientFlag = 0,
) -> MySql raise {
  let mysql = mysql_init(Nullable::none())
  guard mysql.to() is Some(mysql) else {
    fail("Failed to initialize MySQL connection")
  }
  let encode = @encoding.encode(encoding=UTF8, _)
  let host = encode(host)
  let user = encode(user)
  let password = encode(password)
  let database = encode(database)
  let unix_socket = match unix_socket {
    Some(socket) => Nullable::some(encode(socket))
    None => Nullable::none()
  }
  guard mysql_real_connect(
      mysql,
      host,
      user,
      password,
      database,
      port.unwrap_or(3306),
      unix_socket,
      client_flag.inner(),
    ).to()
    is Some(conn) else {
    mysql.fail("Failed to connect to MariaDB database")
  }
  if mysql_set_character_set(mysql, b"utf8mb4") != 0 {
    mysql.fail("Failed to set character set to 'utf8mb4'")
  }
  conn
}

///|
extern "c" fn mysql_init(mysql : Nullable[MySql]) -> Nullable[MySql] = "mysql_init"

///|
#borrow(host, user, passwd, db, unix_socket)
extern "c" fn mysql_real_connect(
  mysql : MySql,
  host : Bytes,
  user : Bytes,
  passwd : Bytes,
  db : Bytes,
  port : UInt,
  unix_socket : Nullable[Bytes],
  client_flag : UInt64,
) -> Nullable[MySql] = "mysql_real_connect"

///|
#borrow(cs)
extern "c" fn mysql_set_character_set(mysql : MySql, cs : Bytes) -> Int = "mysql_set_character_set"

///|
pub fn MySql::real_escape_string(self : Self, s : String) -> String {
  let from = @encoding.encode(encoding=UTF8, s)
  let to = Bytes::make(from.length() * 2 + 1, 0) // Allocate enough space for escaped string
  let escaped_len = mysql_real_escape_string(
    self,
    to,
    from,
    from.length().reinterpret_as_uint(),
  )
  let to = to[0:escaped_len]
  @encoding.decode_lossy(encoding=UTF8, to)
}

///|
#borrow(to, from)
extern "c" fn mysql_real_escape_string(
  mysql : MySql,
  to : Bytes,
  from : Bytes,
  length : UInt,
) -> Int = "mysql_real_escape_string"

///|
/// Executes the given query and returns the result.
pub fn MySql::execute(self : Self, query : String) -> QueryResult? raise {
  let bytes_query = @encoding.encode(encoding=UTF8, query)
  let len = bytes_query.length().reinterpret_as_uint()
  if mysql_real_query(self, bytes_query, len) != 0 {
    self.fail("Failed to execute query '\{query}'")
  }
  QueryResult::new(self)
}

///|
#borrow(query)
extern "c" fn mysql_real_query(
  mysql : MySql,
  query : Bytes,
  length : UInt,
) -> Int = "mysql_real_query"

///|
pub extern "c" fn MySql::close(self : MySql) = "mysql_close"

///|
pub fn MySql::affected_rows(self : Self) -> UInt {
  mysql_affected_rows(self)
}

///|
extern "c" fn mysql_affected_rows(mysql : MySql) -> UInt = "mysql_affected_rows"

///|
/// Raise a Failure with the current MySQL error information as returned
/// by the MySQL API(`mysql_error()` and `mysql_errno()`)
#inline
#callsite(autofill(loc))
pub fn[T] MySql::fail(
  self : MySql,
  err_msg : String,
  loc~ : SourceLoc,
) -> T raise {
  let error = @ffi.moonbit_string(mysql_error(self))
  raise Err((err_msg, mysql_errno(self), error, loc))
}

///|
extern "c" fn mysql_errno(mysql : MySql) -> UInt = "mysql_errno"

///|
extern "c" fn mysql_error(mysql : MySql) -> CString = "mysql_error"
