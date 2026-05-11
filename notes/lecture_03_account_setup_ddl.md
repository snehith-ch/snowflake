# Lecture 3: Account Setup, DDL, Roles Deep Dive, and Date Functions

## Quick Revision — Lecture 3

| # | Key Point |
|---|-----------|
| 1 | Two schemas auto-created with every database: PUBLIC and INFORMATION_SCHEMA |
| 2 | SHOW GRANTS TO ROLE role_name — see all privileges of a role |
| 3 | GRANT privilege ON object_type object_name TO ROLE role_name — full privilege syntax |
| 4 | Custom roles (e.g., MARKETING_ROLE) are real-world roles; system roles (ACCOUNTADMIN etc.) are rarely seen in projects |
| 5 | GRANT CREATE DATABASE ON ACCOUNT TO ROLE role_name — grants ability to create databases |
| 6 | INFORMATION_SCHEMA.COLUMNS — get column information for any table |
| 7 | :: (cast operator) converts data types: '2022-12-26'::DATE treats string as a date |
| 8 | DAYOFYEAR(current_date()) — which day of the year (e.g., 80) |
| 9 | DATEDIFF('years'/'months'/'days', start_date, end_date) — date difference |
| 10 | SPLIT_PART(string, delimiter, position) — splits names like 'Vinay_Kumar_CH' into parts |

---

**Pre-requisite:** Lecture 2 — Users, Roles, UI Navigation, and Utility Functions
**Next:** Lecture 4 — Stages, Files, and Data Loading
**Related:** Lecture 2 — RBAC Fundamentals

---

## Objects Created This Lecture

| Object Type | Name              | Purpose                                           |
|-------------|-------------------|---------------------------------------------------|
| Database    | MARKETING_DB      | Marketing department database (RBAC demo)         |
| Schema      | MARKETING_SCHEMA  | Marketing schema                                  |
| Table       | T_DEPT            | Department table (deptno, dname, loc)             |
| Table       | T_EMP             | Employee table (empno, ename, sal/doj)            |
| Table       | T_HR_INFO         | HR info with name split demo (empno, ename, job, mgr, hiredate, sal, comm, deptno) |
| Role        | MARKETING_ROLE    | Custom role for marketing team (RBAC demo)        |
| Role        | SALES_ROLE        | Custom role for sales team (RBAC demo)            |
| Role        | DEV_ROLE          | Developer custom role                             |
| User        | DEV_USER          | Developer user for ongoing course demos           |
| Warehouse   | MARKETING_WH      | Warehouse created and granted to MARKETING_ROLE   |

---

## ASCII Data Flow — RBAC Privilege Chain

```
ACCOUNTADMIN (Krishna)
       |
       |---> CREATE ROLE marketing_role
       |---> GRANT USAGE ON DATABASE marketing_db TO ROLE marketing_role
       |---> GRANT USAGE ON SCHEMA marketing_schema TO ROLE marketing_role
       |---> GRANT USAGE ON WAREHOUSE marketing_wh TO ROLE marketing_role
       |---> GRANT SELECT ON TABLE t_dept TO ROLE marketing_role
       |---> GRANT SELECT ON TABLE t_emp TO ROLE marketing_role
       |---> GRANT INSERT ON TABLE t_emp TO ROLE marketing_role
       |
       |---> GRANT ROLE marketing_role TO USER vinay
       |
VINAY (with marketing_role)
       |
       +--> Can SELECT from t_dept, t_emp
       +--> Can INSERT into t_emp
       +--> Cannot INSERT into other tables (insufficient privileges)
```

---

## 1. Creating a Snowflake Account — Step-by-Step

1. Navigate to **snowflake.com**
2. Click **Start for Free**
3. Fill in: first name, last name, email, reason for signing up
4. Choose **Edition**: Standard / Enterprise / Business Critical
5. Choose **Cloud Provider**: AWS / Azure / GCP
6. Click **Get Started**
7. Check your email → click **Activate Your Snowflake Account**
8. The activation link contains your **unique account URL** — save this!
9. Set your **username** (e.g., `KRISHNA`) and **password**
10. Log in → navigate to **Projects → Worksheets**

> Snowflake accounts expire after **30 days** on the free trial. You can create a new account with a different email afterward.

> Krishna (in lecture): "There is some issue with my laptop actually. I am logging through other laptop. So that is the reason I am creating this account." — he created a fresh account to demonstrate the full setup flow again.

---

## 2. Creating Databases and Schemas

### Creating a Database

```sql
CREATE DATABASE MARKETING_DB;
```

After creation, two schemas are **automatically created**:
1. `PUBLIC` — default, empty schema for user objects
2. `INFORMATION_SCHEMA` — read-only metadata views about all objects

> Krishna: "Once you create a database, two schemas will be automatically created. What are those schemas? One is public. The other one is what? Information schema."

### Creating Schemas

```sql
CREATE SCHEMA MARKETING_SCHEMA;
```

### Verifying Databases

```sql
-- Method 1: SHOW command
SHOW DATABASES;

-- Method 2: INFORMATION_SCHEMA
SELECT * FROM INFORMATION_SCHEMA.DATABASES;
```

The output includes: database name, creation timestamp, owner, options.

---

## 3. Creating Tables

```sql
-- Department table (created in class)
CREATE TABLE T_DEPT (
    DEPTNO   NUMBER,
    DNAME    VARCHAR,
    LOC      VARCHAR
);

-- Employee table (created in class)
CREATE TABLE T_EMP (
    EMPNO  NUMBER,
    ENAME  VARCHAR,
    SAL    NUMBER
);
```

