# Lecture 28: DBT Pre/Post Hooks — Detailed Implementation and Audit Logging

## Overview
This lecture is a deep-dive into DBT pre/post hooks. It covers configuring hooks in `dbt_project.yml`, using `{{ this.name }}` to capture model names dynamically, verifying audit logs, running specific models, and understanding the difference between model-level hooks and run-level hooks (`on-run-start`/`on-run-end`). Secure views and materialized views are also covered.

---

## 1. Recap: What Are Pre/Post Hooks?

Hooks are SQL statements that DBT automatically executes:
- **`pre-hook`** — runs BEFORE each model's SQL executes.
- **`post-hook`** — runs AFTER each model's SQL executes.

**Primary Use Case:** Audit logging — tracking which models ran, when they started, and when they ended.

---

## 2. Step 1 — Create the Audit Log Table

This table must exist in Snowflake BEFORE any models run.

```sql
CREATE OR REPLACE TABLE PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (
    id           NUMBER AUTOINCREMENT START 1 INCREMENT 1 ORDER,
    audit_type   VARCHAR(50),
    model_name   VARCHAR(200),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

Column explanations:
- `id` — Auto-generated sequential number (using AUTOINCREMENT).
- `audit_type` — Either `'started'` or `'ended'`.
- `model_name` — The name of the DBT model being executed.
- `created_date` — Automatically populated with current timestamp.

---

## 3. Step 2 — Configure Hooks in `dbt_project.yml`

The hooks are defined inside the `models:` section, below the project name.

```yaml
name: 'my_project'
version: '1.0.0'
config-version: 2

profile: 'my_project'

models:
  my_project:
    materialized: view
    pre-hook:
      - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG
         (audit_type, model_name)
         VALUES ('started', '{{ this.name }}')"
    post-hook:
      - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG
         (audit_type, model_name)
         VALUES ('ended', '{{ this.name }}')"
```

> **Important syntax:** No semicolon at the end of the INSERT statement inside the hook string.

---

## 4. The `{{ this.name }}` Jinja Variable

| Variable | Returns |
|---|---|
| `{{ this }}` | Full relation: `"DEV_DB"."DEV_SCHEMA"."model_name"` |
| `{{ this.name }}` | Just the model name: `model_name` |
| `{{ this.schema }}` | Just the schema: `DEV_SCHEMA` |
| `{{ this.database }}` | Just the database: `DEV_DB` |

Example — capturing the full qualified name:
```yaml
pre-hook:
  - "INSERT INTO T_AUDIT_LOG (audit_type, model_name)
     VALUES ('started', '{{ this }}')"
```

---

## 5. Running Models and Verifying the Audit Log

### Run All Models
```bash
dbt run
```
This executes every model in the project. For each model, the sequence is:
1. `pre-hook` INSERT ("started")
2. Model SQL executes (creates view/table)
3. `post-hook` INSERT ("ended")

### Run a Specific Model
```bash
dbt run --select customer
dbt run --select orders
```

### Verifying the Audit Log in Snowflake
```sql
SELECT
    id,
    audit_type,
    model_name,
    created_date
FROM PROD_DB.PROD_SCHEMA.T_AUDIT_LOG
ORDER BY id;
```

Expected output (with models `customer` and `orders`):
```
ID | AUDIT_TYPE | MODEL_NAME | CREATED_DATE
---|-----------|------------|---------------------------
1  | started   | customer   | 2025-05-09 10:00:01.123
2  | ended     | customer   | 2025-05-09 10:00:03.456
3  | started   | orders     | 2025-05-09 10:00:03.789
4  | ended     | orders     | 2025-05-09 10:00:07.012
```

Calculating execution time:
```sql
SELECT
    model_name,
    MIN(CASE WHEN audit_type = 'started' THEN created_date END) AS start_time,
    MAX(CASE WHEN audit_type = 'ended'   THEN created_date END) AS end_time,
    DATEDIFF('second',
        MIN(CASE WHEN audit_type = 'started' THEN created_date END),
        MAX(CASE WHEN audit_type = 'ended'   THEN created_date END)
    ) AS duration_seconds
FROM T_AUDIT_LOG
GROUP BY model_name
ORDER BY start_time;
```

---

## 6. `on-run-start` and `on-run-end` Hooks

These run **once per `dbt run` command** — not per model. Useful for logging the overall run.

```yaml
on-run-start:
  - "INSERT INTO T_AUDIT_LOG (audit_type, model_name)
     VALUES ('run started', 'ALL_MODELS')"

on-run-end:
  - "INSERT INTO T_AUDIT_LOG (audit_type, model_name)
     VALUES ('run ended', 'ALL_MODELS')"
