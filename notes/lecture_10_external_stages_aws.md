# Lecture 10: External Stages — Azure, GCP, and AWS

---

## Quick Revision — Lecture 10

| # | Key Point |
|---|-----------|
| 1 | External stage = Snowflake stage pointing to cloud storage (S3, Azure Blob, GCS) |
| 2 | All three providers charge **₹2** for credit card verification; free tiers available after |
| 3 | Storage Integration object is required to connect Snowflake to any cloud provider |
| 4 | `SHOW INTEGRATIONS` to list existing integrations before creating a new one |
| 5 | Azure needs: AZURE_TENANT_ID + STORAGE_ALLOWED_LOCATIONS + Consent URL + Role assignment |
| 6 | GCP needs: STORAGE_ALLOWED_LOCATIONS + grant STORAGE_GCP_SERVICE_ACCOUNT access to bucket |
| 7 | AWS needs: STORAGE_AWS_ROLE_ARN + STORAGE_ALLOWED_LOCATIONS + update IAM trust policy |
| 8 | After creating integration, run `DESC STORAGE INTEGRATION` to get the values Snowflake provides |
| 9 | Azure URL format: `azure://account.blob.core.windows.net/container/` (not `https://`) |
| 10 | Once external stage is created, reading/loading data is IDENTICAL to internal stages |

---

**Pre-requisite:** Lecture 9 — SnowSQL CLI, Internal Stages, Storage Integration introduction
**Next:** Lecture 11 — Storage Integration (deeper AWS/Azure configuration)
**Related:** Lecture 4 — Internal Named Stages (same @stage notation, different backing storage)

---

## Objects Created in This Lecture

| Object Type       | Name                 | Purpose |
|-------------------|----------------------|---------|
| Storage Integration | azure_integration  | Connects Snowflake to Azure Blob Storage |
| Storage Integration | gcp_integration    | Connects Snowflake to GCP Cloud Storage |
| Storage Integration | S3_integration     | Connects Snowflake to AWS S3 |
| Stage (external)  | azure_csv_stage      | External stage pointing to Azure container |
| Stage (external)  | gcp_csv_stage        | External stage pointing to GCP bucket/folder |
| Stage (external)  | s3_csv_stage         | External stage pointing to S3 CSV folder |
| Stage (external)  | s3_json_stage        | External stage pointing to S3 JSON folder |
| Stage (external)  | s3_xml_stage         | External stage pointing to S3 XML folder |

---

## ASCII Data Flow — External Stage Architecture

```
Cloud Storage Setup:
  AWS S3:    s3://bktapril20250403/stg_csv_files/emp.csv
  Azure:     azure://saapril202502.blob.core.windows.net/stg-csv-files/emp.csv
  GCP:       gcs://bktapril2025/stg_csv_files/emp.csv

Storage Integration (created in Snowflake):
  azure_integration ─── AZURE_CONSENT_URL + Role Assignment ───► Azure
  gcp_integration   ─── STORAGE_GCP_SERVICE_ACCOUNT grant    ───► GCP
  S3_integration    ─── IAM Trust Policy update              ───► AWS S3

External Stage (references integration):
  @azure_csv_stage  ──► azure://saapril202502...
  @gcp_csv_stage    ──► gcs://bktapril2025/...
  @s3_csv_stage     ──► s3://bktapril20250403/stg_csv_files/
  @s3_json_stage    ──► s3://bktapril20250403/stg_json_files/

Snowflake operations:
  LIST @s3_csv_stage;
  SELECT $1,$2,...  FROM @azure_csv_stage (FILE_FORMAT=>FILE_CSV_FORMAT);
  COPY INTO emp FROM @gcp_csv_stage FILE_FORMAT=(FORMAT_NAME=FILE_CSV_FORMAT);
```

---

## 1. Recap: Internal Stages (All Previous Stages)

All stages created in previous lectures are **internal named stages**:

```sql
-- List all stages
SHOW STAGES;
-- csv_stage, json_stage, xml_stage, parquet_stage

-- Or query metadata view
SELECT * FROM information_schema.stages;
-- Same stages, plus type information
```

> **Instructor:** "These are all what? External stages? No — these are all **internal** stages."

Both commands show the same stages, but `SHOW STAGES` shows the current schema only, while `INFORMATION_SCHEMA.STAGES` shows all schemas.

---

## 2. Why External Stages?

An **external stage** points to files stored in a cloud provider's storage service rather than inside Snowflake's own storage.

### Windows Folder Permission Analogy

> **Instructor:** "Just for timing — what you can assume is: in Windows, there is a location, inside the location you have created a folder. You placed a file. What are all the permissions you have guys? Go to Properties → Security. See for each user — full control. What do you mean by Full Control? You can place a file. You can modify. You can delete. You can rename. This is called Full Control."

The analogy extends to cloud storage:

| Platform | "Location" | "Folder" | "Full Control" permission |
|----------|-----------|----------|--------------------------|
| Windows | Drive path | Folder | Full Control (Windows ACL) |
| AWS | S3 Bucket | Folder/Prefix | AmazonS3FullAccess |
| Azure | Storage Account | Container | Storage Blob Data Contributor |
| GCP | GCS Bucket | Folder | Cloud Storage Storage Admin |

