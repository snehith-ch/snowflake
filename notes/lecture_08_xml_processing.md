# Lecture 8: XML File Processing, XMLGET Function, and LATERAL FLATTEN

---

## Quick Revision — Lecture 8

| # | Key Point |
|---|-----------|
| 1 | XML = tag-based format; root element wraps all records (`<ROWSET>`, `<catalog>`) |
| 2 | Like JSON/Parquet, XML from a stage reads as **one column** (`$1`) |
| 3 | `$1:"@"` returns the **root name** (tag name); `$1:"$"` returns the **root content** (array of child elements) |
| 4 | `XMLGET($1, 'ROW', 0)` extracts the first `<ROW>` element; position is zero-based |
| 5 | `XMLGET(element, 'EMPNO'):"$"::NUMBER` extracts the value of a sub-element |
| 6 | LATERAL FLATTEN on `$1:"$"` processes all records with one query |
| 7 | If XML has only ONE record, `$1:"$"` is not an array — use `TO_ARRAY($1:"$")` before FLATTEN |
| 8 | `COPY INTO` does NOT support XMLGET/LATERAL FLATTEN — use `INSERT INTO ... SELECT` |
| 9 | `SELECT GET_DDL('TABLE', 'EMP')` returns the CREATE TABLE script of any object |
| 10 | `PUT file://... @xml_stage OVERWRITE=TRUE` replaces an existing file in the stage |

---

**Pre-requisite:** Lecture 7 — VARIANT, Loading, LATERAL FLATTEN basics with JSON
**Next:** Lecture 9 — SnowSQL CLI, Stage Management, CSV Special Characters
**Related:** Lecture 6 — JSON arrays and LATERAL FLATTEN (same concept applied to XML)

---

## Objects Created in This Lecture

| Object Type  | Name               | Purpose |
|--------------|--------------------|---------|
| File Format  | xml_format         | Tells Snowflake to parse files as XML (TYPE=XML) |
| Stage        | xml_stage          | Internal named stage for XML files (already exists) |
| Table        | emp                | Employee table (8 columns) — target for XML data |
| File         | emp_sample.xml     | XML file with ROWSET/ROW structure (14 employees) |
| File         | books_sample.xml   | XML file with catalog/book structure (12 books) |
| File         | single_record.xml  | XML file with only ONE record — special case |

---

## ASCII Data Flow — XML Loading

```
emp_sample.xml (local disk)
      |
      |  PUT file://...emp_sample.xml @xml_stage  (SnowSQL CLI)
      v
@xml_stage (internal named stage)
  emp_sample.xml.gz
      |
      |  SELECT $1 FROM @xml_stage (file_format=>xml_format)
      v  -- Single column: entire XML document
      |
      |  SELECT $1:"$" FROM @xml_stage  -- array of <ROW> elements
      v
      |
      |  LATERAL FLATTEN(a.$1:"$") AS b
      v  -- One row per <ROW> element
      |
      |  XMLGET(b.value, 'EMPNO'):"$"::NUMBER
      v
INSERT INTO emp (SELECT ... FROM @xml_stage, LATERAL FLATTEN)
      |
      v
emp table (14 records loaded)
```

---

## 1. What is XML?

**XML (Extensible Markup Language)** is a semi-structured data format that uses **tags** to define elements. It is commonly used in legacy enterprise systems, web services (SOAP), and configuration files.

### XML Structure — Two types seen in class:

**Type 1: emp_sample.xml (ROWSET/ROW structure)**
```xml
<ROWSET>
    <ROW>
        <EMPNO>7369</EMPNO>
        <ENAME>Kiran</ENAME>
        <JOB>ANALYST</JOB>
        <MGR>7902</MGR>
        <HIREDATE>2022-12-17</HIREDATE>
        <SAL>3000</SAL>
        <COMM>500</COMM>
        <DEPTNO>20</DEPTNO>
    </ROW>
    <ROW>
        <EMPNO>7370</EMPNO>
        <ENAME>Sai</ENAME>
        <JOB>SALESMAN</JOB>
        <MGR>7902</MGR>
        <HIREDATE>2022-12-17</HIREDATE>
        <SAL>2500</SAL>
        <COMM>300</COMM>
        <DEPTNO>30</DEPTNO>
    </ROW>
</ROWSET>
```

