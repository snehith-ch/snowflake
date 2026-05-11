# Lecture 5: COPY Command, Semi-Structured Data, and JSON Basics

## Quick Revision — Lecture 5

| # | Key Point |
|---|-----------|
| 1 | CSV → multiple columns ($1, $2, ...); JSON/XML/Parquet → only ONE column ($1) |
| 2 | For JSON: use $1:key_name to extract a specific key's value |
| 3 | Use ::DATATYPE cast after JSON key extraction to get correct type |
| 4 | JSON is a key-value pair format, enclosed in curly braces {} |
| 5 | COPY INTO with subquery: `COPY INTO table FROM (SELECT $1:key::type FROM @stage ...)` |
| 6 | VARIANT is the Snowflake data type for storing semi-structured (JSON/XML/Parquet) data |
| 7 | By default, all stages treat files as CSV — always specify file format for other types |
| 8 | METADATA$FILENAME — virtual column showing which file each row came from |
| 9 | Sample.json class file keys: sno, sname, course, DOJ; car.json keys: id, first_name, last_name, car_make, Car_Model, Car_Model_Year |
| 10 | For JSON file format: only TYPE = JSON is needed — no delimiter or skip_header |

---

**Pre-requisite:** Lecture 4 — Stages, Files, and Data Loading
**Next:** Lecture 6 — Advanced COPY Options and Nested JSON
**Related:** Lecture 3 — Cast Operator (::) needed for JSON key extraction

---

## Objects Created This Lecture

| Object Type | Name                  | Purpose                                              |
|-------------|-----------------------|------------------------------------------------------|
| Table       | T_STUDENTS            | Target for loading sample.json (sno, sname, course, doj) |
| Table       | T_CARS_INFO           | Target for loading car.json (id, first_name, last_name, car_make, car_model, car_model_year) |
| Table       | T_SEMI_STRUCTURED_DATA| VARIANT column table — stores raw JSON |
| Table       | T_SSD                 | Two columns: file_name VARCHAR, c1 VARIANT — stores JSON with file name |
| Table       | T_TEST                | Demo table to show numeric validation error |
| Table       | EMP                   | Employee table in SALES_DB (loaded from emp.csv) |
| File Format | JSON_FORMAT           | JSON file format (type=json) |
| File Format | FILE_CSV_FORMAT       | CSV file format in SALES_DB |
| User        | KRANTHI               | Demo user for stage operations (public role) |

---

## ASCII Data Flow — JSON Loading Process

```
sample.json (local file)
       |
       | PUT (SnowSQL)
       v
@json_stage (sample.json.gz)
       |
       | SELECT $1 FROM @json_stage (FILE_FORMAT=>json_format)
       | → Shows raw JSON in single column
       |
       | SELECT $1:sno, $1:sname, $1:course, $1:DOJ
       | → Extracts key values (still strings)
       |
       | SELECT $1:sno::number, $1:sname::varchar, ...
       | → Proper typed values
       v
COPY INTO t_students FROM (
    SELECT $1:sno::number, $1:sname::varchar,
           $1:course::varchar, $1:DOJ::date
    FROM @json_stage (FILE_FORMAT=>json_format)
)
       |
       v
T_STUDENTS table (3 rows loaded)
```

---

## 1. Recap: Stages and Key Concepts

Before loading JSON in this lecture, Krishna re-explained stages:

> Krishna: "So we have, see, basically a stage is nothing but a location. We have three stages, internal and external. External will talk about this later. When it comes to internal stages, how many stages we have? Three stages, okay? User, table and named stage. `@~` will be the user stage. `@%table_name` is table stage. `@stage_name` is the named stage."

Key reminder points:
- `LIST` command — see the files from a stage
- `PUT` command — place a file into a stage
- `COPY INTO` — command to load data from stage into a table
- If you create a user: **user stage is automatically available**
- If you create a table: **table stage is automatically available**

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

### Actual SnowSQL Session from Class (SALES_DB setup)

