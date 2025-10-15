#!/usr/bin/env bash
# Setup script for Contacts Database
# This script creates and populates the contacts database

set -e

echo "============================================"
echo "Contacts Database Setup"
echo "============================================"
echo ""

# Check if MariaDB/MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "Error: mysql command not found. Please install MariaDB or MySQL."
    exit 1
fi

# Get database credentials
DB_HOST=localhost
DB_USER=root

echo ""
echo "Step 1: Creating database schema..."
mariadb-client -h "$DB_HOST" -u "$DB_USER" < "sql/schema.sql"

if [ $? -eq 0 ]; then
    echo "✓ Schema created successfully"
else
    echo "✗ Failed to create schema"
    exit 1
fi

echo ""
echo "Step 2: Loading data from CSV files..."
# Change to sql directory so relative paths in load_data.sql work
cd sql
mariadb-client -h "$DB_HOST" -u "$DB_USER" --local-infile=1 < "load_data.sql"
cd ..

if [ $? -eq 0 ]; then
    echo "✓ Data loaded successfully"
else
    echo "✗ Failed to load data"
    exit 1
fi

echo ""
echo "============================================"
echo "Setup Complete!"
echo "============================================"
echo ""
echo "Database: contacts_db"
echo "Tables created: 5"
echo "  - contacts (main contact information)"
echo "  - addresses (contact addresses)"
echo "  - companies (company information)"
echo "  - contact_companies (employment relationships)"
echo "  - notes (contact notes)"
echo ""
echo "Sample data loaded: ~200 contacts with related data"
echo ""
echo "To connect to the database:"
echo "  mariadb-client -h $DB_HOST -u $DB_USER -p contacts_db"
echo ""
