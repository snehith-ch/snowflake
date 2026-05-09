# Lecture 5: COPY Command, Semi-Structured Data, and JSON Basics

---

## 1. Recap: Stages and PUT Command

- A **stage** is a named file storage location in Snowflake
- **Internal stages**: User (`@~`), Table (`@%table`), Named (`@stage_name`)
- `PUT` command (SnowSQL only) uploads files to a stage
- `COPY INTO` loads data from a stage into a table
- A **File Format** describes how to parse a file (CSV, JSON, XML, Parquet)

---

## 2. Review: Creating Named Stages

```sql
CREATE STAGE CSV_STAGE;
CREATE STAGE JSON_STAGE;
CREATE STAGE XML_STAGE;
CREATE STAGE PARQUET_STAGE;
```

Verify:

```sql
SHOW STAGES;
-- or
SELECT * FROM INFORMATION_SCHEMA.STAGES;
```

---

## 3. Uploading Files with SnowSQL (PUT Recap)

```bash
# Connect via SnowSQL
snowsql -a <account_name> -u KRISHNA

# Once connected, navigate to correct database/schema
USE DATABASE SALES_DB;
USE SCHEMA SALES_SCHEMA;

# Upload CSV file
PUT file://C:/files/emp.csv @CSV_STAGE;

# Upload JSON file
PUT file://C:/files/car.json @JSON_STAGE;

# Upload XML file
PUT file://C:/files/books_info.xml @XML_STAGE;

# Upload Parquet file
PUT file://C:/files/mt_cars.parquet @PARQUET_STAGE;
```

After uploading:

```sql
-- Verify files are in each stage
LIST @CSV_STAGE;      -- emp.csv.gz
LIST @JSON_STAGE;     -- car.json.gz
LIST @XML_STAGE;      -- books_info.xml.gz
LIST @PARQUET_STAGE;  -- mt_cars.parquet.gz
```

Note: Files are automatically **gzip-compressed** — the `.gz` extension is added by PUT.

---

## 4. Default File Format Behavior

> By default, when you create any stage, Snowflake treats **all files inside it as CSV**, regardless of the stage name or file extension.

This means:
- A stage named `JSON_STAGE` containing `car.json.gz` is still treated as a CSV by default
- To read the file correctly, you **must** define and use a File Format

```sql
-- Without file format: Snowflake reads JSON as CSV
SELECT $1 FROM @JSON_STAGE;
-- Result: Garbled data or partial content

-- With file format: Snowflake reads JSON correctly
SELECT $1
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');
-- Result: Full JSON record in one column
```

---

## 5. CSV File Loading — Complete Example

### 5.1 Create the File Format

```sql
CREATE FILE FORMAT FILE_CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    RECORD_DELIMITER = '\n'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';
```

### 5.2 Verify the Stage File

```sql
LIST @CSV_STAGE;
-- emp.csv.gz (25 rows, 10 columns)
```

### 5.3 Inspect the File (Before Loading)

```sql
-- View data (skipping header, 6 columns shown)
SELECT $1, $2, $3, $4, $5, $6
FROM @CSV_STAGE
(FILE_FORMAT => 'FILE_CSV_FORMAT');
```

### 5.4 Create the Target Table

```sql
CREATE TABLE EMPLOYEE (
    EMP_NUMBER    NUMBER,
    EMP_NAME      VARCHAR,
    JOB           VARCHAR,
    MANAGER       NUMBER,
    HIRE_DATE     DATE,
    SALARY        NUMBER,
    COMMISSION    NUMBER,
    DEPT_NUMBER   NUMBER,
    MOBILE        NUMBER,
    STATUS        BOOLEAN
);
```

### 5.5 Load Data with COPY INTO

```sql
COPY INTO EMPLOYEE
FROM @CSV_STAGE
FILE_FORMAT = (FORMAT_NAME = 'FILE_CSV_FORMAT');
```

Output:
```
status | rows_loaded | errors_seen
-------|-------------|------------
LOADED | 25          | 0
```