```
C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.108s
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use SCHEMA SALES_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.115s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_Stage;
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source  | target     | source_size | target_size | source_compression | target_compression | status   | message |
|---------+------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp.csv | emp.csv.gz |        1531 |         560 | NONE               | GZIP               | UPLOADED |         |
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.250s

krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_Stage;
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source   | target      | source_size | target_size | source_compression | target_compression | status   | message |
|----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------|
| car.json | car.json.gz |       38671 |        7232 | NONE               | GZIP               | UPLOADED |         |
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.134s

krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\books_info.xml @xml_Stage;
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| books_info.xml | books_info.xml.gz |        4607 |        1408 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 0.994s

krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\MT_cars.parquet @parquet_Stage;
+-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source          | target          | source_size | target_size | source_compression | target_compression | status   | message |
|-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| MT_cars.parquet | MT_cars.parquet |        2932 |        2944 | PARQUET            | PARQUET            | UPLOADED |         |
+-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 0.508s
```

Note: Parquet is not re-compressed (already in Parquet format); CSV, JSON, XML are gzip compressed.

---

## 4. Default File Format Behavior (Critical Reminder)

> By default, when you create any stage, Snowflake treats **all files inside it as CSV**, regardless of the stage name or file extension.

This means:
- A stage named `JSON_STAGE` containing `car.json.gz` is still treated as CSV by default
- To read the file correctly, you **must** define and use a File Format

```sql
-- Without file format: Snowflake reads JSON as CSV (garbled/incorrect)
SELECT $1 FROM @JSON_STAGE;
-- Result: Only partial content — wherever Snowflake finds a comma, it starts a new column

-- With JSON file format: Snowflake reads JSON correctly
SELECT $1 FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
-- Result: Full JSON record in one column
```

> Krishna: "Why it is giving you this information? But for what is the CSV? Exactly, that is correct. By default, whatever the stage that you have created, Snowflake treats the files as CSV files. Wherever it finds a comma, it treats that is the first column. This is the second column. But that is not true, right?"

---

## 5. CSV File Loading — Complete Class Example

### 5.1 Setup: SALES_DB and Permissions

```sql
-- Create database and schema (ACCOUNTADMIN)
CREATE DATABASE SALES_DB;
CREATE SCHEMA SALES_SCHEMA;

-- Grant access to PUBLIC role
GRANT USAGE ON DATABASE SALES_DB TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA SALES_SCHEMA TO ROLE PUBLIC;
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE PUBLIC;
```

### 5.2 Create the File Format

```sql
CREATE FILE FORMAT FILE_CSV_FORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n';

-- Grant to PUBLIC role
GRANT USAGE ON FILE FORMAT FILE_CSV_FORMAT TO ROLE PUBLIC;
```

### 5.3 Create the Target Table (emp)

```sql
-- From class (SALES_DB)
CREATE TABLE EMP (
    EMPNO    NUMBER,
    ENAME    VARCHAR,
    JOB      VARCHAR,
    MGR      NUMBER,
    HIREDATE DATE,
    SAL      NUMBER,
    COMM     NUMBER,
    DEPTNO   NUMBER,
    MOBILE   NUMBER,
    STATUS   BOOLEAN
);

GRANT SELECT ON TABLE EMP TO ROLE PUBLIC;
GRANT INSERT ON TABLE EMP TO ROLE PUBLIC;
```

### 5.4 Verify Stage File and Inspect

```sql
-- Verify stage has file
LIST @~/emp.csv.gz;

-- Inspect without file format (includes header as first row)
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 FROM @~/emp.csv.gz;

-- Inspect with file format (header skipped, proper data)
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 FROM @~/emp.csv.gz (FILE_FORMAT=>FILE_CSV_FORMAT);
```

### 5.5 Load Data with COPY INTO

```sql
-- Load from user stage (emp.csv.gz)
COPY INTO EMP FROM @~/emp.csv.gz FILE_FORMAT=FILE_CSV_FORMAT;
```

Output:
```
status | rows_loaded | errors_seen
-------|-------------|------------
LOADED | 25          | 0
```

### 5.6 Verify Loaded Data

```sql
SELECT * FROM EMP;
-- Returns 25 rows
```

---

## 6. Common COPY INTO Error: Numeric Value Not Recognized

### Error 1: Header loaded as data

```sql
-- Running COPY INTO without file format
COPY INTO T_STUDENT_INFO FROM @~;
-- Error: "Numeric value 'sno' is not recognized"
```

> Krishna: "Why you are getting this error? Employee number is not recognized, which means it is taking the header, right? It is considering the header. It is another reason it is unable to load the data."

**Fix:** Always specify a file format with `SKIP_HEADER=1`.

### Error 2: Wrong data type in column

> Class demonstration to explain the error:

```sql
CREATE TABLE T_TEST (EMPNO NUMBER);
INSERT INTO T_TEST VALUES ('BALA');
-- Error: "Numeric value 'BALA' is not recognized"
```

