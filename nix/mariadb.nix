{ pkgs, ... }:

[
  (pkgs.writeShellScriptBin "start-mariadb" ''
    set -e
    if [ ! -d "$MARIADB_DATA" ]; then
      echo "Initializing MariaDB data directory..."      
      mariadb-install-db --no-defaults \
              --auth-root-authentication-method=normal \
              --datadir=$MARIADB_DATA \
              --basedir=${pkgs.mariadb} \
              --pid-file=$MARIADB_PID
    fi
    echo "Starting MariaDB..."
    mariadbd-safe --datadir=$MARIADB_DATA --pid-file=$MARIADB_PID --socket=$MARIADB_SOCKET &
    echo "MariaDB started."
  '')
  (pkgs.writeShellScriptBin "stop-mariadb" ''
    echo "Stopping MariaDB..."
    mariadb-admin -u root --socket=$MARIADB_SOCKET shutdown    
    echo "MariaDB stopped."
  '')
  (pkgs.writeShellScriptBin "mariadb-client" ''
    mariadb --socket=$MARIADB_SOCKET "$@"
  '')
  (pkgs.writeShellScriptBin "show-mariadb-vars" ''
    echo PROJECT_ROOT=$PROJECT_ROOT
    echo MARIADB_HOME=$MARIADB_HOME
    echo MARIADB_DATA=$MARIADB_DATA
    echo MARIADB_SOCKET=$MARIADB_SOCKET
    echo MARIADB_PID=$MARIADB_PID
  '')
]
