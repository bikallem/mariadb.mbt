-- Load Data Script for Contacts Database
-- This script loads CSV data into the contacts database
-- Make sure to run schema.sql first
--
-- NOTE: LOAD DATA LOCAL INFILE paths are relative to where the mysql client is run
-- Run this script from the sql/ directory:
--   cd src/examples/contacts/sql
--   mysql -u root -p --local-infile=1 < load_data.sql
--
-- Or use absolute paths if running from elsewhere

USE contacts_db;

-- Disable foreign key checks for faster loading
SET FOREIGN_KEY_CHECKS = 0;

-- Load contacts from CSV (relative path assumes running from sql/ directory)
LOAD DATA LOCAL INFILE 'contacts.csv'
INTO TABLE contacts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(first_name, last_name, email, phone, date_of_birth);

-- Load companies from CSV
LOAD DATA LOCAL INFILE 'companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(name, industry, website, employee_count);

-- Generate addresses for contacts (approximately 250 addresses for 200 contacts)
INSERT INTO addresses (contact_id, address_type, street_address, city, state, postal_code, country, is_primary)
SELECT 
    id,
    'home',
    CONCAT(FLOOR(100 + RAND() * 9900), ' ', 
           ELT(FLOOR(1 + RAND() * 10), 'Main', 'Oak', 'Maple', 'Pine', 'Cedar', 'Elm', 'Park', 'Lake', 'Hill', 'River'),
           ' ',
           ELT(FLOOR(1 + RAND() * 5), 'Street', 'Avenue', 'Road', 'Boulevard', 'Drive')),
    ELT(FLOOR(1 + RAND() * 20), 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 
        'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus',
        'Charlotte', 'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Boston'),
    ELT(FLOOR(1 + RAND() * 10), 'NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'FL', 'OH', 'NC', 'WA'),
    LPAD(FLOOR(10000 + RAND() * 89999), 5, '0'),
    'USA',
    TRUE
FROM contacts;

-- Generate work addresses for about half of contacts
INSERT INTO addresses (contact_id, address_type, street_address, city, state, postal_code, country, is_primary)
SELECT 
    id,
    'work',
    CONCAT(FLOOR(100 + RAND() * 9900), ' ', 
           ELT(FLOOR(1 + RAND() * 10), 'Commerce', 'Business', 'Corporate', 'Industry', 'Tech', 'Innovation', 'Enterprise', 'Professional', 'Executive', 'Market'),
           ' ',
           ELT(FLOOR(1 + RAND() * 5), 'Street', 'Avenue', 'Road', 'Boulevard', 'Drive')),
    ELT(FLOOR(1 + RAND() * 20), 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 
        'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus',
        'Charlotte', 'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Boston'),
    ELT(FLOOR(1 + RAND() * 10), 'NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'FL', 'OH', 'NC', 'WA'),
    LPAD(FLOOR(10000 + RAND() * 89999), 5, '0'),
    'USA',
    FALSE
FROM contacts
WHERE id % 2 = 0;

-- Link contacts to companies with job titles
INSERT INTO contact_companies (contact_id, company_id, job_title, start_date, is_current)
SELECT 
    c.id,
    1 + FLOOR(RAND() * 20),
    ELT(FLOOR(1 + RAND() * 15), 'Software Engineer', 'Senior Manager', 'Director', 'Vice President', 
        'Marketing Specialist', 'Sales Representative', 'Product Manager', 'Business Analyst',
        'Financial Analyst', 'HR Manager', 'Operations Manager', 'Customer Success Manager',
        'Project Manager', 'Data Scientist', 'UX Designer'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(1 + RAND() * 3650) DAY),
    TRUE
FROM contacts c
WHERE c.id <= 180;

-- Add some historical employment (past jobs)
INSERT INTO contact_companies (contact_id, company_id, job_title, start_date, end_date, is_current)
SELECT 
    c.id,
    1 + FLOOR(RAND() * 20),
    ELT(FLOOR(1 + RAND() * 10), 'Junior Developer', 'Associate', 'Coordinator', 'Specialist', 
        'Consultant', 'Analyst', 'Assistant Manager', 'Team Lead', 'Supervisor', 'Engineer'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(2000 + RAND() * 3650) DAY),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(365 + RAND() * 1500) DAY),
    FALSE
FROM contacts c
WHERE c.id <= 100;

-- Generate notes for contacts
INSERT INTO notes (contact_id, note_text, category)
SELECT 
    id,
    CONCAT('Initial contact made on ', DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY), '%Y-%m-%d'),
           '. ', ELT(FLOOR(1 + RAND() * 5), 
                'Very interested in our services.',
                'Requested follow-up next quarter.',
                'Positive discussion about collaboration.',
                'Needs more information about pricing.',
                'Ready to move forward with proposal.')),
    'general'
FROM contacts
WHERE id % 3 = 0;

INSERT INTO notes (contact_id, note_text, category)
SELECT 
    id,
    CONCAT('Meeting scheduled for ', DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 30) DAY), '%Y-%m-%d'),
           ' at ', FLOOR(9 + RAND() * 8), ':00 ',
           ELT(FLOOR(1 + RAND() * 2), 'AM', 'PM'), '. ',
           ELT(FLOOR(1 + RAND() * 4), 
                'Agenda: project review.',
                'Agenda: quarterly planning.',
                'Agenda: product demo.',
                'Agenda: contract discussion.')),
    'meeting'
FROM contacts
WHERE id % 4 = 0;

INSERT INTO notes (contact_id, note_text, category)
SELECT 
    id,
    CONCAT('Phone call on ', DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY), '%Y-%m-%d'),
           '. ', ELT(FLOOR(1 + RAND() * 4), 
                'Left voicemail, awaiting callback.',
                'Discussed project timeline and deliverables.',
                'Confirmed attendance at upcoming event.',
                'Provided technical support and answered questions.')),
    'call'
FROM contacts
WHERE id % 5 = 0;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Display summary statistics
SELECT 'Contacts loaded:' AS summary, COUNT(*) AS count FROM contacts
UNION ALL
SELECT 'Addresses loaded:', COUNT(*) FROM addresses
UNION ALL
SELECT 'Companies loaded:', COUNT(*) FROM companies
UNION ALL
SELECT 'Contact-Company links:', COUNT(*) FROM contact_companies
UNION ALL
SELECT 'Notes created:', COUNT(*) FROM notes;
