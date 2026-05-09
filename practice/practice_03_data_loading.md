# Practice Set 3: Data Loading — Stages, File Formats & COPY Command

> **Topics Covered**: Internal Stages, External Stages, File Formats, COPY INTO, ON_ERROR options, VALIDATION_MODE
> **Related Lectures**: Lecture 4, 5, 6, 13, 14, 15

---

## Background

In Snowflake, data loading follows this flow:

```
Local File → [PUT] → Internal Stage → [COPY INTO] → Table
Cloud Storage (S3/Azure/GCP) → External Stage → [COPY INTO] → Table
```

**Stages** are temporary storage locations in Snowflake (or pointing to cloud storage).
**File Formats** tell Snowflake how to parse the files.
**COPY INTO** moves data from stage to table.

---

## Setup

```sql
CREATE DATABASE IF NOT EXISTS load_practice_db;
CREATE SCHEMA IF NOT EXISTS load_schema;
USE DATABASE load_practice_db;
USE SCHEMA load_schema;
USE WAREHOUSE compute_wh;
```

---

## Section 1: Internal Stages

### Exercise 1.1 — Create Internal Stages
Create stages for different file types:

```sql
-- Stage for CSV files
CREATE STAGE csv_stage
    COMMENT = 'Stage for CSV file loading';

-- Stage for JSON files
CREATE STAGE json_stage
    COMMENT = 'Stage for JSON file loading';

-- Stage for Parquet files
CREATE STAGE parquet_stage;

-- Verify
SHOW STAGES;
```

**Questions**:
1. What is the difference between an internal stage and an external stage?
   - Internal: _______________
   - External: _______________

2. What command uploads a file from your local machine to an internal stage?
   - Answer: `_______________` (Note: This command only works in SnowSQL CLI, not in the web UI)

---

### Exercise 1.2 — Stage Operations
```sql
-- List files in a stage
LIST @csv_stage;

-- Remove a file from stage
-- REMOVE @csv_stage/filename.csv;

-- Describe a stage (see properties)
DESCRIBE STAGE csv_stage;
```

---

## Section 2: File Formats

### Exercise 2.1 — Create File Formats
```sql
-- CSV file format (comma-separated)
CREATE FILE FORMAT csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1           -- Skip the first row (header)
    TRIM_SPACE = TRUE
    NULL_IF = ('NULL', 'null', '');

-- CSV format with pipe delimiter
CREATE FILE FORMAT pipe_csv_format
    TYPE = CSV
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1;

-- JSON file format
CREATE FILE FORMAT json_format
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE;  -- Remove the outer [] array wrapper

-- Parquet file format
CREATE FILE FORMAT parquet_format
    TYPE = PARQUET;

-- Verify
SHOW FILE FORMATS;
```

---

### Exercise 2.2 — File Format Questions

Fill in the blanks:

1. `SKIP_HEADER = 1` means _______________
2. `FIELD_DELIMITER = '|'` means the file uses ________ as separator
3. `STRIP_OUTER_ARRAY = TRUE` is used for ________ files to remove outer brackets
4. If you don't specify a file format in COPY, Snowflake treats it as ________ by default
5. To store semi-structured data (JSON, XML), use the ________ data type

**Answers**:
1. Skip the first line (header row)
2. pipe (|)
3. JSON
4. CSV
5. VARIANT

---

## Section 3: Creating Target Tables

### Exercise 3.1 — Create Tables for Loading
```sql
-- Table for loading employee CSV data
CREATE TABLE emp_staging (
    emp_id      NUMBER,
    emp_name    VARCHAR(100),
    department  VARCHAR(50),
    salary      NUMBER(10,2),
    hire_date   DATE,
    city        VARCHAR(100)
);

-- Table for JSON data (using VARIANT)
CREATE TABLE json_staging (
    raw_data VARIANT
);

-- Verify
SHOW TABLES;
```

---

## Section 4: COPY INTO Command

### Exercise 4.1 — COPY Syntax Understanding

Study these COPY INTO variations:

```sql
-- Basic COPY
COPY INTO emp_staging
FROM @csv_stage/employees.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format');

-- COPY with inline file format (no separate file format object)
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_DELIMITER = ',');

-- COPY specific files using pattern
COPY INTO emp_staging
FROM @csv_stage
PATTERN = '.*employees.*\.csv'
FILE_FORMAT = (FORMAT_NAME = 'csv_format');

-- COPY with column mapping
COPY INTO emp_staging (emp_id, emp_name, salary)
FROM (SELECT $1, $2, $4 FROM @csv_stage)
FILE_FORMAT = (FORMAT_NAME = 'csv_format');
```

**Questions**:
1. What does `$1`, `$2`, `$4` mean in the COPY with column mapping?
   - Answer: _______________

2. What does the `PATTERN` option do?
   - Answer: _______________

---

### Exercise 4.2 — ON_ERROR Options

The `ON_ERROR` parameter controls what happens when a record has an error:

```sql
-- Option 1: ABORT_STATEMENT (default) — stop on first error
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR = 'ABORT_STATEMENT';

-- Option 2: CONTINUE — skip bad records, load good ones
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR = 'CONTINUE';

-- Option 3: SKIP_FILE — skip entire file if it has errors
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR = 'SKIP_FILE';

-- Option 4: SKIP_FILE_n — skip file if more than n errors
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR = 'SKIP_FILE_3';  -- Skip file if it has more than 3 errors
```

**Scenario Questions**:
1. You have 100 records. 5 have errors. You use `ON_ERROR = CONTINUE`. How many records load?
   - Answer: _______________

2. You use `ON_ERROR = ABORT_STATEMENT`. The 50th record has an error. What happens?
   - Answer: _______________

3. You want to load all valid records from a file that has some bad data. Which option do you use?
   - Answer: _______________

---

### Exercise 4.3 — VALIDATION_MODE

Use VALIDATION_MODE to test data BEFORE actually loading:

```sql
-- Check errors without loading data
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
VALIDATION_MODE = 'RETURN_ALL_ERRORS';

-- Return first N rows that would be loaded
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
VALIDATION_MODE = 'RETURN_2_ROWS';
```

**Key Point**: With `VALIDATION_MODE`, data is NOT actually loaded. It only validates.

---

### Exercise 4.4 — PURGE Option

```sql
-- PURGE = TRUE removes the file from stage after successful load
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
PURGE = TRUE;

-- PURGE = FALSE (default) — keeps the file in stage after loading
```

**Question**: What is the risk of loading the same file twice without PURGE?
- Answer: _______________

**Important**: Snowflake prevents re-loading the same file by default (tracks file metadata). Use `FORCE = TRUE` to override:
```sql
-- Force re-load even if file was loaded before
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
FORCE = TRUE;
```

---

## Section 5: Copy History

### Exercise 5.1 — Check Copy History

```sql
-- Check what files were loaded into a table
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'EMP_STAGING',
    START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
));

-- Columns you'll see:
-- FILE_NAME, STAGE_LOCATION, LAST_LOAD_TIME, STATUS
-- ROW_COUNT, ERRORS_SEEN, FIRST_ERROR
```

---

## Section 6: Reading Stage Files Directly

### Exercise 6.1 — Query a Stage (Without Loading)

```sql
-- Read CSV file directly from stage (column $1, $2, etc.)
SELECT $1 AS emp_id, $2 AS emp_name, $3 AS department
FROM @csv_stage/employees.csv
(FILE_FORMAT => 'csv_format');

-- Read JSON file — entire record in $1
SELECT $1 FROM @json_stage/employees.json
(FILE_FORMAT => 'json_format');

-- Extract JSON fields
SELECT 
    $1:emp_id::NUMBER AS emp_id,
    $1:emp_name::VARCHAR AS emp_name,
    $1:salary::NUMBER AS salary
FROM @json_stage/employees.json
(FILE_FORMAT => 'json_format');
```

---

## Section 7: SnowSQL CLI Reference

> **Note**: The PUT command only works in SnowSQL (command-line interface), NOT in the Snowflake web UI.

```bash
# Login to SnowSQL
snowsql -a <account_identifier> -u <username>

# Upload file to internal stage
PUT file:///path/to/employees.csv @csv_stage;

# Upload with auto-compress
PUT file:///path/to/employees.csv @csv_stage AUTO_COMPRESS=FALSE;

# List files in stage
LIST @csv_stage;

# Download file from stage to local
GET @csv_stage/employees.csv file:///local/path/;
```

---

## Snowpipe Quick Reference

```sql
-- Snowpipe = automated/continuous loading from cloud stages

-- Create a snowpipe
CREATE PIPE my_pipe
    AUTO_INGEST = TRUE    -- Triggered automatically by cloud events
AS
COPY INTO emp_staging
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = 'csv_format');

-- Check pipes
SHOW PIPES;

-- Get DDL of a pipe
SELECT GET_DDL('PIPE', 'MY_PIPE');

-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('MY_PIPE');
```

---

## Challenge Questions

1. Create a file format that handles:
   - Pipe-delimited (`|`) file
   - Has a header row
   - Treats empty string as NULL
   - Has double-quote as the text qualifier

2. Write a COPY INTO that:
   - Loads from `@csv_stage`
   - Skips bad records (continues loading)
   - Only loads files matching pattern `emp_*.csv`
   - Removes files after successful load

3. You loaded a file of 50 records. Then truncated the table. Now you try to COPY the same file again. What will happen and how do you fix it?
   - Answer: _______________
   - Fix: _______________

4. What is the difference between a **named stage** and a **table stage** in Snowflake?
   - Named stage: _______________
   - Table stage: _______________
   - Note: Table stages use `@%table_name` syntax

## Answer Key

**Exercise 4.2 Scenarios**:
1. 95 records load (5 skipped)
2. The COPY command stops entirely; 0 records are loaded
3. `ON_ERROR = CONTINUE`

**Challenge Q3**:
- What happens: Snowflake tracks metadata about loaded files; the same file won't be loaded again by default
- Fix: Use `FORCE = TRUE` in COPY INTO, OR truncate metadata with `ALTER TABLE emp_staging TRUNCATE TABLE` then COPY again (metadata is cleared on truncate!)
