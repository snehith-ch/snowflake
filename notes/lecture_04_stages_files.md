# Lecture 4: Stages — Concepts, Internal Stages, and File Operations

## Quick Revision — Lecture 4

| # | Key Point |
|---|-----------|
| 1 | A stage is a named file storage LOCATION — like a folder (C:\ D:\ E:\ analogy) |
| 2 | Internal stages: User (`@~`), Table (`@%table_name`), Named (`@stage_name`) |
| 3 | User stage and Table stage are auto-created; Named stage must be created with CREATE STAGE |
| 4 | LIST command — see files in a stage; PUT command — upload files to a stage |
| 5 | PUT can ONLY be run in SnowSQL (CLI) — NOT in Snowsight worksheet |
| 6 | PUT automatically COMPRESSES (gzip) and ENCRYPTS files |
| 7 | By default, ALL stages treat files as CSV regardless of the stage name or file type |
| 8 | File Format object tells Snowflake how to parse a file (type, delimiter, skip_header) |
| 9 | COPY INTO table FROM @stage FILE_FORMAT = (FORMAT_NAME = 'format_name') — load command |
| 10 | SnowSQL login: `snowsql -a <account_name> -u <username>` |

---

**Pre-requisite:** Lecture 3 — Account Setup, DDL, Roles Deep Dive, and Date Functions
**Next:** Lecture 5 — COPY Command, Semi-Structured Data, and JSON Basics
**Related:** Lecture 2 — RBAC and Privilege Granting (needed before loading data as non-admin)

---

## Objects Created This Lecture

| Object Type | Name             | Purpose                                              |
|-------------|------------------|------------------------------------------------------|
| Database    | SALES_DB         | Database for file loading demos                      |
| Schema      | SALES_SCHEMA     | Schema for file loading demos                        |
| Stage       | CSV_STAGE        | Named stage for CSV files                            |
| Stage       | JSON_STAGE       | Named stage for JSON files                           |
| Stage       | XML_STAGE        | Named stage for XML files                            |
| Stage       | PARQUET_STAGE    | Named stage for Parquet files                        |
| File Format | FILE_CSV_FORMAT  | CSV file format (skip header, comma delimiter)       |
| Table       | T_STUDENT_INFO   | Student info table used with user stage demo         |
| Table       | EMP              | Employee table used in COPY INTO demo                |
| User        | KRANTHI          | Demo user for stage operations                       |

---

## ASCII Data Flow Diagram

```
Local Machine (Windows)
         |
         | PUT command (SnowSQL only)
         |  Compresses (gzip) + Encrypts
         v
  Snowflake Internal Stage
  ┌─────────────────────────────────────────────┐
  │  User Stage  (@~)     — per user            │
  │  Table Stage (@%emp)  — per table           │
  │  Named Stage (@csv_stage, @json_stage ...)  │
  └─────────────────────────────────────────────┘
         |
         | SELECT $1,$2,$3 FROM @stage  (inspect data)
         | COPY INTO table FROM @stage  (load data)
         v
    Snowflake Table
         |
         | SELECT * FROM table  (query loaded data)
         v
      Results
```

---

## 1. What is a Stage?

A **stage** in Snowflake is a **named location** where files are stored before they are loaded into tables (or after they are unloaded from tables). Think of it as a "landing zone" for files.

**Windows Analogy used in class:**

```
Windows File System          Snowflake
─────────────────────────── ─────────────────────────────────
C:\ drive               →   User Stage  (@~)
D:\ drive               →   Table Stage (@%table_name)
E:\ drive               →   Named Stage (@stage_name)
```

> Krishna: "So what are the different stages we have? So in Windows, what are all the places I can place the different files is? In Windows, we have C drive, D drive and different drives. In Snowflake also, you can place the files. But you won't call that as a location, you will call it as a stage. So a stage is nothing but a location, guys."

> A stage is not a database object you store data in permanently — it is a **temporary file storage area** used during the data loading (and unloading) process.

---

## 2. Types of Stages

