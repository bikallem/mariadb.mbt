///|
type MySql

///|
pub fn real_connect(
  host? : String,
  port? : UInt = 3306U,
  user~ : String,
  password~ : String,
  database~ : String,
  unix_socket? : String,
  client_flag? : UInt = 0U,
) -> MySql raise {
  let host = match host {
    None => b"localhost"
    Some(h) => @encoding/utf8.encode(h)
  }
  let user = @encoding/utf8.encode(user)
  let password = @encoding/utf8.encode(password)
  let database = @encoding/utf8.encode(database)
  let unix_socket = match unix_socket {
    None => Bytes::make(0, b'0')
    Some(us) => @encoding/utf8.encode(us)
  }
  let mysql = MySql::init()
  guard !mysql_real_connect(
    mysql,
    host~,
    user~,
    password~,
    database~,
    port~,
    unix_socket~,
    client_flag~,
  ).is_null() else {
    mysql.fail("Failed to connect to MariaDB server at \{host}:\{port}")
  }
  mysql
}

///|
#borrow(mysql, host, user, password, database, unix_socket, port)
extern "c" fn mysql_real_connect(
  mysql : MySql,
  host~ : Bytes,
  user~ : Bytes,
  password~ : Bytes,
  database~ : Bytes,
  port~ : UInt,
  unix_socket~ : Bytes,
  client_flag~ : UInt,
) -> Pointer = "moonbit_mariadb_mysql_real_connect"

///|
fn MySql::init() -> MySql raise {
  let mysql = mysql_init()
  guard !mysql.is_null() else { fail("Failed to initialize MySQL connection") }
  mysql.to_external()
}

///|
extern "c" fn mysql_init() -> Pointer = "moonbit_mariadb_init"

///|
#borrow(self, cs)
pub extern "c" fn MySql::set_character_set(self : MySql, cs : Bytes) -> Int = "moonbit_mariadb_mysql_set_character_set"

///|
pub fn MySql::real_escape_string(self : Self, s : String) -> String {
  let from = @encoding/utf8.encode(s)
  let to = Bytes::make(from.length() * 2 + 1, 0) // Allocate enough space for escaped string
  let escaped_len = mysql_real_escape_string(
    self,
    to,
    from,
    from.length().reinterpret_as_uint(),
  )
  let to = to[0:escaped_len]
  @encoding/utf8.decode_lossy(to)
}

///|
#borrow(mysql, to, from)
extern "c" fn mysql_real_escape_string(
  mysql : MySql,
  to : Bytes,
  from : Bytes,
  length : UInt,
) -> Int = "moonbit_mariadb_mysql_real_escape_string"

///|
/// Executes the given query and returns the result.
pub fn MySql::execute(self : Self, query : String) -> MySqlRes raise {
  let bytes_query = @encoding/utf8.encode(query)
  let len = bytes_query.length().reinterpret_as_uint()
  guard mysql_real_query(self, bytes_query, len) == 0 else {
    self.fail("Failed to execute query '\{query}'")
  }
  MySqlRes::new(self)
}

///|
#borrow(mysql, query)
extern "c" fn mysql_real_query(
  mysql : MySql,
  query : Bytes,
  length : UInt,
) -> Int = "moonbit_mariadb_mysql_real_query"

///|
#borrow(self)
pub extern "c" fn MySql::affected_rows(self : Self) -> UInt = "moonbit_mariadb_mysql_affected_rows"

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
  let error = mysql_error(self).to_bytes() |> @encoding/utf8.decode_lossy(_)
  raise Err(err_msg, mysql_errno(self), error, loc)
}

///|
#borrow(mysql)
extern "c" fn mysql_errno(mysql : MySql) -> UInt = "moonbit_mariadb_mysql_errno"

///|
#borrow(mysql)
extern "c" fn mysql_error(mysql : MySql) -> Pointer = "moonbit_mariadb_mysql_error"
