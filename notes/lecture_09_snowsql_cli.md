# Lecture 9: SnowSQL CLI, Stage Management, CSV Special Characters, and External Stages Introduction

---

## Quick Revision — Lecture 9

| # | Key Point |
|---|-----------|
| 1 | SnowSQL is Snowflake's CLI — the only way to run the `PUT` command |
| 2 | `snowsql -a <account> -u <username>` — connect from command prompt |
| 3 | After login: `USE DATABASE ...` then `USE SCHEMA ...` before running PUT |
| 4 | PUT auto-compresses (GZIP) and auto-encrypts; file status = UPLOADED or SKIPPED |
| 5 | `RM @stage_name` removes all files; `RM @stage/file.gz` removes one file |
| 6 | `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` handles CSV values with commas inside quotes |
| 7 | `DESCRIBE FILE FORMAT format_name` shows all parameters with exact names |
| 8 | `SHOW STAGES` = current schema only; `INFORMATION_SCHEMA.STAGES` = all schemas |
| 9 | External stage locations: AWS=S3 bucket, GCP=GCS bucket, Azure=Storage account |
| 10 | `SHOW INTEGRATIONS` is needed before creating an external stage |

---

**Pre-requisite:** Lecture 8 — XML Processing (covers all internal stage operations)
**Next:** Lecture 10 — External Stages — Azure, GCP, and AWS full setup
**Related:** Lecture 4 — Internal Stages (user, table, named stage introduction)

---

## Objects Created in This Lecture

| Object Type  | Name                   | Purpose |
|--------------|------------------------|---------|
| File Format  | file_address_format    | CSV format with FIELD_OPTIONALLY_ENCLOSED_BY for quoted fields |
| Stage        | xml_stage              | Used for single_record.xml demonstration |
| File         | single_record.xml      | XML with one record — TO_ARRAY() case |
| File         | address.csv            | CSV with commas inside quoted fields — special character case |

---

## ASCII Data Flow — CSV with Special Characters

```
address.csv (contains commas inside quoted fields)
  "1,Tharun,"Flat 7, Main Road, Delhi""
        |
        |  PUT via SnowSQL
        v
@csv_stage
        |
        |  COPY INTO address_info
        |  FILE_FORMAT = file_address_format
        |  (FIELD_OPTIONALLY_ENCLOSED_BY = '"')
        v
address_info table:
  ID=1  |  FIRST_NAME=Tharun  |  ADDRESS="Flat 7, Main Road, Delhi"
```

---

## ASCII Data Flow — External Stage Introduction

```
Cloud Storage (AWS S3 / Azure Blob / GCP GCS)
  [emp.csv in a bucket/container/folder]
        |
        | Storage Integration object
        | (establishes secure connection)
        v
External Stage (@azure_csv_stage / @gcp_csv_stage / @s3_csv_stage)
        |
        |  LIST @external_stage
        |  SELECT $1,$2,...  FROM @external_stage (FILE_FORMAT=>...)
        |  COPY INTO emp FROM @external_stage FILE_FORMAT=...
        v
Snowflake Table (emp)
```

---

## 1. Review: Processing Single-Record XML (TO_ARRAY Case)

The instructor began Lecture 9 by completing the single_record.xml demonstration from the previous session.

### Upload single_record.xml via SnowSQL

```sql
-- Check stages in information_schema
SELECT * FROM information_schema.stages;

LIST @xml_stage;
-- Current files in stage
```

Connect via SnowSQL and upload:

```
snowsql -a iscutgw-jp34947 -u krishna
Password:
```

```sql
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use SCHEMA SALES_SCHEMA;
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\single_record.xml @xml_stage;
```

```sql
-- Verify
LIST @xml_stage;
-- single_record.xml.gz (1 record only)
```

### Single-record XML — Problem and Solution

