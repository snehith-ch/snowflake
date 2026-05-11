# Lecture 13: Table Types Recap, External Stages, Copy History, and Snowpipe Introduction

---

## Quick Revision — Lecture 13

| # | Key Point |
|---|-----------|
| 1 | Four table types: permanent (90-day max retention, 7-day fail-safe), transient (1-day, no fail-safe), temporary (session-only, no fail-safe), external (no retention) |
| 2 | `DESCRIBE STAGE stage_name` reveals the S3 bucket URL a stage points to (STAGE_LOCATION property) |
| 3 | `COPY INTO` works both ways: loading (stage → table) and unloading (table → stage) |
| 4 | Snowpipe automates COPY by listening for AWS SQS event notifications when files land in S3 |
| 5 | `AUTO_INGEST = TRUE` requires pasting the pipe's `notification_channel` ARN into S3 event notifications |
| 6 | `SYSTEM$PIPE_STATUS('pipe_name')` returns JSON — use `PARSE_JSON()` to read it |
| 7 | `VALIDATE_PIPE_LOAD` is the table function that shows Snowpipe ingestion errors |
| 8 | DELETE preserves COPY_HISTORY metadata; TRUNCATE removes manually loaded metadata but preserves Snowpipe metadata |
| 9 | `COPY INTO @stage_name FROM table_name` unloads data; by default produces multiple part files |
| 10 | The PUT command must be run in SnowSQL — it cannot be run from the Snowsight web UI |

---

**Pre-requisite:** Lecture 12 — Table Types and Time Travel
**Next:** Lecture 14 — Snowpipe Deep Dive (file size limits, AUTO_INGEST = FALSE, serverless billing)
**Related:** Lecture 5 — COPY Command Basics; Lecture 10 — External Stages with AWS

---

## Objects Created in This Lecture

| Object Type | Name | Purpose |
|-------------|------|---------|
| Database | test_db | Demo database with 2-day retention |
| Schema | test_schema | Demo schema with 2-day retention |
| Table | t_emp | Simple emp table for demo |
| Stage | S3_CSV_STAGE | External S3 stage pointing to bktapril20250403 |
| Stage | unload_stage | Internal stage for unloading demo |
| Pipe | pipe_load_data | Snowpipe with AUTO_INGEST = TRUE on S3_CSV_STAGE |
| File Format | csv_format | CSV format with SKIP_HEADER = 1 |

---

