# Lecture 8: XML File Processing, XMLGET Function, and LATERAL FLATTEN

---

## 1. What is XML?

**XML (Extensible Markup Language)** is a semi-structured data format that uses **tags** to define elements. It is commonly used in legacy enterprise systems, web services (SOAP), and configuration files.

### XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
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

### XML Terminology

| Term       | Description                                        | Example                  |
|------------|----------------------------------------------------|--------------------------|
| Root       | Top-level parent element                           | `<ROWSET>`               |
| Tag        | Opening and closing markers around an element      | `<EMPNO>...</EMPNO>`     |
| Element    | A node within the XML tree                         | `<ROW>`, `<EMPNO>`       |
| ROWSET     | Common root name for a set of rows                 | `<ROWSET>`               |
| ROW        | A single record within ROWSET                      | `<ROW>...</ROW>`         |

---

## 2. How Snowflake Processes XML

Like JSON and Parquet, XML files read from a stage have **only one column** (`$1`). The entire XML document comes through as a single value.

When Snowflake reads XML, it internally converts it to a **JSON-like structure** for processing.

### Reading XML from Stage

```sql
-- Verify file exists
LIST @XML_STAGE;
-- emp_sample.xml.gz

-- Read raw XML (single column)
SELECT $1
FROM @XML_STAGE
(FILE_FORMAT => 'XML_FORMAT');
```

### Getting the Root Name

```sql
-- Get the root element name
SELECT $1:@  -- Returns root name: "ROWSET"
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');
```

The `@` symbol returns the **tag name** (root/element name).

```sql
-- Get the content (the elements inside the root) as an array
SELECT $1:$
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');
-- Returns an array of ROW elements
```

The `$` symbol returns the **value/content** of an element.

---

## 3. The XMLGET Function

`XMLGET` extracts a specific element from an XML structure by tag name and position.

### Syntax

```sql
XMLGET(xml_value, 'tag_name', position)
```

- `xml_value`: The XML input (usually `$1` from stage or a column)
- `'tag_name'`: The element tag to find
- `position`: Zero-based index (0 = first occurrence, 1 = second, etc.)

### Example — Extract First ROW

```sql
SELECT
    XMLGET($1, 'ROW', 0) AS FIRST_ROW
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT')
WHERE METADATA$FILENAME LIKE '%emp_sample%';
```

This returns the first `<ROW>` element as a JSON-like object.

### Example — Extract Second ROW

```sql
SELECT
    XMLGET($1, 'ROW', 1) AS SECOND_ROW
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT')
WHERE METADATA$FILENAME LIKE '%emp_sample%';
```

---

## 4. Extracting Field Values from XML

To get individual field values from inside a `<ROW>` element:

### Step 1: Get the ROW element

```sql
XMLGET($1, 'ROW', 0)
-- Returns: {"@":"ROW", "$":[{"@":"EMPNO","$":"7369"}, {"@":"ENAME","$":"Kiran"}, ...]}
```

### Step 2: Get a Specific Field Using XMLGET

Apply XMLGET again on the result of the first XMLGET:

```sql
-- Get EMPNO from first row
SELECT
    XMLGET(XMLGET($1, 'ROW', 0), 'EMPNO'):$::NUMBER AS EMP_NUMBER
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT')
WHERE METADATA$FILENAME LIKE '%emp_sample%';
```

The `:$` extracts the **value** of the element.

### Full Multi-Column Extraction