### Verifying Tables

```sql
-- Method 1: INFORMATION_SCHEMA.TABLES
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
-- TABLE_CATALOG = database name, TABLE_SCHEMA = schema name

-- Method 2: SHOW TABLES (current schema only)
SHOW TABLES;
```

**Column descriptions in `INFORMATION_SCHEMA.TABLES`:**

| Column Name      | Description                           |
|------------------|---------------------------------------|
| TABLE_CATALOG    | Database name                         |
| TABLE_SCHEMA     | Schema name                           |
| TABLE_NAME       | Table name                            |
| TABLE_TYPE       | BASE TABLE, VIEW, etc.                |
| CREATED          | Timestamp when table was created      |
| LAST_ALTERED     | Timestamp of last modification        |

> Krishna: "What is this table catalog? Table catalog is nothing but the database name. Table schema is nothing but the current schema name. This is nothing but the table name."

### Checking Column Information

```sql
-- Get column details for a specific table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'T_EMP';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'T_DEPT';
```

> **Student Question:** How many columns are there in dept? How can I get that information?
> **Answer:** Use `SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'T_DEPT';` — returns column names, data types, positions. Dept has 3 columns (DEPTNO, DNAME, LOC).

---

## 4. GET_DDL Function

To view the creation script (DDL) of any Snowflake object:

```sql
-- Syntax
SELECT GET_DDL('object_type', 'object_name');

-- Get DDL for a table
SELECT GET_DDL('TABLE', 'T_EMP');

-- Get DDL for a file format
SELECT GET_DDL('FILE_FORMAT', 'JSON_FORMAT');

-- Get DDL for a view
SELECT GET_DDL('VIEW', 'MY_VIEW');
```

This is useful when you need to:
- Recreate an object in another environment
- Audit the structure of existing objects
- Generate documentation

---

## 5. Snowflake Objects Reference

The full list of objects you can create under a schema (shown in UI under Create button):

```
Schema
├── Tables                 ← Primary storage objects
├── Dynamic Tables         ← Automatically refreshed tables
├── Views                  ← Virtual tables based on queries
├── Materialized Views     ← Pre-computed, stored view results
├── Stages                 ← File storage locations (internal/external)
├── File Formats           ← Describe how to parse files
├── Sequences              ← Auto-incrementing number generators
├── Snowpipes              ← Continuous/micro-batch data loading
├── Streams                ← Change data capture (CDC)
├── Tasks                  ← Scheduled SQL execution
├── Stored Procedures      ← Reusable SQL/JavaScript/Python logic
├── Functions (UDFs)       ← User-defined functions
└── Storage Integrations   ← Cloud storage connection objects
```

> Krishna (in UI demo): "If I click on create, I can see the different objects that I can create. So I can create tables, view, stages, storage integration, file format, sequences, snowpipes, stream, task, procedures, functions. So these are all the different database objects."

---

## 6. Roles Deep Dive: Privileges and Custom Roles

### Role Hierarchy in Snowflake

```
ACCOUNTADMIN
     │
SECURITYADMIN
     │
  USERADMIN
     │
  SYSADMIN
     │
   PUBLIC
```

In real-world projects, you will typically be assigned a **custom role** — not one of the system roles. For example: `MARKETING_ROLE`, `DEV_ROLE`, `SALES_ROLE`.

> Krishna: "In the real time, you will not see these roles. Let's say we are working for a marketing project. I am creating a role here. Marketing role. So what is this marketing role? Who created this? This is a role created by the user. This is not the role which is given by Snowflake."

### Creating a Custom Role

```sql
CREATE ROLE MARKETING_ROLE;
```

### Viewing Privileges of a Role

```sql
-- Show what privileges a role has
SHOW GRANTS TO ROLE MARKETING_ROLE;

-- Initially: no privileges (empty result)
-- Krishna: "With this role, what exit I can do? There are no results. Which means this role does not have any privileges."
```

> **Important First Command on Any Project:**
> When you join a real project, this is the FIRST command you should run:
> ```sql
> SHOW GRANTS TO ROLE <your_role_name>;
> ```
> It tells you exactly what databases, schemas, tables, and warehouses you have access to.

### Granting Privileges to a Role

A role needs privileges to access objects. The privilege hierarchy follows the object hierarchy:

```
Account Level (for CREATE DATABASE)
    └── Database (USAGE)
            └── Schema (USAGE)
                    └── Table (SELECT, INSERT, UPDATE, DELETE)
                    └── Warehouse (USAGE)
```

```sql
-- Step 1: Grant database access
GRANT USAGE ON DATABASE MARKETING_DB TO ROLE MARKETING_ROLE;

-- Step 2: Grant schema access
GRANT USAGE ON SCHEMA MARKETING_SCHEMA TO ROLE MARKETING_ROLE;

-- Step 3: Grant warehouse access
GRANT USAGE ON WAREHOUSE MARKETING_WH TO ROLE MARKETING_ROLE;

-- Step 4: Grant table access (SELECT = read)
GRANT SELECT ON TABLE T_DEPT TO ROLE MARKETING_ROLE;
GRANT SELECT ON TABLE T_EMP  TO ROLE MARKETING_ROLE;

-- Grant INSERT privilege separately (for write operations)
GRANT INSERT ON TABLE T_DEPT TO ROLE MARKETING_ROLE;
GRANT INSERT ON TABLE T_EMP  TO ROLE MARKETING_ROLE;
```

### Full Class Demo — RBAC in Action