### 5.6 Verify Loaded Data

```sql
SELECT * FROM EMPLOYEE;
-- Returns 25 rows
```

---

## 6. Common COPY INTO Error: Column Count Mismatch

```
"Insert value list does not match column list. Expecting 8 but got 10."
```

**Cause:** The file has more columns than the table.

**Fix:** Add the missing columns to the table:

```sql
ALTER TABLE EMPLOYEE ADD COLUMN MOBILE NUMBER;
ALTER TABLE EMPLOYEE ADD COLUMN STATUS BOOLEAN;
```

---

## 7. Understanding Semi-Structured Data

### 7.1 Structured vs. Semi-Structured Data

| Feature        | Structured (CSV/Table)       | Semi-Structured (JSON/XML/Parquet) |
|----------------|------------------------------|-------------------------------------|
| Format         | Fixed columns and rows       | Flexible, hierarchical              |
| Schema         | Defined upfront              | Schema-on-read (inferred at query)  |
| Columns        | Multiple (`$1`, `$2`, ...)   | **Always one column** (`$1`)        |
| Data Types     | Explicit                     | Dynamic (string, number, array)     |
| Snowflake Type | Standard (NUMBER, VARCHAR)   | `VARIANT`                           |

> **Key Rule:** Except for CSV, all other file formats (JSON, XML, Parquet) have **only a single column** when read from a stage.

---

## 8. The VARIANT Data Type

`VARIANT` is Snowflake's special data type for storing semi-structured data (JSON, XML, Parquet objects).

- A single `VARIANT` column can store an entire JSON/XML object
- Snowflake can query into VARIANT columns using dot-notation and the `::` cast operator
- The `VARIANT` type supports arrays, nested objects, and null values

```sql
-- Create a table with a VARIANT column
CREATE TABLE TNS_SEMI_STRUCTURED (
    C1 VARIANT
);
```

---

## 9. JSON Format — Deep Dive

### 9.1 What is JSON?

JSON (JavaScript Object Notation) is a **key-value pair** format. It is widely used for APIs and data exchange.

```json
{
  "student_number": 1,
  "student_name": "Tharun",
  "course": "Snowflake",
  "date_of_joining": "2025-03-15"
}
```

- **Keys** are in double quotes: `"student_number"`, `"student_name"`
- **Values** follow the colon: `1`, `"Tharun"`, `"Snowflake"`
- The entire object is enclosed in **curly braces** `{}`
- String values must be in **double quotes**; numbers do not need quotes
- JSON is always referred to as a **key-value pair** format

### 9.2 JSON File with Multiple Records

```json
[
  {
    "student_number": 1,
    "student_name": "Tharun",
    "course": "Snowflake",
    "date_of_joining": "2025-03-15"
  },
  {
    "student_number": 2,
    "student_name": "Sai",
    "course": "Snowflake",
    "date_of_joining": "2025-03-15"
  },
  {
    "student_number": 3,
    "student_name": "Anand",
    "course": "Snowflake",
    "date_of_joining": "2025-03-15"
  }
]
```

When multiple records exist, they are wrapped in a **JSON array** (square brackets `[]`).

---

## 10. Reading JSON Data from a Stage

```sql
-- Read full JSON content (single column $1)
SELECT $1
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');
```

### Extracting Specific Keys

Use the `$1:key_name` notation:

```sql
-- Extract student_number (returns numbers 1, 2, 3)
SELECT $1:student_number
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');

-- Extract student_name
SELECT $1:student_name
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');

-- Extract multiple fields
SELECT
    $1:student_number   AS STUDENT_NUMBER,
    $1:student_name     AS STUDENT_NAME,
    $1:course           AS COURSE,
    $1:date_of_joining  AS DATE_OF_JOINING
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');
```

### Adding CAST Operator for Data Types

JSON fields are returned as strings by default. Use `::` to cast to the correct type:

```sql
SELECT
    $1:student_number::NUMBER       AS STUDENT_NUMBER,
    $1:student_name::VARCHAR        AS STUDENT_NAME,
    $1:course::VARCHAR              AS COURSE,
    $1:date_of_joining::DATE        AS DATE_OF_JOINING
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');
```

Without `::NUMBER`, the number values appear **left-aligned** (treated as string).
With `::NUMBER`, they appear **right-aligned** (treated as numeric).

---

## 11. Loading JSON into a Table

### Step 1: Create the Target Table

```sql
CREATE TABLE TNS_STUDENTS (
    STUDENT_NUMBER NUMBER,
    STUDENT_NAME   VARCHAR,
    COURSE         VARCHAR,
    DATE_OF_JOINING DATE
);
```

### Step 2: Load Using COPY INTO with SELECT

```sql
COPY INTO TNS_STUDENTS
FROM (
    SELECT
        $1:student_number::NUMBER,
        $1:student_name::VARCHAR,
        $1:course::VARCHAR,
        $1:date_of_joining::DATE
    FROM @JSON_STAGE
    (FILE_FORMAT => 'JSON_FORMAT')
);
```

Output:
```
status | rows_loaded | errors_seen
-------|-------------|------------
LOADED | 3           | 0
```

### Step 3: Verify

```sql
SELECT * FROM TNS_STUDENTS;
```

---

## 12. Loading a Larger JSON File (car.json Example)

### The car.json File Structure

```json
{
  "id": 1,
  "first_name": "John",
  "last_name": "Doe",
  "car_make": "Toyota",
  "car_model": "Camry",
  "car_year": 2020
}
```

This file contains **324 records**.

### Create Table

```sql
CREATE TABLE TNS_CARS_INFO (
    ID          NUMBER,
    FIRST_NAME  VARCHAR,
    LAST_NAME   VARCHAR,
    CAR_MAKE    VARCHAR,
    CAR_MODEL   VARCHAR,
    CAR_YEAR    NUMBER
);
```

### Upload and Load

```bash
# SnowSQL
PUT file://C:/files/car.json @JSON_STAGE;
```

```sql
-- Verify file is in stage
LIST @JSON_STAGE;
-- car.json.gz

-- Load with transformation
COPY INTO TNS_CARS_INFO
FROM (
    SELECT
        $1:id::NUMBER,
        $1:first_name::VARCHAR,
        $1:last_name::VARCHAR,
        $1:car_make::VARCHAR,
        $1:car_model::VARCHAR,
        $1:car_year::NUMBER
    FROM @JSON_STAGE
    (FILE_FORMAT => 'JSON_FORMAT')
    WHERE METADATA$FILENAME LIKE '%car.json%'
);
```

Output:
```
status | rows_loaded
-------|------------
LOADED | 324
```

---

## 13. Reading Multiple Files from the Same Stage

When multiple JSON files are in the same stage, you can identify which records belong to which file using `METADATA$FILENAME`:

```sql
SELECT
    METADATA$FILENAME  AS FILE_NAME,
    $1:student_number::NUMBER AS STUDENT_NUMBER,
    $1:student_name::VARCHAR  AS STUDENT_NAME
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT');
```

This shows which file each record came from — useful for debugging and auditing.

---

## 14. Storing JSON in VARIANT Column

Instead of transforming, you can store the raw JSON in a VARIANT column:

```sql
-- Create table with VARIANT column
CREATE TABLE TNS_SEMI_STRUCTURED (
    C1 VARIANT
);

-- Load all JSON into the single VARIANT column
COPY INTO TNS_SEMI_STRUCTURED
FROM @JSON_STAGE
FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');

-- Query: extract fields from the VARIANT column
SELECT
    C1:student_number::NUMBER  AS STUDENT_NUMBER,
    C1:student_name::VARCHAR   AS STUDENT_NAME,
    C1:course::VARCHAR         AS COURSE
FROM TNS_SEMI_STRUCTURED;
```

This approach is **very flexible** — you can add new keys to the JSON without altering the table schema.

---

