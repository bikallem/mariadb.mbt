-- User Management Script for Contacts Database
-- This script creates a dedicated user for the contacts_db database
-- Run this script as a MySQL/MariaDB administrator (e.g., root)

-- Drop user if exists (MariaDB 10.1.3+)
DROP USER IF EXISTS 'contacts_user'@'localhost';

-- Create the user with a password
-- IMPORTANT: Change 'contacts_password' to a secure password in production
CREATE USER 'contacts_user'@'localhost' IDENTIFIED BY 'contacts_password';

-- Grant all privileges on the contacts_db database to the user
GRANT ALL PRIVILEGES ON contacts_db.* TO 'contacts_user'@'localhost';

-- If you want to allow the user to grant privileges to others, uncomment the line below
-- GRANT ALL PRIVILEGES ON contacts_db.* TO 'contacts_user'@'localhost' WITH GRANT OPTION;

-- If you need the user to access from any host (not just localhost), create an additional user:
-- DROP USER IF EXISTS 'contacts_user'@'%';
-- CREATE USER 'contacts_user'@'%' IDENTIFIED BY 'contacts_password';
-- GRANT ALL PRIVILEGES ON contacts_db.* TO 'contacts_user'@'%';

-- Flush privileges to ensure changes take effect
FLUSH PRIVILEGES;

-- Display the created user
SELECT User, Host FROM mysql.user WHERE User = 'contacts_user';

-- Show granted privileges
SHOW GRANTS FOR 'contacts_user'@'localhost';

-- Usage information
SELECT 'User created successfully!' AS Status;
SELECT 'Username: contacts_user' AS Info
UNION ALL SELECT 'Password: contacts_password (CHANGE THIS IN PRODUCTION!)'
UNION ALL SELECT 'Database: contacts_db'
UNION ALL SELECT ''
UNION ALL SELECT 'To connect:'
UNION ALL SELECT '  mysql -u contacts_user -p contacts_db'
UNION ALL SELECT ''
UNION ALL SELECT 'Connection string format:'
UNION ALL SELECT '  mysql://contacts_user:contacts_password@localhost/contacts_db';