---

## 3. AWS Account Creation (Lecture 10 begins with AWS)

### Steps to create AWS account

1. Go to **https://aws.amazon.com/console/**
2. Click **Create a new AWS account**
3. Provide email address and account name (e.g., "Krishna")
4. Click **Verify** — receive verification code in email
5. Enter verification code → click verify
6. Set password
7. Select **Personal** (for your own projects)
8. Provide name, address, mobile number → check agreement boxes → click **Agree and Continue**
9. Provide credit card details → scroll down, provide PAN card (optional → click No)
10. Click **Verify and Continue**
11. OTP verification — **₹2 charge**
12. Complete setup

> **Instructor:** "So can you see the message how much they are charging? So they are going to charge you exactly two rupees. Even for Microsoft Azure and GCP also they charge you exactly two rupees. For all three cloud providers, they will charge you exactly two rupees."

### Logging into AWS Console

```
1. Go to https://aws.amazon.com/console/
2. Click "Sign In" (root user)
3. Provide email address
4. Multi-factor authentication code (if configured)
5. You are now in the AWS Management Console
```

---

## 4. Microsoft Azure External Stage — Complete Setup

### 4.1 Azure Storage Setup

**Step 1: Log in to Azure Portal**
- Go to **https://portal.azure.com**
- Sign in with credentials

**Step 2: Create Storage Account**
- Navigate: Main Menu → **Storage Account** → **Create**
- Provide Resource Group: `RG April 2025 02` (e.g., click Create new)
- Provide Storage Account Name: `saapril202502` (globally unique, no special chars)

> **Important:** Azure does not allow underscores in container names — use hyphens instead.

- Click **Review + Create** → **Create**
- Wait for "Deployment is complete" message → click **Go to resource**

**Step 3: Create Container**
- In the storage account, scroll to **Containers**
- Click **New Container** (or `+`)
- Container Name: `stg-csv-files` (use hyphens, not underscores)
- Click **Create**

**Step 4: Upload File**
- Click on the container `stg-csv-files`
- Click **Upload**
- Browse to `emp.csv` → click **Upload**
- Message: "Successfully uploaded"

**Step 5: Get File Path**
- Click the three dots (**...**) next to the file → **Properties**
- Copy the URL: `https://saapril202502.blob.core.windows.net/stg-csv-files/emp.csv`

The stage URL format (for Snowflake):
```
azure://saapril202502.blob.core.windows.net/stg-csv-files/
```

> **Instructor:** "In Windows, how you are representing? Drive path → Folder → File. In Azure: Storage Account → Container → File. Both are the same — just the names are different."

### 4.2 Check and Create the Storage Integration in Snowflake

```sql
-- Check existing integrations
SHOW STAGES;
SELECT * FROM information_schema.stages;
SHOW INTEGRATIONS;  -- Currently empty
```

Navigate in Snowflake: Databases → Sales_DB → Sales_Schema → Create → Storage Integration → **Microsoft Azure** → Copy the syntax

```sql
-- Exact SQL from class (2-April section in Daily Notes.sql):
CREATE STORAGE INTEGRATION azure_integration
    TYPE = external_stage
    STORAGE_PROVIDER = azure
    AZURE_TENANT_ID = 'ef5a1cfa-1f98-4ed0-8bc1-29a0b294553b'
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = ( 'azure://saapril202502.blob.core.windows.net/stg-csv-files' );
```

- `TYPE = external_stage` — for external storage
- `STORAGE_PROVIDER = azure` — Microsoft Azure provider
- `AZURE_TENANT_ID` — Azure tenant/directory ID (get from Azure Active Directory / Microsoft Entra ID)
- `STORAGE_ALLOWED_LOCATIONS` — the Azure container path using `azure://` prefix (not `https://`)

```sql
SHOW INTEGRATIONS;
-- azure_integration  (created)
```

### 4.3 Describe the Integration — Get Consent URL

```sql
DESC STORAGE INTEGRATION azure_integration;
```

Values returned (exact from class):

| Parameter | Source | Value |
|-----------|--------|-------|
| `STORAGE_ALLOWED_LOCATIONS` | Azure | `azure://saapril202502.blob.core.windows.net/stg-csv-files` |
| `AZURE_TENANT_ID` | Azure | `ef5a1cfa-1f98-4ed0-8bc1-29a0b294553b` |
| `AZURE_CONSENT_URL` | **Snowflake** | `https://login.microsoftonline.com/ef5a1cfa.../oauth2/authorize?client_id=...` |
| `AZURE_MULTI_TENANT_APP_NAME` | **Snowflake** | `127q7hsnowflakepacint_1743602150484` |

> **Instructor:** "These two parameters — Storage Allowed Locations and Azure Tenant ID — come from Azure. And once you create the integration object, there are two more parameters: Azure Consent URL and Azure Multi-Tenant App Name — these come FROM Snowflake."

### 4.4 Attempt to Create Stage (First Try — Fails)

```sql
CREATE STAGE azure_csv_stage
URL = 'azure://saapril202502.blob.core.windows.net/stg-csv-files'
STORAGE_INTEGRATION = azure_integration;

LIST @azure_csv_stage;
-- Error: "Please check your role assignment and retry"
```

