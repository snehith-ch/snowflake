# Lecture 6: Semi-Structured Data — JSON Deep Dive and COPY INTO

---

## Quick Revision — Lecture 6

| # | Key Point |
|---|-----------|
| 1 | JSON = key-value pair format; each record in `{}`, multiple records in `[]` (array) |
| 2 | XML, JSON, Parquet all read as a **single column** `$1` from a stage (CSV can have many) |
| 3 | Extract keys with `$1:key_name` (colon notation) or `$1['key_name']` (bracket notation) |
| 4 | Always cast with `::DATATYPE` — e.g., `$1:sno::NUMBER`, `$1:DOJ::DATE` |
| 5 | `METADATA$FILENAME` is a virtual column that tells you which file each row came from |
| 6 | Multiple JSON files in a stage → all load at once; use `METADATA$FILENAME` to filter |
| 7 | `ALTER STAGE json_stage SET FILE_FORMAT = json_format` removes need to specify format in COPY |
| 8 | If a stage has a format assigned, `COPY INTO` does NOT need an explicit file format |
| 9 | Store raw JSON in a `VARIANT` column; extract keys at query time |
| 10 | JSON key names are **case-sensitive** — `$1:sno` ≠ `$1:SNO` |

---

**Pre-requisite:** Lecture 5 — COPY Command Basics (stages, PUT, COPY INTO CSV)
**Next:** Lecture 7 — VARIANT Loading, Nested Arrays, and LATERAL FLATTEN
**Related:** Lecture 8 — XML Processing (same `$1:@` / `$1:$` concepts)

---

## Objects Created in This Lecture

| Object Type  | Name                  | Purpose |
|--------------|-----------------------|---------|
| Database     | SALES_DB              | Main database for this module |
| Schema       | SALES_SCHEMA          | Schema for sales-related objects |
| Stage        | json_stage            | Internal named stage for JSON files |
| File Format  | json_format           | Tells Snowflake to parse files as JSON |
| Table        | t_students            | Target table for student JSON data |
| Table        | t_cars_info           | Target table for car JSON data (324 rows) |
| Table        | t_kids_info           | Target table for nested kids JSON data |
| Table        | t_semi_structed_Data  | VARIANT table — raw JSON storage |
| Table        | t_ssd                 | VARIANT table with file_name tracking column |

---

## ASCII Data Flow

```
Local JSON File
      |
      |  PUT (via SnowSQL CLI)
      v
@json_stage (internal named stage)
      |
      |  SELECT $1:key::TYPE FROM @json_stage (file_format=>json_format)
      v
   Preview data in tabular form
      |
      |  COPY INTO table_name FROM (SELECT ...)
      v
Relational table (t_students, t_cars_info)

      OR

      |  COPY INTO t_semi_structed_Data FROM @json_stage file_format=json_format
      v
VARIANT table — raw JSON stored as-is, queried with C1:key::TYPE
```

---

## 1. Recap: What JSON Looks Like and How Snowflake Reads It

- JSON = **Key-Value Pair** format
- Each record is wrapped in `{}` (curly braces)
- Multiple records are wrapped in `[]` (array / square brackets)
- All semi-structured formats (JSON, XML, Parquet) appear as a **single column** (`$1`) when read from a stage — CSV is different (can have multiple columns)
- Use `$1:key_name` to extract a specific key's value from that single column

> **Interview Question:** How many columns do CSV, JSON, XML, and Parquet files have when read from a stage?
> **Answer:** CSV can have single or more than one column. XML, JSON, and Parquet will have **only a single column** (`$1`).

---

## 2. Database and Schema Setup (Done on 26-Mar-2025)

Before working with JSON, the instructor created the database and schema:

```sql
CREATE DATABASE sales_db;
CREATE SCHEMA sales_schema;

GRANT USAGE ON DATABASE sales_db TO ROLE public;
GRANT USAGE ON SCHEMA sales_schema TO ROLE public;
GRANT USAGE ON WAREHOUSE dev_wh TO ROLE public;
```