```sql
-- Problem: $1:"$" for single record is NOT an array
SELECT $1:"$" FROM @xml_stage/single_record.xml (file_format=>xml_format);
-- Returns a single element, not an array → LATERAL FLATTEN gives NULLs

-- Solution 1: Convert to array with TO_ARRAY
SELECT TO_ARRAY($1:"$") FROM @xml_stage/single_record.xml (file_format=>xml_format);
-- Now returns: [{"@":"ROW","$":[...]}] — an array with 1 element

-- Using TO_ARRAY with LATERAL FLATTEN:
SELECT xmlget(value,'EMPNO'):"$"::number  AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar   AS job,
       xmlget(value,'MGR'):"$"::number    AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number    AS sal,
       xmlget(value,'COMM'):"$"::number   AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @xml_stage/single_record.xml.gz (file_format=>xml_format),
     lateral flatten(TO_ARRAY($1:"$"));

-- Solution 2: Use nested XMLGET directly (no FLATTEN needed for 1 record)
SELECT xmlget(xmlget($1,'ROW'),'EMPNO'):"$"::number AS empno,
       xmlget(xmlget($1,'ROW'),'ENAME'):"$"::varchar AS ename
FROM @xml_stage/single_record.xml.gz (file_format=>xml_format);
```

> **Student Question:** "Why are we using lateral flatten? We can use VARIANT because it is in JSON format only, right?"
> **Answer (instructor):** "See, basically XML right — what I'm trying to say is XML gets converted into JSON. From JSON we load into a table. If we have more than one record, we use LATERAL FLATTEN. If we have a single record, yes, you can use XMLGET directly — we have the standard method right. Without using LATERAL FLATTEN you can achieve that. LATERAL FLATTEN is when you have multiple records."

> **Student Question:** "The error earlier was NULL values for all columns when using LATERAL FLATTEN on single_record.xml. Why?"
> **Answer:** "LATERAL FLATTEN expects an array as input. Since you only have a single record, `$1:"$"` is not an array — it is a single element. So you have to convert it to array using `TO_ARRAY`."

---

## 2. Continuing: CSV File with Commas Inside Fields

A student had an issue loading a CSV file with address data that had commas inside quoted values.

### The Problem File — address.csv

```csv
ID,FIRST_NAME,ADDRESS
1,Tharun,"Flat 7, Main Road, Delhi"
2,Sai,"Plot 45, Phase 2, Hyderabad"
```

The address field contains commas — but the entire address is wrapped in double quotes `"..."`.

### Step 1: Upload via SnowSQL

First, remove all existing files from csv_stage:

```sql
RM @csv_stage;  -- Remove all files from csv_stage
```

Then upload address.csv:

```
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://...address.csv @csv_stage;
```

### Step 2: Check file contents — wrong read

```sql
LIST @csv_stage;  -- address.csv.gz

-- Without proper file format: reads 6 columns (wrong)
SELECT $1, $2, $3, $4, $5, $6
FROM @csv_stage;
```

Without proper file format, Snowflake splits the address at every comma, resulting in too many columns.

### Step 3: Find the correct parameter name

```sql
SELECT * FROM information_schema.file_formats;
SHOW FILE FORMATS;
DESC FILE FORMAT FILE_CSV_FORMAT;
-- Shows all parameters including field_optionally_enclosed_by
```

### Step 4: Create file format with FIELD_OPTIONALLY_ENCLOSED_BY

```sql
CREATE FILE FORMAT file_address_format
TYPE = csv
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';
-- Note: parameter name is FIELD_OPTIONALLY_ENCLOSED_BY (not FIELDS with 'S')
```

> **Student Question (during class):** "I had an issue with `TYPE = CSV` — I didn't put single quotes and got a loading error with 13 columns. After putting single quotes it worked. Is it case sensitive?"
> **Answer (instructor):** "Did you share the file in the group? In case if I want to get the parameter name, what I need to do is `DESCRIBE FILE FORMAT format_name` — that shows you the exact parameter names. No, `TYPE = CSV` does not need single quotes. Maybe there was a different issue in your file."

