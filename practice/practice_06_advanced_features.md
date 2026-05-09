# Practice Set 6: Advanced Snowflake Features

> **Topics Covered**: Time Travel, Cloning, Caching, Clustering, Query Optimization
> **Related Lectures**: Lecture 12, 22, 30, 31, 32

---

## Section 1: Time Travel

**Time Travel** lets you go back in time and query/restore historical data.
- **Permanent tables**: Up to 90 days
- **Transient tables**: Up to 1 day
- **Temporary tables**: No time travel
- **After Time Travel expires**: Fail Safe (7 more days — Snowflake support only)

---

### Exercise 1.1 — Check and Change Retention Period

```sql
CREATE DATABASE IF NOT EXISTS time_practice_db;
CREATE SCHEMA IF NOT EXISTS time_schema;
USE DATABASE time_practice_db;
USE SCHEMA time_schema;

-- Create a test table
CREATE TABLE sales_data (
    sale_id   NUMBER,
    product   VARCHAR(100),
    amount    NUMBER,
    sale_date DATE
);

-- Check current retention period (default: 1 day)
SELECT table_name, retention_time
FROM information_schema.tables
WHERE table_name = 'SALES_DATA';

-- Increase to 5 days
ALTER TABLE sales_data SET DATA_RETENTION_TIME_IN_DAYS = 5;

-- Verify change
SELECT table_name, retention_time
FROM information_schema.tables
WHERE table_name = 'SALES_DATA';

-- Can you set it to 91? Try it:
-- ALTER TABLE sales_data SET DATA_RETENTION_TIME_IN_DAYS = 91;
-- Result: ERROR — maximum is 90
```

---

### Exercise 1.2 — Query Historical Data

```sql
-- Insert some data
INSERT INTO sales_data VALUES (1, 'Laptop',  75000, CURRENT_DATE());
INSERT INTO sales_data VALUES (2, 'Phone',   25000, CURRENT_DATE());
INSERT INTO sales_data VALUES (3, 'Tablet',  35000, CURRENT_DATE());

-- Note the current timestamp
SET current_time = CURRENT_TIMESTAMP();

-- Wait a moment, then delete a record
DELETE FROM sales_data WHERE sale_id = 2;

-- Current state — only 2 records
SELECT * FROM sales_data;

-- Go back to before the delete using OFFSET (seconds ago)
SELECT * FROM sales_data 
AT(OFFSET => -60);  -- 60 seconds ago

-- Go back using a specific timestamp
SELECT * FROM sales_data
AT(TIMESTAMP => $current_time::TIMESTAMP_NTZ);
```

---

### Exercise 1.3 — Restore Deleted Data

```sql
-- Method 1: UNDROP a dropped table
DROP TABLE sales_data;

-- Oops! Recover it:
UNDROP TABLE sales_data;

-- Verify data is back
SELECT * FROM sales_data;

-- Method 2: Restore using a query
-- First, re-delete record 2
DELETE FROM sales_data WHERE sale_id = 2;

-- Get the query ID of the DELETE statement
-- Run: SELECT LAST_QUERY_ID();  -- Note this ID

-- Restore from before the delete using BEFORE
INSERT INTO sales_data
SELECT * FROM sales_data 
BEFORE(STATEMENT => '<your_delete_query_id>');

-- Now sale_id = 2 is back
SELECT * FROM sales_data;
```

---

### Exercise 1.4 — Time Travel Questions

1. What is the `FAIL SAFE` period in Snowflake?
   - Answer: _______________

2. What happens to data after both Time Travel AND Fail Safe expire?
   - Answer: _______________

3. Can you query data using Time Travel for a TEMPORARY table?
   - Answer: _______________

4. What is the maximum Time Travel retention for the Enterprise edition?
   - Answer: _______________

**Answers**:
1. 7 days additional period after Time Travel expires — managed by Snowflake support only
2. Data is permanently deleted
3. No — temporary tables have 0 retention time
4. 90 days

---

## Section 2: Cloning

**Zero-Copy Cloning** creates an exact copy instantly with NO additional storage cost (initially).

