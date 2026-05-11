# Lecture 7: VARIANT Data Type, Loading Multiple JSON Files, and LATERAL FLATTEN

---

## Quick Revision — Lecture 7

| # | Key Point |
|---|-----------|
| 1 | **VARIANT** is the correct data type for storing semi-structured data (JSON, XML, Parquet) |
| 2 | All stage files (CSV, JSON, Parquet, XML) can coexist in named stages separated by type |
| 3 | `COPY INTO ... FROM @json_stage FILE_FORMAT=json_format` loads ALL files from the stage |
| 4 | `METADATA$FILENAME` tells you which file each row came from |
| 5 | When querying a VARIANT column, use `C1:key::TYPE` instead of `$1:key::TYPE` |
| 6 | `COPY INTO` answer = **FALSE** — file format not required if stage already has one assigned |
| 7 | The PUT command auto-compresses (GZIP) and auto-encrypts files |
| 8 | Snowflake stores data in **column format** (columnar), not row format like Oracle |
| 9 | Two major Snowflake cost categories: **Storage** and **Compute** |
| 10 | You can use `PATTERN = '.*emp.*\.gz'` in COPY INTO to load files matching a regex |

---

**Pre-requisite:** Lecture 6 — Semi-Structured JSON, COPY INTO with transformation
**Next:** Lecture 8 — XML Processing with XMLGET and LATERAL FLATTEN
**Related:** Lecture 6 — JSON arrays, LATERAL FLATTEN introduction

---

## Objects Created / Used in This Lecture

| Object Type  | Name                   | Purpose |
|--------------|------------------------|---------|
| Table        | t_semi_structed_Data   | VARIANT table — stores all JSON files raw |
| Table        | t_ssd                  | VARIANT table with file_name tracking column |
| Table        | emp_details            | Structured table (empno, ename, sal) created from emp |
| Stage        | json_stage             | Internal named stage (already exists from L6) |
| Stage        | csv_stage              | CSV stage — files added via SnowSQL |
| File Format  | json_format            | Assigned to json_stage via ALTER STAGE |

---

## ASCII Data Flow — VARIANT Loading

```
Multiple JSON files in @json_stage
      |
      |  COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage)
      v
t_ssd VARIANT table:
  file_name = 'sample.json.gz'   | c1 = {"sno":1,"sname":"Tharun",...}
  file_name = 'car.json.gz'      | c1 = {"id":1,"first_name":"Rohit",...}
  file_name = 'kids_data.json.gz'| c1 = {"Name":"Bala","Kids":[...],...}
      |
      |  SELECT c1:sno::NUMBER FROM t_ssd WHERE file_name='sample.json.gz'
      v
Filtered tabular output — any file, any schema, at query time
```

---

## 1. Recap: Why Multiple Stages?

The instructor reviewed the stages created so far:

```sql
SHOW STAGES;
-- CSV_STAGE, JSON_STAGE, PARQUET_STAGE, XML_STAGE
```

> **Student Question:** "Why are we creating these many stages? Why can't all files go into one stage?"
> **Answer (instructor):** It is just to **manage** files. Since we are dealing with multiple file formats, we create different stages for different file types. It helps organize and process files properly.

```sql
LIST @json_stage;
-- sample.json.gz
-- car.json.gz
-- kids_data.json.gz
```

---

## 2. VARIANT Data Type — What It Is

The **VARIANT** data type in Snowflake stores semi-structured data (JSON, XML, Parquet) in a single column.

- Recommended Snowflake data type for JSON: **VARIANT**
- A VARIANT column can hold any JSON object, array, number, string, boolean, or null
- Data stored in VARIANT can be queried using colon notation and the `::` cast operator

> **Certification Question (instructor):** "What is the recommended Snowflake data type to store semi-structured data information like JSON?"
> **Answer:** **VARIANT**

> **Student Note:** "You have to use the data type called VARIANT. So let us try to answer this question — how can you store semi-structured data into a particular column? You have to use the data type VARIANT."

---

## 3. Loading ALL JSON Files from a Stage into a VARIANT Table

### Step 1: Create the table

```sql
CREATE TABLE t_semi_structed_Data
(c1 variant);
```

### Step 2: Load ALL files from stage (without file format — shows error)

