# Fish configuration for MoonBit development with MariaDB

# Set greeting
set -g fish_greeting "🌙 Welcome to MoonBit Development Environment with MariaDB!"

# Database environment variables
set -gx DATABASE_URL "mysql://dev1:devpass@localhost:3306/moonbit_dev"
set -gx TEST_DATABASE_URL "mysql://dev1:devpass@localhost:3306/moonbit_test"

# Aliases
alias ll "ls -alF"
alias la "ls -A"
alias l "ls -CF"
alias .. "cd .."
alias ... "cd ../.."

# Better command line tools (if available via Nix)
if type -q eza
    alias ls "eza --icons"
    alias ll "eza -la --icons"
    alias la "eza -a --icons"
    alias l "eza -l --icons"
    alias tree "eza --tree --icons"
end

if type -q bat
    alias cat "bat"
end

if type -q fd
    alias find "fd"
end

if type -q rg
    alias grep "rg"
end

# MoonBit aliases
alias mb "moon build"
alias mr "moon run"
alias mt "moon test"
alias mf "moon fmt"
alias mc "moon check"
alias mclean "moon clean"
alias mnew "moon new"
alias minfo "moon info"
alias mdoc "moon doc"
alias mpub "moon publish"
alias mup "moon update"
alias mver "moon version"

# Database aliases
alias mysql-dev "mysql -u dev1 -pdevpass moonbit_dev"
alias mysql-test "mysql -u dev1 -pdevpass moonbit_test"
alias mysql-root "mysql -u root -prootpass"

# Git aliases
alias g "git"
alias ga "git add"
alias gc "git commit"
alias gco "git checkout"
alias gd "git diff"
alias gl "git log --oneline --graph"
alias gp "git push"
alias gpl "git pull"
alias gs "git status"

# Nix aliases
alias nd "nix develop"
alias nb "nix build"
alias nfu "nix flake update"
alias nfl "nix flake lock"

# Development aliases
alias da "direnv allow"
alias dr "direnv reload"
alias ds "direnv status"

# Database functions
function db-start --description "Start MariaDB service"
    sudo service mariadb start
    echo "✅ MariaDB started"
end

function db-stop --description "Stop MariaDB service"
    sudo service mariadb stop
    echo "⏹️ MariaDB stopped"
end

function db-restart --description "Restart MariaDB service"
    sudo service mariadb restart
    echo "🔄 MariaDB restarted"
end

function db-status --description "Check MariaDB service status"
    sudo service mariadb status
end

function db-connect --description "Connect to MariaDB database"
    set -l db (test (count $argv) -eq 0; and echo "moonbit_dev"; or echo $argv[1])
    if type -q mycli
        mycli -u dev1 -pdevpass $db
    else
        mysql -u dev1 -pdevpass $db
    end
end

function db-info --description "Show MariaDB connection information"
    echo "MariaDB Connection Information"
    echo "=============================="
    echo "Host: localhost"
    echo "Port: 3306"
    echo ""
    echo "Root User:"
    echo "  Username: root"
    echo "  Password: rootpass"
    echo ""
    echo "Development User:"
    echo "  Username: dev1"
    echo "  Password: devpass"
    echo ""
    echo "Databases:"
    echo "  - moonbit_dev (for development)"
    echo "  - moonbit_test (for testing)"
    echo ""
    echo "Connection Examples:"
    echo "  mysql -u dev1 -pdevpass moonbit_dev"
    echo "  mysql -u root -prootpass"
    echo ""
    echo "Connection URL:"
    echo "  mysql://dev1:devpass@localhost:3306/moonbit_dev"
end

function db-backup --description "Backup a database"
    if test (count $argv) -eq 0
        echo "Usage: db-backup <database_name> [output_file]"
        return 1
    end
    
    set -l db_name $argv[1]
    set -l output_file (test -n "$argv[2]"; and echo $argv[2]; or echo "$db_name"_(date +%Y%m%d_%H%M%S).sql)
    
    mysqldump -u dev1 -pdevpass $db_name > $output_file
    echo "✅ Database '$db_name' backed up to '$output_file'"
end

function db-restore --description "Restore a database from backup"
    if test (count $argv) -lt 2
        echo "Usage: db-restore <database_name> <backup_file>"
        return 1
    end
    
    set -l db_name $argv[1]
    set -l backup_file $argv[2]
    
    if not test -f $backup_file
        echo "❌ Backup file '$backup_file' not found"
        return 1
    end
    
    mysql -u dev1 -pdevpass $db_name < $backup_file
    echo "✅ Database '$db_name' restored from '$backup_file'"
end

function db-create --description "Create a new database"
    if test (count $argv) -eq 0
        echo "Usage: db-create <database_name>"
        return 1
    end
    
    mysql -u dev1 -pdevpass -e "CREATE DATABASE IF NOT EXISTS $argv[1];"
    echo "✅ Database '$argv[1]' created"
end

function db-drop --description "Drop a database"
    if test (count $argv) -eq 0
        echo "Usage: db-drop <database_name>"
        return 1
    end
    
    echo "⚠️  Are you sure you want to drop database '$argv[1]'? (yes/no)"
    read -l confirm
    if test "$confirm" = "yes"
        mysql -u dev1 -pdevpass -e "DROP DATABASE IF EXISTS $argv[1];"
        echo "✅ Database '$argv[1]' dropped"
    else
        echo "❌ Operation cancelled"
    end
end

function db-list --description "List all databases"
    mysql -u dev1 -pdevpass -e "SHOW DATABASES;"
end

function db-tables --description "List tables in a database"
    set -l db (test (count $argv) -eq 0; and echo "moonbit_dev"; or echo $argv[1])
    mysql -u dev1 -pdevpass -e "USE $db; SHOW TABLES;"
end

# MoonBit functions
function moon-init --description "Initialise a new MoonBit project"
    if test (count $argv) -eq 0
        echo "Usage: moon-init <project-name>"
        return 1
    end
    moon new $argv[1]
    cd $argv[1]
    echo "MoonBit project '$argv[1]' created and entered!"
end

function moon-serve --description "Start MoonBit development server"
    moon build --watch &
    if type -q python3
        python3 -m http.server 8080 --directory target/wasm-gc/release/build
    else
        echo "Python3 not found. Install it to serve the built files."
    end
end

function moon-update-toolchain --description "Update MoonBit toolchain"
    curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
    moon version
end

# Utility functions
function mkcd --description "Create a directory and cd into it"
    mkdir -p $argv[1] && cd $argv[1]
end

function show-locale --description "Show current locale settings"
    echo "Current locale settings:"
    echo "  LANG: $LANG"
    echo "  LANGUAGE: $LANGUAGE"
    echo "  LC_ALL: $LC_ALL"
    echo ""
    echo "System locale:"
    locale
end

function show-date --description "Show current date and time in British format"
    date '+%d/%m/%Y %H:%M:%S %Z'
end

function nix-search --description "Search for Nix packages"
    nix search nixpkgs $argv
end

function nix-shell-here --description "Enter nix shell with current flake"
    nix develop
end

# Welcome message with system info
echo "🌍 Locale: $LANG | 📅 Date: "(date '+%d/%m/%Y %H:%M')

# Show MoonBit version on startup
if type -q moon
    echo "🌙 MoonBit: "(moon version 2>&1 | head -n1)
end

# Show MariaDB status on startup
if sudo service mariadb status >/dev/null 2>&1
    echo "🗄️  MariaDB: Running"
else
    echo "🗄️  MariaDB: Stopped (run 'db-start' to start)"
end

# Show direnv status
if type -q direnv
    echo "📁 direnv: Available ("(direnv version)")"
end