```
Snowflake Stages
├── Internal Stages (files stored inside Snowflake)
│   ├── User Stage   @~                (auto-created per user)
│   ├── Table Stage  @%table_name      (auto-created per table)
│   └── Named Stage  @stage_name       (user-created, most flexible)
└── External Stages (files stored in cloud provider)
    ├── AWS S3
    ├── Azure Blob Storage
    └── Google Cloud Storage
```

### 2.1 Internal Stages

Files are stored **inside Snowflake's own storage**. No external cloud account needed.

| Stage Type  | Notation          | Creation              | Notes                                    |
|-------------|-------------------|-----------------------|------------------------------------------|
| User Stage  | `@~`              | Auto-created per user | Every user has one automatically         |
| Table Stage | `@%table_name`    | Auto-created per table| Every table has one automatically        |
| Named Stage | `@stage_name`     | Created by user (`CREATE STAGE`) | Most flexible — can be shared |

> **Important:** You **cannot** manually create a User Stage or Table Stage — they are created automatically. Only **Named Stages** can be explicitly created.

> Krishna: "If I create a user, user stage will be automatically available. If I create a table, table stage will be automatically available. So they may ask you a question. Can you create a user stage and table stage? No, right. We cannot create those stages. They will create it automatically. Now, can you create a name stage? Yes."

> **Interview Question:** Can you create a User Stage or Table Stage?
> **Answer:** No. User Stage and Table Stage are automatically created when a user or table is created. You can only explicitly create Named Stages using `CREATE STAGE`.

### 2.2 External Stages

Files are stored in a **cloud provider's object storage** (S3, Azure Blob, GCS). Covered in later lectures.

---

## 3. Stage Notation Summary

```sql
-- User Stage
@~                     -- Current user's stage

-- Table Stage
@%TABLE_NAME           -- Stage for a specific table

-- Named Stage
@STAGE_NAME            -- Named stage you created
```

> Krishna: "How you are going to denote the user stage? At the rate tilde. At the rate percentage table name — this is called table stage. At the rate stage name — this is called name stage."

---

## 4. Commands for Working with Stages

### 4.1 LIST — View Files in a Stage

```sql
-- List files in User Stage (current user — KRANTHI or KRISHNA)
LIST @~;

-- List files in Table Stage
LIST @%T_STUDENT_INFO;

-- List files in a Named Stage
LIST @CSV_STAGE;
LIST @JSON_STAGE;
```

> Krishna (demonstrating with KRANTHI user): "Now if I say list at the rate tilt. So I don't see any files right? In this particular user there are no files in this particular user stage."

### 4.2 SHOW STAGES — View All Named Stages

```sql
SHOW STAGES;

-- Alternatively, query INFORMATION_SCHEMA
SELECT * FROM INFORMATION_SCHEMA.STAGES;
```

> **Difference:** `SHOW STAGES` shows stages in the **current schema only**. `INFORMATION_SCHEMA.STAGES` shows stages across **all schemas** in the current database.

### 4.3 CREATE STAGE — Create a Named Stage

```sql
-- Create stages for different file types (from class)
CREATE STAGE CSV_STAGE;
CREATE STAGE JSON_STAGE;
CREATE STAGE XML_STAGE;
CREATE STAGE PARQUET_STAGE;
```

> Krishna: "My requirement is all the CSV files, I want to place it into CSV stage. All the JSON files, I want to place it into JSON stage. What is this XML stage? I want to place this file into my XML stage. And what do you mean by a parquet? I want to place the parquet file into parquet stage. That is the reason I have created four stages."

### 4.4 DESCRIBE STAGE — View Stage Properties

```sql
DESCRIBE STAGE CSV_STAGE;
-- or
DESC STAGE CSV_STAGE;
```

Output shows: file format type, field delimiter, skip header setting, etc.

> **Important finding from class:** Ran `DESC STAGE CSV_STAGE` and `DESC STAGE JSON_STAGE`:
> Both showed `type=CSV, field_delimiter=COMMA, skip_header=0`
>
> Krishna: "So this is also CSV stage, guys. See, you have just given the name as JSON. Name as XML. So that doesn't mean that this stage is holding CSV or XML or JSON. Do remember, if you create any stage, Snowflake treats all the files inside the stage as CSV files."

