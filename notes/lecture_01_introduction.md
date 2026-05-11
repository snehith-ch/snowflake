# Lecture 1: Introduction to Snowflake — Databases, Architecture, and Setup

## Quick Revision — Lecture 1

| # | Key Point |
|---|-----------|
| 1 | Snowflake is a cloud data warehouse — NOT on-premise |
| 2 | Three-layer architecture: Database Storage, Query Processing (Virtual Warehouse), Cloud Services |
| 3 | Without a virtual warehouse you CANNOT read or write data |
| 4 | Minimum billing is 1 minute, then per-second after that |
| 5 | Snowsight is the modern UI (2023+); Classic UI is the legacy interface |
| 6 | Two schemas auto-created with every database: PUBLIC and INFORMATION_SCHEMA |
| 7 | Cloud Services layer handles metadata, authentication, and infrastructure management |
| 8 | Snowflake supports CSV, JSON, XML, and Parquet file formats natively |
| 9 | Scale Up = increase capacity; Scale Down = decrease capacity |
| 10 | SnowPro Core is the foundational Snowflake certification |

---

**Pre-requisite:** None — this is Lecture 1  
**Next:** Lecture 2 — Users, Roles, UI Navigation, and Utility Functions  
**Related:** Lecture 3 — Account Setup, DDL, and Date Functions

---

## Objects Created This Lecture

| Object Type | Name                 | Purpose                                                      |
|-------------|----------------------|--------------------------------------------------------------|
| Database    | BOA_DB               | Bank of America demo database                                |
| Database    | DEV_DB               | Development database (created near end of lecture)           |
| Schema      | INSURANCE_SCHEMA     | Insurance department schema                                  |
| Schema      | BANKING_SCHEMA       | Banking department schema                                    |
| Schema      | LOANS_SCHEMA         | Loans department schema                                      |
| Schema      | DEV_SCHEMA           | Development schema inside DEV_DB                             |
| Table       | VIEWERS              | Stores viewer/programme relationship (TV domain demo)        |
| Table       | PROGRAMME            | TV programme details (programme_id, channel_id, name)        |
| Table       | CHANNEL              | TV channel data (channel_id, category, name)                 |
| Table       | CHANNELCATEGORY      | Channel category lookup (category_id, name)                  |
| Table       | TRAIN_DETAILS_TBL    | Train details (id, name, type, time, from, to, speed)        |
| Table       | TRAIN_TYPE_TBL       | Train type reference (type, description)                     |
| Table       | TRAIN_STATIONS_TBL   | Station lookup (station_id, station_name)                    |
| Table       | REGISTRATION         | Student registration (reg_id, year, date, student, section)  |
| Table       | STUDENT              | Student records (id, last_name, first_name, email, phone)    |
| Table       | SECTION              | Course section (section_id, course_id, schedule, instructor) |
| Table       | COURSE               | Course data (course_id, name, type, term)                    |
| Table       | SCHEDULE             | Class schedule (schedule_id, day, start_time, end_time)      |
| Table       | INSTRUCTOR           | Instructor data (id, last_name, first_name, type, dept_id)   |
| Table       | DEPARTMENT           | Department lookup (dept_id, name)                            |
| Table       | PRODUCT_CATEGORY     | E-commerce product-to-category mapping                       |
| Table       | ORDER_ITEM           | Order line items (item_id, order_id, delivery_id, product)   |
| Table       | CATEGORY             | Product category (category_id, code, name)                   |
| Table       | PRODUCT              | Product catalog (product_id, code, name, unit_price)         |
| Table       | ORDER_DELIVERY       | Delivery tracking (delivery_id, order_id, tracking, status)  |
| Table       | PAYMENT              | Payment records (payment_id, order_id, status, cc details)   |
| Table       | CUSTOMER_ORDER       | Order header (order_id, customer_id, username)               |
| Table       | CUSTOMER_ADDRESS     | Customer address (id, customer_id, name, address, phone)     |
| Table       | CUSTOMER             | Customer credentials (customer_id, username, password)       |
| Table       | T_STUDENTS           | Student info table — used throughout the course              |

> **Note:** The instructor ran these 20+ CREATE TABLE scripts to show that DDL from other databases (Oracle, SQL Server) can be migrated to Snowflake with minimal change. After running all scripts, `SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'` returned **23 tables** — confirming all were created successfully.

---

## ASCII Data Flow Diagram