**Type 2: books_sample.xml (catalog/book structure)**
```xml
<catalog>
    <book>
        <id>bk001</id>
        <author>Gambardella, Matthew</author>
        <title>XML Developer's Guide</title>
        <genre>Computer</genre>
        <price>44</price>
        <publish_date>2000-10-01</publish_date>
        <description>An in-depth look at creating XML applications.</description>
    </book>
</catalog>
```

### XML Terminology

| Term    | Description | Example |
|---------|-------------|---------|
| Root    | Top-level parent element | `<ROWSET>`, `<catalog>` |
| Tag     | Opening and closing markers | `<EMPNO>...</EMPNO>` |
| Element | A node within the XML tree | `<ROW>`, `<EMPNO>` |
| ROWSET  | Common root name for a set of rows | `<ROWSET>` |
| ROW     | A single record within ROWSET | `<ROW>...</ROW>` |

> **Instructor:** "What is ROWSET? ROWSET is nothing but the root name. Within the ROWSET you have two records — each is called ROW. What is a starting tag? This is a starting tag. This is the ending tag."

---

## 2. Complete Class Workflow — Step by Step

### Step 1: Check what stages exist

```sql
SHOW STAGES;
-- csv_stage, json_stage, xml_stage, parquet_stage
```

### Step 2: Check files in XML stage

```sql
LIST @xml_stage;
-- books_info.xml.gz  (uploaded earlier)
```

### Step 3: Create the XML file format

```sql
SHOW FILE FORMATS;
-- We have csv_format and json_format — no xml_format yet

CREATE FILE FORMAT xml_format
TYPE = xml;
```

### Step 4: Get DDL of EMP table (to understand its structure)

> **Instructor:** "How can I get the DDL of this particular object? DDL means Data Definition Language — the creation script."

```sql
-- GET_DDL syntax: SELECT GET_DDL('object_type', 'object_name')
SELECT GET_DDL('TABLE', 'EMP');
```

Output:
```sql
CREATE OR REPLACE TABLE EMP (
    EMPNO    NUMBER(38,0),
    ENAME    VARCHAR(16777216),
    JOB      VARCHAR(16777216),
    MGR      NUMBER(38,0),
    HIREDATE DATE,
    SAL      NUMBER(38,0),
    COMM     NUMBER(38,0),
    DEPTNO   NUMBER(38,0),
    MOBILE   NUMBER(38,0),   -- extra column from previous session
    STATUS   BOOLEAN          -- extra column from previous session
);
```

The XML file has 8 columns. The table has 10 — recreate with only 8 columns:

```sql
-- Delete existing records
DELETE FROM emp;

-- Recreate table with 8 columns (matching XML structure)
CREATE OR REPLACE TABLE EMP (
    EMPNO    NUMBER(38,0),
    ENAME    VARCHAR(16777216),
    JOB      VARCHAR(16777216),
    MGR      NUMBER(38,0),
    HIREDATE DATE,
    SAL      NUMBER(38,0),
    COMM     NUMBER(38,0),
    DEPTNO   NUMBER(38,0)
);
```

> **GET_DDL works for any object type:**
> ```sql
> SELECT GET_DDL('FILE_FORMAT', 'FILE_CSV_FORMAT');  -- file format creation script
> SELECT GET_DDL('TABLE', 'EMP');                     -- table creation script
> SELECT GET_DDL('VIEW', 'my_view');                  -- view creation script
> SELECT GET_DDL('STAGE', 'csv_stage');               -- stage creation script
> ```

### Step 5: Upload the XML file via SnowSQL

```
C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
```

```sql
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
```
```
| Statement executed successfully. |   1 Row(s) produced. Time Elapsed: 0.087s
```