> **Instructor:** "I got an error. It is saying 'please check the role assignment.' From Snowflake, you are trying to access a file which is present in Microsoft Azure. So Microsoft Azure has to give you a privilege. They need to give you a privilege."

### 4.5 Grant Access via Azure Consent URL

1. Copy the `AZURE_CONSENT_URL` from DESC output
2. Paste in browser → press Enter
3. Consent dialog appears — check the checkbox
4. Note: `AZURE_MULTI_TENANT_APP_NAME` (e.g., `127q7hsnowflakepacint`) matches what you see in the consent dialog
5. Click **Accept**
6. Redirected to Snowflake confirmation page

> **Instructor:** "Copy the Azure Consent URL and paste it in the browser. Once you click on that, click on this checkbox and you need to copy this ID. Azure Multi-Tenant App Name — both are same. This is nothing but the multi-tenant app name."

### 4.6 Assign Storage Blob Data Contributor Role in Azure

1. Copy `AZURE_MULTI_TENANT_APP_NAME` from DESC output
2. In Azure Portal → Navigate to Storage Account → Container (`stg-csv-files`)
3. Click **Access Control (IAM)**
4. Click **Add** → **Add role assignment**
5. Search for: **Storage Blob Data Contributor** → select it → click **Next**
6. Click **Select members**
7. Paste the Multi-Tenant App Name into the search box → select it → click **Select**
8. Click **Review + assign**
9. Message: "The role assignment has been added"

### 4.7 Recreate Stage and List Files

```sql
-- Drop old stage and recreate
DROP STAGE azure_csv_stage;

CREATE STAGE azure_csv_stage
URL = 'azure://saapril202502.blob.core.windows.net/stg-csv-files'
STORAGE_INTEGRATION = azure_integration;

SHOW STAGES;
-- azure_csv_stage | external | AZURE

LIST @AZURE_CSV_STAGE;
-- emp.csv  (file visible!)
```

### 4.8 Query and Load Data from Azure Stage

```sql
SHOW FILE FORMATS;
SELECT * FROM information_schema.file_formats;

-- Preview data
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
FROM @AZURE_CSV_STAGE (file_format=>FILE_CSV_FORMAT);
-- Header row shows, but with correct format it's skipped

SELECT * FROM emp;
DELETE FROM emp;

-- Load data — first attempt
COPY INTO emp
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
      FROM @AZURE_CSV_STAGE (file_format=>FILE_CSV_FORMAT));
-- Error: "Insert value list does not match the column list. Expecting 8 but got 10."
```

> **Instructor:** "Why are you getting this error? Table only has 8 columns."

Check and fix the table:

```sql
SELECT * FROM information_schema.columns WHERE table_name = 'EMP';
-- emp has 8 columns

-- Add the missing columns
ALTER TABLE emp ADD mobile NUMBER;
ALTER TABLE emp ADD status BOOLEAN;
-- Now emp has 10 columns

-- Reload
COPY INTO emp
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
      FROM @AZURE_CSV_STAGE (file_format=>FILE_CSV_FORMAT));
-- 25 records loaded

SELECT * FROM emp;
```

> **Instructor:** "See here — 25 records are loaded. What are the different steps that I have followed? I created a stage, I gave the storage integration object. To create the storage integration I needed two parameters: Azure Tenant ID and the locations that I want to access."

---

## 5. GCP Cloud Storage External Stage — Complete Setup

### 5.1 GCP Storage Setup

**Step 1: Log in to GCP Console**
- Go to **https://console.cloud.google.com**
- Select the account (e.g., the one created in Lecture 9)

**Step 2: Create a GCS Bucket**
- Navigate: Main menu (hamburger) → **Cloud Storage** → **Buckets**
- Click **Create**
- Bucket Name: `bktapril2025` (globally unique)
- Scroll down → click **Create** → click **Confirm**

> **Instructor:** "In case of GCP what is the first step? I need to create a bucket. Bucket is nothing but a location. If you compare with Windows — it is nothing but a location."

**Step 3: Create a Folder Inside the Bucket**
- Inside the bucket → click **Create Folder**
- Folder Name: `stg_csv_files`
- Click **Create**

**Step 4: Upload a File**
- Select the folder → click **Upload Files**
- Select `emp.csv` → click **Upload**
- Message: "1 file successfully uploaded"

**Step 5: Copy the GCS Path**
- Click the file → click the three-dot menu → **Copy GCS path**
- Path: `gs://bktapril2025/stg_csv_files/emp.csv`

Stage URL format: `gcs://bktapril2025/stg_csv_files/`

### 5.2 Create GCP Storage Integration in Snowflake

Navigate: Databases → Sales_DB → Sales_Schema → Create → Storage Integration → **Google Cloud Platform** → Copy syntax

```sql
-- Exact SQL from class (2-April section):
CREATE STORAGE INTEGRATION gcp_integration
    TYPE = external_stage
    STORAGE_PROVIDER = gcs
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = ( 'gcs://bktapril2025/stg_csv_files' );
```