### 4.5 REMOVE — Delete Files from a Stage

```sql
-- Remove a specific file from a stage
RM @JSON_STAGE/sample.json.gz;

-- Remove ALL files from a stage
RM @JSON_STAGE;
```

> Class demo: "How to remove that file? RM at the right stage name. Can you see the message? The file is removed. Let me verify the files. I don't have any files."

---

## 5. Reading Data Directly from a Stage

You can query data directly from a stage **before** loading it into a table. This is useful for inspection and transformation.

### Dollar Notation for Columns

For **CSV files**, columns are referenced as `$1`, `$2`, `$3`, etc.:

```sql
-- Read all columns from CSV file in user stage (from class)
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 FROM @~/emp.csv.gz;

-- Read using file format to skip header
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 FROM @~/emp.csv.gz (FILE_FORMAT=>FILE_CSV_FORMAT);
```

For **JSON, XML, Parquet**, there is only **one column** (`$1`) because these formats are semi-structured.

```sql
-- Read from JSON stage — returns a single column
SELECT $1 FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT');
```

> Krishna: "CSV will have single or more than one column. XML, JSON, Parquet — these files will have only single column, only single column. You got my point, right? Except CSV, all the other files will have only single column. What is that column? Dollar one."

> **Interview Question:** How many columns do CSV files have vs JSON/XML/Parquet files when read from a stage?
> **Answer:** CSV can have multiple columns (`$1`, `$2`, `$3`…). JSON, XML, and Parquet always have **only ONE column** (`$1`) when read from a stage — because they are semi-structured.

---

## 6. The PUT Command — Uploading Files to a Stage

The `PUT` command uploads a file from your **local machine** into a Snowflake stage.

> **Critical Note:** `PUT` cannot be executed in the Snowflake web UI (Snowsight). It can **only** be executed through **SnowSQL** (the command-line interface).

> Krishna: "So can I write this command in the Snowflake user interface? No right. In the worksheet you cannot execute the put command correct. So how can I place a file in that scenario? What I need to do? I need to use SnowSQL."

### Syntax

```
PUT file://path/to/file @stage_name
```

### Class Examples (actual paths from Daily Notes.sql)

```
-- Uploading files to named stages
PUT file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_stage;
PUT file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_stage;
PUT file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\books_info.xml @xml_stage;
PUT file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\MT_cars.parquet @parquet_stage;

-- Uploading to user stage
PUT file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;
```

### Actual SnowSQL Output from Class

```
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
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+

krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\books_info.xml @xml_Stage;
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| books_info.xml | books_info.xml.gz |        4607 |        1408 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+

krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\MT_cars.parquet @parquet_Stage;
+-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source          | target          | source_size | target_size | source_compression | target_compression | status   | message |
|-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| MT_cars.parquet | MT_cars.parquet |        2932 |        2944 | PARQUET            | PARQUET            | UPLOADED |         |
+-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------+
```

Note: Parquet is NOT re-compressed (already Parquet format), but CSV/JSON/XML are gzip compressed.

### What PUT Does Automatically

1. **Compresses** the file (using gzip — `.gz` extension added)
2. **Encrypts** the file
3. Uploads it to the stage

```sql
-- After PUT, file name appears with .gz extension
LIST @JSON_STAGE;
-- Output: sample.json.gz   car.json.gz
```

> **Interview Question:** "What does the PUT command do automatically?"
> **Answer:** Automatically **compresses** the file using gzip and **encrypts** it before uploading.

### Uploading the Same File Again — OVERWRITE

If you `PUT` the same file to the same stage again, Snowflake **skips** it by default:

```
-- First upload (status = UPLOADED)
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| student.csv | student.csv.gz |          91 |         112 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+

-- Second upload of same file (status = SKIPPED)
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;
+-------------+----------------+-------------+-------------+--------------------+--------------------+---------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status  | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+---------+---------|
| student.csv | student.csv.gz |          81 |           0 | NONE               | GZIP               | SKIPPED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+---------+---------+
```

