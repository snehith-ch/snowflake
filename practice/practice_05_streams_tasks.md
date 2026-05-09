# Practice Set 5: Streams, Tasks & Stored Procedures

> **Topics Covered**: Streams (CDC), MERGE statement, Tasks, Scheduling, Stored Procedures, UDFs
> **Related Lectures**: Lecture 16, 17, 18, 19, 20

---

## Background

**Streams** = Change Data Capture (CDC). Tracks INSERT, UPDATE, DELETE changes to a table.
**Tasks** = Scheduled jobs. Like a cron job inside Snowflake.
**Procedures** = Stored reusable SQL logic (written in JavaScript/Python/SQL).
**UDFs** = User-Defined Functions. Custom functions you write and reuse.

---

## Setup

```sql
CREATE DATABASE IF NOT EXISTS cdc_practice_db;
CREATE SCHEMA IF NOT EXISTS cdc_schema;
USE DATABASE cdc_practice_db;
USE SCHEMA cdc_schema;
USE WAREHOUSE compute_wh;

-- Create source and target tables
CREATE TABLE source_customers (
    cust_id    NUMBER,
    cust_name  VARCHAR(100),
    city       VARCHAR(100),
    email      VARCHAR(150)
);

CREATE TABLE target_customers (
    cust_id    NUMBER,
    cust_name  VARCHAR(100),
    city       VARCHAR(100),
    email      VARCHAR(150),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

---

## Section 1: Streams

### Exercise 1.1 — Create a Stream

```sql
-- Create a stream on the source table
CREATE STREAM customer_stream 
    ON TABLE source_customers;

-- Check stream info
SHOW STREAMS;

-- The stream is empty initially
SELECT * FROM customer_stream;
-- Result: 0 rows (no changes yet)
```

**Stream Metadata Columns** (automatically added):
| Column | Description |
|--------|-------------|
| `METADATA$ACTION` | 'INSERT' or 'DELETE' |
| `METADATA$ISUPDATE` | TRUE = part of an UPDATE operation |
| `METADATA$ROW_ID` | Unique row identifier |

---

### Exercise 1.2 — INSERT and Check Stream

```sql
-- Insert data into source
INSERT INTO source_customers VALUES 
(1, 'Priya Sharma',  'Hyderabad',   'priya@email.com'),
(2, 'Rahul Verma',   'Mumbai',      'rahul@email.com'),
(3, 'Anita Patel',   'Bengaluru',   'anita@email.com');

-- Check the stream — should show 3 new records
SELECT * FROM customer_stream;
```

**Expected Output**:
```
CUST_ID  CUST_NAME     CITY        EMAIL                METADATA$ACTION  METADATA$ISUPDATE
1        Priya Sharma  Hyderabad   priya@email.com      INSERT           FALSE
2        Rahul Verma   Mumbai      rahul@email.com      INSERT           FALSE
3        Anita Patel   Bengaluru   anita@email.com      INSERT           FALSE
```

---

### Exercise 1.3 — UPDATE and Check Stream

```sql
-- Update a record
UPDATE source_customers 
SET city = 'Chennai' 
WHERE cust_id = 2;

-- Check the stream
SELECT * FROM customer_stream;
```

**Expected Output** (UPDATE shows 2 records — old and new):
```
CUST_ID  CUST_NAME   CITY       ACTION   ISUPDATE
2        Rahul Verma Mumbai     DELETE   TRUE     ← Old record (being deleted)
2        Rahul Verma Chennai    INSERT   TRUE     ← New record (being inserted)
```

**Key Concept**: UPDATE = DELETE old record + INSERT new record in the stream.
- Old record: `METADATA$ACTION = 'DELETE'`, `METADATA$ISUPDATE = TRUE`
- New record: `METADATA$ACTION = 'INSERT'`, `METADATA$ISUPDATE = TRUE`

---

### Exercise 1.4 — DELETE and Check Stream

```sql
-- Delete a record
DELETE FROM source_customers WHERE cust_id = 3;

-- Check stream
SELECT * FROM customer_stream;
```

**Expected Output**:
```
CUST_ID  CUST_NAME     ACTION   ISUPDATE
3        Anita Patel   DELETE   FALSE
```

---

## Section 2: MERGE Statement (Consuming the Stream)

### Exercise 2.1 — Basic MERGE

The MERGE statement reads from the stream and applies changes to the target table:

```sql
-- MERGE stream data into target table
MERGE INTO target_customers AS tgt
USING customer_stream AS src
ON tgt.cust_id = src.cust_id

-- When matching record exists and action is DELETE
WHEN MATCHED AND src.METADATA$ACTION = 'DELETE' AND src.METADATA$ISUPDATE = FALSE
    THEN DELETE