```

### Difference: Model Hooks vs Run Hooks

| Hook Type | Runs Per | Captures |
|---|---|---|
| `pre-hook` | Each model | Model-level start |
| `post-hook` | Each model | Model-level end |
| `on-run-start` | Once (entire dbt run) | Overall run start |
| `on-run-end` | Once (entire dbt run) | Overall run end |

---

## 7. Alternative Audit Table with Only Timing Information

If you only want to capture overall run timing without model names:

```sql
CREATE OR REPLACE TABLE T_DBT_RUN_LOG (
    id           NUMBER AUTOINCREMENT,
    run_type     VARCHAR(50),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

```yaml
on-run-start:
  - "INSERT INTO T_DBT_RUN_LOG (run_type) VALUES ('run_started')"

on-run-end:
  - "INSERT INTO T_DBT_RUN_LOG (run_type) VALUES ('run_ended')"
```

---

## 8. Viewing Compiled SQL in DBT Cloud

In DBT Cloud IDE:
1. Open a model.
2. Click **Target** folder in the left panel.
3. Navigate to **Run** → **Models** → click on the model.
4. View the compiled CREATE VIEW / CREATE TABLE statement.

Example compiled output for a model with `config(materialized='table')`:
```sql
CREATE OR REPLACE TRANSIENT TABLE "DEV_DB"."DEV_SCHEMA"."CUSTOMER" AS (
    SELECT
        1 AS ticket_id,
        101 AS customer_id,
        'new' AS ticket_status
);
```

### Why DBT Creates TRANSIENT Tables (Not Permanent Tables)

When you set `materialized='table'`, DBT creates a **transient table** in Snowflake — not a permanent table. Here is why:

| Feature | Permanent Table | Transient Table |
|---|---|---|
| Time Travel | Up to 90 days | 0 or 1 day maximum |
| Fail-Safe | 7 days (additional cost) | None |
| Storage Cost | Higher (fail-safe adds cost) | Lower |
| DBT default | No | Yes |

DBT models are rebuilt on every `dbt run`, so there is no need for long-term Time Travel or Fail-Safe on models — the model can always be re-created. Using transient tables reduces storage costs significantly.

**To force a permanent table (if needed):**
```yaml
# dbt_project.yml
models:
  my_project:
    my_model_name:
      +snowflake_options:
        transient: false
```

---

## 9. Secure Views — Overview

### Normal View (Definition Is Visible)
```sql
CREATE OR REPLACE VIEW V_CUSTOMER AS
SELECT customer_id, customer_name
FROM T_CUSTOMER
WHERE region = 'NORTH';
```

Any user with access can run `SHOW VIEWS` and see the underlying SELECT statement in the `text` column.

### Secure View (Definition Is Hidden)
```sql
CREATE OR REPLACE SECURE VIEW V_CUSTOMER_SECURE AS
SELECT customer_id, customer_name
FROM T_CUSTOMER
WHERE region = 'NORTH';
```

Non-owner roles cannot see the underlying SQL definition, even with `SHOW VIEWS`.

```sql
-- Check if a view is secure
SHOW VIEWS;
-- is_secure column = TRUE for secure views
```

---

## 10. Complete `dbt_project.yml` Template with Hooks

```yaml
name: 'snowflake_dbt'
version: '1.0.0'
config-version: 2

profile: 'snowflake_dbt'

model-paths: ["models"]
seed-paths: ["seeds"]
snapshot-paths: ["snapshots"]
macro-paths: ["macros"]

target-path: "target"
clean-targets: ["target", "dbt_packages"]

on-run-start:
  - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (audit_type, model_name)
     VALUES ('run_started', 'ALL')"

on-run-end:
  - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (audit_type, model_name)
     VALUES ('run_ended', 'ALL')"

models:
  snowflake_dbt:
    materialized: view
    pre-hook:
      - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (audit_type, model_name)
         VALUES ('started', '{{ this.name }}')"
    post-hook:
      - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (audit_type, model_name)
         VALUES ('ended', '{{ this.name }}')"
```

---

## 11. Key Commands

| Command | Description |
|---|---|
| `dbt run` | Run all models (hooks fire for each model) |
| `dbt run --select customer` | Run only the `customer` model |
| `dbt run --select customer orders` | Run multiple specific models |
| `SELECT * FROM T_AUDIT_LOG` | Verify audit records in Snowflake |
| `DELETE FROM T_AUDIT_LOG` | Clear audit records for re-testing |

---

## Summary

- `pre-hook` and `post-hook` are configured in `dbt_project.yml` under the `models:` section.
- `{{ this.name }}` is the Jinja variable that inserts the current model's name dynamically into the hook SQL.
- Audit logging captures start/end timestamps for each model execution, enabling performance monitoring.
- `on-run-start` and `on-run-end` run once per `dbt run` invocation, not per model.
- DBT creates Snowflake tables as **transient tables** by default (no fail-safe period, lower cost).
- Secure views hide the underlying SQL definition from non-owner roles — useful for HIPAA and data governance requirements.
- No semicolons should be used at the end of SQL statements within hook strings.