To force re-upload use `OVERWRITE=TRUE`:

```
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~ OVERWRITE=true;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| student.csv | student.csv.gz |          81 |         112 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
```

---

## 7. Installing SnowSQL (CLI)

SnowSQL is Snowflake's command-line interface — required for the `PUT` command.

> Krishna (in class): "In case for your information let me uninstall that and I will reinstall one more time. Go to control panel. Uninstall the existing one. SnowSQL. Uninstall."

### Installation

1. Search for "SnowSQL download" → go to Snowflake documentation site
2. Download the Windows installer for the correct version (instructor used v1.3.2)
3. Run the installer (click Next → Install → Finish)

### Connecting via SnowSQL

```
snowsql -a <account_name> -u <username>
```

- **Account name**: found in your Snowflake URL (e.g., `iscutgw-jp34947` from `iscutgw-jp34947.snowflakecomputing.com`)
- Enter password when prompted

### SnowSQL Session — Actual Class Output

```
C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE DEV_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.115s
krishna#COMPUTE_WH@DEV_DB.PUBLIC>use SCHEMA DEV_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.102s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>
```

> The SnowSQL prompt shows: `username#warehouse@database.schema>` — tells you your current context.

---

## 8. File Formats

A **File Format** is a named object that describes how a file should be parsed. It specifies:
- The type of file (CSV, JSON, XML, Parquet)
- Delimiters (for CSV)
- Whether to skip the header row
- Quote characters
- Null handling

### Why File Formats Are Needed

By default, Snowflake treats every file in a stage as a **CSV file**. When you have JSON, XML, or Parquet files, you must specify the correct file format so Snowflake parses them correctly.

> Krishna: "By default, whatever the stage that you have created, Snowflake treats the files as CSV files. Wherever it finds a comma, it treats that is the first column. This is the second column. But that is not true, right? So for that reason, what we need to do? We need to create a file format."

### Creating File Formats (from class)

```sql
-- CSV file format (created in class for SALES_DB)
CREATE FILE FORMAT FILE_CSV_FORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n';

-- JSON file format — type alone is sufficient
CREATE FILE FORMAT JSON_FORMAT
    TYPE = JSON;

-- XML file format
CREATE FILE FORMAT XML_FORMAT
    TYPE = XML;

-- Parquet file format
CREATE FILE FORMAT PARQUET_FORMAT
    TYPE = PARQUET;
```

### CSV File Format Parameters Explained

| Parameter         | Description                                              | Class Value |
|-------------------|----------------------------------------------------------|-------------|
| `TYPE`            | File type: CSV, JSON, XML, PARQUET                       | `CSV`       |
| `SKIP_HEADER`     | Number of header rows to skip                            | `1`         |
| `FIELD_DELIMITER` | Character separating fields within a row                 | `','`       |
| `RECORD_DELIMITER`| Character separating rows (`\n` = newline)               | `'\n'`      |

> Student question about field_delimiter and record_delimiter:
> Krishna: "How each field is separated? That is called field delimiter. Field delimiter is comma. How each record is separated? Next line, right? Each record is present in the next line. That is called record delimiter."

### Viewing File Formats

```sql
-- Method 1
SHOW FILE FORMATS;

-- Method 2
SELECT * FROM INFORMATION_SCHEMA.FILE_FORMATS;
```

### Granting File Format Access to a Role

```sql
GRANT USAGE ON FILE FORMAT FILE_CSV_FORMAT TO ROLE PUBLIC;

-- Revoke example
REVOKE USAGE ON FILE FORMAT FILE_CSV_FORMAT FROM ROLE PUBLIC;
```

---

## 9. Loading Data via the Snowsight UI (Drag and Drop)

Snowsight provides a **visual data loading** option (demonstrated in lecture 4):

1. Go to **Databases → [db] → [schema] → Tables**
2. Click **Create** → **From File**
3. Browse and select your CSV file
4. Configure options:
   - **First line contains header** → gets column names from header (vs C1, C2, C3...)
   - **Skip header equal to 1** → skips first line
   - **Field delimiter** = comma
   - **Record delimiter** = next line
