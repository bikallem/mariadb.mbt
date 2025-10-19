#include <mysql/mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../mysql.h"
#include "moonbit.h"

static inline void
moonbit_mariadb_mysql_stmt_t_finalize(void* obj)
{
    moonbit_mariadb_mysql_stmt_t* mysql_stmt_t =
      (moonbit_mariadb_mysql_stmt_t*)obj;
    mysql_stmt_free_result(mysql_stmt_t->mysql_stmt);
    mysql_stmt_close(mysql_stmt_t->mysql_stmt);

    // Free parameter binds if they exist
    for (int i = 0; i < mysql_stmt_t->mysql_bind_params_count; i++) {
        free(mysql_stmt_t->mysql_bind_params[i].buffer);
        free(mysql_stmt_t->mysql_bind_params[i].length);
        free(mysql_stmt_t->mysql_bind_params[i].is_null);
        free(mysql_stmt_t->mysql_bind_params[i].error);
    }
    free(mysql_stmt_t->mysql_bind_params);

    // Free result binds if they exist
    for (int i = 0; i < mysql_stmt_t->mysql_bind_results_count; i++) {
        free(mysql_stmt_t->mysql_bind_results[i].buffer);
        free(mysql_stmt_t->mysql_bind_results[i].length);
        free(mysql_stmt_t->mysql_bind_results[i].is_null);
        free(mysql_stmt_t->mysql_bind_results[i].error);
    }
    free(mysql_stmt_t->mysql_bind_results);
    moonbit_decref(mysql_stmt_t->mysql_t);
    mysql_stmt_t->mysql_t = NULL;
    mysql_stmt_t->mysql_stmt = NULL;
    mysql_stmt_t->mysql_bind_results = NULL;
    mysql_stmt_t->mysql_bind_results_count = 0;
    mysql_stmt_t->mysql_bind_params = NULL;
    mysql_stmt_t->mysql_bind_params_count = 0;
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
        &moonbit_mariadb_mysql_stmt_t_finalize,
        sizeof(moonbit_mariadb_mysql_stmt_t));
    if (mysql_stmt_t == NULL) {
        mysql_stmt_close(stmt);
        moonbit_decref(mysql_stmt_t);
        return NULL;
    }
    mysql_stmt_t->mysql_t = mysql_t;
    mysql_stmt_t->mysql_stmt = stmt;
    mysql_stmt_t->mysql_bind_params = NULL;
    mysql_stmt_t->mysql_bind_params_count = 0;
    mysql_stmt_t->mysql_bind_results = NULL;
    mysql_stmt_t->mysql_bind_results_count = 0;
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

static MYSQL_BIND*
create_mysql_binds(int32_t count,
                   int32_t* bind_sizes,
                   int32_t* bind_types,
                   int32_t* bind_unsigned)
{
    MYSQL_BIND* mysql_bind_params = calloc(count, sizeof(MYSQL_BIND));
    if (mysql_bind_params == NULL) {
        return NULL;
    }
    for (unsigned int i = 0; i < count; i++) {
        mysql_bind_params[i].buffer_type = (enum enum_field_types)bind_types[i];
        mysql_bind_params[i].buffer = malloc(bind_sizes[i]);
        mysql_bind_params[i].buffer_length = bind_sizes[i];
        mysql_bind_params[i].is_unsigned = bind_unsigned[i];
        mysql_bind_params[i].length = malloc(sizeof(unsigned long));
        mysql_bind_params[i].is_null = malloc(sizeof(my_bool));
        mysql_bind_params[i].error = malloc(sizeof(my_bool));
        *mysql_bind_params[i].is_null = 1; // Set to null by default
    }
    return mysql_bind_params;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_stmt_bind_params(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t,
                                 int32_t params_count,
                                 int32_t* bind_sizes,
                                 int32_t* bind_types,
                                 int32_t* bind_unsigned)
{
    printf("Binding %d params\n", params_count);
    MYSQL_BIND* mysql_bind_params =
      create_mysql_binds(params_count, bind_sizes, bind_types, bind_unsigned);
    if (mysql_bind_params == NULL) {
        return -1; // False
    }
    mysql_stmt_t->mysql_bind_params = mysql_bind_params;
    mysql_stmt_t->mysql_bind_params_count = params_count;
    return mysql_stmt_bind_param(mysql_stmt_t->mysql_stmt, mysql_bind_params);
}

MOONBIT_FFI_EXPORT
void
moonbit_mariadb_stmt_set_param_value(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t,
                                     int32_t index,
                                     moonbit_bytes_t value,
                                     uint32_t length)
{
    memcpy(mysql_stmt_t->mysql_bind_params[index].buffer, value, length);
    *mysql_stmt_t->mysql_bind_params[index].is_null = 0; // Set to not null
    *mysql_stmt_t->mysql_bind_params[index].length = length;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_mysql_stmt_execute(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    return (int32_t)mysql_stmt_execute(mysql_stmt_t->mysql_stmt);
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_mariadb_mysql_stmt_field_count(
  moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    return (uint32_t)mysql_stmt_field_count(mysql_stmt_t->mysql_stmt);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_stmt_bind_results(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t,
                                  int32_t result_field_count,
                                  int32_t* bind_sizes,
                                  int32_t* bind_types,
                                  int32_t* bind_unsigned)
{
    MYSQL_BIND* mysql_bind_results = create_mysql_binds(
      result_field_count, bind_sizes, bind_types, bind_unsigned);
    if (mysql_bind_results == NULL) {
        return -1; // False
    }
    mysql_stmt_t->mysql_bind_results = mysql_bind_results;
    mysql_stmt_t->mysql_bind_results_count = result_field_count;
    return (int32_t)mysql_stmt_bind_result(mysql_stmt_t->mysql_stmt,
                                           mysql_bind_results);
}

MOONBIT_FFI_EXPORT
int32_t // Bool
moonbit_mariadb_mysql_stmt_fetch(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    return (int32_t)mysql_stmt_fetch(mysql_stmt_t->mysql_stmt);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_stmt_mysql_no_data(void)
{
    return MYSQL_NO_DATA;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_stmt_mysql_data_truncated(void)
{
    return MYSQL_DATA_TRUNCATED;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t*
moonbit_mariadb_stmt_result_column_values(
  moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    moonbit_bytes_t* values = (moonbit_bytes_t*)moonbit_make_ref_array(
      mysql_stmt_t->mysql_bind_results_count, NULL);
    for (int i = 0; i < mysql_stmt_t->mysql_bind_results_count; i++) {
        if (*mysql_stmt_t->mysql_bind_results[i].is_null) {
            values[i] = moonbit_make_bytes(0, 0);
            continue;
        }
        unsigned long length = *mysql_stmt_t->mysql_bind_results[i].length;
        moonbit_bytes_t mb_bytes = moonbit_make_bytes(length, 0);
        mysql_stmt_t->mysql_bind_results[i].buffer = mb_bytes;
        mysql_stmt_t->mysql_bind_results[i].buffer_length = length;
        mysql_stmt_fetch_column(
          mysql_stmt_t->mysql_stmt, &mysql_stmt_t->mysql_bind_results[i], i, 0);
        mysql_stmt_t->mysql_bind_results[i].buffer = NULL;
        mysql_stmt_t->mysql_bind_results[i].buffer_length = 0;
        values[i] = mb_bytes;
    }
    return values;
}
