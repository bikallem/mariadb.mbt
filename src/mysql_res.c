#include "moonbit.h"
#include "mysql.h"
#include <mysql/mysql.h>
#include <string.h>

static inline void
moonbit_mariadb_mysql_res_t_finalize(void* obj)
{
  moonbit_mariadb_mysql_res_t* res_ptr = (moonbit_mariadb_mysql_res_t*)obj;
  mysql_free_result(res_ptr->res);
}

MOONBIT_FFI_EXPORT
moonbit_mariadb_mysql_res_t*
moonbit_mariadb_store_result(moonbit_mariadb_mysql_t* mysql_t)
{
  moonbit_mariadb_mysql_res_t* mysql_res_t =
    (moonbit_mariadb_mysql_res_t*)moonbit_make_external_object(
      moonbit_mariadb_mysql_res_t_finalize,
      sizeof(moonbit_mariadb_mysql_res_t));
  if (mysql_res_t == NULL) {
    return NULL;
  }
  mysql_res_t->res = mysql_store_result(mysql_t->mysql);
  if (mysql_res_t->res == NULL) {
    moonbit_decref(mysql_res_t);
    return NULL;
  }
  return mysql_res_t;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_num_fields(moonbit_mariadb_mysql_res_t* res_t)
{
  return (uint32_t)mysql_num_fields(res_t->res);
}

MOONBIT_FFI_EXPORT
MYSQL_ROW
moonbit_mariadb_mysql_fetch_row(moonbit_mariadb_mysql_res_t* res_t)
{
  return mysql_fetch_row(res_t->res);
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