> Krishna: "Can I insert a character into a column which is a number? No. What it is? Numeric value, Bala is not recognized."

**Fix:** Check data types match between file columns and table columns.

---

## 7. Understanding Semi-Structured Data

### 7.1 Structured vs. Semi-Structured Data

| Feature        | Structured (CSV/Table)       | Semi-Structured (JSON/XML/Parquet) |
|----------------|------------------------------|-------------------------------------|
| Format         | Fixed columns and rows       | Flexible, hierarchical              |
| Schema         | Defined upfront              | Schema-on-read (inferred at query)  |
| Columns in stage | Multiple (`$1`, `$2`, ...) | **Always one column** (`$1`)        |
| Data Types     | Explicit                     | Dynamic (string, number, array)     |
| Snowflake Type | Standard (NUMBER, VARCHAR)   | `VARIANT`                           |

> **Key Rule:** Except for CSV, all other file formats (JSON, XML, Parquet) have **only a single column** when read from a stage.

> Krishna: "CSV will have single or more than one column. But XML, JSON, Parquet — these files will have only single column, only single column. You got my point right? Except CSV, all the other files will have only single column. What is that column? Dollar one."

---

## 8. The VARIANT Data Type

`VARIANT` is Snowflake's special data type for storing semi-structured data (JSON, XML, Parquet objects).

- A single `VARIANT` column can store an entire JSON/XML object
- Snowflake can query into VARIANT columns using colon notation and the `::` cast operator
- The `VARIANT` type supports arrays, nested objects, and null values

```sql
-- Create a table with a VARIANT column (from class)
CREATE TABLE T_SEMI_STRUCTURED_DATA (C1 VARIANT);
```

---

## 9. JSON Format — Deep Dive

### 9.1 What is JSON?

JSON (JavaScript Object Notation) is a **key-value pair** format. It is widely used for APIs and data exchange.

> Krishna: "What is JSON guys? JSON is a key value pair. Okay? JSON is nothing but a key value pair. And how to identify the JSON file? It will be within this particular basis. This is called what? Curly braces. If I have to explain you about JSON format, it is like a key-value pair."

```json
{
  "sno": 1,
  "sname": "Tarun",
  "course": "snowflake",
  "DOJ": "2025-03-15"
}
```

- **Keys** are in double quotes: `"sno"`, `"sname"`, `"DOJ"`
- **Values** follow the colon: `1`, `"Tarun"`, `"2025-03-15"`
- The entire object is enclosed in **curly braces** `{}`
- **String values** must be in **double quotes**; numbers do not need quotes
- JSON is always a **key-value pair**

### 9.2 JSON File Created in Class (sample.json)

```json
[
  {"sno": 1, "sname": "Tarun", "course": "snowflake", "DOJ": "2025-03-15"},
  {"sno": 2, "sname": "Sai", "course": "snowflake", "DOJ": "2025-03-15"},
  {"sno": 3, "sname": "Anand", "course": "snowflake", "DOJ": "2025-03-15"}
]
```

> Krishna (building this file live): "See, this is called key guys. How many keys are there? Can you tell me? Student number is a key. Student name is a key. Course is a key. Date of joining is a key. Now, what is value? If I want to get the value of a key, what is the value here? 1, 2, 3 are the values. Tarun Sai Anand are the values. Snowflake is the value."

When multiple records exist, they are wrapped in a **JSON array** (square brackets `[]`).

### 9.3 car.json Sample Record

```json
{"id":1,"first_name":"Rohit","last_name":"K","car_make":"Mercedes-Benz","Car_Model":"C-Class","Car_Model_Year":2001}
```

This file contains **324 records**.

---

## 10. Reading JSON Data from a Stage

### Step 1: Upload JSON file

```
-- Actual SnowSQL output from class:
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\sample.json @json_stage;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| sample.json | sample.json.gz |         202 |         128 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
```

### Step 2: Create JSON File Format

```sql
CREATE FILE FORMAT JSON_FORMAT
    TYPE = JSON;
-- That's all! No skip_header, no delimiter needed for JSON
```

### Step 3: Read Raw JSON from Stage

```sql
-- Without file format (treated as CSV — garbled):
SELECT $1 FROM @JSON_STAGE;
-- Result: broken partial content wherever commas appear

-- With file format (correct — full JSON per row):
SELECT $1 FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
-- Result: each row shows one complete JSON object
```