```sql
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use schema SALES_SCHEMA;
```
```
| Statement executed successfully. |   1 Row(s) produced. Time Elapsed: 0.085s
```

```sql
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp_sample.xml @xml_stage;
```

```
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp_sample.xml | emp_sample.xml.gz |         448 |         256 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.093s
```

### Step 6: Verify the upload

```sql
LIST @xml_stage;
-- emp_sample.xml.gz   (new file)
-- books_info.xml.gz   (old file)
```

---

## 3. How Snowflake Processes XML

Like JSON and Parquet, XML files read from a stage have **only one column** (`$1`). The entire XML document comes through as a single value.

When Snowflake reads XML, it internally converts it to a **JSON-like structure** for processing.

```sql
-- Single column read
SELECT $1 FROM @xml_stage (file_format=>xml_format);

-- Specify file path to limit to one file
SELECT $1 FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
```

### Getting the Root Name — `$1:"@"`

```sql
-- "@" symbol returns the TAG NAME (root/element name)
SELECT $1:"@"
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- Returns: "ROWSET"
```

### Getting Root Content — `$1:"$"`

```sql
-- "$" symbol returns the VALUE/CONTENT of an element (as an array of children)
SELECT $1:"$"
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- Returns: array of ROW elements [{"@":"ROW","$":[...]}, {"@":"ROW","$":[...]}, ...]
```

> **Instructor:** "So what is `@`? The `@` means tag name. And what is `$`? The `$` means value. So the complete information is available in array format — within square braces. That is array."

---

## 4. The XMLGET Function

`XMLGET` extracts a specific element from an XML structure by tag name and optional position.

### Syntax

```sql
XMLGET(xml_value, 'tag_name', position)
-- position is optional; defaults to 0 (first occurrence)
```

- `xml_value`: The XML input (`$1` from stage or a VARIANT column)
- `'tag_name'`: The element tag to find (case-sensitive)
- `position`: Zero-based index (0 = first, 1 = second, etc.)

### Extract First and Second ROW

```sql
-- First ROW (zero-based index 0)
SELECT XMLGET($1, 'ROW', 0) AS value
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);

-- Second ROW
SELECT XMLGET($1, 'ROW', 1) AS value
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
```

> **Instructor:** "So here I am using zero-based index. Zero means what? The first record. If you don't give any value, it is the first record by default. If I give one, I get the second record."

---

## 5. Extracting Field Values from XML (Three-Step Process)

### Step 1: Get the ROW element (gives a "value" to work with)

```sql
SELECT XMLGET($1, 'ROW', 0) AS value
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
```

### Step 2: Get a specific field using XMLGET on value

```sql
SELECT XMLGET(value, 'EMPNO')
FROM (
    SELECT XMLGET($1, 'ROW', 0) AS value
    FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);
-- Returns: {"@":"EMPNO","$":"7369"}
```

### Step 3: Extract the tag name vs the value

```sql
-- "@" gives the tag name (EMPNO)
SELECT XMLGET(value, 'EMPNO'):"@"
FROM (SELECT XMLGET($1, 'ROW', 0) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format));

-- "$" gives the actual VALUE of the element
SELECT XMLGET(value, 'EMPNO'):"$"
FROM (SELECT XMLGET($1, 'ROW', 0) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format));
-- Returns: "7369"

-- Cast to NUMBER to get typed value
SELECT XMLGET(value, 'EMPNO'):"$"::NUMBER AS empno
FROM (SELECT XMLGET($1, 'ROW', 0) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format));
-- Returns: 7369
```

> **Instructor:** "What is `@`? `@` will give you the key name (tag name). What is `$`? `$` gives you the value. These two are very important in XML processing."

---

## 6. Full Column Extraction — UNION Approach (For Small Files)

For the first version of emp_sample.xml with only 2 records:

```sql
SELECT xmlget(value,'EMPNO'):"$"::number   AS empno,
       xmlget(value,'ENAME'):"$"::varchar  AS ename,
       xmlget(value,'JOB'):"$"::varchar    AS job,
       xmlget(value,'MGR'):"$"::number     AS mgr,
       xmlget(value,'HIREDATE'):"$"::date  AS hiredate,
       xmlget(value,'SAL'):"$"::number     AS sal,
       xmlget(value,'COMM'):"$"::number    AS comm,
       xmlget(value,'DEPTNO'):"$"::number  AS deptno
FROM (
    SELECT xmlget($1,'ROW',0) AS value
    FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION
    SELECT xmlget($1,'ROW',1) AS value
    FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);
```

> **Problem:** This approach requires one UNION per record. For 14 records you need 14 UNION clauses. Not practical for large files.

Extended UNION for all 7 rows (after adding more records):

```sql
-- Instructor showed union of 7 records:
SELECT xmlget(value,'EMPNO'):"$"::number AS empno, ...
FROM (
    SELECT xmlget($1,'ROW',0) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION SELECT xmlget($1,'ROW',1) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION SELECT xmlget($1,'ROW',2) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION SELECT xmlget($1,'ROW',3) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION SELECT xmlget($1,'ROW',4) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION SELECT xmlget($1,'ROW',5) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
    UNION SELECT xmlget($1,'ROW',6) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);
```

> **Instructor:** "But is it the ideal way to do that? What if we have like 10,000 records? Are you going to write 10,000 queries? No, right? Let me tell you the simplest way — LATERAL FLATTEN."

---

## 7. Re-Uploading Updated File (OVERWRITE=TRUE)

The instructor added more records to emp_sample.xml and needed to re-upload:

```sql
-- Without OVERWRITE: status = SKIPPED (file already exists)
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\...\emp_sample.xml @xml_stage;
-- | emp_sample.xml | emp_sample.xml.gz | 448 | 0 | SKIPPED |

-- With OVERWRITE=TRUE: status = UPLOADED (replaces existing file)
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\...\emp_sample.xml @xml_stage OVERWRITE=true;
```

```
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp_sample.xml | emp_sample.xml.gz |        2659 |         576 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.052s
```

Note the larger size (2659 vs 448 bytes) confirms the updated file was uploaded.

---

## 8. LATERAL FLATTEN for XML — The Optimal Approach

**Key insight:** `$1:"$"` returns the root content as an **array** of child elements. LATERAL FLATTEN can expand this array into one row per record.

### Step 1: Verify the array

```sql
-- $1:"$" gives the array of ROW elements
SELECT $1:"$" FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- Returns: [{"@":"ROW","$":[...]}, {"@":"ROW","$":[...]}, ...] -- all 14 records
```

### Step 2: Apply LATERAL FLATTEN

```sql
-- See all FLATTEN columns
SELECT b.*
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format) a,
     lateral flatten($1:"$") b;
-- 14 rows returned (b.value = one ROW element each)
```

### Step 3: Extract fields from each b.value

```sql
-- Full extraction with LATERAL FLATTEN — 14 records at once
SELECT xmlget(value,'EMPNO'):"$"::number  AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar   AS job,
       xmlget(value,'MGR'):"$"::number    AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number    AS sal,
       xmlget(value,'COMM'):"$"::number   AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");
-- 14 rows — works for any number of records!
```

> **Instructor:** "So instead of preparing these many statements, if I run this — what will happen is I get the 14 records. What is LATERAL FLATTEN doing? It is internally preparing the different statements — one for each record. I am making use of the value column and building the statement."

---

## 9. Loading XML into EMP Table

### COPY INTO attempt — and why it FAILS

```sql
-- This FAILS:
COPY INTO emp FROM (
    SELECT xmlget(value,'EMPNO'):"$"::number AS empno, ...
    FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
         lateral flatten($1:"$")
);
-- Error: "COPY statement only supports simple select, comes stage statement for import"
```

> **Instructor:** "The point is when you are having these complex functions, COPY statement will not support that. So in that scenario, what you can do is simply use INSERT statement."