## Table of Contents
1. [Table Types Recap](#1-table-types-recap)
2. [Stages Overview](#2-stages-overview)
3. [Working with External Stages (S3)](#3-working-with-external-stages-s3)
4. [DESCRIBE STAGE and Bucket Structure](#4-describe-stage-and-bucket-structure)
5. [Copy History](#5-copy-history)
6. [Snowpipe — Automated Continuous Loading](#6-snowpipe--automated-continuous-loading)
7. [Auto Ingest vs Manual Refresh](#7-auto-ingest-vs-manual-refresh)
8. [Data Unloading (Table to File)](#8-data-unloading-table-to-file)
9. [Common Errors Table](#9-common-errors-table)
10. [Key Commands Reference](#10-key-commands-reference)
11. [Interview Questions](#11-interview-questions)
12. [Try It Yourself](#12-try-it-yourself)

---

## 1. Table Types Recap

Snowflake has four distinct table types. This was reviewed at the start of lecture 13.

| Table Type | Retention Period | Fail-Safe | Behavior |
|------------|-----------------|-----------|----------|
| **Permanent** | 0–90 days (default: 1 day) | 7 days | Default type; persists indefinitely |
| **Transient** | 0–1 day | None | No fail-safe; lower storage cost |
| **Temporary** | 0–1 day (session only) | None | Dropped automatically when session ends |
| **External** | N/A (data lives outside) | None | Points to files in an external stage |

> **Exam Tip:** The maximum retention period for permanent tables is **90 days**. Temporary tables drop when the **SESSION** ends, not when the query ends.

> **Interview Question:** What is the difference between temporary and transient tables?
> **Answer:** Temporary tables exist only for the duration of the session and are dropped automatically when the session ends. Transient tables persist until explicitly dropped but have a maximum retention period of 1 day and no fail-safe storage.

### Creating a Database and Schema with Custom Retention (class demo)

```sql
-- Class demo: 7 April 2025
CREATE DATABASE test_db DATA_RETENTION_TIME_IN_DAYS = 2;
CREATE SCHEMA test_schema DATA_RETENTION_TIME_IN_DAYS = 2;

CREATE TABLE t_emp (empno NUMBER, ename VARCHAR, sal NUMBER);
```

### Checking Table Retention Periods

```sql
SELECT table_name, table_type, retention_time
FROM information_schema.tables
WHERE table_type = 'BASE TABLE';
```

### External Tables

An external table lets you query files in an external stage as if they were a regular table.

```sql
-- Exact class example: creating an external table on S3 parquet stage
CREATE EXTERNAL TABLE ext_cars_info_new
(model TEXT AS (value:model::TEXT),
 mpg REAL AS (value:mpg::REAL),
 cyl NUMBER(38, 0) AS (value:cyl::NUMBER(38, 0)),
 disp REAL AS (value:disp::REAL),
 hp NUMBER(38, 0) AS (value:hp::NUMBER(38, 0)),
 drat REAL AS (value:drat::REAL),
 wt REAL AS (value:wt::REAL),
 qsec REAL AS (value:qsec::REAL),
 vs NUMBER(38, 0) AS (value:vs::NUMBER(38, 0)),
 am NUMBER(38, 0) AS (value:am::NUMBER(38, 0)),
 gear NUMBER(38, 0) AS (value:gear::NUMBER(38, 0)),
 carb NUMBER(38, 0) AS (value:carb::NUMBER(38, 0))
)
location=@s3_parquet_Stage
file_Format=parquet_format;

-- Query the external table — use EXCLUDE to hide the raw value column
SELECT * EXCLUDE value FROM ext_cars_info_new;
```

---

## 2. Stages Overview

A **stage** is a named location where data files are stored before loading into Snowflake (or after unloading from Snowflake).

```
                   Snowflake Stages
                        |
          +-------------+-------------+
          |                           |
     Internal Stages            External Stages
          |                           |
   +------+------+          +---------+---------+
   |      |      |          |         |         |
User   Table   Named      Amazon   Microsoft  Google
Stage  Stage   Stage        S3       Azure     Cloud
(@~)  (@%tbl) (created              Blob      Storage
               by user)
```

### Viewing Stages

```sql
SHOW STAGES;                          -- all stages
SELECT * FROM information_schema.stages;   -- alternate method
```

### Listing Files in a Stage

```sql
LIST @stage_name;     -- or LS @stage_name
LIST @S3_CSV_STAGE;   -- class example
```

### Removing Files from a Stage

```sql
RM @stage_name/filename.csv;  -- remove specific file
RM @stage_name;               -- remove ALL files from stage
```

---

## 3. Working with External Stages (S3)

### Class Setup — Stage and Integration Used

```sql
-- Integration already created (from earlier lecture):
-- S3_INTEGRATION pointing to s3://bktapril20250403/

-- S3 CSV stage used in class:
SHOW STAGES;
LIST @S3_CSV_STAGE;
-- Result: shows emp.csv file in the bucket
```

### COPY Command with External Stage

```sql
-- Load data from S3 stage into emp table
COPY INTO emp FROM @S3_CSV_STAGE FILE_FORMAT = FILE_CSV_FORMAT;

-- Result (when no files):
-- "Copy executed with 0 files processed."
```

> **Student Question:** What does "Copy executed with 0 files processed" mean?
> **Answer:** It means there are no new files in the stage that haven't already been loaded. Snowflake checks COPY_HISTORY before loading to avoid duplicate loads.

### Complete S3 Integration Setup (from earlier lectures, reviewed here)

```sql
-- Step 1: Create storage integration
CREATE STORAGE INTEGRATION S3_integration
    TYPE = external_stage
    STORAGE_PROVIDER = s3
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::581573444142:role/roleapril20250403'
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = ('s3://bktapril20250403/stg_csv_files/');

-- Step 2: Get external ID and IAM user ARN from Snowflake
DESC STORAGE INTEGRATION S3_integration;
-- Key outputs:
-- STORAGE_AWS_IAM_USER_ARN: arn:aws:iam::779846784444:user/hvxx0000-s
-- STORAGE_AWS_EXTERNAL_ID:  TF93031_SFCRole=3_9tSBrTtKfuJsh1lwIbuyZ3w2biQ=

-- Step 3: Create stage using integration
CREATE STAGE s3_csv_stage
    URL='s3://bktapril20250403/stg_csv_files/'
    STORAGE_INTEGRATION=S3_integration;
```

> **Interview Question:** What is a storage integration object? Is it database-level or account-level?
> **Answer:** A storage integration is an **account-level** object that securely connects Snowflake to a cloud provider. You cannot create two integration objects with the same name in one Snowflake account. However, you CAN create two tables with the same name in different schemas, because tables are database-level objects.

---

## 4. DESCRIBE STAGE and Bucket Structure

Use `DESCRIBE STAGE` to inspect a stage's configuration.

```sql
DESCRIBE STAGE S3_CSV_STAGE;
-- or
DESC STAGE S3_CSV_STAGE;
```

**Class output (key property):**
```
property              value
STAGE_LOCATION        ["s3://bktapril20250403/stg_csv_files/"]
```

- **Bucket name:** `bktapril20250403`
- **Folder:** `stg_csv_files/`

> **Common Mistake:** Students confuse the bucket name with the folder name. The URL format is `s3://bucket-name/folder-name/`. Everything before the first `/` after `s3://` is the bucket.

---

## 5. Copy History

The `INFORMATION_SCHEMA.COPY_HISTORY` table function tracks every file loaded via COPY or Snowpipe.

### Class SQL — Exact Syntax Used

```sql
-- Check copy history for emp table from the past 1 day
SELECT *
FROM TABLE(information_Schema.copy_history(
    table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())
));
```

**Important columns:**

| Column | Description |
|--------|-------------|
| `FILE_NAME` | Path/name of the loaded file |
| `STATUS` | LOADED, LOAD_FAILED, PARTIALLY_LOADED |
| `ROW_COUNT` | Number of rows loaded |
| `ERROR_COUNT` | Number of errors |
| `LAST_LOAD_TIME` | Timestamp of load completion |
| `PIPE_NAME` | NULL = loaded manually; pipe name = loaded via Snowpipe |

### Class Demo: What Happens to Copy History After DELETE vs TRUNCATE

**The instructor ran this sequence live:**

```sql
-- After loading 35 records through Snowpipe and 5 records manually:
-- COPY_HISTORY has 5 entries

-- Step 1: Delete all records
DELETE FROM emp;
-- Records are removed, but COPY_HISTORY still has 5 entries!

-- Step 2: Truncate the table
TRUNCATE TABLE emp;
-- Now check COPY_HISTORY:
SELECT * FROM TABLE(information_Schema.copy_history(
    table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())
));
-- Result: 4 entries remain (only the Snowpipe entries)
-- The manually loaded entry (emp40.csv) disappeared!
```

> **Interview Question (instructor flagged as very important):** What is the difference between DELETE and TRUNCATE with respect to COPY history?
> **Answer:**
> - `DELETE`: Row-level removal. Metadata in COPY_HISTORY is **preserved**. You still cannot reload the same file.
> - `TRUNCATE`: Removes all data AND removes metadata for files loaded via manual COPY. However, files loaded via **Snowpipe** retain their metadata even after TRUNCATE.

```
Data Flow: COPY_HISTORY Behavior

File loaded via COPY (manually)
    |
    +-- DELETE rows  -->  COPY_HISTORY: UNCHANGED (metadata preserved)
    |
    +-- TRUNCATE     -->  COPY_HISTORY: entry REMOVED (can reload file)

File loaded via Snowpipe
    |
    +-- DELETE rows  -->  COPY_HISTORY: UNCHANGED
    |
    +-- TRUNCATE     -->  COPY_HISTORY: UNCHANGED (Snowpipe metadata kept)
```

### How the Pipe Name Column Shows the Load Method

```sql
-- After loading files, check who loaded them:
SELECT file_name, pipe_name, status, row_count
FROM TABLE(information_Schema.copy_history(
    table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())
));
```

| FILE_NAME | PIPE_NAME | STATUS |
|-----------|-----------|--------|
| emp.csv | PIPE_LOAD_DATA | LOADED |
| emp40.csv | NULL | LOADED |
| emp30.csv | PIPE_LOAD_DATA | LOAD_FAILED |

---

## 6. Snowpipe — Automated Continuous Loading

### What Problem Does Snowpipe Solve?

Without Snowpipe you must manually run `COPY INTO` every time a file arrives:

```sql
-- WITHOUT Snowpipe (manual, repetitive):
COPY INTO emp FROM @S3_CSV_STAGE FILE_FORMAT = FILE_CSV_FORMAT;
-- You must run this every time a file arrives — not practical!
```

With Snowpipe, this runs **automatically** when a file lands in S3.

```
Data Flow: Snowpipe Architecture

Application/ETL
      |
      v
  AWS S3 Bucket  -----> ObjectCreated event -----> AWS SQS Queue
      |                                                  |
      |                                                  v
      |                                         Snowpipe (listens)
      |                                                  |
      +<-------------------------------------------------+
      |              Snowpipe fetches file
      v
  COPY INTO emp (executes automatically, no warehouse needed)
      |
      v
  Snowflake Table (emp)
      |
      v
  COPY_HISTORY metadata recorded
```

### Creating a Snowpipe (class SQL — exact)

```sql
-- Class demo: 7 April 2025
SHOW PIPES;
SELECT * FROM information_schema.pipes;

CREATE PIPE pipe_load_Data
    auto_ingest = TRUE
AS
COPY INTO emp FROM @S3_CSV_STAGE FILE_FORMAT = FILE_CSV_FORMAT;
```

**Parameters explained:**
- `AUTO_INGEST = TRUE` — Snowflake uses an AWS SQS queue to receive event notifications from S3 and auto-ingest files.
- `AUTO_INGEST = FALSE` — Files are NOT auto-loaded. You must manually refresh the pipe.

### Getting the Notification Channel

```sql
SHOW PIPES;
-- Look for the "notification_channel" column
-- Example value: arn:aws:sqs:us-east-1:779846784444:sf-snowpipe-AIDA3LET5SW6O3GZWVSI4-s1Qc78e7uriS6p0Gy0TCCQ
```

### Configuring S3 Event Notifications (step-by-step from class)

1. Go to AWS Console → S3 → Click your bucket (bktapril20250403)
2. Click the **Properties** tab
3. Scroll to **Event notifications** → Click **Create event notification**
4. Name: `notify-snowpipe` (any name you like)
5. Event types: Check **"All object create events"**
6. Destination: Select **SQS queue** → Select **Enter SQS ARN**
7. Paste the `notification_channel` value from SHOW PIPES
8. Click **Save changes**

### Checking Pipe Status

```sql
-- Returns JSON — hard to read directly
SELECT system$pipe_status('pipe_load_Data');

-- Use PARSE_JSON to format it nicely
SELECT parse_json(system$pipe_status('pipe_load_Data'));
```

**Class output (after file uploaded to S3):**
```json
{
  "executionState": "RUNNING",
  "pendingFileCount": 0,
  "lastForwardedFilePath": "stg_csv_files/emp.csv",
  "lastIngestedFilePath": "stg_csv_files/emp.csv"
}
```

**Key status fields:**
- `executionState` — RUNNING, PAUSED, STOPPED
- `pendingFileCount` — Files waiting to be loaded
- `lastIngestedFilePath` — Most recent file that was loaded

### Validating Errors in Snowpipe

```sql
-- Class SQL (exact):
SELECT *
FROM TABLE(information_Schema.validate_pipe_load(
    pipe_name => 'pipe_load_data',
    start_time => dateadd('days', -1, current_timestamp())
));
```

**Class scenario:** emp30.csv had 11 columns but table had 10 columns. Error shown:
```
Number of columns in the file 11 does not match the corresponding table.
```

> **Student Question:** When I add a new column to the source file and try to load it, will it cause errors?
> **Answer (instructor):** Yes, if your file has more columns than the table, it will fail with a column count mismatch. You need to either add the column to the table with `ALTER TABLE emp ADD column_name data_type`, or remove the extra column from the file. You can also create a procedure to dynamically handle column mapping.

### Refreshing a Pipe Manually

```sql
-- Class demo: refreshing pipe after truncate
ALTER PIPE pipe_load_Data REFRESH;
-- Output: "4 files sent" (but files won't reload because they are in COPY_HISTORY)
```

> **Common Mistake:** Students expect that ALTER PIPE REFRESH will reload files that were already loaded. It won't — Snowpipe still checks COPY_HISTORY. To force reload, you need `FORCE = TRUE` in the COPY statement (covered in Lecture 15).

---

## 7. Auto Ingest vs Manual Refresh

| Feature | AUTO_INGEST = TRUE | AUTO_INGEST = FALSE |
|---------|------------------|-------------------|
| Trigger | S3 event → SQS → Snowpipe | Manual `ALTER PIPE ... REFRESH` |
| Status fields | Many: lastIngestedFilePath, pendingFileCount, lastForwardedFilePath | Minimal: executionState, pendingFileCount |
| SQS setup needed | Yes | No |
| Suitable for | Production real-time ingestion | Batch/manual workflows |

### Snowpipe Is Serverless

```
Regular COPY INTO:
  Need active warehouse (RUNNING) --> Credits consumed per hour

Snowpipe COPY INTO:
  No warehouse needed --> Snowflake manages compute internally
  Costs appear under "Snowpipe" service type in Cost Management
```

To verify in the UI: **Admin → Cost Management → Consumption → Filter by "Snowpipe"**

> **Key Point:** Snowpipe does not require a user-defined virtual warehouse. Snowflake provisions its own internal compute. That is why it is called **serverless**.

---

## 8. Data Unloading (Table to File)

**Loading** = from file to table (what we usually do)
**Unloading** = from table to file (reverse direction — same COPY INTO command)

### Class Demo: Unloading emp to S3

```sql
-- Step 1: Insert records into emp for demo
INSERT INTO emp
SELECT xmlget(value,'EMPNO'):"$"::number AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar AS job,
       xmlget(value,'MGR'):"$"::number AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number AS sal,
       xmlget(value,'COMM'):"$"::number AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @xml_stage/emp_sample.xml.gz (file_format => xml_format),
LATERAL FLATTEN($1:"$");

-- Step 2: Verify record count
SELECT * FROM emp;  -- 14 records

-- Step 3: Unload to S3 stage
COPY INTO @S3_CSV_STAGE FROM emp FILE_FORMAT = FILE_CSV_FORMAT;
-- Result: file created in S3 bucket (e.g., data_0_0_0.csv)

-- Step 4: Load back from S3 (verify round-trip)
TRUNCATE TABLE emp;
COPY INTO emp FROM @S3_CSV_STAGE FILE_FORMAT = FILE_CSV_FORMAT;
-- 13 records loaded (header row was written as data, so 13 not 14)
SELECT * FROM emp;
```

> **Student Question:** Can we unload to JSON format?
> **Answer (instructor):** There is a limitation — unloading requires either single-column tables or VARIANT data type. The error "Unsupported feature — unloading of more than one column or non-JSON values" appears if you try to unload a regular multi-column table with JSON format. We will cover the VARIANT data type later.

### SINGLE = TRUE — Unload to One File

By default Snowflake splits output across **multiple part files** (data_0_0_0.csv, data_0_0_1.csv, etc.) for parallel performance. Use `SINGLE = TRUE` to force one file:

```sql
-- Unload to a single file
COPY INTO @s3_csv_stage FROM emp
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
SINGLE = TRUE;
```

> **Trade-off:** `SINGLE = TRUE` is convenient but slower for large tables. Omit it for multi-GB tables.

---

## 9. Common Errors Table

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `Copy executed with 0 files processed` | File already in COPY_HISTORY | Use `FORCE = TRUE` or truncate table first |
| `Number of columns in the file X does not match the corresponding table` | File has more/fewer columns than the table | `ALTER TABLE emp ADD column_name data_type` or fix the source file |
| `Snowpipe: file not found` | File was deleted before Snowpipe processed it | Re-upload the file |
| `executionState: RUNNING, pendingFileCount: 0` | Pipe is active but no new files | Normal state; will process when file arrives |
| `Not authorized to perform this action` | Stage or integration permissions issue | Check IAM role trust policy; re-run DESCRIBE INTEGRATION and update policy |

---

## 10. Key Commands Reference

### Stage Management

```sql
SHOW STAGES;
DESCRIBE STAGE S3_CSV_STAGE;                          -- get bucket/folder info
LIST @S3_CSV_STAGE;                                    -- list files
RM @S3_CSV_STAGE;                                      -- remove all files
RM @S3_CSV_STAGE/emp.csv;                             -- remove specific file
```

### File Formats

```sql
SHOW FILE_FORMATS;
SELECT * FROM information_schema.file_formats;

-- Create CSV format (class version):
CREATE FILE FORMAT csv_format TYPE = CSV SKIP_HEADER = 1;
```

### COPY / Unload

```sql
-- Load from stage to table
COPY INTO emp FROM @S3_CSV_STAGE FILE_FORMAT = FILE_CSV_FORMAT;

-- Unload from table to stage
COPY INTO @S3_CSV_STAGE FROM emp FILE_FORMAT = FILE_CSV_FORMAT;

-- Unload single file
COPY INTO @S3_CSV_STAGE FROM emp FILE_FORMAT = FILE_CSV_FORMAT SINGLE = TRUE;
```

### Copy History

```sql
SELECT *
FROM TABLE(information_Schema.copy_history(
    table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())
));
```

### Snowpipe

```sql
-- Create pipe (class SQL exact):
CREATE PIPE pipe_load_Data
    AUTO_INGEST = TRUE
AS
COPY INTO emp FROM @S3_CSV_STAGE FILE_FORMAT = FILE_CSV_FORMAT;

SHOW PIPES;
SELECT * FROM information_schema.pipes;

-- Check status:
SELECT parse_json(system$pipe_status('pipe_load_Data'));

-- Validate errors:
SELECT * FROM TABLE(information_Schema.validate_pipe_load(
    pipe_name => 'pipe_load_data',
    start_time => dateadd('days', -1, current_timestamp())
));

-- Manual refresh:
ALTER PIPE pipe_load_Data REFRESH;
```

---

## 11. Interview Questions

**Q: What are the four types of tables in Snowflake and their retention periods?**
A: Permanent (0–90 days, with 7-day fail-safe), Transient (0–1 day, no fail-safe), Temporary (session-only, no fail-safe), External (no retention — data lives outside Snowflake).

**Q: What is a storage integration object? Is it account-level or database-level?**
A: A storage integration is an **account-level** object. You cannot create two integration objects with the same name in one account. In contrast, tables are database-level objects and can share names across different schemas.

**Q: What is Snowpipe and how does it work with AWS?**
A: Snowpipe is Snowflake's serverless continuous ingestion service. When a file lands in an S3 bucket, S3 sends an ObjectCreated event notification to an AWS SQS queue. The SQS queue ARN is the `notification_channel` generated when you create a pipe with `AUTO_INGEST = TRUE`. Snowpipe polls SQS, receives the notification, then automatically executes the embedded COPY INTO statement.

**Q: What is the difference between DELETE and TRUNCATE with respect to COPY_HISTORY?**
A: DELETE removes rows but COPY_HISTORY metadata is preserved (you cannot reload the same file). TRUNCATE removes all rows AND removes metadata for manually loaded files (allowing reload), but metadata from Snowpipe-loaded files is always preserved even after TRUNCATE.

**Q: What is VALIDATE_PIPE_LOAD used for?**
A: `INFORMATION_SCHEMA.VALIDATE_PIPE_LOAD` is a table function that shows errors that occurred during Snowpipe file ingestion. Pass the pipe name and a start time to see which files failed and why.

**Q: Why is Snowpipe called a "serverless" feature?**
A: Snowpipe does not require a user-defined virtual warehouse to execute its COPY commands. Snowflake manages its own internal compute. Costs appear under the "Snowpipe" service type in Cost Management, billed per second of compute usage — not per warehouse hour.

**Q: How do you get the SQL definition of a Snowpipe?**
A: Use `SELECT GET_DDL('pipe', 'pipe_name')`. This returns the full CREATE PIPE statement.

**Q: What are the two table functions used in connection with the COPY command?**
A: `INFORMATION_SCHEMA.COPY_HISTORY` (shows files loaded and their status) and `INFORMATION_SCHEMA.VALIDATE_PIPE_LOAD` (shows errors in Snowpipe ingestion).

**Q: What happens when you run ALTER PIPE pipe_name REFRESH after truncating the table?**
A: The refresh command re-queues files from the stage. However, if those files were loaded via Snowpipe, their metadata is preserved in COPY_HISTORY even after TRUNCATE — so the files will NOT be reloaded (Snowpipe will skip them as already processed).

**Q: When would you use SINGLE = TRUE in an unload operation?**
A: When downstream systems require exactly one output file — for example, emailing an attachment, sending to a legacy system, or when the output must have a predictable filename. Trade-off: slower for large datasets because all data goes through a single write thread.

---

## 12. Try It Yourself

**Exercise 1: Inspect a Stage**
Find out which S3 bucket your `s3_csv_stage` points to.
```sql
-- Hint: use DESC or DESCRIBE
DESCRIBE STAGE s3_csv_stage;
-- Look for property: STAGE_LOCATION
```

**Exercise 2: Check Copy History**
After loading data into the `emp` table, check what files were used.
```sql
-- Answer:
SELECT file_name, status, row_count, pipe_name
FROM TABLE(information_Schema.copy_history(
    table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())
));
```

**Exercise 3: Create a Snowpipe**
Create a pipe on `s3_csv_stage` that loads into `emp` using `file_csv_format`.
```sql
-- Answer:
CREATE PIPE my_emp_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO emp FROM @s3_csv_stage FILE_FORMAT = FILE_CSV_FORMAT;

-- Get the notification channel:
SHOW PIPES;
```

**Exercise 4: Unloading Data**
Unload all records from `emp` to `s3_csv_stage` as a single CSV file.
```sql
-- Answer:
COPY INTO @s3_csv_stage FROM emp
FILE_FORMAT = (FORMAT_NAME = 'FILE_CSV_FORMAT')
SINGLE = TRUE;

-- Verify:
LIST @s3_csv_stage;
```

**Exercise 5: Test DELETE vs TRUNCATE with Copy History**
Load a file, check copy history (should show 1 entry). Delete all rows, check again (should still show 1 entry). Truncate, check again (should show 0 entries for manual load).
```sql
-- Load:
COPY INTO emp FROM @s3_csv_stage/emp.csv FILE_FORMAT = FILE_CSV_FORMAT;

-- Check (should see 1 entry):
SELECT * FROM TABLE(information_Schema.copy_history(table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())));

-- Delete all rows:
DELETE FROM emp;

-- Check again (still 1 entry — DELETE preserves history):
SELECT * FROM TABLE(information_Schema.copy_history(table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())));

-- Truncate:
TRUNCATE TABLE emp;

-- Check again (0 entries — TRUNCATE removes manual load history):
SELECT * FROM TABLE(information_Schema.copy_history(table_name => 'EMP',
    start_time => dateadd('days', -1, current_timestamp())));
```

---

## Key Terms

| Term | Definition |
|------|------------|
| **Stage** | Named storage location for data files (internal or external) |
| **Internal Stage** | Storage managed by Snowflake itself |
| **External Stage** | Points to cloud storage (S3, Azure, GCS) |
| **Storage Integration** | Account-level object that authorizes Snowflake to access cloud storage |
| **COPY INTO** | SQL command to load data from stage to table, or unload from table to stage |
| **Copy History** | Metadata log of all files loaded via COPY or Snowpipe |
| **Snowpipe** | Serverless continuous ingestion service |
| **AUTO_INGEST** | Snowpipe parameter enabling automatic S3 event-triggered loading |
| **SQS** | AWS Simple Queue Service used to send event notifications to Snowpipe |
| **Notification Channel** | SQS ARN generated by Snowpipe; must be configured in S3 event notifications |
| **VALIDATE_PIPE_LOAD** | Table function to inspect errors during Snowpipe ingestion |
| **Serverless** | Snowpipe does not require a user-defined warehouse to operate |
| **Unloading** | Writing data FROM a table TO a file/stage (reverse of loading) |
