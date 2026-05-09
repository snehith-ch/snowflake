# SQL vs Snowflake — Comprehensive Reference

A complete comparison of standard SQL commands vs Snowflake equivalents, covering DDL, DML, DCL, data loading, semi-structured data, and Snowflake-specific features.

---

## 1. DDL (Data Definition Language)

### Databases and Schemas

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `CREATE DATABASE db` | `CREATE DATABASE db` | Same syntax |
| `CREATE SCHEMA schema` | `CREATE SCHEMA schema` | Same syntax |
| `DROP DATABASE db` | `DROP DATABASE db` | Same syntax |
| `DROP SCHEMA schema` | `DROP SCHEMA schema` | Same syntax |
| `ALTER DATABASE db RENAME TO new_db` | `ALTER DATABASE db RENAME TO new_db` | Same |
| *(no equivalent)* | `UNDROP DATABASE db` | Snowflake-specific: restores dropped DB within retention period |
| *(no equivalent)* | `UNDROP SCHEMA schema` | Snowflake-specific |

### Tables

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `CREATE TABLE t (col TYPE)` | `CREATE TABLE t (col TYPE)` | Same base syntax |
| `CREATE TABLE t AS SELECT ...` | `CREATE TABLE t AS SELECT ...` | Same (CTAS) |
| `CREATE TEMP TABLE t ...` | `CREATE TEMPORARY TABLE t ...` | Session-scoped, auto-dropped |
| *(no equivalent)* | `CREATE TRANSIENT TABLE t ...` | No fail-safe, lower storage cost |
| `DROP TABLE t` | `DROP TABLE t` | Same |
| `DROP TABLE IF EXISTS t` | `DROP TABLE IF EXISTS t` | Same |
| `TRUNCATE TABLE t` | `TRUNCATE TABLE t` | Same |
| `ALTER TABLE t ADD COLUMN col TYPE` | `ALTER TABLE t ADD COLUMN col TYPE` | Same |
| `ALTER TABLE t DROP COLUMN col` | `ALTER TABLE t DROP COLUMN col` | Same |
| `ALTER TABLE t RENAME TO new_t` | `ALTER TABLE t RENAME TO new_t` | Same |
| *(no equivalent)* | `UNDROP TABLE t` | Restores within Time Travel window |
| *(no equivalent)* | `CREATE TABLE t CLONE source_t` | Zero-copy clone |
| *(no equivalent)* | `ALTER TABLE t CLUSTER BY (col)` | Micro-partition clustering |

### Views

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `CREATE VIEW v AS SELECT ...` | `CREATE VIEW v AS SELECT ...` | Same |
| `CREATE OR REPLACE VIEW v AS SELECT ...` | `CREATE OR REPLACE VIEW v AS SELECT ...` | Same |
| `DROP VIEW v` | `DROP VIEW v` | Same |
| *(limited support)* | `CREATE SECURE VIEW v AS SELECT ...` | Hides view definition from non-owners |
| *(no equivalent)* | `CREATE MATERIALIZED VIEW mv AS SELECT ...` | Pre-computed, auto-refreshes (single table only) |
| *(no equivalent)* | `CREATE SECURE MATERIALIZED VIEW mv AS SELECT ...` | Secure + materialized |
| *(no equivalent)* | `CREATE DYNAMIC TABLE dt TARGET_LAG='2 min' AS SELECT ...` | Multi-table auto-refresh |

### Indexes vs Clustering Keys

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `CREATE INDEX idx ON t (col)` | *(no indexes in Snowflake)* | Snowflake uses micro-partition pruning instead |
| `DROP INDEX idx` | *(not applicable)* | — |
| *(no equivalent)* | `ALTER TABLE t CLUSTER BY (col)` | Reorganizes micro-partitions for pruning |
| *(no equivalent)* | `ALTER TABLE t DROP CLUSTERING KEY` | Remove clustering |

---