```sql
-- Without file format: ERROR
COPY INTO t_semi_structed_Data FROM @json_stage;
-- Error: By default Snowflake treats each file as CSV — it will fail on JSON
```

> **Instructor:** "By default, Snowflake treats each file as CSV. So that is the reason it is throwing an error. I need to define the file format."

### Step 3: Load with file format (correct)

```sql
COPY INTO t_semi_structed_Data FROM @json_stage FILE_FORMAT=json_format;

SELECT * FROM t_semi_structed_Data;
-- Each row = one JSON object in C1 column
-- Records from all 3 files loaded at once
```

> **Instructor:** "I placed all the files into this particular table. See, this is from one file, this is from another file, this is another file."

---

## 4. Loading JSON with File Name Tracking (t_ssd Table)

### Create table with file_name column

```sql
CREATE TABLE t_ssd
(file_name varchar, c1 variant);
```

### See what we'll load first

```sql
SELECT METADATA$FILENAME, $1
FROM @json_stage (file_format=>json_format);
-- Shows file names alongside their JSON records
```

### Load with file name

```sql
COPY INTO t_ssd
FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage (file_format=>json_format));

SELECT * FROM t_ssd;
-- file_name = 'sample.json.gz'    | c1 = {...}
-- file_name = 'car.json.gz'       | c1 = {...}
-- file_name = 'kids_data.json.gz' | c1 = {...}
```

> **Instructor:** "So from sample.json.gz I'm getting these two records. And these are the records belonging to the second file. And these three records belong to the third file."

---

## 5. Querying VARIANT Columns from t_ssd

When extracting from a VARIANT **column** (in a table), use the column name instead of `$1`:

```sql
-- Query only sample.json records
SELECT c1 FROM t_ssd WHERE file_name='sample.json.gz';

-- Extract to tabular form (key change: use c1: instead of $1:)
SELECT c1:sno::NUMBER    AS sno,
       c1:sname::VARCHAR  AS sname,
       c1:course::VARCHAR AS course,
       c1:DOJ::DATE       AS DOJ
FROM t_ssd WHERE file_name='sample.json.gz';

-- Query only car.json records
SELECT c1:id::NUMBER           AS id,
       c1:first_name::VARCHAR  AS first_name,
       c1:last_name::VARCHAR   AS last_name,
       c1:car_make::VARCHAR    AS car_make,
       c1:Car_Model::VARCHAR   AS Car_Model,
       c1:Car_Model_Year::NUMBER AS Car_Model_Year
FROM t_ssd WHERE file_name='car.json.gz';
```

> **Instructor:** "Instead of dollar one, I need to use C1 because C1 is my column. This practice is very important, guys."

---

## 6. Assigning File Format to Stage — Then COPY Without Format

```sql
TRUNCATE TABLE t_ssd;

-- Fails: no file format
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);
-- Error: Error parsing JSON

-- Assign format permanently to the stage:
DESC STAGE json_stage;
-- stage_file_format shows CSV (before assignment)

ALTER STAGE json_stage SET FILE_FORMAT = json_format;

DESC STAGE json_stage;
-- Now stage_file_format shows JSON

-- Now this works WITHOUT specifying file format:
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);
-- Loaded successfully!
```

> **Certification Question (instructor emphasis — Q11):** "A COPY command must specify a file format in order to execute. True or False?"
> **Answer: FALSE.** "You can associate a file format to the stage directly. Whatever files I place into this stage, Snowflake treats those files as JSON files. You do not need to specify file format in COPY command when stage already has one."

---

## 7. emp_details Table — Structured Table from EMP

```sql
CREATE TABLE emp_details (
    empno NUMBER,
    ename VARCHAR,
    sal   NUMBER
);

INSERT INTO emp_details
SELECT empno, ename, sal FROM emp;

SELECT * FROM emp_details;
```

---

## 8. COPY INTO with PATTERN — Loading Files by Name Pattern

The instructor demonstrated loading CSV files that match a filename pattern:

```sql
-- See files in stage
LIST @csv_stage;
-- emp.csv.gz, emp_10.csv.gz, emp_20.csv.gz, emp_50.csv.gz

-- Upload additional files via SnowSQL
-- PUT file://...emp_10.csv @csv_stage
-- PUT file://...emp_20.csv @csv_stage
-- PUT file://...emp_50.csv @csv_stage

SHOW FILE FORMATS;
-- FILE_CSV_FORMAT

-- Load only files matching pattern "contains EMP and ends in .gz"
COPY INTO emp
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = FILE_CSV_FORMAT)
PATTERN = '.*emp.*[.]gz';
-- 3 files loaded (emp_10, emp_20, emp_50)
```