### Correct approach: INSERT INTO ... SELECT

```sql
-- Method 1: INSERT (for complex transformations not supported by COPY INTO)
INSERT INTO emp
SELECT xmlget(value,'EMPNO'):"$"::number  AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar   AS job,
       xmlget(value,'MGR'):"$"::number    AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number    AS sal,
       xmlget(value,'COMM'):"$"::number   AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");
-- 14 records inserted into emp

-- Method 2: COPY INTO (also works for simple XML without complex functions)
COPY INTO emp FROM (
    SELECT xmlget(value,'EMPNO'):"$"::number AS empno,
           xmlget(value,'ENAME'):"$"::varchar AS ename,
           xmlget(value,'JOB'):"$"::varchar AS job,
           xmlget(value,'MGR'):"$"::number AS mgr,
           xmlget(value,'HIREDATE'):"$"::date AS hiredate,
           xmlget(value,'SAL'):"$"::number AS sal,
           xmlget(value,'COMM'):"$"::number AS comm,
           xmlget(value,'DEPTNO'):"$"::number AS deptno
    FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
         lateral flatten($1:"$")
);
```

> **Note:** COPY INTO actually works in this case too (the instructor ran both). The restriction is more specifically around very complex nested functions. INSERT INTO is the safest approach when COPY INTO fails.

---

## 10. Books XML Example (books_sample.xml)

### Upload via SnowSQL

```
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\...\books_sample.xml @xml_stage;
+------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source           | target              | source_size | target_size | source_compression | target_compression | status   | message |
|------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| books_sample.xml | books_sample.xml.gz |         752 |         400 | NONE               | GZIP               | UPLOADED |         |
+------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.663s
```

### Extract data from books_sample.xml

```sql
-- Note: root is "catalog", children are "book" elements
-- Use same LATERAL FLATTEN pattern on $1:"$"
SELECT xmlget(value,'id'):"$"::varchar          AS id,
       xmlget(value,'author'):"$"::varchar      AS author,
       xmlget(value,'title'):"$"::varchar       AS title,
       xmlget(value,'genre'):"$"::varchar       AS genre,
       xmlget(value,'price'):"$"::number        AS price,
       xmlget(value,'publish_date'):"$"::date   AS publish_date,
       xmlget(value,'description'):"$"::varchar AS description
FROM @xml_stage/books_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");
-- 12 records returned (after instructor added all records)
```

> **Instructor:** "What is catalog? Catalog is called **root**. What are these elements? These are the elements **inside the root**. The same pattern applies — same LATERAL FLATTEN approach works regardless of root/element names."

---

## 11. Handling Single-Record XML Files (single_record.xml)

During Lecture 9 (reviewed here as context), the instructor demonstrated the special case of a single-record XML file.

**Problem:** If XML has only one record, `$1:"$"` does NOT return an array:

```sql
-- First upload the single-record file (done in Lecture 9 via SnowSQL)
-- put file://...single_record.xml @xml_stage

LIST @xml_stage;

SELECT $1 FROM @xml_stage/single_record.xml (file_format=>xml_format);

-- $1:"$" for a single record returns a single element (NOT an array):
SELECT $1:"$" FROM @xml_stage/single_record.xml (file_format=>xml_format);
-- Returns: {"@":"ROW", "$":[...]}  -- NOT wrapped in []
```

**Solution: Use TO_ARRAY()**

```sql
-- Convert single element to array:
SELECT TO_ARRAY($1:"$")
FROM @xml_stage/single_record.xml (file_format=>xml_format);
-- Now returns: [{"@":"ROW","$":[...]}]  -- wrapped in []
```

Now LATERAL FLATTEN works:

```sql
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
```

**Alternative for single record — direct XMLGET without FLATTEN:**

```sql
-- For a single record, you can use nested XMLGET directly:
SELECT xmlget(xmlget($1,'ROW'),'EMPNO'):"$"::number AS empno,
       xmlget(xmlget($1,'ROW'),'ENAME'):"$"::varchar AS ename
FROM @xml_stage/single_record.xml.gz (file_format=>xml_format);
```

