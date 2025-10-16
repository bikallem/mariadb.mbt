#ifndef MOONBIT_MARIADB_H
#define MOONBIT_MARIADB_H

#include "moonbit.h"
#include <mysql/mysql.h>

typedef struct
{
    MYSQL* mysql;
} moonbit_mariadb_mysql_t;

typedef struct
{
    MYSQL_RES* res;
} moonbit_mariadb_mysql_res_t;

typedef struct
{
    MYSQL_STMT* mysql_stmt;
    MYSQL_BIND* mysql_binds;
    uint32_t mysql_binds_count;
} moonbit_mariadb_mysql_stmt_t;

#endif // MOONBIT_MARIADB_H