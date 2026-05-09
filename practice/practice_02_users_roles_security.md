# Practice Set 2: Users, Roles & Access Control (RBAC)

> **Topics Covered**: Users, Roles, Granting Privileges, RBAC, Masking Policies
> **Related Lectures**: Lecture 2, 3, 21, 22

---

## Background: Role-Based Access Control (RBAC)

In Snowflake, security is managed through **RBAC** — Role-Based Access Control:
- Every user must have a role
- Roles have privileges (permissions) on objects
- Users can have multiple roles
- Default role for any new user is `PUBLIC`

```
ACCOUNTADMIN (highest)
    └── SECURITYADMIN
            └── USERADMIN
                    └── SYSADMIN
                            └── PUBLIC (lowest / default)
```

---

## Setup — Run as ACCOUNTADMIN

```sql
USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS security_practice_db;
CREATE SCHEMA IF NOT EXISTS security_practice_schema;
USE DATABASE security_practice_db;
USE SCHEMA security_practice_schema;
```

---

## Section 1: Creating Users

### Exercise 1.1 — Create Multiple Users
Create the following users (all with password `Snowflake123!`):

| User     | Role to Assign  | Description          |
|----------|-----------------|----------------------|
| dev_user1 | SYSADMIN       | Developer             |
| analyst1  | PUBLIC         | Read-only analyst     |
| admin1    | SECURITYADMIN  | Security administrator|

```sql
-- Create users:
CREATE USER dev_user1 
    PASSWORD = 'Snowflake123!'
    DEFAULT_ROLE = SYSADMIN
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER analyst1
    PASSWORD = 'Snowflake123!'
    DEFAULT_ROLE = PUBLIC
    MUST_CHANGE_PASSWORD = FALSE;

-- Write analyst1 and admin1 yourself:


```

---

### Exercise 1.2 — View User Information
```sql
-- List all users
SHOW USERS;

-- Check details of a specific user
DESCRIBE USER dev_user1;

-- What is the default role of analyst1?
-- Answer: _______________
```

---

### Exercise 1.3 — Grant Roles to Users
```sql
-- Grant SYSADMIN to dev_user1
GRANT ROLE SYSADMIN TO USER dev_user1;

-- Grant SECURITYADMIN to admin1
-- Write here:


-- Can you grant the same role to multiple users?
GRANT ROLE SYSADMIN TO USER admin1;
-- Yes! Multiple users can have the same role.

-- Can one user have multiple roles?
GRANT ROLE PUBLIC TO USER dev_user1;
-- Yes! One user can have multiple roles.
```

---

## Section 2: Creating and Using Roles

### Exercise 2.1 — Create a Custom Role
```sql
-- Create a custom role for data analysts
CREATE ROLE analyst_role COMMENT = 'Read-only access to sales data';

-- Check roles
SHOW ROLES;

-- Grant the role to analyst1
GRANT ROLE analyst_role TO USER analyst1;
```

---

### Exercise 2.2 — Grant Object Privileges to Roles
```sql
-- Step 1: Create a test table
USE ROLE SYSADMIN;
USE DATABASE security_practice_db;
USE SCHEMA security_practice_schema;

CREATE TABLE customer_data (
    cust_id     NUMBER,
    cust_name   VARCHAR(100),
    email       VARCHAR(150),
    phone       VARCHAR(20),
    credit_score NUMBER
);

INSERT INTO customer_data VALUES
(1, 'Alice Johnson', 'alice@email.com', '9876543210', 750),
(2, 'Bob Smith',     'bob@email.com',   '8765432109', 620),
(3, 'Carol White',   'carol@email.com', '7654321098', 810);

-- Step 2: Grant SELECT on this table to analyst_role
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON DATABASE security_practice_db TO ROLE analyst_role;
GRANT USAGE ON SCHEMA security_practice_schema TO ROLE analyst_role;
GRANT SELECT ON TABLE customer_data TO ROLE analyst_role;

-- Step 3: Log in as analyst1 and try:
-- USE ROLE analyst_role;
-- SELECT * FROM customer_data;  -- Should WORK
-- DELETE FROM customer_data;    -- Should FAIL (no DELETE privilege)
```

---

### Exercise 2.3 — Privilege Questions

Fill in the blanks:

1. To see all tables in a schema, you need ________ privilege on the schema.
2. To read data from a table, you need ________ privilege.
3. To insert data into a table, you need ________ privilege.
4. The ________ role can create other roles and manage access.
5. The ________ role can create warehouses, databases, and schemas.

