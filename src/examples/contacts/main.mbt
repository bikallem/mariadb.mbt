///|
fn main {
  try {
    let mariadb = @mariadb.real_connect(
      host="127.0.0.1",
      port=3307U,
      user="contacts_user",
      password="contacts_password",
      database="contacts_db",
    )
    println("✓ Connected to MariaDB successfully!")
    count_contacts(mariadb)
    println("✓ Successfully counted 200 contacts from Contacts DB!")
    contacts_by_industry(mariadb, industry="Technology")
    println(
      "✓ Successfully retrieved all contacts in the Technology industry!",
    )
    contacts_by_industry(mariadb)
    println("✓ Successfully retrieved all contacts in all industries!")
    contacts_by_industry_stmt(mariadb, ["Technology", "Manufacturing"])
    println(
      "✓ Successfully retrieved all contacts in the Technology industry!",
    )
  } catch {
    e => println("✗ Error: \{e}")
  }
}

///|
fn count_contacts(mariadb : MySql) -> Unit raise {
  let query = "SELECT count(id) FROM contacts"
  let result = mariadb.execute(query)
  let contacts_count = (result.iter().nth(0).unwrap()[0] : Int)
  guard contacts_count == 200 else { fail("count_contacts() failed") }
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
    let id = (row[0] : Int)
    let first_name = (row[1] : String)
    let last_name = (row[2] : String)
    println("- \{id}: \{first_name} \{last_name}")
  }
}

///|
fn contacts_by_industry_stmt(
  mariadb : MySql,
  industries : Array[String],
) -> Unit raise {
  let query =
    #|SELECT c.id, c.first_name, c.last_name FROM contacts c
    #|INNER JOIN contact_companies cc ON cc.contact_id = c.id
    #|INNER JOIN companies com ON com.id = cc.company_id
    #|WHERE com.industry LIKE ?
  let industry_param = {
    let max_len = industries.fold(init=0, (max, s) => max.max(s.length())) + 2 // 2 for '%' chars at the front and the back
    MySqlStmtParam::String(max_len.reinterpret_as_uint())
  }
  let stmt = @stmt.stmt_prepare(mariadb, query, param_types=[industry_param])
  for industry in industries {
    println("Contacts in industry matching '\{industry}':")
    let industry = "%\{industry}%"
    stmt.execute(param_values={ 0: industry }, result_field_types=[
      MySqlStmtParam::Int,
      MySqlStmtParam::String(50),
      MySqlStmtParam::String(50),
    ])
    loop stmt.fetch() {
      MySqlStmtFetchResult::NoData => break
      MySqlStmtFetchResult::Error(e) => fail("Failed to fetch contact: \{e}")
      MySqlStmtFetchResult::Data(row) | MySqlStmtFetchResult::Truncated(row) => {
        println(
          "- \{(row[0] : Int)}: \{(row[1] : String)} \{(row[2] : String)}",
        )
        continue stmt.fetch()
      }
    }
  }
}
