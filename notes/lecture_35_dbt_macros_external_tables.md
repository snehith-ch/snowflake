# Lecture 35: DBT Macros, Jinja Templating, and External Tables

## Overview
This lecture covers DBT macros — reusable Jinja SQL functions that automate repetitive SQL patterns. Two practical macro examples are built: one that auto-generates `GROUP BY 1, 2, 3` clauses, and one that transforms column values using a `CASE WHEN` expression. Snowflake's `SPLIT_PART` function is also covered, along with a refresher on external tables and insert-only streams.

---

## 1. What Are DBT Macros?

A **macro** is a reusable piece of SQL logic written using Jinja templating. Macros are stored in the `macros/` folder of a DBT project.

**Macros are similar to:**
- Snowflake Stored Procedures / User-Defined Functions (UDFs)
- Python functions
- SQL template functions

**Built-in DBT macros you already know:**
- `{{ ref('model_name') }}` — references another model
- `{{ config(materialized='table') }}` — sets model materialization

---

## 2. Jinja Templating Basics

DBT uses Jinja2 templating engine to add logic to SQL.

| Jinja Syntax | Purpose |
|---|---|
| `{{ expression }}` | Print/output the value of an expression |
| `{% statement %}` | Control flow (for loops, if/else) |
| `{# comment #}` | Comment (not rendered) |
| `{{ macro_name(args) }}` | Call a macro |

### Jinja Control Structures

```jinja
{# If/Else #}
{% if condition %}
    ...
{% elif other_condition %}
    ...
{% else %}
    ...
{% endif %}

{# For Loop #}
{% for i in range(1, n+1) %}
    {{ i }}{% if not loop.last %}, {% endif %}
{% endfor %}
```

---

## 3. Macro Syntax Structure

```sql
{# macros/my_macro.sql #}
{% macro macro_name(param1, param2) %}

    -- Your SQL or Jinja logic here

{% endmacro %}
```

### Calling a Macro Inside a Model
```sql
{{ macro_name(arg1, arg2) }}
```

---

## 4. Example 1: `group_by` Macro

### Problem
When writing queries with many columns, typing `GROUP BY col1, col2, col3, ...` is tedious. If you could use positional notation `GROUP BY 1, 2, 3`, it would be simpler. But with 50 columns, you still need to type all 50 numbers.

### Solution: A Macro That Generates GROUP BY Automatically

```sql
{# macros/group_by.sql #}
{% macro group_by(n) %}

    GROUP BY
    {% for i in range(1, n + 1) %}
        {{ i }}{% if not loop.last %}, {% endif %}
    {% endfor %}

{% endmacro %}
```

### How It Works

| Input (`n`) | Output |
|---|---|
| `3` | `GROUP BY 1, 2, 3` |
| `5` | `GROUP BY 1, 2, 3, 4, 5` |
| `10` | `GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10` |

### Using the Macro in a Model

```sql
{# models/customer_orders_info.sql #}
SELECT
    c.c_custkey,
    c.c_name,
    n.n_nationkey,
    SUM(o.o_totalprice) AS total_price
FROM DEV_DB.DEV_SCHEMA.T_CUSTOMERS c
JOIN DEV_DB.DEV_SCHEMA.T_ORDERS    o ON c.c_custkey = o.o_custkey
GROUP BY 1, 2, 3
```

Or use the macro:
```sql
SELECT
    c.c_custkey,
    c.c_name,
    n.n_nationkey,
    SUM(o.o_totalprice) AS total_price
FROM DEV_DB.DEV_SCHEMA.T_CUSTOMERS c
JOIN DEV_DB.DEV_SCHEMA.T_ORDERS    o ON c.c_custkey = o.o_custkey
{{ group_by(3) }}
```

### What DBT Compiles It To
```sql
SELECT
    c.c_custkey,
    c.c_name,
    n.n_nationkey,
    SUM(o.o_totalprice) AS total_price
FROM DEV_DB.DEV_SCHEMA.T_CUSTOMERS c
JOIN DEV_DB.DEV_SCHEMA.T_ORDERS    o ON c.c_custkey = o.o_custkey
GROUP BY
    1 ,
    2 ,
    3
```