Then created the stages for each file type:

```sql
SHOW STAGES;

CREATE STAGE csv_stage;
CREATE STAGE json_stage;
CREATE STAGE xml_stage;
CREATE STAGE parquet_stage;

LIST @csv_stage;
LIST @json_stage;
LIST @xml_stage;
LIST @parquet_Stage;
```

---

## 3. Sample JSON File — sample.json (3 records)

**Keys:** `sno`, `sname`, `course`, `DOJ`

```json
[
  { "sno": 1, "sname": "Tharun",  "course": "Snowflake", "DOJ": "2025-03-15" },
  { "sno": 2, "sname": "Sai",     "course": "Snowflake", "DOJ": "2025-03-15" },
  { "sno": 3, "sname": "Anand",   "course": "Snowflake", "DOJ": "2025-03-15" }
]
```

**Note:** The instructor used `sno`, `sname`, `course`, `DOJ` as key names (not `student_number` etc.).

---

## 4. Uploading Files via SnowSQL (PUT Command)

The `PUT` command can **only** be run from **SnowSQL** (CLI), NOT from the Snowsight web UI.

### Step-by-step SnowSQL workflow (exact from class):

```
C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
```

```sql
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
```

```
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.108s
```

```sql
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use SCHEMA SALES_SCHEMA;
```

```
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.115s
```

```sql
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\sample.json @json_stage;
```

```
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| sample.json | sample.json.gz |         202 |         128 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.616s
```

> **Interview Question:** What does the PUT command do automatically?
> **Answer:** PUT automatically (1) **compresses** the file using GZIP and (2) **encrypts** the file. You can see the `.gz` extension added to the target file name.

> **Common Mistake:** Running PUT from the Snowsight worksheet — it throws `Unsupported feature 'unsupported_requested_format:snowflake'`. You must use SnowSQL CLI.

---

## 5. Reading JSON from the Stage — Why Format Is Needed

```sql
-- Without file format: Snowflake treats files as CSV and gives garbage output
SELECT $1 FROM @json_Stage;

-- With JSON file format: correct JSON parsing
```

First create the file format:

```sql
SHOW FILE FORMATS;

CREATE FILE FORMAT json_format
TYPE = json;
```

Now query works correctly:

```sql
SELECT $1 FROM @json_Stage (file_format=>json_format);
```

> **Key point from instructor:** If you don't define the file format, Snowflake treats the files as CSV. That is why you define the file format.

---

## 6. Extracting Individual Keys — Colon Notation

Use `$1:key_name` to extract a specific key:

```sql
-- Extract individual keys (note: returns values with double quotes around strings)
SELECT $1:sno, $1:sname, $1:course, $1:DOJ
FROM @json_Stage (file_format=>json_format);
```

Cast to remove quotes and get correct data types:

```sql
-- Cast to correct types (::TYPE removes quotes, right-aligns numbers, parses dates)
SELECT $1:sno::NUMBER  AS sno,
       $1:sname::VARCHAR AS sname,
       $1:course::VARCHAR AS course,
       $1:DOJ::DATE    AS doj
FROM @json_Stage (file_format=>json_format);
```

> **Interview Question (instructor emphasis):** Why use `::NUMBER` (cast operator) when extracting from JSON?
> **Answer:** JSON stores everything as text. Without casting, numbers appear left-aligned with double quotes. `::NUMBER` converts the string to an actual number (right-aligned). `::DATE` parses the string as a date value. This is called the **Cast Operator** (double colon `::` syntax).

---

## 7. Two Equivalent Notations for Key Extraction

| Method           | Syntax            | Use Case |
|------------------|-------------------|---------|
| Colon notation   | `$1:key_name`     | Clean key names (most common) |
| Bracket notation | `$1['key_name']`  | Keys with spaces, hyphens, or starting with a digit |

