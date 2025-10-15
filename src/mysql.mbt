///|
type MySql

///|
pub fn connect_via_tcp_socket(
  host~ : String,
  port~ : UInt,
  user~ : String,
  password~ : String,
  database~ : String,
  client_flag? : UInt = 0U,
) -> MySql raise {
  let mysql = MySql::init()
  let host = @encoding/utf8.encode(host)
  let user = @encoding/utf8.encode(user)
  let password = @encoding/utf8.encode(password)
  let database = @encoding/utf8.encode(database)
  guard mariadb_connect_via_tcp_socket(
    mysql,
    host~,
    port~,
    user~,
    password~,
    database~,
    client_flag~,
  ) else {
    mysql.fail("Failed to connect to MariaDB server at \{host}:\{port}")
  }
  mysql
}

///|
#borrow(mysql, host, user, password, database)
extern "c" fn mariadb_connect_via_tcp_socket(
  mysql : MySql,
  host~ : Bytes,
  port~ : UInt,
  user~ : Bytes,
  password~ : Bytes,
  database~ : Bytes,
  client_flag~ : UInt,
) -> Bool = "moonbit_mariadb_connect_via_tcp_socket"

///|
fn MySql::init() -> MySql raise {
  let mysql = mysql_init()
  guard !mysql.is_null() else { fail("Failed to initialize MySQL connection") }
  mysql.to_external()
}

///|
extern "c" fn mysql_init() -> Pointer = "moonbit_mariadb_init"

///|
pub fn connect_via_unix_socket(
  unix_socket~ : String,
  user~ : String,
  password~ : String,
  database~ : String,
  client_flag? : UInt = 0U,
) -> MySql raise {
  let mysql = MySql::init()
  let unix_socket = @encoding/utf8.encode(unix_socket)
  let user = @encoding/utf8.encode(user)
  let password = @encoding/utf8.encode(password)
  let database = @encoding/utf8.encode(database)
  guard mariadb_connect_via_unix_socket(
    mysql,
    unix_socket,
    user~,
    password~,
    database~,
    client_flag~,
  ) else {
    mysql.fail(
      "Failed to connect to MariaDB server via unix socket \{unix_socket}",
    )
  }
  mysql
}

///|
#borrow(mysql, unix_socket, user, password, database)
extern "c" fn mariadb_connect_via_unix_socket(
  mysql : MySql,
  unix_socket : Bytes,
  user~ : Bytes,
  password~ : Bytes,
  database~ : Bytes,
  client_flag~ : UInt,
) -> Bool = "moonbit_mariadb_connect_via_unix_socket"

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
  raise Err((err_msg, mysql_errno(self), error, loc))
}

///|
#borrow(mysql)
extern "c" fn mysql_errno(mysql : MySql) -> UInt = "moonbit_mariadb_mysql_errno"

///|
#borrow(mysql)
extern "c" fn mysql_error(mysql : MySql) -> Pointer = "moonbit_mariadb_mysql_error"