5. Give the table a name (e.g., `T_STD_INFO`)
6. Click **Load**

> Krishna (demonstrating): "Now let me understand this. What is this header? Do you want to skip the header? Yes. Skip first line. Field delimiter is comma. Record delimiter is next line. So this is to describe the file. How the file is looking like."

> **What happens if you don't check "first line contains header"?**
> You get column names `C1`, `C2`, `C3`, `C4` instead of the actual column names. Snowflake cannot read them because it's treating the header as data.

> **Class result:** "Two records were successfully loaded. Click on done. Now can you see these values, guys? Student number one, student name, Sunil, course, Snowflake."

---

## 10. COPY INTO — Loading Data from Stage to Table

The `COPY INTO` command loads data from a stage into a table.

### Syntax

```sql
-- Basic syntax
COPY INTO table_name
FROM @stage_name
FILE_FORMAT = (FORMAT_NAME = 'format_name');

-- With transformation (subquery)
COPY INTO table_name
FROM (SELECT column1, column2 FROM @stage_name FILE_FORMAT = (FORMAT_NAME = 'format_name'));
```

### Class Example — Loading emp.csv into emp table

```sql
-- Create target table (from class - SALES_DB)
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

-- Grant permissions
GRANT SELECT ON TABLE EMP TO ROLE PUBLIC;
GRANT INSERT ON TABLE EMP TO ROLE PUBLIC;

-- Inspect file before loading
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 FROM @~/emp.csv.gz;
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 FROM @~/emp.csv.gz (FILE_FORMAT=>FILE_CSV_FORMAT);

-- Load data
COPY INTO EMP FROM @~/emp.csv.gz FILE_FORMAT=FILE_CSV_FORMAT;
-- Status: LOADED, 25 rows
```

### COPY INTO Output

```
status | rows_loaded | errors_seen | first_error
-------|-------------|-------------|------------
LOADED | 25          | 0           | NULL
```

---

## 11. Granting Privileges for Loading Data

For a non-admin user to run `COPY INTO`, they need the `INSERT` privilege on the target table:

```sql
-- Grant INSERT on table
GRANT INSERT ON TABLE EMP TO ROLE PUBLIC;

-- Grant SELECT on table (for reading/verifying)
GRANT SELECT ON TABLE EMP TO ROLE PUBLIC;
```

> Class demo: "Can I run this command? What is the message that you are getting? Insufficient privileges. Why you are getting insufficient privileges? You are able to see the data right. You are able to run the select statement, but why you are not able to run the copy command? Copy is nothing but inserting, right. So the point is you don't have an insert privilege. Let me use insert, let me give insert here."

---

## 12. Complete Data Loading Workflow (ASCII Diagram)

```
Step 1: Install SnowSQL
   snowsql -a iscutgw-jp34947 -u krishna

Step 2: Connect to right database and schema in SnowSQL
   USE DATABASE SALES_DB;
   USE SCHEMA SALES_SCHEMA;

Step 3: Verify stage is empty
   LIST @CSV_STAGE;
   -- 0 rows

Step 4: Upload file via PUT
   PUT file://C:\path\to\emp.csv @CSV_STAGE;
   -- status: UPLOADED, target: emp.csv.gz

Step 5: Back in Snowsight — verify file is in stage
   LIST @CSV_STAGE;
   -- emp.csv.gz   1531 bytes

Step 6: Inspect data from stage (before loading)
   SELECT $1,$2,$3 FROM @CSV_STAGE (FILE_FORMAT=>FILE_CSV_FORMAT);

Step 7: Create file format (if not already done)
   CREATE FILE FORMAT FILE_CSV_FORMAT TYPE=CSV SKIP_HEADER=1 FIELD_DELIMITER=',';

Step 8: Load with COPY INTO
   COPY INTO EMP FROM @CSV_STAGE FILE_FORMAT=(FORMAT_NAME='FILE_CSV_FORMAT');
   -- LOADED | 25 rows | 0 errors

Step 9: Verify data
   SELECT * FROM EMP;
   -- 25 rows returned
```