```sql
-- Colon notation
SELECT $1:sno::NUMBER FROM @json_Stage (file_format=>json_format);

-- Bracket notation — identical result for normal key names
SELECT $1['sno']::NUMBER FROM @json_Stage (file_format=>json_format);

-- Bracket notation REQUIRED for special characters:
SELECT $1['student-number']::NUMBER  -- hyphen in key name
SELECT $1['first name']::VARCHAR     -- space in key name
SELECT $1['2024_score']::NUMBER      -- starts with digit
```

---

## 8. Loading Student JSON Data into a Table

### Step 1: Create the table

```sql
CREATE TABLE t_students (
    sno    NUMBER,
    sname  VARCHAR,
    course VARCHAR,
    doj    DATE
);

SELECT * FROM t_students;  -- 0 records initially
```

### Step 2: Load using COPY INTO with transformation subquery

```sql
COPY INTO t_students
FROM (
    SELECT $1:sno::NUMBER   AS sno,
           $1:sname::VARCHAR  AS sname,
           $1:course::VARCHAR AS course,
           $1:DOJ::DATE      AS doj
    FROM @json_Stage (file_format=>json_format)
);
```

Output:
```
status | rows_loaded | errors_seen
-------|-------------|------------
LOADED | 3           | 0
```

```sql
SELECT * FROM t_students;
-- 3 records loaded
```

> **Instructor:** "Now I am able to load the JSON data into a table. What are the different steps? First, I placed the file into the respective stage. After that, I used the file format (JSON format). Then I ran the COPY INTO with a SELECT statement."

---

## 9. Complete Workflow — car.json (324 records)

The instructor walked through the complete workflow with car.json next.

**Sample record from car.json:**
```json
{"id":1,"first_name":"Rohit","last_name":"K","car_make":"Mercedes-Benz","Car_Model":"C-Class","Car_Model_Year":2001}
```

**Note:** Key names are `id`, `first_name`, `last_name`, `car_make`, `Car_Model`, `Car_Model_Year` — watch the case!

### Step 1: Upload via SnowSQL

```
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_stage;
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source   | target      | source_size | target_size | source_compression | target_compression | status   | message |
|----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------|
| car.json | car.json.gz |       38671 |        7232 | NONE               | GZIP               | UPLOADED |         |
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.134s
```

### Step 2: Check how many files are now in the stage

```sql
LIST @json_stage;
-- Two files: sample.json.gz and car.json.gz
```

Use `METADATA$FILENAME` to distinguish them:

```sql
SELECT $1, METADATA$FILENAME
FROM @json_stage (file_format=>json_format);
-- Shows which records come from sample.json.gz and which from car.json.gz
```

### Step 3: Query only the car.json file by path

```sql
SELECT $1:id::NUMBER          AS id,
       $1:first_name::VARCHAR  AS first_name,
       $1:last_name::VARCHAR   AS last_name,
       $1:car_make::VARCHAR    AS car_make,
       $1:Car_Model::VARCHAR   AS Car_Model,
       $1:Car_Model_Year::NUMBER AS Car_Model_Year
FROM @json_stage/car.json.gz (file_format=>json_format);
-- Returns 324 rows
```

### Step 4: Create target table

```sql
CREATE TABLE t_cars_info (
    id             NUMBER,
    first_name     VARCHAR,
    last_name      VARCHAR,
    car_make       VARCHAR,
    car_model      VARCHAR,
    car_model_year NUMBER
);

SELECT * FROM t_cars_info;  -- 0 rows initially
```

### Step 5: Load data

```sql
COPY INTO t_cars_info
FROM (
    SELECT $1:id::NUMBER,
           $1:first_name::VARCHAR,
           $1:last_name::VARCHAR,
           $1:car_make::VARCHAR,
           $1:Car_Model::VARCHAR,
           $1:Car_Model_Year::NUMBER
    FROM @json_stage/car.json.gz (file_format=>json_format)
);
```

> **Error encountered during class:**
> The instructor first ran COPY INTO with the wrong table name (`t_students`). The error was:
> `Insert value list does not match column list. Expecting 4 but got 6.`
> **Fix:** Use the correct table name `t_cars_info` which has 6 columns.

### Step 6: Verify