## 2. DML (Data Manipulation Language)

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `SELECT * FROM t` | `SELECT * FROM t` | Same |
| `INSERT INTO t VALUES (...)` | `INSERT INTO t VALUES (...)` | Same |
| `INSERT INTO t SELECT ...` | `INSERT INTO t SELECT ...` | Same |
| `UPDATE t SET col=val WHERE ...` | `UPDATE t SET col=val WHERE ...` | Same |
| `DELETE FROM t WHERE ...` | `DELETE FROM t WHERE ...` | Same |
| `MERGE INTO target USING source ON ...` | `MERGE INTO target USING source ON ...` | Same (powerful in Snowflake with streams) |
| `SELECT * FROM t LIMIT n` | `SELECT * FROM t LIMIT n` | Same |
| *(varies by DB)* | `SELECT * EXCLUDE col FROM t` | Snowflake-specific: exclude columns from SELECT * |
| *(varies by DB)* | `SELECT * RENAME col AS new_col FROM t` | Snowflake-specific: rename in SELECT * |
| *(varies by DB)* | `SELECT * ILIKE '%pattern%' FROM t` | Snowflake-specific: filter columns by name |

### Time Travel Queries (Snowflake-Specific)

```sql
-- Standard SQL: no equivalent
-- Snowflake:
SELECT * FROM t AT (TIMESTAMP => '2025-01-01 12:00:00'::TIMESTAMP);
SELECT * FROM t AT (OFFSET => -3600);            -- 1 hour ago
SELECT * FROM t AT (STATEMENT => 'query_id');
SELECT * FROM t BEFORE (STATEMENT => 'query_id');
```

---

## 3. DCL (Data Control Language)

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `GRANT SELECT ON t TO user` | `GRANT SELECT ON TABLE t TO ROLE role_name` | Snowflake grants to **roles**, not users directly |
| `REVOKE SELECT ON t FROM user` | `REVOKE SELECT ON TABLE t FROM ROLE role_name` | Same difference |
| `GRANT ALL ON t TO user` | `GRANT ALL PRIVILEGES ON TABLE t TO ROLE role_name` | Same concept |
| `CREATE USER user ...` | `CREATE USER user PASSWORD='...' DEFAULT_ROLE=...` | Extended Snowflake options |
| `CREATE ROLE role` | `CREATE ROLE role` | Same |
| `GRANT role TO user` | `GRANT ROLE role TO USER user` | Snowflake syntax is explicit |
| *(no equivalent)* | `GRANT USAGE ON WAREHOUSE w TO ROLE role` | Snowflake: warehouse access must be granted |
| *(no equivalent)* | `GRANT USAGE ON DATABASE db TO ROLE role` | Snowflake: database access must be granted |
| *(no equivalent)* | `GRANT USAGE ON SCHEMA s TO ROLE role` | Snowflake: schema access must be granted |
| *(no equivalent)* | `GRANT FUTURE GRANTS ...` | Automatically grant privileges on future objects |

### Snowflake RBAC (Role-Based Access Control)

```sql
-- Standard SQL does not have this layered approach
-- Snowflake requires each level to be granted:
GRANT USAGE ON DATABASE my_db TO ROLE analyst;
GRANT USAGE ON SCHEMA my_db.my_schema TO ROLE analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA my_db.my_schema TO ROLE analyst;

-- Grant role to user
GRANT ROLE analyst TO USER john;

-- Assume role in session
USE ROLE analyst;
```

---

## 4. Data Loading

### Standard SQL vs Snowflake Loading

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `INSERT INTO t VALUES (...)` | `INSERT INTO t VALUES (...)` | Works but not for bulk loads |
| `BULK INSERT t FROM 'file'` (SQL Server) | `COPY INTO t FROM @stage` | Different approach |
| `LOAD DATA INFILE 'file' INTO t` (MySQL) | `COPY INTO t FROM @stage FILE_FORMAT=(TYPE=CSV)` | Different approach |
| *(no equivalent)* | `PUT file://local/path @stage_name` | Upload file to Snowflake stage |
| *(no equivalent)* | `LIST @stage_name` | List files in stage |
| *(no equivalent)* | `REMOVE @stage/file.csv` | Delete file from stage |
| *(no equivalent)* | `GET @stage/file.csv file://local/path` | Download file from stage |