---

## 13. JSON Format — Introduction (Covered at End of Lecture 4)

> Krishna introduced stages with JSON files. He showed car.json and explained the structure.

JSON is a **key-value pair** format. Example:

```json
{
  "student_number": 1,
  "student_name": "Tharun",
  "course": "Snowflake",
  "date_of_joining": "2025-03-15"
}
```

> Krishna: "And one more point is, what is JSON guys? JSON is a key value pair. And how to identify the JSON file? It will be within this particular basis. This is called curly braces. If I have to explain you about JSON format, it is like a key-value. JSON is nothing but a key value pair."

The class created `sample.json` with these 3 records and uploaded it:

```
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\sample.json @json_stage;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| sample.json | sample.json.gz |         202 |         128 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
```

(JSON reading from stage and COPY INTO for JSON is covered in Lecture 5.)

---

## 14. Key Differences — Stage Types Compared

| Feature            | User Stage (`@~`)       | Table Stage (`@%table`) | Named Stage (`@stage`) |
|--------------------|------------------------|------------------------|------------------------|
| Auto-created?      | Yes (per user)         | Yes (per table)        | No — user must create  |
| Notation           | `@~`                   | `@%table_name`         | `@stage_name`          |
| Can be shared?     | No (private to user)   | No (tied to table)     | Yes                    |
| Can be deleted?    | No                     | No                     | Yes (`DROP STAGE`)     |
| Use case           | Quick personal uploads | Loading one specific table | Production ETL, shared pipelines |

### File Format: CSV Parameters vs JSON/XML/Parquet

| Parameter       | CSV               | JSON         | XML          | Parquet      |
|-----------------|-------------------|--------------|--------------|--------------|
| TYPE            | `CSV`             | `JSON`       | `XML`        | `PARQUET`    |
| SKIP_HEADER     | Required (1 or 0) | Not needed   | Not needed   | Not needed   |
| FIELD_DELIMITER | Required (`,`)    | Not needed   | Not needed   | Not needed   |
| RECORD_DELIMITER| Optional (`\n`)   | Not needed   | Not needed   | Not needed   |
| Columns in stage| Multiple ($1..$n) | ONE ($1 only)| ONE ($1 only)| ONE ($1 only)|

---

## 15. Key Commands Summary

```sql
-- Stage Management
CREATE STAGE stage_name;
SHOW STAGES;
SELECT * FROM INFORMATION_SCHEMA.STAGES;
LIST @stage_name;
DESCRIBE STAGE stage_name;
RM @stage_name/file_name;
RM @stage_name;       -- Remove ALL files

-- File Formats
CREATE FILE FORMAT format_name
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n';
CREATE FILE FORMAT format_name TYPE = JSON;
SHOW FILE FORMATS;
SELECT * FROM INFORMATION_SCHEMA.FILE_FORMATS;
DESCRIBE FILE FORMAT format_name;

-- Granting file format access
GRANT USAGE ON FILE FORMAT format_name TO ROLE role_name;
REVOKE USAGE ON FILE FORMAT format_name FROM ROLE role_name;

-- Loading Data
SELECT $1,$2,$3 FROM @stage_name (FILE_FORMAT=>format_name);

COPY INTO table_name
FROM @stage_name
FILE_FORMAT = (FORMAT_NAME = 'format_name');

-- SnowSQL CLI
-- snowsql -a <account> -u <username>
-- USE DATABASE db_name;
-- USE SCHEMA schema_name;
-- PUT file://local/path/file.csv @stage_name;
-- PUT file://local/path/file.csv @stage_name OVERWRITE=TRUE;
-- LIST @stage_name;
```

---

## 16. Common Errors Table

