# Contacts Database Example

This example demonstrates a complete contacts management database with sample data for testing the MariaDB MoonBit bindings.

## Database Schema

The database consists of 5 tables:

1. **contacts** - Main contact information (200 records)
   - id, first_name, last_name, email, phone, date_of_birth
   - Timestamps for tracking record creation/updates

2. **addresses** - Contact addresses (one-to-many relationship)
   - Supports multiple addresses per contact (home, work, other)
   - Includes street address, city, state, postal code, country
   - Tracks primary address

3. **companies** - Company information (20 records)
   - name, industry, website, employee_count
   
4. **contact_companies** - Employment relationships (many-to-many)
   - Links contacts to companies
   - Includes job title, start/end dates
   - Tracks current vs. historical employment

5. **notes** - Contact notes (one-to-many)
   - Various note categories: general, meeting, call, email, other
   - Timestamps for tracking

## Files

- `schema.sql` - Database schema definitions (idempotent)
- `contacts.csv` - 200 sample contacts with realistic data
- `companies.csv` - 20 sample companies across various industries
- `load_data.sql` - SQL script to load CSV data and generate related records
- `user.sql` - Creates a dedicated database user for contacts_db
- `setup.sh` - Automated setup script (bash)
- `README.md` - This file

## Setup Instructions

### Option 1: Automated Setup (Recommended)

```bash
cd src/examples/contacts
chmod +x setup.sh
./setup.sh
```

The script will prompt you for:
- MySQL/MariaDB host (default: localhost)
- Username (default: root)
- Password

### Option 2: Manual Setup

1. Create the schema:
```bash
mysql -u root -p < sql/schema.sql
```

2. Load the data (must run from sql/ directory for relative paths):
```bash
cd sql
mysql -u root -p --local-infile=1 < load_data.sql
cd ..
```

3. (Optional) Create a dedicated database user:
```bash
mysql -u root -p < sql/user.sql
```

**Note:** If you get an error about `local-infile`, you may need to:
- Enable it in your MariaDB/MySQL configuration
- Or update the `load_data.sql` to use absolute paths to the CSV files

### Security: Database User

The `user.sql` script creates a dedicated user for the contacts database:

- **Username:** `contacts_user`
- **Password:** `contacts_password` (⚠️ **CHANGE THIS IN PRODUCTION!**)
- **Privileges:** Full access to `contacts_db` only

To use the dedicated user:
```bash
mysql -u contacts_user -p contacts_db
```

To change the password after creation:
```sql
ALTER USER 'contacts_user'@'localhost' IDENTIFIED BY 'your_secure_password';
```

## Verification

After setup, verify the data:

```bash
mysql -u root -p contacts_db
```

```sql
-- Check record counts
SELECT 'Contacts' as table_name, COUNT(*) as count FROM contacts
UNION ALL
SELECT 'Addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'Companies', COUNT(*) FROM companies
UNION ALL
SELECT 'Contact-Company Links', COUNT(*) FROM contact_companies
UNION ALL
SELECT 'Notes', COUNT(*) FROM notes;

-- Sample query: Find contacts with their companies
SELECT 
    c.first_name, 
    c.last_name, 
    c.email,
    cc.job_title,
    co.name as company_name,
    co.industry
FROM contacts c
JOIN contact_companies cc ON c.id = cc.contact_id
JOIN companies co ON cc.company_id = co.id
WHERE cc.is_current = TRUE
LIMIT 10;
```

## Repeatability

The database setup is fully repeatable:
- `schema.sql` uses `DROP DATABASE IF EXISTS` to ensure a clean slate
- Running the setup multiple times will reset the database to its initial state
- All data generation uses deterministic or random seeding for variety

## Sample Queries

Here are some useful queries to explore the data:

```sql
-- Contacts by city
SELECT city, COUNT(*) as contact_count 
FROM addresses 
WHERE is_primary = TRUE 
GROUP BY city 
ORDER BY contact_count DESC;

-- Companies by industry with employee counts
SELECT industry, COUNT(*) as company_count, AVG(employee_count) as avg_employees
FROM companies
GROUP BY industry
ORDER BY avg_employees DESC;

-- Contacts with multiple addresses
SELECT c.first_name, c.last_name, COUNT(a.id) as address_count
FROM contacts c
JOIN addresses a ON c.id = a.contact_id
GROUP BY c.id
HAVING address_count > 1;

-- Recent notes
SELECT c.first_name, c.last_name, n.category, n.note_text, n.created_at
FROM notes n
JOIN contacts c ON n.contact_id = c.id
ORDER BY n.created_at DESC
LIMIT 10;
```

## Next Steps

Use this database to test the MariaDB MoonBit bindings:
- Connect to the database
- Execute queries
- Test prepared statements
- Practice transaction handling
- Experiment with different data types

## Database Statistics

- **Total Contacts:** 200
- **Total Addresses:** ~300 (contacts have 1-2 addresses each)
- **Total Companies:** 20
- **Employment Records:** ~280 (current and historical)
- **Notes:** ~100+ (various categories)
