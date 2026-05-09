# Practice Set 7: DBT and Python Connector

> **Topics Covered**: DBT Cloud, DBT Core, Models, Seeds, Snapshots, Macros, Python Connector
> **Related Lectures**: Lecture 23, 24, 25, 26, 27, 28, 29, 35

---

## PART A: DBT (Data Build Tool)

---

## Background: What is DBT?

DBT is a **transformation tool** that lets you write SQL models and manage data transformations.

```
Source Data (Snowflake Tables/Views)
          ↓ DBT Models (SQL files)
Target Tables/Views in Snowflake
```

**Two versions**:
- **DBT Cloud**: Web-based IDE at cloud.getdbt.com (free trial available)
- **DBT Core**: Command-line tool, runs locally

---

## Section 1: DBT Core — Setup (Reference)

### Step-by-Step Setup

```bash
# 1. Install Anaconda (Python environment manager)
# Download from: anaconda.com

# 2. Open Anaconda Prompt and create a new environment
conda create -n dbt_project python=3.12
conda activate dbt_project

# 3. Install dbt-snowflake package
pip install dbt-snowflake

# 4. Initialize a new dbt project
dbt init my_project
# Answer the prompts: choose snowflake as the database

# 5. Verify setup
cd my_project
dbt debug  # Should say: All checks passed!

# 6. Open in VS Code
code .
```

---

### DBT Project File Structure

```
my_project/
├── dbt_project.yml          ← Main config file
├── profiles.yml             ← Connection details (in ~/.dbt/)
├── models/
│   ├── staging/
│   │   └── stg_employees.sql
│   └── marts/
│       └── dim_employees.sql
├── seeds/
│   └── employees.csv        ← CSV file to load as table
├── snapshots/
│   └── orders_snapshot.sql  ← SCD Type 2 tracking
├── macros/
│   └── my_macro.sql         ← Reusable Jinja functions
└── tests/
    └── schema.yml           ← Test definitions
```

---

## Section 2: DBT Models

### Exercise 2.1 — Create a Simple Model

Models are `.sql` files in the `models/` folder.

```sql
-- File: models/stg_employees.sql
-- This creates a VIEW in Snowflake by default

SELECT 
    emp_id,
    UPPER(emp_name)  AS emp_name,
    department,
    salary,
    hire_date
FROM {{ source('raw_data', 'employees') }}
WHERE is_active = TRUE
```

**Run the model**:
```bash
dbt run --select stg_employees
```

---

### Exercise 2.2 — Materialization Types

```sql
-- Create as a VIEW (default)
{{ config(materialized='view') }}
SELECT * FROM source_table;

-- Create as a TABLE
{{ config(materialized='table') }}
SELECT * FROM source_table;

-- Create as INCREMENTAL (only process new records)
{{ config(
    materialized='incremental',
    unique_key='emp_id'
) }}
SELECT * FROM source_table
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

**Questions**:
1. What is the difference between `materialized='view'` and `materialized='table'`?
   - View: _______________
   - Table: _______________

2. When would you use `materialized='incremental'`?
   - Answer: _______________

---

### Exercise 2.3 — Referencing Other Models

```sql
-- File: models/mart_employees.sql
-- Reference stg_employees model using {{ ref() }}

{{ config(materialized='table') }}

SELECT 
    e.emp_id,
    e.emp_name,
    e.department,
    e.salary,
    -- Categorize salary
    CASE 
        WHEN e.salary >= 80000 THEN 'High'
        WHEN e.salary >= 60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM {{ ref('stg_employees') }} e   -- Reference to stg_employees model
```

```bash
# Run with dependencies
dbt run --select mart_employees+  # Run mart_employees and all models it depends on
```

---

## Section 3: DBT Seeds

Seeds load CSV files into Snowflake tables.

### Exercise 3.1 — Using Seeds

```bash
# Place your CSV in seeds/ folder
# seeds/departments.csv:
```

```csv
dept_id,dept_name,location,budget
1,Engineering,Hyderabad,5000000
2,Marketing,Mumbai,2000000
3,Finance,Delhi,3000000
4,HR,Bengaluru,1000000
```

```bash
# Load seed to Snowflake
dbt seed

# Load specific seed
dbt seed --select departments
```

**Key points**:
- Seeds always create **TABLES** (not views)
- Good for static lookup data or test data
- The table name = the CSV filename

---

## Section 4: DBT Snapshots (SCD Type 2)

Snapshots capture changes over time — like SCD Type 2 in data warehousing.

### Exercise 4.1 — Create a Snapshot

```sql
-- File: snapshots/employees_snapshot.sql

{% snapshot employees_snapshot %}

{{ config(
    target_schema='snapshots',
    unique_key='emp_id',
    strategy='timestamp',
    updated_at='updated_at'
) }}

SELECT * FROM {{ ref('stg_employees') }}

{% endsnapshot %}
```

```bash
# Run snapshot
dbt snapshot
```

**Snapshot adds these columns automatically**:
| Column | Description |
|--------|-------------|
| `dbt_scd_id` | Unique ID for the record |
| `dbt_updated_at` | When the record was last changed |
| `dbt_valid_from` | When this version became active |
| `dbt_valid_to` | When this version was superseded (NULL = current) |

---

## Section 5: DBT Macros

Macros are **reusable Jinja functions** in DBT.

### Exercise 5.1 — Create and Use a Macro

```sql
-- File: macros/generate_schema_name.sql

