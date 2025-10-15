///|
using @mariadb {type MySql}

///|
const MARIADB_SOCKET = "MARIADB_SOCKET"

///|
fn main {
  try {
    let env = @sys.get_env_vars()
    let mariadb = @mariadb.connect_via_unix_socket(
      unix_socket=env[MARIADB_SOCKET],
      user="contacts_user",
      password="contacts_password",
      database="contacts_db",
    )
    defer mariadb.close()
    println("✓ Connected to MariaDB successfully!")
    count_contacts(mariadb)
  } catch {
    e => println("✗ Error: \{e}")
  }
}

///|
fn count_contacts(mariadb : MySql) -> Unit raise {
  let query = "SELECT id, first_name, last_name, email, phone FROM contacts"
  let result = mariadb.execute(query).unwrap()
  let contacts : Array[Json] = []
  for row in result.iter() {
    contacts.push({
      "id": (row[0] : String),
      "first_name": (row[1] : String),
      "last_name": (row[2] : String),
      "email": (row[3] : String),
      "phone": (row[4] : String),
    })
  }
  guard contacts.length() == 200 else { fail("count_contacts() failed") }
  result.free_result()
  println("✓ Successfully retrieved 200 contacts from Contacts DB!")
}