### COPY INTO Syntax
```sql
-- Load from internal stage
COPY INTO my_table
FROM @my_stage/path/
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Load from external stage (S3)
COPY INTO my_table
FROM 's3://bucket/folder/'
STORAGE_INTEGRATION = s3_integration
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
PATTERN = '.*\.csv';

-- Validate without loading
COPY INTO my_table
FROM @my_stage
VALIDATION_MODE = RETURN_ALL_ERRORS;
```

---

## 5. Semi-Structured Data

Standard SQL has very limited support. Snowflake has native semi-structured capabilities.

| Concept | Standard SQL | Snowflake |
|---|---|---|
| JSON storage | `TEXT` column + manual parsing | `VARIANT` native type |
| JSON parsing | `JSON_VALUE()` (limited) | Dot notation `col:key` or `col['key']` |
| JSON array access | Not standard | `col[0]`, `col[1]` |
| Type casting | `CAST(val AS type)` | `val::type` shorthand |
| Null handling in JSON | Not standard | `TRY_PARSE_JSON()` returns NULL on error |
| Array functions | Varies by vendor | `ARRAY_SIZE()`, `ARRAY_CONTAINS()`, `ARRAY_APPEND()` |
| Object construction | Not standard | `OBJECT_CONSTRUCT('key', value)` |
| Array construction | Not standard | `ARRAY_CONSTRUCT(v1, v2, v3)` |
| Unnest arrays | Not standard | `LATERAL FLATTEN(INPUT => col)` |
| XML parsing | `XMLTABLE` (limited) | `XMLGET(col, 'tagname')` |
| Path expressions | Not standard | `$` (dollar sign) for root element |

### Semi-Structured Queries in Snowflake

```sql
-- Standard SQL: no equivalent
-- Snowflake:

-- Access JSON key
SELECT col:customer_id::NUMBER AS cust_id FROM t;

-- Nested key access
SELECT col:address:city::VARCHAR AS city FROM t;

-- Array element
SELECT col:orders[0]:order_id::NUMBER AS first_order FROM t;

-- Flatten array
SELECT
    f.value:item_name::VARCHAR AS item,
    f.value:quantity::NUMBER   AS qty
FROM t,
LATERAL FLATTEN(INPUT => col:items) f;

-- Object construction
SELECT OBJECT_CONSTRUCT('name', emp_name, 'salary', salary) AS emp_json
FROM employees;

-- Array aggregation
SELECT ARRAY_AGG(product_name) AS product_list
FROM products;
```

---

## 6. Snowflake-Specific Objects (No SQL Standard Equivalent)

### Stages
```sql
-- Internal named stage
CREATE STAGE my_stage
    FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

-- External stage (S3 with storage integration)
CREATE STAGE s3_stage
    URL = 's3://bucket/folder/'
    STORAGE_INTEGRATION = s3_integration;

-- External stage (S3 with credentials - not recommended)
CREATE STAGE s3_creds_stage
    URL = 's3://bucket/folder/'
    CREDENTIALS = (AWS_KEY_ID = '...' AWS_SECRET_KEY = '...');
```

### Snowpipe (Continuous Loading)
```sql
CREATE PIPE my_pipe
    AUTO_INGEST = TRUE
AS
COPY INTO my_table FROM @my_stage;

-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('my_pipe');
SHOW PIPES;
```

### Streams (Change Data Capture)
```sql
-- Standard stream (captures INSERT/UPDATE/DELETE)
CREATE STREAM std_stream ON TABLE my_table;

-- Append-only stream (captures only INSERTs)
CREATE STREAM append_stream ON TABLE my_table APPEND_ONLY = TRUE;

-- Insert-only stream on external table
CREATE STREAM ext_stream ON EXTERNAL TABLE ext_table INSERT_ONLY = TRUE;

-- Consuming a stream
SELECT *, METADATA$ACTION, METADATA$ISUPDATE
FROM my_stream;
```

### Tasks (Scheduled SQL Execution)
```sql
-- Standalone task with cron schedule
CREATE TASK my_task
    WAREHOUSE  = COMPUTE_WH
    SCHEDULE   = 'USING CRON 0 2 * * * UTC'
AS
INSERT INTO target_table SELECT * FROM source_table;

-- Child task (triggers after parent)
CREATE TASK child_task
    WAREHOUSE = COMPUTE_WH
    AFTER parent_task
AS
MERGE INTO target USING source ON ...;

-- Control tasks
ALTER TASK my_task RESUME;
ALTER TASK my_task SUSPEND;
```

