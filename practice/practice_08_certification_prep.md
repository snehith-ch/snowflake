# Practice Set 8: SnowPro Core Certification Preparation

> **Topics Covered**: All Snowflake concepts — certification-style questions
> **Related Lectures**: All lectures, especially Lecture 33

---

## About SnowPro Core Certification

- **Exam**: SnowPro Core (COF-C02)
- **Questions**: ~100 multiple choice / multi-select
- **Time**: 115 minutes
- **Passing Score**: 75%
- **Topics**: Architecture, Storage, Compute, Security, Data Loading, Performance, Semi-structured data

---

## Certification Topics Breakdown

| Domain | Weight |
|--------|--------|
| Snowflake Cloud Data Platform Features & Architecture | ~25% |
| Account Access and Security | ~20% |
| Performance Concepts | ~15% |
| Data Loading & Unloading | ~15% |
| Data Transformations | ~15% |
| Data Protection & Data Sharing | ~10% |

---

## Section 1: Architecture Questions

### Q1: Snowflake Architecture
Which of the following correctly describes the three layers of Snowflake architecture?

A) Compute Layer, Memory Layer, Storage Layer  
B) Database Storage Layer, Query Processing Layer, Cloud Services Layer ✓  
C) Frontend Layer, Backend Layer, Database Layer  
D) Application Layer, Data Layer, Presentation Layer  

---

### Q2: Database Storage Layer
What is the primary function of the Database Storage Layer in Snowflake?

A) Execute SQL queries  
B) Manage user authentication  
C) Store data in compressed, columnar micro-partitions ✓  
D) Monitor query performance  

---

### Q3: Virtual Warehouse
Which statement about Virtual Warehouses is CORRECT?

A) You need a warehouse to create databases and schemas  
B) Without a warehouse, you cannot read or write data ✓  
C) A warehouse can only be used by one user at a time  
D) Warehouses are automatically deleted after 24 hours  

---

### Q4: Cloud Services Layer
Which of the following is NOT managed by the Cloud Services Layer?

A) Authentication  
B) Query optimization  
C) Metadata management  
D) Data storage in micro-partitions ✓  

---

### Q5: Snowflake Editions
Which edition supports Time Travel up to 90 days?

A) Standard (only up to 1 day)  
B) Enterprise ✓  
C) Business Critical ✓  
D) Virtual Private Snowflake ✓  

*(Enterprise and above support 90 days)*

---

## Section 2: Storage and Tables

### Q6: Table Types
Match each table type with its retention period:

| Table Type | Retention |
|-----------|-----------|
| Permanent | Up to 90 days (configurable) |
| Transient | Up to 1 day |
| Temporary | 0 (session only) |
| External  | 0 (data in external storage) |

### Q7: Fail Safe
A user's permanent table has `DATA_RETENTION_TIME_IN_DAYS = 7`. After 7 days, how many more days does Snowflake's Fail Safe give?

A) 0  
B) 7 ✓  
C) 14  
D) 30  

---

### Q8: Micro-partitions
Which statement about Snowflake micro-partitions is TRUE?

A) Users must manually create micro-partitions  
B) Each micro-partition is 16MB-512MB compressed  ✓  
C) Micro-partitions can be modified by users directly  
D) All micro-partitions are exactly 100MB  

---

## Section 3: Billing and Warehouses

### Q9: Billing
What is the MINIMUM billing period for a Snowflake virtual warehouse?

A) 1 second  
B) 1 minute ✓  
C) 5 minutes  
D) 1 hour  

---

### Q10: Warehouse Auto-Suspend
A warehouse has `AUTO_SUSPEND = 300`. What does this mean?

A) The warehouse suspends after 300 queries  
B) The warehouse suspends if idle for 300 seconds (5 minutes) ✓  
C) The warehouse resumes after 300 seconds  
D) The warehouse processes 300 queries per second  

---

### Q11: Multi-Cluster Warehouse
What is the purpose of a Multi-Cluster Warehouse?

A) Store more data  
B) Run faster SQL queries  
C) Handle more concurrent users by adding more clusters ✓  
D) Reduce storage costs  

---

## Section 4: Data Loading

### Q12: COPY Command - ON_ERROR
What happens when you use `ON_ERROR = CONTINUE` in a COPY INTO statement?

A) The entire COPY fails on the first error  
B) Bad records are skipped and valid records are loaded ✓  
C) The file is skipped entirely  
D) All records are loaded including bad ones  

---

### Q13: Snowpipe
Which statement about Snowpipe is TRUE?

A) Snowpipe is triggered manually by the user  
B) Snowpipe can only load CSV files  
C) Snowpipe automatically loads data when new files arrive in a stage ✓  
D) Snowpipe requires a virtual warehouse to be running 24/7  

---

### Q14: Stage Types
Which of the following is an INTERNAL stage?

A) An S3 bucket stage  
B) An Azure Blob stage  
C) A GCS stage  
D) A named stage created with `CREATE STAGE` ✓  

---

### Q15: PUT Command
Where can you execute the PUT command?

A) Snowflake web UI (Snowsight)  
B) SnowSQL command-line interface only ✓  
C) Any SQL client  
D) Python connector  

---

## Section 5: Security

### Q16: RBAC
What is the default role assigned to a newly created user?

A) SYSADMIN  
B) ACCOUNTADMIN  
C) PUBLIC ✓  
D) USERADMIN  