> **Common Mistake:** Typing `FIELDS` (with S) instead of `FIELD_OPTIONALLY_ENCLOSED_BY` — will give error `Field unit`. Use `DESC FILE FORMAT` to verify exact parameter names.

### Step 5: Read with correct format

```sql
SELECT $1, $2, $3
FROM @csv_stage (file_format=>file_address_format);
-- Correct output: 3 columns with address as one field
-- $1 = 1,  $2 = Tharun,  $3 = "Flat 7, Main Road, Delhi"
```

---

## 3. SnowSQL — Snowflake's Command-Line Interface

**SnowSQL** is the official command-line client for Snowflake. It is the ONLY way to run the `PUT` command.

### Installation

1. Search "SnowSQL download" → go to docs.snowflake.com
2. Download the installer for your OS (Windows: `.msi`)
3. Run installer: Next → Install → Finish
4. SnowSQL is available as `snowsql` command in your terminal

### Connection Syntax

```bash
snowsql -a <account_identifier> -u <username>
```

**Account identifier** is found in your Snowflake URL: `https://<account>.snowflakecomputing.com`

**Example from class:**
```
C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>
```

After login you see: `username#WAREHOUSE@database.schema>`

### Setting Database and Schema in SnowSQL

```sql
USE DATABASE SALES_DB;
USE SCHEMA SALES_SCHEMA;
-- Prompt changes to: krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>
```

### Disconnecting

```
!quit
```

---

## 4. PUT Command — Uploading Files

```bash
PUT file://local/path/filename @stage_name;
```

### What PUT Does Automatically

1. **Compresses** the file using GZIP (`.gz` extension added)
2. **Encrypts** the file for security

### Exact SnowSQL PUT outputs from class

```
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>list @csv_stage;
+------+------+-----+---------------+
| name | size | md5 | last_modified |
|------+------+-----+---------------|
+------+------+-----+---------------+
0 Row(s) produced. Time Elapsed: 0.120s
```

```
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_Stage;
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source  | target     | source_size | target_size | source_compression | target_compression | status   | message |
|---------+------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp.csv | emp.csv.gz |        1531 |         560 | NONE               | GZIP               | UPLOADED |         |
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.250s
```

### PUT status values

| Status   | Meaning |
|----------|---------|
| UPLOADED | File successfully uploaded (compressed + encrypted) |
| SKIPPED  | File already exists in stage with same name — not overwritten |

### Overwrite Existing Files

```bash
PUT file://C:/data/emp.csv @csv_stage OVERWRITE = TRUE;
-- Status becomes UPLOADED (replaces existing file)
```

### Removing Files from a Stage

```sql
RM @csv_stage/emp.csv.gz;  -- Remove specific file
RM @csv_stage;              -- Remove ALL files from the stage
```

> **Certification Question:** "Can you load data using PUT command through worksheets in the Snowflake web UI?"
> **Answer: FALSE.** PUT command can only be executed from SnowSQL CLI. Copy command (COPY INTO) can be run in the worksheet, but PUT cannot.

---

## 5. Stage Types — Complete Review

### Internal Stages

| Stage Type     | Notation          | Auto-Created?  | Who Creates? |
|----------------|-------------------|----------------|--------------|
| User Stage     | `@~`              | Yes            | Auto for each user |
| Table Stage    | `@%table_name`    | Yes            | Auto for each table |
| Named Stage    | `@stage_name`     | No             | Developer: `CREATE STAGE` |

```
Internal stages:
  @~            ← user stage (for current user)
  @%table_name  ← table stage (for a specific table)
  @stage_name   ← named stage (created by developer)
```

> **Certification Question:** "Select the different types of internal stages."
> **Answer:** User (`@~`), Table (`@%table_name`), Named (`@stage_name`)

### External Stages