### Storage Integration
```sql
CREATE STORAGE INTEGRATION s3_integration
    TYPE                      = EXTERNAL_STAGE
    STORAGE_PROVIDER          = S3
    ENABLED                   = TRUE
    STORAGE_AWS_ROLE_ARN      = 'arn:aws:iam::123:role/snowflake_role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://my-bucket/');

DESCRIBE STORAGE INTEGRATION s3_integration;
SHOW INTEGRATIONS;
```

### Resource Monitor
```sql
CREATE RESOURCE MONITOR rm_dev
    WITH CREDIT_QUOTA = 10
    FREQUENCY = MONTHLY
    TRIGGERS
        ON 50 PERCENT DO NOTIFY
        ON 80 PERCENT DO SUSPEND
        ON 90 PERCENT DO SUSPEND_IMMEDIATE
    WAREHOUSES = dev_warehouse;
```

### Sequences
```sql
-- Standard SQL uses IDENTITY/AUTOINCREMENT
CREATE SEQUENCE seq_emp START = 1 INCREMENT = 1;
SELECT seq_emp.NEXTVAL;

-- Or inline autoincrement (Snowflake)
CREATE TABLE t (
    id NUMBER AUTOINCREMENT START 1 INCREMENT 1,
    name VARCHAR
);
```

### Data Shares
```sql
CREATE SHARE my_share;
GRANT USAGE ON DATABASE db TO SHARE my_share;
GRANT SELECT ON TABLE t TO SHARE my_share;

-- Add consumer account
ALTER SHARE my_share ADD ACCOUNT = 'consumer_account_id';
```

---

## 7. Data Types — Differences

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `INT` / `INTEGER` | `NUMBER(38,0)` or `INT` | Snowflake numbers have precision |
| `DECIMAL(p,s)` | `NUMBER(p,s)` | Identical in behavior |
| `FLOAT` / `REAL` | `FLOAT` / `DOUBLE` | Same |
| `VARCHAR(n)` | `VARCHAR(n)` | Max 16,777,216 in Snowflake |
| `CHAR(n)` | `CHAR(n)` | Same |
| `TEXT` / `CLOB` | `TEXT` or `VARCHAR(16777216)` | No separate TEXT type needed |
| `DATE` | `DATE` | Same |
| `TIME` | `TIME` | Same |
| `DATETIME` | `TIMESTAMP_NTZ` | No timezone |
| `TIMESTAMP` | `TIMESTAMP_LTZ` (with TZ) or `TIMESTAMP_NTZ` | LTZ = Local TZ, NTZ = no TZ |
| *(no equivalent)* | `VARIANT` | Stores any JSON/XML/Avro value |
| *(no equivalent)* | `ARRAY` | Semi-structured array type |
| *(no equivalent)* | `OBJECT` | Semi-structured key-value object |
| `BOOLEAN` | `BOOLEAN` | Same |
| `BINARY` | `BINARY` / `VARBINARY` | Same |

---

## 8. Function Differences

### String Functions

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `SUBSTRING(s, start, len)` | `SUBSTR(s, start, len)` or `SUBSTRING(...)` | Both work |
| `LENGTH(s)` | `LENGTH(s)` | Same |
| `UPPER(s)` | `UPPER(s)` | Same |
| `LOWER(s)` | `LOWER(s)` | Same |
| `TRIM(s)` | `TRIM(s)` | Same |
| `CONCAT(a, b)` | `CONCAT(a, b)` or `a || b` | `||` pipe concatenation |
| `REPLACE(s, old, new)` | `REPLACE(s, old, new)` | Same |
| *(varies)* | `SPLIT_PART(s, delim, pos)` | Extract part by delimiter |
| *(varies)* | `REGEXP_LIKE(s, pattern)` | Regex matching |
| *(varies)* | `REGEXP_REPLACE(s, pattern, replacement)` | Regex replace |
| *(varies)* | `EDITDISTANCE(s1, s2)` | Levenshtein distance |
| `CHARINDEX(s, search)` (SQL Server) | `POSITION(search IN s)` | Position of substring |

