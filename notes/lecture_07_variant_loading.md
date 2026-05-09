# Lecture 7: VARIANT Data Type, Loading Multiple JSON Files, and LATERAL FLATTEN

---

## 1. VARIANT Data Type — Review

The **VARIANT** data type in Snowflake stores semi-structured data (JSON, XML, Parquet) in a single column.

- Recommended Snowflake data type for JSON: **VARIANT**
- A VARIANT column can hold any JSON object, array, number, string, boolean, or null
- Data stored in VARIANT can be queried using dot-notation and the `::` cast operator

```sql
-- Create a table with VARIANT column
CREATE TABLE TNS_SEMI_STRUCTURED_DATA (
    C1 VARIANT
);
```

---

## 2. Multiple JSON Files in a Stage

The stages created in previous lectures:

```sql
SHOW STAGES;
-- CSV_STAGE, JSON_STAGE, PARQUET_STAGE, XML_STAGE
```

List files in the JSON stage:

```sql
LIST @JSON_STAGE;
-- sample.json.gz
-- car.json.gz
-- kids_data.json.gz
```

### Loading All Files from a Stage into a VARIANT Table

```sql
COPY INTO TNS_SEMI_STRUCTURED_DATA
FROM @JSON_STAGE
FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');
```

This loads records from **all JSON files** in the stage into the `C1` VARIANT column.

```sql
SELECT * FROM TNS_SEMI_STRUCTURED_DATA;
-- Each row contains one JSON object in C1
```

---

## 3. Storing JSON with File Name Reference

To keep track of which file each record came from:

```sql
CREATE TABLE TNS_SSD (
    FILE_NAME  VARCHAR,
    C1         VARIANT
);

COPY INTO TNS_SSD
FROM (
    SELECT METADATA$FILENAME, $1
    FROM @JSON_STAGE
    (FILE_FORMAT => 'JSON_FORMAT')
);

-- Verify: see which records belong to which file
SELECT FILE_NAME, C1 FROM TNS_SSD;
```

### Filtering by File

```sql
-- Only process records from sample.json.gz
SELECT
    C1:student_number::NUMBER  AS STUDENT_NUMBER,
    C1:student_name::VARCHAR   AS STUDENT_NAME,
    C1:course::VARCHAR         AS COURSE,
    C1:date_of_joining::DATE   AS DATE_OF_JOINING
FROM TNS_SSD
WHERE FILE_NAME LIKE '%sample.json%';
```

---

## 4. Processing JSON with Nested Arrays — kids_data.json

Some JSON files contain **nested structures** and **arrays**. Consider this file:

**File: kids_data.json**

```json
[
  {
    "name": "Bala",
    "gender": "male",
    "dob": "1985-06-15",
    "kids": ["Pavan", "Chandra"],
    "kids_school": ["Basha Manchitranna", "DPS"],
    "address": {
      "house_no": "12-3",
      "city": "Hyderabad",
      "state": "Telangana"
    },
    "phone": {
      "office": "040-12345678",
      "personal": "9876543210"
    }
  },
  {
    "name": "Jaya",
    "gender": "female",
    "dob": "1990-03-22",
    "kids": ["Riya", "DPS", "Slate"],
    "kids_school": ["RINAR", "DPS", "Slate"],
    "address": {
      "house_no": "45-7",
      "city": "Delhi",
      "state": "Delhi"
    },
    "phone": {
      "office": "011-87654321",
      "personal": "9123456780"
    }
  }
]
```

**Challenge:** The `kids` and `kids_school` fields are **arrays** — each person can have multiple kids.

---

## 5. What is an Array?

An **array** in JSON is a list of values enclosed in **square brackets** `[]`:

```json
"kids": ["Pavan", "Chandra"]
```

- `"kids"[0]` → `"Pavan"` (first element, zero-indexed)
- `"kids"[1]` → `"Chandra"` (second element)

Accessing array elements in Snowflake:

```sql
SELECT
    $1:name::VARCHAR        AS NAME,
    $1:kids[0]::VARCHAR     AS FIRST_KID,
    $1:kids[1]::VARCHAR     AS SECOND_KID
FROM @JSON_STAGE
(FILE_FORMAT => 'JSON_FORMAT')
WHERE METADATA$FILENAME LIKE '%kids_data%';
```

### Problem with Fixed Index Access

If you write:
```sql
SELECT $1:kids[0], $1:kids[1], $1:kids[2]
```

- For Bala: `kids[2]` is null (only 2 kids)
- For Jaya: `kids[2]` has a value (3 kids)

This approach requires knowing the **maximum number of array elements** upfront — not practical for large datasets.

---

## 6. UNION ALL — Combining Multiple Queries

Before learning LATERAL FLATTEN, a manual approach uses `UNION ALL`:

```sql
-- Get first kid for all records
SELECT $1:name::VARCHAR AS NAME, $1:kids[0]::VARCHAR AS KID
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT')
WHERE METADATA$FILENAME LIKE '%kids_data%'
  AND $1:kids[0] IS NOT NULL

UNION ALL

-- Get second kid for all records
SELECT $1:name::VARCHAR AS NAME, $1:kids[1]::VARCHAR AS KID
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT')
WHERE METADATA$FILENAME LIKE '%kids_data%'
  AND $1:kids[1] IS NOT NULL

UNION ALL

-- Get third kid (returns null for Bala)
SELECT $1:name::VARCHAR AS NAME, $1:kids[2]::VARCHAR AS KID
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT')
WHERE METADATA$FILENAME LIKE '%kids_data%'
  AND $1:kids[2] IS NOT NULL;
```

**Result:**
```
NAME | KID
-----|-------
Bala | Pavan
Bala | Chandra
Jaya | Riya
Jaya | DPS
Jaya | Slate
```

**Problem:** You need as many `UNION ALL` clauses as the maximum number of array elements. For 100-element arrays, this is impractical.

---

## 7. LATERAL FLATTEN — The Better Solution

**LATERAL FLATTEN** is a Snowflake table function that **expands arrays into rows**. It takes an array as input and returns one row per array element.

### Syntax

```sql
SELECT
    a.<column>,
    b.VALUE
FROM @stage_name (FILE_FORMAT => 'format_name') AS a,
     LATERAL FLATTEN(INPUT => a.$1:array_key) AS b
```

- `a` = alias for the stage (each row = one JSON record)
- `b` = alias for the flattened output (each row = one array element)
- `b.VALUE` = the actual array element value

### Example: Flatten Kids Array

```sql
SELECT
    a.$1:name::VARCHAR   AS NAME,
    a.$1:gender::VARCHAR AS GENDER,
    b.VALUE::VARCHAR     AS KID_NAME
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:kids) AS b
WHERE METADATA$FILENAME LIKE '%kids_data%';
```

**Result (5 rows for 2 records with combined 5 kids):**
```
NAME | GENDER | KID_NAME
-----|--------|----------
Bala | male   | Pavan
Bala | male   | Chandra
Jaya | female | Riya
Jaya | female | DPS
Jaya | female | Slate
```

With a single query, LATERAL FLATTEN handles any number of array elements!

---

## 8. LATERAL FLATTEN Columns

When using LATERAL FLATTEN, the flattened table (alias `b`) contains these columns:

| Column   | Description                                        |
|----------|----------------------------------------------------|
| `SEQ`    | Sequence number for ordering                        |
| `KEY`    | Key name (for objects; null for plain arrays)       |
| `PATH`   | Path to the element                                 |
| `INDEX`  | Zero-based position in the array (0, 1, 2, ...)    |
| `VALUE`  | The actual element value                            |
| `THIS`   | The input object/array                              |

```sql
-- See all LATERAL FLATTEN columns
SELECT b.*
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:kids) AS b
WHERE METADATA$FILENAME LIKE '%kids_data%';
```

The `INDEX` column is important when joining multiple LATERAL FLATTEN calls (e.g., kids and kids_school must align by index).

---

## 9. Flattening Two Arrays Together (kids + kids_school)