### Extracting Specific Keys

Use the `$1:key_name` notation:

```sql
-- Class queries (from Daily Notes.sql)
SELECT $1:sno, $1:sname, $1:course, $1:DOJ
FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
-- Returns: values as strings (left-aligned in Snowsight — indicating varchar)
```

> Krishna: "If I want to get the first key value, I need to use colon. Student number. What you are getting is 1, 2, 3, right? Correct? You got the student number. Dollar 1 colon. What is the second column? Student name, right? Student name. You got the student name."

### Step 4: Add CAST Operator for Proper Data Types

JSON fields are returned as strings by default. Use `::` to cast to the correct type:

```sql
-- From Daily Notes.sql (Lecture 27 section)
SELECT
    $1:sno::NUMBER    AS SNO,
    $1:sname::VARCHAR AS SNAME,
    $1:course::VARCHAR AS COURSE,
    $1:DOJ::DATE      AS DOJ
FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
```

> Without `::NUMBER`, numeric values appear **left-aligned** (treated as string).
> With `::NUMBER`, they appear **right-aligned** (treated as numeric).

---

## 11. Loading JSON into a Table

### Step 1: Create the Target Table

```sql
-- From class (Daily Notes.sql)
CREATE TABLE T_STUDENTS (
    SNO    NUMBER,
    SNAME  VARCHAR,
    COURSE VARCHAR,
    DOJ    DATE
);

SELECT * FROM T_STUDENTS;
-- 0 rows initially
```

### Step 2: Load Using COPY INTO with Subquery

```sql
-- From Daily Notes.sql
COPY INTO T_STUDENTS
FROM (
    SELECT
        $1:sno::NUMBER    AS SNO,
        $1:sname::VARCHAR AS SNAME,
        $1:course::VARCHAR AS COURSE,
        $1:DOJ::DATE       AS DOJ
    FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT)
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
SELECT * FROM T_STUDENTS;
-- 3 rows: Tarun, Sai, Anand
```

---

## 12. Loading car.json (324 Records Example)

### Setup

```sql
-- Create target table (from class)
CREATE TABLE T_CARS_INFO (
    ID             NUMBER,
    FIRST_NAME     VARCHAR,
    LAST_NAME      VARCHAR,
    CAR_MAKE       VARCHAR,
    CAR_MODEL      VARCHAR,
    CAR_MODEL_YEAR NUMBER
);

SELECT * FROM T_CARS_INFO;
-- 0 rows initially
```

### Upload car.json (already done in previous session)

```
-- SnowSQL (from Daily Notes.sql)
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_stage;
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source   | target      | source_size | target_size | source_compression | target_compression | status   | message |
|----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------|
| car.json | car.json.gz |       38671 |        7232 | NONE               | GZIP               | UPLOADED |         |
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
```

### Read and Load car.json

```sql
-- Check METADATA$FILENAME to see which file each row comes from
SELECT $1, METADATA$FILENAME FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);

-- Read from specific file within stage
SELECT
    $1:id::NUMBER          AS ID,
    $1:first_name::VARCHAR AS FIRST_NAME,
    $1:last_name::VARCHAR  AS LAST_NAME,
    $1:car_make::VARCHAR   AS CAR_MAKE,
    $1:Car_Model::VARCHAR  AS CAR_MODEL,
    $1:Car_Model_Year::NUMBER AS CAR_MODEL_YEAR
FROM @JSON_STAGE/car.json.gz (FILE_FORMAT => JSON_FORMAT);

-- Load into table
COPY INTO T_CARS_INFO
FROM (
    SELECT
        $1:id::NUMBER,
        $1:first_name::VARCHAR,
        $1:last_name::VARCHAR,
        $1:car_make::VARCHAR,
        $1:Car_Model::VARCHAR,
        $1:Car_Model_Year::NUMBER
    FROM @JSON_STAGE/car.json.gz (FILE_FORMAT => JSON_FORMAT)
);
```

Output:
```
status | rows_loaded
-------|------------
LOADED | 324
```

> **Note on case sensitivity in JSON keys:** The car.json file uses `Car_Model` and `Car_Model_Year` (mixed case). When extracting, use the exact key name as it appears in the JSON file: `$1:Car_Model::VARCHAR` not `$1:car_model::VARCHAR`.

---

## 13. METADATA$FILENAME — Identifying Source File

When multiple JSON files are in the same stage, use `METADATA$FILENAME` to identify which records belong to which file:

```sql
-- From Daily Notes.sql
SELECT $1, METADATA$FILENAME FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
-- Shows: sample.json.gz or car.json.gz per row
```

This shows which file each record came from — useful for debugging and auditing.

---

## 14. Storing JSON in VARIANT Column

Instead of transforming, you can store the raw JSON in a VARIANT column:

```sql
-- From Daily Notes.sql
-- Create table with VARIANT column
CREATE TABLE T_SEMI_STRUCTURED_DATA (C1 VARIANT);

-- Load all JSON from json_stage into single VARIANT column
COPY INTO T_SEMI_STRUCTURED_DATA FROM @JSON_STAGE FILE_FORMAT = JSON_FORMAT;

SELECT * FROM T_SEMI_STRUCTURED_DATA;
-- Raw JSON stored in C1 column
```

### Querying VARIANT Column (Same as querying from stage)

```sql
-- Query using colon notation on VARIANT column
SELECT
    C1:sno::NUMBER    AS SNO,
    C1:sname::VARCHAR AS SNAME,
    C1:course::VARCHAR AS COURSE,
    C1:DOJ::DATE       AS DOJ
FROM T_SEMI_STRUCTURED_DATA;
```

---

## 15. T_SSD — Tracking File Names with VARIANT Data

A more useful pattern: store both the filename and the JSON content:

```sql
-- From Daily Notes.sql
CREATE TABLE T_SSD (
    FILE_NAME VARCHAR,
    C1        VARIANT
);

-- Load with filename tracking
COPY INTO T_SSD
FROM (
    SELECT METADATA$FILENAME, $1
    FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT)
);

SELECT * FROM T_SSD;

-- Query only sample.json records
SELECT C1 FROM T_SSD WHERE FILE_NAME = 'sample.json.gz';

SELECT
    C1:sno::NUMBER    AS SNO,
    C1:sname::VARCHAR AS SNAME,
    C1:course::VARCHAR AS COURSE,
    C1:DOJ::DATE       AS DOJ
FROM T_SSD
WHERE FILE_NAME = 'sample.json.gz';

-- Query only car.json records
SELECT
    C1:id::NUMBER              AS ID,
    C1:first_name::VARCHAR     AS FIRST_NAME,
    C1:last_name::VARCHAR      AS LAST_NAME,
    C1:car_make::VARCHAR       AS CAR_MAKE,
    C1:Car_Model::VARCHAR      AS CAR_MODEL,
    C1:Car_Model_Year::NUMBER  AS CAR_MODEL_YEAR
FROM T_SSD
WHERE FILE_NAME = 'car.json.gz';
```

---

## 16. JSON File Format — No Additional Parameters Needed

For JSON (and XML, Parquet), the `TYPE` parameter is sufficient:

```sql
-- This is all you need for JSON
CREATE FILE FORMAT JSON_FORMAT
    TYPE = JSON;

-- You do NOT need FIELD_DELIMITER, SKIP_HEADER, etc. for JSON
```

| File Type | Parameters Needed |
|-----------|-----------------|
| CSV | TYPE, SKIP_HEADER, FIELD_DELIMITER, RECORD_DELIMITER |
| JSON | TYPE only |
| XML | TYPE only |
| Parquet | TYPE only |

---

## 17. Grant Access (Permissions) for Loading

```sql
-- Grant database access
GRANT USAGE ON DATABASE SALES_DB TO ROLE PUBLIC;

-- Grant schema access
GRANT USAGE ON SCHEMA SALES_SCHEMA TO ROLE PUBLIC;

-- Grant file format access
GRANT USAGE ON FILE FORMAT FILE_CSV_FORMAT TO ROLE PUBLIC;

-- Grant warehouse access
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE PUBLIC;

-- Grant table access
GRANT SELECT ON TABLE EMP TO ROLE PUBLIC;
GRANT INSERT ON TABLE EMP TO ROLE PUBLIC;
```

---

## 18. Key Differences Tables

### CSV vs JSON/XML/Parquet in a Stage

| Property | CSV | JSON / XML / Parquet |
|----------|-----|----------------------|
| Columns in stage | Multiple: $1, $2, $3... | ONE column: $1 only |
| Column extraction | `$1`, `$2` by position | `$1:key_name` by key |
| File format needed | Yes (SKIP_HEADER, delimiter) | Yes (TYPE only) |
| Cast operator | Optional | Required for typed output |
| Header row | Yes (must skip with SKIP_HEADER=1) | No header concept |
| Data type | Explicit (NUMBER, DATE) | Variant (string by default) |