---

### Q17: Role Hierarchy
Which role is at the TOP of Snowflake's default role hierarchy?

A) SYSADMIN  
B) SECURITYADMIN  
C) USERADMIN  
D) ACCOUNTADMIN ✓  

---

### Q18: Masking Policy
A masking policy is applied to the `salary` column. User with `ANALYST` role queries the table. What happens?

A) The query fails with an error  
B) The user sees masked/hidden salary values (as per policy logic) ✓  
C) The user sees the actual salary values  
D) The column is automatically removed from the result  

---

### Q19: Storage Integration
What is the PRIMARY advantage of using Storage Integration instead of credentials (key/secret) for external stages?

A) Storage integration is faster  
B) Storage integration is free  
C) Storage integration is more secure (no hardcoded credentials) ✓  
D) Storage integration supports more file formats  

---

## Section 6: Performance

### Q20: Caching Types
Snowflake has 3 types of cache. Match them:

| Cache Type | Location | Duration |
|-----------|----------|----------|
| Result Cache | Cloud Services Layer | 24 hours |
| Warehouse Cache | Virtual Warehouse memory | Until warehouse suspends |
| Metadata Cache | Cloud Services Layer | Persistent |

---

### Q21: Query Result Reuse
Under what condition does Snowflake reuse the cached query result?

A) When the same user runs the same query  
B) When the exact same query is run AND the underlying data hasn't changed ✓  
C) When any user runs any similar query  
D) Only when USE_CACHED_RESULT = TRUE  

---

### Q22: Clustering Keys
When should you add a clustering key to a table?

A) For every table in Snowflake  
B) For small tables (< 1000 rows)  
C) For large tables frequently filtered on specific columns ✓  
D) Only for JSON data  

---

## Section 7: Streams and Tasks

### Q23: Streams
What does `METADATA$ISUPDATE = TRUE` indicate in a Snowflake stream?

A) The record was inserted  
B) The record was deleted  
C) The record is part of an UPDATE operation ✓  
D) The record has been consumed  

---

### Q24: Task Resume
A newly created task is in which state by default?

A) RUNNING  
B) SCHEDULED  
C) SUSPENDED ✓  
D) COMPLETED  

---

### Q25: Insert-Only Stream
Insert-only streams can be created on which type of table?

A) Permanent tables only  
B) Temporary tables only  
C) External tables and Iceberg tables ✓  
D) All table types  

---

## Section 8: Semi-Structured Data

### Q26: VARIANT
Which data type is used to store semi-structured data (JSON, XML, Parquet) in Snowflake?

A) VARCHAR  
B) TEXT  
C) BLOB  
D) VARIANT ✓  

---

### Q27: LATERAL FLATTEN
What is the purpose of LATERAL FLATTEN in Snowflake?

A) Flatten a 3D array into 2D  
B) Convert VARIANT array elements into individual rows ✓  
C) Compress JSON data  
D) Extract specific keys from XML  

---

## Section 9: DBT and Tools

### Q28: DBT Materialization
Which DBT materialization type creates a new table every time the model runs?

A) view  
B) table ✓  
C) incremental  
D) ephemeral  

---

### Q29: DBT Seeds
What does `dbt seed` do?

A) Creates new dbt models  
B) Runs all dbt tests  
C) Loads CSV files from the seeds/ folder into Snowflake tables ✓  
D) Initializes a new dbt project  

---

## Section 10: Time Travel and Cloning

### Q30: Zero-Copy Cloning
What happens to the storage cost when you clone a table?

A) Doubles immediately  
B) Triples because of redundancy  
C) No additional cost initially; cost is incurred only when clone data changes ✓  
D) Always costs 50% of original table size  

---

## Practice Exam — 10 Questions (Timed)

**Time yourself: 12 minutes for 10 questions**

1. What is the minimum billing unit for Snowflake compute?
2. Name the 3 layers of Snowflake architecture.
3. What command shows all tables in a schema?
4. True/False: Temporary tables persist after the session ends.
5. What parameter makes a warehouse start automatically?
6. Name the 3 stream types in Snowflake.
7. What does `COPY HISTORY` show?
8. What is the maximum Time Travel retention for permanent tables in Enterprise edition?
9. What function gets the DDL of any Snowflake object?
10. What command makes a suspended task start running on schedule?

**Answers**:
1. 1 minute
2. Database Storage, Query Processing, Cloud Services
3. `SHOW TABLES` or `SELECT * FROM INFORMATION_SCHEMA.TABLES`
4. False — they are dropped when session ends
5. `AUTO_RESUME = TRUE`
6. Standard, Append-Only, Insert-Only
7. Files that were loaded into a table via COPY command
8. 90 days
9. `GET_DDL(object_type, object_name)`
10. `ALTER TASK task_name RESUME`

---

## Key Facts to Memorize

```
Minimum billing = 1 minute, then per second
Time Travel max = 90 days (Enterprise+), 1 day (Standard)
Fail Safe = 7 days (non-configurable, Snowflake support only)
Micro-partition size = 16MB - 512MB (compressed)
Default role for new user = PUBLIC
Snowpipe latency = ~1 second
Recommended file size for COPY = ~100-250MB
VARIANT stores: JSON, XML, Parquet, Avro, ORC
PUT command = SnowSQL CLI ONLY
```