```sql
SELECT
    XMLGET(XMLGET($1, 'ROW', 0), 'EMPNO'):$::NUMBER   AS EMP_NUMBER,
    XMLGET(XMLGET($1, 'ROW', 0), 'ENAME'):$::VARCHAR  AS EMP_NAME,
    XMLGET(XMLGET($1, 'ROW', 0), 'JOB'):$::VARCHAR    AS JOB,
    XMLGET(XMLGET($1, 'ROW', 0), 'MGR'):$::NUMBER     AS MANAGER,
    XMLGET(XMLGET($1, 'ROW', 0), 'HIREDATE'):$::DATE  AS HIRE_DATE,
    XMLGET(XMLGET($1, 'ROW', 0), 'SAL'):$::NUMBER     AS SALARY,
    XMLGET(XMLGET($1, 'ROW', 0), 'COMM'):$::NUMBER    AS COMMISSION,
    XMLGET(XMLGET($1, 'ROW', 0), 'DEPTNO'):$::NUMBER  AS DEPT_NUMBER
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT')
WHERE METADATA$FILENAME LIKE '%emp_sample%';
```

### Using UNION ALL for Multiple Records

For files with 2 records:

```sql
-- First record (position 0)
SELECT
    XMLGET(XMLGET($1, 'ROW', 0), 'EMPNO'):$::NUMBER AS EMP_NUMBER,
    XMLGET(XMLGET($1, 'ROW', 0), 'ENAME'):$::VARCHAR AS EMP_NAME
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT')

UNION ALL

-- Second record (position 1)
SELECT
    XMLGET(XMLGET($1, 'ROW', 1), 'EMPNO'):$::NUMBER AS EMP_NUMBER,
    XMLGET(XMLGET($1, 'ROW', 1), 'ENAME'):$::VARCHAR AS EMP_NAME
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');
```

This approach is limited — you need as many `UNION ALL` clauses as records in the file.

---

## 5. Better Approach: LATERAL FLATTEN for XML

For XML with multiple records, the optimal approach uses LATERAL FLATTEN on the array of ROW elements.

### Step 1: Get Array of Rows

```sql
SELECT $1:$
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');
-- Returns an array like: [{"@":"ROW","$":[...]}, {"@":"ROW","$":[...]}]
```

### Step 2: Apply LATERAL FLATTEN

```sql
SELECT b.VALUE
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:$) AS b;
-- Returns one row per ROW element (14 rows for 14 employees)
```

### Step 3: Extract Fields from Each Row

```sql
SELECT
    XMLGET(b.VALUE, 'EMPNO'):$::NUMBER   AS EMP_NUMBER,
    XMLGET(b.VALUE, 'ENAME'):$::VARCHAR  AS EMP_NAME,
    XMLGET(b.VALUE, 'JOB'):$::VARCHAR    AS JOB,
    XMLGET(b.VALUE, 'MGR'):$::NUMBER     AS MANAGER,
    XMLGET(b.VALUE, 'HIREDATE'):$::DATE  AS HIRE_DATE,
    XMLGET(b.VALUE, 'SAL'):$::NUMBER     AS SALARY,
    XMLGET(b.VALUE, 'COMM'):$::NUMBER    AS COMMISSION,
    XMLGET(b.VALUE, 'DEPTNO'):$::NUMBER  AS DEPT_NUMBER
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:$) AS b
WHERE METADATA$FILENAME LIKE '%emp_sample%';
```

This works for **any number of records** without needing UNION ALL!

---

## 6. Handling Single-Record XML Files

If the XML file has only **one record**, `$1:$` does NOT return an array — it returns a single object. LATERAL FLATTEN requires an array as input.

**Problem:**

```sql
-- File with single record: NOT an array
SELECT $1:$
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT')
WHERE METADATA$FILENAME LIKE '%single_record%';
-- Returns: {"@":"EMPNO","$":"7369"} — not an array!
```

**Solution: Use TO_ARRAY()**

```sql
SELECT b.VALUE
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => TO_ARRAY(a.$1:$)) AS b
WHERE METADATA$FILENAME LIKE '%single_record%';
```

`TO_ARRAY()` wraps the single object in an array so LATERAL FLATTEN can process it.

---

## 7. Loading XML into a Table

### Create the EMP Table

