#include <mysql/mysql.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "moonbit.h"

#define LONG 0
#define ULONG 1
#define LONGLONG 2
#define ULONGLONG 3
#define FLOAT 4
#define DOUBLE 5
#define STRING 6
#define BLOB 7
#define BOOL 8

static enum enum_field_types
buffer_type(uint32_t type)
{
  switch (type) {
    case LONG:
    case ULONG:
    case BOOL:
      return MYSQL_TYPE_LONG;
    case LONGLONG:
    case ULONGLONG:
      return MYSQL_TYPE_LONGLONG;
    case FLOAT:
      return MYSQL_TYPE_FLOAT;
    case DOUBLE:
      return MYSQL_TYPE_DOUBLE;
    case BLOB:
      return MYSQL_TYPE_BLOB;
    default:
      return MYSQL_TYPE_STRING;
  }
}

MOONBIT_FFI_EXPORT
MYSQL_BIND*
moonbit_stmt_make_binds(uint32_t binds_count,
                        int32_t* bind_sizes,
                        int32_t* bind_types,
                        int32_t* bind_unsigned)
{
  MYSQL_BIND* binds = calloc(binds_count, sizeof(MYSQL_BIND));
  if (!binds) {
    return NULL;
  }
  for (unsigned int i = 0; i < binds_count; i++) {
    binds[i].buffer_type = buffer_type(bind_types[i]);
    binds[i].buffer = malloc(bind_sizes[i]);
    binds[i].buffer_length = bind_sizes[i];
    binds[i].is_unsigned = bind_unsigned[i];
    binds[i].length = malloc(sizeof(unsigned long));
    binds[i].is_null = malloc(sizeof(my_bool));
    binds[i].error = malloc(sizeof(my_bool));
    *binds[i].is_null = 1; // Set to null by default
  }
  return binds;
}

MOONBIT_FFI_EXPORT
void
moonbit_free_binds(MYSQL_BIND* binds, uint32_t count)
{
  for (size_t i = 0; i < count; i++) {
    free(binds[i].buffer);
    free(binds[i].length);
    free(binds[i].is_null);
    free(binds[i].error);
  }
  free(binds);
}

MOONBIT_FFI_EXPORT
void
moonbit_set_param_value(MYSQL_BIND* binds,
                        int32_t index,
                        const void* value,
                        uint32_t length)
{
  memcpy(binds[index].buffer, value, length);
  *binds[index].is_null = 0; // Set to not null
  *binds[index].length = length;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t*
moonbit_stmt_result_column_values(MYSQL_STMT* stmt,
                                  MYSQL_BIND* binds,
                                  u_int32_t count)
{
  moonbit_bytes_t* values =
    (moonbit_bytes_t*)moonbit_make_ref_array(count, NULL);
  for (int i = 0; i < count; i++) {
    if (*binds[i].is_null) {
      values[i] = moonbit_make_bytes(0, 0);
      continue;
    }
    unsigned long length = *binds[i].length;
    moonbit_bytes_t mb_bytes = moonbit_make_bytes(length, 0);
    binds[i].buffer = mb_bytes;
    binds[i].buffer_length = length;
    mysql_stmt_fetch_column(stmt, &binds[i], i, 0);
    binds[i].buffer = NULL;
    binds[i].buffer_length = 0;
    values[i] = mb_bytes;
  }
  return values;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_MYSQL_NO_DATA(void)
{
  return MYSQL_NO_DATA;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_MYSQL_DATA_TRUNCATED(void)
{
  return MYSQL_DATA_TRUNCATED;
}