-- When matching record exists and action is INSERT (update case)
WHEN MATCHED AND src.METADATA$ACTION = 'INSERT' AND src.METADATA$ISUPDATE = TRUE
    THEN UPDATE SET
        tgt.cust_name = src.cust_name,
        tgt.city = src.city,
        tgt.email = src.email,
        tgt.last_updated = CURRENT_TIMESTAMP()

-- When no matching record (new insert)
WHEN NOT MATCHED AND src.METADATA$ACTION = 'INSERT'
    THEN INSERT (cust_id, cust_name, city, email)
    VALUES (src.cust_id, src.cust_name, src.city, src.email);
```

---

### Exercise 2.2 — Verify the Stream is Consumed

```sql
-- After MERGE, check the stream
SELECT * FROM customer_stream;
-- Result: 0 rows (stream is consumed/empty)

-- Check the target table
SELECT * FROM target_customers;
-- Should have the merged data
```

**Important**: A stream is consumed (emptied) only when:
1. A DML operation (INSERT/UPDATE/DELETE) is performed on a table using the stream data
2. Typically done via MERGE, INSERT INTO ... SELECT FROM stream

---

### Exercise 2.3 — Append-Only Stream

```sql
-- An append-only stream ONLY captures INSERT operations (ignores UPDATE/DELETE)
CREATE STREAM insert_only_stream
    ON TABLE source_customers
    APPEND_ONLY = TRUE;

-- Now insert new data
INSERT INTO source_customers VALUES (4, 'Deepika Singh', 'Delhi', 'deepika@email.com');

-- Check — should show INSERT
SELECT * FROM insert_only_stream;

-- Now update
UPDATE source_customers SET city = 'Pune' WHERE cust_id = 4;

-- Check — should show NOTHING (append-only ignores updates)
SELECT * FROM insert_only_stream;
```

---

## Section 3: Tasks

### Exercise 3.1 — Create a Scheduled Task

```sql
-- Create a task that runs every 1 minute
CREATE TASK sync_customers_task
    WAREHOUSE = compute_wh
    SCHEDULE = '1 MINUTE'
AS
MERGE INTO target_customers AS tgt
USING customer_stream AS src
ON tgt.cust_id = src.cust_id
WHEN MATCHED AND src.METADATA$ACTION = 'DELETE' AND NOT src.METADATA$ISUPDATE
    THEN DELETE
WHEN MATCHED AND src.METADATA$ACTION = 'INSERT' AND src.METADATA$ISUPDATE
    THEN UPDATE SET tgt.cust_name = src.cust_name, tgt.city = src.city, tgt.email = src.email
WHEN NOT MATCHED AND src.METADATA$ACTION = 'INSERT'
    THEN INSERT (cust_id, cust_name, city, email) 
    VALUES (src.cust_id, src.cust_name, src.city, src.email);
```

---

### Exercise 3.2 — Task Management

```sql
-- By default, tasks are SUSPENDED. You must RESUME them.
ALTER TASK sync_customers_task RESUME;

-- Check tasks
SHOW TASKS;

-- Suspend a task
ALTER TASK sync_customers_task SUSPEND;

-- Execute a task manually (don't wait for schedule)
EXECUTE TASK sync_customers_task;

-- View task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'SYNC_CUSTOMERS_TASK'
));
```

---

### Exercise 3.3 — CRON Scheduling

```sql
-- Use CRON syntax for specific scheduling
-- Format: 'USING CRON <min> <hour> <day-of-month> <month> <day-of-week> <timezone>'

-- Run every day at midnight UTC
CREATE TASK daily_task
    WAREHOUSE = compute_wh
    SCHEDULE = 'USING CRON 0 0 * * * UTC'
AS
    INSERT INTO audit_log VALUES (CURRENT_TIMESTAMP(), 'Daily task ran');

-- Run every Monday at 9 AM India time
CREATE TASK weekly_report_task
    WAREHOUSE = compute_wh
    SCHEDULE = 'USING CRON 0 9 * * 1 Asia/Kolkata'
AS
    INSERT INTO audit_log VALUES (CURRENT_TIMESTAMP(), 'Weekly report generated');

-- CRON Reference:
-- * = every
-- 0-59 for minutes
-- 0-23 for hours  
-- 1-31 for day of month
-- 1-12 for month
-- 0-6 for day of week (0 = Sunday)
```

---

### Exercise 3.4 — Task Dependencies

```sql
-- Create a parent task
CREATE TASK parent_task
    WAREHOUSE = compute_wh
    SCHEDULE = '5 MINUTE'
AS
    INSERT INTO process_log VALUES (CURRENT_TIMESTAMP(), 'Parent task started');

-- Create a child task that runs AFTER parent
CREATE TASK child_task
    WAREHOUSE = compute_wh
    AFTER parent_task    -- This task runs only after parent_task completes