```sql
-- STEP 1: Create role
CREATE ROLE MARKETING_ROLE;

-- STEP 2: Create warehouse
CREATE WAREHOUSE MARKETING_WH;

-- STEP 3: Create tables and insert data (as ACCOUNTADMIN)
CREATE TABLE T_DEPT (DEPTNO NUMBER, DNAME VARCHAR, LOC VARCHAR);
CREATE TABLE T_EMP  (EMPNO NUMBER, ENAME VARCHAR, SAL NUMBER);

INSERT INTO T_DEPT VALUES (10, 'SALES', 'HYD');
INSERT INTO T_DEPT VALUES (20, 'ACCOUNTS', 'DELHI');
INSERT INTO T_EMP  VALUES (101, 'Vinay', 20000);
INSERT INTO T_EMP  VALUES (102, 'Rajesh', 40000);

-- STEP 4: Grant privileges
GRANT USAGE ON DATABASE MARKETING_DB TO ROLE MARKETING_ROLE;
GRANT USAGE ON SCHEMA MARKETING_SCHEMA TO ROLE MARKETING_ROLE;
GRANT USAGE ON WAREHOUSE MARKETING_WH TO ROLE MARKETING_ROLE;
GRANT SELECT ON TABLE T_DEPT TO ROLE MARKETING_ROLE;
GRANT SELECT ON TABLE T_EMP  TO ROLE MARKETING_ROLE;

-- STEP 5: Grant role to user
GRANT ROLE MARKETING_ROLE TO USER VINAY;

-- Now log in as VINAY → they can SELECT but NOT INSERT
-- INSERT gives: "Insufficient privileges to operate on this account"

-- STEP 6: Grant INSERT privilege
GRANT INSERT ON TABLE T_EMP  TO ROLE MARKETING_ROLE;
GRANT INSERT ON TABLE T_DEPT TO ROLE MARKETING_ROLE;

-- Now VINAY can INSERT into both tables
```

> **Key insight:** "Can I say Snowflake is a role-based? Correct. It is a role based, right? Whatever the role you have based on that, you'll get the privileges, correct? So that is the reason Snowflake is called what? Role based. So generally we'll call it as RBAC. Role based access control."

### Revoking Roles and Granting New Ones

```sql
-- Revoke role from user
REVOKE ROLE MARKETING_ROLE FROM USER SUNIL;

-- Grant new role
GRANT ROLE SALES_ROLE TO USER SUNIL;
```

> Krishna (demonstrating): "So whatever the role that I have granted, I revoke that. Let me come back and do a refresh. Go to the databases. His role is what? Public. So he don't have access to any of the objects because I have revoked that."

### Creating a Warehouse (for a Role)

```sql
CREATE WAREHOUSE MARKETING_WH;
```

---

## 7. RBAC Full Example — New User Joining the Team

> **Scenario:** A new user (Sunil) joins the marketing project. We want to give them the same access as Vinay.

```sql
-- All we need to do is grant the SAME role
GRANT ROLE MARKETING_ROLE TO USER SUNIL;
-- Sunil now has all the same privileges as Vinay (database, schema, warehouse, tables)
```

> Krishna: "Now tell me guys, what will happen if I give this role to Sunil? What are the objects that he can access? Exactly. He can able to access the database, schema, and he can able to access the warehouse, and he can able to see the different tables. Now tell me, can I say Snowflake is role based? Correct."

---

## 8. Granting CREATE DATABASE Privilege

To allow a role to create databases, you grant at the **account** level:

```sql
GRANT CREATE DATABASE ON ACCOUNT TO ROLE DEV_ROLE;
```

Once a role can create a database, it automatically has full control over objects within that database.

```sql
-- Demonstration from class:
-- (Logged in as DEV_USER with DEV_ROLE)
-- Trying CREATE DATABASE without privilege:
CREATE DATABASE DEV_DB;
-- Error: "Insufficient privilege to operate on the account"

-- ACCOUNTADMIN grants:
GRANT CREATE DATABASE ON ACCOUNT TO ROLE DEV_ROLE;

-- Now DEV_USER can create database
SHOW GRANTS TO ROLE DEV_ROLE;
-- Shows: CREATE DATABASE privilege on ACCOUNT

-- After grant, can also create schema and tables
CREATE SCHEMA DEV_SCHEMA;
CREATE TABLE T_CUSTOMER (CUST_ID NUMBER, CUST_NAME VARCHAR, CODE VARCHAR);
```

> **Important Note:** "It is not a user based, that's what I'm telling you. This is a role based. Whatever the role you have based on that, you have the privilege. Everything is driven by a role."

---

## 9. Snowflake Built-in Functions

Snowflake provides nearly **1,000 built-in functions** covering date, string, math, conversion, and more.

```sql
-- View all available functions
SHOW FUNCTIONS;
-- Returns ~986 functions with their descriptions
```

> **Student Question:** As you were having hands-on experience, you are typically typing the functions. What can be the good thing for getting hands-on for commands you are typing?
> **Answer (Krishna):** There are a lot of functions. Whenever the requirement comes in, let's say we just talked about date. You can go look at the date functions and find the relevant one. There are descriptions given for each function. Export the results to Excel and highlight whatever you use during the course.

> Krishna: "Even I don't know most of the functions. So whenever the requirement comes in, right? You go to date, see the functions there, find the relevant one. They are giving you the description as well."

### Finding Specific Functions

```sql
-- Search functions by name pattern
SHOW FUNCTIONS LIKE '%current_Database%';
SHOW FUNCTIONS LIKE '%current_timestamp%';
```