### COPY INTO Basic vs with Subquery

| Method | Syntax | Use Case |
|--------|--------|----------|
| Basic COPY INTO | `COPY INTO table FROM @stage FILE_FORMAT=...` | CSV — columns match exactly |
| COPY INTO with SELECT | `COPY INTO table FROM (SELECT $1:key::type FROM @stage ...)` | JSON/XML — need key extraction and type casting |

### Storing JSON: Direct Transform vs VARIANT

| Approach | Method | Pros | Cons |
|----------|--------|------|------|
| Direct transform | Extract keys, cast types, store in typed columns | Query-efficient, typed | Schema must be known upfront |
| VARIANT storage | Store raw JSON in VARIANT column | Flexible, handles schema changes | Slightly slower to query |

---

## 19. Key Commands Summary

```sql
-- File Format Creation
CREATE FILE FORMAT FILE_CSV_FORMAT
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    RECORD_DELIMITER = '\n';

CREATE FILE FORMAT JSON_FORMAT TYPE = JSON;
CREATE FILE FORMAT XML_FORMAT  TYPE = XML;
CREATE FILE FORMAT PARQUET_FORMAT TYPE = PARQUET;

-- Reading from Stage (CSV)
SELECT $1,$2,$3 FROM @stage_name (FILE_FORMAT => FILE_CSV_FORMAT);

-- Reading from Stage (JSON — single column with key extraction)
SELECT $1 FROM @json_stage (FILE_FORMAT => JSON_FORMAT);
SELECT $1:sno, $1:sname, $1:DOJ FROM @json_stage (FILE_FORMAT => JSON_FORMAT);
SELECT $1:sno::NUMBER, $1:sname::VARCHAR, $1:DOJ::DATE FROM @json_stage (FILE_FORMAT => JSON_FORMAT);

-- Loading CSV Data
COPY INTO emp FROM @~/emp.csv.gz FILE_FORMAT=FILE_CSV_FORMAT;

-- Loading JSON with transformation
COPY INTO t_students
FROM (
    SELECT $1:sno::NUMBER, $1:sname::VARCHAR, $1:course::VARCHAR, $1:DOJ::DATE
    FROM @json_stage (FILE_FORMAT => JSON_FORMAT)
);

-- Loading specific file from stage
SELECT ... FROM @json_stage/car.json.gz (FILE_FORMAT => JSON_FORMAT);

-- Metadata column
SELECT METADATA$FILENAME, $1 FROM @json_stage (FILE_FORMAT => JSON_FORMAT);

-- VARIANT table loading
CREATE TABLE T_SEMI_STRUCTURED_DATA (C1 VARIANT);
COPY INTO T_SEMI_STRUCTURED_DATA FROM @json_stage FILE_FORMAT = JSON_FORMAT;

-- Query VARIANT column
SELECT C1:sno::NUMBER, C1:sname::VARCHAR FROM T_SEMI_STRUCTURED_DATA;

-- T_SSD pattern (filename + variant)
CREATE TABLE T_SSD (FILE_NAME VARCHAR, C1 VARIANT);
COPY INTO T_SSD FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage (FILE_FORMAT => JSON_FORMAT));
SELECT C1:sno::NUMBER FROM T_SSD WHERE FILE_NAME = 'sample.json.gz';
```

---

## 20. Common Errors Table

| Error Message | Cause | Fix |
|---------------|-------|-----|
| "Numeric value 'sno' is not recognized" | Header row loaded as data (missing SKIP_HEADER) | Use file format with `SKIP_HEADER=1` |
| "Numeric value 'BALA' is not recognized" | VARCHAR value inserted into NUMBER column | Check data type of column vs value |
| "Insufficient privileges to operate" when COPY INTO | Role has SELECT but not INSERT on table | `GRANT INSERT ON TABLE ... TO ROLE ...` |
| `SELECT $1:sno FROM @json_stage;` returns garbled data | No file format specified — treated as CSV | Add `(FILE_FORMAT => JSON_FORMAT)` |
| No warehouse available when querying stage | Warehouse not selected/granted to role | Grant warehouse USAGE, select warehouse in UI |
| "File format does not exist or not authorized" | File format not granted to role or wrong name | `GRANT USAGE ON FILE FORMAT ... TO ROLE ...` |
| JSON values appear left-aligned (as text) | Missing `::TYPE` cast operator | Add `::NUMBER`, `::VARCHAR`, `::DATE` after key extraction |