```
Source Table [Micro-partitions 1,2,3,4,5]
     ↓ CLONE
Clone Table  [Shares micro-partitions 1,2,3,4,5]

After changes to clone:
Clone Table  [Micro-partitions 1,2,3 + NEW 6,7] ← Only stores new/changed data
```

---

### Exercise 2.1 — Clone a Table

```sql
-- Clone the sales_data table
CREATE TABLE sales_data_backup 
    CLONE sales_data;

-- Check data in clone — same as original
SELECT * FROM sales_data_backup;

-- Check storage — both should show 0 in clone_bytes initially
SELECT table_name, active_bytes, clone_bytes
FROM information_schema.table_storage_metrics
WHERE table_name IN ('SALES_DATA', 'SALES_DATA_BACKUP');
```

---

### Exercise 2.2 — Modify Clone and Check Storage

```sql
-- Insert new records into the clone
INSERT INTO sales_data_backup VALUES (4, 'Headphones', 8000, CURRENT_DATE());
INSERT INTO sales_data_backup VALUES (5, 'Keyboard',   3000, CURRENT_DATE());

-- Now check storage — clone has additional bytes
SELECT table_name, active_bytes
FROM information_schema.table_storage_metrics
WHERE table_name IN ('SALES_DATA', 'SALES_DATA_BACKUP');
```

---

### Exercise 2.3 — Clone a Database

```sql
-- Clone entire database
CREATE DATABASE time_practice_db_backup
    CLONE time_practice_db;

-- The clone has all schemas and tables
SHOW SCHEMAS IN DATABASE time_practice_db_backup;
```

---

### Exercise 2.4 — Clone at a Point in Time (Zero-Copy Backup with Time Travel)

```sql
-- Clone table from 1 hour ago
CREATE TABLE sales_yesterday 
    CLONE sales_data
    AT(OFFSET => -3600);  -- 3600 seconds = 1 hour
```

---

## Section 3: Caching

Snowflake has 3 levels of cache. Understanding them helps optimize query performance.

```
Query → Check Result Cache → Check Warehouse Cache → Check Storage
           (free, 24h)         (free, warehouse size)    (costs credits)
```

---

### Exercise 3.1 — Result Cache

```sql
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;
USE WAREHOUSE compute_wh;

-- Run a query and note execution time
SELECT COUNT(*) FROM ORDERS;

-- Run the EXACT SAME query again
SELECT COUNT(*) FROM ORDERS;
-- Should be much faster — uses Result Cache

-- Check query profile — it should say "Query Result Reuse"
```

---

### Exercise 3.2 — Disable Result Cache

```sql
-- Disable result cache for current session
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- Run query again — takes full time now (no cache)
SELECT COUNT(*) FROM ORDERS;

-- Re-enable
ALTER SESSION SET USE_CACHED_RESULT = TRUE;
```

---

### Exercise 3.3 — Metadata Cache

```sql
-- These operations use METADATA cache (cloud services layer)
-- They're fast because results come from metadata, not storage

SELECT COUNT(*) FROM ORDERS;          -- Count uses metadata
SELECT MAX(O_ORDERDATE) FROM ORDERS;  -- MAX of some columns from metadata
SELECT MIN(O_ORDERDATE) FROM ORDERS;  -- MIN from metadata

-- Check query profile → should say "Metadata-based result"
```

**Rule**: Simple aggregates (COUNT, MAX, MIN on certain columns) often hit the metadata cache.

---

## Section 4: Clustering Keys

**Clustering** organizes data into micro-partitions based on a column, improving query performance on large tables.

---

### Exercise 4.1 — Check Clustering Information

```sql
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

-- Check clustering info for ORDERS table
SELECT SYSTEM$CLUSTERING_INFORMATION('ORDERS', '(O_ORDERDATE)');
-- Returns: total_partition_count, partitions_not_on_meta, etc.
```

---

### Exercise 4.2 — Create a Clustering Key

