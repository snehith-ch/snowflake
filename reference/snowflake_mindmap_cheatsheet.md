# Snowflake — Mind Map & Visual Cheat Sheet

---

## 1. Snowflake Big Picture (Mind Map)

```
                         ┌─────────────────────────────────────┐
                         │           SNOWFLAKE                 │
                         │   Cloud Data Warehouse Platform     │
                         └──────────────┬──────────────────────┘
                                        │
          ┌─────────────────────────────┼─────────────────────────────┐
          │                             │                             │
   ┌──────▼──────┐             ┌────────▼────────┐          ┌────────▼────────┐
   │  STRUCTURE  │             │   PROCESSING    │          │    SECURITY     │
   │             │             │                 │          │                 │
   │ Database    │             │ Virtual         │          │ Roles (RBAC)    │
   │   Schema    │             │ Warehouse       │          │ Users           │
   │    Table    │             │                 │          │ Masking Policy  │
   │    View     │             │ ─ X-Small       │          │ Row Access      │
   │  Sequence   │             │ ─ Small         │          │ Network Policy  │
   └─────────────┘             │ ─ Medium        │          └─────────────────┘
                               │ ─ Large         │
   ┌─────────────┐             │ ─ X-Large       │          ┌─────────────────┐
   │  DATA LOAD  │             └─────────────────┘          │  ADVANCED       │
   │             │                                          │                 │
   │ Stage       │             ┌─────────────────┐          │ Time Travel     │
   │ File Format │             │   TRANSFORM     │          │ Fail Safe       │
   │ COPY INTO   │             │                 │          │ Cloning         │
   │ Snowpipe    │             │ Streams         │          │ Clustering      │
   │ PUT (CLI)   │             │ Tasks           │          │ Caching         │
   └─────────────┘             │ Procedures      │          │ EXPLAIN Plan    │
                               │ UDFs            │          └─────────────────┘
                               │ DBT / Informatica│
                               └─────────────────┘
```

---

## 2. Snowflake Architecture (Detailed)

```
┌─────────────────────────────────────────────────────────────────────┐
│                      SNOWFLAKE ARCHITECTURE                         │
└─────────────────────────────────────────────────────────────────────┘

Layer 3: CLOUD SERVICES LAYER (Metadata + Authentication + Optimization)
┌─────────────────────────────────────────────────────────────────────┐
│  Authentication │ Access Control │ Query Parser │ Query Optimizer   │
│  Metadata Manager │ Infrastructure Manager │ Transaction Manager   │
└─────────────────────────────────────────────────────────────────────┘
                              ↕ (communicates with all layers)

Layer 2: QUERY PROCESSING LAYER (Compute)
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐
│  Warehouse 1 │  │  Warehouse 2 │  │  Warehouse 3 │  │  WH N ...  │
│  (X-Small)   │  │   (Large)    │  │   (Medium)   │  │            │
│              │  │              │  │              │  │            │
│  Read/Write  │  │  Read/Write  │  │  Read/Write  │  │  Read/Write│
└──────────────┘  └──────────────┘  └──────────────┘  └────────────┘
                              ↕ (reads data)

Layer 1: DATABASE STORAGE LAYER (Persistent Storage)
┌─────────────────────────────────────────────────────────────────────┐
│                      CENTRALIZED STORAGE                            │
│  Micro-partition 1 │ Micro-partition 2 │ ... │ Micro-partition N   │
│  (16MB-512MB each) │   (Columnar,      │     │  (Compressed &      │
│                    │    Immutable)     │     │   Encrypted)        │
└─────────────────────────────────────────────────────────────────────┘

KEY INSIGHT: Storage and Compute are SEPARATE → Scale independently!
```

---

## 3. Object Hierarchy

```
ACCOUNT
  └── DATABASE
        └── SCHEMA
              ├── TABLE
              ├── VIEW
              ├── MATERIALIZED VIEW
              ├── STAGE (internal/external)
              ├── FILE FORMAT
              ├── SEQUENCE
              ├── STREAM
              ├── TASK
              ├── PIPE (Snowpipe)
              ├── STORED PROCEDURE
              ├── FUNCTION (UDF)
              ├── MASKING POLICY
              └── EXTERNAL TABLE
```

---

## 4. Role Hierarchy

```
ACCOUNTADMIN  ←── Highest privilege, full control
      │
SECURITYADMIN ←── Manages roles and privileges
      │
  USERADMIN   ←── Creates users and roles
      │
  SYSADMIN    ←── Creates databases, schemas, tables, warehouses
      │
   PUBLIC      ←── Default role for ALL users (minimum access)
```

**Memory tip**: **A**lways **S**tay **U**nder **S**nowy **P**eaks
(AccountAdmin → SecurityAdmin → UserAdmin → SysAdmin → Public)

