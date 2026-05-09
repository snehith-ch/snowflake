# Lecture 9: SnowSQL CLI, Stage Management, and CSV Special Characters

---

## 1. SnowSQL — Snowflake's Command-Line Interface

**SnowSQL** is the official command-line client for Snowflake. It is required for:
- Executing the `PUT` command (uploading local files to stages)
- Batch scripting and automation
- Running queries in non-GUI environments

### 1.1 Installation

1. Search "SnowSQL download" → go to docs.snowflake.com
2. Download the installer for your OS (Windows: `.msi`)
3. Run installer: Next → Install → Finish
4. SnowSQL is available as a command in your terminal

### 1.2 Connection Syntax

```bash
snowsql -a <account_identifier> -u <username>
```

**Account identifier** format: `xy12345.us-east-1` (found in your Snowflake URL)

```bash
# Example connection
snowsql -a xy12345.us-east-1 -u KRISHNA
Password: ****
```

After successful login you'll see:

```
Connected:
  User:      KRISHNA
  Warehouse: COMPUTE_WH
  Database:  (none)
  Schema:    (none)
```

### 1.3 Navigating in SnowSQL

```sql
-- Connect to a database
USE DATABASE SALES_DB;

-- Connect to a schema
USE SCHEMA SALES_SCHEMA;

-- Check current context
SELECT CURRENT_DATABASE();
SELECT CURRENT_SCHEMA();
SELECT CURRENT_WAREHOUSE();
```

### 1.4 Disconnecting

```
!quit
```

---

## 2. Stage Types — Complete Review

### Internal Stages

| Stage Type     | Notation          | Auto-Created?  | Who Creates?                       |
|----------------|-------------------|----------------|------------------------------------|
| User Stage     | `@~`              | Yes            | Auto-created for each user         |
| Table Stage    | `@%table_name`    | Yes            | Auto-created for each table        |
| Named Stage    | `@stage_name`     | No             | Developer creates with CREATE STAGE|

### External Stages

| Provider    | Storage Type    | Notes                               |
|-------------|-----------------|-------------------------------------|
| AWS         | S3 Bucket       | Requires IAM role or access keys    |
| Azure       | Blob Container  | Requires Storage Integration object |
| GCP         | GCS Bucket      | Requires Storage Integration object |

---

## 3. INFORMATION_SCHEMA.STAGES vs SHOW STAGES

Understanding the difference is important for interviews:

| Command                          | Scope                              |
|----------------------------------|------------------------------------|
| `SHOW STAGES`                    | Current schema only                |
| `SELECT * FROM INFORMATION_SCHEMA.STAGES` | All schemas in the current database |

```sql
-- Show stages in current schema
SHOW STAGES;

-- Show stages across all schemas in the database
SELECT * FROM INFORMATION_SCHEMA.STAGES;
```

---

## 4. Uploading Files via SnowSQL — PUT Command

```bash
# Syntax
PUT file://local/path/filename @stage_name;

# Examples
PUT file://C:/data/emp.csv @CSV_STAGE;
PUT file://C:/data/car.json @JSON_STAGE;
PUT file://C:/data/books_info.xml @XML_STAGE;
PUT file://C:/data/mt_cars.parquet @PARQUET_STAGE;
```

### What PUT Does Automatically

1. **Compresses** the file using gzip (`.gz` extension added)
2. **Encrypts** the file for security
3. Uploads to the specified stage

```sql
-- Verify upload
LIST @CSV_STAGE;
-- emp.csv.gz (compressed)
```

### Overwrite Existing Files

```bash
PUT file://C:/data/emp.csv @CSV_STAGE OVERWRITE = TRUE;
```

### Removing Files from a Stage

```sql
-- Remove specific file
RM @CSV_STAGE/emp.csv.gz;

-- Remove all files from a stage
RM @CSV_STAGE;
```

---

## 5. Verifying Stage Contents

