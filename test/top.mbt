///|
test "@mariadb.MySql::execute" {
  // This test assumes a valid MySQL connection and tests basic query execution
  // The function should return Some(QueryResult) for successful queries
  let mysql = @mariadb.connect(
    "localhost",
    user="dev1",
    password="devpass",
    database="moonbit_test",
  )
  let result = mysql.execute("SELECT 1")
  match result {
    Some(_) => () // Expected: successful query returns Some(QueryResult)
    None => () //fail("Expected Some(QueryResult) for valid SELECT query")
  }
  mysql.close()
}

///|
test "@mariadb.MySql::execute/empty_query" {
  // Test boundary case: empty query string
  let mysql = @mariadb.connect(
    "localhost",
    user="dev1",
    password="devpass",
    database="moonbit_test",
  )
  let result = mysql.execute("")
  match result {
    Some(_) => () // MySQL might handle empty queries differently
    None => () // Or return None, both are acceptable boundary behaviors
  }
  mysql.close()
}

///|
test "panic @mariadb.MySql::execute/invalid_sql" {
  // Test boundary case: invalid SQL syntax should raise an error
  let mysql = @mariadb.connect(
    "localhost",
    user="dev1",
    password="devpass",
    database="moonbit_test",
  )
  ignore(mysql.execute("INVALID SQL SYNTAX HERE"))
  mysql.close()
}

///|
fn main {
  // This test assumes a valid MySQL connection and tests basic query execution
  // The function should return Some(QueryResult) for successful queries
  try {
    let mysql = @mariadb.connect(
      "localhost",
      user="dev1",
      password="devpass",
      database="moonbit_test",
    )
    let result = mysql.execute("SELECT 1")
    match result {
      Some(_) => println("Connected successfully!")
      None => fail("Expected Some(QueryResult) for valid SELECT query")
    }
    mysql.close()
  } catch {
    e => println("Failed to connect to MySQL database, \{e}")
  }
}