| Provider    | Storage Type    | Notes |
|-------------|-----------------|-------|
| AWS         | S3 Bucket       | Requires IAM role setup |
| Azure       | Blob Container  | Requires Storage Integration + Consent URL |
| GCP         | GCS Bucket      | Requires Storage Integration + Service Account grant |

---

## 6. SHOW STAGES vs INFORMATION_SCHEMA.STAGES

| Command | Scope |
|---------|-------|
| `SHOW STAGES` | Current schema only |
| `SELECT * FROM INFORMATION_SCHEMA.STAGES` | All schemas in the current database |

```sql
-- Show stages in current schema only
SHOW STAGES;

-- Show stages across ALL schemas in the current database
SELECT * FROM information_schema.stages;
```

This principle applies to ALL Snowflake objects:

| Object | SHOW command | Scope | INFORMATION_SCHEMA view | Scope |
|--------|-------------|-------|-------------------------|-------|
| Tables | `SHOW TABLES` | Current schema | `INFORMATION_SCHEMA.TABLES` | All schemas |
| Stages | `SHOW STAGES` | Current schema | `INFORMATION_SCHEMA.STAGES` | All schemas |
| File Formats | `SHOW FILE FORMATS` | Current schema | `INFORMATION_SCHEMA.FILE_FORMATS` | All schemas |
| Columns | N/A | — | `INFORMATION_SCHEMA.COLUMNS` | All schemas |

---

## 7. DESCRIBE STAGE — Viewing Stage Properties

```sql
SHOW STAGES;
DESCRIBE STAGE csv_stage;
```

Key properties shown:
- `stage_file_format` — the format type assigned (CSV by default)
- `stage_url` — for external stages, the cloud storage URL
- `stage_region` — the cloud region

### Before vs After Assigning File Format

```sql
-- Default: many properties (26+ for CSV format)
DESC STAGE json_stage;
-- stage_file_format: CSV (24+ properties)

-- After assigning JSON format:
ALTER STAGE json_stage SET FILE_FORMAT = (FORMAT_NAME = 'json_format');

DESC STAGE json_stage;
-- Now only ~10 properties (JSON-specific)
-- stage_file_format: JSON
```

> **Instructor (Lecture 7 review):** "After assigning the file format, you can run COPY INTO without specifying the format explicitly."

---

## 8. External Stages — Introduction (Windows Folder Analogy)

### What Is an External Stage?

An external stage points to files stored in a **cloud provider's storage** (AWS S3, Azure Blob Storage, or GCP Cloud Storage) rather than inside Snowflake.

### Permissions Analogy

The instructor explained external stage permissions using Windows folder permissions:

```
Windows: C:\path\STG_CSV_Files\
  Properties → Security → Users:
    SYSTEM       → Full Control
    Administrator→ Full Control
    Your_User    → Full Control
  
  Full Control = Read + Write + Delete + Modify + Rename
```

> **Instructor:** "What do you mean by Full Control on a particular folder? You can place a file, modify a file, delete a file, rename a file — that is called Full Control."

In cloud storage, equivalent permissions are:

| Platform | Storage Unit | Folder Equivalent | Required Permission |
|----------|-------------|-------------------|---------------------|
| Windows  | Drive/Path  | Folder            | Full Control |
| AWS      | S3 Bucket   | Folder/Prefix     | AmazonS3FullAccess (IAM) |
| Azure    | Storage Account | Container    | Storage Blob Data Contributor |
| GCP      | GCS Bucket  | Folder            | Cloud Storage Storage Admin |

---

## 9. Cloud Storage Terminology by Provider

| Concept | Windows | AWS | Azure | GCP |
|---------|---------|-----|-------|-----|
| "Location" (drive/server) | Drive path | S3 Bucket | Storage Account | GCS Bucket |
| "Folder" | Folder | Prefix/Folder | Container | Folder |
| URL format | `C:\path\` | `s3://bucket/folder/` | `azure://account.blob.../container/` | `gcs://bucket/folder/` |
| Permission mechanism | Windows ACL | IAM Role | Role Assignment | Service Account grant |