> **Instructor:** "If the file contains EMP, you want to load all the files. At the end you have `.gz` — that is why I am giving `.*[.]gz` at the end. This is the command. They want you to use the pattern."

> **Certification Question:** "You have several CSV files loaded into a named stage. You want to load files from the stage into a table using pattern matching. How can you do that?"
> **Answer:** Use `PATTERN = '.*pattern.*\\.ext\\.gz'` in the COPY INTO command.

---

## 9. Snowflake Certification Review (Questions Covered in Class)

| Question | Answer |
|----------|--------|
| Recommended data type for JSON? | VARIANT |
| Can a single database exist in more than one Snowflake account? | No — one database belongs to one account |
| Role recommended for creating users and roles? | SECURITYADMIN |
| Does COPY INTO require a file format? | False — not required if stage has format assigned |
| Where does Snowflake store metadata? | Cloud Services Layer |
| Can PUT command be used in worksheet UI? | False — only in SnowSQL CLI |
| Does Snowflake allow only structured data loading? | False — JSON, XML, Parquet also supported |
| What does PUT command do automatically? | Compresses (GZIP) and encrypts files |
| Which cloud providers are supported by Snowflake? | AWS, Azure, GCP |
| What are the types of internal stages? | User (`@~`), Table (`@%table`), Named (`@stage`) |
| In which layer does Snowflake store metadata? | Cloud Services Layer |
| What is the earliest way to monitor queries run on Snowflake? | Query History (shows queries from last 14 days) |

> **Student Question:** "Is a customer using SnowSQL unable to use the Snowflake UI as well?"
> **Answer (instructor):** "No, that is not required. You can use both SnowSQL and the Snowflake web UI. There is no exclusive permission needed for SnowSQL."

> **Student Question:** "Is there any single query to grant all privileges at once?"
> **Answer (instructor):** "No, you cannot grant all privileges in one query. But it is a one-time effort — you configure a role once with all required privileges, then assign the role to users. That way you don't repeat the grant statements."

---

## 10. Role and User Management (Demonstrated in Class)

The instructor showed how to restrict a user to only one specific database:

```sql
SHOW ROLES;
SHOW GRANTS TO ROLE dev_role;

-- Create a new user
CREATE USER deepak PASSWORD='deepak@123';

-- By default deepak may have SECURITYADMIN role — revoke it
REVOKE ROLE securityadmin FROM USER deepak;

-- Create a restricted role
CREATE ROLE tst_role;

-- Grant only specific database access to the role
GRANT ROLE tst_role TO USER deepak;
GRANT USAGE ON DATABASE dev_db TO ROLE tst_role;

-- If public role has sales_db access, revoke it
REVOKE USAGE ON DATABASE sales_db FROM ROLE public;
```

> **Student Question:** "Is it possible for a user to be able to see only one database?"
> **Answer:** "Yes. Create a role, grant that role access only to that specific database, then assign the role to the user. The user will only see that one database."

---

## 11. Snowflake Data Storage Format (Columnar)

> **Student Question:** "In Snowflake, is data stored in column format or row format?"
> **Answer (instructor):** **Column format (columnar storage)**

| Database  | Storage Format |
|-----------|---------------|
| Oracle    | Row-based     |
| Snowflake | **Column-based** (columnar) |
| SQL Server| Row-based     |

```sql
-- The instructor showed this by creating a table
CREATE TABLE emp_details (empno NUMBER, ename VARCHAR, sal NUMBER);

-- Then showed query profile: partitions = 1 partition
SELECT * FROM emp_details;
-- Click Query ID → See query profile → 1 partition
```

> **Why columnar storage?** Columnar storage is much more efficient for analytical queries (e.g., `SUM(SAL)` only reads the SAL column, not entire rows). This is why Snowflake outperforms row-based systems for analytics.

---

## 12. Two Major Cost Categories in Snowflake

> **Certification Question:** "What are the two major cost categories in Snowflake?"
> **Answer:**

