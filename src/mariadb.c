#include "moonbit.h"
#include <mysql/mysql.h>
#include <stdio.h>
#include <string.h>

typedef struct
{
  MYSQL* mysql;
} moonbit_mariadb_mysql_t;

static inline void
moonbit_mariadb_mysql_t_finalize(void* obj)
{
  moonbit_mariadb_mysql_t* mysql_ptr = (moonbit_mariadb_mysql_t*)obj;
  mysql_close(mysql_ptr->mysql);
}

MOONBIT_FFI_EXPORT
moonbit_mariadb_mysql_t*
moonbit_mariadb_init(void)
{
  MYSQL* mysql = mysql_init(NULL);
  if (mysql == NULL) {
    return NULL;
  }
  moonbit_mariadb_mysql_t* mysql_t =
    (moonbit_mariadb_mysql_t*)moonbit_make_external_object(
      moonbit_mariadb_mysql_t_finalize, sizeof(moonbit_mariadb_mysql_t));
  if (mysql_t == NULL) {
    mysql_close(mysql);
    moonbit_decref(mysql_t);
    return NULL;
  }
  mysql_t->mysql = mysql;

  return mysql_t;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_connect_via_tcp_socket(moonbit_mariadb_mysql_t* mysql_t,
                                       const char* host,
                                       uint32_t port,
                                       const char* user,
                                       const char* password,
                                       const char* database,
                                       uint32_t client_flag)
{

  if (!mysql_real_connect(mysql_t->mysql,
                          host,
                          user,
                          password,
                          database,
                          port,
                          NULL,
                          client_flag)) {
    return 0; // false
  }
  return 1; // true
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_connect_via_unix_socket(moonbit_mariadb_mysql_t* mysql_t,
                                        const char* unix_socket,
                                        const char* user,
                                        const char* password,
                                        const char* database,
                                        uint32_t client_flag)
{
  if (!mysql_real_connect(mysql_t->mysql,
                          NULL,
                          user,
                          password,
                          database,
                          0,
                          unix_socket,
                          client_flag)) {
    return 0; // false
  }
  return 1; // true
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_mysql_set_character_set(moonbit_mariadb_mysql_t* mysql_t,
                                        const char* cs)
{
  return mysql_set_character_set(mysql_t->mysql, cs);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_mysql_real_escape_string(moonbit_mariadb_mysql_t* mysql_t,
                                         char* to,
                                         const char* from,
                                         uint32_t length)
{
  return mysql_real_escape_string(mysql_t->mysql, to, from, length);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_mysql_real_query(moonbit_mariadb_mysql_t* mysql_t,
                                 const char* query,
                                 uint32_t length)
{
  return mysql_real_query(mysql_t->mysql, query, length);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_affected_rows(moonbit_mariadb_mysql_t* mysql_t)
{
  return (uint32_t)mysql_affected_rows(mysql_t->mysql);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_errno(moonbit_mariadb_mysql_t* mysql_t)
{
  return (uint32_t)mysql_errno(mysql_t->mysql);
}

MOONBIT_FFI_EXPORT
const char*
moonbit_mariadb_mysql_error(moonbit_mariadb_mysql_t* mysql_t)
{
  return mysql_error(mysql_t->mysql);
}

MOONBIT_FFI_EXPORT
MYSQL_RES*
moonbit_mariadb_store_result(moonbit_mariadb_mysql_t* mysql_t)
{
  return mysql_store_result(mysql_t->mysql);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_num_fields(MYSQL_RES* res)
{
  return (uint32_t)mysql_num_fields(res);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t*
moonbit_row_column_values(MYSQL_ROW row, uint32_t count)
{
  moonbit_bytes_t* values =
    (moonbit_bytes_t*)moonbit_make_ref_array(count, NULL);
  for (int i = 0; i < count; i++) {
    if (row[i] == NULL) {
      values[i] = moonbit_make_bytes(0, 0);
      continue;
    }
    size_t len = strlen((const char*)row[i]);
    moonbit_bytes_t mb_bytes = moonbit_make_bytes(len, 0);
    memcpy(mb_bytes, row[i], len);
    values[i] = mb_bytes;
  }
  return values;
}