Note: GCP integration requires **only `STORAGE_ALLOWED_LOCATIONS`** — no tenant ID needed.

```sql
SHOW INTEGRATIONS;
-- azure_integration, gcp_integration
```

### 5.3 Create Stage and First List Attempt (Permission Error)

```sql
CREATE STAGE gcp_csv_stage
URL = 'gcs://bktapril2025/stg_csv_files'
STORAGE_INTEGRATION = gcp_integration;

LIST @gcp_csv_stage;
-- Error: "does not have storage.objects.list access to the Google Cloud Storage bucket.
--         Permission 'storage.objects.list' denied on resource (or it may not exist). (Status Code: 403)"
```

### 5.4 Describe Integration — Get Service Account

```sql
DESC STORAGE INTEGRATION gcp_integration;
```

Values returned (exact from class):

| Parameter | Source | Value |
|-----------|--------|-------|
| `STORAGE_ALLOWED_LOCATIONS` | GCP | `gcs://bktapril2025/stg_csv_files` |
| `STORAGE_GCP_SERVICE_ACCOUNT` | **Snowflake** | `kw1p00000@awsapsoutheast1sg-e3bb.iam.gserviceaccount.com` |

> **Instructor:** "From GCP you have configured a parameter called storage allowed locations. Once you create the integration object you get storage GCP service account. To this service account — you need to grant access."

### 5.5 Grant Access in GCP Bucket

1. In GCP Console → **Cloud Storage** → **Buckets**
2. Click on bucket name `bktapril2025`
3. Click the **Permissions** tab
4. Click **Grant Access**
5. In **New principals**, paste the `STORAGE_GCP_SERVICE_ACCOUNT` value
6. In **Role**, search for: **Cloud Storage Storage Admin** (under Storage section)
7. Click **Save**

> **Instructor:** "From GCP, you need to give cloud storage — storage admin. Search for the role. Cloud Storage Storage Admin. Select and click on next. Select member — paste the service account name here."

### 5.6 List and Load from GCP Stage

```sql
LIST @gcp_csv_stage;
-- emp.csv  (now visible!)

DELETE FROM emp;
SELECT * FROM emp;

-- Load from GCP external stage
COPY INTO emp
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
      FROM @gcp_csv_stage (file_format=>FILE_CSV_FORMAT));
-- 25 records loaded

SELECT COUNT(*) FROM emp;  -- 25
```

> **Instructor:** "See I know these steps are confusing for you. But we are going to perform similar steps. There is no difference. The same command — only thing is you change the stage name."

---

## 6. AWS S3 External Stage — Complete Setup (Lecture 10 + 3-April)

### 6.1 AWS S3 Setup

**Step 1: Create an S3 Bucket**
- In AWS Console → search for **S3** → click **Create bucket**
- Bucket Name: `bktapril20250403` (globally unique)
- Click **Create bucket**

**Step 2: Create Folders**
- Navigate into the bucket → click **Create folder**
- Create: `stg_csv_files`, `stg_json_files`, `stg_xml_files` (one at a time)

**Step 3: Upload Files**
- Navigate to `stg_csv_files` → **Upload** → Add files → select `emp.csv` → **Upload**
- Navigate to `stg_json_files` → Upload `car.json`
- Navigate to `stg_xml_files` → Upload `emp_sample.xml`

### 6.2 Create IAM Role in AWS

IAM (Identity and Access Management) controls who can access AWS resources.

**Step 1: Navigate to IAM**
- In AWS Console → search for **IAM** → click **Roles** in left menu

**Step 2: Create a New Role**
- Click **Create role**
- Trusted entity type: **AWS account** → **Another AWS account**
- Account ID: enter dummy value (will update later)
- Enable: **Require external ID** → Enter dummy value (will update with real value from Snowflake)
- Click **Next**

**Step 3: Attach Policy**
- Search: **AmazonS3FullAccess** → check → **Next**

**Step 4: Name and Create Role**
- Role Name: `roleapril20250403`
- Click **Create role**

**Step 5: Copy the ARN**
- Search for the role → click it
- Copy the **ARN**: `arn:aws:iam::581573444142:role/roleapril20250403`

### 6.3 Create S3 Storage Integration in Snowflake

```sql
SHOW INTEGRATIONS;

-- Exact SQL from class (3-April section):
CREATE STORAGE INTEGRATION S3_integration
    TYPE = external_stage
    STORAGE_PROVIDER = s3
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::581573444142:role/roleapril20250403'
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = (
        's3://bktapril20250403/stg_csv_files/',
        's3://bktapril20250403/stg_json_files/'
    );
```

- `STORAGE_AWS_ROLE_ARN` — the ARN of the IAM role created above
- `STORAGE_ALLOWED_LOCATIONS` — one or more S3 paths Snowflake is allowed to access

### 6.4 Describe Integration — Get External ID and IAM User ARN

```sql
DESC STORAGE INTEGRATION S3_integration;
```

Values returned (exact from class):