| Error Message | Cause | Fix |
|---------------|-------|-----|
| "Unsupported feature 'unsupported_requested_format:snowflake'" | Tried to run PUT in Snowsight worksheet | Use SnowSQL (CLI) for PUT command |
| Status = SKIPPED when running PUT | File already exists in stage with same name | Add `OVERWRITE=TRUE` to PUT command |
| "Numeric value 'sno' is not recognized" during COPY INTO | Header row is being loaded as data | Specify `SKIP_HEADER=1` in file format |
| "Numeric value 'BALA' is not recognized" during INSERT | Inserting a VARCHAR into a NUMBER column | Fix data type or use correct column |
| "No warehouse" when querying from stage in Snowsight | Warehouse not selected | Set warehouse via USE WAREHOUSE or UI dropdown |
| "Insufficient privileges" on COPY INTO | Role has SELECT but not INSERT on target table | `GRANT INSERT ON TABLE ... TO ROLE ...` |

---

## 17. Q&A from This Lecture

> **Student Question:** What are the limitations of a user stage?
> **Answer (Krishna):** I will come to that. We will try to talk about the differences. (Covered more in next lecture.) Key limitation: User stage is private — only the owning user can access it. Named stages can be shared across roles.

> **Student Question:** Do we create users and grant roles in real time on the job?
> **Answer (Krishna):** No, no, no. You don't have a privilege. Everything is done by security admin. This is not your responsibility. But this is good to know.

> **Student Question:** Why is there a `file_format` parameter when selecting from a stage — why not just read the file directly?
> **Answer (Krishna):** By default, Snowflake treats everything as CSV. If you read a JSON file without a file format, wherever it finds a comma, it treats that as a column separator — giving garbled output. The file format tells Snowflake the actual structure.

---

## 18. Interview Questions

**Q: What is a stage in Snowflake?**
A: A stage is a named location (file storage area) where files are temporarily held before loading into tables or after unloading from tables. It's like a C:\ or D:\ drive in Windows.

**Q: What are the three types of internal stages?**
A: User Stage (`@~`) — auto-created per user; Table Stage (`@%table_name`) — auto-created per table; Named Stage (`@stage_name`) — explicitly created with `CREATE STAGE`.

**Q: Can you create a User Stage or Table Stage manually?**
A: No. User Stages and Table Stages are automatically created by Snowflake when a user or table is created. Only Named Stages can be manually created.

**Q: What command is used to upload a file to a stage?**
A: `PUT` command — but it can only be run in SnowSQL (CLI), not in the Snowsight web UI.

**Q: What does the PUT command do automatically?**
A: Compresses the file (gzip — adds `.gz` extension) and encrypts it before uploading.

**Q: If you run PUT with the same file twice, what happens?**
A: The second upload will have `status = SKIPPED`. Snowflake skips re-uploading a file that already exists in the stage. Use `OVERWRITE=TRUE` to force the upload.

**Q: What does a File Format do?**
A: It tells Snowflake how to parse a file — the type (CSV/JSON/XML/Parquet), field delimiter, whether to skip the header, quote character, etc. Without a correct file format, Snowflake treats everything as CSV.

**Q: What is the difference between SHOW STAGES and INFORMATION_SCHEMA.STAGES?**
A: `SHOW STAGES` shows stages in the current schema only. `INFORMATION_SCHEMA.STAGES` shows stages across all schemas in the current database.

**Q: What privileges does a role need to run COPY INTO?**
A: USAGE on database, USAGE on schema, USAGE on warehouse, SELECT on table (to query), INSERT on table (to write/load), and access to the file format.

**Q: By default, how does Snowflake treat all files in a stage?**
A: As CSV files, regardless of the stage name or actual file format. To use JSON, XML, or Parquet, you must create the appropriate file format and specify it in your query or COPY INTO.

---

## 19. Try It Yourself Exercises

**Exercise 1:** Create four stages: CSV_STAGE, JSON_STAGE, XML_STAGE, PARQUET_STAGE. Verify them with SHOW STAGES and INFORMATION_SCHEMA.STAGES.
```sql
CREATE STAGE CSV_STAGE;
CREATE STAGE JSON_STAGE;
CREATE STAGE XML_STAGE;
CREATE STAGE PARQUET_STAGE;
SHOW STAGES;
SELECT * FROM INFORMATION_SCHEMA.STAGES;
```