---

## 21. Q&A from This Lecture

> **Student Question:** What are the limitations of the user stage?
> **Answer (Krishna):** I will come to that. We will talk about the differences (in later session). Key limitation: user stage is private — only the user who owns it can access it. Named stages can be shared across roles. You also cannot explicitly create or drop a user stage.

> **Student Question:** Can we check the files from user stage that were uploaded by another user?
> **Answer:** No. User stage is private to the user. Only the user whose stage it is can list and access files in it.

> **Student Question:** You are able to follow? (after JSON loading demo)
> **Answer (class):** Yes. Student confirms understanding of the JSON loading workflow.

---

## 22. Interview Questions

**Q: How many columns does a CSV file have when read from a stage vs a JSON file?**
A: CSV can have multiple columns — referenced as `$1`, `$2`, `$3`, etc. JSON, XML, and Parquet always have only ONE column (`$1`) when read from a stage.

**Q: How do you extract a specific field from a JSON file in a Snowflake stage?**
A: Use `$1:key_name` notation. For example, `$1:sno` extracts the `sno` key's value. Then cast with `::` for the correct data type: `$1:sno::NUMBER`.

**Q: What is VARIANT in Snowflake?**
A: VARIANT is Snowflake's semi-structured data type for storing JSON, XML, or Parquet objects. A single VARIANT column can store an entire JSON object and can be queried using colon notation.

**Q: What is the syntax for COPY INTO when loading from a JSON stage?**
A: You must use a subquery to extract and cast the fields:
```sql
COPY INTO table FROM (
    SELECT $1:key1::TYPE, $1:key2::TYPE
    FROM @stage (FILE_FORMAT => JSON_FORMAT)
);
```

**Q: What file format parameters are needed for JSON vs CSV?**
A: CSV needs TYPE, SKIP_HEADER, FIELD_DELIMITER, RECORD_DELIMITER. JSON only needs TYPE = JSON — no delimiter or header parameters.

**Q: What does METADATA$FILENAME return?**
A: It returns the name of the source file (e.g., `sample.json.gz`) for each row. Useful when multiple files are in a stage and you need to identify the source of each record.

**Q: Why do JSON values appear left-aligned in Snowsight when extracted from a stage?**
A: Because without the `::` cast operator, all JSON values are returned as strings (VARCHAR), which are left-aligned. Use `::NUMBER` or `::DATE` to get right-aligned numeric/date values.

**Q: What is the difference between storing JSON in a typed table vs a VARIANT column?**
A: Typed table: you extract specific keys and store in proper columns — good for query performance but requires the schema upfront. VARIANT column: stores the raw JSON — flexible for schema changes but slightly slower to query.

**Q: How do you load data from a specific file within a stage?**
A: Append the filename to the stage path: `FROM @json_stage/car.json.gz` — this reads only that specific file.

**Q: What is the T_SSD pattern for loading JSON?**
A: Create a table with a FILE_NAME VARCHAR and C1 VARIANT column. Use COPY INTO with `SELECT METADATA$FILENAME, $1 FROM @stage` to store both the source filename and the raw JSON. Then filter by file name when querying.

---

## 23. Try It Yourself Exercises

**Exercise 1:** Create a simple JSON file with 3 student records (fields: id, name, grade), upload it to a JSON stage via SnowSQL, then read it from the stage using the correct file format.
```sql
-- Create JSON format
CREATE FILE FORMAT JSON_FORMAT TYPE = JSON;
-- In SnowSQL: PUT file://path/students.json @json_stage;
-- In Snowsight:
SELECT $1 FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
SELECT $1:id::NUMBER, $1:name::VARCHAR, $1:grade::VARCHAR
FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);
```

**Exercise 2:** Create a table T_STUDENTS_JSON (ID NUMBER, NAME VARCHAR, GRADE VARCHAR) and load from the JSON stage using COPY INTO with a transformation subquery.
```sql
CREATE TABLE T_STUDENTS_JSON (ID NUMBER, NAME VARCHAR, GRADE VARCHAR);
COPY INTO T_STUDENTS_JSON
FROM (
    SELECT $1:id::NUMBER, $1:name::VARCHAR, $1:grade::VARCHAR
    FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT)
);
SELECT * FROM T_STUDENTS_JSON;
```