| Cost Type    | Description |
|--------------|-------------|
| **Storage Cost** | Cost for storing data in Snowflake's Data Storage Layer |
| **Compute Cost** | Cost for running virtual warehouses when reading/writing data |

---

## 13. Key Differences — VARIANT vs Regular Table Column

| Feature          | Regular Column (e.g., NUMBER)     | VARIANT Column |
|------------------|-----------------------------------|----------------|
| Data type        | Fixed (NUMBER, VARCHAR, DATE)     | Any semi-structured data |
| Schema change    | Requires ALTER TABLE              | No change needed — just add new keys to JSON |
| Key access       | Direct column reference           | `C1:key_name::TYPE` |
| Flexibility      | Rigid                             | Fully flexible |
| Storage          | Structured                        | Semi-structured (optimized columnar) |
| Use case         | Known, stable schema              | Unknown/changing schema (API data, JSON feeds) |

---

## 14. Key Differences — COPY INTO vs INSERT INTO for Complex Transformations

| Feature                  | COPY INTO                          | INSERT INTO ... SELECT              |
|--------------------------|------------------------------------|-------------------------------------|
| Simple column mapping    | Supported                          | Supported                           |
| LATERAL FLATTEN          | NOT supported                      | Supported                           |
| XMLGET function          | NOT supported                      | Supported                           |
| Performance              | Higher (optimized bulk loader)     | Lower (row-by-row insert logic)     |
| When to use              | Simple loads                       | Complex transformations             |

---

## 15. Key Commands Summary

```sql
-- Stages
SHOW STAGES;
LIST @json_stage;
RM @json_stage;

-- VARIANT table
CREATE TABLE t_semi_structed_Data (c1 variant);
COPY INTO t_semi_structed_Data FROM @json_stage FILE_FORMAT=json_format;
SELECT * FROM t_semi_structed_Data;

-- VARIANT with file tracking
CREATE TABLE t_ssd (file_name varchar, c1 variant);
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage (file_format=>json_format));
SELECT c1:sno::NUMBER AS sno FROM t_ssd WHERE file_name='sample.json.gz';
SELECT c1:id::NUMBER AS id, c1:first_name::VARCHAR FROM t_ssd WHERE file_name='car.json.gz';

-- Assign format to stage
DESC STAGE json_stage;
ALTER STAGE json_stage SET FILE_FORMAT = json_format;

-- COPY without format (after ALTER STAGE)
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);

-- COPY with PATTERN
COPY INTO emp FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = FILE_CSV_FORMAT)
PATTERN = '.*emp.*[.]gz';

-- Role management
SHOW ROLES;
SHOW GRANTS TO ROLE dev_role;
CREATE ROLE tst_role;
GRANT ROLE tst_role TO USER deepak;
GRANT USAGE ON DATABASE dev_db TO ROLE tst_role;
REVOKE USAGE ON DATABASE sales_db FROM ROLE public;

-- Query history info
SELECT CURRENT_WAREHOUSE();
```

---

## 16. Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `Error parsing JSON` on COPY INTO | No file format specified on a JSON stage | Add `FILE_FORMAT = json_format` or assign format to stage first |
| `0 rows loaded` in COPY with PATTERN | Pattern does not match actual file names in stage | Check `LIST @stage` for exact file names and adjust pattern |
| Returns null for `C1:key` | Wrong key name case or wrong column name (`$1` vs `C1`) | Use VARIANT column name (`C1:key`) not `$1:key` when querying from a table |
| File status = `SKIPPED` in PUT | File already exists in stage | Add `OVERWRITE = TRUE` to PUT command |

---

## 17. Interview Questions

**Q: What is the VARIANT data type in Snowflake?**
A: VARIANT is a special data type that can store any semi-structured data — JSON objects, arrays, XML, Parquet, or even primitives (numbers, strings, booleans). It is the recommended type for loading JSON data.

**Q: Is a COPY command required to specify a file format?**
A: False. If the stage has a file format already assigned (via `ALTER STAGE ... SET FILE_FORMAT`), the COPY command will use that format automatically without needing it specified explicitly.

**Q: How is data stored in Snowflake — row-based or column-based?**
A: **Column-based (columnar storage)**. Oracle is row-based. Snowflake is column-based, which makes analytical queries (aggregations, filters on specific columns) much faster.

**Q: What does the PUT command do when uploading a file?**
A: PUT automatically (1) **compresses** the file using GZIP and (2) **encrypts** the file. You cannot run PUT from the Snowsight web UI — it only works in SnowSQL CLI.

