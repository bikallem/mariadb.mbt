#include <mysql/mysql.h>
#include <stdlib.h>
#include <string.h>

#include "moonbit.h"
#include "mysql.h"

static inline void
moonbit_mariadb_mysql_stmt_t_finalize(void* obj)
{
    moonbit_mariadb_mysql_stmt_t* self = (moonbit_mariadb_mysql_stmt_t*)obj;
    mysql_stmt_close(self->mysql_stmt);
    for (int i = 0; i < self->mysql_binds_count; i++) {
        moonbit_decref(self->mysql_binds[i].buffer);
        free(self->mysql_binds[i].length);
        free(self->mysql_binds[i].is_null);
        free(self->mysql_binds[i].error);
    }
    free(self->mysql_binds);
}

MOONBIT_FFI_EXPORT
moonbit_mariadb_mysql_stmt_t*
moonbit_mariadb_mysql_stmt_init(moonbit_mariadb_mysql_t* mysql_t)
{
    MYSQL_STMT* stmt = mysql_stmt_init(mysql_t->mysql);
    if (stmt == NULL) {
        return NULL;
    }
    moonbit_mariadb_mysql_stmt_t* mysql_stmt_t =
      (moonbit_mariadb_mysql_stmt_t*)moonbit_make_external_object(
        moonbit_mariadb_mysql_stmt_t_finalize,
        sizeof(moonbit_mariadb_mysql_stmt_t));
    if (mysql_stmt_t == NULL) {
        mysql_stmt_close(stmt);
        moonbit_decref(mysql_stmt_t);
        return NULL;
    }
    mysql_stmt_t->mysql_stmt = stmt;
    mysql_stmt_t->mysql_binds = NULL;
    mysql_stmt_t->mysql_binds_count = 0;
    return mysql_stmt_t;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_mysql_stmt_prepare(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t,
                                   const char* stmt_str,
                                   unsigned long length)
{
    return mysql_stmt_prepare(mysql_stmt_t->mysql_stmt, stmt_str, length);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_stmt_param_count(
  moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    return mysql_stmt_param_count(mysql_stmt_t->mysql_stmt);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_type_long(void)
{
    return MYSQL_TYPE_LONG;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_type_longlong(void)
{
    return MYSQL_TYPE_LONGLONG;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_type_float(void)
{
    return MYSQL_TYPE_FLOAT;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_type_double(void)
{
    return MYSQL_TYPE_DOUBLE;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_type_string(void)
{
    return MYSQL_TYPE_STRING;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_type_blob(void)
{
    return MYSQL_TYPE_BLOB;
}

MOONBIT_FFI_EXPORT
int32_t // Bool
moonbit_mariadb_stmt_bind_params(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t,
                                 int32_t columns_count,
                                 int32_t* bind_sizes,
                                 int32_t* bind_types,
                                 int32_t* bind_unsigned)
{
    MYSQL_BIND* mysql_binds = calloc(columns_count, sizeof(MYSQL_BIND));
    for (unsigned int i = 0; i < columns_count; i++) {
        mysql_binds[i].buffer_type = (enum enum_field_types)bind_types[i];
        mysql_binds[i].buffer = malloc(bind_sizes[i]);
        mysql_binds[i].buffer_length = bind_sizes[i];
        mysql_binds[i].is_unsigned = bind_unsigned[i];
        mysql_binds[i].length = malloc(sizeof(unsigned long));
        mysql_binds[i].is_null = malloc(sizeof(my_bool));
        mysql_binds[i].error = malloc(sizeof(my_bool));
        *mysql_binds[i].is_null = 1; // Set to null by default
    }
    mysql_stmt_t->mysql_binds = mysql_binds;
    mysql_stmt_t->mysql_binds_count = columns_count;
    return 1;
}

MOONBIT_FFI_EXPORT
void
moonbit_mariadb_stmt_set_param_value(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t,
                                     int32_t index,
                                     moonbit_bytes_t value,
                                     uint32_t length)
{
    mysql_stmt_t->mysql_binds[index].buffer = (void*)value;
    *mysql_stmt_t->mysql_binds[index].is_null = 0; // Set to not null
    *mysql_stmt_t->mysql_binds[index].length = length;
}

// MOONBIT_FFI_EXPORT
// moonbit_bytes_t*
// moonbit_stmt_result_column_values(MYSQL_STMT* stmt,
//                                   MYSQL_BIND* binds,
//                                   u_int32_t count)
// {
//     moonbit_bytes_t* values =
//       (moonbit_bytes_t*)moonbit_make_ref_array(count, NULL);
//     for (int i = 0; i < count; i++) {
//         if (*binds[i].is_null) {
//             values[i] = moonbit_make_bytes(0, 0);
//             continue;
//         }
//         unsigned long length = *binds[i].length;
//         moonbit_bytes_t mb_bytes = moonbit_make_bytes(length, 0);
//         binds[i].buffer = mb_bytes;
//         binds[i].buffer_length = length;
//         mysql_stmt_fetch_column(stmt, &binds[i], i, 0);
//         binds[i].buffer = NULL;
//         binds[i].buffer_length = 0;
//         values[i] = mb_bytes;
//     }
//     return values;
// }

// MOONBIT_FFI_EXPORT
// int32_t // Bool
// moonbit_mariadb_mysql_stmt_bind_param(
//   moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
// {
//     return (int32_t)mysql_stmt_bind_param(mysql_stmt_t->mysql_stmt,
//                                           mysql_stmt_t->mysql_binds);
// }

// MOONBIT_FFI_EXPORT
// int32_t
// moonbit_MYSQL_NO_DATA(void)
// {
//     return MYSQL_NO_DATA;
// }

// MOONBIT_FFI_EXPORT
// int32_t
// moonbit_MYSQL_DATA_TRUNCATED(void)
// {
//     return MYSQL_DATA_TRUNCATED;
// }