---

## 5. Data Loading Flow

```
LOCAL MACHINE
     │
     │  [PUT - SnowSQL CLI only]
     ▼
INTERNAL STAGE (@csv_stage)
     │
     │  [COPY INTO table]
     ▼
SNOWFLAKE TABLE ✓

──────────────────────────────────────────────

CLOUD STORAGE (S3 / Azure Blob / GCS)
     │
     │  (external stage points here)
     ▼
EXTERNAL STAGE (@s3_stage)
     │
     │  [COPY INTO table]
     ▼
SNOWFLAKE TABLE ✓

──────────────────────────────────────────────

CLOUD STORAGE + EVENT NOTIFICATION
     │
     │  [Snowpipe — AUTO_INGEST = TRUE]
     ▼
SNOWPIPE (listens for new files)
     │
     │  [automatic COPY INTO]
     ▼
SNOWFLAKE TABLE ✓  (near real-time loading)
```

---

## 6. Table Types Quick Reference

```
┌─────────────────┬──────────────┬─────────────┬───────────────────────┐
│   Table Type    │  Retention   │  Fail Safe  │       Use Case        │
├─────────────────┼──────────────┼─────────────┼───────────────────────┤
│ PERMANENT       │ 0-90 days    │ 7 days      │ Production data       │
│                 │ (default: 1) │             │                       │
├─────────────────┼──────────────┼─────────────┼───────────────────────┤
│ TRANSIENT       │ 0-1 day      │ None (0)    │ Staging/temp storage  │
│                 │ (default: 0) │             │ (save costs)          │
├─────────────────┼──────────────┼─────────────┼───────────────────────┤
│ TEMPORARY       │ 0 days       │ None (0)    │ Session-only data;    │
│                 │              │             │ auto-deleted on logout│
├─────────────────┼──────────────┼─────────────┼───────────────────────┤
│ EXTERNAL        │ 0 days       │ None (0)    │ Read files as table;  │
│                 │              │             │ data lives in S3/etc  │
└─────────────────┴──────────────┴─────────────┴───────────────────────┘
```

---

## 7. Stream Types Quick Reference

```
┌──────────────────┬──────────────────────────────┬─────────────────────────┐
│   Stream Type    │      Captures What?           │      Created With        │
├──────────────────┼──────────────────────────────┼─────────────────────────┤
│ Standard         │ INSERT + UPDATE + DELETE      │ CREATE STREAM s ON      │
│ (default)        │ (all changes)                 │   TABLE t;              │
├──────────────────┼──────────────────────────────┼─────────────────────────┤
│ Append-Only      │ INSERT only                   │ CREATE STREAM s ON      │
│                  │ (ignores UPDATE/DELETE)        │   TABLE t               │
│                  │                               │   APPEND_ONLY = TRUE;   │
├──────────────────┼──────────────────────────────┼─────────────────────────┤
│ Insert-Only      │ INSERT only (for external     │ CREATE STREAM s ON      │
│                  │ tables/iceberg tables)         │   TABLE ext_t           │
│                  │                               │   INSERT_ONLY = TRUE;   │
└──────────────────┴──────────────────────────────┴─────────────────────────┘
```

---

## 8. Stream Metadata Columns

```
When INSERT happens:
  METADATA$ACTION    = 'INSERT'
  METADATA$ISUPDATE  = FALSE

When DELETE happens:
  METADATA$ACTION    = 'DELETE'
  METADATA$ISUPDATE  = FALSE

When UPDATE happens (TWO records appear):
  Record 1: METADATA$ACTION = 'DELETE', METADATA$ISUPDATE = TRUE  ← OLD value
  Record 2: METADATA$ACTION = 'INSERT', METADATA$ISUPDATE = TRUE  ← NEW value
  
  (To get the LATEST value after update: pick INSERT + ISUPDATE = TRUE)
```

---

## 9. Caching Mind Map

```
SNOWFLAKE CACHING
        │
        ├── Result Cache (Cloud Services Layer)
        │       ├── Duration: 24 hours
        │       ├── Condition: Same query + data unchanged
        │       ├── Disable: ALTER SESSION SET USE_CACHED_RESULT = FALSE
        │       └── Benefit: FREE — no compute cost
        │
        ├── Warehouse/Local Cache (Virtual Warehouse)
        │       ├── Duration: Until warehouse suspends
        │       ├── Condition: Same warehouse reuses data in memory
        │       ├── Benefit: Faster reads from memory than storage
        │       └── Note: Cleared when warehouse suspends
        │
        └── Metadata Cache (Cloud Services Layer)
                ├── Duration: Persistent
                ├── Used for: COUNT(*), MAX, MIN, AVG (some operations)
                └── Benefit: Aggregates without scanning all data
```

---