Exported results show: function name, minimum arguments, maximum arguments, description, return type.

- `CURRENT_DATABASE` → 0 parameters (no arguments needed)
- `DAYOFYEAR` → 1 parameter (pass a date)
- `DATEDIFF` → 3 parameters (unit, start, end)

---

## 10. Date Functions — Complete Coverage

### 10.1 CURRENT_DATE and CURRENT_TIMESTAMP

```sql
SELECT CURRENT_DATE();       -- 2025-03-21 (no parameters needed)
SELECT CURRENT_TIMESTAMP();  -- 2025-03-21 08:30:00.123
```

> Krishna: "What I'm doing, I'm just putting open-brace and closed-brace, which means zero parameters. I don't need to pass any parameters. If I run this, what will happen? I'll get the today's date."

### 10.2 DAYOFYEAR

Returns which day of the year the given date falls on (1–366):

```sql
SELECT DAYOFYEAR(CURRENT_DATE());  -- 80 (80th day of the year on 2025-03-21)
                                   -- 83 (when run a few days later on 2025-03-24)

-- Passing a specific date (must use CAST if it's a string)
SELECT DAYOFYEAR('2022-12-26'::DATE);  -- Returns 360
```

> Krishna: "So day of year, out of 365 days, I'm at which day? Exactly at 83rd day. Now, if I want to find out the starting date of the year, for that I need to use a function called date_trunc."

> **Common Mistake:** `SELECT DAYOFYEAR('2022-12-26');` — treats the string as VARCHAR, not a date, gives error. Must use `::DATE` cast.

### 10.3 DATE_TRUNC — Find Start of Period

```sql
-- Start of current year
SELECT DATE_TRUNC('year', CURRENT_DATE());   -- 2025-01-01

-- Start of current month
SELECT DATE_TRUNC('month', CURRENT_DATE());  -- 2025-03-01

-- Start of current day (midnight)
SELECT DATE_TRUNC('day', CURRENT_DATE());    -- 2025-03-24
```

> Krishna: "You can get the starting date of the year, starting date of the month and starting date of the day. When the day will start? It is exactly midnight time actually."

### 10.4 LAST_DAY — Last Day of a Month

```sql
-- Last day of the current month
SELECT LAST_DAY(CURRENT_DATE());        -- 2025-03-31

-- Last day of February 2024 (leap year check)
SELECT LAST_DAY('2024-02-02'::DATE);    -- 2024-02-29
```

> Krishna: "What is the last date of the February month? 28th. So this is not a leap year. Actually you can get February 29th."

### 10.5 ADD_MONTHS — Add or Subtract Months

```sql
-- Add 2 months to current date
SELECT ADD_MONTHS(CURRENT_DATE(), 2);    -- 2025-05-24 (from March 24)

-- Subtract 2 months
SELECT ADD_MONTHS(CURRENT_DATE(), -2);   -- 2025-01-24
```

> Krishna: "If I add two months, what will be the output date? It will be May, right? May 24, correct? If I want to subtract two months, I can use minus 2."

### 10.6 DATEDIFF — Calculate Date Differences

```sql
-- Syntax: DATEDIFF(unit, start_date, end_date)

-- Calculate experience in years
SELECT DATEDIFF('years',  '2020-03-24'::DATE, CURRENT_DATE());    -- 5
SELECT DATEDIFF('months', '2020-03-24'::DATE, CURRENT_DATE());    -- ~60
SELECT DATEDIFF('days',   '2020-03-24'::DATE, CURRENT_DATE());    -- ~1826
```

### 10.7 Practical Example: Calculate Employee Experience

Exact class demo — table created and data inserted in class:

```sql
-- Create table (from class)
CREATE TABLE T_EMP (EMPNO NUMBER, ENAME VARCHAR, DOJ DATE);

-- Insert records
INSERT INTO T_EMP VALUES (1, 'Syed',  '2020-03-24');
INSERT INTO T_EMP VALUES (2, 'Sunil', '2010-03-24');

SELECT * FROM T_EMP;

-- Calculate experience
SELECT EMPNO, ENAME, DATEDIFF('years',  DOJ, CURRENT_DATE()) FROM T_EMP;
SELECT EMPNO, ENAME, DATEDIFF('months', DOJ, CURRENT_DATE()) FROM T_EMP;
SELECT EMPNO, ENAME, DATEDIFF('days',   DOJ, CURRENT_DATE()) FROM T_EMP;
```

Expected output (as of March 2025):
```
EMPNO | ENAME | years | months | days
------|-------|-------|--------|------
1     | Syed  | 5     | 60     | 1826
2     | Sunil | 15    | 180    | 5479
```

---

## 11. How Many Days Left in the Year? — Class Exercise

> Krishna: "I have to find out the number of days left in the current year. Can you able to answer this? How many days are left to complete the current year?"

**Step-by-step solution built in class:**