### Date Functions

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `CURRENT_DATE` | `CURRENT_DATE()` | Same |
| `CURRENT_TIMESTAMP` | `CURRENT_TIMESTAMP()` | Same |
| `DATEADD(part, n, date)` | `DATEADD(part, n, date)` | Same |
| `DATEDIFF(part, d1, d2)` | `DATEDIFF(part, d1, d2)` | Same |
| `EXTRACT(part FROM date)` | `EXTRACT(part FROM date)` or `DATE_PART(part, date)` | Both work |
| `DATE_FORMAT(date, fmt)` (MySQL) | `TO_CHAR(date, 'YYYY-MM-DD')` | Oracle-style format strings |
| `GETDATE()` (SQL Server) | `CURRENT_TIMESTAMP()` | — |
| *(varies)* | `DATE_TRUNC('month', date)` | Truncate to period |
| *(varies)* | `LAST_DAY(date)` | Last day of month |
| *(varies)* | `MONTHNAME(date)` | Returns 'Jan', 'Feb', etc. |

### Aggregate Functions

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `COUNT(*)` | `COUNT(*)` | Same (uses metadata cache) |
| `SUM(col)` | `SUM(col)` | Same |
| `AVG(col)` | `AVG(col)` | Same |
| `MIN(col)` | `MIN(col)` | Same (metadata cache) |
| `MAX(col)` | `MAX(col)` | Same (metadata cache) |
| `GROUP_CONCAT(col)` (MySQL) | `LISTAGG(col, ',') WITHIN GROUP (ORDER BY col)` | String aggregation |
| *(varies)* | `ARRAY_AGG(col)` | Aggregates values into an array |
| *(varies)* | `OBJECT_AGG(key_col, val_col)` | Aggregates key-value pairs into object |

### Conditional Functions

| Standard SQL | Snowflake | Notes |
|---|---|---|
| `CASE WHEN ... THEN ... END` | `CASE WHEN ... THEN ... END` | Same |
| `COALESCE(a, b, c)` | `COALESCE(a, b, c)` | Same |
| `NULLIF(a, b)` | `NULLIF(a, b)` | Same |
| `IIF(cond, a, b)` (SQL Server) | `IFF(cond, a, b)` | Snowflake uses IFF |
| `ISNULL(a, b)` (SQL Server) | `NVL(a, b)` | Oracle-style |
| *(varies)* | `ZEROIFNULL(col)` | Returns 0 if NULL |
| *(varies)* | `NVL2(col, not_null_val, null_val)` | Oracle-style ternary |

---

## 9. Common Pitfalls for SQL Users Moving to Snowflake

### Pitfall 1: No Indexes — Use Clustering Keys Instead
```sql
-- SQL: CREATE INDEX idx ON orders (order_date);
-- Snowflake equivalent for large tables:
ALTER TABLE orders CLUSTER BY (order_date);
```

### Pitfall 2: Grants Go to Roles, Not Users
```sql
-- Standard SQL: GRANT SELECT ON t TO user_john;
-- Snowflake: Must grant to a role, then assign role to user
GRANT SELECT ON TABLE my_table TO ROLE analyst;
GRANT ROLE analyst TO USER user_john;
```

### Pitfall 3: Three Layers of Grant Required
```sql
-- Snowflake requires ALL THREE for a user to query a table:
GRANT USAGE  ON DATABASE my_db     TO ROLE analyst;
GRANT USAGE  ON SCHEMA   my_schema TO ROLE analyst;
GRANT SELECT ON TABLE    my_table  TO ROLE analyst;
```

### Pitfall 4: AUTOINCREMENT vs SEQUENCE
```sql
-- Standard SQL: IDENTITY(1,1)
-- Snowflake:
id NUMBER AUTOINCREMENT START 1 INCREMENT 1
-- Or:
id NUMBER DEFAULT seq_name.NEXTVAL
```

