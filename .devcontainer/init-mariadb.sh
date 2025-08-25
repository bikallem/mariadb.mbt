#!/bin/bash

# MariaDB initialization script for dev container

# Get the container user from environment or default to 'dev1'
CONTAINER_USER="${CONTAINER_USER:-dev1}"
DEV_PASSWORD="${DEV_PASSWORD:-devpass}"

echo "🗄️ Initializing MariaDB for user: $CONTAINER_USER..."

# Start MariaDB service
sudo service mariadb start

# Wait for MariaDB to be ready
sleep 2

# Check if root password is already set
if sudo mysql -u root -e "SELECT 1" &>/dev/null; then
    echo "Setting up MariaDB for development..."
    
    # Set root password and create dev user
    sudo mysql -u root <<EOF
-- Set root password (for development only!)
ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpass';

-- Create development user
CREATE USER IF NOT EXISTS '$CONTAINER_USER'@'localhost' IDENTIFIED BY '$DEV_PASSWORD';
CREATE USER IF NOT EXISTS '$CONTAINER_USER'@'%' IDENTIFIED BY '$DEV_PASSWORD';

-- Grant all privileges to dev user
GRANT ALL PRIVILEGES ON *.* TO '$CONTAINER_USER'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$CONTAINER_USER'@'%' WITH GRANT OPTION;

-- Create a default development database
CREATE DATABASE IF NOT EXISTS moonbit_dev;
CREATE DATABASE IF NOT EXISTS moonbit_test;

-- Flush privileges
FLUSH PRIVILEGES;
EOF
    
    echo "✅ MariaDB configured successfully!"
    echo "   Root password: rootpass"
    echo "   Dev user: $CONTAINER_USER / $DEV_PASSWORD"
    echo "   Databases: moonbit_dev, moonbit_test"
else
    echo "MariaDB already configured, starting service..."
fi

# Create convenience file with connection info
cat > ~/.config/devcontainer/mariadb-info.txt <<EOF
MariaDB Connection Information
==============================
Host: localhost
Port: 3306

Root User:
  Username: root
  Password: rootpass

Development User:
  Username: $CONTAINER_USER
  Password: $DEV_PASSWORD

Databases:
  - moonbit_dev (for development)
  - moonbit_test (for testing)

Connection Examples:
  mysql -u $CONTAINER_USER -p$DEV_PASSWORD moonbit_dev
  mysql -u root -prootpass

Connection URL:
  mysql://$CONTAINER_USER:$DEV_PASSWORD@localhost:3306/moonbit_dev
EOF

echo ""
echo "📝 Connection info saved to ~/.config/devcontainer/mariadb-info.txt"