```sql
-- Step 1: Find which day of the year we are on
SELECT DAYOFYEAR(CURRENT_DATE()); -- 80 (on March 21)

-- Step 2: Subtract from 365 (simple approach)
SELECT 365 - DAYOFYEAR(CURRENT_DATE()); -- 285

-- Step 3: More accurate (gets the real last day of the year)
-- Find the start of the year
SELECT DATE_TRUNC('year', CURRENT_DATE()); -- 2025-01-01

-- Add 11 months to get December 1st
SELECT ADD_MONTHS(DATE_TRUNC('year', CURRENT_DATE()), 11); -- 2025-12-01

-- Get the last day of December
SELECT LAST_DAY(ADD_MONTHS(DATE_TRUNC('year', CURRENT_DATE()), 11)); -- 2025-12-31

-- Get difference between Jan 1 and Dec 31 (+1 to count both endpoints)
SELECT DATEDIFF('days', DATE_TRUNC('year', CURRENT_DATE()),
    LAST_DAY(ADD_MONTHS(DATE_TRUNC('year', CURRENT_DATE()), 11))) + 1;
-- 365 (2025 is not a leap year)

-- Final: days remaining
SELECT DATEDIFF('days', DATE_TRUNC('year', CURRENT_DATE()),
    LAST_DAY(ADD_MONTHS(DATE_TRUNC('year', CURRENT_DATE()), 11))) + 1
    - DAYOFYEAR(CURRENT_DATE());
-- 285 (as of March 21, 2025)
```

> Krishna: "So I have used date_trunc, add_months, last_day, datediff, dayofyear — many functions, right? See, just forget about these functions for now. The main point is just try to understand the significance of the functions. If I want to achieve a specific functionality, I need to go with the functions."

---

## 12. The CAST Operator (`::`)

The `::` operator converts a value from one data type to another.

```sql
-- Convert string to DATE
SELECT '2022-12-26'::DATE;

-- Convert to NUMBER
SELECT '42'::NUMBER;

-- Convert to VARCHAR
SELECT 100::VARCHAR;

-- In context with DAYOFYEAR
SELECT DAYOFYEAR('2022-12-26'::DATE);  -- 360
```

> **Why this matters:** When you pass a string literal like `'2022-12-26'` to a date function, Snowflake may treat it as `VARCHAR`. Using `::DATE` explicitly tells Snowflake to treat it as a date.

> Krishna: "It is not treating it as a date, guys. Okay. So I want Snowflake to treat it as a date. So what you need to do is, you need to know one more parameter, colon colon. This is called cast operator. Cast operator."

> **Common Mistake:** Forgetting `::DATE` when passing a date string to date functions. `DAYOFYEAR('2022-12-26')` fails; `DAYOFYEAR('2022-12-26'::DATE)` works.

---

## 13. TO_DATE() — Parsing Dates in Non-Standard Formats

The `::DATE` cast works well when your date string is already in the standard `YYYY-MM-DD` format. But what if the date is stored in a different format, like `'17-DEC-1980'` or `'03/21/2025'`?

That is when you need `TO_DATE()` with a **format string**.

### Syntax

```sql
TO_DATE(date_string, 'format_pattern')
```

The format pattern tells Snowflake exactly how to read the string. Common format codes:

| Code  | Meaning                        | Example      |
|-------|--------------------------------|--------------|
| `DD`  | Day as two digits              | `17`         |
| `MON` | Month as three-letter abbreviation | `DEC`    |
| `MM`  | Month as two digits            | `12`         |
| `YYYY`| Four-digit year                | `1980`       |
| `YY`  | Two-digit year                 | `80`         |

### Examples

```sql
-- Date stored as 'DD-MON-YYYY' (common in Oracle/legacy systems)
SELECT TO_DATE('17-DEC-1980', 'DD-MON-YYYY');
-- Returns: 1980-12-17

-- Date stored as 'MM/DD/YYYY' (US format)
SELECT TO_DATE('03/21/2025', 'MM/DD/YYYY');
-- Returns: 2025-03-21
```

> **Interview Tip:** If asked "how do you handle a date field that comes in as `'17-DEC-1980'`?", the answer is: use `TO_DATE('17-DEC-1980', 'DD-MON-YYYY')` to parse it into a proper Snowflake DATE value.

---

## 14. String Functions — SPLIT_PART

### The Problem: Names Stored as Combined String

In the class, the `T_HR_INFO` table stores employee names as `'VINAY_KUMAR_CH'` — first name, last name, and surname all in one field, separated by underscore.

### Creating and Populating T_HR_INFO

```sql
-- Table created in class
CREATE TABLE T_HR_INFO (
    EMPNO    NUMBER,
    ENAME    VARCHAR,   -- Format: 'FirstName_LastName_Surname'
    JOB      VARCHAR,
    MGR      NUMBER,
    HIREDATE DATE,
    SAL      NUMBER,
    COMM     NUMBER,
    DEPTNO   NUMBER
);

-- Actual data inserted in class using TO_DATE
INSERT INTO T_HR_INFO VALUES
    (7369, 'VINAY_KUMAR_CH',  'CLERK',   7902,
     TO_DATE('17-DEC-1980', 'DD-MON-YYYY'),  800, NULL, 20);
INSERT INTO T_HR_INFO VALUES
    (7499, 'THARUN_KUMAR_CHALLA',  'SALESMAN', 7698,
     TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600, 300, 30);
INSERT INTO T_HR_INFO VALUES
    (7521, 'BALA_KRISHNA_KORAGANTI', 'SALESMAN', 7698,
     TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250, 500, 30);
INSERT INTO T_HR_INFO VALUES
    (7566, 'SAI_KISHORE_P', 'MANAGER', 7839,
     TO_DATE('2-APR-1981', 'DD-MON-YYYY'), 2975, NULL, 20);
```

### Using SPLIT_PART

```sql
-- Syntax: SPLIT_PART(string, delimiter, position)

-- Get employee name components from T_HR_INFO
SELECT
    EMPNO,
    SPLIT_PART(ENAME, '_', 1) AS FIRST_NAME,
    SPLIT_PART(ENAME, '_', 2) AS LAST_NAME,
    SPLIT_PART(ENAME, '_', 3) AS SURNAME
FROM T_HR_INFO;
```