| Parameter | Source | Value |
|-----------|--------|-------|
| `STORAGE_ALLOWED_LOCATIONS` | AWS | `s3://bktapril20250403/stg_csv_files/,...` |
| `STORAGE_AWS_ROLE_ARN` | AWS | `arn:aws:iam::581573444142:role/roleapril20250403` |
| `STORAGE_AWS_IAM_USER_ARN` | **Snowflake** | `arn:aws:iam::779846784444:user/hvxx0000-s` |
| `STORAGE_AWS_EXTERNAL_ID` | **Snowflake** | `TF93031_SFCRole=3_9tSBrTtKfuJsh1lwIbuyZ3w2biQ=` |

> **Instructor:** "From AWS you have configured the storage allowed locations and the IAM role ARN. From Snowflake you get the IAM user ARN and the External ID. Earlier when you created the IAM role, you used a dummy External ID. The actual external ID comes from Snowflake."

### 6.5 Update the IAM Trust Policy

1. In AWS IAM → **Roles** → search `roleapril20250403` → click it
2. Click **Trust relationships** tab
3. Click **Edit trust policy**
4. Update with real values from Snowflake DESC output:
   - Replace dummy account ID with `STORAGE_AWS_IAM_USER_ARN` value
   - Replace dummy External ID with `STORAGE_AWS_EXTERNAL_ID` value

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::779846784444:user/hvxx0000-s"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "TF93031_SFCRole=3_9tSBrTtKfuJsh1lwIbuyZ3w2biQ="
        }
      }
    }
  ]
}
```

5. Click **Update policy**

### 6.6 Create S3 External Stages

```sql
-- CSV stage
CREATE STAGE s3_csv_stage
URL = 's3://bktapril20250403/stg_csv_files/'
STORAGE_INTEGRATION = S3_integration;

-- JSON stage
CREATE STAGE s3_json_stage
URL = 's3://bktapril20250403/stg_json_files/'
STORAGE_INTEGRATION = S3_integration;

-- Verify
LIST @s3_csv_stage;
LIST @s3_json_stage;
```

> **Note:** One integration (`S3_integration`) can be used for multiple stages — each pointing to a different folder within the allowed locations.

### 6.7 Query and Load Data from S3

**JSON from S3 (query):**

```sql
-- Query car.json directly from S3 stage (no PUT needed — file already in S3)
SELECT $1:id::NUMBER           AS id,
       $1:first_name::VARCHAR  AS first_name,
       $1:last_name::VARCHAR   AS last_name,
       $1:car_make::VARCHAR    AS car_make,
       $1:Car_Model::VARCHAR   AS Car_Model,
       $1:Car_Model_Year::NUMBER AS Car_Model_Year
FROM @s3_json_stage/car.json (file_format=>json_format);
```

**Adding XML stage (requires updating allowed locations first):**

```sql
-- First attempt fails — xml location not in allowed locations:
CREATE STAGE s3_xml_stage
URL = 's3://bktapril20250403/stg_xml_files/'
STORAGE_INTEGRATION = S3_integration;

-- Check current allowed locations:
DESC STORAGE INTEGRATION S3_integration;
-- STORAGE_ALLOWED_LOCATIONS = s3://...csv_files/,s3://...json_files/
-- xml_files is NOT in the list!

-- Update allowed locations to include XML:
ALTER STORAGE INTEGRATION S3_integration SET
STORAGE_ALLOWED_LOCATIONS = (
    's3://bktapril20250403/stg_csv_files/',
    's3://bktapril20250403/stg_json_files/',
    's3://bktapril20250403/stg_xml_files/'
);

-- Now create the XML stage:
CREATE STAGE s3_xml_stage
URL = 's3://bktapril20250403/stg_xml_files/'
STORAGE_INTEGRATION = S3_integration;

LIST @s3_xml_stage;
```

**XML from S3:**

```sql
SELECT xmlget(value,'EMPNO'):"$"::number  AS empno,
       xmlget(value,'ENAME'):"$"::varchar AS ename,
       xmlget(value,'JOB'):"$"::varchar   AS job,
       xmlget(value,'MGR'):"$"::number    AS mgr,
       xmlget(value,'HIREDATE'):"$"::date AS hiredate,
       xmlget(value,'SAL'):"$"::number    AS sal,
       xmlget(value,'COMM'):"$"::number   AS comm,
       xmlget(value,'DEPTNO'):"$"::number AS deptno
FROM @s3_xml_stage/emp_sample.xml (file_format=>xml_format),
     lateral flatten($1:"$");
-- Note: files in S3 stages don't have .gz extension (they're not compressed by Snowflake)
```

---

## 7. ALTER STORAGE INTEGRATION — Adding New Allowed Locations

When you try to create a stage pointing to a location not in `STORAGE_ALLOWED_LOCATIONS`, it will fail. Update the integration first:

```sql
-- View current allowed locations
DESC STORAGE INTEGRATION S3_integration;

-- Update to add new location
ALTER STORAGE INTEGRATION S3_integration SET
STORAGE_ALLOWED_LOCATIONS = (
    's3://bktapril20250403/stg_csv_files/',
    's3://bktapril20250403/stg_json_files/',
    's3://bktapril20250403/stg_xml_files/'
);

-- Verify update
DESC STORAGE INTEGRATION S3_integration;
-- STORAGE_ALLOWED_LOCATIONS now shows all three paths
```

---

## 8. Verifying All Stages (Internal + External)

```sql
SHOW STAGES;
-- All stages with their type and provider