## 15. JSON File Format — No Additional Parameters Needed

For JSON (and XML, Parquet), the `TYPE` parameter is sufficient:

```sql
-- This is all you need for JSON
CREATE FILE FORMAT JSON_FORMAT
    TYPE = 'JSON';

-- You do NOT need FIELD_DELIMITER, SKIP_HEADER, etc. for JSON
```

---

## 16. Grant Access (Permissions) for the Role

```sql
-- Grant database access
GRANT USAGE ON DATABASE SALES_DB TO ROLE PUBLIC;

-- Grant schema access
GRANT USAGE ON SCHEMA SALES_SCHEMA TO ROLE PUBLIC;

-- Grant file format access
GRANT USAGE ON FILE FORMAT JSON_FORMAT TO ROLE PUBLIC;

-- Grant warehouse access
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE PUBLIC;

-- Grant table access
GRANT SELECT ON TABLE TNS_STUDENTS TO ROLE PUBLIC;
GRANT INSERT ON TABLE TNS_STUDENTS TO ROLE PUBLIC;
```

---

## 17. Key Commands Summary

```sql
-- File Format Creation
CREATE FILE FORMAT FILE_CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE FILE FORMAT JSON_FORMAT TYPE = 'JSON';
CREATE FILE FORMAT XML_FORMAT  TYPE = 'XML';
CREATE FILE FORMAT PARQUET_FORMAT TYPE = 'PARQUET';

-- Reading from Stage
SELECT $1 FROM @stage_name (FILE_FORMAT => 'format_name');
SELECT $1:key_name::DATATYPE AS alias FROM @stage_name (FILE_FORMAT => 'JSON_FORMAT');

-- Loading Data
COPY INTO table_name
FROM @stage_name
FILE_FORMAT = (FORMAT_NAME = 'format_name');

COPY INTO table_name
FROM (
    SELECT $1:col1::TYPE, $1:col2::TYPE
    FROM @stage_name
    (FILE_FORMAT => 'JSON_FORMAT')
);

-- Metadata column
SELECT METADATA$FILENAME, $1 FROM @stage_name;

-- VARIANT table loading
CREATE TABLE semi_table (C1 VARIANT);
COPY INTO semi_table FROM @json_stage FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');
```

---

## 18. Key Terms

| Term              | Definition                                                                      |
|-------------------|---------------------------------------------------------------------------------|
| CSV               | Comma-Separated Values — structured, tabular file format                        |
| JSON              | JavaScript Object Notation — semi-structured key-value pair format              |
| Key-Value Pair    | JSON data structure: `"key": value`                                              |
| VARIANT           | Snowflake data type for semi-structured data (JSON, XML, Parquet)               |
| Dollar Notation   | `$1`, `$2` for CSV columns; `$1:key` for JSON keys                              |
| CAST (::)         | Converts a value to a specific data type (e.g., `::NUMBER`, `::DATE`)           |
| COPY INTO         | Command to load data from a stage into a Snowflake table                         |
| METADATA$FILENAME | Virtual column returning the name of the source file for each row                |
| SKIP_HEADER       | File format parameter to skip the first N rows (usually the header row)          |
| FIELD_OPTIONALLY_ENCLOSED_BY | File format parameter to handle fields wrapped in quote characters |

---

## 19. Summary

- CSV files have **multiple columns** (`$1`, `$2`, `$3`...); JSON/XML/Parquet have **one column** (`$1`)
- For JSON, use `$1:key_name` to extract a specific field's value
- Use `::DATATYPE` to cast JSON string values to the correct type (NUMBER, DATE, VARCHAR)
- **VARIANT** is the Snowflake data type for storing semi-structured (JSON/XML/Parquet) data
- JSON is a **key-value pair** format, enclosed in curly braces `{}`; arrays use square brackets `[]`
- By default, all stages treat files as **CSV** — always specify a file format for other types
- `COPY INTO` with a `SELECT` subquery allows data transformation during loading
- `METADATA$FILENAME` identifies which source file each record came from