AS
    INSERT INTO process_log VALUES (CURRENT_TIMESTAMP(), 'Child task completed');

-- Find all tasks that depend on parent_task
SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('parent_task');
```

---

## Section 4: Stored Procedures

### Exercise 4.1 — Create a Simple Procedure

```sql
-- Simple procedure that returns a message
CREATE OR REPLACE PROCEDURE greet_user(user_name VARCHAR)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
AS
$$
    return 'Hello, ' + USER_NAME + '! Welcome to Snowflake.';
$$;

-- Call the procedure
CALL greet_user('Priya');
-- Returns: 'Hello, Priya! Welcome to Snowflake.'
```

---

### Exercise 4.2 — Procedure with SQL Execution

```sql
-- Procedure that updates salary
CREATE OR REPLACE PROCEDURE update_salary(emp_id_param NUMBER, increment_pct NUMBER)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
AS
$$
    var sql = `UPDATE employees 
               SET salary = salary * (1 + ${INCREMENT_PCT}/100) 
               WHERE emp_id = ${EMP_ID_PARAM}`;
    
    var stmt = snowflake.execute({sqlText: sql});
    
    return 'Salary updated for employee ' + EMP_ID_PARAM;
$$;

-- Call with parameters
CALL update_salary(1, 10);   -- Give 10% raise to employee 1
```

---

### Exercise 4.3 — Procedure with Loop (Cursor)

```sql
-- Procedure that processes multiple rows
CREATE OR REPLACE PROCEDURE give_raise_to_dept(dept_name VARCHAR, pct NUMBER)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
AS
$$
    var updated_count = 0;
    
    // Get all employees in department
    var stmt = snowflake.execute({
        sqlText: `SELECT emp_id FROM employees WHERE department = '${DEPT_NAME}'`
    });
    
    // Loop through each employee and update
    while (stmt.next()) {
        var emp_id = stmt.getColumnValue(1);
        snowflake.execute({
            sqlText: `UPDATE employees SET salary = salary * (1 + ${PCT}/100) WHERE emp_id = ${emp_id}`
        });
        updated_count++;
    }
    
    return 'Updated ' + updated_count + ' employees in ' + DEPT_NAME;
$$;

-- Call it
CALL give_raise_to_dept('Engineering', 15);
```

---

## Section 5: User-Defined Functions (UDFs)

### Exercise 5.1 — Create a SQL UDF

```sql
-- Simple function that calculates annual salary
CREATE OR REPLACE FUNCTION annual_salary(monthly_sal NUMBER)
    RETURNS NUMBER
AS
$$
    monthly_sal * 12
$$;

-- Use the function in a query
SELECT emp_name, salary AS monthly_salary, annual_salary(salary) AS yearly_salary
FROM employees;
```

---

### Exercise 5.2 — Create a JavaScript UDF

```sql
-- Function to mask sensitive data
CREATE OR REPLACE FUNCTION mask_email(email VARCHAR)
    RETURNS VARCHAR
    LANGUAGE JAVASCRIPT
AS
$$
    if (EMAIL === null) return null;
    var parts = EMAIL.split('@');
    if (parts.length !== 2) return EMAIL;
    var masked = parts[0].substring(0, 2) + '****@' + parts[1];
    return masked;
$$;

-- Test it
SELECT email, mask_email(email) AS masked_email
FROM employees;
-- priya@techcorp.com → pr****@techcorp.com
```

---

### Exercise 5.3 — Check Existing UDFs

```sql
-- List all user-defined functions
SELECT function_name, argument_signature, data_type, body
FROM information_schema.functions
WHERE function_type = 'FUNCTION';
```

---

## Challenge Questions

1. Create a stream on the `products` table (from data files). Write a MERGE statement to sync changes to a `products_archive` table.

2. Create a task that runs every 5 minutes and:
   - Inserts the current timestamp and row count of `source_customers` into an `activity_log` table
   - Use `SCHEDULE = '5 MINUTE'`

3. Write a stored procedure `get_dept_stats(dept_name VARCHAR)` that returns a string like:
   `"Engineering: 4 employees, avg salary 87500"`

4. What is the difference between a **Standard Stream** and an **Append-Only Stream**?
   - Standard: _______________
   - Append-Only: _______________

5. If a stream has pending changes but no one consumes it, what happens after the table's `DATA_RETENTION_TIME_IN_DAYS` expires?
   - Answer: _______________

## Answer Key

**Challenge Q4**:
- Standard Stream: Captures ALL changes — INSERT, UPDATE, DELETE
- Append-Only Stream: Captures ONLY INSERT operations (ignores UPDATE and DELETE)

**Challenge Q5**:
- The stream becomes "stale" — the historical data needed to compute the changes has been purged. You'll get an error when trying to consume it.