{% macro salary_band(salary_col) %}
    CASE 
        WHEN {{ salary_col }} >= 80000 THEN 'High'
        WHEN {{ salary_col }} >= 60000 THEN 'Medium'
        ELSE 'Low'
    END
{% endmacro %}
```

```sql
-- Use the macro in a model:
-- File: models/employees_with_band.sql

SELECT 
    emp_name,
    salary,
    {{ salary_band('salary') }} AS band    -- Call the macro
FROM {{ ref('stg_employees') }}
```

---

## Section 6: Pre-hook and Post-hook

Hooks run SQL **before** or **after** a model executes.

### Exercise 6.1 — Audit Logging with Hooks

```yaml
# In dbt_project.yml, add under models:
models:
  my_project:
    +pre-hook:
      - "INSERT INTO audit_log (run_time, model_name, status) VALUES (CURRENT_TIMESTAMP(), '{{ this.name }}', 'STARTED')"
    +post-hook:
      - "INSERT INTO audit_log (run_time, model_name, status) VALUES (CURRENT_TIMESTAMP(), '{{ this.name }}', 'COMPLETED')"
```

**Important**: Create the audit_log table first:
```sql
CREATE TABLE audit_log (
    run_time  TIMESTAMP_NTZ,
    model_name VARCHAR(100),
    status     VARCHAR(20)
);
```

---

## PART B: Python Connector

---

## Section 7: Python Setup

### Exercise 7.1 — Install and Connect

```bash
# Install the Snowflake Python connector
pip install snowflake-connector-python
```

```python
# File: snowflake_connection.py
import snowflake.connector

# Create connection
conn = snowflake.connector.connect(
    user='your_username',
    password='your_password',
    account='your_account_identifier',  # e.g., 'xy12345.us-east-1'
    warehouse='COMPUTE_WH',
    database='PRACTICE_DB',
    schema='PRACTICE_SCHEMA'
)

# Create cursor
cursor = conn.cursor()

# Execute a query
cursor.execute("SELECT CURRENT_USER(), CURRENT_DATABASE()")

# Fetch result
result = cursor.fetchone()
print(f"User: {result[0]}, Database: {result[1]}")

# Close connection
cursor.close()
conn.close()
```

---

### Exercise 7.2 — Run Queries from Python

```python
import snowflake.connector
import pandas as pd

conn = snowflake.connector.connect(
    user='your_username',
    password='your_password',
    account='your_account'
)

cursor = conn.cursor()

# Use context
cursor.execute("USE DATABASE practice_db")
cursor.execute("USE SCHEMA practice_schema")
cursor.execute("USE WAREHOUSE compute_wh")

# SELECT query
cursor.execute("SELECT emp_name, salary FROM employees WHERE salary > 70000")
rows = cursor.fetchall()

print("High earners:")
for row in rows:
    print(f"  {row[0]}: ₹{row[1]:,}")

# INSERT with parameters (safe from SQL injection)
new_emp = (9, 'New Employee', 'Engineering', 80000, '2024-01-01', 'new@email.com')
cursor.execute(
    "INSERT INTO employees (emp_id, emp_name, department, salary, hire_date, email) VALUES (%s, %s, %s, %s, %s, %s)",
    new_emp
)

# Load into Pandas DataFrame (requires snowflake-connector-python[pandas])
cursor.execute("SELECT * FROM employees")
df = cursor.fetch_pandas_all()
print(df.head())

cursor.close()
conn.close()
```

---

### Exercise 7.3 — Snowpark (Advanced Python)

```python
# Snowpark is a Python API for Snowflake (more powerful than connector)
# Install: pip install snowflake-snowpark-python

from snowflake.snowpark import Session

connection_parameters = {
    "account": "your_account",
    "user": "your_username",
    "password": "your_password",
    "role": "SYSADMIN",
    "warehouse": "COMPUTE_WH",
    "database": "PRACTICE_DB",
    "schema": "PRACTICE_SCHEMA"
}

session = Session.builder.configs(connection_parameters).create()

# Read a Snowflake table as a DataFrame
df = session.table("employees")

# Apply transformations (similar to PySpark)
from snowflake.snowpark.functions import col, avg

result = df.filter(col("department") == "Engineering") \
           .select("emp_name", "salary") \
           .sort("salary", ascending=False)

result.show()

session.close()
```

---

## Challenge Questions

### DBT Challenges

1. Write a model `high_value_orders.sql` that:
   - References a `stg_orders` model
   - Filters for orders where amount > 50000
   - Adds a column `order_tier` ('Gold' if > 100000, 'Silver' otherwise)
   - Is materialized as a TABLE

2. What command do you run to:
   a. Run all models: _______________
   b. Run only models that have changed: _______________
   c. Run a specific model and all models downstream: _______________
   d. Test all models: _______________

3. What is the difference between `{{ ref('model_name') }}` and `{{ source('source_name', 'table') }}`?
   - `ref`: _______________
   - `source`: _______________

### Python Challenges

4. Write Python code to:
   - Connect to Snowflake
   - Insert 3 new employees using a loop
   - Then SELECT all employees and print them

5. What is the difference between the **Snowflake Connector** and **Snowpark**?
   - Connector: _______________
   - Snowpark: _______________

## Answer Key

**DBT Challenge Q2**:
- a. `dbt run`
- b. `dbt run --select state:modified`
- c. `dbt run --select my_model+` (+ selects downstream models)
- d. `dbt test`

**DBT Challenge Q3**:
- `ref`: References another DBT model (managed by DBT)
- `source`: References a raw source table NOT managed by DBT