```sql
CREATE TABLE EMP (
    EMP_NUMBER  NUMBER,
    EMP_NAME    VARCHAR,
    JOB         VARCHAR,
    MANAGER     NUMBER,
    HIRE_DATE   DATE,
    SALARY      NUMBER,
    COMMISSION  NUMBER,
    DEPT_NUMBER NUMBER
);
```

### Use INSERT INTO (Not COPY INTO) for Complex XML

```sql
INSERT INTO EMP
SELECT
    XMLGET(b.VALUE, 'EMPNO'):$::NUMBER,
    XMLGET(b.VALUE, 'ENAME'):$::VARCHAR,
    XMLGET(b.VALUE, 'JOB'):$::VARCHAR,
    XMLGET(b.VALUE, 'MGR'):$::NUMBER,
    XMLGET(b.VALUE, 'HIREDATE'):$::DATE,
    XMLGET(b.VALUE, 'SAL'):$::NUMBER,
    XMLGET(b.VALUE, 'COMM'):$::NUMBER,
    XMLGET(b.VALUE, 'DEPTNO'):$::NUMBER
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:$) AS b
WHERE METADATA$FILENAME LIKE '%emp_sample%';
```

> **Important:** COPY INTO does not support complex functions like XMLGET or LATERAL FLATTEN. Use `INSERT INTO ... SELECT` for XML processing.

---

## 8. Books XML Example

### File: books_sample.xml

```xml
<catalog>
    <book id="bk001">
        <author>Gambardella, Matthew</author>
        <title>XML Developer's Guide</title>
        <genre>Computer</genre>
        <price>44.95</price>
        <publish_date>2000-10-01</publish_date>
        <description>An in-depth look at creating XML applications.</description>
    </book>
    <book id="bk002">
        <author>Ralls, Kim</author>
        <title>Midnight Rain</title>
        <genre>Fantasy</genre>
        <price>5.95</price>
        <publish_date>2000-12-16</publish_date>
        <description>A former architect battles corporate zombies.</description>
    </book>
</catalog>
```

### Processing the Books XML

```sql
-- Upload
-- PUT file://C:/files/books_sample.xml @XML_STAGE; (via SnowSQL)

-- Create table
CREATE TABLE BOOKS (
    ID           VARCHAR,
    AUTHOR       VARCHAR,
    TITLE        VARCHAR,
    GENRE        VARCHAR,
    PRICE        NUMBER,
    PUBLISH_DATE DATE,
    DESCRIPTION  VARCHAR
);

-- Load data using LATERAL FLATTEN
INSERT INTO BOOKS
SELECT
    b.VALUE:@id::VARCHAR           AS ID,
    XMLGET(b.VALUE, 'author'):$::VARCHAR    AS AUTHOR,
    XMLGET(b.VALUE, 'title'):$::VARCHAR     AS TITLE,
    XMLGET(b.VALUE, 'genre'):$::VARCHAR     AS GENRE,
    XMLGET(b.VALUE, 'price'):$::NUMBER      AS PRICE,
    XMLGET(b.VALUE, 'publish_date'):$::DATE AS PUBLISH_DATE,
    XMLGET(b.VALUE, 'description'):$::VARCHAR AS DESCRIPTION
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:$) AS b
WHERE METADATA$FILENAME LIKE '%books_sample%';
```

---

## 9. XML vs JSON Notation Comparison

| Operation                    | JSON                             | XML                                      |
|------------------------------|----------------------------------|------------------------------------------|
| Get root name                | N/A (no root concept)            | `$1:@`                                   |
| Get content                  | `$1` directly                    | `$1:$`                                   |
| Get attribute                | N/A                              | `element:@attribute_name`                |
| Get element value            | `$1:key_name`                    | `XMLGET($1, 'tag_name'):$`               |
| Get by position              | `$1:array[0]`                    | `XMLGET($1, 'tag_name', position)`       |
| Flatten array                | `LATERAL FLATTEN(INPUT => a.$1:array_key)` | `LATERAL FLATTEN(INPUT => a.$1:$)` |

---

## 10. Creating the XML File Format