SELECT * FROM information_schema.stages;
-- More detail on all stages
```

Expected output after all setups:

```
Stage Name        | Type     | Cloud Provider | URL
------------------|----------|----------------|------------------------------------------
csv_stage         | internal | -              | -
json_stage        | internal | -              | -
xml_stage         | internal | -              | -
parquet_stage     | internal | -              | -
azure_csv_stage   | external | AZURE          | azure://saapril202502.blob.core.windows...
gcp_csv_stage     | external | GCS            | gcs://bktapril2025/stg_csv_files
s3_csv_stage      | external | S3             | s3://bktapril20250403/stg_csv_files/
s3_json_stage     | external | S3             | s3://bktapril20250403/stg_json_files/
s3_xml_stage      | external | S3             | s3://bktapril20250403/stg_xml_files/
```

> **Instructor:** "See this is the Azure stage. What is the type? External. Who is the cloud provider? Microsoft Azure. How you created the stage? By using Azure integration."

---

## 9. Comparison: Azure vs GCP vs AWS Integration

| Feature | Azure | GCP | AWS |
|---------|-------|-----|-----|
| Storage Unit | Storage Account | GCS Bucket | S3 Bucket |
| Sub-unit (Folder) | Container (use hyphens) | Folder | Folder/Prefix |
| URL Format | `azure://account.blob.core.windows.net/container/` | `gcs://bucket/folder/` | `s3://bucket/folder/` |
| Integration parameter | `AZURE_TENANT_ID` + `STORAGE_ALLOWED_LOCATIONS` | `STORAGE_ALLOWED_LOCATIONS` only | `STORAGE_AWS_ROLE_ARN` + `STORAGE_ALLOWED_LOCATIONS` |
| From Snowflake | `AZURE_CONSENT_URL`, `AZURE_MULTI_TENANT_APP_NAME` | `STORAGE_GCP_SERVICE_ACCOUNT` | `STORAGE_AWS_EXTERNAL_ID`, `STORAGE_AWS_IAM_USER_ARN` |
| Auth step | Open Consent URL in browser → Accept | Grant service account access to bucket | Update IAM trust policy with External ID |
| Role to assign | Storage Blob Data Contributor | Cloud Storage Storage Admin | AmazonS3FullAccess |
| Where to assign | Container → Access Control (IAM) → Add role assignment | Bucket → Permissions → Grant Access | IAM Role → Trust relationships |

---

## 10. Key Differences — External Stage vs Internal Stage

| Feature | Internal Named Stage | External Stage |
|---------|---------------------|----------------|
| Where files are stored | Inside Snowflake's cloud storage | In your cloud provider (S3, Azure, GCP) |
| PUT command needed? | Yes — use PUT to upload files | No — files already exist in cloud storage |
| Storage Integration needed? | No | Yes — required |
| Notation | `@stage_name` | `@stage_name` (same!) |
| File reading syntax | `SELECT $1 FROM @stage` | `SELECT $1 FROM @stage` (identical) |
| COPY INTO syntax | `COPY INTO table FROM @stage` | `COPY INTO table FROM @stage` (identical) |
| Compression | Snowflake auto-compresses (`.gz`) | Files as-is in cloud storage |
| Cost | Snowflake storage charges | Cloud provider storage charges |

> **Instructor:** "Once an external stage is created, reading and loading data is IDENTICAL to internal stages — only the stage name changes."

---

## 11. Key Commands Summary