```sql
-- List all files in a stage
LIST @CSV_STAGE;

-- Output columns:
-- name          - full path and filename (with .gz)
-- size          - compressed file size in bytes
-- md5           - checksum
-- last_modified - when the file was uploaded
```

---

## 6. CSV with Special Characters — FIELD_OPTIONALLY_ENCLOSED_BY

**Problem:** A CSV field contains a comma inside a quoted value:

```csv
ID,FIRST_NAME,ADDRESS
1,Tharun,"Flat 7, Main Road, Delhi"
2,Sai,"Plot 45, Phase 2, Hyderabad"
```

Without proper file format, Snowflake splits the address at every comma, reading more columns than expected.

**File:** `address.csv`

```csv
ID,FIRST_NAME,ADDRESS
1,Tharun,"Flat 7, Main Road, Delhi"
2,Sai,"Plot 45, Phase 2, Hyderabad"
```

**Columns:** 6 fields expected (ID, FIRST_NAME, and 3 address sub-parts — wrong!)

### Correct File Format with FIELD_OPTIONALLY_ENCLOSED_BY

```sql
CREATE FILE FORMAT FILE_ADDRESS_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';
```

The `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` parameter tells Snowflake:
> "If a field value is wrapped in double quotes, treat the content as a single field — even if it contains commas."

### Verify: Reading the File Correctly

```sql
SELECT $1, $2, $3
FROM @CSV_STAGE
(FILE_FORMAT => 'FILE_ADDRESS_FORMAT');
```

Output (3 columns, correct):
```
$1 | $2     | $3
---|--------|----------------------------
1  | Tharun | Flat 7, Main Road, Delhi
2  | Sai    | Plot 45, Phase 2, Hyderabad
```

### Describing a File Format to Find Parameter Names

If you're unsure of the parameter name:

```sql
DESCRIBE FILE FORMAT FILE_ADDRESS_FORMAT;
-- Shows all parameters including:
-- field_optionally_enclosed_by = '"'
-- skip_header = 1
-- field_delimiter = ','
```

---

## 7. DESCRIBE STAGE — Viewing Stage Properties

```sql
DESCRIBE STAGE CSV_STAGE;
```

Key properties shown:
- `stage_file_format` — the format type (CSV, JSON, etc.)
- `stage_url` — for external stages, the cloud storage URL
- `stage_region` — the cloud region

### Before vs After Assigning File Format

```sql
-- Default: stage shows CSV format
DESCRIBE STAGE JSON_STAGE;
-- stage_file_format: CSV (many properties, all CSV-related)

-- After assigning JSON format:
ALTER STAGE JSON_STAGE
    SET FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');

DESCRIBE STAGE JSON_STAGE;
-- stage_file_format: JSON (fewer properties, JSON-specific)
```

---

## 8. How SHOW vs INFORMATION_SCHEMA Differ (General Rule)

This principle applies to all Snowflake objects:

| Object   | `SHOW` Command         | Scope              | `INFORMATION_SCHEMA` query          | Scope                      |
|----------|------------------------|--------------------|-------------------------------------|----------------------------|
| Tables   | `SHOW TABLES`          | Current schema     | `INFORMATION_SCHEMA.TABLES`         | All schemas in database    |
| Stages   | `SHOW STAGES`          | Current schema     | `INFORMATION_SCHEMA.STAGES`         | All schemas in database    |
| Columns  | N/A                    | -                  | `INFORMATION_SCHEMA.COLUMNS`        | All schemas in database    |
| Formats  | `SHOW FILE FORMATS`    | Current schema     | `INFORMATION_SCHEMA.FILE_FORMATS`   | All schemas in database    |

**Practical Example:**