The challenge: kids and their schools should align (kid[0] goes to school[0], etc.)

```sql
SELECT
    a.$1:name::VARCHAR         AS NAME,
    b.VALUE::VARCHAR           AS KID_NAME,
    c.VALUE::VARCHAR           AS KID_SCHOOL
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:kids) AS b,
     LATERAL FLATTEN(INPUT => a.$1:kids_school) AS c
WHERE METADATA$FILENAME LIKE '%kids_data%'
  AND b.INDEX = c.INDEX;  -- Join on position to align kids with schools
```

**Result:**
```
NAME | KID_NAME | KID_SCHOOL
-----|----------|--------------------
Bala | Pavan    | Basha Manchitranna
Bala | Chandra  | DPS
Jaya | Riya     | RINAR
Jaya | DPS      | DPS
Jaya | Slate    | Slate
```

Without the `b.INDEX = c.INDEX` condition, you get a Cartesian product (duplicates).

---

## 10. Nested Objects in JSON

JSON can also contain **nested objects** (not arrays). The kids_data file has an `address` object:

```json
"address": {
  "house_no": "12-3",
  "city": "Hyderabad",
  "state": "Telangana"
}
```

Accessing nested object fields:

```sql
SELECT
    $1:name::VARCHAR              AS NAME,
    $1:address:house_no::VARCHAR  AS HOUSE_NO,
    $1:address:city::VARCHAR      AS CITY,
    $1:address:state::VARCHAR     AS STATE
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT')
WHERE METADATA$FILENAME LIKE '%kids_data%';
```

Use **colon chaining** (`$1:parent_key:child_key`) to navigate nested objects.

---

## 11. VARIANT + LATERAL FLATTEN from a Table

LATERAL FLATTEN also works on VARIANT columns in a table (not just stages):

```sql
-- Assuming TNS_SSD has C1 VARIANT column with kids_data
SELECT
    a.C1:name::VARCHAR  AS NAME,
    b.VALUE::VARCHAR    AS KID_NAME
FROM TNS_SSD AS a,
     LATERAL FLATTEN(INPUT => a.C1:kids) AS b
WHERE FILE_NAME LIKE '%kids_data%';
```

---

## 12. LATERAL FLATTEN — Key Rules

1. LATERAL FLATTEN **requires an array** as input
2. If input is a single-element (not an array), use `TO_ARRAY()` to convert it:
   ```sql
   LATERAL FLATTEN(INPUT => TO_ARRAY(a.$1:single_value))
   ```
3. The output column `VALUE` holds each array element
4. Use `VALUE::VARCHAR` to cast the value (removes surrounding double quotes)
5. Multiple LATERAL FLATTENs on the same record must be joined on `INDEX` to avoid duplicates
6. `COPY INTO` does **not** support complex functions like LATERAL FLATTEN — use `INSERT INTO ... SELECT` instead

---

## 13. Insert Instead of COPY INTO for Complex Transformations

When your loading logic involves functions like LATERAL FLATTEN, use `INSERT INTO ... SELECT`:

```sql
-- COPY INTO does not support LATERAL FLATTEN
-- Use INSERT INTO instead:

CREATE TABLE TNS_KIDS_INFO (
    NAME        VARCHAR,
    KID_NAME    VARCHAR,
    KID_SCHOOL  VARCHAR
);

INSERT INTO TNS_KIDS_INFO
SELECT
    a.$1:name::VARCHAR,
    b.VALUE::VARCHAR,
    c.VALUE::VARCHAR
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:kids) AS b,
     LATERAL FLATTEN(INPUT => a.$1:kids_school) AS c
WHERE METADATA$FILENAME LIKE '%kids_data%'
  AND b.INDEX = c.INDEX;
```

---

## 14. Certification Questions — Covered Topics