## 10. Time Travel Mind Map

```
DATA WRITTEN TO TABLE
        │
        ▼
 [TODAY: Day 0]
        │
        ▼  ← Can time-travel back to ANY point in this period
 [Day 1 to Day 90]  ← TIME TRAVEL PERIOD
    (configurable: 0-90 days)
        │
        ▼  ← Cannot self-restore; need Snowflake Support
 [Day 91 to Day 97]  ← FAIL SAFE PERIOD (7 days, fixed)
        │
        ▼
 [Day 98+]  ← DATA PERMANENTLY DELETED


TIME TRAVEL COMMANDS:
─────────────────────
-- Go back N seconds
SELECT * FROM table AT(OFFSET => -N);

-- Go back to specific time
SELECT * FROM table AT(TIMESTAMP => 'YYYY-MM-DD HH:MM:SS'::TIMESTAMP_NTZ);

-- Go back to before a SQL statement
SELECT * FROM table BEFORE(STATEMENT => 'query_id');

-- Restore deleted table
UNDROP TABLE table_name;

-- Clone at a past point
CREATE TABLE backup CLONE source AT(OFFSET => -3600);
```

---

## 11. Cloning (Zero-Copy) Diagram

```
BEFORE CLONE:
Source Table  [P1][P2][P3][P4][P5]   Storage: 100 MB

AFTER CLONE:
Source Table  [P1][P2][P3][P4][P5]   Storage: 100 MB (unchanged)
Clone Table   [P1][P2][P3][P4][P5]   Storage: 0 MB (shares same micro-partitions!)
              ↑ points to same data

AFTER MODIFYING CLONE:
Source Table  [P1][P2][P3][P4][P5]   Storage: 100 MB
Clone Table   [P1][P2][P3][P4][P5]   Storage: 0 MB for shared
              + [P6][P7]              Storage: 15 MB for new/changed data

KEY POINT: You only pay for CHANGES made to the clone, not the full copy!
```

---

## 12. Virtual Warehouse Sizes

```
Size       │ Compute Credits/Hour  │ Best For
───────────┼───────────────────────┼──────────────────────────────
X-Small    │ 1 credit/hour         │ Development, small queries
Small      │ 2 credits/hour        │ Small workloads
Medium     │ 4 credits/hour        │ Moderate workloads
Large      │ 8 credits/hour        │ Heavy workloads
X-Large    │ 16 credits/hour       │ Very heavy workloads
2X-Large   │ 32 credits/hour       │ Large ETL jobs
3X-Large   │ 64 credits/hour       │ Very large ETL
4X-Large   │ 128 credits/hour      │ Maximum compute

Rule: Each size UP doubles compute AND cost
Rule: Minimum billing = 1 minute, then per second
```

---

## 13. COPY INTO Parameters Quick Reference

```sql
COPY INTO table_name
FROM @stage_name
FILE_FORMAT = (FORMAT_NAME = 'fmt_name'
               -- OR inline:
               TYPE = CSV
               FIELD_DELIMITER = ','
               SKIP_HEADER = 1)
ON_ERROR = { CONTINUE        -- Skip bad records, load good ones
           | ABORT_STATEMENT -- Stop on first error (DEFAULT)
           | SKIP_FILE       -- Skip entire file on any error
           | SKIP_FILE_n }   -- Skip file if more than n errors
PURGE = { TRUE | FALSE }     -- Remove file after load? (default FALSE)
FORCE = { TRUE | FALSE }      -- Re-load even if loaded before? (default FALSE)
TRUNCATECOLUMNS = { TRUE | FALSE }  -- Truncate values that exceed column width?
PATTERN = '.*\.csv'           -- Regex pattern to match file names
VALIDATION_MODE = { RETURN_ALL_ERRORS
                  | RETURN_n_ROWS }  -- Validate without loading
```

---

## 14. Useful Functions Quick Reference

