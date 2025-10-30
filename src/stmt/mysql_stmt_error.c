#include "moonbit.h"
#include "mysql_stmt.h"
#include <mysql/mysql.h>
#include <stdlib.h>

MOONBIT_FFI_EXPORT
int32_t
moonbit_mariadb_mysql_stmt_errno(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    return (int32_t)mysql_stmt_errno(mysql_stmt_t->mysql_stmt);
}

MOONBIT_FFI_EXPORT
const char*
moonbit_mariadb_mysql_stmt_error(moonbit_mariadb_mysql_stmt_t* mysql_stmt_t)
{
    return mysql_stmt_error(mysql_stmt_t->mysql_stmt);
}