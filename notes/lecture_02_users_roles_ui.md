# Lecture 2: Users, Roles, UI Navigation, and Utility Functions

## Quick Revision — Lecture 2

| # | Key Point |
|---|-----------|
| 1 | Snowflake is role-based (RBAC) — privileges are assigned to roles, then roles to users |
| 2 | Default role for any new user is PUBLIC |
| 3 | Built-in roles: ACCOUNTADMIN > SECURITYADMIN > USERADMIN > SYSADMIN > PUBLIC |
| 4 | "Granting role PUBLIC has no effect — every user has PUBLIC implicitly" |
| 5 | A user can have multiple roles; multiple users can share the same role |
| 6 | SHOW USERS — lists all users; SHOW ROLES — lists all roles |
| 7 | CURRENT_USER(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE() are context functions |
| 8 | Default timezone is America/Los_Angeles; change with ALTER SESSION SET TIMEZONE |
| 9 | Marketplace lets you import third-party datasets; Partner Connect links to ETL/BI partners |
| 10 | Query History stores all executed statements |

---

**Pre-requisite:** Lecture 1 — Introduction to Snowflake, Architecture  
**Next:** Lecture 3 — Account Setup, DDL, Roles Deep Dive, and Date Functions  
**Related:** Lecture 3 — Custom Roles and Privilege Granting

---

## Objects Created This Lecture

| Object Type | Name          | Purpose                                     |
|-------------|---------------|---------------------------------------------|
| Database    | DEV_DB        | Development database                        |
| Schema      | DEV_SCHEMA    | Development schema                          |
| Table       | T_STUDENTS    | Student info table (used in later lectures) |
| User        | DEEPAK        | Security admin demo user                    |
| User        | ANIL          | User admin demo user                        |
| User        | VINAY         | Sysadmin demo user                          |
| User        | RAJSHEKHAR    | Public role demo user                       |
| User        | SUNIL         | Sysadmin demo user                          |

---

## ASCII Data Flow — Role Assignment

```
ACCOUNTADMIN (Krishna)
        |
        ├── CREATE USER deepak
        │       └── GRANT ROLE SECURITYADMIN TO USER deepak
        |
        ├── CREATE USER anil
        │       └── GRANT ROLE USERADMIN TO USER anil
        |
        ├── CREATE USER vinay
        │       └── GRANT ROLE SYSADMIN TO USER vinay
        |
        └── CREATE USER rajshekhar
                └── (PUBLIC — default, no GRANT needed)
```

---

## 1. Recap of Lecture 1

- **Database** → contains **Schemas** → which contain **Objects** (tables, views, stages, etc.)
- Snowflake is a **cloud data warehouse** (not on-premise)
- **Three-layer architecture**: Database Storage | Query Processing (Virtual Warehouse) | Cloud Services
- Virtual warehouse must be **running** for any read/write operation
- Minimum billing: **1 minute**, then per-second

---

## 2. Snowflake Editions (Recap)

| Edition           | Description                                      |
|-------------------|--------------------------------------------------|
| Standard          | Core features                                    |
| Enterprise        | Advanced features                                |
| Business Critical | All features + compliance (HIPAA, PCI-DSS, etc.) |

Snowflake is currently supported by **three major cloud providers**: AWS, Azure, and GCP.

---

## 3. Snowflake User Interface Navigation

### 3.1 Snowsight vs. Classic UI

| Interface   | Period       | Description                             |
|-------------|------------- |-----------------------------------------|
| Classic UI  | Before 2023  | Legacy interface; still works           |
| Snowsight   | 2023 onwards | Modern, improved UI                     |

> **Interview Tip:** "What user interfaces have you worked on in Snowflake?" — Answer: Snowsight (current) and Classic UI (legacy).

### Shortcut for Executing Queries

```
Ctrl + Enter   →  Execute the selected/current query
```

### Common UI Navigation Shown in Class

```sql
-- Select database and schema via UI dropdown or SQL
USE DATABASE DEV_DB;
USE SCHEMA DEV_SCHEMA;
```

> Krishna: "Did anyone remember guys, what is the name of this UI? Snow site. It is Snow site guys."

---

## 4. Snowflake Marketplace

The **Marketplace** is a data-sharing platform within Snowflake where you can import third-party datasets.

**Demonstrated in class:**
1. Click on **Marketplace** in the sidebar
2. Browse — found COVID-19 Analysis dataset
3. Click **Get** → **Get** → **Done**
4. Go back to Projects → do a refresh
5. COVID-19 Analysis database now appears in your databases list

> Krishna: "From the marketplace, what you can do, guys? You can import the database. You can import the database."

> **Student Question:** How can I find out when a database was created?
> **Answer:** Run `SELECT * FROM INFORMATION_SCHEMA.DATABASES;` — it shows the creation timestamp.

---

## 5. Partner Connect

**Partner Connect** lists all Snowflake partner tools — ETL, reporting, analytics, and big data tools.

```
Partner Connect shows:
├── DBT (Data Build Tool)
├── Informatica (IICS)
├── Matillion
├── SnapLogic
├── Talend
├── Looker
└── Many more...
```

> Krishna: "So partner connect means these are all the partners with Snowflake. If you want to work with Informatica, click on Informatica. There is an option called connect. If you click on this connect, you will get one 30-day free trial."

---

## 6. Query History

Snowflake maintains a **Query History** of all statements you have executed.

> Krishna: "Whatever the statement that I have executed, everything will be available in what? In the query history."

- Shows: CREATE DATABASE, CREATE SCHEMA, CREATE TABLE, INSERT — everything
- Accessible via **Activity → Query History** in the UI

---

## 7. Roles in Snowflake — Core Concept

### The Real-World Analogy Krishna Used

```
Company Hierarchy:
  Krishna    → Manager
  Deepak     → Team Lead
  Anil       → Consultant
  Vinay      → Senior Software Engineer
  Rajshekhar → Fresher
```

> Krishna: "Without a role, can an employee exist in a company? No. Similarly, in Snowflake, without a role, a user will not exist."

> **Key Principle:** "Each role has its own significance. Each role has what? Privileges."

### 7.1 Built-in System Roles

```
ACCOUNTADMIN       (Manager — manages everything)
      |
SECURITYADMIN      (Team Lead — manages users and roles)
      |
USERADMIN          (Consultant — creates users)
      |
SYSADMIN           (Senior SE — creates databases and warehouses)
      |
PUBLIC             (Fresher — default, minimal privileges)
```

| Role          | Responsibilities                                                    | Analogy            |
|---------------|---------------------------------------------------------------------|--------------------|
| ACCOUNTADMIN  | Full control — manages the entire account                           | CEO / Manager      |
| SECURITYADMIN | Creates and manages users and roles                                  | IT Security Lead   |
| USERADMIN     | Creates users and grants roles                                       | HR / Team Lead     |
| SYSADMIN      | Creates databases, schemas, warehouses                               | Consultant         |
| PUBLIC        | Default role — minimal privileges, assigned to all users by default  | Fresher            |

> **Important:** Without a role, a user cannot exist in Snowflake. Every user is assigned at least the PUBLIC role by default.

### 7.2 Default Role

When you create a user **without** explicitly assigning a role, the default role is:
```
PUBLIC
```

> Krishna demonstrated: Created user Deepak, logged in as Deepak, checked role → "It is public. So the important point is if you create a user, the default role of the user is what? Public."

---

## 8. Creating Users — Step-by-Step

### Syntax

```sql
CREATE USER username PASSWORD = 'your_password';
```

### Class Example — Creating the Team

```sql
-- Deepak → Security Admin (Team Lead)
CREATE USER Deepak PASSWORD = 'Happybirthday12';

-- Anil → User Admin (Consultant)
CREATE USER Anil PASSWORD = 'Happybirthday12';

-- Vinay → Sys Admin (Senior SE)
CREATE USER Vinay PASSWORD = 'Happybirthday12';

-- Rajshekhar → Public (Fresher)
CREATE USER Raksekhar PASSWORD = 'Happybirthday12';

-- Sunil → Sys Admin
CREATE USER Sunil PASSWORD = 'Happybirthday12';
```

### Verify Users

```sql
SHOW USERS;
```

Class output shown:
```
KRISHNA      ACCOUNTADMIN
Deepak       SECURITYADMIN
Anil         USERADMIN
Vinay        SYSADMIN
Rajsekhar    PUBLIC
```

---

## 9. Granting Roles to Users

```sql
-- Syntax
GRANT ROLE role_name TO USER user_name;

-- Class examples
GRANT ROLE SECURITYADMIN TO USER Deepak;
GRANT ROLE USERADMIN     TO USER Anil;
GRANT ROLE SYSADMIN      TO USER Vinay;
GRANT ROLE SYSADMIN      TO USER Sunil;
-- Raksekhar keeps PUBLIC (default — no GRANT needed)
```

> **Important Note about PUBLIC:**

```sql
GRANT ROLE PUBLIC TO USER Raksekhar;
-- Message: "Granting role PUBLIC has no effect. Every user and role has PUBLIC implicitly granted."
```

> Krishna: "The meaning is if you create a user, the default role of the user is what? Public."

### Verifying the Current Role

```sql
SELECT CURRENT_ROLE();
-- Shows: SECURITYADMIN (for Deepak after grant)
```

---

## 10. Multiple Roles Per User

> **Student Question:** Can a role be granted to multiple persons?
> **Answer (Krishna):** Yes. Multiple users can have the same role. And the user can have multiple roles.

```sql
-- Multiple users can have same role
GRANT ROLE SYSADMIN TO USER Vinay;
GRANT ROLE SYSADMIN TO USER Sunil;  -- Both have SYSADMIN

-- User can have multiple roles
GRANT ROLE SECURITYADMIN TO USER Deepak;
GRANT ROLE USERADMIN     TO USER Deepak;
-- Deepak now has: SECURITYADMIN, USERADMIN, PUBLIC (implicit)
```

Class demonstration: Logged in as user with SECURITYADMIN role — showed they have 3 roles: SECURITYADMIN, USERADMIN (granted), PUBLIC (implicit).

---

## 11. Context / Session Functions

These functions return information about the **current session** — commonly asked in interviews.

### 11.1 Functions Demonstrated in Class

```sql
SELECT CURRENT_USER();        -- Returns: KRISHNA
SELECT CURRENT_DATABASE();    -- Returns: DEV_DB
SELECT CURRENT_SCHEMA();      -- Returns: DEV_SCHEMA
SELECT CURRENT_WAREHOUSE();   -- Returns: COMPUTE_WH
SELECT CURRENT_ROLE();        -- Returns: current active role
SELECT CURRENT_DATE();        -- Returns: 2025-03-20
SELECT CURRENT_TIMESTAMP();   -- Returns: 2025-03-20 06:57:08.772 -0700
```

> Krishna asked the class: "Now, what is the current username? What is the current database name? Schema name? Current warehouse name that you are using?"
> Students answered: Krishna, DevDB, DevSchema, Compute.

> **Interview Tip:** These context functions are very commonly asked. Know all of them.

---

## 12. Time Zones in Snowflake

Snowflake uses **UTC-based time zones**. Default is `America/Los_Angeles`.

> Krishna: "According to India it is 7:27 PM. But the time which we are getting is 6:57. Early morning 6:57. So there should be a different time zone."

### Viewing and Changing Time Zone

```sql
-- Show all session parameters
SHOW PARAMETERS;

-- Filter for timezone only
SHOW PARAMETERS LIKE 'TIMEZONE';
-- Output: America/Los_Angeles (UTC-7, so 6:57 AM while India is 7:27 PM)

-- Change to India Standard Time
ALTER SESSION SET TIMEZONE = 'Asia/Kolkata';

-- Verify
SELECT CURRENT_TIMESTAMP();  -- Now shows +05:30
```

> Krishna: "From the universal time zone, we are 5 and a half hours ahead. So +530."

**Understanding UTC Offsets:**
- UTC is **Universal Time Coordinated** — the global time standard
- **India (IST)** = UTC + 5:30 (Asia/Kolkata)
- **America/Los_Angeles** = UTC - 7:00 (PDT) or UTC - 8:00 (PST)

---

## 13. Creating DEV_DB and T_STUDENTS Table

This was done during the lecture to set up for future demos:

```sql
CREATE DATABASE DEV_DB;
CREATE SCHEMA DEV_SCHEMA;

-- Table used throughout the course
CREATE TABLE T_STUDENTS (SNO NUMBER, SNAME VARCHAR, DOJ DATE);

-- Verify
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
-- Returns 1 row
```

> Krishna: "See, since I have one table I got that information."

---

## 14. SHOW Commands Reference

```sql
SHOW USERS;          -- List all users in the account
SHOW ROLES;          -- List all roles available
SHOW DATABASES;      -- List all databases
SHOW SCHEMAS;        -- List schemas in current database
SHOW TABLES;         -- List tables in current schema
SHOW WAREHOUSES;     -- List virtual warehouses
SHOW PARAMETERS;     -- List session/account parameters
SHOW FUNCTIONS;      -- List all built-in functions (~986)
```

### SHOW FUNCTIONS — Finding Specific Functions

```sql
-- There are 986 built-in functions — use LIKE to narrow down
SHOW FUNCTIONS LIKE '%current_Database%';
SHOW FUNCTIONS LIKE '%current_timestamp%';
```

> Krishna: "Show functions — how many functions are you getting? Can you see the number here? 986 rows, which means there are 986 functions. Even I don't know most of the functions."

### Difference: SHOW TABLES vs. INFORMATION_SCHEMA.TABLES

| Command                            | Scope                                          |
|------------------------------------|------------------------------------------------|
| `SHOW TABLES`                      | Current schema only                            |
| `INFORMATION_SCHEMA.TABLES`        | All schemas in current database                |

---

## 15. Switching Context (USE Command)

```sql
-- Switch to a specific database
USE DATABASE DEV_DB;

-- Switch to a specific schema
USE SCHEMA DEV_SCHEMA;

-- Switch warehouse
USE WAREHOUSE COMPUTE_WH;
```

Also done via the dropdown in the Snowsight UI.

---

## 16. REVOKE — Two Different Forms

### Form 1: Revoke a Role from a User

Removes the role assignment from a specific user. The role itself is not deleted.

```sql
-- Syntax
REVOKE ROLE role_name FROM USER user_name;

-- Class example: Remove MARKETING_ROLE from user Sunil
REVOKE ROLE MARKETING_ROLE FROM USER SUNIL;
-- After this: Sunil's role reverts to PUBLIC
-- Come back → do a refresh → role is PUBLIC, no database access
```

### Form 2: Revoke a Privilege from a Role

Removes a specific permission from a role. All users with that role immediately lose that permission.

```sql
-- Syntax
REVOKE privilege ON object_type object_name FROM ROLE role_name;

-- Class example: Remove USAGE on database from PUBLIC role
REVOKE USAGE ON DATABASE SALES_DB FROM ROLE PUBLIC;
```

---

## 17. Common Q&A from This Lecture

> **Student Question:** Is there any way to grant information in bulk — like we are creating the metadata and then granting everything at once?
> **Answer (Krishna):** You can prepare all the statements and run them at once, then grant the role to the required users.

> **Student Question:** What if we are into online mode — can people share their real-time code/work?
> **Answer:** No. That is a compliance issue. People who are working won't share anything online. You can see it by coming to office.

> **Student Question:** As a fresher, can I get a job in this technology?
> **Answer:** Yes. Even for freshers, if you know Snowflake and SQL, you can highlight that on your CV. Most companies give training to freshers and put them on projects. Minimum 2 years experience is what they typically look for, but freshers can try too.

---

## 18. Key Commands Summary

```sql
-- User management
CREATE USER username PASSWORD = 'pwd';
SHOW USERS;
GRANT ROLE role_name TO USER user_name;
REVOKE ROLE role_name FROM USER user_name;

-- Context/Session functions
SELECT CURRENT_USER();
SELECT CURRENT_DATABASE();
SELECT CURRENT_SCHEMA();
SELECT CURRENT_WAREHOUSE();
SELECT CURRENT_ROLE();
SELECT CURRENT_DATE();
SELECT CURRENT_TIMESTAMP();

-- Parameters
SHOW PARAMETERS;
SHOW PARAMETERS LIKE 'TIMEZONE';
ALTER SESSION SET TIMEZONE = 'Asia/Kolkata';

-- Object discovery
SHOW TABLES;
SHOW SCHEMAS;
SHOW WAREHOUSES;
SHOW FUNCTIONS LIKE '%current%';

-- Database metadata
SELECT * FROM INFORMATION_SCHEMA.DATABASES;
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
```

---

## 19. Common Errors Table

| Error / Scenario                                              | Cause                                        | Fix                                          |
|---------------------------------------------------------------|----------------------------------------------|----------------------------------------------|
| "Granting role PUBLIC has no effect..."                       | PUBLIC is implicitly granted to all users    | No action needed — PUBLIC is always there    |
| User created but has no access to any database               | Default role is PUBLIC with no privileges    | Grant USAGE on database, schema, warehouse   |
| Warehouse suspended — cannot read/write                       | Warehouse not running                        | `ALTER WAREHOUSE ... RESUME`                 |
| Wrong timezone shown in CURRENT_TIMESTAMP()                  | Default is America/Los_Angeles               | `ALTER SESSION SET TIMEZONE = 'Asia/Kolkata'`|

---

## 20. Interview Questions

**Q: What is RBAC in Snowflake?**
A: Role-Based Access Control. Privileges are assigned to roles, not directly to users. Users are then assigned roles. Whatever the role you have, based on that, you get the privileges.

**Q: What is the default role for a new user in Snowflake?**
A: PUBLIC. If you try to explicitly grant PUBLIC, Snowflake says: "Granting role PUBLIC has no effect. Every user and role has PUBLIC implicitly granted."

**Q: Can a user have multiple roles?**
A: Yes. A user can be granted multiple roles. They can switch between roles in the UI or with `USE ROLE`.

**Q: Can multiple users have the same role?**
A: Yes. You can grant the same role to many different users. All of them get the same privileges.

**Q: What is CURRENT_USER()?**
A: Returns the username of the currently logged-in user.

**Q: What is the difference between SHOW TABLES and INFORMATION_SCHEMA.TABLES?**
A: SHOW TABLES shows tables in the current schema only. INFORMATION_SCHEMA.TABLES shows tables across all schemas in the current database.

**Q: How do you change the timezone in Snowflake?**
A: `ALTER SESSION SET TIMEZONE = 'Asia/Kolkata';`

**Q: What is the Snowflake Marketplace?**
A: A platform within Snowflake where you can import third-party datasets (like COVID-19 data) directly into your account as databases.

---

## 21. Try It Yourself Exercises

**Exercise 1:** Create a user `TEST_USER` with a password. Check their default role using SHOW USERS.

```sql
CREATE USER TEST_USER PASSWORD = 'Test@1234';
SHOW USERS;
-- Default role will be PUBLIC
```

**Exercise 2:** Grant SYSADMIN role to TEST_USER. Log in as TEST_USER and verify the role.

```sql
GRANT ROLE SYSADMIN TO USER TEST_USER;
-- Then log in as TEST_USER
SELECT CURRENT_ROLE(); -- Should show SYSADMIN
```

**Exercise 3:** Run all context functions and note the output.

```sql
SELECT CURRENT_USER();
SELECT CURRENT_DATABASE();
SELECT CURRENT_SCHEMA();
SELECT CURRENT_WAREHOUSE();
SELECT CURRENT_ROLE();
SELECT CURRENT_DATE();
SELECT CURRENT_TIMESTAMP();
```

**Exercise 4:** Change timezone to India time and verify CURRENT_TIMESTAMP().

```sql
ALTER SESSION SET TIMEZONE = 'Asia/Kolkata';
SELECT CURRENT_TIMESTAMP(); -- Should show +05:30
SHOW PARAMETERS LIKE 'TIMEZONE'; -- Should show Asia/Kolkata
```

**Exercise 5:** Revoke SYSADMIN from TEST_USER and verify they only have PUBLIC.

```sql
REVOKE ROLE SYSADMIN FROM USER TEST_USER;
-- Log in as TEST_USER
SELECT CURRENT_ROLE(); -- Should show PUBLIC
```

---

## 22. Key Terms

| Term              | Definition                                                                     |
|-------------------|--------------------------------------------------------------------------------|
| RBAC              | Role-Based Access Control — privileges are assigned to roles, not users         |
| Role              | A named collection of privileges in Snowflake                                   |
| ACCOUNTADMIN      | Highest-privilege built-in role in Snowflake                                    |
| PUBLIC            | Default role automatically assigned to all users                                |
| Marketplace       | Snowflake's built-in platform for sharing and accessing third-party datasets    |
| Partner Connect   | Portal linking Snowflake with partner ETL and BI tools                          |
| Query History     | Log of all executed SQL statements                                              |
| SHOW PARAMETERS   | Command to display all session/account configuration settings                   |
| CURRENT_USER()    | Function returning the currently logged-in username                             |
| Snowsight         | Snowflake's modern UI (2023+)                                                   |
| REVOKE ROLE       | Removes a role assignment from a user                                           |
| REVOKE privilege  | Removes a specific permission (SELECT, USAGE, etc.) from a role                 |
| UTC               | Universal Time Coordinated — the global time standard                           |

---

## 23. Summary

- Snowflake is **role-based** (RBAC) — privileges are assigned to roles, then roles to users
- **Built-in roles**: ACCOUNTADMIN > SECURITYADMIN > USERADMIN > SYSADMIN > PUBLIC
- A user's **default role** is always PUBLIC unless explicitly changed
- Use `GRANT ROLE role_name TO USER user_name` to assign roles
- **Two forms of REVOKE**: `REVOKE ROLE X FROM USER Y` (removes role from user) vs. `REVOKE privilege ON object FROM ROLE X` (removes a permission from a role)
- **Context functions** (`CURRENT_USER`, `CURRENT_DATABASE`, etc.) are frequently asked in interviews
- **SHOW PARAMETERS** reveals all session settings including the active timezone
- Use `SHOW FUNCTIONS LIKE '%pattern%'` to find specific functions without scrolling through all 986
- **Marketplace** lets you import third-party datasets; **Partner Connect** connects to ETL/BI tools