```
Instructor (Krishna)
        |
        v
[Snowflake.com] --> Start for Free --> Email Activation
        |
        v
[Snowsight UI] --> Projects --> Worksheets --> SQL Commands
        |
        v
[Database Layer] <---(reads/writes via)---> [Virtual Warehouse]
        |
        v
[Cloud Services Layer] --- manages metadata, auth, infrastructure
```

---

## 1. About the Instructor

Krishna has approximately 14 years of experience in data technologies, working in Snowflake for the past 3+ years, currently as an architect for a bank.

**Course plan:** 30 sessions, 1 hour/day, Monday to Saturday, approximately 35-40 days total.

> **Student Question:** Through this training, which role can we get?
> **Answer:** Snowflake Developer / Data Engineer. If you have more than 10 years of experience you would get an Architect role. Below 10 years, expect a Snowflake Developer / Data Engineer designation.

> **Student Question:** Is Python mandatory for Snowflake?
> **Answer:** Yes, Python is increasingly mandatory for every technology. Snowpark uses Python. The world is moving towards AI, and Python is the basic skill needed.

---

## 2. Prerequisites

- Basic SQL knowledge (SELECT, INSERT, CREATE TABLE, data types)
- Familiarity with concepts like rows, columns, and relational data

> The instructor said: "Just for 5 to 7 minutes I will cover the basics — whatever is required for today's session."

---

## 3. Core Database Terminology

### 3.1 Database

A **database** is a system used to store and manage information for a business or application. Every industry — banking, insurance, telecom, healthcare, retail — relies on databases to store customer and operational data.

**Example used in class:** Bank of America stores customer information, loan details, and insurance records in a database for 4 million customers.

### 3.2 Schema

A **schema** is a logical grouping within a database. Different schemas separate data by department or domain.

```
Database: BankOfAmerica_DB (BOA_DB)
├── Schema: Insurance_Schema
├── Schema: Banking_Schema
└── Schema: Loans_Schema
```

> Krishna: "The reason why you have different schemas is to differentiate the service."

### 3.3 Table

A **table** is the fundamental storage object inside a schema. It organizes data into **rows** (records) and **columns** (fields).

```
┌────────────┬───────────────┬──────────────┬──────────────┐
│ EMP_NUMBER │ EMP_NAME      │ ROLE         │ DATE_JOINED  │
├────────────┼───────────────┼──────────────┼──────────────┤
│ 1          │ Vinay         │ Engineer     │ 2022-01-31   │
│ 2          │ Sunil         │ Analyst      │ 2022-01-31   │
│ 3          │ Babu          │ Manager      │ 2022-01-31   │
└────────────┴───────────────┴──────────────┴──────────────┘
  (NUMBER)     (VARCHAR)       (VARCHAR)      (DATE)
```

> **Student Question:** How many tables are there? (After instructor ran scripts)
> **Answer:** Four tables. Later 23 tables after more scripts were added.

> **Student Question:** In real-time, are we going to write scripts manually using SQL?
> **Answer:** No, we have data models. From the data models we get the scripts.

### 3.4 Data Types

A **data type** defines the kind of information stored in a column.

| Data Type | Description                       | Example Values           |
|-----------|-----------------------------------|--------------------------|
| NUMBER    | Whole or decimal numbers          | 1, 42, 3.14              |
| VARCHAR   | Text / character strings          | 'Vinay', 'Engineer'      |
| DATE      | Calendar dates                    | 2022-01-31               |
| BOOLEAN   | True / False values               | TRUE, FALSE              |
| VARIANT   | Semi-structured data (JSON etc.)  | `{"key": "value"}`       |

> Krishna: "Data type is nothing but the type of information which we are storing in a particular column."

---

## 4. On-Premise vs. Cloud

### 4.1 On-Premise

With an on-premise deployment, a business owns and manages all hardware and software.

**Real example used:** Sunil wants to start a supermarket business.

- Must **purchase** servers and software licenses upfront (V1 software, 1TB/32GB RAM)
- After 2 months, business grows from 100 to 1000 customers — need to **upgrade** to V2
- Servers must run **24/7**, even 9 AM to 5 PM customers — electricity cost always running
- Must hire an **admin team** for maintenance, patches, upgrades
- **Scale Up** = increasing existing capacity (1TB → 2TB RAM)
- **Scale Down** = reducing capacity when business shrinks (1TB → 500GB)

```
On-Premise Model:
  Business Owner
       │
       ├── Purchase Hardware (Server: 1 TB, 32 GB RAM)
       ├── Purchase Software (V1 → upgrade to V2 manually)
       ├── Run 24/7 (pay electricity even with no customers)
       ├── Admin team for maintenance and patches
       └── Manual scale-up/down (buy more or less hardware)
```

