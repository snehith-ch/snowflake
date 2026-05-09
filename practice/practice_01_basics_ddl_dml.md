# Practice Set 1: Snowflake Basics — DDL & DML

> **Topics Covered**: Databases, Schemas, Tables, Data Types, Virtual Warehouses, Basic SQL
> **Related Lectures**: Lecture 1, 2, 3

---

## Setup — Run These First

```sql
-- Create your practice environment
CREATE DATABASE IF NOT EXISTS practice_db;
CREATE SCHEMA IF NOT EXISTS practice_schema;
USE DATABASE practice_db;
USE SCHEMA practice_schema;
USE WAREHOUSE compute_wh;  -- or your warehouse name
```

---

## Section 1: Database & Schema Operations

### Exercise 1.1 — Create a Database Hierarchy
Create the following structure for a fictional company "TechCorp":
- Database: `techcorp_db`
- Schemas: `hr_schema`, `sales_schema`, `finance_schema`

```sql
-- Write your answer here:



```

**Expected Result**: 3 schemas inside techcorp_db.

**Check your work**:
```sql
SELECT schema_name, created
FROM techcorp_db.information_schema.schemata
WHERE schema_name NOT IN ('INFORMATION_SCHEMA', 'PUBLIC');
-- Should show 3 schemas
```

---

### Exercise 1.2 — Explore Automatic Schemas
After creating a database, Snowflake automatically creates 2 schemas. Find them:

```sql
SELECT schema_name 
FROM techcorp_db.information_schema.schemata;
-- What are the two automatically created schemas?
-- Answer: _______________ and _______________
```

---

### Exercise 1.3 — Check Current Context
Run these commands and note the output:

```sql
SELECT CURRENT_USER();        -- Who are you logged in as?
SELECT CURRENT_ROLE();        -- What is your current role?
SELECT CURRENT_DATABASE();    -- What database are you using?
SELECT CURRENT_SCHEMA();      -- What schema are you using?
SELECT CURRENT_WAREHOUSE();   -- What warehouse is active?
SELECT CURRENT_DATE();        -- Today's date
SELECT CURRENT_TIMESTAMP();   -- Current date and time
```

---

## Section 2: Creating Tables

### Exercise 2.1 — Create an Employee Table
Create a table called `employees` with the following columns:

| Column Name  | Data Type     | Notes              |
|-------------|---------------|---------------------|
| emp_id      | NUMBER        | Employee ID         |
| emp_name    | VARCHAR(100)  | Full name           |
| department  | VARCHAR(50)   | Department name     |
| salary      | NUMBER(10,2)  | Salary with 2 decimals|
| hire_date   | DATE          | Date of joining     |
| email       | VARCHAR(150)  | Email address       |
| is_active   | BOOLEAN       | Active or not       |

```sql
-- Write your CREATE TABLE statement here:
USE DATABASE practice_db;
USE SCHEMA practice_schema;




```

**Check your work**:
```sql
DESCRIBE TABLE employees;
-- Should show 7 columns
```

---

### Exercise 2.2 — Create a Departments Table

```sql
CREATE TABLE departments (
    dept_id     NUMBER,
    dept_name   VARCHAR(100),
    location    VARCHAR(100),
    budget      NUMBER(15,2),
    created_at  TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```
What does `DEFAULT CURRENT_TIMESTAMP()` do?
**Answer**: _______________

---

### Exercise 2.3 — Add Constraints
Re-create the employees table with a PRIMARY KEY:

```sql
CREATE OR REPLACE TABLE employees (
    emp_id      NUMBER PRIMARY KEY,
    emp_name    VARCHAR(100) NOT NULL,
    department  VARCHAR(50),
    salary      NUMBER(10,2),
    hire_date   DATE,
    email       VARCHAR(150),
    is_active   BOOLEAN DEFAULT TRUE
);
```

---

## Section 3: Inserting Data

### Exercise 3.1 — Insert Single Records
Insert 3 employees into the employees table:

```sql
INSERT INTO employees (emp_id, emp_name, department, salary, hire_date, email)
VALUES (1, 'Priya Sharma', 'Engineering', 85000.00, '2022-01-15', 'priya@techcorp.com');

-- Now insert 2 more employees yourself:
-- Employee 2: Rahul Verma, Marketing, 65000, 2021-06-01
-- Employee 3: Anita Patel, Finance, 72000, 2023-03-10
```

---

### Exercise 3.2 — Insert Multiple Records at Once
```sql
INSERT INTO employees (emp_id, emp_name, department, salary, hire_date, email) VALUES
(4, 'Suresh Kumar',   'Engineering', 90000, '2020-08-20', 'suresh@techcorp.com'),
(5, 'Deepika Singh',  'HR',          55000, '2022-11-05', 'deepika@techcorp.com'),
(6, 'Amit Joshi',     'Sales',       60000, '2021-04-15', 'amit@techcorp.com'),
(7, 'Kavya Reddy',    'Engineering', 95000, '2019-12-01', 'kavya@techcorp.com'),
(8, 'Ravi Teja',      'Marketing',   68000, '2023-07-20', 'ravi@techcorp.com');
```

---

## Section 4: Querying Data