**Q: What is METADATA$FILENAME?**
A: A virtual column that Snowflake provides when querying stage files. It returns the name of the source file for each row, allowing you to distinguish records from different files loaded into the same stage or VARIANT table.

**Q: What are the two major cost categories in Snowflake?**
A: **Storage cost** (cost for storing data) and **Compute cost** (cost for running virtual warehouses for queries/loading).

**Q: Which Snowflake role is recommended for creating users and roles?**
A: **SECURITYADMIN**. This role is specifically designed to manage users, roles, and their privileges.

**Q: What does Query History in Snowflake show?**
A: It shows all SQL statements executed in the last **14 days**. You can click on a query ID to see query profile, partitions scanned, and performance details.

---

## 18. Try It Yourself Exercises

**Exercise 1:** Load all files from `json_stage` into `t_semi_structed_Data` (VARIANT table). Then count how many records came from each file.

```sql
-- Answer:
COPY INTO t_semi_structed_Data FROM @json_stage FILE_FORMAT=json_format;

-- Count by file (using metadata was loaded at copy time, not in variant table)
-- Better: use t_ssd which tracks file names:
SELECT file_name, COUNT(*) AS record_count
FROM t_ssd
GROUP BY file_name;
```

**Exercise 2:** From `t_ssd`, extract `id`, `car_make`, and `Car_Model_Year` for all car records sorted by id.

```sql
-- Answer:
SELECT c1:id::NUMBER AS id,
       c1:car_make::VARCHAR AS car_make,
       c1:Car_Model_Year::NUMBER AS car_model_year
FROM t_ssd
WHERE file_name = 'car.json.gz'
ORDER BY id;
```

**Exercise 3:** Use `PATTERN` in COPY INTO to load only emp files (not dept) from csv_stage into the emp table.

```sql
-- Answer:
COPY INTO emp
FROM @csv_stage
FILE_FORMAT = (FORMAT_NAME = FILE_CSV_FORMAT)
PATTERN = '.*emp.*[.]gz';
```

**Exercise 4:** Create a new role `analyst_role`, grant it access to `sales_db` and `sales_schema`, and assign it to user `deepak`.

```sql
-- Answer:
CREATE ROLE analyst_role;
GRANT USAGE ON DATABASE sales_db TO ROLE analyst_role;
GRANT USAGE ON SCHEMA sales_schema TO ROLE analyst_role;
GRANT SELECT ON ALL TABLES IN SCHEMA sales_schema TO ROLE analyst_role;
GRANT ROLE analyst_role TO USER deepak;
SHOW GRANTS TO ROLE analyst_role;
```

**Exercise 5:** Assign `json_format` to `json_stage`, then TRUNCATE `t_ssd` and reload it without specifying a file format in the COPY command.

```sql
-- Answer:
ALTER STAGE json_stage SET FILE_FORMAT = json_format;
TRUNCATE TABLE t_ssd;
COPY INTO t_ssd FROM (SELECT METADATA$FILENAME, $1 FROM @json_stage);
SELECT COUNT(*) FROM t_ssd;  -- All records reloaded
```

---

## 19. Summary

- Use `VARIANT` to store semi-structured JSON data in a table — the recommended data type for JSON
- `COPY INTO t_variant FROM @json_stage FILE_FORMAT=json_format` loads ALL files from the stage at once
- Use `METADATA$FILENAME` + `CREATE TABLE(file_name, c1 VARIANT)` to track which file each row came from
- When querying a VARIANT **column** in a table, use `C1:key::TYPE` (not `$1:key`)
- A stage can have a file format permanently assigned via `ALTER STAGE ... SET FILE_FORMAT` — after this, COPY INTO needs no explicit format
- `COPY INTO` with `PATTERN = '.*emp.*[.]gz'` loads only files matching the regex pattern
- **COPY INTO** only supports simple SELECT — no LATERAL FLATTEN or complex functions; use `INSERT INTO ... SELECT` for those
- Snowflake stores data in **columnar format** — optimized for analytical queries
- Two major Snowflake costs: **Storage** (data at rest) and **Compute** (virtual warehouse execution)
- SECURITYADMIN role manages users and roles; permissions are assigned once to a role, then the role is assigned to users