> **Instructor:** "In case of AWS, you will call it as S3 bucket. In case of GCP, you will call it as a bucket. In case of Azure, you will call it as a storage account. In Windows, we create a folder. In GCP also we call it a folder. In Microsoft Azure, you will call it as a container."

---

## 10. External Stage Setup Overview (Introduction Only)

The instructor introduced external stages at the end of Lecture 9 and began creating Azure/GCP accounts. Full setup is covered in Lecture 10.

### The Integration Object

To connect Snowflake to cloud storage, you must create a **Storage Integration** object:

```sql
SHOW INTEGRATIONS;
-- Currently empty (no integrations yet)
```

> **Instructor:** "In order to establish the relationship between Snowflake and Azure, you need to create an integration object. Integration object is a Snowflake object which helps us communicate between Snowflake and Azure."

### Azure Account Creation Steps (for practice)

1. Go to **https://portal.azure.com**
2. Create new account with Gmail address
3. Click on **"Start with an Azure free trial"** → **Try Azure for free**
4. Provide first name, last name, mobile (verify), address → click Next
5. Provide credit card number
6. OTP verification (₹2 charge)
7. Account created

### GCP Account Creation Steps

1. Go to **https://console.cloud.google.com**
2. Select email address and click **Agree and Continue**
3. Click **Start for free** → select country
4. Click **Create a new payment profile** → provide organization and address → click Create
5. Add payment method (credit card) → provide card details → click **Save Card**
6. Click **Start for free** → verify OTP (₹2 charge)

> **Important:** All three providers (AWS, Azure, GCP) charge exactly **₹2 for card verification**. Free tiers are available after sign-up.

---

## 11. File Format: FIELD_OPTIONALLY_ENCLOSED_BY — Full Reference

```sql
CREATE FILE FORMAT file_address_format
TYPE = csv
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';
```

The `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` parameter tells Snowflake:
> "If a field value is wrapped in double quotes, treat the content as a single field — even if it contains commas."

### Verify by describing the file format

```sql
DESCRIBE FILE FORMAT file_address_format;
-- Shows all parameters including:
-- field_optionally_enclosed_by  "
-- skip_header                   1
-- field_delimiter               ,
```

### Complete loading example

```sql
-- Place file into stage (SnowSQL)
-- PUT file://path/address.csv @csv_stage;

-- Create target table
CREATE TABLE address_info (
    id         NUMBER,
    first_name VARCHAR,
    address    VARCHAR
);

-- Query with correct format (3 columns now)
SELECT $1, $2, $3
FROM @csv_stage (file_format=>file_address_format);

-- Load
COPY INTO address_info
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'file_address_format');
```

---

## 12. Key Differences — FIELD_OPTIONALLY_ENCLOSED_BY Behavior

| Scenario | Without Parameter | With Parameter |
|----------|-------------------|----------------|
| `"Flat 7, Main Road, Delhi"` | Split into 3 columns at each comma | Treated as ONE field |
| Number of columns detected | 6 (wrong) | 3 (correct) |
| COPY INTO behavior | Fails or loads garbage | Loads correctly |
| Error seen | `Insert value list does not match column list` | No error |

---

## 13. Key Commands Summary

```bash
# SnowSQL connection
snowsql -a iscutgw-jp34947 -u krishna
# Then: password prompt

# PUT command (run AFTER USE DATABASE + USE SCHEMA)
PUT file://C:\path\to\file.ext @stage_name;
PUT file://C:\path\to\file.ext @stage_name OVERWRITE = TRUE;
```

