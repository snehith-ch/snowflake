# Practice Set 4: Semi-Structured Data — JSON, XML, Parquet

> **Topics Covered**: VARIANT data type, JSON querying, LATERAL FLATTEN, XML processing, Parquet
> **Related Lectures**: Lecture 5, 6, 7, 8, 9

---

## Background

Semi-structured data does NOT have a fixed schema like a table. Examples:
- **JSON**: `{"name": "Alice", "scores": [90, 85, 78]}`
- **XML**: `<employee><name>Alice</name></employee>`
- **Parquet**: Binary columnar format

Snowflake's **VARIANT** data type stores any semi-structured data.

---

## Setup

```sql
CREATE DATABASE IF NOT EXISTS semi_practice_db;
CREATE SCHEMA IF NOT EXISTS semi_schema;
USE DATABASE semi_practice_db;
USE SCHEMA semi_schema;
USE WAREHOUSE compute_wh;
```

---

## Section 1: VARIANT Data Type

### Exercise 1.1 — Creating Tables with VARIANT

```sql
-- A table with a VARIANT column
CREATE TABLE employee_json (
    emp_id   NUMBER AUTOINCREMENT,
    raw_data VARIANT
);

-- Insert JSON directly using PARSE_JSON function
INSERT INTO employee_json (raw_data)
SELECT PARSE_JSON('{"name": "Priya Sharma", "dept": "Engineering", "salary": 85000, "skills": ["Python", "SQL", "Snowflake"]}');

INSERT INTO employee_json (raw_data)
SELECT PARSE_JSON('{"name": "Rahul Verma", "dept": "Marketing", "salary": 65000, "skills": ["Excel", "PowerBI"]}');

INSERT INTO employee_json (raw_data)
SELECT PARSE_JSON('{"name": "Anita Patel", "dept": "Finance", "salary": 72000, "skills": ["SAP", "SQL"]}');

-- View the data
SELECT * FROM employee_json;
```

---

## Section 2: Querying JSON Data

### Exercise 2.1 — Extracting JSON Fields

Snowflake uses **colon (`:`) notation** to access JSON keys:

```sql
-- Extract specific fields from VARIANT
SELECT 
    raw_data:name::VARCHAR    AS emp_name,
    raw_data:dept::VARCHAR    AS department,
    raw_data:salary::NUMBER   AS salary
FROM employee_json;
```

**Explanation**:
- `raw_data:name` → access the `name` key in the JSON
- `::VARCHAR` → cast to VARCHAR (CAST operator)
- Without the cast, Snowflake returns the value in its JSON format

---

### Exercise 2.2 — Nested JSON Access

```sql
-- Insert an employee with nested address
INSERT INTO employee_json (raw_data)
SELECT PARSE_JSON('{
    "name": "Suresh Kumar",
    "dept": "Engineering",
    "salary": 90000,
    "address": {
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500001"
    },
    "skills": ["Java", "AWS", "Snowflake"]
}');

-- Access nested field (address.city)
SELECT 
    raw_data:name::VARCHAR                AS emp_name,
    raw_data:address:city::VARCHAR        AS city,
    raw_data:address:state::VARCHAR       AS state
FROM employee_json;
```

---

### Exercise 2.3 — Casting Practice

Try these casts:

```sql
SELECT 
    raw_data:salary::NUMBER         AS salary_num,
    raw_data:salary::VARCHAR        AS salary_str,
    raw_data:name::VARCHAR          AS name,
    -- Equivalent using CAST() function:
    CAST(raw_data:salary AS NUMBER) AS salary_cast
FROM employee_json;
```

**Question**: What happens if you try `raw_data:salary::DATE`?
- Answer: _______________

---

## Section 3: Arrays in JSON (LATERAL FLATTEN)

### Exercise 3.1 — Understanding FLATTEN

The `skills` field is an **array**: `["Python", "SQL", "Snowflake"]`

To work with arrays, use **LATERAL FLATTEN**:

```sql
-- FLATTEN the skills array — creates one row per skill
SELECT 
    emp_id,
    raw_data:name::VARCHAR  AS emp_name,
    f.value::VARCHAR        AS skill
FROM employee_json,
LATERAL FLATTEN(INPUT => raw_data:skills) f;
```

**Output** (example):
```
EMP_ID  EMP_NAME       SKILL
1       Priya Sharma   Python
1       Priya Sharma   SQL
1       Priya Sharma   Snowflake
2       Rahul Verma    Excel
2       Rahul Verma    PowerBI
```

Each skill becomes its own row!

---

### Exercise 3.2 — FLATTEN with Additional Info

```sql
-- Get the skill AND its position in the array
SELECT 
    raw_data:name::VARCHAR  AS emp_name,
    f.index                 AS skill_position,
    f.value::VARCHAR        AS skill
FROM employee_json,
LATERAL FLATTEN(INPUT => raw_data:skills) f
ORDER BY emp_name, skill_position;
```

**FLATTEN Output Columns**:
| Column | Description |
|--------|-------------|
| `f.value` | The value in the array |
| `f.index` | Position in the array (0-based) |
| `f.key` | Key name (for objects) |
| `f.path` | Full path to the element |
| `f.this` | The element being flattened |

---

### Exercise 3.3 — Count Skills per Employee

```sql
-- Using ARRAY_SIZE to count elements
SELECT 
    raw_data:name::VARCHAR       AS emp_name,
    ARRAY_SIZE(raw_data:skills)  AS skill_count
FROM employee_json;

-- Find employees with more than 2 skills
SELECT raw_data:name::VARCHAR AS emp_name
FROM employee_json
WHERE ARRAY_SIZE(raw_data:skills) > 2;
```

---

## Section 4: Creating a Structured View from JSON

### Exercise 4.1 — Normalize JSON to Table

```sql
-- Create a view that flattens JSON to a regular table structure
CREATE VIEW employee_view AS
SELECT 
    emp_id,
    raw_data:name::VARCHAR      AS emp_name,
    raw_data:dept::VARCHAR      AS department,
    raw_data:salary::NUMBER     AS salary,
    raw_data:address:city::VARCHAR AS city
FROM employee_json;

-- Query the view like a regular table
SELECT * FROM employee_view WHERE department = 'Engineering';
```

---

### Exercise 4.2 — Insert Parsed JSON into a Structured Table

```sql
-- Create a structured target table
CREATE TABLE employees_structured (
    emp_id      NUMBER,
    emp_name    VARCHAR(100),
    department  VARCHAR(50),
    salary      NUMBER(10,2),
    city        VARCHAR(100)
);

-- Copy data from JSON table to structured table
INSERT INTO employees_structured
SELECT 
    emp_id,
    raw_data:name::VARCHAR,
    raw_data:dept::VARCHAR,
    raw_data:salary::NUMBER,
    raw_data:address:city::VARCHAR
FROM employee_json
WHERE raw_data:address IS NOT NULL;

-- Verify
SELECT * FROM employees_structured;
```

---

## Section 5: JSON Array of Objects

### Exercise 5.1 — Object Arrays

```sql
CREATE TABLE orders_json (
    order_id NUMBER AUTOINCREMENT,
    raw_data VARIANT
);

-- Insert order with multiple items (array of objects)
INSERT INTO orders_json (raw_data)
SELECT PARSE_JSON('{
    "order_date": "2024-01-15",
    "customer": "Priya Sharma",
    "items": [
        {"product": "Laptop",  "qty": 1, "price": 75000},
        {"product": "Mouse",   "qty": 2, "price": 1500},
        {"product": "Keyboard","qty": 1, "price": 3000}
    ],
    "total": 81000
}');

-- Flatten the items array to get one row per item
SELECT 
    order_id,
    raw_data:customer::VARCHAR      AS customer,
    raw_data:order_date::DATE       AS order_date,
    f.value:product::VARCHAR        AS product,
    f.value:qty::NUMBER             AS qty,
    f.value:price::NUMBER           AS price
FROM orders_json,
LATERAL FLATTEN(INPUT => raw_data:items) f;
```

