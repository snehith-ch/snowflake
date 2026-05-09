# Lecture 27: DBT Cloud — GitHub Integration, Snapshots, and Hooks

## Overview
This lecture covers setting up DBT Cloud from scratch: creating a Snowflake connection, linking a GitHub repository via SSH deploy keys, initializing a DBT project, and running models with pre/post hooks for audit logging. The SCD Type 2 / Snapshot concepts are reinforced with a practical example.

---

## 1. DBT Cloud vs DBT Core — Recap

```mermaid
flowchart LR
    A[DBT Core] -->|Local installation| B[VS Code + Terminal]
    C[DBT Cloud] -->|Browser-based IDE| D[dbt.com]
    C -->|GitHub integration| E[Version control]
    C -->|Built-in scheduler| F[Job scheduling]
    C -->|Team collaboration| G[Multiple users]
```

**When to use DBT Cloud:**
- Production deployments requiring scheduling.
- Team collaboration with version control.
- No local environment setup required.
- GitHub/GitLab integration is needed.

**When to use DBT Core:**
- Local development and experimentation.
- No licensing cost required.
- Custom scripted pipelines (Apache Airflow, etc.).

---

## 2. Creating a Snowflake Connection in DBT Cloud

### Step-by-Step

1. Go to [cloud.getdbt.com](https://cloud.getdbt.com) and log in.
2. Navigate to **Account Settings** → **Projects** → **New Project**.
3. Give the project a name (e.g., `snowflake_project`).
4. Under **Configure a Connection**, select **Snowflake**.

### Required Snowflake Connection Parameters

| Parameter | Example Value | Notes |
|---|---|---|
| Account | `abc123.us-east-1` | Snowflake account identifier |
| Database | `PROD_DB` | Target database |
| Warehouse | `COMPUTE_WH` | Virtual warehouse to use |
| Schema | `DBT_SCHEMA` | Default schema for models |
| Role | `SYSADMIN` | Role with CREATE permission |
| Username | `krishna` | Snowflake user |
| Password | `*****` | Snowflake password |

5. Click **Test Connection** to validate. If successful, click **Save**.

---

## 3. Setting Up a GitHub Repository

### Step 1: Create a New Repository on GitHub
1. Go to [github.com](https://github.com) → Click **New** repository.
2. Name it (e.g., `dbt_repo`).
3. Set visibility to **Public** or **Private**.
4. Click **Create repository**.

### Step 2: Copy the SSH URL
On the repository page, click **SSH** and copy the URL:
```
git@github.com:<username>/dbt_repo.git
```

### Step 3: Configure SSH in DBT Cloud
1. In DBT Cloud, go to **Account Settings** → **Integrations** → **GitHub**.
2. Click **Import a Git Repository**.
3. Paste the SSH URL.
4. Click **Generate Deploy Key** — DBT Cloud generates an SSH public key.
5. Copy the generated key.

### Step 4: Add Deploy Key in GitHub
1. Go to your GitHub repository → **Settings** → **Deploy keys**.
2. Click **Add deploy key**.
3. Paste the DBT Cloud public key.
4. Check **Allow write access**.
5. Click **Add key**.

---

## 4. Initializing the DBT Cloud Project

1. Go back to DBT Cloud → Click **Start Developing**.
2. Click **Initialize your project** — This creates the default folder structure:
   ```
   models/
   seeds/
   snapshots/
   macros/
   dbt_project.yml
   ```
3. The project is now linked to your GitHub repository.

---

## 5. SCD Type 2 and Snapshot — DBT Cloud Example

### Source Model: `customer.sql`
```sql
-- models/customer.sql
{{ config(materialized='table') }}

SELECT 1 AS ticket_id, 101 AS customer_id, 'new' AS ticket_status, '2025-01-01'::DATE AS created_date
UNION ALL
SELECT 2, 102, 'new', '2025-01-01'
UNION ALL
SELECT 3, 103, 'new', '2025-01-01'
```

### Snapshot: `change_track.sql`
```sql
-- snapshots/change_track.sql
{% snapshot change_track %}

{{
    config(
        target_schema = 'dbt_schema',
        strategy       = 'check',
        unique_key     = 'ticket_id',
        check_cols     = ['ticket_status']
    )
}}

SELECT * FROM {{ ref('customer') }}

{% endsnapshot %}
```

### Running the Snapshot
```bash
dbt snapshot --select change_track
```

### Tracking Changes Over Time

| Step | Action | change_track rows |
|---|---|---|
| 1 | Initial `dbt snapshot` | 3 rows, all `valid_to = NULL` |
| 2 | Update model: status → `in_progress`, `dbt run`, `dbt snapshot` | 6 rows (3 old + 3 new) |
| 3 | Update model: status → `complete`, `dbt run`, `dbt snapshot` | 9 rows total |

---

## 6. Pre-Hook and Post-Hook in DBT Cloud

### Audit Table Setup (in Snowflake)
```sql
CREATE TABLE PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (
    id           NUMBER AUTOINCREMENT,
    audit_type   VARCHAR(50),
    model_name   VARCHAR(200),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

### Hook Configuration in `dbt_project.yml`
```yaml
name: 'snowflake_project'
version: '1.0.0'

profile: 'snowflake_project'

models:
  snowflake_project:
    materialized: view
    pre-hook:
      - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (audit_type, model_name)
         VALUES ('started', '{{ this.name }}')"
    post-hook:
      - "INSERT INTO PROD_DB.PROD_SCHEMA.T_AUDIT_LOG (audit_type, model_name)
         VALUES ('ended', '{{ this.name }}')"
```

### Running Models with Hooks
In the DBT Cloud IDE terminal:
```bash
dbt run
```

Each model execution will:
1. Execute the `pre-hook` INSERT (logs "started").
2. Execute the model SQL.
3. Execute the `post-hook` INSERT (logs "ended").

### Verifying the Audit Log
```sql
SELECT id, audit_type, model_name, created_date
FROM PROD_DB.PROD_SCHEMA.T_AUDIT_LOG
ORDER BY created_date;
```

---

## 7. Scheduling Jobs in DBT Cloud

1. Navigate to **Deploy** → **Jobs**.
2. Click **New Job**.
3. Give the job a name.
4. Select the environment (`production`).
5. Under **Commands**, add:
   ```
   dbt run
   dbt snapshot
   ```
6. Under **Schedule**, configure:
   - **Cron** or **Day/Time** based scheduling.
   - Example cron: `0 2 * * *` (runs at 2 AM daily).
7. Click **Save**.

---

## 8. Secure Views and Materialized Views (Mentioned in Lecture 27/28)

### Secure View
Hides the underlying SELECT definition from non-owner roles.
```sql
CREATE SECURE VIEW v_customer AS
SELECT customer_id, customer_name
FROM t_customer
WHERE region = 'NORTH';
```

### Materialized View
Pre-computes and stores query results. Auto-refreshes when underlying data changes.
```sql
CREATE MATERIALIZED VIEW mv_country_info AS
SELECT
    nation_key,
    SUM(account_balance) AS total_balance
FROM t_customer
GROUP BY nation_key;
```

| Type | Storage Cost | JOIN Support | Auto-Refresh |
|---|---|---|---|
| View | None | Yes | N/A |
| Secure View | None | Yes | N/A |
| Materialized View | Yes | Single table only | Yes (automatic) |
| Secure Materialized View | Yes | Single table only | Yes |
| Dynamic Table | Yes | Multiple tables | Yes (configurable lag) |

---

## 9. Dynamic Tables (Alternative to Materialized Views for Multi-Table Joins)

When you need auto-refresh from multiple joined tables, use a **Dynamic Table**:
```sql
CREATE OR REPLACE DYNAMIC TABLE T_REFRESH_DATA
    TARGET_LAG = '2 minutes'
    WAREHOUSE  = COMPUTE_WH
    COMMENT    = 'Refreshes customer + nation data every 2 min'
AS
SELECT
    c.c_custkey,
    c.c_name,
    n.n_name AS nation_name
FROM T_CUSTOMER c
JOIN T_NATION n ON c.c_nationkey = n.n_nationkey;
```

To manually refresh:
```sql
ALTER DYNAMIC TABLE T_REFRESH_DATA REFRESH;
```

Check refresh history:
```sql
SELECT * FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
    NAME => 'T_REFRESH_DATA'
));
```

---

## 10. Key Commands

| Command | Description |
|---|---|
| `dbt run` | Run all models (hooks execute automatically) |
| `dbt run --select model_name` | Run a specific model |
| `dbt snapshot --select snapshot_name` | Run a specific snapshot |
| `dbt debug` | Test connection |
| `show streams` | List all streams in Snowflake |
| `show views` | List all views in current schema |

---

## Summary

- DBT Cloud integrates with GitHub using SSH deploy keys — add the DBT-generated public key to the GitHub repository's Deploy Keys setting.
- Snowflake connection parameters (account, database, warehouse, schema, credentials) are configured in DBT Cloud's connection settings.
- Snapshots implement SCD Type 2 by tracking changes with `dbt_valid_from` and `dbt_valid_to` columns.
- Pre/post hooks insert audit log records before and after each model execution; `{{ this.name }}` provides the dynamic model name.
- DBT Cloud supports built-in job scheduling with cron expressions.
- Materialized views support single-table aggregates with automatic refresh; use Dynamic Tables for multi-table refresh scenarios.
