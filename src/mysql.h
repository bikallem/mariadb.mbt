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
  MYSQL_ROW* row;
} moonbit_mariadb_mysql_row_t;

#endif // MOONBIT_MARIADB_H