### Pitfall 5: Case Sensitivity in Identifiers
```sql
-- Snowflake is case-INSENSITIVE by default for unquoted identifiers
SELECT * FROM MY_TABLE;  -- Same as my_table
SELECT * FROM "MyTable"; -- Different! Quoted = case-sensitive

-- Column names stored in uppercase unless quoted at creation
SELECT CUSTOMER_NAME FROM t;   -- Works
SELECT customer_name FROM t;   -- Works (auto-uppercased)
SELECT "customer_name" FROM t; -- May FAIL if column was created as CUSTOMER_NAME
```

### Pitfall 6: NULL Handling in Snowflake
```sql
-- Snowflake: NULL != NULL (standard SQL behavior)
SELECT NULL = NULL;    -- Returns NULL, not TRUE
SELECT NULL IS NULL;   -- Returns TRUE

-- Sorting: NULLs sort LAST by default in Snowflake ASC
SELECT * FROM t ORDER BY col ASC NULLS LAST;  -- Explicit is clearer
```

### Pitfall 7: Semi-Colon Not Required in Snowflake UI
```sql
-- Single statements in Snowflake UI don't need a semicolon
-- But in scripts, use semicolons to separate statements
SELECT 1  -- OK in worksheet
```

### Pitfall 8: Snowflake Always Has a Warehouse Context
```sql
-- Before running any query, ensure a warehouse is selected:
USE WAREHOUSE COMPUTE_WH;
-- Or set a default warehouse in user properties
```

### Pitfall 9: Time Travel vs Fail-Safe
```sql
-- Time Travel: User-accessible, configurable (0–90 days for Enterprise)
-- Fail-Safe: 7 days AFTER Time Travel, only Snowflake Support can recover

-- Permanent table: Time Travel + Fail-Safe
-- Transient table: Time Travel only (0-1 day), NO Fail-Safe
-- Temporary table: Time Travel only, dropped at session end
```

### Pitfall 10: COPY INTO Is Idempotent by Default
```sql
-- COPY INTO skips files already loaded (tracks load history)
-- To reload a previously loaded file, use FORCE = TRUE:
COPY INTO my_table FROM @stage/file.csv FORCE = TRUE;

-- Or use PURGE = TRUE to delete file after loading:
COPY INTO my_table FROM @stage PURGE = TRUE;
```

### Pitfall 11: Materialized Views Only Support Single Tables
```sql
-- This FAILS:
CREATE MATERIALIZED VIEW mv AS
SELECT a.col1, b.col2
FROM table_a a JOIN table_b b ON a.id = b.id;
-- Error: More than one table reference in definition

-- Use Dynamic Table instead:
CREATE DYNAMIC TABLE dt TARGET_LAG = '5 minutes' WAREHOUSE = wh AS
SELECT a.col1, b.col2
FROM table_a a JOIN table_b b ON a.id = b.id;
```

---

## 10. Snowflake-Only Features Summary

| Feature | SQL Standard | Snowflake |
|---|---|---|
| Zero-copy cloning | No | `CREATE TABLE t CLONE source` |
| Time Travel | No | `AT`/`BEFORE` clauses |
| Fail-Safe | No | 7-day post-Time Travel recovery |
| Semi-structured types | No | `VARIANT`, `ARRAY`, `OBJECT` |
| Micro-partition pruning | No (uses indexes) | Automatic + clustering keys |
| Result cache | No | 24-hour query result cache |
| Warehouse cache | No | Local SSD in virtual warehouse |
| Auto-suspend/resume | No | Warehouse setting |
| Snowpipe | No | Continuous S3 ingestion |
| Streams (CDC) | No | `CREATE STREAM ON TABLE` |
| Tasks | Via external tools | `CREATE TASK WITH SCHEDULE` |
| Storage integrations | No | IAM Role-based S3 access |
| Data sharing | No | Cross-account secure shares |
| Secure views | No | `CREATE SECURE VIEW` |
| Dynamic data masking | No | `CREATE MASKING POLICY` |
| Row access policies | No | `CREATE ROW ACCESS POLICY` |
| Query Acceleration Service | No | Scaling factor boost |
| Snowpark | No | Python/Java/Scala in Snowflake |
| Cortex AI | No | Built-in ML/AI capabilities |

---

*Reference guide for Snowflake training series — Lectures 1–35.*
