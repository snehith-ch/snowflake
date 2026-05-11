# Lecture 25: DBT Core — Setup, Models, and Profiles

## Quick Revision — Lecture 25
| # | Key Point |
|---|-----------|
| 1 | DBT Core is installed locally; DBT Cloud is browser-based at dbt.com |
| 2 | Activate a conda environment with `conda activate <env_name>` before running dbt |
| 3 | `dbt debug` verifies the Snowflake connection — all checks must pass before running models |
| 4 | A **model** is just a `.sql` file in the `models/` folder |
| 5 | By default, running a model creates a **view** in Snowflake |
| 6 | To create a table instead, use `{{ config(materialized='table') }}` in the model file |
| 7 | To reference one model inside another, use `{{ ref('model_name') }}` |
| 8 | `dbt run --select model_name` runs one model; `dbt run` runs all models |
| 9 | `profiles.yml` lives at `~/.dbt/profiles.yml` and holds Snowflake connection details |
| 10 | The `target` key in `profiles.yml` defines the active environment (dev, prod, etc.) |

**Pre-requisite:** Lecture 24 — DBT Cloud setup and introduction
**Next:** Lecture 26 — DBT Seeds, Snapshots, and Hooks

---

## Objects Created in This Lecture
| Object Type | Name | Purpose |
|-------------|------|---------|
| Conda Environment | `dbt_project` | Isolated Python environment for dbt |
| Snowflake Table | `orders` | 99 records loaded from S3 public bucket |
| Snowflake Table | `customers` | 100 records loaded from S3 public bucket |
| Snowflake Table | `payment` | 120 records loaded from S3 public bucket |
| DBT Model (view) | `t_customer` | Wraps customer table data |
| DBT Model (view) | `t_orders` | Wraps orders table data |
| DBT Model (view/table) | `t_cust_order_report` | Joins 3 tables for customer order summary |

---

## ASCII Data Flow
```
CSV (S3 public bucket: dbt-tutorial-public)
        |
        | COPY INTO
        v
Snowflake tables (orders, customers, payment)
        |
        | DBT model (.sql file)
        v
DBT run command (dbt run --select model_name)
        |
        | creates
        v
Snowflake VIEW or TABLE (in target schema)
```

---

## 1. DBT Core vs DBT Cloud

| Feature | DBT Core | DBT Cloud |
|---|---|---|
| Installation | Local via pip/conda | Web UI (dbt.com) |
| GitHub Integration | Manual | Built-in |
| Scheduling | External tools (Airflow, cron) | Built-in Jobs |
| IDE | VS Code / terminal | Browser IDE |
| Cost | Free / open source | Free trial + paid tiers |
| Use case | Local dev, scripted workflows | Collaborative, production |
| Profiles file | `~/.dbt/profiles.yml` (local file) | Configured in UI |
| License needed | No | Yes (for production features) |

> **Instructor Note:** In real-time projects, most teams use DBT Cloud because it is more user-friendly, has built-in GitHub integration, and supports scheduling. DBT Core is used for local development and when there is no license budget.

---

## 2. Setting Up Anaconda and Conda Environments

### Why Use Conda?
Conda manages Python environments and packages. It keeps project dependencies isolated — each project can have its own Python version and package set without conflicts.