```sql
SELECT * FROM t_cars_info;
-- 324 records
```

---

## 10. Nested JSON — kids_data.json (Arrays)

The instructor introduced a more complex JSON file with nested arrays.

**Sample from kids_data.json:**
```json
[
  {
    "Name": "Bala",
    "Gender": "male",
    "DOB": "1985-06-15",
    "Kids": ["Pavan", "Chandra"],
    "Kids_School": ["Basha Manchitranna", "DPS"],
    "address": { "house_number": "12-3", "city": "Hyderabad", "state": "Telangana" },
    "phone": { "office_number": "040-12345678", "personal_number": "9876543210" }
  },
  {
    "Name": "Jaya",
    "Gender": "female",
    "DOB": "1990-03-22",
    "Kids": ["Riya", "DPS", "Slate"],
    "Kids_School": ["RINAR", "DPS", "Slate"],
    "address": { "house_number": "45-7", "city": "Delhi", "state": "Delhi" },
    "phone": { "office_number": "011-87654321", "personal_number": "9123456780" }
  }
]
```

### Upload via SnowSQL

```
| kids_data.json | kids_data.json.gz |  655 |  352 | NONE | GZIP | UPLOADED |
```

### Create target table

```sql
CREATE TABLE t_kids_info (
    name            VARCHAR,
    gender          VARCHAR,
    dob             DATE,
    kids_name       VARCHAR,
    kids_School     VARCHAR,
    house_number    VARCHAR,
    city            VARCHAR,
    state           VARCHAR,
    office_number   NUMBER,
    personal_number NUMBER
);

SELECT * FROM t_kids_info;  -- 0 rows
```

### Accessing array elements by index

```sql
-- $1:Kids is an array — access by zero-based index
SELECT $1:Name::VARCHAR  AS Name,
       $1:Gender::VARCHAR AS Gender,
       $1:DOB::DATE       AS DOB,
       $1:Kids[0]         -- first kid (Pavan / Riya)
FROM @json_Stage/kids_data.json.gz (file_format=>json_format);

SELECT $1:Name::VARCHAR  AS Name,
       $1:Gender::VARCHAR AS Gender,
       $1:DOB::DATE       AS DOB,
       $1:Kids[1]         -- second kid
FROM @json_Stage/kids_data.json.gz (file_format=>json_format);

-- Filter out nulls (Bala has no kids[2])
SELECT $1:Name::VARCHAR  AS Name,
       $1:Gender::VARCHAR AS Gender,
       $1:DOB::DATE       AS DOB,
       $1:Kids[2]
FROM @json_Stage/kids_data.json.gz (file_format=>json_format)
WHERE $1:Kids[2] IS NOT NULL;
```

> **Instructor explanation:** "If you see any information within square braces `[]`, that is called an **array**. Within square braces I am giving zero. Zero means the first element. One means the second element."

### Manual UNION approach (not ideal)

```sql
-- Combine all three indices with UNION
SELECT $1:Name::VARCHAR AS Name,
       $1:Gender::VARCHAR AS Gender,
       $1:DOB::DATE AS DOB,
       $1:Kids[0]::VARCHAR value
FROM @json_Stage/kids_data.json.gz (file_format=>json_format)
UNION
SELECT $1:Name::VARCHAR, $1:Gender::VARCHAR, $1:DOB::DATE, $1:Kids[1]
FROM @json_Stage/kids_data.json.gz (file_format=>json_format)
UNION
SELECT $1:Name::VARCHAR, $1:Gender::VARCHAR, $1:DOB::DATE, $1:Kids[2]
FROM @json_Stage/kids_data.json.gz (file_format=>json_format)
WHERE $1:Kids[2] IS NOT NULL;
```

> **Instructor:** "Somebody looks very complicated. What if I have 100 products? Are you going to write 100 queries? Ideally we should not. There should be a way to get the desired output. So I am going to use a function called **LATERAL FLATTEN**."

> **Student Question:** What is the UNION operator?
> **Answer:** UNION combines the results of more than one query. It removes duplicates. If you want to keep duplicates, use UNION ALL.

