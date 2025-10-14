#include "moonbit.h"
#include <mysql/mysql.h>
#include <string.h>

static inline moonbit_bytes_t
moonbit_bytes(const void* data)
{
  size_t len = strlen((const char*)data);
  moonbit_bytes_t mb_bytes = moonbit_make_bytes(len, 0);
  memcpy(mb_bytes, data, len);
  return mb_bytes;
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
    values[i] = moonbit_bytes(row[i]);
  }
  return values;
}