**Exercise 2:** Create a CSV file format with skip_header=1, comma delimiter, newline record delimiter. Then grant it to role PUBLIC. Verify with SHOW FILE FORMATS.
```sql
CREATE FILE FORMAT MY_CSV_FORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n';
GRANT USAGE ON FILE FORMAT MY_CSV_FORMAT TO ROLE PUBLIC;
SHOW FILE FORMATS;
```

**Exercise 3:** Use SnowSQL to connect to your Snowflake account. Run `LIST @~;` to verify your user stage is empty, then list a named stage.
```
snowsql -a <your_account> -u <your_username>
USE DATABASE <your_db>;
USE SCHEMA <your_schema>;
LIST @~;
LIST @csv_stage;
```

**Exercise 4:** Describe your CSV_STAGE and JSON_STAGE. Notice that both show CSV as the default format even though you named one JSON_STAGE.
```sql
DESC STAGE CSV_STAGE;
DESC STAGE JSON_STAGE;
-- Both will show TYPE=CSV, field_delimiter=COMMA
```

**Exercise 5:** Create a simple table EMP_TEST (EMPNO NUMBER, ENAME VARCHAR, SAL NUMBER). Grant INSERT and SELECT to your role. Then read from a user stage (after PUT via SnowSQL) and run COPY INTO.
```sql
CREATE TABLE EMP_TEST (EMPNO NUMBER, ENAME VARCHAR, SAL NUMBER);
GRANT SELECT ON TABLE EMP_TEST TO ROLE PUBLIC;
GRANT INSERT ON TABLE EMP_TEST TO ROLE PUBLIC;
-- In SnowSQL: PUT file://path/to/emp.csv @~;
-- In Snowsight:
SELECT $1,$2,$3 FROM @~ (FILE_FORMAT=>MY_CSV_FORMAT);
COPY INTO EMP_TEST FROM @~ FILE_FORMAT=(FORMAT_NAME='MY_CSV_FORMAT');
SELECT * FROM EMP_TEST;
```

---

## 20. Key Terms

| Term          | Definition                                                                   |
|---------------|------------------------------------------------------------------------------|
| Stage         | A named location (internal or external) where files are stored               |
| User Stage    | Auto-created stage for each user (`@~`)                                       |
| Table Stage   | Auto-created stage for each table (`@%tablename`)                             |
| Named Stage   | A stage explicitly created with `CREATE STAGE`                               |
| PUT           | SnowSQL command to upload a file from local to a stage (compresses + encrypts)|
| LIST          | Command to view files in a stage                                              |
| RM            | Command to remove a file from a stage                                         |
| COPY INTO     | Command to load data from a stage into a table                               |
| File Format   | Named object describing how to parse a file (CSV, JSON, XML, Parquet)        |
| SnowSQL       | Snowflake's command-line interface (CLI) — required for PUT command           |
| Dollar Notation | `$1`, `$2`, etc. — positional column references when reading from a stage  |
| SKIP_HEADER   | File format parameter — number of header rows to skip (usually 1)            |
| FIELD_DELIMITER | Character separating fields in a CSV row (comma by default)                |
| OVERWRITE=TRUE | PUT parameter to force re-upload of a file that already exists in the stage |

---

## 21. Summary

- A **stage** is a file storage location — think of it as a folder inside (or outside) Snowflake
- **Internal stages**: User (`@~`), Table (`@%table`), Named (`@stage_name`)
- User and Table stages are **auto-created**; Named stages are created with `CREATE STAGE`
- The **PUT command** uploads local files to a stage — only works in **SnowSQL** (CLI), not in the web UI
- PUT automatically **compresses** (gzip) and **encrypts** files
- A **File Format** tells Snowflake how to parse a file — critical for non-CSV formats
- By default, all stages treat files as CSV — assign a JSON/XML/Parquet file format explicitly
- **COPY INTO** loads data from a stage into a table — use `FILE_FORMAT` to skip headers and parse correctly
- If PUT is run twice on the same file: second time gives `SKIPPED` — use `OVERWRITE=TRUE` to force
- JSON, XML, Parquet files have only **one column** (`$1`) when read from a stage