**Exercise 3:** Create a VARIANT table and load all files from JSON stage. Then query the VARIANT column to extract specific fields.
```sql
CREATE TABLE T_ALL_JSON (C1 VARIANT);
COPY INTO T_ALL_JSON FROM @JSON_STAGE FILE_FORMAT = JSON_FORMAT;
SELECT C1:id::NUMBER, C1:name::VARCHAR FROM T_ALL_JSON;
```

**Exercise 4:** Use METADATA$FILENAME to see which file each row in the stage comes from. Then load to a table that stores both filename and content.
```sql
SELECT METADATA$FILENAME, $1 FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT);

CREATE TABLE T_JSON_TRACKING (FILE_NAME VARCHAR, CONTENT VARIANT);
COPY INTO T_JSON_TRACKING
FROM (SELECT METADATA$FILENAME, $1 FROM @JSON_STAGE (FILE_FORMAT => JSON_FORMAT));
SELECT * FROM T_JSON_TRACKING;
```

**Exercise 5:** Replicate the car.json loading demo. Check the case of JSON keys, extract them, and load into T_CARS_INFO. Verify with SELECT.
```sql
-- First check key names
SELECT $1 FROM @JSON_STAGE/car.json.gz (FILE_FORMAT => JSON_FORMAT) LIMIT 1;
-- Note: Car_Model and Car_Model_Year use mixed case

CREATE TABLE T_CARS_INFO (
    ID NUMBER, FIRST_NAME VARCHAR, LAST_NAME VARCHAR,
    CAR_MAKE VARCHAR, CAR_MODEL VARCHAR, CAR_MODEL_YEAR NUMBER
);

COPY INTO T_CARS_INFO
FROM (
    SELECT
        $1:id::NUMBER, $1:first_name::VARCHAR, $1:last_name::VARCHAR,
        $1:car_make::VARCHAR, $1:Car_Model::VARCHAR, $1:Car_Model_Year::NUMBER
    FROM @JSON_STAGE/car.json.gz (FILE_FORMAT => JSON_FORMAT)
);

SELECT COUNT(*) FROM T_CARS_INFO; -- Should be 324
SELECT * FROM T_CARS_INFO LIMIT 5;
```

---

## 24. Key Terms

| Term              | Definition                                                                      |
|-------------------|---------------------------------------------------------------------------------|
| CSV               | Comma-Separated Values — structured, tabular file format                        |
| JSON              | JavaScript Object Notation — semi-structured key-value pair format              |
| Key-Value Pair    | JSON data structure: `"key": value`                                              |
| Curly Braces      | `{}` — enclose a JSON object                                                    |
| Square Brackets   | `[]` — enclose a JSON array (multiple records)                                   |
| VARIANT           | Snowflake data type for semi-structured data (JSON, XML, Parquet)               |
| Dollar Notation   | `$1`, `$2` for CSV columns; `$1:key` for JSON keys                              |
| CAST (::)         | Converts a value to a specific data type (e.g., `::NUMBER`, `::DATE`)           |
| COPY INTO         | Command to load data from a stage into a Snowflake table                         |
| METADATA$FILENAME | Virtual column returning the name of the source file for each row                |
| SKIP_HEADER       | File format parameter to skip the first N rows (usually the header row)          |
| FILE_FORMAT       | Named object describing how to parse a file; also the parameter in COPY INTO    |
| T_SSD             | Pattern: table with FILE_NAME + VARIANT column to store JSON with source tracking |

---

## 25. Summary

- CSV files have **multiple columns** (`$1`, `$2`, `$3`...); JSON/XML/Parquet have **one column** (`$1`)
- For JSON, use `$1:key_name` to extract a specific field's value
- Use `::DATATYPE` to cast JSON string values to the correct type (NUMBER, DATE, VARCHAR)
- **VARIANT** is the Snowflake data type for storing semi-structured (JSON/XML/Parquet) data
- JSON is a **key-value pair** format, enclosed in curly braces `{}`; arrays use square brackets `[]`
- By default, all stages treat files as **CSV** — always specify a file format for other types
- `COPY INTO` with a `SELECT` subquery allows data transformation during loading
- JSON key names are **case-sensitive** — use exact casing from the JSON file (e.g., `Car_Model` not `car_model`)
- `METADATA$FILENAME` identifies which source file each record came from
- The T_SSD pattern (FILE_NAME + VARIANT) lets you store all JSON in one table, then filter by file name when querying