> **Instructor:** "So without using LATERAL FLATTEN you can get that because you only have a single record. LATERAL FLATTEN is for when you have multiple records — generally you would not have a single record, you will have multiple records."

> **Student Question:** "Should we only use lateral flatten when the XML is in JSON format?"
> **Answer (instructor):** "See, basically XML gets converted into JSON internally. What I'm trying to say is XML to we convert into JSON, from JSON we load into a table. If we have more than one record, we use LATERAL FLATTEN. If we have a single record, we can use XMLGET directly without FLATTEN."

---

## 12. XML vs JSON — Key Differences in Snowflake Processing

| Operation | JSON | XML |
|-----------|------|-----|
| Get root name | N/A (no root concept) | `$1:"@"` |
| Get content/children | `$1` or `$1:key` directly | `$1:"$"` (returns array of children) |
| Get element value | `$1:key_name` | `XMLGET($1, 'tag_name'):"$"` |
| Get by position | `$1:array[0]` | `XMLGET($1, 'tag_name', 0)` |
| Flatten array | `LATERAL FLATTEN(INPUT => a.$1:array_key)` | `LATERAL FLATTEN(INPUT => a.$1:"$")` |
| Single record special case | Not an issue | Use `TO_ARRAY($1:"$")` |
| Value extraction cast | `$1:key::TYPE` | `XMLGET(val, 'tag'):"$"::TYPE` |

---

## 13. Creating the XML File Format

```sql
CREATE FILE FORMAT xml_format
TYPE = xml;
-- That's all — no additional parameters needed for XML
```

Compare with CSV format (which needs many parameters):
```sql
CREATE FILE FORMAT csv_format
TYPE = csv
SKIP_HEADER = 1
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n';
```

---

## 14. Key Commands Summary

```sql
-- XML file format
CREATE FILE FORMAT xml_format TYPE = xml;
SHOW FILE FORMATS;

-- Upload via SnowSQL (CLI only)
-- PUT file://C:\Users\Balakrishna\...\emp_sample.xml @xml_stage;
-- PUT file://C:\Users\Balakrishna\...\emp_sample.xml @xml_stage OVERWRITE=true;
-- PUT file://C:\Users\Balakrishna\...\books_sample.xml @xml_stage;

-- Verify
LIST @xml_stage;

-- GET_DDL
SELECT GET_DDL('TABLE', 'EMP');
SELECT GET_DDL('FILE_FORMAT', 'FILE_CSV_FORMAT');

-- Read raw XML
SELECT $1 FROM @xml_stage (file_format=>xml_format);
SELECT $1 FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);

-- Get root name
SELECT $1:"@" FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- Returns: "ROWSET"

-- Get root content as array
SELECT $1:"$" FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);

-- Extract record by position
SELECT xmlget($1,'ROW',0) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
SELECT xmlget($1,'ROW',1) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);

-- Extract field from a row
SELECT xmlget(value,'EMPNO'):"$" FROM (
    SELECT xmlget($1,'ROW',0) AS value FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);

-- LATERAL FLATTEN — optimal for multiple records
SELECT b.*
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format) a,
     lateral flatten($1:"$") b;

-- Full extraction with LATERAL FLATTEN
SELECT xmlget(value,'EMPNO'):"$"::number  AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar   AS job,
       xmlget(value,'MGR'):"$"::number    AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number    AS sal,
       xmlget(value,'COMM'):"$"::number   AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");

-- INSERT INTO (use this when COPY INTO fails for complex XML)
INSERT INTO emp
SELECT xmlget(value,'EMPNO'):"$"::number, xmlget(value,'ENAME'):"$"::varchar, ...
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");

-- COPY INTO (also works for the LATERAL FLATTEN case in class)
COPY INTO emp FROM (
    SELECT xmlget(value,'EMPNO'):"$"::number, ...
    FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
         lateral flatten($1:"$")
);

-- Single-record XML (use TO_ARRAY)
SELECT TO_ARRAY($1:"$") FROM @xml_stage/single_record.xml (file_format=>xml_format);
LATERAL FLATTEN(TO_ARRAY(a.$1:"$")) AS b;

-- Alternative for single record
SELECT xmlget(xmlget($1,'ROW'),'EMPNO'):"$"::number AS empno,
       xmlget(xmlget($1,'ROW'),'ENAME'):"$"::varchar AS ename
FROM @xml_stage/single_record.xml.gz (file_format=>xml_format);

-- Books XML
SELECT xmlget(value,'id'):"$"::varchar        AS id,
       xmlget(value,'author'):"$"::varchar    AS author,
       xmlget(value,'title'):"$"::varchar     AS title,
       xmlget(value,'genre'):"$"::varchar     AS genre,
       xmlget(value,'price'):"$"::number      AS price,
       xmlget(value,'publish_date'):"$"::date AS publish_date,
       xmlget(value,'description'):"$"::varchar AS description
FROM @xml_stage/books_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");
```