```sql
-- Context Functions
CURRENT_USER()         -- Current logged-in user
CURRENT_ROLE()         -- Current active role
CURRENT_DATABASE()     -- Current database
CURRENT_SCHEMA()       -- Current schema
CURRENT_WAREHOUSE()    -- Current warehouse
CURRENT_DATE()         -- Today's date
CURRENT_TIMESTAMP()    -- Current date and time

-- DDL Functions
GET_DDL('TABLE', 'db.schema.table')      -- Get CREATE TABLE statement
GET_DDL('VIEW', 'view_name')             -- Get CREATE VIEW statement
GET_DDL('PIPE', 'pipe_name')             -- Get CREATE PIPE statement
GET_DDL('PROCEDURE', 'proc(type)')       -- Get CREATE PROCEDURE statement

-- Semi-Structured Functions
PARSE_JSON('{"key": "val"}')             -- Parse string as JSON
OBJECT_KEYS(variant_col)                 -- Get keys from JSON object
ARRAY_SIZE(array_col)                    -- Count elements in array
ARRAY_TO_STRING(array_col, delimiter)    -- Convert array to string
ARRAY_CONTAINS(val::VARIANT, array_col)  -- Check if value exists in array
OBJECT_CONSTRUCT('k1', v1, 'k2', v2)    -- Build JSON object
TYPEOF(variant_col)                      -- Get type of VARIANT value
FLATTEN(input => array_col)              -- Used with LATERAL

-- Date Functions
DATEADD(unit, amount, date)              -- Add to date
DATEDIFF(unit, date1, date2)             -- Difference between dates
DATE_TRUNC('MONTH', date)                -- Truncate to start of month
YEAR(date) / MONTH(date) / DAY(date)     -- Extract parts
TO_DATE('2024-01-15')                    -- Convert string to date

-- String Functions
UPPER(str) / LOWER(str)                  -- Case conversion
LEFT(str, n) / RIGHT(str, n)             -- Get n chars from left/right
TRIM(str) / LTRIM(str) / RTRIM(str)      -- Remove whitespace
REPLACE(str, find, replace)              -- Replace substring
SPLIT_PART(str, delimiter, position)     -- Split and get part
SUBSTRING(str, start, length)            -- Extract substring
CONCAT(str1, str2) or str1 || str2       -- Concatenate strings
LENGTH(str)                              -- String length
REGEXP_REPLACE(str, pattern, replace)    -- Regex replace

-- Numeric Functions
ROUND(num, decimal_places)               -- Round number
FLOOR(num) / CEIL(num)                   -- Floor/ceiling
ABS(num)                                 -- Absolute value
MOD(num, divisor)                        -- Modulo

-- Aggregate Functions
COUNT(*) / COUNT(col)                    -- Count rows
SUM(col) / AVG(col)                      -- Sum / average
MIN(col) / MAX(col)                      -- Minimum / maximum
LISTAGG(col, delimiter) WITHIN GROUP (ORDER BY col)  -- Concatenate values
```

---

## 15. Key SHOW Commands

```sql
SHOW DATABASES;
SHOW SCHEMAS IN DATABASE db_name;
SHOW TABLES IN SCHEMA schema_name;
SHOW VIEWS IN SCHEMA schema_name;
SHOW USERS;
SHOW ROLES;
SHOW WAREHOUSES;
SHOW STAGES IN SCHEMA schema_name;
SHOW FILE FORMATS;
SHOW INTEGRATIONS;
SHOW PIPES;
SHOW STREAMS;
SHOW TASKS;
SHOW PROCEDURES;
SHOW FUNCTIONS;
SHOW MASKING POLICIES;
SHOW PARAMETERS;
SHOW PARAMETERS LIKE 'TIME_ZONE';
SHOW GRANTS TO USER username;
SHOW GRANTS TO ROLE role_name;
```

---

## 16. Error Recovery Cheat Sheet

```
Problem                    │ Solution
───────────────────────────┼────────────────────────────────────────────
Warehouse suspended        │ ALTER WAREHOUSE wh RESUME;
                           │ or set AUTO_RESUME = TRUE
───────────────────────────┼────────────────────────────────────────────
Table accidentally dropped │ UNDROP TABLE table_name;
                           │ (within retention period)
───────────────────────────┼────────────────────────────────────────────
Schema accidentally dropped│ UNDROP SCHEMA schema_name;
───────────────────────────┼────────────────────────────────────────────
Database accidentally      │ UNDROP DATABASE db_name;
dropped                    │
───────────────────────────┼────────────────────────────────────────────
Records deleted by mistake │ INSERT INTO table
                           │ SELECT * FROM table AT(OFFSET => -N);
───────────────────────────┼────────────────────────────────────────────
Same file loaded twice     │ Check COPY HISTORY;
                           │ Use FORCE = TRUE to override metadata
                           │ or TRUNCATE TABLE and reload
───────────────────────────┼────────────────────────────────────────────
Stage not accessible       │ DESCRIBE INTEGRATION integration_name;
(S3 integration)           │ Check STORAGE_AWS_IAM_USER_ARN
                           │ Update trust relationship in AWS IAM
───────────────────────────┼────────────────────────────────────────────
Stream is stale            │ Data retention expired for stream;
                           │ Re-create the stream
───────────────────────────┼────────────────────────────────────────────
Task not running           │ ALTER TASK task_name RESUME;
                           │ Check: SHOW TASKS; verify SUSPENDED or STARTED
───────────────────────────┼────────────────────────────────────────────
Cannot drop masking policy │ First: ALTER TABLE MODIFY COLUMN UNSET MASKING POLICY;
                           │ Then: DROP MASKING POLICY policy_name;
```
