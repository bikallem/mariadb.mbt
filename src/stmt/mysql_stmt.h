#ifndef MOONBIT_MARIADB_STMT_H
#define MOONBIT_MARIADB_STMT_H

#include "../mysql.h"

typedef struct
{
    moonbit_mariadb_mysql_t* mysql_t;
    MYSQL_STMT* mysql_stmt;
    MYSQL_BIND* mysql_bind_params;     // Parameter binds
    uint32_t mysql_bind_params_count;  // Number of parameter binds
    MYSQL_BIND* mysql_bind_results;    // Result field binds
    uint32_t mysql_bind_results_count; // Number of result field binds
} moonbit_mariadb_mysql_stmt_t;

#endif // MOONBIT_MARIADB_STMT_H