```sql
-- Check existing integrations and stages
SHOW INTEGRATIONS;
SHOW STAGES;
SELECT * FROM information_schema.stages;

-- Azure integration (exact from class)
CREATE STORAGE INTEGRATION azure_integration
    TYPE = external_stage
    STORAGE_PROVIDER = azure
    AZURE_TENANT_ID = 'ef5a1cfa-1f98-4ed0-8bc1-29a0b294553b'
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = ('azure://saapril202502.blob.core.windows.net/stg-csv-files');

-- GCP integration (exact from class)
CREATE STORAGE INTEGRATION gcp_integration
    TYPE = external_stage
    STORAGE_PROVIDER = gcs
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = ('gcs://bktapril2025/stg_csv_files');

-- AWS S3 integration (exact from class)
CREATE STORAGE INTEGRATION S3_integration
    TYPE = external_stage
    STORAGE_PROVIDER = s3
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::581573444142:role/roleapril20250403'
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = (
        's3://bktapril20250403/stg_csv_files/',
        's3://bktapril20250403/stg_json_files/'
    );

-- Describe integrations (get Consent URL, Service Account, External ID)
DESC STORAGE INTEGRATION azure_integration;
DESC STORAGE INTEGRATION gcp_integration;
DESC STORAGE INTEGRATION S3_integration;

-- Update allowed locations (add new location to existing integration)
ALTER STORAGE INTEGRATION S3_integration SET
STORAGE_ALLOWED_LOCATIONS = (
    's3://bktapril20250403/stg_csv_files/',
    's3://bktapril20250403/stg_json_files/',
    's3://bktapril20250403/stg_xml_files/'
);

-- Create external stages
CREATE STAGE azure_csv_stage
URL = 'azure://saapril202502.blob.core.windows.net/stg-csv-files'
STORAGE_INTEGRATION = azure_integration;

CREATE STAGE gcp_csv_stage
URL = 'gcs://bktapril2025/stg_csv_files'
STORAGE_INTEGRATION = gcp_integration;

CREATE STAGE s3_csv_stage
URL = 's3://bktapril20250403/stg_csv_files/'
STORAGE_INTEGRATION = S3_integration;

CREATE STAGE s3_json_stage
URL = 's3://bktapril20250403/stg_json_files/'
STORAGE_INTEGRATION = S3_integration;

CREATE STAGE s3_xml_stage
URL = 's3://bktapril20250403/stg_xml_files/'
STORAGE_INTEGRATION = S3_integration;

-- List files in external stages
LIST @AZURE_CSV_STAGE;
LIST @gcp_csv_stage;
LIST @s3_csv_stage;
LIST @s3_json_stage;

-- Preview data from external stage (identical syntax to internal)
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
FROM @AZURE_CSV_STAGE (file_format=>FILE_CSV_FORMAT);

-- Load data from external stage into table
DELETE FROM emp;
COPY INTO emp FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
                    FROM @AZURE_CSV_STAGE (file_format=>FILE_CSV_FORMAT));
-- 25 records loaded

COPY INTO emp FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
                    FROM @gcp_csv_stage (file_format=>FILE_CSV_FORMAT));

-- Query JSON from S3 external stage
SELECT $1:id::NUMBER AS id, $1:first_name::VARCHAR AS first_name
FROM @s3_json_stage/car.json (file_format=>json_format);

-- Query XML from S3 external stage
SELECT xmlget(value,'EMPNO'):"$"::number AS empno
FROM @s3_xml_stage/emp_sample.xml (file_format=>xml_format),
     lateral flatten($1:"$");

-- Fix table column mismatch
ALTER TABLE emp ADD mobile NUMBER;
ALTER TABLE emp ADD status BOOLEAN;
SELECT * FROM information_schema.columns WHERE table_name = 'EMP';
```

---

## 12. Common Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `please check your role assignment and retry` | Azure role assignment not yet done | Complete the Consent URL flow and assign Storage Blob Data Contributor to Snowflake's app |
| `does not have storage.objects.list access to the Google Cloud Storage bucket. Permission 'storage.objects.list' denied on resource` | GCP service account not granted bucket access | Grant `Cloud Storage Storage Admin` to `STORAGE_GCP_SERVICE_ACCOUNT` in GCP bucket permissions |
| `Insert value list does not match the column list. Expecting 8 but got 10` | Table has fewer columns than the stage file | Use `ALTER TABLE ADD COLUMN` to add missing columns, or fix SELECT column list |
| Stage creation fails for new S3 folder | URL not in STORAGE_ALLOWED_LOCATIONS | Use `ALTER STORAGE INTEGRATION SET STORAGE_ALLOWED_LOCATIONS` to add the new path |
| `Stage already exists` | Tried to create a stage with a name that exists | Use `DROP STAGE stage_name` first, then recreate |
| Blank screen / stage shows empty on LIST | Consent URL not clicked (Azure) | Complete the consent URL step in browser |

---

## 13. Interview Questions

**Q: What is an external stage in Snowflake?**
A: An external stage is a Snowflake stage that points to files stored in a cloud provider's storage (AWS S3, Azure Blob Storage, or GCP Cloud Storage) rather than inside Snowflake's own managed storage. It allows Snowflake to read and load files from cloud buckets directly.

**Q: What is a Storage Integration object in Snowflake?**
A: A Storage Integration is a Snowflake account-level object that establishes a trusted, secure connection between Snowflake and cloud storage. It stores authentication parameters and allowed locations. It is required before creating any external stage.

**Q: How is the syntax for reading data from an external stage different from an internal stage?**
A: It is IDENTICAL. `SELECT $1 FROM @s3_csv_stage (FILE_FORMAT=>format)` and `SELECT $1 FROM @csv_stage (FILE_FORMAT=>format)` use the same syntax. Only the stage name is different.

**Q: What is the AZURE_TENANT_ID and where do you get it?**
A: The AZURE_TENANT_ID is the unique identifier for your Azure Active Directory (Microsoft Entra ID) tenant/subscription. It is found in Azure Portal → Microsoft Entra ID (Azure AD). It is required to create an Azure Storage Integration in Snowflake.