```sql
-- Return to our practice database
USE DATABASE time_practice_db;
USE SCHEMA time_schema;

-- Create a larger table for demo
CREATE TABLE large_sales AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY RANDOM()) AS sale_id,
    UNIFORM(1, 100, RANDOM())::VARCHAR AS product_id,
    UNIFORM(1000, 100000, RANDOM())::NUMBER AS amount,
    DATEADD(DAY, -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()) AS sale_date,
    CASE WHEN UNIFORM(1,4,RANDOM()) = 1 THEN 'Electronics'
         WHEN UNIFORM(1,4,RANDOM()) = 2 THEN 'Clothing'
         WHEN UNIFORM(1,4,RANDOM()) = 3 THEN 'Food'
         ELSE 'Other' END AS category
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- Add a clustering key on sale_date
ALTER TABLE large_sales CLUSTER BY (sale_date);

-- Check clustering info
SELECT SYSTEM$CLUSTERING_INFORMATION('LARGE_SALES', '(SALE_DATE)');
```

---

## Section 5: Execution Plan (EXPLAIN)

### Exercise 5.1 — Generating Execution Plans

```sql
-- Text format execution plan
EXPLAIN USING TEXT
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.department = d.dept_name
WHERE e.salary > 70000
ORDER BY e.salary DESC;

-- Table format (more detailed)
EXPLAIN USING TABULAR
SELECT COUNT(*), department FROM employees GROUP BY department;

-- JSON format
EXPLAIN USING JSON
SELECT * FROM employees WHERE emp_id = 1;
```

---

### Exercise 5.2 — Reading the Execution Plan

The execution plan shows steps like:
- **TableScan** — reading data from a table
- **Filter** — applying WHERE conditions
- **Aggregate** — GROUP BY operations
- **Sort** — ORDER BY operations
- **Join** — JOIN operations
- **Pruned Partitions** — micro-partitions skipped due to clustering

---

## Section 6: Table Storage Metrics

```sql
-- Check table sizes
SELECT 
    table_name,
    ROUND(active_bytes / 1024 / 1024, 2)        AS size_mb,
    ROUND(time_travel_bytes / 1024 / 1024, 2)   AS time_travel_mb,
    ROUND(failsafe_bytes / 1024 / 1024, 2)       AS failsafe_mb,
    ROUND(retained_for_clone_bytes / 1024, 2)    AS clone_kb
FROM information_schema.table_storage_metrics
WHERE table_schema = 'TIME_SCHEMA'
ORDER BY active_bytes DESC;
```

---

## Challenge Questions

1. You accidentally dropped an entire schema. How would you recover it?
   ```sql
   -- Answer:
   UNDROP SCHEMA schema_name;
   ```

2. What is the difference between `AT(OFFSET)`, `AT(TIMESTAMP)`, and `BEFORE(STATEMENT)`?
   - `AT(OFFSET => -N)`: Query data _____ seconds ago
   - `AT(TIMESTAMP => ts)`: Query data at a specific _____
   - `BEFORE(STATEMENT => id)`: Query data just before _____ was executed

3. You cloned `sales_table` to `sales_backup`. Then you deleted 100 rows from `sales_table`. Does `sales_backup` still have the deleted rows?
   - Answer: _______________

4. Why is `COUNT(*)` typically a metadata operation in Snowflake?
   - Answer: _______________

5. When should you add a clustering key to a table?
   - Answer: _______________

## Answer Key

**Challenge Q2**:
- `AT(OFFSET => -N)`: Query data N seconds ago
- `AT(TIMESTAMP => ts)`: Query data at a specific point in time
- `BEFORE(STATEMENT => id)`: Query data just before a specific SQL statement was executed

**Challenge Q3**: 
Yes — because the clone is independent of the original. Deleting from `sales_table` does NOT affect `sales_backup`.

**Challenge Q4**: 
Snowflake maintains metadata about the number of rows in each micro-partition. COUNT(*) reads this metadata instead of scanning all data.

**Challenge Q5**: 
When a table is very large (millions of rows), frequently queried with WHERE filters on the same column(s), and queries are scanning too many micro-partitions.