### Step 1: Install Anaconda
Download from [anaconda.com](https://www.anaconda.com/products/distribution) and install.

### Step 2: List Existing Environments
```bash
conda env list
```
Example output:
```
# conda environments:
#
base                  *  C:\Users\user\anaconda3
dbt_project              C:\Users\user\anaconda3\envs\dbt_project
```
The `*` indicates the currently active environment.

### Step 3: Activate a Conda Environment
```bash
conda activate dbt_project
```
After activation, the terminal prompt changes to show the active environment name:
```
(dbt_project) C:\Users\user>
```

> **Student Question:** What is the command to list all environments?
> **Answer:** `conda env list`

> **Student Question:** What is the command to switch/activate an environment?
> **Answer:** `conda activate <project_name>` — after this, the prompt prefix changes to show the active environment.

### Step 4: Install DBT for Snowflake
```bash
pip install dbt-snowflake
```
This installs both `dbt-core` and the Snowflake adapter in one command.

---

## 3. Initializing a DBT Project

### Command: `dbt init`
```bash
dbt init my_project
```
This creates the project folder structure:
```
my_project/
├── dbt_project.yml       ← project config (materialization, paths)
├── profiles.yml          ← connection config (goes to ~/.dbt/)
├── models/               ← .sql model files go here
│   └── example/
├── seeds/                ← CSV files to load as tables
├── snapshots/            ← SCD Type 2 change tracking
├── macros/               ← reusable Jinja SQL functions
├── tests/                ← data quality tests
└── target/               ← compiled SQL output (auto-generated)
```

### Command: `dbt debug`
Verifies all connections and configurations. Run this after setting up `profiles.yml`.
```bash
dbt debug
```
Expected output:
```
Running with dbt=1.x.x
Checking your connection to dbt...
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]
  Connection test: [OK connection ok]

All checks passed!
```

> **Instructor Emphasis:** Always run `dbt debug` first. If it says "All checks passed" you are good to go. If there is an error, fix the connection details in `profiles.yml` before trying to run any models.

---

## 4. Key Configuration Files

### `profiles.yml`
Located at `~/.dbt/profiles.yml` on your local machine. Stores database connection details.

```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account_identifier>   # e.g. nbhvhdc-wp31641
      user: <username>                     # e.g. krishna
      password: <password>
      role: SYSADMIN
      database: DEV_DB
      warehouse: COMPUTE_WH
      schema: DEV_SCHEMA
      threads: 4
      client_session_keep_alive: False
```

> **Important:** The `target` key maps to an output name (`dev`, `prod`, etc.). The `project` name in this file must match what is in `dbt_project.yml`.

> **Common Mistake from Class:** The instructor accidentally connected to the wrong Snowflake account. The account name in `profiles.yml` must exactly match the Snowflake URL. If you have created objects in `devdb` but `profiles.yml` points to a different account, the models will try to create objects in the wrong location.

> **Student Question:** Can we have multiple connections (e.g., one for Snowflake, one for Oracle) in the same profiles.yml?
> **Answer:** Yes. You can add multiple targets under `outputs`, each with different connection details. The `target:` key controls which one is active by default. You can also override at runtime with `dbt run --target prod`.

### `dbt_project.yml`
Defines project settings, model paths, and default materializations.

```yaml
name: 'my_project'
version: '1.0.0'
config-version: 2

profile: 'my_project'    # must match the name in profiles.yml

model-paths: ["models"]
seed-paths: ["seeds"]
snapshot-paths: ["snapshots"]
macro-paths: ["macros"]

target-path: "target"    # compiled SQL goes here

models:
  my_project:
    materialized: view      # default materialization = view
```

---

## 5. Opening VS Code from the Terminal

```bash
code .
```
Launches Visual Studio Code in the current project folder. This is how the instructor switched to the VS Code IDE to create model files.

---

## 6. Creating Source Tables in Snowflake (Class Demo)

Before creating models, the instructor created source tables by loading data from a public S3 bucket.

```sql
-- Step 1: Create file format
CREATE FILE FORMAT my_csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1;

-- Step 2: Create orders table
CREATE OR REPLACE TABLE orders (
    order_id    NUMBER,
    customer_id NUMBER,
    order_date  DATE,
    status      VARCHAR
);

-- Step 3: Load from public S3 bucket (no credentials needed — public bucket)
COPY INTO orders (order_id, customer_id, order_date, status)
FROM 's3://dbt-tutorial-public/jaffle_shop_orders.csv'
FILE_FORMAT = (FORMAT_NAME = my_csv_format);
-- Result: 99 records inserted

-- Step 4: Create customers table
CREATE OR REPLACE TABLE customers (
    customer_id NUMBER,
    first_name  VARCHAR,
    last_name   VARCHAR
);

COPY INTO customers (customer_id, first_name, last_name)
FROM 's3://dbt-tutorial-public/jaffle_shop_customers.csv'
FILE_FORMAT = (FORMAT_NAME = my_csv_format);
-- Result: 100 records inserted

-- Step 5: Create payment table
CREATE TABLE payment (
    id             NUMBER,
    orderid        NUMBER,
    paymentmethod  VARCHAR,
    status         VARCHAR,
    amount         NUMBER,
    created        DATE,
    _batched_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COPY INTO payment (id, orderid, paymentmethod, status, amount, created)
FROM 's3://dbt-tutorial-public/stripe_payments.csv'
FILE_FORMAT = (FORMAT_NAME = my_csv_format);
-- Result: 120 records inserted
```

> **Instructor Note:** The S3 bucket `dbt-tutorial-public` is a public bucket provided by DBT Labs for practice. Anyone can access it — no credentials required. This is the same data used in DBT's official tutorial.

---

## 7. DBT Models

A **model** is a `.sql` file in the `models/` folder. When executed, DBT runs the SQL and creates the result as a **view** or **table** in Snowflake.

> **Instructor Statement:** "Model is nothing but a SQL file. Yes, it's just a SQL file. You can write any SELECT statement inside it."

### Default Behavior: View
By default, every model creates a **view** in the target schema.

### Class Model 1: Simple Customer Model (`t_customer.sql`)
```sql
-- models/t_customer.sql
WITH c1 AS (
    SELECT * FROM dev_db.dev_schema.customers
)
SELECT * FROM c1
```

### Class Model 2: Orders Model (`t_orders.sql`)
```sql
-- models/t_orders.sql
WITH orders AS (
    SELECT * FROM dev_db.dev_schema.orders
)
SELECT * FROM orders
```

### Running a Specific Model
```bash
dbt run --select t_customer
```
The `--select` flag (with double hyphens) lets you run only one model.

> **Student Question:** Why do you use `--select` when running a specific model?
> **Answer:** Without `--select`, `dbt run` executes ALL models in the project. If you have 6 models and only want to run one, use `dbt run --select model_name`. This saves time.

> **Instructor Emphasis:** If you don't give `--select`, it will execute ALL models. I had 6 models and all 6 ran. That is why I explicitly specify the model name.

### Running All Models
```bash
dbt run
```

---

## 8. Materialization: View vs Table

### Method 1: Change in `dbt_project.yml` (applies to ALL models)
```yaml
models:
  my_project:
    materialized: table     # Change from "view" to "table"
```

### Method 2: Add Config Block Inside the Model File (overrides for that model only)
```sql
{{ config(materialized='table') }}

SELECT
    customer_id,
    first_name,
    last_name
FROM dev_db.dev_schema.customers
```

> **Instructor Statement:** "There are two ways to create an object as a table or view. One is you can change the `dbt_project.yml` file. The other way is to use `config(materialized='table')` inside the model. I think we already discussed that."

> **Exam Tip:** The `config()` block inside a model overrides the project-level setting. Model-level config always wins.

---

## 9. Referring One Model Inside Another (`ref()`)

The `ref()` function lets one model reference another model, creating a dependency graph.

> **Instructor Emphasis:** "This is one more important point — if you want to refer to a model inside another model, you need to use the `ref()` function."

```sql
-- File: t_cust_order_report.sql
WITH customers AS (
    SELECT * FROM {{ ref('t_customer') }}   -- references t_customer model
),
orders AS (
    SELECT * FROM {{ ref('t_orders') }}     -- references t_orders model
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    MIN(o.order_date)  AS first_order_date,
    MAX(o.order_date)  AS latest_order_date,
    COUNT(o.order_id)  AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
```

> **Important:** You cannot use `ref()` for a model that has not been executed yet. Always run the referenced model first, or run all models together (`dbt run`) so DBT manages dependency order automatically.

> **Student Question:** What is the advantage of using `ref()` instead of hardcoding the table/view name?
> **Answer:** Reusability. You can reuse the same model logic in multiple other models. Also, `ref()` tells DBT the dependency relationship — DBT uses this to run models in the correct order automatically.

---

## 10. Actual Class CTE Query (from Daily Notes.sql)

This is the exact SQL the instructor built to demonstrate the requirement before converting it to a DBT model:

```sql
-- The full business requirement: join 3 tables for customer order summary
WITH customers AS (
    SELECT
        customer_id,
        first_name,
        last_name
    FROM dev_db.dev_schema.customers
),
orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        status
    FROM dev_db.dev_schema.orders
),
customer_orders AS (
    SELECT
        customer_id,
        MIN(order_date)   AS first_order_date,
        MAX(order_date)   AS most_recent_order_date,
        COUNT(*)          AS number_of_orders
    FROM dev_db.dev_schema.orders
    GROUP BY 1
),
final AS (
    SELECT
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        COALESCE(customer_orders.number_of_orders, 0) AS number_of_orders
    FROM customers
    LEFT JOIN customer_orders ON customers.customer_id = customer_orders.customer_id
)
SELECT * FROM final;
```

---

## 11. How DBT Compiles a Model (target/ folder)

After running a model, DBT writes the compiled SQL to the `target/run/` folder. The instructor showed this in the class.

For a model with `materialized = 'view'`, the compiled output is:
```sql
CREATE OR REPLACE VIEW "DEV_DB"."DEV_SCHEMA"."T_CUSTOMER" AS (
    SELECT * FROM dev_db.dev_schema.customers
);
```

For a model with `materialized = 'table'`, the compiled output is:
```sql
CREATE OR REPLACE TRANSIENT TABLE "DEV_DB"."DEV_SCHEMA"."T_CUSTOMER" AS (
    SELECT * FROM dev_db.dev_schema.customers
);
```

> **Important:** DBT creates **transient tables** (not permanent tables) when materialization = 'table'. Transient tables have no fail-safe period, which reduces storage costs. This is intentional — DBT models can always be rebuilt by re-running.

---

## 12. Scheduling DBT Jobs

> **Student Question:** Can we schedule DBT models? Like running them at a specific time?
> **Answer (Instructor):** Yes. In DBT Cloud, go to **Deploy** → **Jobs** → create a new job → add commands (`dbt run`, `dbt snapshot`) → configure the schedule under the **Trigger** tab. You can set it to run daily, hourly, etc.

For DBT Core, you would use an external scheduler like:
- Apache Airflow
- Linux cron
- Windows Task Scheduler

---

## 13. Complete Step-by-Step Workflow

```
Step 1:  Install Anaconda
Step 2:  Open Anaconda Prompt
Step 3:  conda env list           (see available environments)
Step 4:  conda activate dbt_project   (activate project env)
Step 5:  pip install dbt-snowflake    (install dbt + snowflake adapter)
Step 6:  dbt init project_name        (create project structure)
Step 7:  Edit ~/.dbt/profiles.yml     (add Snowflake connection)
Step 8:  dbt debug                    (verify connection — all checks must pass)
Step 9:  code .                       (open VS Code in project folder)
Step 10: Create .sql files in models/ folder
Step 11: dbt run --select model_name  (run specific model)
Step 12: Verify in Snowflake          (check that view/table was created)
```

---

## 14. Key Commands

| Command | Description |
|---|---|
| `conda env list` | List all Conda environments |
| `conda activate <env_name>` | Activate a specific environment |
| `pip install dbt-snowflake` | Install DBT with Snowflake adapter |
| `dbt init <project_name>` | Initialize a new DBT project |
| `dbt debug` | Verify connection and configuration |
| `dbt run` | Run ALL models in the project |
| `dbt run --select <model_name>` | Run a single specific model |
| `dbt run --select <model_name>+` | Run model AND all downstream models that depend on it |
| `dbt run --select +<model_name>` | Run model AND all upstream models it depends on |
| `dbt run --select state:modified` | Run only models changed since last run |
| `code .` | Open VS Code in current directory |

---

## 15. Selective Model Run Patterns

### Run a Specific Model
```bash
dbt run --select t_customer
```

### Run Only Models That Changed Since the Last Run
```bash
dbt run --select state:modified
```
DBT compares the current state to previous run artifacts and only executes changed models.

### Run a Model AND Everything That Depends On It (Downstream)
```bash
dbt run --select t_customer+
```
The `+` suffix runs the model AND all models that `ref()` it.

### Run a Model AND Everything It Depends On (Upstream)
```bash
dbt run --select +t_cust_order_report
```

### Practical Selector Summary

| Selector | What It Runs |
|---|---|
| `t_customer` | Only `t_customer` |
| `t_customer+` | `t_customer` + all downstream models |
| `+t_report` | `t_report` + all upstream models |
| `+t_report+` | Everything upstream + `t_report` + everything downstream |
| `state:modified` | Only models changed since last `dbt run` |

---

## Key Differences Table: View vs Table Materialization

| Feature | View | Table |
|---|---|---|
| Storage cost | None (no data stored) | Yes (Snowflake stores data) |
| Query speed | Slower (re-runs SQL each time) | Faster (data already stored) |
| DBT default | Yes | No |
| How to set in model | `{{ config(materialized='view') }}` | `{{ config(materialized='table') }}` |
| How to set globally | `materialized: view` in project.yml | `materialized: table` in project.yml |
| DBT creates as | Regular view | **Transient** table |

---

## Common Errors Table

| Error Message | Cause | Fix |
|---|---|---|
| `profiles.yml file not found` | profiles.yml not created or wrong path | Create `~/.dbt/profiles.yml` with correct config |
| `Connection test failed` | Wrong account name, username, or password in profiles.yml | Verify the Snowflake account identifier and credentials |
| `Database 'devdb' does not exist` | profiles.yml points to wrong Snowflake account | Check `account:` value — it must match your Snowflake URL |
| `could not find relation` | Referenced table/view doesn't exist in the specified schema | Check database.schema.table in model SQL matches actual Snowflake location |
| `model 'X' not found` | Wrong model name in `--select` | File name in models/ must match what you pass to `--select` |
| `Compilation Error: missing semicolon` | Semicolon inside model SQL | Never put a semicolon at the end of a model's SELECT statement |
| `All checks passed!` | Success message from `dbt debug` | No fix needed — you are good to go |

---

## Interview Questions

> **Interview Question:** What is the difference between DBT Core and DBT Cloud?
> **Answer:** DBT Core is installed locally and is free/open source. DBT Cloud is a browser-based SaaS with built-in IDE, GitHub integration, job scheduling, and team collaboration features. In real time, most organizations use DBT Cloud for production.

> **Interview Question:** What is a DBT model?
> **Answer:** A model is a `.sql` file in the `models/` folder of a DBT project. When you run `dbt run`, DBT executes the SQL and materializes the result as a view (default) or table in the target database.

> **Interview Question:** How do you reference one DBT model inside another?
> **Answer:** Using the `{{ ref('model_name') }}` function. This creates a dependency relationship and ensures DBT runs the referenced model before the dependent model.

> **Interview Question:** Where does DBT store connection details for Snowflake?
> **Answer:** In `~/.dbt/profiles.yml`. This file contains the Snowflake account, username, password, database, warehouse, and schema. The `dbt_project.yml` references the profile name.

> **Interview Question:** What command verifies a DBT connection?
> **Answer:** `dbt debug`. It checks that both `profiles.yml` and `dbt_project.yml` are valid and that the Snowflake connection is successful. Output: "All checks passed!"

> **Interview Question:** What does `dbt run --select model_name+` do?
> **Answer:** It runs the specified model AND all downstream models that depend on it (via `ref()`). The `+` suffix means "and all models downstream."

> **Interview Question:** What type of Snowflake object does DBT create when materialization = 'table'?
> **Answer:** A **transient table**. DBT uses transient tables by default to avoid fail-safe storage costs, since models can always be rebuilt by re-running.

> **Interview Question:** What is the purpose of `dbt init`?
> **Answer:** It creates the project folder structure with `dbt_project.yml`, `models/`, `seeds/`, `snapshots/`, `macros/`, and `tests/` directories. It also prompts for the database connection type (Snowflake, Redshift, etc.).

---

## Try It Yourself Exercises

**Exercise 1:** Create your own customer model
- Create `models/my_customers.sql` that selects `customer_id`, `first_name`, `last_name` from the `customers` table.
- Run: `dbt run --select my_customers`
- Verify a view called `MY_CUSTOMERS` appeared in Snowflake.

**Exercise 2:** Change materialization to table
- Add `{{ config(materialized='table') }}` at the top of `my_customers.sql`.
- Run the model again.
- Verify it is now a **table** (not a view) in Snowflake.

**Exercise 3:** Create a model that uses ref()
- Create `models/my_orders.sql` selecting from `orders`.
- Create `models/my_report.sql` that references `{{ ref('my_customers') }}` and `{{ ref('my_orders') }}`.
- Run: `dbt run --select my_customers my_orders my_report`

**Exercise 4:** Verify the target folder
- After running a model, open the `target/run/` folder.
- Find the compiled `.sql` file for your model.
- Open it and observe the generated `CREATE OR REPLACE VIEW` or `CREATE OR REPLACE TRANSIENT TABLE` statement.

<details>
<summary>Hints and Answers</summary>

**Exercise 1 answer:**
```sql
-- models/my_customers.sql
SELECT customer_id, first_name, last_name
FROM dev_db.dev_schema.customers
```

**Exercise 3 answer (my_report.sql):**
```sql
-- models/my_report.sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM {{ ref('my_customers') }} c
JOIN {{ ref('my_orders') }} o ON c.customer_id = o.customer_id
GROUP BY 1, 2, 3
```
</details>