---

## 15. Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `COPY statement only supports simple select, comes stage statement for import` | Using complex functions (XMLGET, LATERAL FLATTEN) inside COPY INTO | Use `INSERT INTO ... SELECT` instead of COPY INTO |
| LATERAL FLATTEN returns NULL values | XML has single record — `$1:"$"` returns single object, not array | Use `TO_ARRAY($1:"$")` to wrap in array before passing to FLATTEN |
| `SKIPPED` status in PUT output | File already exists in stage | Add `OVERWRITE = TRUE` to PUT command |
| Getting wrong number of records | Using UNION approach with insufficient UNION clauses | Switch to LATERAL FLATTEN approach — handles any number of records |
| NULL returned from XMLGET | Tag name case mismatch or tag does not exist at that path | Check exact XML tag names — they are case-sensitive |
| File cast to VARIANT error | Trying to cast XML sub-element without `:"$"` | Always use `:"$"` to get the text value: `xmlget(v, 'TAG'):"$"::TYPE` |

---

## 16. Interview Questions

**Q: How does Snowflake process XML data from a stage?**
A: XML files from a stage appear as a single column (`$1`). Snowflake internally converts XML to a JSON-like structure. Use `$1:"@"` to get the root name and `$1:"$"` to get the array of child elements. Then use `XMLGET` to extract specific elements and `LATERAL FLATTEN` to iterate over multiple records.

**Q: What is the XMLGET function?**
A: `XMLGET(xml_value, 'tag_name', position)` — extracts a specific XML element by tag name and zero-based position from an XML VARIANT value. Returns the element as a VARIANT containing `"@"` (tag name) and `"$"` (value).

**Q: What does `$1:"@"` and `$1:"$"` mean in XML processing?**
A: `"@"` returns the **tag name** of the element. `"$"` returns the **value/content** of the element (or array of child elements for the root). These are Snowflake's special XML notation symbols.

**Q: Why use LATERAL FLATTEN for XML instead of XMLGET with UNION?**
A: XMLGET with UNION requires one clause per record — impractical for large files. LATERAL FLATTEN takes `$1:"$"` (the array of all ROW elements) as input and generates one row per element automatically, regardless of file size.

**Q: What is TO_ARRAY() used for in XML processing?**
A: `TO_ARRAY()` wraps a single non-array value into an array. It is used when an XML file has only one record — in this case `$1:"$"` returns a single object (not an array), so LATERAL FLATTEN fails. `TO_ARRAY($1:"$")` makes it an array with one element so FLATTEN can process it.

**Q: What is GET_DDL used for?**
A: `SELECT GET_DDL('object_type', 'object_name')` returns the complete CREATE statement for any Snowflake object — tables, views, file formats, stages, procedures, functions, etc. Useful for understanding an object's structure or recreating it.