Expected output:
```
EMPNO | FIRST_NAME | LAST_NAME | SURNAME
------|------------|-----------|--------
7369  | VINAY      | KUMAR     | CH
7499  | THARUN     | KUMAR     | CHALLA
7521  | BALA       | KRISHNA   | KORAGANTI
7566  | SAI        | KISHORE   | P
```

> Krishna: "See my requirement is, employee name contains first name last name and surname, right? I want to display the employee name into three different columns. What you need to do is you need to use a function called split_part."

> Krishna: "How first name, last name and surname are separated? Under score. Under score. So the here underscore is called what? Delimiter."

---

## 15. Granting Access to DEV_USER (Course Setup)

This setup is used for the rest of the course demos:

```sql
-- From Daily Notes.sql
CREATE ROLE DEV_ROLE;
CREATE USER DEV_USER PASSWORD = 'Happybirtdhay12';
GRANT ROLE DEV_ROLE TO USER DEV_USER;

-- Granting database, schema and warehouse access
GRANT USAGE ON DATABASE DEV_DB TO ROLE DEV_ROLE;
GRANT USAGE ON SCHEMA DEV_SCHEMA TO ROLE DEV_ROLE;
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE DEV_ROLE;

-- Granting table access
GRANT SELECT ON TABLE T_STUDENTS TO ROLE DEV_ROLE;
GRANT SELECT ON TABLE T_EMP TO ROLE DEV_ROLE;
GRANT SELECT ON TABLE T_HR_INFO TO ROLE DEV_ROLE;
```

---

## 16. Key Differences Tables

### SHOW TABLES vs INFORMATION_SCHEMA.TABLES

| Command                            | Scope                                   | Output Format  |
|------------------------------------|-----------------------------------------|----------------|
| `SHOW TABLES`                      | Current schema only                     | Tabular, limited columns |
| `INFORMATION_SCHEMA.TABLES`        | All schemas in current database         | More columns including CREATED timestamp |

### GRANT ROLE vs GRANT PRIVILEGE

| Command | What it does | Example |
|---------|-------------|---------|
| `GRANT ROLE X TO USER Y` | Assigns a role (which carries privileges) to a user | `GRANT ROLE marketing_role TO USER vinay` |
| `GRANT privilege ON object TO ROLE X` | Assigns a specific permission on an object to a role | `GRANT SELECT ON TABLE t_emp TO ROLE marketing_role` |

### :: (Cast) vs TO_DATE()

| Situation | Use | Example |
|-----------|-----|---------|
| String is already `'YYYY-MM-DD'` | `::DATE` | `'2022-12-26'::DATE` |
| String is `'DD-MON-YYYY'` or other format | `TO_DATE('value', 'format')` | `TO_DATE('17-DEC-1980', 'DD-MON-YYYY')` |
| From external system with custom format | `TO_DATE(column, 'format')` | `TO_DATE(hire_date, 'MM/DD/YYYY')` |

### System Roles vs Custom Roles

| Type | Examples | Who Creates | When You See It |
|------|----------|-------------|-----------------|
| System Roles | ACCOUNTADMIN, SECURITYADMIN, USERADMIN, SYSADMIN, PUBLIC | Snowflake (built-in) | During account setup / admin work |
| Custom Roles | MARKETING_ROLE, DEV_ROLE, SALES_ROLE | DBA / Admin team | In real projects (day-to-day work) |

---

## 17. Key Commands Reference

```sql
-- Database and Schema
CREATE DATABASE db_name;
CREATE SCHEMA schema_name;
SHOW DATABASES;
SHOW SCHEMAS;
SELECT * FROM INFORMATION_SCHEMA.DATABASES;

-- Tables
CREATE TABLE table_name (col1 datatype, col2 datatype, ...);
SHOW TABLES;
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'table_name';
SELECT GET_DDL('TABLE', 'table_name');

-- Roles and Privileges
CREATE ROLE role_name;
CREATE WAREHOUSE wh_name;
GRANT USAGE ON DATABASE db_name TO ROLE role_name;
GRANT USAGE ON SCHEMA schema_name TO ROLE role_name;
GRANT USAGE ON WAREHOUSE wh_name TO ROLE role_name;
GRANT SELECT ON TABLE table_name TO ROLE role_name;
GRANT INSERT ON TABLE table_name TO ROLE role_name;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE role_name;
REVOKE ROLE role_name FROM USER user_name;
SHOW GRANTS TO ROLE role_name;

-- Date Functions
SELECT DAYOFYEAR(CURRENT_DATE());
SELECT DATE_TRUNC('year', CURRENT_DATE());
SELECT DATE_TRUNC('month', CURRENT_DATE());
SELECT LAST_DAY(CURRENT_DATE());
SELECT ADD_MONTHS(CURRENT_DATE(), n);
SELECT DATEDIFF('years', start_date, end_date);
SELECT DATEDIFF('months', start_date, end_date);
SELECT DATEDIFF('days', start_date, end_date);

-- Cast operator
SELECT '2022-12-26'::DATE;
SELECT '42'::NUMBER;

-- TO_DATE with format string
SELECT TO_DATE('17-DEC-1980', 'DD-MON-YYYY');
SELECT TO_DATE('03/21/2025', 'MM/DD/YYYY');

-- String functions
SELECT SPLIT_PART(ENAME, '_', 1) AS FIRST_NAME FROM T_HR_INFO;
SELECT SPLIT_PART(ENAME, '_', 2) AS LAST_NAME  FROM T_HR_INFO;
SELECT SPLIT_PART(ENAME, '_', 3) AS SURNAME    FROM T_HR_INFO;
```