```sql
CREATE SCHEMA MARKETING_SCHEMA;

-- Create tables in both schemas
USE SCHEMA SALES_SCHEMA;
CREATE TABLE SALES_TABLE_1 (...);
-- ... (8 tables total in SALES_SCHEMA)

USE SCHEMA MARKETING_SCHEMA;
CREATE TABLE MKT_TABLE_1 (...);
-- ... (5 tables total in MARKETING_SCHEMA)

-- SHOW TABLES: only current schema (5 tables)
SHOW TABLES;  -- Returns 5 tables (MARKETING_SCHEMA only)

-- INFORMATION_SCHEMA.TABLES: all schemas (13 tables)
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
-- Returns 13 tables (8 + 5)
```

---

## 9. External Stages — Introduction and Comparison

### Windows Folder Permission Analogy

In Windows, a folder has permissions:
- **Full Control** = Read + Write + Delete + Modify + Rename
- When you have Full Control, you can do everything with files in that folder

Similarly, in cloud storage:
- **AWS S3** → requires `AmazonS3FullAccess` IAM permission
- **GCP** → requires `Cloud Storage Storage Admin`
- **Azure Blob** → requires `Storage Blob Data Contributor`

### Stage Locations by Cloud Provider

| Cloud    | Storage Type    | Folder Name | Path Component  |
|----------|-----------------|-------------|-----------------|
| Windows  | Local Folder    | Folder      | C:\path\folder\ |
| AWS      | S3 Bucket       | Prefix/Folder | s3://bucket/folder/ |
| Azure    | Storage Account | Container   | https://account.blob.core.windows.net/container/ |
| GCP      | GCS Bucket      | Folder      | gcs://bucket/folder/ |

---

## 10. External Stage Types

### AWS S3 Stage

Files live in: `s3://bucket-name/folder-name/`

```
S3 Bucket: bkt-april-2025
  └── stg_csv_files/
          └── emp.csv
```

### Azure Blob Storage Stage

Files live in: `https://storageaccount.blob.core.windows.net/container/`

```
Storage Account: sa-april-2025
  └── Container: stg-csv-files
            └── emp.csv
```

### GCP Cloud Storage Stage

Files live in: `gcs://bucket-name/folder-name/`

```
GCS Bucket: bkt-april-2025
  └── stg_csv_files/
          └── emp.csv
```

---

## 11. Creating Accounts with Cloud Providers

All three major cloud providers require:
1. **Sign up** with email and basic information
2. **Provide credit card** (they charge ₹2 / ~$0.03 for verification)
3. **Free tier** available for 12 months (AWS, Azure) or 90 days (GCP)

### AWS Account Creation Steps

1. Go to **aws.amazon.com** → Click **Create an AWS Account**
2. Provide: Email, account name (e.g., "KRISHNA")
3. Verify email address
4. Set password
5. Choose **Personal** account type
6. Provide name, address, mobile number → Check agreement boxes
7. Provide credit card details → verify with OTP (₹2 charge)
8. Complete phone verification
9. Choose **Free tier** support plan
10. Log in to **AWS Console**

---

## 12. SQL for Stage Management — Complete Reference

```sql
-- Create named stages
CREATE STAGE CSV_STAGE;
CREATE STAGE JSON_STAGE;
CREATE STAGE XML_STAGE;
CREATE STAGE PARQUET_STAGE;

-- Verify stages
SHOW STAGES;
SELECT * FROM INFORMATION_SCHEMA.STAGES;

-- List files in a stage
LIST @CSV_STAGE;

-- Remove files
RM @JSON_STAGE/sample.json.gz;  -- Remove specific file
RM @CSV_STAGE;                   -- Remove all files

-- Describe stage properties
DESCRIBE STAGE CSV_STAGE;

-- Assign file format to stage
ALTER STAGE JSON_STAGE SET FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');
ALTER STAGE XML_STAGE  SET FILE_FORMAT = (FORMAT_NAME = 'XML_FORMAT');

-- Grant stage access
GRANT USAGE ON STAGE CSV_STAGE TO ROLE PUBLIC;
```

---

