#include "mysql.h"

#include <mysql/mysql.h>
#include <stdio.h>
#include <string.h>

#include "moonbit.h"

static inline void
moonbit_mariadb_mysql_t_finalize(void* obj)
{
    moonbit_mariadb_mysql_t* mysql_t = (moonbit_mariadb_mysql_t*)obj;
    mysql_close(mysql_t->mysql);
    mysql_t->mysql = NULL;
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
        &moonbit_mariadb_mysql_t_finalize, sizeof(moonbit_mariadb_mysql_t));
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
    return mysql_real_connect(mysql_t->mysql,
                              host,
                              user,
                              password,
                              database,
                              port,
                              NULL,
                              client_flag) != NULL;
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
    return mysql_real_connect(mysql_t->mysql,
                              NULL,
                              user,
                              password,
                              database,
                              0,
                              unix_socket,
                              client_flag) != NULL;
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