**Output**:
```
ORDER_ID  CUSTOMER       ORDER_DATE  PRODUCT   QTY  PRICE
1         Priya Sharma   2024-01-15  Laptop    1    75000
1         Priya Sharma   2024-01-15  Mouse     2    1500
1         Priya Sharma   2024-01-15  Keyboard  1    3000
```

---

## Section 6: XML Data (Overview)

### Exercise 6.1 — XML Structure

XML uses tags: `<tag>value</tag>`

```xml
<ROWSET>
    <ROW>
        <emp_id>1</emp_id>
        <emp_name>Priya Sharma</emp_name>
        <department>Engineering</department>
    </ROW>
    <ROW>
        <emp_id>2</emp_id>
        <emp_name>Rahul Verma</emp_name>
        <department>Marketing</department>
    </ROW>
</ROWSET>
```

When loaded into Snowflake (VARIANT), XML data is queried using `$` notation:

```sql
-- Insert sample XML
INSERT INTO xml_staging (raw_data)
SELECT PARSE_XML('<ROW><emp_id>1</emp_id><emp_name>Priya Sharma</emp_name></ROW>');

-- Query XML fields
SELECT 
    GET(raw_data, 'emp_id')::NUMBER   AS emp_id,
    GET(raw_data, 'emp_name')::VARCHAR AS emp_name
FROM xml_staging;
```

---

## Section 7: Useful VARIANT Functions

```sql
-- Check if a key exists in JSON
SELECT 
    raw_data:name::VARCHAR,
    (raw_data:address IS NOT NULL) AS has_address
FROM employee_json;

-- Get all keys from a JSON object
SELECT OBJECT_KEYS(raw_data) AS all_keys
FROM employee_json;

-- Check data type of a JSON value
SELECT TYPEOF(raw_data:salary) AS salary_type  -- Returns 'INTEGER' or 'DECIMAL' etc.
FROM employee_json;

-- Combine multiple JSON objects
SELECT OBJECT_CONSTRUCT(
    'name', raw_data:name,
    'dept', raw_data:dept
) AS simplified_json
FROM employee_json;

-- Convert array to string
SELECT ARRAY_TO_STRING(raw_data:skills, ', ') AS skills_csv
FROM employee_json;
```

---

## Challenge Questions

1. Write a query that returns each employee's name and all their skills as a comma-separated string.
   - Hint: Use `LATERAL FLATTEN` then `LISTAGG` or use `ARRAY_TO_STRING`

2. Write a query to find employees who have 'SQL' in their skills array.
   - Hint: Use `ARRAY_CONTAINS('SQL'::VARIANT, raw_data:skills)`

3. Create a new JSON record for an employee with:
   - name: Your name
   - dept: "Data Engineering"
   - salary: 80000
   - skills: ["Snowflake", "Python", "dbt"]
   - address: { city: "Bengaluru", state: "Karnataka" }
   
   Insert it and verify you can query all fields.

4. What is the difference between `$1:key_name` (stage notation) and `column_name:key_name` (table notation)?
   - Answer: _______________

## Answer Key

**Challenge Q1 (ARRAY_TO_STRING)**:
```sql
SELECT 
    raw_data:name::VARCHAR                         AS emp_name,
    ARRAY_TO_STRING(raw_data:skills, ', ')         AS all_skills
FROM employee_json;
```

**Challenge Q2 (Check if skill exists)**:
```sql
SELECT raw_data:name::VARCHAR AS emp_name
FROM employee_json
WHERE ARRAY_CONTAINS('SQL'::VARIANT, raw_data:skills);
```

**Challenge Q4 Answer**:
- `$1:key_name` is used when reading directly FROM a stage (file not yet loaded)
- `column_name:key_name` is used when querying a VARIANT column inside a table