**Q: Can COPY INTO be used with XMLGET and LATERAL FLATTEN?**
A: In practice COPY INTO can work with LATERAL FLATTEN for XML, but INSERT INTO ... SELECT is the safer approach when COPY INTO throws the error "COPY statement only supports simple select." The insert approach always works for complex transformations.

**Q: What is the difference between the root element and its children in XML?**
A: The root element is the outermost tag that wraps all records (e.g., `<ROWSET>`, `<catalog>`). Children are the records nested inside (e.g., `<ROW>`, `<book>`). In Snowflake: `$1:"@"` = root name, `$1:"$"` = array of children.

---

## 17. Try It Yourself Exercises

**Exercise 1:** Create the XML file format and upload `emp_sample.xml` to `xml_stage`. Verify the file appears in the stage.

```sql
-- Answer:
CREATE FILE FORMAT xml_format TYPE = xml;
-- Upload via SnowSQL:
-- PUT file://path/emp_sample.xml @xml_stage;

LIST @xml_stage;
-- Should show emp_sample.xml.gz
```

**Exercise 2:** Read the root name and root content from `emp_sample.xml.gz`.

```sql
-- Answer:
SELECT $1:"@" FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- Output: "ROWSET"

SELECT $1:"$" FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- Output: array of ROW elements
```

**Exercise 3:** Extract EMPNO and ENAME from the first ROW using XMLGET with position 0.

```sql
-- Answer:
SELECT xmlget(xmlget($1,'ROW',0),'EMPNO'):"$"::number AS empno,
       xmlget(xmlget($1,'ROW',0),'ENAME'):"$"::varchar AS ename
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
```

**Exercise 4:** Use LATERAL FLATTEN to extract all 8 columns from all records in `emp_sample.xml.gz` and load them into the `emp` table.

```sql
-- Answer:
DELETE FROM emp;  -- clear existing records

INSERT INTO emp
SELECT xmlget(value,'EMPNO'):"$"::number  AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar   AS job,
       xmlget(value,'MGR'):"$"::number    AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number    AS sal,
       xmlget(value,'COMM'):"$"::number   AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");

SELECT COUNT(*) FROM emp;  -- Should be 14
```

**Exercise 5:** Extract all 7 columns from `books_sample.xml.gz` using LATERAL FLATTEN.

```sql
-- Answer:
SELECT xmlget(value,'id'):"$"::varchar          AS id,
       xmlget(value,'author'):"$"::varchar      AS author,
       xmlget(value,'title'):"$"::varchar       AS title,
       xmlget(value,'genre'):"$"::varchar       AS genre,
       xmlget(value,'price'):"$"::number        AS price,
       xmlget(value,'publish_date'):"$"::date   AS publish_date,
       xmlget(value,'description'):"$"::varchar AS description
FROM @xml_stage/books_sample.xml.gz (file_format=>xml_format),
     lateral flatten($1:"$");
```

---

## 18. Summary

- XML uses **tags** (opening and closing) to structure data in a tree
- When read from a stage, XML is a **single column** (`$1`) — same as JSON and Parquet
- `$1:"@"` gives the **root name** (e.g., "ROWSET"); `$1:"$"` gives the **root content** (array of child elements)
- `XMLGET(xml, 'tag_name', position)` extracts a specific element by name and zero-based position
- `XMLGET(element, 'field_name'):"$"` extracts the **value** of a sub-element; `:"@"` gives the tag name
- `LATERAL FLATTEN(INPUT => a.$1:"$")` expands the array of XML elements into individual rows — works for any number of records
- For **single-record XML**, use `TO_ARRAY()` to convert the single element to an array before using LATERAL FLATTEN; or use nested XMLGET directly
- Use `INSERT INTO ... SELECT` (not `COPY INTO`) for XML transformations involving XMLGET and LATERAL FLATTEN
- The XML file format is created with just `TYPE = XML` — no additional parameters
- `GET_DDL('object_type', 'object_name')` returns the creation script of any Snowflake object
- `PUT ... OVERWRITE = TRUE` replaces an existing file in the stage
