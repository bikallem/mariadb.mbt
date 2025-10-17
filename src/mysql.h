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
    MYSQL_BIND* mysql_bind_params;     // Parameter binds
    uint32_t mysql_bind_params_count;  // Number of parameter binds
    MYSQL_BIND* mysql_bind_results;    // Result field binds
    uint32_t mysql_bind_results_count; // Number of result field binds
} moonbit_mariadb_mysql_stmt_t;

#endif // MOONBIT_MARIADB_H