| Question                                               | Answer                                  |
|-------------------------------------------------------|-----------------------------------------|
| Recommended data type for JSON in Snowflake?          | VARIANT                                 |
| Can a single database exist in more than one account? | No                                      |
| Role recommended for creating users and roles?        | SECURITYADMIN                            |
| Does COPY INTO require a file format?                 | No (if stage has format assigned)        |
| Where does Snowflake store metadata?                  | Cloud Services Layer                     |
| Can PUT command be used in the web UI worksheet?      | No — only in SnowSQL (CLI)               |
| Does Snowflake allow only structured data loading?    | No — JSON, XML, Parquet supported too    |

---

## 15. Snowflake Data Storage Format

**Question:** Does Snowflake store data in **row format** or **column format**?

**Answer:** **Column format (columnar storage)**

- Oracle → Row-based
- Snowflake → **Column-based**

**Why columnar?** Columnar storage is much more efficient for analytical queries (e.g., `SUM(salary)` only needs to read the salary column, not entire rows).

---

## 16. Cost Categories in Snowflake

| Cost Type    | Description                                             |
|--------------|---------------------------------------------------------|
| Storage Cost | Cost for storing data in Snowflake (database layer)     |
| Compute Cost | Cost for running virtual warehouses (reads and writes)  |

These are the **two major cost categories** in Snowflake.

---

## 17. Key Commands Summary

```sql
-- Load all JSON files into VARIANT table
COPY INTO TNS_SEMI_STRUCTURED FROM @JSON_STAGE
FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT');

-- Access array element by index
SELECT $1:kids[0]::VARCHAR FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT');

-- LATERAL FLATTEN single array
SELECT a.$1:name::VARCHAR AS NAME, b.VALUE::VARCHAR AS KID
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:kids) AS b;

-- LATERAL FLATTEN two aligned arrays
SELECT a.$1:name::VARCHAR AS NAME, b.VALUE::VARCHAR AS KID, c.VALUE::VARCHAR AS SCHOOL
FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:kids) AS b,
     LATERAL FLATTEN(INPUT => a.$1:kids_school) AS c
WHERE b.INDEX = c.INDEX;

-- LATERAL FLATTEN from table
SELECT a.C1:name::VARCHAR AS NAME, b.VALUE::VARCHAR AS KID
FROM TNS_SSD AS a,
     LATERAL FLATTEN(INPUT => a.C1:kids) AS b;

-- INSERT (for complex transformations not supported by COPY INTO)
INSERT INTO target_table
SELECT ... FROM @stage AS a, LATERAL FLATTEN(...) AS b;

-- Nested object access
SELECT $1:address:city::VARCHAR FROM @JSON_STAGE (FILE_FORMAT => 'JSON_FORMAT');
```

---

## 18. Key Terms

| Term            | Definition                                                                    |
|-----------------|-------------------------------------------------------------------------------|
| VARIANT         | Snowflake data type for semi-structured data (JSON, XML, Parquet)              |
| Array           | JSON list structure: `["value1", "value2", "value3"]` enclosed in `[]`        |
| LATERAL FLATTEN | Table function that expands an array into individual rows                      |
| VALUE           | Column in LATERAL FLATTEN output containing each array element                 |
| INDEX           | Zero-based position of each element in the array (0, 1, 2, ...)               |
| Nested Object   | JSON object inside another object: `"address": { "city": "Hyderabad" }`       |
| UNION ALL       | SQL operator to combine results of multiple queries                            |
| Columnar Storage| Data storage format where each column is stored together (Snowflake's format) |

---

## 19. Summary

- Use `VARIANT` to store semi-structured JSON data in a table
- JSON arrays (`[]`) require special handling — you can't just use `$1:key[0]`, `$1:key[1]`, etc. for large arrays
- **LATERAL FLATTEN** is the correct tool for expanding JSON arrays into rows
- It takes an array as input and produces one row per element, with a `VALUE` column
- When flattening two aligned arrays (e.g., kids + schools), join on `b.INDEX = c.INDEX`
- For nested JSON objects, use `$1:parent:child` colon chaining
- **COPY INTO** does not support complex functions — use `INSERT INTO ... SELECT` instead
- Snowflake uses **columnar storage** (not row-based like Oracle)
- The two main Snowflake cost categories are **Storage** and **Compute**