### LATERAL FLATTEN — the correct solution

```sql
-- See all flatten output columns (SEQ, KEY, PATH, INDEX, VALUE, THIS)
SELECT b.*
FROM @json_Stage/kids_data.json.gz (file_format=>json_format) a,
     lateral flatten($1:Kids) b;

-- Get name, gender, DOB from A plus kid name from B
SELECT a.$1:Name::VARCHAR  AS Name,
       a.$1:Gender::VARCHAR AS Gender,
       a.$1:DOB::DATE       AS DOB,
       b.value::VARCHAR
FROM @json_Stage/kids_data.json.gz (file_format=>json_format) a,
     lateral flatten(a.$1:Kids) b;
```

> **Instructor:** "Lateral flatten will take array as input. You pass the array and the array will internally convert to tabular format. The `value` column holds each element."

### Flattening two aligned arrays (Kids + Kids_School)

The instructor showed that when flattening two arrays, you get a Cartesian product (13 records instead of 5). Fix: join on `INDEX`.

```sql
-- Wrong: Cartesian product gives 13 rows (2×2 + 3×3 = 4+9 = 13)
SELECT c.*
FROM @json_Stage/kids_data.json.gz (file_format=>json_format) a,
     lateral flatten(a.$1:Kids) b,
     lateral flatten(a.$1:Kids_School) c;

-- Correct: join on INDEX to align kids with their schools
SELECT a.$1:Name::VARCHAR  AS Name,
       a.$1:Gender::VARCHAR AS Gender,
       a.$1:DOB::DATE       AS DOB,
       b.value::VARCHAR,
       c.value::VARCHAR
FROM @json_Stage/kids_data.json.gz (file_format=>json_format) a,
     lateral flatten(a.$1:Kids) b,
     lateral flatten(a.$1:Kids_School) c
WHERE c.index = b.index;
```

> **Student Question:** Why are we getting 13 records instead of 5?
> **Answer:** Without the `c.index = b.index` condition, you get a Cartesian product — every kid is paired with every school. The `INDEX` column gives the zero-based position, so INDEX=0 means both the first kid and the first school, INDEX=1 both second, etc.

---

## 11. VARIANT Table — Storing Raw JSON

```sql
LIST @json_stage;

-- Method 1: Store raw JSON (all files) into a VARIANT table
CREATE TABLE t_semi_structed_Data
(c1 variant);

COPY INTO t_semi_structed_Data FROM @json_stage file_format=json_format;

SELECT * FROM t_semi_structed_Data;
```

### Method 2: Store JSON with file name tracking

```sql
CREATE TABLE t_ssd
(file_name varchar, c1 variant);

-- Preview what we'll load:
SELECT METADATA$FILENAME, $1
FROM @json_stage (file_format=>json_format);

-- Load with file name
COPY INTO t_ssd
FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage (file_format=>json_format));

SELECT * FROM t_ssd;
```

### Query data from VARIANT table by file name

```sql
-- Query only sample.json records
SELECT c1 FROM t_ssd WHERE file_name='sample.json.gz';

SELECT c1:sno::NUMBER    AS sno,
       c1:sname::VARCHAR  AS sname,
       c1:course::VARCHAR AS course,
       c1:DOJ::DATE       AS DOJ
FROM t_ssd WHERE file_name='sample.json.gz';

-- Query only car.json records
SELECT c1:id::NUMBER           AS id,
       c1:first_name::VARCHAR  AS first_name,
       c1:last_name::VARCHAR   AS last_name,
       c1:car_make::VARCHAR    AS car_make,
       c1:Car_Model::VARCHAR   AS Car_Model,
       c1:Car_Model_Year::NUMBER AS Car_Model_Year
FROM t_ssd WHERE file_name='car.json.gz';
```

---

## 12. Assigning File Format to a Stage

The instructor demonstrated that `COPY INTO` can fail when no file format is specified if the stage has not been configured:

```sql
TRUNCATE TABLE t_ssd;

-- This FAILS — no file format specified and stage has no default
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);
-- Error: Error parsing JSON

-- Check stage properties:
DESC STAGE json_stage;
-- stage_file_format shows CSV (default)
```

```sql
-- Assign the JSON format to the stage permanently
ALTER STAGE json_stage SET FILE_FORMAT = json_format;

-- Now DESC shows JSON format assigned
DESC STAGE json_stage;
```

Now COPY works without specifying format:

```sql
-- This SUCCEEDS — stage already has json_format assigned
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);
```

> **Interview Question (instructor emphasis — Certification Question Q11):** "A COPY command must specify a file format in order to execute. True or False?"
> **Answer: FALSE.** If the stage already has a file format associated (via `ALTER STAGE ... SET FILE_FORMAT`), the COPY command does NOT need to specify one explicitly.

---

## 13. JSON Key Names Are Case-Sensitive

```sql
-- Key in file is "DOJ" (uppercase)
SELECT $1:DOJ::DATE FROM @json_Stage (file_format=>json_format);  -- CORRECT: returns dates

-- Wrong case returns NULL
SELECT $1:doj::DATE FROM @json_Stage (file_format=>json_format);  -- NULL (key not found)
SELECT $1:Doj::DATE FROM @json_Stage (file_format=>json_format);  -- NULL (key not found)
```

> **Common Mistake:** Getting NULLs when extracting JSON keys — usually caused by wrong case. Key names must match exactly as they appear in the file.

---

## 14. Multiple Files — Using METADATA$FILENAME vs Path

```sql
-- Method 1: See all records with file name label
SELECT $1, METADATA$FILENAME AS source_file
FROM @json_stage (file_format=>json_format);

-- Method 2: Access one file directly by path  
SELECT $1:id::NUMBER AS id
FROM @json_stage/car.json.gz (file_format=>json_format);
```

---

## 15. Key Differences — Accessing JSON Keys

| Method          | Syntax               | When to Use |
|-----------------|----------------------|-------------|
| Colon notation  | `$1:key_name`        | Standard — normal key names |
| Bracket notation| `$1['key_name']`     | Keys with spaces, hyphens, or starting with a digit |
| Chained colon   | `$1:parent:child`    | Nested objects: `$1:address:city` |
| Array index     | `$1:array[0]`        | First element of an array |
| Cast            | `$1:key::TYPE`       | Always cast — otherwise you get string with quotes |

---

## 16. Key Differences — File Format Required in COPY INTO?

| Scenario                                        | File Format Required in COPY? |
|-------------------------------------------------|-------------------------------|
| Stage has no file format assigned               | YES — must specify            |
| Stage has a file format assigned (ALTER STAGE)  | NO — optional                 |
| Using default CSV files                         | Optional (CSV is default)     |
| Loading JSON without format assigned to stage   | YES — will fail without it    |

---

## 17. Snowflake Architecture — Cloud Services Layer (Certification Q)

> **Student Question:** "In which layer of the architecture does Snowflake store the metadata?"
> **Answer:** The **Cloud Services Layer**. This layer handles: metadata management, access control, and authentication. The three layers are: (1) Data Storage Layer — stores data, (2) Query Processing Layer (Virtual Warehouse) — reads/writes, (3) Cloud Services Layer — metadata, access, auth.

---

## 18. Key Commands Summary