---

## 5. Example 2: `new_segment` Macro (CASE WHEN Logic)

### Problem
Marketing segment values in the customer table (`machinery`, `automobile`, `household`, `building`, `furniture`) need to be grouped into broader categories.

```sql
-- Distinct marketing segments
SELECT DISTINCT c_mktsegment FROM T_CUSTOMERS;
-- MACHINERY, AUTOMOBILE, HOUSEHOLD, BUILDING, FURNITURE
```

### Solution: A Macro That Generates a CASE Statement

```sql
{# macros/new_segment.sql #}
{% macro new_segment(column_name) %}

    CASE
        WHEN {{ column_name }} IN ('MACHINERY', 'AUTOMOBILE') THEN 'Mission Segment'
        WHEN {{ column_name }} IN ('HOUSEHOLD', 'BUILDING', 'FURNITURE') THEN 'House Segment'
        ELSE 'Other'
    END

{% endmacro %}
```

### Using the Macro in a Model

```sql
{# models/new_marketing_segment.sql #}
SELECT
    c_custkey,
    c_mktsegment,
    {{ new_segment('c_mktsegment') }} AS new_marketing_segment
FROM DEV_DB.DEV_SCHEMA.T_CUSTOMERS
```

### Compiled Output
```sql
SELECT
    c_custkey,
    c_mktsegment,
    CASE
        WHEN c_mktsegment IN ('MACHINERY', 'AUTOMOBILE') THEN 'Mission Segment'
        WHEN c_mktsegment IN ('HOUSEHOLD', 'BUILDING', 'FURNITURE') THEN 'House Segment'
        ELSE 'Other'
    END AS new_marketing_segment
FROM DEV_DB.DEV_SCHEMA.T_CUSTOMERS
```

### Running the Model
```bash
dbt run --select new_marketing_segment
```

---

## 6. DBT `compile` and `preview`

Before running, you can verify the generated SQL:

| DBT Cloud Action | Description |
|---|---|
| **Compile** | Shows the generated SQL without executing |
| **Preview** | Executes and shows the result in the IDE |

In DBT Cloud IDE:
- Click **Compile** button to see what SQL the model generates.
- Click **Preview** to run and see sample results.

---

## 7. Snowflake `SPLIT_PART` Function

`SPLIT_PART` splits a string by a delimiter and returns the element at a specified position.

### Syntax
```sql
SPLIT_PART(string, delimiter, position)
```

### Examples

```sql
-- Full name: 'John Michael Smith'
SELECT SPLIT_PART('John Michael Smith', ' ', 1);  -- Returns: John
SELECT SPLIT_PART('John Michael Smith', ' ', 2);  -- Returns: Michael
SELECT SPLIT_PART('John Michael Smith', ' ', 3);  -- Returns: Smith

-- Email: 'user@company.com'
SELECT SPLIT_PART('user@company.com', '@', 1);    -- Returns: user
SELECT SPLIT_PART('user@company.com', '@', 2);    -- Returns: company.com

-- Date string: '2025-05-09'
SELECT SPLIT_PART('2025-05-09', '-', 1);          -- Returns: 2025
SELECT SPLIT_PART('2025-05-09', '-', 2);          -- Returns: 05
SELECT SPLIT_PART('2025-05-09', '-', 3);          -- Returns: 09
```

### Using in a DBT Model
```sql
SELECT
    customer_name,
    SPLIT_PART(customer_name, ' ', 1) AS first_name,
    SPLIT_PART(customer_name, ' ', 2) AS last_name
FROM {{ ref('t_customers') }}
```

---

## 8. Creating Tables in DBT Models

To create a model as a table (not view), use `config`:

```sql
{{ config(materialized='table') }}

SELECT
    c.c_custkey,
    c.c_name
FROM DEV_DB.DEV_SCHEMA.T_CUSTOMERS c
LIMIT 100
```

Note: DBT creates Snowflake tables as **TRANSIENT** tables by default (no fail-safe, lower storage cost).

To create a permanent table (with fail-safe):
```yaml
# dbt_project.yml
models:
  my_project:
    snowflake_options:
      transient: false
```

