#include "moonbit.h"
#include <mysql/mysql.h>
#include <string.h>

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

MOONBIT_FFI_EXPORT
MYSQL*
moonbit_mariadb_connect_via_tcp_socket(MYSQL* mysql,
                                       const char* host,
                                       uint32_t port,
                                       const char* user,
                                       const char* password,
                                       const char* database,
                                       uint32_t client_flag)
{
  return mysql_real_connect(
    mysql, host, user, password, database, port, NULL, client_flag);
}

MOONBIT_FFI_EXPORT
MYSQL*
moonbit_mariadb_connect_via_unix_socket(MYSQL* mysql,
                                        const char* unix_socket,
                                        const char* user,
                                        const char* password,
                                        const char* database,
                                        uint32_t client_flag)
{
  return mysql_real_connect(
    mysql, NULL, user, password, database, 0, unix_socket, client_flag);
}