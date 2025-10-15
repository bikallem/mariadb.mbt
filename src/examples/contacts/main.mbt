///|
const MARIADB_SOCKET = "MARIADB_SOCKET"

///|
fn main {
  try {
    let env = @sys.get_env_vars()
    let _mariadb = @mariadb.connect_via_unix_socket(
      unix_socket=env[MARIADB_SOCKET],
      user="contacts_user",
      password="contacts_password",
      database="contacts_db",
    )
    println("✓ Connected to MariaDB successfully!")
    // count_contacts(mariadb)
    // contacts_by_industry(mariadb, industry="Technology")
    // println(
    //   "✓ Successfully retrieved all contacts in the Technology industry!",
    // )
    // contacts_by_industry(mariadb)
    // println("✓ Successfully retrieved all contacts in all industries!")
  } catch {
    e => println("✗ Error: \{e}")
  }
}

///|
fn count_contacts(mariadb : MySql) -> Unit raise {
  let query = "SELECT id, first_name, last_name, email, phone FROM contacts"
  let result = mariadb.execute(query)
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

///|
fn contacts_by_industry(mariadb : MySql, industry? : String) -> Unit raise {
  let query =
    #|SELECT c.id, c.first_name, c.last_name FROM contacts c
    #|INNER JOIN contact_companies cc ON cc.contact_id = c.id
    #|INNER JOIN companies com ON com.id = cc.company_id
  let query = match industry {
    None => query
    Some(industry) =>
      "\{query} WHERE com.industry LIKE '%\{mariadb.real_escape_string(industry)}%'"
  }
  let result = mariadb.execute(query)
  for row in result.iter() {
    let id = row[0]
    let first_name = row[1]
    let last_name = row[2]
    println("- \{id}: \{first_name} \{last_name}")
  }
  result.free_result()
}