### 4.2 Cloud

Cloud providers (AWS, Azure, GCP) own the infrastructure. You pay only for what you use.

```
Cloud Model:
  Business Owner
       │
       └── Place Request with Cloud Provider
               ├── No hardware purchase needed
               ├── No manual software upgrades
               ├── No maintenance
               ├── Scale up/down instantly on demand
               └── Pay only for services consumed
```

**Major Cloud Providers:**
- **AWS** — Amazon Web Services
- **Azure** — Microsoft Azure
- **GCP** — Google Cloud Platform

> Krishna mentioned: "Even in Hyderabad, vegetables — we have an Amazon data center."

**Cloud Service Models:**
- **SaaS** — Software as a Service
- **PaaS** — Platform as a Service
- **IaaS** — Infrastructure as a Service
- **DBaaS** (DaaS) — Database as a Service

---

## 5. Data Formats Supported by Snowflake

Snowflake can process data in multiple formats — demonstrated by showing actual files:

| Format  | Description                                     | Example File     |
|---------|-------------------------------------------------|------------------|
| CSV     | Comma-Separated Values — structured, tabular    | employees.csv    |
| JSON    | Key-value pairs — semi-structured               | car.json         |
| XML     | Tag-based markup — semi-structured              | books_info.xml   |
| Parquet | Columnar binary format — used in big data       | MT_cars.parquet  |

> Krishna: "The data can be in any format. Snowflake supports loading the data. So here the point is the data can be in any format."

---

## 6. Why Snowflake?

Snowflake is a **cloud data warehouse** — it runs entirely on cloud infrastructure.

> **Common Interview Question / Certification Question:**
> "Is Snowflake available on-premise?" → **FALSE. Snowflake is cloud-based, not on-premise.**

| Advantage                        | Details                                                         |
|----------------------------------|-----------------------------------------------------------------|
| Cloud-native                     | No hardware to buy or manage                                    |
| Pay-per-use billing              | Minimum billing: **1 minute**, then per-second after that       |
| Flexible storage                 | Scale up or down on demand                                      |
| Multi-format support             | CSV, JSON, XML, Parquet                                         |
| Cloud integrations               | Works with AWS, Azure, GCP                                      |
| ETL tool integrations            | Informatica (IICS), DBT, Talend, SnapLogic, Matillion           |
| Reporting tool integrations      | Power BI                                                        |
| Python integration               | Snowpark for Python-based data engineering                      |
| Big data tool integrations       | Apache Spark, Hive                                              |

> **Interview Tip:** "What is the minimum billing period in Snowflake?"
> **Answer:** 1 minute minimum, then per-second billing after that.

---

## 7. Snowflake Architecture

Snowflake uses a **three-layer architecture** that separates storage, compute, and services.

```
         ┌─────────────────────────────────┐
         │      Cloud Services Layer        │
         │  (Metadata, Auth, Access Control)│
         └─────────────────────────────────┘
                         │
         ┌─────────────────────────────────┐
         │    Query Processing Layer        │
         │    (Virtual Warehouses)          │
         │    Reads and Writes Data         │
         └─────────────────────────────────┘
                         │
         ┌─────────────────────────────────┐
         │     Database Storage Layer       │
         │     Stores all data              │
         └─────────────────────────────────┘
```

### 7.1 Database Storage Layer

- Responsible for **storing all data**
- Data is stored in **compressed, columnar format**
- Comparable to an external hard disk — it holds data but cannot process it alone
- **Analogy used:** External hard disk (1TB) — stores files, images, videos

### 7.2 Query Processing Layer (Virtual Warehouses)

- Responsible for **reading and writing data**
- Uses **Virtual Warehouses** (compute clusters) to execute queries
- **Without a virtual warehouse, you CANNOT read or write data**
- Multiple virtual warehouses can exist in one account — you can create any number
- Virtual warehouses can be started, suspended, and resized independently
- **Analogy used:** Computer RAM — more RAM = faster read/write performance

```
Virtual Warehouse States:
  STARTED   → Can read and write data (GREEN color in UI)
  SUSPENDED → Cannot read or write data (Error thrown)
```

**Demonstration run in class:**