**Answers**: 
1. USAGE
2. SELECT
3. INSERT
4. SECURITYADMIN / ACCOUNTADMIN
5. SYSADMIN

---

## Section 3: Masking Policies

### Exercise 3.1 — Create a Masking Policy
Scenario: The `credit_score` column should only be visible to users with `SYSADMIN` role. Other roles should see `****`.

```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE security_practice_db;
USE SCHEMA security_practice_schema;

-- Step 1: Create the masking policy
CREATE MASKING POLICY credit_mask
AS (val NUMBER) RETURNS NUMBER ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN') THEN val
        ELSE 0   -- Show 0 for non-privileged roles
    END;

-- Step 2: Apply it to the credit_score column
ALTER TABLE customer_data
    MODIFY COLUMN credit_score 
    SET MASKING POLICY credit_mask;

-- Step 3: Test with different roles
-- As SYSADMIN: should see actual credit scores
-- As analyst_role: should see 0

-- Test as SYSADMIN:
USE ROLE SYSADMIN;
SELECT cust_name, credit_score FROM customer_data;
-- You should see: 750, 620, 810

-- Test as analyst_role:
USE ROLE analyst_role;
SELECT cust_name, credit_score FROM customer_data;
-- You should see: 0, 0, 0
```

---

### Exercise 3.2 — Mask Email Address
Create a masking policy for the `email` column that shows:
- Full email for SYSADMIN/ACCOUNTADMIN
- Only `****@****.com` for other roles

```sql
CREATE MASKING POLICY email_mask
AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() IN ('SYSADMIN', 'ACCOUNTADMIN') THEN val
        ELSE '****@****.com'
    END;

-- Apply the policy to email column:
-- Write ALTER TABLE statement here:


-- Test it:
USE ROLE analyst_role;
SELECT cust_name, email FROM customer_data;
```

---

### Exercise 3.3 — Check and Remove Masking Policies
```sql
-- Check existing masking policies
SHOW MASKING POLICIES;

-- Check what columns have masking policies applied
SELECT * FROM information_schema.policy_references
WHERE policy_kind = 'MASKING_POLICY';

-- Remove masking policy from a column BEFORE dropping it
ALTER TABLE customer_data 
    MODIFY COLUMN credit_score 
    UNSET MASKING POLICY;

-- Now drop the masking policy
DROP MASKING POLICY credit_mask;

-- Can you drop a masking policy that is still applied to a column?
-- Answer: _______________  (No — you must UNSET it first)
```

---

## Section 4: Show Commands Reference

```sql
-- Frequently used SHOW commands:
SHOW USERS;                  -- List all users
SHOW ROLES;                  -- List all roles  
SHOW WAREHOUSES;             -- List all virtual warehouses
SHOW DATABASES;              -- List all databases
SHOW SCHEMAS IN DATABASE my_db;   -- List schemas in a database
SHOW TABLES IN SCHEMA my_schema;  -- List tables in a schema
SHOW GRANTS TO USER username;     -- Show grants for a user
SHOW GRANTS TO ROLE role_name;    -- Show grants for a role
SHOW MASKING POLICIES;       -- List masking policies
SHOW STAGES;                 -- List stages
SHOW INTEGRATIONS;           -- List integration objects
SHOW PIPES;                  -- List snowpipes
SHOW STREAMS;                -- List streams
SHOW TASKS;                  -- List tasks
```

---

## Challenge Questions

1. Create a role `report_viewer` that can only SELECT from all tables in `security_practice_schema`. Grant it to `analyst1`.

2. Create a masking policy for `phone` that shows only the last 4 digits (e.g., `******3210`) for non-admin roles. 
   - Hint: Use `RIGHT(val, 4)` and `CONCAT('******', RIGHT(val, 4))`

3. List all the privileges granted to the `analyst_role`:
   ```sql
   SHOW GRANTS TO ROLE analyst_role;
   ```

4. What happens if you try to grant `ACCOUNTADMIN` to a user when you are logged in as `SYSADMIN`?
   - Try it: `GRANT ROLE ACCOUNTADMIN TO USER dev_user1;`
   - Answer: _______________

5. Write a query to find all users and their default roles from the information schema:
   ```sql
   -- Hint: Use SHOW USERS and look for default_role column
   SHOW USERS;
   -- Then filter: SELECT "name", "default_role" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
   ```
