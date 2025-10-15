///|
const MARIADB_SOCKET = "MARIADB_SOCKET"

///|
fn main {
  try {
    let env = @sys.get_env_vars()

    // Alternately, you can connect via TCP:
    // let mariadb = @mariadb.connect(
    //   host="127.0.0.1",
    //   port=3307,
    //   user="contacts_user",
    //   password="contacts_password",
    //   database="contacts_db",
    // )

    let mariadb = @mariadb.connect_via_unix_socket(
      unix_socket=env[MARIADB_SOCKET],
      user="contacts_user",
      password="contacts_password",
      database="contacts_db",
    )
    println("✓ Connected to MariaDB successfully!")
    mariadb.close()
    println("✓ Connection closed.")
  } catch {
    e => println("✗ Error: \{e}")
  }
}