```sql
-- Suspend warehouse → try INSERT → Error
ALTER WAREHOUSE COMPUTE_WH SET AUTO_RESUME=FALSE;
ALTER WAREHOUSE COMPUTE_WH SUSPEND;

-- Try INSERT → fails with: "Your warehouse is suspended"
INSERT INTO CUSTOMER VALUES ('401', 'Vinay', 'JORAN');

-- Resume warehouse
ALTER WAREHOUSE COMPUTE_WH RESUME;

-- Now INSERT works
INSERT INTO CUSTOMER VALUES ('401', 'Vinay', 'JORAN');
INSERT INTO CUSTOMER VALUES ('402', 'Sunil', 'JANE');
INSERT INTO CUSTOMER VALUES ('403', 'Babu', 'TERESA');

-- Verify
SELECT * FROM CUSTOMER;
-- Returns 3 rows: Vinay, Sunil, Babu
```

> Krishna: "The main purpose of the virtual warehouse is to read and write. Without virtual warehouse you cannot read or write."

### 7.3 Cloud Services Layer

- Handles **metadata management** — stores information about all objects created
- Handles **authentication** — verifying user identity on login
- Handles **infrastructure management**
- Handles **access control** (role-based permissions)
- The `INFORMATION_SCHEMA` in each database is part of cloud services metadata

> **Interview Tip:** "In which layer does Snowflake store metadata?" → **Cloud Services Layer**