## 13. File Format with FIELD_OPTIONALLY_ENCLOSED_BY — Full Example

**Scenario:** Address CSV file with commas inside quoted field values.

```csv
1,Tharun,"Flat 7, Main Road, Delhi"
```

```sql
-- Create file format that handles quoted fields
CREATE FILE FORMAT FILE_ADDRESS_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create table
CREATE TABLE ADDRESS_INFO (
    ID          NUMBER,
    FIRST_NAME  VARCHAR,
    ADDRESS     VARCHAR
);

-- Upload via SnowSQL:
-- PUT file://C:/data/address.csv @CSV_STAGE;

-- Load data
COPY INTO ADDRESS_INFO
FROM @CSV_STAGE
FILE_FORMAT = (FORMAT_NAME = 'FILE_ADDRESS_FORMAT');

-- Verify
SELECT * FROM ADDRESS_INFO;
```

---

## 14. Key Commands Summary

```bash
# SnowSQL connection
snowsql -a <account> -u <username>

# PUT command
PUT file://path/to/file.ext @stage_name;
PUT file://path/to/file.ext @stage_name OVERWRITE = TRUE;
```

```sql
-- Stage operations
CREATE STAGE stage_name;
SHOW STAGES;
SELECT * FROM INFORMATION_SCHEMA.STAGES;
LIST @stage_name;
DESCRIBE STAGE stage_name;
ALTER STAGE stage_name SET FILE_FORMAT = (FORMAT_NAME = 'format');
RM @stage_name/file_name.gz;
RM @stage_name;

-- File formats
CREATE FILE FORMAT csv_format TYPE = 'CSV'
    FIELD_DELIMITER = ',' SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';
DESCRIBE FILE FORMAT format_name;

-- COPY INTO
COPY INTO table_name FROM @stage_name
FILE_FORMAT = (FORMAT_NAME = 'format_name');

COPY INTO table_name FROM @stage_name
FILE_FORMAT = (FORMAT_NAME = 'format_name')
PATTERN = '.*pattern.*\\.ext\\.gz';
```

---

## 15. Key Terms

| Term                            | Definition                                                                          |
|---------------------------------|-------------------------------------------------------------------------------------|
| SnowSQL                         | Snowflake's command-line interface — required for the PUT command                   |
| PUT                             | SnowSQL command to upload local files to a Snowflake stage                          |
| OVERWRITE                       | PUT option to replace an existing file in a stage                                   |
| FIELD_OPTIONALLY_ENCLOSED_BY    | File format parameter to handle quoted field values (allows commas inside fields)   |
| INFORMATION_SCHEMA.STAGES       | Metadata view listing all internal named stages in the current database             |
| SHOW STAGES                     | Command listing stages in the current schema only                                   |
| DESCRIBE STAGE                  | Command showing all properties of a specific stage                                  |
| ALTER STAGE                     | Command to modify stage properties (e.g., assign file format)                       |
| RM                              | Command to remove files from a stage                                                |
| External Stage                  | A stage pointing to cloud storage (S3, Azure Blob, GCS)                             |

---

## 16. Summary

- **SnowSQL** is required for `PUT` — it cannot be run in the Snowsight web UI
- `PUT` automatically **compresses** (gzip) and **encrypts** files during upload
- Use `OVERWRITE = TRUE` in PUT to replace existing files in a stage
- `SHOW STAGES` shows stages in the **current schema only**; `INFORMATION_SCHEMA.STAGES` shows stages across all schemas
- `FIELD_OPTIONALLY_ENCLOSED_BY = '"'` handles CSV values that contain commas inside double-quoted fields
- `DESCRIBE STAGE` reveals the current file format and URL of a stage
- `ALTER STAGE` can assign a file format to a stage, eliminating the need to specify it in every COPY command
- External stages point to cloud provider storage (S3, Azure Blob, GCS) — covered in detail in Lectures 10–11