---

## 18. Common Errors Table

| Error / Scenario | Cause | Fix |
|------------------|-------|-----|
| "Insufficient privilege to operate on this account" | Role does not have the required privilege | `GRANT <privilege> ON <object> TO ROLE <role_name>` |
| "Numeric value 'Bala' is not recognized" | Inserting a VARCHAR into a NUMBER column | Check data type — use VARCHAR column or fix data |
| `DAYOFYEAR('2022-12-26')` gives wrong result | String not cast to DATE — treated as VARCHAR | Use `DAYOFYEAR('2022-12-26'::DATE)` |
| `INSERT INTO T_EMP VALUES (103, 'Sonali', 50000)` fails with "insufficient privileges" | Role only has SELECT, not INSERT | `GRANT INSERT ON TABLE T_EMP TO ROLE MARKETING_ROLE` |
| `CREATE DATABASE DEV_DB` fails for DEV_ROLE | Role needs CREATE DATABASE at account level | `GRANT CREATE DATABASE ON ACCOUNT TO ROLE DEV_ROLE` |

---

## 19. Q&A from This Lecture

> **Student Question:** Is there any way to grant information in bulk — like granting everything at once?
> **Answer (Krishna):** You can prepare all the statements and run them at once, okay? And grant that role to the required users. There is no single "grant all" shortcut — you must grant database, schema, warehouse, and each table individually.

> **Student Question:** As a fresher can I get a job in this technology?
> **Answer (Krishna):** Yes. Even if you have any opportunity, let's say when you place in any company, for fresher also they are giving this training. It's Snowflake with Janay, it has integration with many things. You will get it. Even though they will generally see some experience — at least minimum two years — for fresher you can highlight this skill. Most companies give training in-house and put them on projects.

> **Student Question:** How it would be in real time — what will you actually be working on as a Snowflake developer?
> **Answer (Krishna):** I'll show you that in tomorrow's session. I'll take a couple of scenarios and show you what is the exact role of the snowflake developer. But whatever we have done today — that is the part of the admin activity. It is completely admin work.

> **Student Question:** Can we get training on ticketing tools and how to understand requirements?
> **Answer (Krishna):** Yes, I'll explain how the agile process works, what a sprint is, etc. If you're planning to come to office, you can see that with people who are working. How they are getting requirements, what is agile, what is a sprint.

> **Student Question:** If I wanted to put 3 years of experience, which role can I say in Snowflake?
> **Answer (Krishna):** Snowflake developer / data engineer role.

---

## 20. Interview Questions

**Q: What is RBAC in Snowflake?**
A: Role-Based Access Control. Privileges are assigned to roles, not directly to users. Users are then assigned roles. Whatever the role you have, based on that you get the privileges.

**Q: What are the system (built-in) roles in Snowflake?**
A: ACCOUNTADMIN, SECURITYADMIN, USERADMIN, SYSADMIN, PUBLIC (in order from highest to lowest privilege).

**Q: What is the difference between system roles and custom roles?**
A: System roles are built into Snowflake. Custom roles are created by users/admins for specific project needs (e.g., MARKETING_ROLE, DEV_ROLE). In real projects, you typically work with custom roles.

**Q: What command do you run first when you join a new project?**
A: `SHOW GRANTS TO ROLE <your_role>;` — to see exactly what databases, schemas, warehouses, and tables you have access to.

**Q: How do you grant a role access to create databases?**
A: `GRANT CREATE DATABASE ON ACCOUNT TO ROLE role_name;` — granted at the account level.

**Q: What is the CAST operator in Snowflake?**
A: `::` — used to convert a value to a specific data type. For example, `'2022-12-26'::DATE` converts the string to a DATE value.

**Q: What is SPLIT_PART()?**
A: A string function that splits a string by a delimiter and returns a specific part. `SPLIT_PART('Vinay_Kumar_CH', '_', 1)` returns 'Vinay'.

**Q: What does DATE_TRUNC() do?**
A: Returns the start of a specified time period. `DATE_TRUNC('year', CURRENT_DATE())` returns 2025-01-01 (start of the current year).

**Q: How does DATEDIFF() work?**
A: `DATEDIFF(unit, start_date, end_date)` — returns the difference between two dates in the specified unit (years, months, days).

**Q: What is the difference between GRANT ROLE and GRANT privilege?**
A: `GRANT ROLE X TO USER Y` assigns a role to a user. `GRANT SELECT ON TABLE T TO ROLE R` assigns a specific privilege on an object to a role.

**Q: What are the privileges needed for a role to access a table in Snowflake?**
A: USAGE on DATABASE + USAGE on SCHEMA + USAGE on WAREHOUSE + SELECT (and/or INSERT, etc.) on the TABLE.