> **Certification Question:** "Which of the below services are provided with the Cloud Services Layer?"
> Answer: Metadata management, Authentication, Infrastructure management.
> (Query execution is NOT part of cloud services layer — that's the query processing layer)

### 7.4 Full Architecture Analogy

```
External Hard Disk  →  Database Storage Layer   (stores files/data)
Computer RAM        →  Virtual Warehouse         (processes reads/writes)
Operating System    →  Cloud Services Layer       (manages metadata, auth)
```

```
PC1 (4GB RAM)    PC2 (8GB RAM)    PC3 (16GB RAM)
     │                │                  │
     └────────────────┴──────────────────┘
                       │
              External Hard Disk (1 TB)
              
More RAM = Faster read/write from disk
Similarly: Larger Virtual Warehouse = Faster query processing
```

---

## 8. Snowflake Editions

Snowflake offers three editions — like car variants (base, mid, high):

| Edition           | Features Available  | Use Case                              |
|-------------------|---------------------|---------------------------------------|
| Standard          | ~70% of features    | Learning, basic development           |
| Enterprise        | ~90% of features    | Most production workloads             |
| Business Critical | 100% of features    | Banks, healthcare, finance (HIPAA, PCI)|

> Krishna: "I want to explore most of the features given by Snowflake. I want to go with Business Critical."
> **Recommendation for this course:** Choose Business Critical for learning.

---

## 9. Snowflake Certifications

| Certification          | Level    | Description                                       |
|------------------------|----------|---------------------------------------------------|
| SnowPro Core           | Basic    | Foundation — required before advanced             |
| SnowPro Advanced       | Advanced | Role-specific: Architect, Data Engineer, Admin    |

> Krishna: "If you complete this course, you can easily clear the SnowPro Core certification."

Certification dumps (300-400 questions with answers) will be shared during the course.

Sample certification question shown in class:
- "Is Snowflake available on-premise?" → FALSE
- "What are the three key layers of Snowflake?" → Database, Query Processing, Cloud Services
- "Query processing layer in Snowflake is done by?" → Virtual Warehouse
- "What are components of Cloud Services Layer?" → Metadata management, Authentication, Infrastructure management

---

## 10. Creating a Snowflake Account (Free Trial — Step-by-Step)

1. Go to **snowflake.com**
2. Click **"Start for Free"** (30-day free trial)
3. Fill: First name, last name, email
4. Reason: "I want to complete my training and certification"
5. Click **Continue** → provide company name, job title (Engineer)
6. Choose **Edition**: Business Critical (recommended)
7. Choose **Cloud Provider**: AWS (just storage — no functional difference between providers)
8. Check the checkbox and click **Get Started**
9. Receive activation email → click the activation link
10. Note the unique **account URL** — save this (e.g., `https://niotyjo-ov02811.snowflakecomputing.com`)
11. Set username (e.g., `Krishna`) and password (14 characters minimum)
12. Click **Get Started** → you're in Snowsight

> **Student Question:** Is there any possibility to completely choose Python and ignore SQL?
> **Answer:** No — that is just feedback they are collecting. SQL is always required.

---

## 11. Snowflake User Interfaces

| Interface   | Available Since | Description                                  |
|-------------|-----------------|----------------------------------------------|
| Classic UI  | Pre-2023        | Legacy interface; still functional           |
| Snowsight   | 2023+           | Modern UI with improved user experience      |

**Common navigation elements (both UIs):**
- **Databases** — view and manage databases
- **Worksheets** — where you write and execute SQL (`Ctrl + Enter` shortcut)
- **Warehouses** — manage virtual warehouses
- **Marketplace** — import third-party datasets
- **Partner Connect** — connect to ETL/BI tool partners
- **Query/Copy History** — log of executed statements

> **Interview Tip:** "What user interfaces have you worked on in Snowflake?" → Snowsight (2023+) and Classic UI (pre-2023).

> Krishna: "Whatever the classic UI is having, even Snowsight is also having the similar options. So the only difference is the user experience is different. The rest of the commands are same."

---

## 12. Snowflake Objects

When you create a schema, you can create many types of objects inside it:

```
Schema
├── Tables
├── Dynamic Tables
├── Views
├── Materialized Views
├── Stages (Internal/External)
├── Storage Integrations
├── File Formats
├── Sequences
├── Snowpipes
├── Streams
├── Tasks
├── Stored Procedures
└── Functions (UDFs)
```

> Krishna: "If you say you're having three years of experience, they will ask: what are your roles and responsibilities? Answer: I create tables, views, stages, file formats, storage integrations, snowpipes, streams, tasks, procedures, functions."

---

## 13. Key SQL Commands Demonstrated in Class

### Creating Database and Schemas (from class)

```sql
-- Create database for Bank of America
CREATE DATABASE BOA_DB;

-- Create schemas inside the database
CREATE SCHEMA INSURANCE_SCHEMA;
CREATE SCHEMA LOANS_SCHEMA;
CREATE SCHEMA BANKING_SCHEMA;
```

### Tables Created in Class

> **Instructor note:** "The reason I am giving you all these scripts is — when we go for migration, when we come from Oracle, SQL Server, Teradata to Snowflake, all the scripts come from the existing database. We just need to run these scripts on Snowflake."

```sql
-- ============================================================
-- TV / Media domain tables
-- ============================================================
CREATE OR REPLACE TABLE VIEWERS (
    VIEWERID     NUMBER,
    PROGRAMMEID  NUMBER,
    VIEWERNAME   VARCHAR(30)
);

CREATE OR REPLACE TABLE PROGRAMME (
    PROGRAMMEID    NUMBER,
    CHANNELID      NUMBER,
    PROGRAMME_NAME VARCHAR(40)
);

CREATE OR REPLACE TABLE CHANNEL (
    CHANNELID    NUMBER,
    CATEGORY     VARCHAR(1),
    CHANNELNAME  VARCHAR(30)
);

CREATE OR REPLACE TABLE CHANNELCATEGORY (
    CATEGORYID   VARCHAR(1),
    CATEGORYNAME VARCHAR(30)
);

-- ============================================================
-- Railway domain tables
-- ============================================================
CREATE OR REPLACE TABLE TRAIN_DETAILS_TBL (
    TRAIN_ID    INT,
    TRAIN_NAME  VARCHAR(50),
    TRAIN_TYPE  VARCHAR(5),
    TRAIN_TIME  VARCHAR(4),
    TRAIN_FROM  VARCHAR(5),
    TRAIN_TO    VARCHAR(5),
    TRAIN_SPEED INT
);

CREATE OR REPLACE TABLE TRAIN_TYPE_TBL (
    TRAIN_TYPE        VARCHAR(5),
    TRAIN_DESCRIPTION VARCHAR(30)
);

CREATE OR REPLACE TABLE TRAIN_STATIONS_TBL (
    STATION_ID   VARCHAR(5),
    STATION_NAME VARCHAR(30)
);

-- ============================================================
-- Academic / University domain tables
-- ============================================================
CREATE OR REPLACE TABLE REGISTRATION (
    REG_ID         DECIMAL(10,0),
    REG_YEAR       DECIMAL(10,0),
    REG_DATE       DATE,
    STUDENT_ID     DECIMAL(10,0),
    SECTION_ID     DECIMAL(10,0),
    MIDTERM_GRADE  VARCHAR(10),
    FULLTERM_GRADE VARCHAR(10)
);

CREATE OR REPLACE TABLE STUDENT (
    STUDENT_ID DECIMAL(10,0),
    LAST_NAME  VARCHAR(40),
    FIRST_NAME VARCHAR(40),
    EMAIL      VARCHAR(100),
    PHONE      DECIMAL(20,0)
);

CREATE OR REPLACE TABLE SECTION (
    SECTION_ID    DECIMAL(10,0),
    COURSE_ID     DECIMAL(10,0),
    SCHEDULE_ID   DECIMAL(10,0),
    INSTRUCTOR_ID DECIMAL(10,0),
    ROOM          VARCHAR(20)
);

CREATE OR REPLACE TABLE COURSE (
    COURSE_ID DECIMAL(10,0),
    NAME      VARCHAR(40),
    TYPE      VARCHAR(30),
    TERM      DECIMAL(10,0)
);

CREATE OR REPLACE TABLE SCHEDULE (
    SCHEDULE_ID DECIMAL(10,0),
    DAY         VARCHAR(20),
    STARTTIME   VARCHAR(30),
    ENDTIME     VARCHAR(30)
);

CREATE OR REPLACE TABLE INSTRUCTOR (
    INSTRUCTOR_ID DECIMAL(10,0),
    LAST_NAME     VARCHAR(40),
    FIRST_NAME    VARCHAR(40),
    TYPE          VARCHAR(40),
    DEPT_ID       DECIMAL(10,0)
);

CREATE OR REPLACE TABLE DEPARTMENT (
    DEPT_ID DECIMAL(10,0),
    NAME    VARCHAR(40)
);

-- ============================================================
-- E-commerce domain tables
-- ============================================================
CREATE OR REPLACE TABLE PRODUCT_CATEGORY (
    PRODUCT_CATEGORY_ID DECIMAL(18,0),
    PRODUCT_ID          DECIMAL(18,0),
    CATEGORY_ID         DECIMAL(18,0)
);

CREATE OR REPLACE TABLE ORDER_ITEM (
    ORDER_ITEM_ID    DECIMAL(18,0),
    ORDER_ID         DECIMAL(18,0),
    ORDER_DELIVERY_ID DECIMAL(18,0),
    PRODUCT_ID       DECIMAL(18,0),
    QUANTITY         DECIMAL(10,0)
);

CREATE OR REPLACE TABLE CATEGORY (
    CATEGORY_ID DECIMAL(18,0),
    CODE        VARCHAR(20),
    NAME        VARCHAR(40)
);

CREATE OR REPLACE TABLE PRODUCT (
    PRODUCT_ID  DECIMAL(18,0),
    CODE        VARCHAR(20),
    NAME        VARCHAR(40),
    UNIT_PRICE  DECIMAL(10,0)
);

CREATE OR REPLACE TABLE ORDER_DELIVERY (
    ORDER_DELIVERY_ID DECIMAL(18,0),
    ORDER_ID          DECIMAL(18,0),
    TRACKING_NO       DECIMAL(10,0),
    STATUS            VARCHAR(90)
);

CREATE OR REPLACE TABLE PAYMENT (
    PAYMENT_ID DECIMAL(18,0),
    ORDER_ID   DECIMAL(18,0),
    STATUS     VARCHAR(90),
    CCTYPE     VARCHAR(40),
    CCNAME     VARCHAR(200),
    CCDATE     VARCHAR(200)
);

CREATE OR REPLACE TABLE CUSTOMER_ORDER (
    ORDER_ID    DECIMAL(18,0),
    CUSTOMER_ID DECIMAL(18,0),
    USERNAME    VARCHAR(40)
);

CREATE OR REPLACE TABLE CUSTOMER_ADDRESS (
    CUSTOMER_ADDRESS_ID DECIMAL(18,0),
    CUSTOMER_ID         DECIMAL(18,0),
    FIRST_NAME          VARCHAR(40),
    LAST_NAME           VARCHAR(40),
    ADDRESS             VARCHAR(200),
    PHONE               DECIMAL(10,0),
    EMAIL               VARCHAR(60)
);

CREATE OR REPLACE TABLE CUSTOMER (
    CUSTOMER_ID DECIMAL(18,0),
    USERNAME    VARCHAR(40),
    PASSWORD    VARCHAR(40)
);

-- ============================================================
-- Development database and student table
-- ============================================================
CREATE DATABASE DEV_DB;
CREATE SCHEMA DEV_SCHEMA;

-- Student table — used throughout the entire course
CREATE TABLE T_STUDENTS (SNO NUMBER, SNAME VARCHAR, DOJ DATE);
```

### Querying Metadata

```sql
-- Count all tables in the current database (metadata)
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
-- Krishna got 23 tables after creating all demo tables
```

### Inserting and Selecting Data

```sql
INSERT INTO CUSTOMER VALUES ('401', 'Vinay', 'JORAN');
INSERT INTO CUSTOMER VALUES ('402', 'Sunil', 'JANE');
INSERT INTO CUSTOMER VALUES ('403', 'Babu', 'TERESA');

SELECT * FROM CUSTOMER;
```

### Warehouse Control

```sql
-- Suspend a warehouse (stops compute billing)
ALTER WAREHOUSE COMPUTE_WH SET AUTO_RESUME = FALSE;
ALTER WAREHOUSE COMPUTE_WH SUSPEND;

-- Resume a warehouse (green = started)
ALTER WAREHOUSE COMPUTE_WH RESUME;
```

### Context Functions (mentioned in this lecture)

```sql
SELECT CURRENT_USER();        -- KRISHNA
SELECT CURRENT_DATABASE();    -- DEV_DB
SELECT CURRENT_SCHEMA();      -- DEV_SCHEMA
SELECT CURRENT_WAREHOUSE();   -- COMPUTE_WH
```

---

## 14. Snowflake Ecosystem — Course Coverage

```
                    ┌──────────────────────┐
                    │      Snowflake        │
                    └──────────┬───────────┘
           ┌──────────┬────────┴────────┬──────────┐
           │          │                 │          │
      ┌────┴────┐ ┌───┴────┐ ┌─────────┴─┐ ┌─────┴─────┐
      │   ETL   │ │Big Data│ │ Reporting  │ │  Python   │
      │IICS,DBT │ │Spark   │ │  Power BI  │ │ Snowpark  │
      └─────────┘ └────────┘ └────────────┘ └───────────┘
           │
  ┌────────┴─────────┐
  │  Cloud Storage    │
  │ AWS / Azure / GCP │
  └──────────────────┘
```

**Tools covered in this course:**
- Snowflake (primary)
- AWS, Azure, GCP accounts (cloud storage integration)
- Informatica Cloud (IICS) — ETL tool
- DBT (Data Build Tool) — transformation tool
- Power BI — reporting tool
- Python / Snowpark
- PyCharm, Visual Studio, Anaconda (IDE/Python tools)

---

## 15. Key Differences Table

### On-Premise vs. Cloud vs. Snowflake

| Feature               | On-Premise                     | Generic Cloud                     | Snowflake                         |
|-----------------------|--------------------------------|-----------------------------------|-----------------------------------|
| Hardware ownership    | Business owns it               | Cloud provider owns it            | Cloud provider owns it            |
| Software upgrades     | Manual, costly                 | Handled by provider               | Automatic                         |
| Scaling               | Requires new hardware purchase | On-demand via API                 | Instant, on-demand                |
| Cost model            | Fixed (24/7 costs)             | Pay-as-you-go                     | Min 1 min, then per second        |
| Maintenance           | Admin team needed              | Minimal                           | Zero maintenance needed           |
| Data formats          | Depends on DB product          | Depends on service                | CSV, JSON, XML, Parquet native    |

---

## 16. Common Errors Table

| Error / Scenario                             | Cause                                          | Fix                                               |
|----------------------------------------------|------------------------------------------------|---------------------------------------------------|
| "Your warehouse is suspended"                | INSERT/SELECT run while warehouse is suspended | Run `ALTER WAREHOUSE ... RESUME`                  |
| Cannot read data after warehouse suspension  | Warehouse suspended — no compute available     | Resume warehouse first                            |
| Table count shows more than expected         | INFORMATION_SCHEMA includes system tables      | Use `WHERE TABLE_TYPE = 'BASE TABLE'`             |

---

## 17. Interview Questions

**Q: What is the minimum billing period in Snowflake?**
A: 1 minute minimum, then per-second billing after that.

**Q: Is Snowflake available on-premise?**
A: No. Snowflake is a cloud-native data warehouse. It is not available on-premise.

**Q: What are the three layers of Snowflake architecture?**
A: Database Storage Layer, Query Processing Layer (Virtual Warehouses), Cloud Services Layer.

**Q: What does the Cloud Services Layer handle?**
A: Metadata management, authentication, access control (RBAC), infrastructure management.

**Q: What is the purpose of the Virtual Warehouse?**
A: To read and write data. Without a virtual warehouse, no query can execute.

**Q: How many virtual warehouses can you create in one Snowflake account?**
A: Multiple (any number). Each can be independently sized, started, and suspended.

**Q: What are the Snowflake editions?**
A: Standard, Enterprise, Business Critical. Business Critical has all features and compliance support.

**Q: What user interfaces does Snowflake provide?**
A: Snowsight (2023+, modern) and Classic UI (pre-2023, legacy).

**Q: What are Snowflake objects?**
A: Tables, views, dynamic tables, materialized views, stages, file formats, sequences, snowpipes, streams, tasks, stored procedures, functions, storage integrations.

**Q: Which cloud providers does Snowflake support?**
A: AWS, Microsoft Azure, Google Cloud Platform (GCP).

---

## 18. Try It Yourself Exercises

**Exercise 1:** Create a database called `PRACTICE_DB` and three schemas: `HR_SCHEMA`, `FINANCE_SCHEMA`, `SALES_SCHEMA`. Verify with `SHOW SCHEMAS`.

```sql
CREATE DATABASE PRACTICE_DB;
CREATE SCHEMA HR_SCHEMA;
CREATE SCHEMA FINANCE_SCHEMA;
CREATE SCHEMA SALES_SCHEMA;
SHOW SCHEMAS;
```

**Exercise 2:** Check what schemas were auto-created when you made `PRACTICE_DB`.

```sql
SELECT * FROM INFORMATION_SCHEMA.DATABASES WHERE DATABASE_NAME = 'PRACTICE_DB';
-- Look for PUBLIC and INFORMATION_SCHEMA
```

**Exercise 3:** Suspend your COMPUTE_WH, try to run a SELECT, see the error, then resume it.

```sql
ALTER WAREHOUSE COMPUTE_WH SUSPEND;
SELECT CURRENT_DATE(); -- This will fail
ALTER WAREHOUSE COMPUTE_WH RESUME;
SELECT CURRENT_DATE(); -- Now it works
```

**Exercise 4:** Create a table `T_EMPLOYEES` with columns: EMPNO (NUMBER), ENAME (VARCHAR), SAL (NUMBER), DOJ (DATE). Insert 3 records. Count all tables using INFORMATION_SCHEMA.

```sql
CREATE TABLE T_EMPLOYEES (EMPNO NUMBER, ENAME VARCHAR, SAL NUMBER, DOJ DATE);
INSERT INTO T_EMPLOYEES VALUES (1, 'Vinay', 50000, '2020-01-15');
INSERT INTO T_EMPLOYEES VALUES (2, 'Sunil', 60000, '2019-06-01');
INSERT INTO T_EMPLOYEES VALUES (3, 'Babu',  45000, '2021-03-10');
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
```

**Exercise 5:** Get the count of all tables in your database using INFORMATION_SCHEMA and compare with SHOW TABLES.

```sql
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
SHOW TABLES;
```

---

## 19. Key Terms

| Term              | Definition                                                              |
|-------------------|-------------------------------------------------------------------------|
| Database          | Container for storing and organizing business data                      |
| Schema            | Logical grouping of objects within a database                           |
| Table             | Structured storage of data in rows and columns                          |
| Data Type         | The kind of value stored in a column (NUMBER, VARCHAR, DATE, etc.)      |
| On-Premise        | Infrastructure owned and managed by the business itself                 |
| Cloud             | Infrastructure rented from a provider (AWS, Azure, GCP)                 |
| Virtual Warehouse | Snowflake's compute engine for reading and writing data                 |
| Snowsight         | Snowflake's modern web UI (available from 2023)                         |
| Classic UI        | Snowflake's legacy web interface (pre-2023)                             |
| Metadata          | Data about data (object names, creation dates, column types, etc.)      |
| SnowPro Core      | The foundational Snowflake certification exam                           |
| Scale Up          | Increasing server/compute capacity                                      |
| Scale Down        | Decreasing server/compute capacity                                      |
| INFORMATION_SCHEMA| Auto-created schema with metadata views about all database objects      |
| SaaS              | Software as a Service — cloud delivery model                            |
| Snowpark          | Snowflake's Python API for data engineering                             |

---

## 20. Summary

- A **database** holds **schemas**, which hold **objects** (tables, views, stages, etc.)
- Snowflake is a **cloud data warehouse** — not on-premise
- The **three-layer architecture**: Database Storage → Query Processing (Virtual Warehouse) → Cloud Services
- A **Virtual Warehouse must be running** to execute any read or write operation
- Snowflake charges a **minimum of 1 minute**, then per-second after that
- Snowflake supports **CSV, JSON, XML, and Parquet** file formats natively
- The **Snowsight** UI is the modern interface (2023+); **Classic UI** is the legacy version
- Two schemas are auto-created with every database: `PUBLIC` and `INFORMATION_SCHEMA`
- Snowflake integrates with AWS, Azure, GCP, Informatica, DBT, Power BI, and Python
