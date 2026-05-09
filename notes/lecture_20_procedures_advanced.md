# Lecture 20: Stored Procedures — Advanced Topics (Cursors, Exceptions, Execute As)

---

## Table of Contents
1. [Recap — Procedure Basics](#1-recap--procedure-basics)
2. [GET_DDL for Tables and Procedures](#2-get_ddl-for-tables-and-procedures)
3. [Cursor Refresher](#3-cursor-refresher)
4. [Net Salary Update with Cursor](#4-net-salary-update-with-cursor)
5. [EXECUTE AS OWNER vs EXECUTE AS CALLER](#5-execute-as-owner-vs-execute-as-caller)
6. [Exception Handling](#6-exception-handling)
7. [Exception Types](#7-exception-types)
8. [User-Defined Exceptions](#8-user-defined-exceptions)
9. [INFORMATION_SCHEMA.PROCEDURES](#9-information_schemaprocedures)
10. [Key Commands Reference](#10-key-commands-reference)
11. [Key Terms](#11-key-terms)
12. [Summary](#12-summary)

---

## 1. Recap — Procedure Basics

Key points from previous lectures:

```sql
-- Procedure structure
CREATE OR REPLACE PROCEDURE proc_name(param_name TYPE)
RETURNS RETURN_TYPE
LANGUAGE SQL
AS
$$
DECLARE
  var_name TYPE;      -- Declare variables here
BEGIN
  -- Main logic
  SELECT col INTO :var_name FROM table WHERE key = :param_name;
  var_name := :var_name + 100;  -- Assign with :=
  RETURN :var_name;
END;
$$;

-- Call a procedure
CALL proc_name(argument);
```

---

## 2. GET_DDL for Tables and Procedures

### GET_DDL for a Table

```sql
-- View the CREATE TABLE statement for any table
SELECT GET_DDL('table', 'emp');
```

**Output:**
```sql
CREATE OR REPLACE TABLE EMP (
  EMP_NO NUMBER(38,0),
  EMP_NAME VARCHAR(50),
  JOB VARCHAR(20),
  MGR NUMBER(38,0),
  HIRE_DATE DATE,
  SALARY NUMBER(38,0),
  COMMISSION NUMBER(38,0),
  DEPT_NO NUMBER(38,0),
  DATE_OF_EXIT DATE,
  GRATUITY NUMBER(38,0)
);
```

### GET_DDL for a Procedure

```sql
-- You must specify the parameter data type in the second argument
SELECT GET_DDL('procedure', 'pr_emp_info(NUMBER)');
```

**Important:** The parameter data type must be included. If you have multiple parameters, include all of them:

```sql
SELECT GET_DDL('procedure', 'proc_with_two_params(NUMBER, VARCHAR)');
```

### What GET_DDL Reveals

When you view a procedure's DDL, you may notice a keyword you didn't explicitly add:

```sql
CREATE OR REPLACE PROCEDURE PR_EMP_INFO (P_DEPT_NO NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER    ← This was added by default!
AS
$$...$$;
```

The `EXECUTE AS OWNER` clause is automatically added by Snowflake. This has significant security implications.

---

## 3. Cursor Refresher

### Why Cursors Are Needed

```sql
-- This fails if dept_no = 10 has multiple employees:
SELECT emp_no, emp_name, salary
INTO :v_emp_no, :v_emp_name, :v_salary
FROM emp
WHERE dept_no = :p_dept_no;
-- Error: SELECT INTO statement expects exactly one row, but got 3
```

Cursors solve this by letting you process **one row at a time** in a loop.

### Cursor Pattern

```sql
DECLARE
  c1 CURSOR FOR SELECT col1, col2 FROM table WHERE key = ?;
  v_col1 TYPE;
  v_col2 TYPE;

BEGIN
  OPEN c1 USING (:p_param);    -- Pass parameters here

  FOR i IN c1 LOOP
    v_col1 := i.col1;          -- Access using i.column_name
    v_col2 := i.col2;
    -- do something with v_col1, v_col2
  END LOOP;

  RETURN 'done';
END;
```

---

## 4. Net Salary Update with Cursor

### Setup

```sql
-- Add net_salary column to emp table
ALTER TABLE emp ADD COLUMN net_salary NUMBER;
```

### Procedure to Update Net Salary by Department

```sql
CREATE OR REPLACE PROCEDURE pr_emp_info(
  p_dept_no  NUMBER
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
  c1 CURSOR FOR
    SELECT emp_no, emp_name, salary, commission
    FROM emp
    WHERE dept_no = ?;

  v_emp_no     NUMBER;
  v_emp_name   VARCHAR;
  v_salary     NUMBER;
  v_commission NUMBER;
  v_net        NUMBER;

BEGIN
  OPEN c1 USING (:p_dept_no);

  FOR i IN c1 LOOP
    v_emp_no     := i.emp_no;
    v_emp_name   := i.emp_name;
    v_salary     := i.salary;
    v_commission := i.commission;

    -- Calculate net salary (salary + NVL of commission)
    v_net := NVL(:v_salary, 0) + NVL(:v_commission, 0);

    -- Update the net_salary column
    UPDATE emp
    SET net_salary = :v_net
    WHERE emp_no = :v_emp_no;

  END LOOP;

  RETURN 'Procedure completed successfully';
END;
$$;
```

### Testing

```sql
-- Verify net_salary is null before calling
SELECT emp_no, salary, commission, net_salary FROM emp WHERE dept_no = 10;

-- Call for department 10
CALL pr_emp_info(10);

-- Verify net_salary is updated
SELECT emp_no, salary, commission, net_salary FROM emp WHERE dept_no = 10;
-- e.g., salary=1300, commission=NULL → net_salary=1300
-- e.g., salary=1600, commission=300 → net_salary=1900

-- Call for other departments
CALL pr_emp_info(20);
CALL pr_emp_info(30);
```

---

## 5. EXECUTE AS OWNER vs EXECUTE AS CALLER

This is one of the most important and frequently asked security concepts in Snowflake procedures.

### EXECUTE AS OWNER (Default)

```sql
-- Default — automatically added even if you don't specify it
CREATE OR REPLACE PROCEDURE pr_emp_info(p_dept_no NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER  -- Default behavior
AS
$$...$$;
```

**What it means:**
- When **any role** calls this procedure, it runs with the **owner's privileges**.
- The caller does **NOT** need privileges on the underlying tables.
- Perfect for cases where you want controlled access (e.g., let a restricted user update data they can't directly access).

### EXECUTE AS CALLER

```sql
CREATE OR REPLACE PROCEDURE proc_caller_example(p_dept_no NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER  -- Must explicitly specify
AS
$$...$$;
```

**What it means:**
- The procedure runs with **the caller's privileges**.
- The caller must have proper privileges on all objects used inside the procedure.
- If the caller lacks SELECT, INSERT, UPDATE, etc. — the procedure fails.

### Demonstration

```sql
-- Setup: Create a restricted user
CREATE USER bob PASSWORD = 'password123';
CREATE ROLE marketing_role;
GRANT ROLE marketing_role TO USER bob;

-- Grant access to warehouse, database, schema
GRANT USAGE ON WAREHOUSE dev_warehouse TO ROLE marketing_role;
GRANT USAGE ON DATABASE dev_db TO ROLE marketing_role;
GRANT USAGE ON SCHEMA dev_schema TO ROLE marketing_role;

-- Create the procedure (EXECUTE AS OWNER by default)
CREATE OR REPLACE PROCEDURE pr_emp_info(p_dept_no NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
AS $$...$$;  -- EXECUTE AS OWNER by default

-- Grant procedure access to marketing role
GRANT USAGE ON PROCEDURE pr_emp_info(NUMBER) TO ROLE marketing_role;
```

### Test as Bob (marketing_role)

```sql
-- Bob does NOT have SELECT on emp table
SELECT * FROM emp;  -- Error: Insufficient privileges!

-- But Bob CAN call the procedure successfully:
CALL pr_emp_info(10);  -- Works! Uses owner's privileges
```

### EXECUTE AS CALLER Example

```sql
-- Create procedure with EXECUTE AS CALLER
CREATE OR REPLACE PROCEDURE proc_caller(p_dept_no NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS $$
DECLARE
  c1 CURSOR FOR SELECT emp_no, salary FROM emp WHERE dept_no = ?;
  v_emp_no NUMBER;
  v_salary NUMBER;
  v_net NUMBER;
BEGIN
  OPEN c1 USING (:p_dept_no);
  FOR i IN c1 LOOP
    v_emp_no := i.emp_no;
    v_salary := i.salary;
    v_net := NVL(:v_salary, 0) + 500;
    UPDATE emp SET net_salary = :v_net WHERE emp_no = :v_emp_no;
  END LOOP;
  RETURN 'Done';
END;
$$;

-- Grant procedure to marketing role
GRANT USAGE ON PROCEDURE proc_caller(NUMBER) TO ROLE marketing_role;
```

### Bob tries to call CALLER procedure without privileges

```sql
-- As Bob (marketing_role):
CALL proc_caller(10);
-- Error: Object 'EMP' does not exist or not authorized
```

### Granting required privileges to Bob

```sql
-- Grant SELECT on emp
GRANT SELECT ON TABLE emp TO ROLE marketing_role;
-- Call again:
CALL proc_caller(10);
-- Error: Insufficient privileges to UPDATE table EMP

-- Grant UPDATE too:
GRANT UPDATE ON TABLE emp TO ROLE marketing_role;
-- Call again:
CALL proc_caller(10);
-- Now succeeds!
```

### Summary Table

| | EXECUTE AS OWNER | EXECUTE AS CALLER |
|--|-----------------|-------------------|
| Runs with | **Owner's** privileges | **Caller's** privileges |
| Caller needs object privileges? | No | Yes |
| Default? | Yes | No (must specify) |
| Use case | Controlled access to sensitive data | User-specific access control |

---

## 6. Exception Handling

The `EXCEPTION` block catches runtime errors and allows graceful error handling.

### Exception Block Syntax

```sql
BEGIN
  -- Main logic

EXCEPTION
  WHEN STATEMENT_ERROR THEN
    RETURN SQLCODE || ': ' || SQLERRM;

  WHEN EXPRESSION_ERROR THEN
    RETURN SQLCODE || ': ' || SQLERRM;

  WHEN OTHER THEN
    RETURN SQLCODE || ': ' || SQLERRM;
END;
```

### SQLCODE and SQLERRM

- `SQLCODE` — The numeric error code (e.g., `2003`)
- `SQLERRM` — The error message string (e.g., `"Object 'TNS_EMP' does not exist or not authorized"`)

---

## 7. Exception Types

### STATEMENT_ERROR

Triggered by SQL statement failures: object not found, syntax errors, etc.

```sql
CREATE OR REPLACE PROCEDURE exp_1()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
  SELECT * FROM tns_emp;  -- Table doesn't exist!

EXCEPTION
  WHEN STATEMENT_ERROR THEN
    RETURN SQLCODE || ': ' || SQLERRM;
    -- Returns: "002003: Object 'TNS_EMP' does not exist or not authorized"
END;
$$;

CALL exp_1();
-- No error thrown to user — gracefully handled
```

### EXPRESSION_ERROR

Triggered by data type mismatches (e.g., assigning a string to a NUMBER variable).

```sql
CREATE OR REPLACE PROCEDURE exp_2(p_dept_no NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
  v_name NUMBER;  -- Wrong! emp_name is VARCHAR
BEGIN
  SELECT emp_name INTO :v_name FROM emp WHERE dept_no = :p_dept_no;

EXCEPTION
  WHEN EXPRESSION_ERROR THEN
    RETURN SQLCODE || ': ' || SQLERRM;
    -- Returns: "Numeric value 'SMITH' is not recognized"
END;
$$;
```

### OTHER

Catches any exception not explicitly handled:

```sql
EXCEPTION
  WHEN OTHER THEN
    RETURN SQLCODE || ': ' || SQLERRM;
    -- Handles all exception types
```

---

## 8. User-Defined Exceptions

When your business rules define an error condition (not an actual SQL error), you can create custom exceptions.

### Business Scenario

If an employee's salary is less than 1000, raise a custom error.

```sql
CREATE OR REPLACE PROCEDURE exp_4(p_emp_no NUMBER)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
  -- Declare a custom exception
  exc_salary EXCEPTION (-20002, 'Employee salary is less than 1000');

  v_emp_name   VARCHAR;
  v_salary     NUMBER;
  v_commission NUMBER;

BEGIN
  SELECT emp_name, salary, commission
  INTO :v_emp_name, :v_salary, :v_commission
  FROM emp
  WHERE emp_no = :p_emp_no;

  -- Check business rule
  IF :v_salary < 1000 THEN
    RAISE exc_salary;  -- Raise the custom exception
  END IF;

  RETURN 'Salary is valid: ' || :v_salary;

EXCEPTION
  WHEN exc_salary THEN
    RETURN SQLCODE || ': ' || SQLERRM;
    -- Returns: "-20002: Employee salary is less than 1000"
END;
$$;
```

### Testing

```sql
-- Employee with salary < 1000:
CALL exp_4(7369);  -- Returns: "-20002: Employee salary is less than 1000"

-- Employee with salary >= 1000:
CALL exp_4(7902);  -- Returns: "Salary is valid: 100000"
```

### Exception Code Range

User-defined exception codes must be between **-20000 and -20999**.

```sql
-- Valid range:
exc_name EXCEPTION (-20000, 'Custom error message');
exc_name EXCEPTION (-20999, 'Another custom error');

-- Cannot use: -19999 or below / -21000 or above (reserved by Snowflake/Oracle convention)
```

---

## 9. INFORMATION_SCHEMA.PROCEDURES

```sql
SELECT
  procedure_name,
  argument_signature,
  data_type,
  procedure_definition,
  procedure_owner
FROM information_schema.procedures
ORDER BY procedure_name;
```

**Key columns:**
| Column | Description |
|--------|-------------|
| `PROCEDURE_NAME` | Name of the procedure |
| `ARGUMENT_SIGNATURE` | Parameter types, e.g., `(NUMBER)` |
| `DATA_TYPE` | Return type |
| `PROCEDURE_DEFINITION` | The SQL code body |
| `PROCEDURE_OWNER` | Role that owns the procedure |

---

## 10. Key Commands Reference

```sql
-- Create procedure with EXECUTE AS OWNER (default)
CREATE OR REPLACE PROCEDURE proc_name(param TYPE)
RETURNS VARCHAR
LANGUAGE SQL
AS $$...$$;

-- Create procedure with EXECUTE AS CALLER
CREATE OR REPLACE PROCEDURE proc_name(param TYPE)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS $$...$$;

-- Call a procedure
CALL proc_name(arg);

-- Get procedure DDL
SELECT GET_DDL('procedure', 'proc_name(NUMBER)');
SELECT GET_DDL('table', 'table_name');

-- View procedures
SELECT * FROM information_schema.procedures;

-- Grant procedure access
GRANT USAGE ON PROCEDURE proc_name(NUMBER) TO ROLE role_name;

-- Grant table access
GRANT SELECT ON TABLE table_name TO ROLE role_name;
GRANT UPDATE ON TABLE table_name TO ROLE role_name;

-- Exception handling template
EXCEPTION
  WHEN STATEMENT_ERROR THEN RETURN SQLCODE || ': ' || SQLERRM;
  WHEN EXPRESSION_ERROR THEN RETURN SQLCODE || ': ' || SQLERRM;
  WHEN OTHER THEN RETURN SQLCODE || ': ' || SQLERRM;

-- Declare user-defined exception
exc_name EXCEPTION (-20001, 'Custom error message');
RAISE exc_name;  -- Trigger the exception

-- Add column to table
ALTER TABLE emp ADD COLUMN net_salary NUMBER;
```

---

## 11. Key Terms

| Term | Definition |
|------|------------|
| **GET_DDL** | Function to retrieve the CREATE statement of any object |
| **EXECUTE AS OWNER** | Procedure runs with the owner's privileges (default) |
| **EXECUTE AS CALLER** | Procedure runs with the caller's privileges |
| **EXCEPTION block** | Optional section that catches and handles runtime errors |
| **STATEMENT_ERROR** | Exception for SQL failures (object not found, etc.) |
| **EXPRESSION_ERROR** | Exception for data type mismatches |
| **OTHER** | Catch-all exception handler |
| **SQLCODE** | Numeric error code in an exception handler |
| **SQLERRM** | Error message string in an exception handler |
| **RAISE** | Keyword to trigger an exception in a procedure |
| **User-Defined Exception** | Custom exception with code -20000 to -20999 |
| **Cursor** | Processes query results one row at a time |
| **OPEN ... USING** | Opens a parameterized cursor and passes arguments |

---

## 12. Summary

- `GET_DDL('procedure', 'proc_name(TYPE)')` retrieves the full procedure code, including the `EXECUTE AS` clause.
- By default, all procedures are created with `EXECUTE AS OWNER`, meaning any user who can call the procedure runs it with the **owner's privileges** — no need to grant table-level access.
- `EXECUTE AS CALLER` requires the calling user to have all necessary privileges on underlying objects.
- **Exception handling** uses `WHEN STATEMENT_ERROR`, `WHEN EXPRESSION_ERROR`, and `WHEN OTHER` to catch runtime errors gracefully.
- Use `SQLCODE` and `SQLERRM` to get error codes and messages inside exception handlers.
- **User-defined exceptions** allow you to enforce custom business rules (e.g., salary < 1000) with custom error codes in the range -20000 to -20999.
- **Cursors** are essential when `SELECT INTO` would return multiple rows — they process each row in a `FOR i IN cursor LOOP`.
- For parameterized cursors, use `?` as a placeholder and pass the value with `OPEN cursor USING (:param)`.