**Q: How do you handle date values in non-standard formats (like Oracle's 'DD-MON-YYYY')?**
A: Use `TO_DATE('17-DEC-1980', 'DD-MON-YYYY')` — pass the date string and the format pattern.

---

## 21. Try It Yourself Exercises

**Exercise 1:** Create a custom role called `ANALYST_ROLE`, a warehouse called `ANALYST_WH`, and grant it access to `DEV_DB` and `DEV_SCHEMA`. Then show what privileges it has.
```sql
CREATE ROLE ANALYST_ROLE;
CREATE WAREHOUSE ANALYST_WH;
GRANT USAGE ON DATABASE DEV_DB TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA DEV_SCHEMA TO ROLE ANALYST_ROLE;
GRANT USAGE ON WAREHOUSE ANALYST_WH TO ROLE ANALYST_ROLE;
SHOW GRANTS TO ROLE ANALYST_ROLE;
```

**Exercise 2:** Create a table `T_EMP` (EMPNO NUMBER, ENAME VARCHAR, DOJ DATE), insert 3 records with different join dates, and calculate experience in years, months, and days for each.
```sql
CREATE TABLE T_EMP (EMPNO NUMBER, ENAME VARCHAR, DOJ DATE);
INSERT INTO T_EMP VALUES (1, 'Vinay', '2020-01-15');
INSERT INTO T_EMP VALUES (2, 'Sunil', '2015-06-01');
INSERT INTO T_EMP VALUES (3, 'Syed',  '2010-03-24');
SELECT EMPNO, ENAME,
    DATEDIFF('years',  DOJ, CURRENT_DATE()) AS YEARS,
    DATEDIFF('months', DOJ, CURRENT_DATE()) AS MONTHS,
    DATEDIFF('days',   DOJ, CURRENT_DATE()) AS DAYS
FROM T_EMP;
```

**Exercise 3:** Create a table `T_HR_INFO` with the schema from class, insert 2 records using TO_DATE, then use SPLIT_PART to separate the name into first, last, and surname.
```sql
CREATE TABLE T_HR_INFO (EMPNO NUMBER, ENAME VARCHAR, JOB VARCHAR, HIREDATE DATE);
INSERT INTO T_HR_INFO VALUES (1001, 'ARJUN_KUMAR_REDDY', 'ANALYST',
    TO_DATE('15-JAN-2020', 'DD-MON-YYYY'));
INSERT INTO T_HR_INFO VALUES (1002, 'PRIYA_SHARMA_MN', 'ENGINEER',
    TO_DATE('20-FEB-2019', 'DD-MON-YYYY'));
SELECT EMPNO,
    SPLIT_PART(ENAME, '_', 1) AS FIRST_NAME,
    SPLIT_PART(ENAME, '_', 2) AS LAST_NAME,
    SPLIT_PART(ENAME, '_', 3) AS SURNAME
FROM T_HR_INFO;
```

**Exercise 4:** Calculate how many days are left in the current year using DATEDIFF, DATE_TRUNC, ADD_MONTHS, and LAST_DAY.
```sql
SELECT DATEDIFF('days', DATE_TRUNC('year', CURRENT_DATE()),
    LAST_DAY(ADD_MONTHS(DATE_TRUNC('year', CURRENT_DATE()), 11))) + 1
    - DAYOFYEAR(CURRENT_DATE()) AS DAYS_LEFT_IN_YEAR;
```

**Exercise 5:** Grant ANALYST_ROLE insert privilege on T_EMP, then revoke the marketing_role from a user (substitute your own test user). Verify the privileges changed.
```sql
GRANT INSERT ON TABLE T_EMP TO ROLE ANALYST_ROLE;
SHOW GRANTS TO ROLE ANALYST_ROLE;
-- Should now show both USAGE and INSERT privileges

-- Revoke example
REVOKE ROLE ANALYST_ROLE FROM USER TEST_USER;
-- User now falls back to PUBLIC role
```

---

## 22. Key Terms

| Term           | Definition                                                              |
|----------------|-------------------------------------------------------------------------|
| DDL            | Data Definition Language — CREATE, ALTER, DROP statements               |
| INFORMATION_SCHEMA | System schema containing metadata views for all objects in a database |
| RBAC           | Role-Based Access Control                                               |
| Privilege      | A specific permission granted to a role (SELECT, INSERT, USAGE, etc.)   |
| USAGE          | Privilege to access (but not modify) a database, schema, or warehouse   |
| GET_DDL()      | Function that returns the creation script of any object                  |
| CAST (::)      | Operator to convert a value to a different data type                    |
| TO_DATE()      | Function to parse a date string using an explicit format pattern (e.g., `'DD-MON-YYYY'`) |
| DATE_TRUNC     | Function returning the start of a time period (year, month, week, day)  |
| DATEDIFF       | Function calculating the difference between two dates                   |
| SPLIT_PART     | Function splitting a string by a delimiter and returning a portion      |
| Delimiter      | The character that separates parts in a string (e.g., underscore `_` or comma `,`) |
| Custom Role    | A role created by a user/admin for project-specific access control      |

---

## 23. Summary

- Creating a database automatically creates `PUBLIC` and `INFORMATION_SCHEMA` schemas
- `INFORMATION_SCHEMA` is your primary tool for **metadata queries** (tables, columns, schemas, stages, file formats)
- Snowflake objects include: tables, views, stages, file formats, sequences, snowpipes, streams, tasks, procedures, functions, storage integrations
- Custom roles give teams granular access — the admin defines roles once, then assigns to users
- **Role-based**: give privileges to roles, assign roles to users — this is RBAC
- The `::` cast operator converts data types — critical for date comparisons
- Use `TO_DATE('date_string', 'format_pattern')` when dates arrive in non-standard formats like `'17-DEC-1980'` or `'03/21/2025'`; `::DATE` only works for `YYYY-MM-DD` strings
- Key date functions: `DAYOFYEAR`, `DATE_TRUNC`, `LAST_DAY`, `ADD_MONTHS`, `DATEDIFF`
- `SPLIT_PART` splits strings by a delimiter — useful for parsing combined fields
- When joining a new project: run `SHOW GRANTS TO ROLE <your_role>;` first to understand your access