```sql
CREATE FILE FORMAT XML_FORMAT
    TYPE = 'XML';
```

That's all that's needed — no additional parameters required for XML.

---

## 11. Overwriting Existing Files in Stage

When you modify and re-upload an existing file:

```bash
# In SnowSQL, use OVERWRITE = TRUE to replace existing file
PUT file://C:/files/emp_sample.xml @XML_STAGE OVERWRITE = TRUE;
```

Without `OVERWRITE = TRUE`, Snowflake skips files that already exist in the stage.

---

## 12. Key Commands Summary

```sql
-- Create XML file format
CREATE FILE FORMAT XML_FORMAT TYPE = 'XML';

-- Verify stage contents
LIST @XML_STAGE;

-- Read XML (single column $1)
SELECT $1 FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');

-- Get root name
SELECT $1:@ FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');

-- Get root content as array
SELECT $1:$ FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');

-- Extract record by position
SELECT XMLGET($1, 'ROW', 0)
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');

-- Extract field value
SELECT XMLGET(XMLGET($1, 'ROW', 0), 'EMPNO'):$::NUMBER AS EMP_NUMBER
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT');

-- LATERAL FLATTEN for multiple records
SELECT
    XMLGET(b.VALUE, 'EMPNO'):$::NUMBER  AS EMP_NUMBER,
    XMLGET(b.VALUE, 'ENAME'):$::VARCHAR AS EMP_NAME
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:$) AS b;

-- Single-record XML (use TO_ARRAY)
SELECT b.VALUE
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => TO_ARRAY(a.$1:$)) AS b;

-- INSERT (for complex XML transformations)
INSERT INTO EMP
SELECT XMLGET(b.VALUE, 'EMPNO'):$::NUMBER, ...
FROM @XML_STAGE (FILE_FORMAT => 'XML_FORMAT') AS a,
     LATERAL FLATTEN(INPUT => a.$1:$) AS b;

-- GET_DDL to view object creation script
SELECT GET_DDL('TABLE', 'EMP');

-- Overwrite file in stage (SnowSQL)
-- PUT file://path/file.xml @XML_STAGE OVERWRITE = TRUE;
```

---

## 13. Key Terms

| Term          | Definition                                                                       |
|---------------|----------------------------------------------------------------------------------|
| XML           | Extensible Markup Language — tag-based semi-structured format                    |
| Root          | Top-level element in an XML document (e.g., `<ROWSET>`, `<catalog>`)             |
| Tag           | Element markers in XML: opening `<TAG>` and closing `</TAG>`                     |
| ROWSET        | Common XML root element name for a collection of rows                            |
| XMLGET        | Snowflake function to extract an XML element by tag name and position             |
| `:@`          | Syntax to get the tag name (key) of an XML element                               |
| `:$`          | Syntax to get the value (content) of an XML element                              |
| LATERAL FLATTEN | Table function to expand XML/JSON arrays into rows                             |
| TO_ARRAY()    | Function to wrap a single value in an array (needed for single-record XML files) |
| GET_DDL()     | Function returning the creation script of any Snowflake object                   |

---

## 14. Summary

- XML uses **tags** (opening and closing) to structure data in a tree
- When read from a stage, XML is a **single column** (`$1`)
- `$1:@` gives the **root name**; `$1:$` gives the **root content** (as an array of child elements)
- `XMLGET(xml, 'tag_name', position)` extracts a specific element by name and zero-based position
- `XMLGET(element, 'field_name'):$` extracts the **value** of a sub-element
- `LATERAL FLATTEN(INPUT => a.$1:$)` expands the array of XML elements into individual rows — works for any number of records
- For **single-record XML**, use `TO_ARRAY()` to convert the single element to an array before using LATERAL FLATTEN
- Use `INSERT INTO ... SELECT` (not `COPY INTO`) for complex XML transformations involving XMLGET and LATERAL FLATTEN
- The XML file format is created with just `TYPE = 'XML'`