```sql
-- File Format Creation
CREATE FILE FORMAT json_format TYPE = json;

-- Upload via SnowSQL (CLI only — not in web UI)
-- PUT file://C:\Users\Balakrishna\...\sample.json @json_stage;
-- PUT file://C:\Users\Balakrishna\...\car.json @json_stage;

-- List files
LIST @json_stage;

-- Remove files from stage
RM @json_stage;

-- Read raw JSON
SELECT $1 FROM @json_Stage (file_format=>json_format);

-- Extract keys
SELECT $1:sno, $1:sname, $1:course, $1:DOJ FROM @json_Stage (file_format=>json_format);

-- Cast to correct types
SELECT $1:sno::NUMBER AS sno,
       $1:sname::VARCHAR AS sname,
       $1:course::VARCHAR AS course,
       $1:DOJ::DATE AS doj
FROM @json_Stage (file_format=>json_format);

-- Track file source
SELECT METADATA$FILENAME, $1 FROM @json_stage (file_format=>json_format);

-- Target specific file
SELECT $1 FROM @json_stage/car.json.gz (file_format=>json_format);

-- COPY INTO with transformation
COPY INTO t_students
FROM (SELECT $1:sno::NUMBER, $1:sname::VARCHAR, $1:course::VARCHAR, $1:DOJ::DATE
      FROM @json_Stage (file_format=>json_format));

-- VARIANT storage
CREATE TABLE t_semi_structed_Data (c1 variant);
COPY INTO t_semi_structed_Data FROM @json_stage file_format=json_format;

-- VARIANT with file tracking
CREATE TABLE t_ssd (file_name varchar, c1 variant);
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage (file_format=>json_format));

-- Query VARIANT column
SELECT c1:sno::NUMBER, c1:sname::VARCHAR FROM t_ssd WHERE file_name='sample.json.gz';

-- Assign format to stage
ALTER STAGE json_stage SET FILE_FORMAT = json_format;

-- LATERAL FLATTEN for arrays
SELECT a.$1:Name::VARCHAR AS Name, b.value::VARCHAR AS kid
FROM @json_Stage/kids_data.json.gz (file_format=>json_format) a,
     lateral flatten(a.$1:Kids) b;

-- Flatten two aligned arrays
SELECT a.$1:Name::VARCHAR, b.value::VARCHAR, c.value::VARCHAR
FROM @json_Stage/kids_data.json.gz (file_format=>json_format) a,
     lateral flatten(a.$1:Kids) b,
     lateral flatten(a.$1:Kids_School) c
WHERE c.index = b.index;

-- Stage and format info
SHOW STAGES;
DESC STAGE json_stage;
SHOW FILE FORMATS;
```

---

## 19. Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `Unsupported feature 'unsupported_requested_format:snowflake'` | Running PUT command in Snowsight web UI | Use SnowSQL CLI instead |
| `Error parsing JSON` | COPY INTO without file format on a JSON file | Add `FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT')` or assign format to stage |
| `Insert value list does not match column list. Expecting 4 but got 6` | Wrong table name used in COPY INTO — table has fewer columns than the SELECT | Use the correct target table (e.g., `t_cars_info` not `t_students`) |
| Returns NULL for all key extractions | JSON key name case mismatch | Match key names exactly as in JSON file (case-sensitive) |
| `SKIPPED` status in PUT output | File already exists in stage with same name | Add `OVERWRITE = TRUE` to the PUT command |
| `Numeric value 'sno' is not recognized` | COPY without file format reads CSV incorrectly | Always specify `FILE_FORMAT` in COPY INTO |

---

## 20. Interview Questions

**Q: What data type is used to store semi-structured data in Snowflake?**
A: **VARIANT**. It can store JSON, XML, Parquet, or any semi-structured data.

**Q: How many columns does a JSON file have when queried from a stage?**
A: Always exactly **one column** (`$1`). XML and Parquet also have one column. Only CSV can have multiple columns.

**Q: Does COPY INTO require a file format?**
A: **No** (False). If the stage already has a file format assigned via `ALTER STAGE ... SET FILE_FORMAT`, the COPY INTO does not need to specify one explicitly.

**Q: What is the difference between colon notation and bracket notation for JSON key access?**
A: Both are equivalent for normal key names. Bracket notation (`$1['key']`) is required when the key contains spaces, hyphens, or starts with a digit.

**Q: What does METADATA$FILENAME do?**
A: It is a virtual column provided by Snowflake that returns the source file name for each row read from a stage. Useful when multiple files are in the same stage.

**Q: Why are JSON key names case-sensitive in Snowflake?**
A: Because Snowflake preserves the original JSON structure. `$1:DOJ` and `$1:doj` are different keys. Always match the exact case as it appears in the JSON file.