---

## 9. External Tables and Insert-Only Streams — Recap

### External Table
Reads data from an S3 stage without storing it in Snowflake.

```sql
-- Create file format
CREATE FILE FORMAT CSV_FORMAT
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create external table
CREATE EXTERNAL TABLE EXT_EMP (
    emp_no    NUMBER  AS (VALUE:c1::NUMBER),
    emp_name  VARCHAR AS (VALUE:c2::VARCHAR),
    salary    NUMBER  AS (VALUE:c6::NUMBER)
)
    LOCATION    = @S3_CSV_STAGE
    FILE_FORMAT = CSV_FORMAT;
```

### Insert-Only Stream on External Table
Standard streams track INSERT/UPDATE/DELETE. External tables only have inserts (files are added). Therefore, only **insert-only streams** work on external tables.

```sql
-- FAILS: Standard stream on external table
CREATE STREAM STD_STREAM ON TABLE EXT_EMP;
-- Error: Stream of type insert-only must be on external table

-- WORKS: Insert-only stream
CREATE STREAM INSERT_STREAM
    ON EXTERNAL TABLE EXT_EMP
    INSERT_ONLY = TRUE;
```

Consuming the stream:
```sql
SELECT * FROM INSERT_STREAM;
-- Shows new rows added since last stream consumption
```

---

## 10. DBT `EXCLUDE` Column Shortcut in Snowflake

When querying external tables, a `VALUE` metadata column is included. Snowflake's `EXCLUDE` keyword removes specific columns:

```sql
-- Standard query (includes VALUE column)
SELECT * FROM EXT_EMP;

-- Exclude VALUE column
SELECT * EXCLUDE value FROM EXT_EMP;

-- Exclude multiple columns
SELECT * EXCLUDE (value, created_at) FROM EXT_EMP;
```

This works in any Snowflake SELECT — not just external tables.

---

## 11. Complete DBT Macro Project Structure

```
my_dbt_project/
├── macros/
│   ├── group_by.sql          ← group_by(n) macro
│   └── new_segment.sql       ← new_segment(column) macro
├── models/
│   ├── t_customer.sql        ← source model
│   ├── t_orders.sql          ← source model
│   ├── customer_orders_info.sql   ← uses group_by macro
│   └── new_marketing_segment.sql  ← uses new_segment macro
├── seeds/
├── snapshots/
└── dbt_project.yml
```

---

## 12. Key Commands

| Command | Description |
|---|---|
| `dbt run --select model_name` | Run a specific model |
| `dbt run` | Run all models |
| `{{ macro_name(args) }}` | Call a macro inside a model |
| `{% macro name(params) %} ... {% endmacro %}` | Define a macro |
| `{% for i in range(1, n+1) %}` | Jinja for loop |
| `{% if not loop.last %}, {% endif %}` | Conditional comma in loop |
| `SPLIT_PART(str, delim, pos)` | Split a string by delimiter |
| `SELECT * EXCLUDE col FROM table` | Select all columns except specified |

---

## Summary

- **DBT Macros** are reusable Jinja SQL templates stored in the `macros/` folder — similar to functions or stored procedures.
- The `group_by(n)` macro demonstrates a for loop that generates `GROUP BY 1, 2, 3, ..., n` automatically.
- The `new_segment(column_name)` macro generates a `CASE WHEN` expression from a parameterized column name.
- `{{ macro_name(args) }}` calls a macro; `{% macro name(params) %} ... {% endmacro %}` defines one.
- `loop.last` is a Jinja loop variable that is `True` on the final iteration — used to avoid a trailing comma.
- DBT's `ref()` and `config()` are themselves macros provided by DBT Core.
- Snowflake's `SPLIT_PART(string, delimiter, position)` extracts a part of a string — useful for name parsing, email splitting, date components.
- External tables read from S3 stages without storing data in Snowflake — ideal for infrequently changing reference data.
- Only **insert-only streams** (`INSERT_ONLY = TRUE`) can be created on external tables.
- Use `SELECT * EXCLUDE column_name FROM table` to omit specific columns without listing all others.