```sql
-- Navigation in SnowSQL
USE DATABASE SALES_DB;
USE SCHEMA SALES_SCHEMA;

-- Stage operations
SHOW STAGES;
SELECT * FROM information_schema.stages;
LIST @csv_stage;
DESC STAGE csv_stage;
ALTER STAGE json_stage SET FILE_FORMAT = (FORMAT_NAME = 'json_format');

-- File management
RM @csv_stage/emp.csv.gz;   -- Remove specific file
RM @csv_stage;               -- Remove all files

-- File formats
SHOW FILE FORMATS;
SELECT * FROM information_schema.file_formats;
DESC FILE FORMAT FILE_CSV_FORMAT;

-- Address CSV format
CREATE FILE FORMAT file_address_format
TYPE = csv
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Query with format
SELECT $1, $2, $3 FROM @csv_stage (file_format=>file_address_format);

-- COPY INTO
COPY INTO address_info FROM @csv_stage FILE_FORMAT = (FORMAT_NAME = 'file_address_format');
COPY INTO emp FROM @csv_stage FILE_FORMAT = (FORMAT_NAME = FILE_CSV_FORMAT) PATTERN = '.*emp.*[.]gz';

-- Single-record XML
SELECT TO_ARRAY($1:"$") FROM @xml_stage/single_record.xml (file_format=>xml_format);
-- Use LATERAL FLATTEN(TO_ARRAY(a.$1:"$")) for single-record XML

-- External stage prep
SHOW INTEGRATIONS;

-- Grant/revoke
GRANT USAGE ON DATABASE sales_db TO ROLE public;
REVOKE USAGE ON DATABASE sales_db FROM ROLE public;
```

---

## 14. Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `Unsupported feature 'unsupported_requested_format:snowflake'` | Running PUT in the web UI worksheet | Use SnowSQL CLI |
| `SKIPPED` in PUT output | File already exists in stage | Add `OVERWRITE = TRUE` |
| `Insert value list does not match column list` | Loading CSV with commas in fields without proper format | Add `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` to file format |
| `Field unit` error when creating file format | Misspelled `FIELD_OPTIONALLY_ENCLOSED_BY` as `FIELDS_OPTIONALLY...` | Use `DESC FILE FORMAT` to find exact parameter name |
| LATERAL FLATTEN returns NULLs on single-record XML | `$1:"$"` is not an array for single-record files | Wrap with `TO_ARRAY($1:"$")` before LATERAL FLATTEN |
| `does not have storage.objects.list access` | Snowflake service account not granted access to GCS bucket | Grant `Cloud Storage Storage Admin` role to Snowflake's service account |
| `please check your role assignment` on LIST @azure_stage | Azure role assignment not yet configured | Follow Azure Consent URL process and assign `Storage Blob Data Contributor` |

---

## 15. Interview Questions

**Q: What is SnowSQL and why is it needed?**
A: SnowSQL is Snowflake's official command-line interface. It is the only tool that can execute the `PUT` command to upload local files to Snowflake stages. The web UI (Snowsight) does not support PUT.

**Q: What does the PUT command do automatically?**
A: PUT automatically (1) **compresses** files using GZIP and (2) **encrypts** files for security. The compressed file gets a `.gz` extension added in the stage.

**Q: What is `FIELD_OPTIONALLY_ENCLOSED_BY` used for?**
A: It handles CSV files where field values are wrapped in double quotes (e.g., `"New York, USA"`). Without this parameter, Snowflake splits at every comma, misreading quoted values as multiple columns. Setting `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` tells Snowflake to treat quoted content as a single field.

**Q: What is the difference between SHOW STAGES and INFORMATION_SCHEMA.STAGES?**
A: `SHOW STAGES` returns stages in the **current schema only**. `SELECT * FROM INFORMATION_SCHEMA.STAGES` returns stages from **all schemas** in the current database. This principle applies to all Snowflake objects (tables, file formats, etc.).

**Q: What are the three types of internal stages in Snowflake?**
A: (1) User Stage (`@~`) — automatically created for each user; (2) Table Stage (`@%table_name`) — automatically created for each table; (3) Named Stage (`@stage_name`) — manually created by developers using `CREATE STAGE`.