**Q: What values does Snowflake provide after creating a Storage Integration for Azure?**
A: `AZURE_CONSENT_URL` (a URL you must open in a browser to grant consent) and `AZURE_MULTI_TENANT_APP_NAME` (the name of Snowflake's application registered in your Azure tenant, used for the IAM role assignment).

**Q: What is the STORAGE_GCP_SERVICE_ACCOUNT and what do you do with it?**
A: It is a GCP service account email address that Snowflake uses to access GCS buckets. You get it from `DESC STORAGE INTEGRATION gcp_integration`. You must then go to GCP and grant this service account the `Cloud Storage Storage Admin` role on your bucket.

**Q: What are STORAGE_AWS_EXTERNAL_ID and STORAGE_AWS_IAM_USER_ARN?**
A: Both are provided by Snowflake after creating an S3 integration. `STORAGE_AWS_EXTERNAL_ID` must be placed in the IAM role's trust policy condition for security. `STORAGE_AWS_IAM_USER_ARN` must be placed as the Principal in the IAM trust policy — it represents Snowflake's own AWS user that will assume your IAM role.

**Q: Can one Storage Integration be used to create multiple external stages?**
A: Yes. A single integration can back multiple stages as long as all the stage URLs fall within the `STORAGE_ALLOWED_LOCATIONS` of the integration. Use `ALTER STORAGE INTEGRATION SET STORAGE_ALLOWED_LOCATIONS` to add new paths.

---

## 14. Try It Yourself Exercises

**Exercise 1:** Create a GCS bucket, folder, and upload `emp.csv`. Then create a GCP storage integration and external stage in Snowflake. List the files.

```sql
-- Answer steps:
-- 1. GCP Console: Cloud Storage → Create bucket (bkt-practice-2025)
-- 2. Create folder: stg_csv_files
-- 3. Upload emp.csv to the folder
-- 4. In Snowflake:
CREATE STORAGE INTEGRATION my_gcp_integration
    TYPE = external_stage
    STORAGE_PROVIDER = gcs
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = ('gcs://bkt-practice-2025/stg_csv_files/');

DESC STORAGE INTEGRATION my_gcp_integration;
-- Copy STORAGE_GCP_SERVICE_ACCOUNT → Go to GCP → Grant Cloud Storage Storage Admin

CREATE STAGE my_gcp_stage
    URL = 'gcs://bkt-practice-2025/stg_csv_files/'
    STORAGE_INTEGRATION = my_gcp_integration;

LIST @my_gcp_stage;  -- Should show emp.csv
```

**Exercise 2:** After creating an Azure external stage, preview the first 5 rows of emp.csv using SELECT with file format.

```sql
-- Answer:
SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
FROM @AZURE_CSV_STAGE (file_format=>FILE_CSV_FORMAT)
LIMIT 5;
```

**Exercise 3:** You have `S3_integration` with CSV and JSON allowed. Add XML files path to it, then create `s3_xml_stage`.

```sql
-- Answer:
-- First add the new path:
ALTER STORAGE INTEGRATION S3_integration SET
STORAGE_ALLOWED_LOCATIONS = (
    's3://bktapril20250403/stg_csv_files/',
    's3://bktapril20250403/stg_json_files/',
    's3://bktapril20250403/stg_xml_files/'
);

-- Then create the stage:
CREATE STAGE s3_xml_stage
URL = 's3://bktapril20250403/stg_xml_files/'
STORAGE_INTEGRATION = S3_integration;

LIST @s3_xml_stage;
```

**Exercise 4:** Delete all records from `emp`, then load from `gcp_csv_stage`.

```sql
-- Answer:
DELETE FROM emp;
SELECT * FROM emp;  -- 0 records

COPY INTO emp
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
      FROM @gcp_csv_stage (file_format=>FILE_CSV_FORMAT));

SELECT COUNT(*) FROM emp;  -- 25
```

**Exercise 5:** List all integrations and all stages (including type and cloud provider) using both SHOW and INFORMATION_SCHEMA.

```sql
-- Answer:
SHOW INTEGRATIONS;
-- Shows: azure_integration, gcp_integration, S3_integration

SHOW STAGES;
-- Shows current schema stages with type

SELECT STAGE_NAME, STAGE_TYPE, STAGE_URL, STAGE_REGION
FROM information_schema.stages;
-- All stages with details
```

---

## 15. Summary

- External stages point to files in **cloud provider storage** (AWS S3, Azure Blob, GCS) rather than inside Snowflake
- A **Storage Integration** object is required for any external stage — it establishes a trusted connection to cloud storage
- **Azure** setup: Storage Account → Container → upload file → integration (needs Tenant ID + allowed locations) → open Consent URL in browser → assign `Storage Blob Data Contributor` role to Snowflake's app in Azure IAM
- **GCP** setup: GCS Bucket → Folder → upload file → integration (needs only allowed locations) → grant `Cloud Storage Storage Admin` to Snowflake's `STORAGE_GCP_SERVICE_ACCOUNT` in GCP bucket permissions
- **AWS** setup: S3 Bucket → Folder → upload file → IAM role (AmazonS3FullAccess) → integration (needs IAM role ARN + allowed locations) → update IAM trust policy with `STORAGE_AWS_EXTERNAL_ID` and `STORAGE_AWS_IAM_USER_ARN` from Snowflake
- `DESC STORAGE INTEGRATION name` reveals what **Snowflake provides** (Consent URL / Service Account / External ID) for the cloud-side configuration
- Once an external stage is created, reading and loading data is **identical syntax** to internal stages
- One integration can back **multiple stages** — add new locations with `ALTER STORAGE INTEGRATION SET STORAGE_ALLOWED_LOCATIONS`
- All three cloud providers (AWS, Azure, GCP) charge **₹2** for credit card verification; free tiers are available after signup
