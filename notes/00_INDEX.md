# Snowflake Training — Master Index

Complete index of all 35 lecture notes from the Snowflake training series.

---

## Table of Contents

| # | File | Topic |
|---|---|---|
| [1](#lecture-1) | [lecture_01_introduction.md](lecture_01_introduction.md) | Introduction to Snowflake — architecture, databases, warehouses |
| [2](#lecture-2) | [lecture_02_users_roles_ui.md](lecture_02_users_roles_ui.md) | Users, roles, UI navigation, utility functions |
| [3](#lecture-3) | [lecture_03_account_setup_ddl.md](lecture_03_account_setup_ddl.md) | Account setup, DDL, roles deep dive, date functions |
| [4](#lecture-4) | [lecture_04_stages_files.md](lecture_04_stages_files.md) | Stages — concepts, internal stages, file operations |
| [5](#lecture-5) | [lecture_05_copy_command_basics.md](lecture_05_copy_command_basics.md) | COPY command, semi-structured data, JSON basics |
| [6](#lecture-6) | [lecture_06_semistructured_json.md](lecture_06_semistructured_json.md) | Semi-structured data — JSON deep dive and COPY INTO |
| [7](#lecture-7) | [lecture_07_variant_loading.md](lecture_07_variant_loading.md) | VARIANT data type, loading multiple JSON files, LATERAL FLATTEN |
| [8](#lecture-8) | [lecture_08_xml_processing.md](lecture_08_xml_processing.md) | XML file processing, XMLGET function, LATERAL FLATTEN |
| 9 | *(pending)* | Time Travel — AT, BEFORE, OFFSET, STATEMENT |
| 10 | *(pending)* | Fail-Safe and data recovery |
| 11 | *(pending)* | Data Sharing — Shares, Data Exchange |
| 12 | *(pending)* | Table types — Permanent, Transient, Temporary, External |
| [13](#lecture-13) | [lecture_13_copy_history_external.md](lecture_13_copy_history_external.md) | Table types recap, external stages, COPY history, Snowpipe intro |
| [14](#lecture-14) | [lecture_14_snowpipe.md](lecture_14_snowpipe.md) | Snowpipe — continuous data ingestion |
| [15](#lecture-15) | [lecture_15_copy_options.md](lecture_15_copy_options.md) | COPY command options and error handling |
| [16](#lecture-16) | [lecture_16_streams.md](lecture_16_streams.md) | Streams — change data capture (CDC) |
| [17](#lecture-17) | [lecture_17_tasks_udfs.md](lecture_17_tasks_udfs.md) | Tasks, scheduling, and User-Defined Functions |
| [18](#lecture-18) | [lecture_18_streams_merge_advanced.md](lecture_18_streams_merge_advanced.md) | Streams and MERGE — advanced topics, warehouse auto-resume |
| [19](#lecture-19) | [lecture_19_stored_procedures.md](lecture_19_stored_procedures.md) | Stored procedures — introduction and SQL scripting |
| 20 | *(pending)* | Stored procedures — JavaScript and Python procedures |
| 21 | *(pending)* | Dynamic Data Masking and Row Access Policies |
| 22 | *(pending)* | DBT Introduction — concepts and DBT vs SQL |
| 23 | *(pending)* | DBT Cloud setup and first models |
| 24 | *(pending)* | DBT models — views, tables, CTEs, ref() function |
| [25](#lecture-25) | [lecture_25_dbt_core.md](lecture_25_dbt_core.md) | DBT Core — Anaconda, Conda environments, profiles.yml, models |
| [26](#lecture-26) | [lecture_26_dbt_seeds_snapshots.md](lecture_26_dbt_seeds_snapshots.md) | DBT Seeds, Snapshots (SCD Type 2), pre/post hooks intro |
| [27](#lecture-27) | [lecture_27_dbt_github.md](lecture_27_dbt_github.md) | DBT Cloud — GitHub integration, deploy keys, snapshots, hooks |
| [28](#lecture-28) | [lecture_28_dbt_hooks.md](lecture_28_dbt_hooks.md) | DBT pre/post hooks — detailed audit logging implementation |
| [29](#lecture-29) | [lecture_29_python_connector.md](lecture_29_python_connector.md) | Python connector — PyCharm setup, connect, query, Snowpark intro |
| [30](#lecture-30) | [lecture_30_caching.md](lecture_30_caching.md) | Caching — Result Cache, Warehouse Cache, Metadata Cache |
| [31](#lecture-31) | [lecture_31_query_optimization.md](lecture_31_query_optimization.md) | Query optimization — EXPLAIN plans, clustering keys, QAS |
| [32](#lecture-32) | [lecture_32_cloning_python.md](lecture_32_cloning_python.md) | Zero-copy cloning, resource monitors, multi-cluster warehouses |
| [33](#lecture-33) | [lecture_33_certifications.md](lecture_33_certifications.md) | Snowflake certifications — SnowPro Core exam process and study tips |
| [34](#lecture-34) | [lecture_34_s3_integration_detailed.md](lecture_34_s3_integration_detailed.md) | External stages — storage integration with S3, HIPAA, external tables |
| [35](#lecture-35) | [lecture_35_dbt_macros_external_tables.md](lecture_35_dbt_macros_external_tables.md) | DBT macros, Jinja templating, SPLIT_PART, external tables, insert-only streams |

---

## Lecture Summaries

### Lecture 1
**Introduction to Snowflake — Databases, Architecture, and Setup**
Snowflake overview, cloud platform architecture (storage / compute / services layers), account creation, creating databases and schemas, virtual warehouses, and basic DDL.

### Lecture 2
**Users, Roles, UI Navigation, and Utility Functions**
Creating users, assigning roles, granting privileges, navigating the Snowflake Web UI, date/time functions, string functions, and aggregate functions.

### Lecture 3
**Account Setup, DDL, Roles Deep Dive, and Date Functions**
RBAC hierarchy (ACCOUNTADMIN → SYSADMIN → custom roles), creating and granting custom roles, ALTER statements, date arithmetic, and `CURRENT_DATE()` / `DATEADD()` / `DATEDIFF()`.

### Lecture 4
**Stages — Concepts, Internal Stages, and File Operations**
What is a stage, three types of internal stages (user stage `@~`, table stage `@%table`, named stage `@stage_name`), PUT command, LIST command, and file formats (CSV, JSON, Parquet).

### Lecture 5
**COPY Command, Semi-Structured Data, and JSON Basics**
Loading CSV data using `COPY INTO` from internal stages, file format options, handling headers, loading JSON into VARIANT columns.

### Lecture 6
**Semi-Structured Data — JSON Deep Dive and COPY INTO**
Querying VARIANT columns with dot notation (`col:key`), bracket notation (`col['key']`), type casting (`::VARCHAR`, `::NUMBER`), `PARSE_JSON`, loading nested JSON.

### Lecture 7
**VARIANT Data Type, Loading Multiple JSON Files, and LATERAL FLATTEN**
Loading multiple JSON files with pattern matching, `LATERAL FLATTEN` to unnest arrays, `ARRAY_AGG`, `OBJECT_CONSTRUCT`, querying nested arrays.

### Lecture 8
**XML File Processing, XMLGET Function, and LATERAL FLATTEN**
Loading XML data into VARIANT, `XMLGET(col, 'tag')` function, extracting attributes with `@attribute`, combining XMLGET with LATERAL FLATTEN for XML arrays.

### Lecture 9
**Time Travel — AT, BEFORE, OFFSET, STATEMENT** *(notes pending)*
Querying historical data with `AT (TIMESTAMP => ...)`, `AT (OFFSET => ...)`, `AT (STATEMENT => ...)`, `BEFORE (STATEMENT => ...)`. Retention period configuration. Restoring dropped tables with `UNDROP`.

### Lecture 10
**Fail-Safe and Data Recovery** *(notes pending)*
Fail-Safe period (7 days, non-configurable), difference between Time Travel and Fail-Safe, `TABLE_STORAGE_METRICS`, storage cost analysis.

### Lecture 11
**Data Sharing — Shares and Data Exchange** *(notes pending)*
Creating secure shares, adding objects to shares, granting access to consumer accounts, Snowflake Data Marketplace, data exchange setup.

### Lecture 12
**Table Types** *(notes pending)*
Permanent, Transient, Temporary, and External tables. Differences in Time Travel retention, Fail-Safe, and storage costs. When to use each type.

### Lecture 13
**Table Types Recap, External Stages, Copy History, and Snowpipe Introduction**
Reviewing all table types, creating external stages (S3/Azure/GCS), `COPY_HISTORY` table function, staged file metadata, introduction to Snowpipe.

### Lecture 14
**Snowpipe — Continuous Data Ingestion**
Creating a Snowpipe with `AUTO_INGEST = TRUE`, SQS queue setup for S3 event notifications, `SHOW PIPES`, `PIPE_STATUS`, `COPY_HISTORY` monitoring.

### Lecture 15
**COPY Command Options and Error Handling**
`ON_ERROR` options (CONTINUE, SKIP_FILE, ABORT_STATEMENT), `PURGE`, `FORCE`, `VALIDATION_MODE`, `LOAD_UNCERTAIN_FILES`, error handling best practices.

### Lecture 16
**Streams — Change Data Capture in Snowflake**
Creating streams on tables, stream types (STANDARD vs APPEND_ONLY), `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`, consuming streams with DML.

### Lecture 17
**Tasks, Scheduling, and User-Defined Functions (UDFs)**
`CREATE TASK` with cron schedule, `AFTER` clause for task chaining, starting/suspending tasks, SQL UDFs, JavaScript UDFs, Python UDFs.

### Lecture 18
**Streams and MERGE — Advanced Topics, Warehouse Auto-Resume**
MERGE statement to apply stream changes to target tables (INSERT/UPDATE/DELETE in one statement), auto-resume warehouses, stream+task pipeline automation.

### Lecture 19
**Stored Procedures — Introduction and SQL Scripting**
Creating stored procedures in SQL Scripting, `DECLARE`, `BEGIN/END` blocks, `FOR` loops, `EXECUTE IMMEDIATE`, calling procedures with `CALL`.

### Lecture 20
**Stored Procedures — JavaScript and Python** *(notes pending)*
JavaScript stored procedures with Snowflake JavaScript API, Python stored procedures, `snowflake.execute()`, returning results, exception handling.

### Lecture 21
**Dynamic Data Masking and Row Access Policies** *(notes pending)*
Creating masking policies (full mask, partial mask, SHA256 hash), applying to columns, row access policies for role-based row filtering.

### Lecture 22
**DBT Introduction — Concepts and Architecture** *(notes pending)*
What is DBT, ELT vs ETL philosophy, DBT project structure, models vs seeds vs snapshots vs macros vs tests, comparison with traditional SQL tools.

### Lecture 23
**DBT Cloud Setup and First Models** *(notes pending)*
Creating a DBT Cloud account, connecting to Snowflake, creating first models, understanding the DBT DAG, running models and seeing results in Snowflake.

### Lecture 24
**DBT Models — Views, Tables, CTEs, and ref()** *(notes pending)*
Model materializations in detail, using CTEs within models, `{{ ref() }}` function for cross-model dependencies, model dependency graph, dbt_project.yml model configuration.

### Lecture 25
**DBT Core — Anaconda, Conda Environments, and Profiles**
Installing DBT Core with `pip install dbt-snowflake` inside a Conda environment. Configuring `profiles.yml` (Snowflake connection) and `dbt_project.yml`. Running models with `dbt run`, `dbt debug`. Creating views and tables in Snowflake via DBT models. Using `{{ ref() }}` to chain models.

### Lecture 26
**DBT Seeds, Snapshots (SCD Type 2), and Pre/Post Hooks Introduction**
Seeds load CSV files to Snowflake tables with `dbt seed`. Snapshots implement SCD Type 2 history tracking using `strategy=check` with `unique_key` and `check_cols`. DBT adds `dbt_valid_from` and `dbt_valid_to` columns automatically. Introduction to pre/post hooks for audit logging.

### Lecture 27
**DBT Cloud — GitHub Integration, Deploy Keys, and Hooks**
Full DBT Cloud setup: Snowflake connection, GitHub repository creation, SSH deploy key configuration. Snapshots in DBT Cloud. Configuring pre/post hooks in `dbt_project.yml`. Secure views, materialized views, and dynamic tables in Snowflake.

### Lecture 28
**DBT Pre/Post Hooks — Detailed Audit Logging**
Step-by-step: creating the audit log table, configuring pre/post hooks using `{{ this.name }}`, running all models, verifying audit records. Difference between model-level hooks and run-level hooks (`on-run-start`/`on-run-end`). Transient table behavior in DBT.

### Lecture 29
**Python Connector for Snowflake**
Installing `snowflake-connector-python` via PyCharm or pip. Writing Python code to connect, execute queries, and fetch results using `cursor.execute()`, `cursor.fetchall()`. Introduction to Snowpark. Resource Monitor and warehouse sizing discussion.

### Lecture 30
**Caching in Snowflake — Three Cache Types**
Three caches: Metadata Cache (cloud services, serves COUNT/MAX/MIN), Result Cache (cloud services, 24h TTL, exact query match), Warehouse Cache (local disk, cleared on suspend). Demonstrated by enabling/disabling caches, suspending warehouses, and observing "Percentage scanned from cache" metrics.

### Lecture 31
**Query Optimization — EXPLAIN Plans, Clustering Keys, and QAS**
`EXPLAIN USING TEXT/TABULAR/JSON` generates execution plans. Clustering keys on large tables reorganize micro-partitions for better pruning. `SYSTEM$CLUSTERING_INFORMATION` shows clustering quality. Query Acceleration Service (QAS) multiplies warehouse size by a scaling factor; `SYSTEM$ESTIMATE_QUERY_ACCELERATION` finds optimal scaling factor.

### Lecture 32
**Zero-Copy Cloning, Resource Monitors, and Multi-Cluster Warehouses**
Cloning creates instant, storage-free copies at table/schema/database level. Storage cost only incurred when either side is modified. `TABLE_STORAGE_METRICS` tracks bytes. Resource Monitors alert and suspend warehouses at credit thresholds. Multi-cluster warehouses handle concurrency (horizontal scaling). Python connector finalized in PyCharm.

### Lecture 33
**Snowflake Certifications — SnowPro Core Exam Process**
Six certification tracks (Core + 5 Advanced). SnowPro Core details: 100 questions, 115 minutes, $175. Registration on Kryterion/Webassessor. Online proctored exam requirements (room scan, photo ID, no movement). Study resources: Snowflake University, practice exams, official study guide.

### Lecture 34
**External Stages with S3 Storage Integration — Detailed Setup**
Complete walkthrough: create S3 bucket, create IAM Role (with placeholder trust relationship), create `STORAGE INTEGRATION` in Snowflake, `DESCRIBE` to get IAM User ARN and External ID, update AWS trust relationship, create stage. Adding locations with `ALTER STORAGE INTEGRATION`. HIPAA compliance rationale. External tables and insert-only streams.

### Lecture 35
**DBT Macros, Jinja Templating, and External Tables**
Macros as reusable Jinja SQL templates. `group_by(n)` macro generates `GROUP BY 1, 2, 3, ..., n` using Jinja for loops. `new_segment(column)` macro generates CASE WHEN expressions. `{{ macro_name(args) }}` calling syntax. Snowflake `SPLIT_PART` function. `SELECT * EXCLUDE column` Snowflake syntax. Insert-only streams on external tables.

---

## Learning Path Recommendations

### Beginner Path (Weeks 1–2)
```
Lecture 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8
Focus: Architecture, DDL, Stages, COPY command, JSON/XML data loading
```

### Intermediate Path (Weeks 3–4)
```
Lecture 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18
Focus: Time Travel, Fail-Safe, Data Sharing, Snowpipe, Streams, Tasks
```

### Advanced Path (Weeks 5–6)
```
Lecture 19 → 20 → 21 → 22 → 23 → 24
Focus: Stored Procedures, Dynamic Masking, DBT Introduction
```

### DBT Deep Dive (Weeks 7–8)
```
Lecture 25 → 26 → 27 → 28 → 35
Focus: DBT Core, Seeds, Snapshots, Hooks, Macros
```

### Performance and Integration (Weeks 8–9)
```
Lecture 29 → 30 → 31 → 32 → 34
Focus: Python Connector, Caching, Query Optimization, Cloning, S3 Integration
```

### Certification Prep (Week 10)
```
Lecture 33 (Certifications) → Review all notes → Practice exam
```

---

## Key Snowflake Objects Quick Reference

| Object | Create Command | Purpose |
|---|---|---|
| Database | `CREATE DATABASE name` | Top-level namespace |
| Schema | `CREATE SCHEMA db.name` | Organizes tables/views |
| Table | `CREATE TABLE name (cols)` | Stores data permanently |
| View | `CREATE VIEW name AS SELECT...` | Virtual table, no storage |
| Secure View | `CREATE SECURE VIEW name AS SELECT...` | View with hidden definition |
| Materialized View | `CREATE MATERIALIZED VIEW name AS SELECT...` | Cached aggregate, auto-refresh |
| Dynamic Table | `CREATE DYNAMIC TABLE ... TARGET_LAG = '2 min'` | Multi-table auto-refresh |
| Stage (Internal) | `CREATE STAGE name` | Internal file storage |
| Stage (External) | `CREATE STAGE name URL='s3://...' STORAGE_INTEGRATION=...` | S3/Azure/GCS file access |
| External Table | `CREATE EXTERNAL TABLE name ... LOCATION=@stage` | Query files as tables |
| File Format | `CREATE FILE FORMAT name TYPE=CSV` | Define file parsing rules |
| Pipe | `CREATE PIPE name ... AS COPY INTO ...` | Continuous ingestion |
| Stream | `CREATE STREAM name ON TABLE t` | Change Data Capture |
| Task | `CREATE TASK name SCHEDULE='5 MINUTE' AS SQL...` | Scheduled SQL execution |
| Stored Procedure | `CREATE PROCEDURE name(...) AS ...` | Reusable SQL/Python logic |
| UDF | `CREATE FUNCTION name(...) RETURNS type AS...` | Custom scalar function |
| Storage Integration | `CREATE STORAGE INTEGRATION ... TYPE=EXTERNAL_STAGE` | IAM Role-based S3 access |
| Resource Monitor | `CREATE RESOURCE MONITOR name WITH CREDIT_QUOTA=N` | Credit usage control |
| Sequence | `CREATE SEQUENCE name START=1 INCREMENT=1` | Auto-incrementing numbers |
| Clone | `CREATE TABLE clone CLONE source` | Zero-copy instant copy |
| Share | `CREATE SHARE name` | Share data with other accounts |

---

## Essential Commands Quick Reference

```sql
-- Session management
USE DATABASE db_name;
USE SCHEMA schema_name;
USE WAREHOUSE warehouse_name;
USE ROLE role_name;

-- Information commands
SHOW TABLES;
SHOW VIEWS;
SHOW STAGES;
SHOW PIPES;
SHOW STREAMS;
SHOW TASKS;
SHOW WAREHOUSES;
SHOW RESOURCE MONITORS;
SHOW INTEGRATIONS;
SHOW ROLES;
SHOW GRANTS TO ROLE role_name;
SHOW PARAMETERS;

-- Data loading
PUT file://local/path @stage_name;
LIST @stage_name;
COPY INTO table FROM @stage;

-- Querying
EXPLAIN USING TEXT SELECT ...;
SYSTEM$CLUSTERING_INFORMATION('table', '(col)');
SYSTEM$ESTIMATE_QUERY_ACCELERATION('query_id');

-- Cache control
ALTER SESSION SET USE_CACHED_RESULT = FALSE;
ALTER WAREHOUSE w SUSPEND;
ALTER WAREHOUSE w RESUME;

-- Cloning
CREATE TABLE clone CLONE source;
CREATE DATABASE clone CLONE source AT (OFFSET => -3600);

-- Time Travel
SELECT * FROM table AT (TIMESTAMP => '2025-01-01');
SELECT * FROM table BEFORE (STATEMENT => 'query_id');
UNDROP TABLE table_name;
```

---

*Generated from 35 live training session transcripts — Snowflake training series.*