**Q: What is the LATERAL FLATTEN function used for?**
A: LATERAL FLATTEN expands a JSON/XML array into individual rows. It takes an array as input and returns one row per element, with a `VALUE` column holding each element's value.

**Q: Can COPY INTO be used with LATERAL FLATTEN?**
A: No. COPY INTO only supports simple SELECT statements (not complex functions like LATERAL FLATTEN or XMLGET). Use `INSERT INTO ... SELECT` instead.

**Q: What is UNION operator? How is it different from UNION ALL?**
A: Both combine results of multiple queries. UNION removes duplicates. UNION ALL keeps all rows including duplicates (faster).

**Q: What does the `::` operator do in Snowflake?**
A: It is the **Cast Operator** — it converts a value from one data type to another. For example, `$1:sno::NUMBER` converts the JSON string `"1"` to the number `1`. It removes surrounding double quotes from string values.

---

## 21. Try It Yourself Exercises

**Exercise 1:** Upload `car.json` to `json_stage` and query all 324 records using METADATA$FILENAME to confirm the source file.

```sql
-- Hint:
SELECT $1, METADATA$FILENAME
FROM @json_stage (file_format=>json_format);
-- Answer: All 324 rows should show 'car.json.gz' in METADATA$FILENAME
```

**Exercise 2:** Extract only `id`, `first_name`, and `car_make` from `car.json.gz` with correct data types.

```sql
-- Answer:
SELECT $1:id::NUMBER AS id,
       $1:first_name::VARCHAR AS first_name,
       $1:car_make::VARCHAR AS car_make
FROM @json_stage/car.json.gz (file_format=>json_format);
```

**Exercise 3:** Load sample.json into t_students and verify 3 records were loaded. Then run SELECT * to confirm.

```sql
-- Answer:
COPY INTO t_students
FROM (
    SELECT $1:sno::NUMBER, $1:sname::VARCHAR, $1:course::VARCHAR, $1:DOJ::DATE
    FROM @json_Stage (file_format=>json_format)
    WHERE METADATA$FILENAME LIKE '%sample%'
);
SELECT * FROM t_students;
```

**Exercise 4:** Store both sample.json and car.json into t_ssd with the file name column, then query only the car.json records.

```sql
-- Answer:
COPY INTO t_ssd
FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage (file_format=>json_format));

SELECT c1:id::NUMBER AS id, c1:first_name::VARCHAR AS first_name
FROM t_ssd
WHERE file_name = 'car.json.gz'
LIMIT 5;
```

**Exercise 5:** Assign `json_format` to `json_stage`, then run COPY INTO t_ssd without specifying any file format and confirm it succeeds.

```sql
-- Answer:
ALTER STAGE json_stage SET FILE_FORMAT = json_format;
TRUNCATE TABLE t_ssd;
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);
SELECT COUNT(*) FROM t_ssd;  -- Should load all records
```

---

## 22. Summary

- JSON is a **key-value pair** format; extract values using `$1:key_name::TYPE`
- XML, JSON, Parquet from a stage always have **only one column** (`$1`); CSV can have many
- Always use `::DATATYPE` (Cast) to get properly typed values — removes double quotes, right-aligns numbers
- Multiple JSON files in a stage process together; use `METADATA$FILENAME` to track sources, or `/filename.gz` path to target one file
- Store raw JSON in `VARIANT` columns — flexible, extract keys at query time
- Attaching a file format to a stage via `ALTER STAGE ... SET FILE_FORMAT` removes the need to specify it in every `COPY INTO`
- `COPY INTO` does **not** require an explicit file format if the stage already has one assigned (Certificate Q — answer is FALSE)
- JSON key names are **case-sensitive** — `DOJ` ≠ `doj`
- Use **LATERAL FLATTEN** to expand JSON arrays into rows; `b.value` holds each element
- When flattening two arrays in the same record, join on `b.index = c.index` to avoid Cartesian products
- **COPY INTO** does not support LATERAL FLATTEN — use `INSERT INTO ... SELECT` instead