**Q: What is a Storage Integration object?**
A: A Storage Integration is a Snowflake object that establishes a trusted, secure connection between Snowflake and a cloud storage provider (AWS S3, Azure Blob, or GCS). It is required before creating an external stage.

**Q: How do you replace an existing file in a Snowflake stage?**
A: Use `PUT file://path @stage OVERWRITE = TRUE`. Without OVERWRITE, the PUT returns status SKIPPED if the file already exists.

**Q: How do you remove files from a Snowflake stage?**
A: `RM @stage_name/specific_file.gz` removes one file. `RM @stage_name` removes all files from the stage.

---

## 16. Try It Yourself Exercises

**Exercise 1:** Connect to SnowSQL, switch to SALES_DB / SALES_SCHEMA, upload `address.csv` to `csv_stage`, and verify it appears.

```sql
-- Answer:
-- In SnowSQL:
-- snowsql -a <account> -u krishna
-- USE DATABASE SALES_DB;
-- USE SCHEMA SALES_SCHEMA;
-- PUT file://path/address.csv @csv_stage;
LIST @csv_stage;  -- Should show address.csv.gz
```

**Exercise 2:** Create `file_address_format` with `FIELD_OPTIONALLY_ENCLOSED_BY` and query the address CSV to verify only 3 columns appear.

```sql
-- Answer:
CREATE FILE FORMAT file_address_format
TYPE = csv
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

SELECT $1 AS id, $2 AS name, $3 AS address
FROM @csv_stage (file_format=>file_address_format);
```

**Exercise 3:** Remove all files from csv_stage, then upload emp.csv and verify.

```sql
-- Answer:
RM @csv_stage;
-- In SnowSQL: PUT file://path/emp.csv @csv_stage;
LIST @csv_stage;  -- Should show emp.csv.gz only
```

**Exercise 4:** Use `DESCRIBE FILE FORMAT` to see all parameters of your CSV format.

```sql
-- Answer:
DESC FILE FORMAT file_address_format;
-- Shows: field_optionally_enclosed_by, field_delimiter, skip_header, etc.
```

**Exercise 5:** Show all stages across all schemas using both SHOW STAGES and INFORMATION_SCHEMA, and observe the difference.

```sql
-- Answer:
USE SCHEMA SALES_SCHEMA;
SHOW STAGES;   -- Only shows stages in SALES_SCHEMA

USE SCHEMA marketing_Schema;  -- Switch to different schema
SHOW STAGES;   -- Only shows stages in marketing_Schema

-- Shows ALL stages in all schemas of the database:
SELECT * FROM information_schema.stages;
```

---

## 17. Summary

- **SnowSQL** is required for `PUT` — it cannot be run in the Snowsight web UI
- `PUT` automatically **compresses** (GZIP) and **encrypts** files during upload
- Use `OVERWRITE = TRUE` in PUT to replace existing files in a stage
- `RM @stage` removes all files; `RM @stage/file.gz` removes one file
- `SHOW STAGES` shows stages in the **current schema only**; `INFORMATION_SCHEMA.STAGES` shows all
- `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` handles CSV values that contain commas inside double-quoted fields
- `DESCRIBE FILE FORMAT` / `DESCRIBE STAGE` shows all properties — use it to find exact parameter names
- Internal stages: User (`@~`), Table (`@%table`), Named (`@stage_name`)
- External stages: AWS (S3 bucket), Azure (Storage Account + Container), GCP (GCS Bucket + Folder)
- A **Storage Integration** object is needed to connect Snowflake to any external cloud storage
- All three cloud providers (AWS, Azure, GCP) charge ~₹2 for credit card verification during sign-up
- Single-record XML files: use `TO_ARRAY($1:"$")` before LATERAL FLATTEN to convert to array