### Exercise 4.1 — Basic SELECT
```sql
-- Q1: Select all columns from employees
SELECT * FROM employees;

-- Q2: Select only emp_name, department, and salary
-- Write here:


-- Q3: Find all employees in 'Engineering' department
-- Write here:


-- Q4: Find employees with salary greater than 75000
-- Write here:

```

---

### Exercise 4.2 — Sorting and Limiting
```sql
-- Q1: Show employees sorted by salary (highest first)
SELECT emp_name, salary 
FROM employees 
ORDER BY salary DESC;

-- Q2: Show top 3 highest paid employees
-- Write here:


-- Q3: Show employees hired after 2022-01-01, sorted by hire_date
-- Write here:

```

---

### Exercise 4.3 — Aggregate Functions
```sql
-- Q1: Count total number of employees
SELECT COUNT(*) AS total_employees FROM employees;

-- Q2: Find average salary
-- Write here:


-- Q3: Find highest and lowest salary
-- Write here:


-- Q4: Find total salary by department
-- Write here:


-- Q5: Find departments with average salary > 70000
-- Write here (Hint: use HAVING):

```

---

### Exercise 4.4 — String Functions
```sql
-- Q1: Convert all emp_name to UPPER case
SELECT UPPER(emp_name) FROM employees;

-- Q2: Get first 3 characters of each department name
SELECT LEFT(department, 3), emp_name FROM employees;

-- Q3: Find employees whose name contains 'Sharma'
SELECT * FROM employees WHERE emp_name LIKE '%Sharma%';

-- Q4: Concatenate emp_name and department with a dash
-- Expected: 'Priya Sharma - Engineering'
-- Write here:

```

---

## Section 5: Updating and Deleting

### Exercise 5.1 — UPDATE
```sql
-- Q1: Give Engineering employees a 10% salary raise
UPDATE employees 
SET salary = salary * 1.10
WHERE department = 'Engineering';

-- Verify the change:
SELECT emp_name, salary FROM employees WHERE department = 'Engineering';

-- Q2: Deactivate employees hired before 2021-01-01
-- Write UPDATE statement here:


-- Q3: Change department of emp_id = 6 from 'Sales' to 'Business Development'
-- Write here:

```

---

### Exercise 5.2 — DELETE
```sql
-- Q1: Delete employees with is_active = FALSE
-- Write here:


-- Q2: Count remaining records
SELECT COUNT(*) FROM employees;
```

---

## Section 6: Virtual Warehouse Operations

### Exercise 6.1 — Warehouse Management
```sql
-- Check current warehouse status
SHOW WAREHOUSES;

-- Suspend the warehouse (do this in a test session)
-- ALTER WAREHOUSE compute_wh SUSPEND;

-- Try to run a query — what happens?
-- SELECT * FROM employees;  -- ERROR: warehouse is suspended

-- Resume the warehouse
-- ALTER WAREHOUSE compute_wh RESUME;

-- Check auto_resume setting
SHOW PARAMETERS LIKE 'AUTO_RESUME' IN WAREHOUSE compute_wh;
```

---

## Section 7: Metadata Queries

### Exercise 7.1 — Information Schema
```sql
-- Q1: List all tables in practice_schema
SELECT table_name, table_type, row_count
FROM practice_db.information_schema.tables
WHERE table_schema = 'PRACTICE_SCHEMA'
  AND table_type = 'BASE TABLE';

-- Q2: Get column details for the employees table
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM practice_db.information_schema.columns
WHERE table_name = 'EMPLOYEES'
  AND table_schema = 'PRACTICE_SCHEMA';

-- Q3: When was the employees table created?
SELECT table_name, created
FROM practice_db.information_schema.tables
WHERE table_name = 'EMPLOYEES';
```

---

## Challenge Questions

1. Create a `projects` table with columns: project_id, project_name, start_date, end_date, budget, lead_emp_id. Then insert 3 sample projects.

2. Write a query to find the employee count and average salary for each department, only for departments with more than 1 employee, sorted by average salary descending.

3. Write a query to find all employees who joined in the year 2022.
   - Hint: Use `YEAR(hire_date) = 2022` or `hire_date BETWEEN '2022-01-01' AND '2022-12-31'`

4. Create a view called `engineering_team` that shows only Engineering department employees with columns: emp_name, salary, hire_date.
   ```sql
   CREATE VIEW engineering_team AS
   SELECT emp_name, salary, hire_date
   FROM employees
   WHERE department = 'Engineering';
   ```

5. Use `GET_DDL` to get the structure of the employees table:
   ```sql
   SELECT GET_DDL('TABLE', 'PRACTICE_DB.PRACTICE_SCHEMA.EMPLOYEES');
   ```

---

## Answer Key (Selected)

**Exercise 1.1**:
```sql
CREATE DATABASE techcorp_db;
USE DATABASE techcorp_db;
CREATE SCHEMA hr_schema;
CREATE SCHEMA sales_schema;
CREATE SCHEMA finance_schema;
```

**Exercise 4.3 — Q4 (Total salary by department)**:
```sql
SELECT department, SUM(salary) AS total_salary, COUNT(*) AS emp_count
FROM employees
GROUP BY department
ORDER BY total_salary DESC;
```

**Exercise 4.3 — Q5 (Departments with avg salary > 70000)**:
```sql
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;
```

**Challenge Q3 (Employees who joined in 2022)**:
```sql
SELECT emp_name, hire_date
FROM employees
WHERE YEAR(hire_date) = 2022;
```
