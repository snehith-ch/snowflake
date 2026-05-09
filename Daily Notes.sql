https://niotyjo-ov02811.snowflakecomputing.com/console/login

krishna 
Happybirthday12

gmail.com 
username 
password 

snowsight --> from 2023 
Classic UI  --> Prior 2023


--pending 
unloading 


--CLI ( Command line interface)
snowsql 


snowsql -a iscutgw-jp34947 -u krishna
Happybirthday12

snowsql -a iscutgw-jp34947 -u kranthi
Happybirthday12

Oracle
Sqlserver
Teradata         ---------->   Snowflake 
Postfreq sql 



4M --> Database --> Cust Info 

BOA   -->    Database 
------------------------------------------------------------------------------------------------------------------------------------------------
Insurance --> Schame1
Banking   --> Schame2
Loans     --> Schame3
------------------------------------------------------------------------------------------------------------------------------------------------
DB --> Schemas --> Objects 
Objects:- Tables, Views, Procedures, Functions 
Table :- Rows and rows 
Data Type :- Number , Varchar, Date

9 --> 5PM

Sunil --> 

On-Premise:-  24*7 
-----------------------------------------------------------------------------------------------------
Software --> V1  --> V2 
Hardware --> 1 TB , 32 GB RAM 
upgrade 
24*7 
Patches 

100 --> 2 months --> 1000 
100 --> 2 months --> 50 

Hardware --> 1 TB , 32 GB RAM   --> 2 TB , 64 GB RAM    --> Scale up 
Hardware --> 1 TB , 32 GB RAM   --> 500 GB , 8 GB RAM   --> Scale Down 


Cloud :-
----------
AWS 
AZURE
GCP 


Saas
Paas
Iaas
Daas


;

Snowflake --> minumum 1 min 
per second billing 


Snowflake 
AWS 
AZURE
GCP 
IICS
DBT
Power BI 
Python 
Snowpark 
Pycharm
Visual studtio
Anaconda 



Pc1 (4GB RAM)     PC2 (8GB RAM)     PC3(16GB RAM)

External Hard Disk -->1 TB  files, images, videos 

Read 
Write 



DB + ETL + Repriting + Scripting +Cloud  --> Data Engineer 


Snowflake + sql 
Snowflake + Python 
Snowflake + DBT 
Snowflake + AWS/AZURE/GCP 
Snowflake + Informatica/Talent/Matillion




Databases 
Schemas 
worksheet
warehouse 
Marketplace
Partner Connect 


---
BOA   -->    Database 
------------------------------------------------------------------------------------------------------------------------------------------------
Insurance --> Schame1
Banking   --> Schame2
Loans     --> Schame3
;

ctrl+enter 
;

create database boa_db;

create schema insurance_schema;
create schema loans_schema;
create schema banking_schema;


ui --> user interface 
Snowsight --> from 2023 
Classic UI --> Prior to 2023 


;

create or replace table viewers
(
viewerid number,
programmeid number,
viewername varchar(30) 
);

create or replace table programme
(
programmeid number,
channelid number,
programme_name varchar(40) 
);

create or replace table channel
(
channelid number,
category varchar(1),
channelname varchar(30) 
);

create or replace table channelcategory
(
categoryid varchar(1),
categoryname varchar(30) 
);

-----




create or replace table train_details_tbl
(
train_id int,
train_name varchar(50),
train_type varchar(5) ,
train_time varchar(4) ,
train_from varchar(5) ,
train_to varchar(5),
train_speed int
);

create or replace table train_type_tbl
(
train_type varchar(5),
train_description varchar(30)
);

create or replace table train_stations_tbl
(
station_id varchar(5),
station_name varchar(30)
);


create or replace table registration
(
reg_id decimal(10,0),
reg_year decimal(10,0),
reg_date date,
student_id decimal(10,0),
section_id decimal(10,0),
midterm_grade varchar(10),
fullterm_grade varchar(10)
);

create or replace table student
(
student_id decimal(10,0),
last_name varchar(40),
first_name varchar(40),
email varchar(100),
phone decimal(20,0)
);

create or replace table section
(
section_id decimal(10,0),
course_id decimal(10,0),
schedule_id decimal(10,0),
instructor_id decimal(10,0),
room varchar(20)
);

create or replace table course
(
course_id decimal(10,0),
name varchar(40),
type varchar(30),
term decimal(10,0)
);


create or replace table schedule
(
schedule_id decimal(10,0),
day varchar(20),
starttime varchar(30),
endtime varchar(30)
);

create or replace table instructor
(
instructor_id decimal(10,0),
last_name varchar(40),
first_name varchar(40),
type varchar(40),
dept_id decimal(10,0)
);



create or replace table department
(
dept_id decimal(10,0),
name varchar(40)
);


create or replace table product_category
(
product_category_id decimal(18,0),
product_id decimal(18,0),
category_id decimal(18,0)
);

create or replace table order_item
(
order_item_id decimal(18,0),
order_id decimal(18,0),
order_delivery_id decimal(18,0),
product_id decimal(18,0),
quantity decimal(10,0)
);

create or replace table category
(
category_id decimal(18,0),
code varchar(20),
name  varchar(40)
);

create or replace table product
(
product_id decimal(18,0),
code varchar(20),
name  varchar(40),
unit_price decimal(10,0)
);


create or replace table order_delivery
(
order_delivery_id decimal(18,0),
order_id decimal(18,0),
tracking_no decimal(10,0),
status varchar(90)
);

create or replace table payment
(
payment_id decimal(18,0),
order_id decimal(18,0),
status varchar(90),
cctype varchar(40),
ccname varchar(200),
ccdate varchar(200)
);

create or replace table customer_order
(
order_id decimal(18,0),
customer_id decimal(18,0),
username varchar(40) 
);


create or replace table customer_address
(
customer_address_id decimal(18,0),
customer_id decimal(18,0),
first_name varchar(40) ,
last_name varchar(40) ,
address varchar(200) ,
phone decimal(10,0),
email varchar(60) 
);


create or replace table customer
(
customer_id decimal(18,0),
username varchar(40) ,
password varchar(40) 
);


-- metadata 
select * from information_schema.tables where table_type='BASE TABLE';





INSERT INTO CUSTOMER  VALUES ('401', 'Vinay', 'JORAN');
INSERT INTO CUSTOMER  VALUES ('402', 'Sunil', 'JANE');
INSERT INTO CUSTOMER  VALUES ('403', 'Babu', 'TERESA');


select * from customer;






alter warehouse compute_wh set auto_Resume=false;
alter warehouse compute_wh suspend;
alter warehouse compute_wh resume;


create database dev_Db;
create schema dev_schema;

create table t_students(sno number,sname varchar,doj date);


select * from information_schema.tables where table_type='BASE TABLE';

alter warehouse compute_wh resume;

select current_user(); -- KRISHNA
select current_database(); -- DEV_DB
select current_schema()-- DEV_SCHEMA
select current_warehouse(); -- COMPUTE_WH


select current_date();

select current_timestamp();-- 2025-03-20 06:57:08.772 -0700
                              2025-03-20 19:29:39.481 +0530
show parameters;
show parameters like 'timezone';

alter session set timezone='Asia/Kolkata';

select * from information_schema.databases;

show users;

KRIHSNA	    ACCOUNTADMIN
Deepak	    SECURITYADMIN
Anil	    USERADMIN
Vinay	    SYSADMIN
Rajsekhar	PUBLIC

;

create user deepak 
password='Happybirthday12';

-- 
grant role <role_name> to user <user_name>;

grant role securityadmin to user deepak;


create user Anil 
password='Happybirthday12';


grant role USERADMIN to user Anil;


create user vinay 
password='Happybirthday12';


grant role SYSADMIN to user vinay;

create user raksekhar 
password='Happybirthday12';

grant role public to user raksekhar;

create user sunil 
password='Happybirthday12';


grant role SYSADMIN to user sunil;


  
  
  
  https://atyreyj-tf40590.snowflakecomputing.com/console/login
krishna
Happybirtdhay12

dev_user
Happybirtdhay12
dev_role


create database marketing_db;
create schema marketing_schema;

create table t_Dept(deptno number,dname varchar,loc varchar);

select * from information_schema.tables where table_type='BASE TABLE';

create table t_emp(empno number,ename varchar,sal number);

select * from information_schema.columns where table_name ='T_EMP';
select * from information_schema.columns where table_name ='T_DEPT';

select current_database();
select current_user();
select current_warehouse();

show users;
show tables;


create user vinay
password='Happybirtdhay12';

create user sunil
password='Happybirtdhay12';

show roles;

create role marketing_role;

create warehouse marketing_Wh;

grant role marketing_role to user vinay;

-- how to grant a dataabse access to a role 
grant <privilege> on <object_Type> <object_name> to role <role_name>;

grant usage on database marketing_db to role marketing_role;
grant usage on schema marketing_schema to role marketing_role;
grant usage on warehouse marketing_Wh to role marketing_role;


grant select on table t_dept to role marketing_role;
grant select on table t_emp to role marketing_role;
grant insert on table t_emp to role marketing_role;
grant insert on table t_dept to role marketing_role;


insert into t_Dept values(10,'SALES','HYD');
insert into t_Dept values(20,'ACCOUNTS','DELHI');

insert into t_emp values(101,'Vinay',20000);
insert into t_emp values(102,'Rajesh',40000);

select * from t_emp;
select * from t_dept;

grant role marketing_role to user sunil;

RBAC --> Role based Access Control 
Snowflake --> Role based 
;

create role sales_role;

revoke role marketing_role from  user sunil;
grant role sales_role to  user sunil;




create role dev_role;

create user dev_user
password='Happybirtdhay12';

grant role dev_role to user dev_user;

grant create database on account to role dev_role;


show functions;

show functions like '%current_Database%';
show functions like '%current_timestamp%';

--- How to find the number of days left in the current year 

365 
;
select dayofyear(current_date()); -- 80 

select 365-dayofyear(current_date());-- 285

select date_trunc('year',current_date());-- 2025-01-01
select add_months(date_trunc('year',current_date()),11); -- 2025-12-01
select last_Day(add_months(date_trunc('year',current_date()),11)); -- 2025-12-31



select datediff('days',date_trunc('year',current_date()),last_Day(add_months(date_trunc('year',current_date()),11)))+1;

select datediff('days',date_trunc('year',current_date()),last_Day(add_months(date_trunc('year',current_date()),11)))+1-dayofyear(current_date());



select * from information_schema.databases;

show users;



create role dev_role;
create role qa_role;

create user dev_user
password='Happybirtdhay12';

grant role dev_role to user dev_user;
grant role qa_role to user dev_user;
 


grant usage on database dev_db to role dev_role;
grant usage on schema dev_schema to role dev_role;
grant usage on warehouse dev_wh to role dev_role;


grant select on table t_students to role dev_role;



show functions;

YYYY-MM-DD

:: --> cast operator 


select current_Date();-- 0 parameters 

select dayofyear('2022-12-26'::date);
select dayofyear(current_date());

;
select dayofyear(current_date()); -- 83 

select 365-dayofyear(current_date());-- 285

select date_trunc('year',current_date());-- 2025-01-01
select date_trunc('month',current_date());-- 2025-03-01
select date_trunc('day',current_date());-- 2025-03-24

select add_months(current_date(),2);
select add_months(current_date(),-2);

select last_Day(current_Date()); -- 2025-03-31
select last_Day('2024-02-02'::date); -- 2025-03-31


create table t_emp(empno number,ename varchar,doj date);
insert into t_emp values(1,'Syed','2020-03-24');
insert into t_emp values(2,'Sunil','2010-03-24');
select * from t_emp;

select empno,ename,datediff('years',doj,current_Date()) from t_emp;
select empno,ename,datediff('months',doj,current_Date()) from t_emp;
select empno,ename,datediff('days',doj,current_Date()) from t_emp;

select add_months(date_trunc('year',current_date()),11); -- 2025-12-01
select last_Day(add_months(date_trunc('year',current_date()),11)); -- 2025-12-31



select datediff('days',date_trunc('year',current_date()),last_Day(add_months(date_trunc('year',current_date()),11)))+1;

select datediff('days',date_trunc('year',current_date()),last_Day(add_months(date_trunc('year',current_date()),11)))+1-dayofyear(current_date());



create table t_hr_info(empno number,ename varchar,job varchar,mgr number,hiredate date,
sal number,comm number,deptno number);



INSERT INTO t_hr_info VALUES
        (7369, 'VINAY_KUMAR_CH',  'CLERK',     7902,
        TO_DATE('17-DEC-1980', 'DD-MON-YYYY'),  800, NULL, 20);
INSERT INTO t_hr_info VALUES
        (7499, 'THARUN_KUMAR_CHALLA',  'SALESMAN',  7698,
        TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600,  300, 30);
INSERT INTO t_hr_info VALUES
        (7521, 'BALA_KRISHNA_KORAGANTI',   'SALESMAN',  7698,
        TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250,  500, 30);
INSERT INTO t_hr_info VALUES
        (7566, 'SAI_KISHORE_P',  'MANAGER',   7839,
        TO_DATE('2-APR-1981', 'DD-MON-YYYY'),  2975, NULL, 20);

select empno,ename from t_hr_info;
select empno,split_part(ename,'_',1) as first_name,
split_part(ename,'_',2) as last_name ,
split_part(ename,'_',3) as surname 
from t_hr_info;

grant select on table t_emp to role dev_role;
grant select on table t_hr_info to role dev_role;


--stage is nothing but a location 


select current_user();

list @~;
list @%t_emp;

-- 000002 (0A000): Unsupported feature 'unsupported_requested_format:snowflake'.
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;




type=csv
skip_header=1
field_delimiter=','
record_delimiter='\n'



-----25-Mar-2025 


select current_user();

list @~; --> user stage 
list @%t_emp; --> table stage 

put file://path_of_the_file/name_of_the_file @<stage_name>;
--000002 (0A000): Unsupported feature 'unsupported_requested_format:snowflake'.
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;


krishna#COMPUTE_WH@(no database).(no schema)>

;

use database dev_db;
use schema dev_schema;


list @~;

create table t_student_info
(sno number,sname  varchar,course varchar,doj date);


list @%t_student_info;

put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @%t_student_info;

show stages;

create stage csv_stage;


list @csv_stage;
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_stage;


copy into <table_name> from @stage_name [file_format=format_name];
copy into <table_name> from (select column1,columns2  from @stage_name [file_format=format_name]);

list @~;

select $1,$2,$3,$4 from @~;

show file formats;

create file format csv_foramt
type=csv 
skip_header=1
field_Delimiter=','
record_delimiter='\n';

select $1,$2,$3,$4 from @~ (file_format=>csv_foramt);
select $1,$2,$3,$4 from @~ ;

select * from  t_student_info;

copy into t_student_info from @~;  -- Numeric value 'sno' is not recognized


insert into t_student_info values('sno','sname','course','doj');

create table t_test(empno number);
insert into t_test values('Krishna');-- Numeric value 'Krishna' is not recognized


copy into t_student_info from @~ file_format=csv_foramt;


select * from t_student_info;


list @~;
list @%t_student_info;
list @csv_stage;

show stages;

list @csv_stage;

desc stage csv_stage;


select $1,$2,$3 from @csv_stage/dept.csv.gz;


create file format csv_format_new
type=csv 
skip_header=1
field_Delimiter='_'
record_delimiter='\n';

select $1,$2,$3 from @csv_stage/dept.csv.gz (file_format=>csv_format_new);

C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE DEV_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.115s
krishna#COMPUTE_WH@DEV_DB.PUBLIC>use SCHEMA DEV_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.102s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>

krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| student.csv | student.csv.gz |          91 |         112 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 2.393s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>


krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @%t_student_info;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| student.csv | student.csv.gz |          91 |         112 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 2.970s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>

krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_stage;
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source  | target     | source_size | target_size | source_compression | target_compression | status   | message |
|---------+------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp.csv | emp.csv.gz |        1531 |         560 | NONE               | GZIP               | UPLOADED |         |
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+

krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~;
+-------------+----------------+-------------+-------------+--------------------+--------------------+---------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status  | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+---------+---------|
| student.csv | student.csv.gz |          81 |           0 | NONE               | GZIP               | SKIPPED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+---------+---------+
1 Row(s) produced. Time Elapsed: 2.722s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>


krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\student.csv @~ OVERWRITE=true;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| student.csv | student.csv.gz |          81 |         112 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.848s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>




krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\dept.csv @csv_stage;
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source   | target      | source_size | target_size | source_compression | target_compression | status   | message |
|----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------|
| dept.csv | dept.csv.gz |          64 |          96 | NONE               | GZIP               | UPLOADED |         |
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 2.926s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>





--26-Mar-2025 


--26
show users;


create user kranthi
password='Happybirthday12';




create database sales_db;
create schema sales_schema;

grant usage on database sales_db to role public;
grant usage on schema sales_schema to role public;
grant usage on warehouse dev_wh to role public;

show file formats;
select * from information_schema.file_formats;


create file format file_csv_format
type=csv
skip_header=1
field_Delimiter=','
record_Delimiter='\n';

grant usage on file format file_csv_format to role public;
revoke usage on file format file_csv_format from role public;


create table emp(empno number,ename varchar,job varchar,mgr number,hiredate date,
sal number,comm number, deptno number,mobile number,status boolean);

grant select on table emp to role public;
grant insert on table emp to role public;


create table t_test(empno number);
insert into t_test values('Bala');




---- run the below commands by loggin g with user called Kranthi




select current_user();

Stage:-  Location 
Internal stage 
External stage 


Inter --> user    table           named 
      --> @~      @%table_name    @stage_name 
;
list @~;

put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @~;
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @~;

list @~;

select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 from @~/emp.csv.gz;


show grants to role public;

show file formats;




select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 from @~/emp.csv.gz (file_format=>FILE_CSV_FORMAT);

copy into <table_name> from @stage_name [file_Format=format_name];

select * from emp;

copy into emp from @~/emp.csv.gz file_format=FILE_CSV_FORMAT;

--- log into snowsql 

C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.113s
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use SCHEMA SALES_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.105s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>list @csv_stage;
+------+------+-----+---------------+
| name | size | md5 | last_modified |
|------+------+-----+---------------|
+------+------+-----+---------------+
0 Row(s) produced. Time Elapsed: 0.120s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_Stage;
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source  | target     | source_size | target_size | source_compression | target_compression | status   | message |
|---------+------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp.csv | emp.csv.gz |        1531 |         560 | NONE               | GZIP               | UPLOADED |         |
+---------+------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.250s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_Stage;
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source   | target      | source_size | target_size | source_compression | target_compression | status   | message |
|----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------|
| car.json | car.json.gz |       38671 |        7232 | NONE               | GZIP               | UPLOADED |         |
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.134s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\books_info.xml @xml_Stage
                                         ;
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| books_info.xml | books_info.xml.gz |        4607 |        1408 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 0.994s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\MT_cars.parquet @parquet_
                                         Stage;
+-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source          | target          | source_size | target_size | source_compression | target_compression | status   | message |
|-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| MT_cars.parquet | MT_cars.parquet |        2932 |        2944 | PARQUET            | PARQUET            | UPLOADED |         |
+-----------------+-----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 0.508s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>



krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\sample.json @json_stage;
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source      | target         | source_size | target_size | source_compression | target_compression | status   | message |
|-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------|
| sample.json | sample.json.gz |         202 |         128 | NONE               | GZIP               | UPLOADED |         |
+-------------+----------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.616s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>




show stages;
select * from information_schema.stages;


create stage csv_stage;
create stage json_stage;
create stage xml_stage;
create stage parquet_stage;


list @csv_stage;
list @json_stage;
list @xml_stage;
list @parquet_Stage;

put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp.csv @csv_Stage;
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_Stage;
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\books_info.xml @xml_Stage;
put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\MT_cars.parquet @parquet_Stage;

desc stage csv_stage;
desc stage json_Stage;


json--> key:value pair 
{}
;


list @json_stage;

rm @json_stage;

put file://C:\Users\Balakrishna\Desktop\2025\March_2025\sample.json @json_stage;


create table t_students(sno number,sname varchar,course varchar,doj date);

select * from t_students;


csv --> will have single or more than one column
xml,json,parquet --> will have only single column
;
select $1 from @json_Stage;

show file formats;


create file format json_format
type=json;

select $1 from @json_Stage (file_format=>json_format);

select $1:sno,$1:sname,$1:course,$1:DOJ from @json_Stage (file_format=>json_format);


---27

select $1 from @json_Stage (file_format=>json_format);
select $1:sno::number as sno,
$1:sname::varchar as sname,
$1:course::varchar as course,
$1:DOJ::date as doj,
from @json_Stage (file_format=>json_format);

select * from t_students;

copy into t_students from (select $1:sno::number as sno,
$1:sname::varchar as sname,
$1:course::varchar as course,
$1:DOJ::date as doj,
from @json_Stage (file_format=>json_format));


{"id":1,"first_name":"Rohit","last_name":"K","car_make":"Mercedes-Benz","Car_Model":"C-Class","Car_Model_Year":2001},
;

create table t_cars_info
(id number,first_name varchar,last_name varchar,car_make varchar,car_model varchar,car_model_year number);

select * from t_cars_info;


put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_stage;


C:\Users\Balakrishna>snowsql -a iscutgw-jp34947 -u krishna
Password:
* SnowSQL * v1.3.2
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.108s
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use SCHEMA SALES_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.115s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\car.json @json_stage;
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source   | target      | source_size | target_size | source_compression | target_compression | status   | message |
|----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------|
| car.json | car.json.gz |       38671 |        7232 | NONE               | GZIP               | UPLOADED |         |
+----------+-------------+-------------+-------------+--------------------+--------------------+----------+---------+

;


select $1,metadata$filename from @json_stage (file_format=>json_format);

select $1:id::number as id,
$1:first_name::varchar as first_name  ,
$1:last_name::varchar as last_name  ,
$1:car_make::varchar as car_make  ,
$1:Car_Model::varchar as Car_Model  ,
$1:Car_Model_Year::number as Car_Model_Year  ,
from @json_stage/car.json.gz (file_format=>json_format);

copy into t_cars_info from (select $1:id::number as id,
$1:first_name::varchar as first_name  ,
$1:last_name::varchar as last_name  ,
$1:car_make::varchar as car_make  ,
$1:Car_Model::varchar as Car_Model  ,
$1:Car_Model_Year::number as Car_Model_Year  ,
from @json_stage/car.json.gz (file_format=>json_format));



select * from t_cars_info;


+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| kids_data.json | kids_data.json.gz |         655 |         352 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 2.824s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>

;
create table t_kids_info(name varchar,gender varchar,dob date,kids_name varchar,kids_School varchar,house_number varchar,
city varchar,state varchar,office_number number,personal_number number);

select * from t_kids_info;

select $1 from @json_Stage/kids_data.json.gz (file_format=>json_format);
select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids
from @json_Stage/kids_data.json.gz (file_format=>json_format);

select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids[0]
from @json_Stage/kids_data.json.gz (file_format=>json_format)

select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids[1]
from @json_Stage/kids_data.json.gz (file_format=>json_format);

select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids[2]
from @json_Stage/kids_data.json.gz (file_format=>json_format)
where $1:Kids[2] is not null;



select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids[0]::varchar value
from @json_Stage/kids_data.json.gz (file_format=>json_format)
union 
select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids[1]
from @json_Stage/kids_data.json.gz (file_format=>json_format)
union 
select $1:Name::varchar as Name,
$1:Gender::varchar as Gender,
$1:DOB::date as DOB,
$1:Kids[2]
from @json_Stage/kids_data.json.gz (file_format=>json_format)
where $1:Kids[2] is not null;

select  a.*
from @json_Stage/kids_data.json.gz (file_format=>json_format) a,
lateral flatten($1:Kids) b;


select  b.*
from @json_Stage/kids_data.json.gz (file_format=>json_format) a,
lateral flatten($1:Kids) b;


select c.*
from @json_Stage/kids_data.json.gz (file_format=>json_format) a,
lateral flatten(a.$1:Kids) b,
lateral flatten(a.$1:Kids_School) c;

select 
a.$1:Name::varchar as Name,
a.$1:Gender::varchar as Gender,
a.$1:DOB::date as DOB,
b.value::varchar,
c.value::varchar
from @json_Stage/kids_data.json.gz (file_format=>json_format) a,
lateral flatten(a.$1:Kids) b,
lateral flatten(a.$1:Kids_School) c
where c.index=b.index;



list @json_stage;

create table t_semi_structed_Data
(c1 variant);

copy into t_semi_structed_Data  from @json_stage file_format=json_format;

select * from t_semi_structed_Data;

create table t_ssd
(file_name varchar,c1 variant);

select metadata$filename,$1 from @json_stage (file_format=>json_format);

copy into t_ssd from (select metadata$filename,$1 from @json_stage (file_format=>json_format));


select * from t_ssd;

select c1 from t_ssd where file_name='sample.json.gz';

select c1:sno::number as sno,
 c1:sname::varchar as sname,
 c1:course::varchar as course,
 c1:DOJ::date as DOJ,
from t_ssd where file_name='sample.json.gz';


select  c1:id::number as id,
c1:first_name::varchar as first_name  ,
c1:last_name::varchar as last_name  ,
c1:car_make::varchar as car_make  ,
c1:Car_Model::varchar as Car_Model  ,
c1:Car_Model_Year::number as Car_Model_Year  ,
from t_ssd where file_name='car.json.gz';

show roles;

show grants to role DEV_ROLE;

create user deepak
password='deepak@123';


revoke role securityadmin from user deepak;

create role tst_role;

grant role tst_role to user deepak;

grant usage on database dev_db to role tst_role;

show grants to role public;

revoke usage on database sales_db from role public;

truncate table t_ssd;

copy into t_ssd from (select metadata$filename,$1 from @json_stage );


desc stage json_stage;

alter stage json_stage set file_format=json_format;


copy into t_ssd from (select metadata$filename,$1 from @json_stage );


create table emp_details
(empno number,ename varchar,sal number);

insert into emp_details
select empno,ename,sal from emp;

select * from emp_details;


select * from emp;

list @csv_stage;


show file formats;

copy into emp 
from @csv_stage   
file_format = (format_name = FILE_CSV_FORMAT) 
pattern='.*emp.*[.]gz'; 

show stages;

list @xml_stage;

select * from emp;

delete from emp;


DDL --> Data Definition Language 
;

select get_ddl('object_type','object_name');

select get_ddl('TABLE','EMP');

create or replace TABLE EMP (
	EMPNO NUMBER(38,0),
	ENAME VARCHAR(16777216),
	JOB VARCHAR(16777216),
	MGR NUMBER(38,0),
	HIREDATE DATE,
	SAL NUMBER(38,0),
	COMM NUMBER(38,0),
	DEPTNO NUMBER(38,0),
	MOBILE NUMBER(38,0),
	STATUS BOOLEAN
);


show file formats;


select get_ddl('FILE_FORMAT','FILE_CSV_FORMAT');

CREATE OR REPLACE FILE FORMAT FILE_CSV_FORMAT
	TYPE = csv
	SKIP_HEADER = 1
;


create or replace TABLE EMP (
	EMPNO NUMBER(38,0),
	ENAME VARCHAR(16777216),
	JOB VARCHAR(16777216),
	MGR NUMBER(38,0),
	HIREDATE DATE,
	SAL NUMBER(38,0),
	COMM NUMBER(38,0),
	DEPTNO NUMBER(38,0)
);


put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp_sample.xml @xml_stage;


krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE SALES_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.087s
krishna#COMPUTE_WH@SALES_DB.PUBLIC>use schema SALES_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.085s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp_sample.xml @xml_stage
                                         ;
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp_sample.xml | emp_sample.xml.gz |         448 |         256 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.093s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>

;

show file formats;

create file format xml_format
type=xml;

list @xml_stage;

select $1 from @xml_stage (file_format=>xml_format);

-- How to get  the name of the root 
select $1:"@" from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
-- How to get  the elements of the root 
select $1:"$" from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);

select xmlget($1,'ROW',0) from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
select xmlget($1,'ROW',1) from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);


select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);
select xmlget($1,'ROW',1) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);

select value from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);


select xmlget(value,'EMPNO') from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);

select xmlget(value,'EMPNO'):"@" from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);

select xmlget(value,'EMPNO'):"$" from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);


select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',1) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);


krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\emp_sample.xml @xml_stage
                                          OVERWRITE=true;
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source         | target            | source_size | target_size | source_compression | target_compression | status   | message |
|----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| emp_sample.xml | emp_sample.xml.gz |        2659 |         576 | NONE               | GZIP               | UPLOADED |         |
+----------------+-------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.052s

;

select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',1) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);


select $1 from @xml_stage/emp_sample.xml.gz (file_format=>xml_format);



select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from (
select xmlget($1,'ROW',0) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',1) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',2) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',3) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',4) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',5) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
union 
select xmlget($1,'ROW',6) as value from @xml_stage/emp_sample.xml.gz (file_format=>xml_format)
);



select b.*
from  @xml_stage/emp_sample.xml.gz (file_format=>xml_format) a ,
lateral flatten($1:"$") b;


select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from  @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
lateral flatten($1:"$");


copy into emp from (select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from  @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
lateral flatten($1:"$"));


insert into emp 
select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from  @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
lateral flatten($1:"$");



krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>put file://C:\Users\Balakrishna\Desktop\2025\March_2025\STG_FILES\books_sample.xml @xml_sta
                                         ge;
+------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source           | target              | source_size | target_size | source_compression | target_compression | status   | message |
|------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------|
| books_sample.xml | books_sample.xml.gz |         752 |         400 | NONE               | GZIP               | UPLOADED |         |
+------------------+---------------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 1.663s
krishna#COMPUTE_WH@SALES_DB.SALES_SCHEMA>


;



select xmlget(value,'id'):"$"::varchar as id,
xmlget(value,'author'):"$"::varchar as author ,
xmlget(value,'title'):"$"::varchar as title ,
xmlget(value,'genre'):"$"::varchar as genre ,
xmlget(value,'price'):"$"::number as price ,
xmlget(value,'publish_date'):"$"::date as publish_date ,
xmlget(value,'description'):"$"::varchar as description
from  @xml_stage/books_sample.xml.gz (file_format=>xml_format),
lateral flatten($1:"$");

--1-April-2025 

select * from information_schema.stages;

list @xml_stage;

put file://C:\Users\Balakrishna\Desktop\2025\March_2025\single_record.xml @xml_stage;

;

select $1 from @xml_stage/single_record.xml (file_format=>xml_format);

select to_Array($1:"$") from @xml_stage/single_record.xml (file_format=>xml_format);

select $1:"$" from @xml_stage/books_sample.xml.gz (file_format=>xml_format);

select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from  @xml_stage/single_record.xml.gz (file_format=>xml_format),
lateral flatten(to_Array($1:"$"));



select xmlget(xmlget($1,'ROW'),'EMPNO'):"$"::number as empno,
xmlget(xmlget($1,'ROW'),'ENAME'):"$"::varchar as ename,
from  @xml_stage/single_record.xml.gz (file_format=>xml_format);

list @csv_stage;


rm @csv_stage;


select $1,$2,$3,$4,$5,$6 from @csv_stage;

select * from information_schema.file_formats;

desc file format FILE_CSV_FORMAT;

create file format file_address_format
type=csv 
field_Delimiter=','
skip_header=1
FIELD_OPTIONALLY_ENCLOSED_BY='"';


select $1,$2,$3,$4,$5,$6 from @csv_stage (file_Format=>file_address_format);

show stages;


external stage--> aws , azure , gcp 
credit card , --> 2 rs 


-- Azure
1) https://portal.azure.com
2) Create a new account by providing the gmail address 
3) click on "Start with an Azure free trial"
4) Try azure for free
5) provide the first name ,last name ,mobile(verify the mobile) , address and click on next 
6) credit card number
 We have sent you a text message with an OTP to your registered mobile number ending with XXXXXX5042. 
You are paying merchant MICROSOFTBUS the amount of ₹INR 2.00 on Tue Apr 01 19:44:12 IST 2025.


---- log in 
1) go to the storag account 
2) click on create 
3) provide he rsource group name (rgapril2025)
4) provide the Storage account name (saapril2025)
5)click on  review and creaet 
6) click on create 
7) go to resource 
8) click on containers --> provide the container name and click on create 
9) clik on the container and click on upload 
----gcp 
1) https://console.cloud.google.com
2) select the email address and click on agree and continue 
3) click on start for free
4) select country and continue 
5) click on create a new payment profile 
6) provide organization and address details and click on create 
7) add payment method and provide the card details and click on save card 
8) click on start for free

We have sent you a text message with an OTP to your registered mobile number ending with XXXXXX5042. 
You are paying merchant GOOGLECLOUD the amount of ₹INR 2.00 on Tue Apr 01 19:56:57 IST 2025.

--2-April 
--aws 
1) https://aws.amazon.com/console/
2) Create a new AWS account
3) provide the email address and the name 
4) verify the email 
5) set the password 
6) Personal - for your own projects
7) Name , address, mobile number and click on agreee and continue 
8) Provide the credit card details and verify and continue 
You are paying merchant AMAZONAWSESC the amount of ₹INR 2.00 on Wed Apr 02 19:11:28 IST 2025.



C:\Users\Balakrishna\Desktop\2025\March_2025/stage_csv_files/emp.csv
https://saapril202502.blob.core.windows.net/stg-csv-files/emp.csv


show stages;
select * from information_schema.stages;

snowflake --> Azure (https://saapril202502.blob.core.windows.net/stg-csv-files/emp.csv)
;
-- inorder to establish the relation between snowflake and azure you need to create integration_object 
show integrations;

create storage integration azure_integration
    type = external_stage
    storage_provider = azure
    azure_tenant_id = 'ef5a1cfa-1f98-4ed0-8bc1-29a0b294553b'
    enabled = true
    storage_allowed_locations = ( 'azure://saapril202502.blob.core.windows.net/stg-csv-files' );

create stage azure_csv_stage
url='azure://saapril202502.blob.core.windows.net/stg-csv-files'
storage_integration=azure_integration
;

--  please check your role assignment and retry
list @azure_csv_stage;


desc storage integration azure_integration;


--From Azure
STORAGE_ALLOWED_LOCATIONS	 	azure://saapril202502.blob.core.windows.net/stg-csv-files
AZURE_TENANT_ID	 	            ef5a1cfa-1f98-4ed0-8bc1-29a0b294553b
-- from Snowfalke 
AZURE_CONSENT_URL	 	https://login.microsoftonline.com/ef5a1cfa-1f98-4ed0-8bc1-29a0b294553b/oauth2/authorize?client_id=076d5b02-5b39-4f9c-88bb-241df41db97e&response_type=code
AZURE_MULTI_TENANT_APP_NAME	 	127q7hsnowflakepacint_1743602150484

127q7hsnowflakepacint

;

drop stage azure_csv_stage;

create stage azure_csv_stage
url='azure://saapril202502.blob.core.windows.net/stg-csv-files'
storage_integration=azure_integration
;


show stages;

list @AZURE_CSV_STAGE;

show file formats;
select * from information_schema.file_formats;


select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 from @AZURE_CSV_STAGE ( file_format=>FILE_CSV_FORMAT);

select * from emp;

delete from emp;


copy into emp from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 from @AZURE_CSV_STAGE ( file_format=>FILE_CSV_FORMAT));

select * from information_schema.columns where table_name ='EMP';

alter table emp add mobile number;
alter table emp add status boolean;

copy into emp from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 from @AZURE_CSV_STAGE ( file_format=>FILE_CSV_FORMAT));


--gcp 

show integrations;


create storage integration gcp_integration
    type = external_stage
    storage_provider = gcs
    enabled = true
    storage_allowed_locations = ( 'gcs://bktapril2025/stg_csv_files' );

create stage gcp_csv_stage
url='gcs://bktapril2025/stg_csv_files'
storage_integration=gcp_integration
;

-- does not have storage.objects.list access to the Google Cloud Storage bucket. Permission 'storage.objects.list' denied on resource (or it may not exist). (Status Code: 403)]
list @gcp_csv_stage;    



desc storage integration gcp_integration;

--from gcp
STORAGE_ALLOWED_LOCATIONS	 	gcs://bktapril2025/stg_csv_files
--from snowflake 
STORAGE_GCP_SERVICE_ACCOUNT	 	kw1p00000@awsapsoutheast1sg-e3bb.iam.gserviceaccount.com

;

delete from emp;

select * from emp;

copy into emp from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 from @gcp_csv_stage ( file_format=>FILE_CSV_FORMAT));


--3-April-2025 
-- aws 

show integrations;

create storage integration S3_integration
    type = external_stage
    storage_provider = s3
    storage_aws_role_arn = 'arn:aws:iam::581573444142:role/roleapril20250403'
    enabled = true
    storage_allowed_locations = ( 's3://bktapril20250403/stg_csv_files/', 's3://bktapril20250403/stg_json_files/' );


  iam_role_arn

  1) IAM --> Identity Access Management 
  2) Create Role 
  3) get the ARN 



  External ID --> This will come from Snowflake 
;

  desc storage integration S3_integration;

-- From AWS 
STORAGE_ALLOWED_LOCATIONS	 	s3://bktapril20250403/stg_csv_files/,s3://bktapril20250403/stg_json_files/
STORAGE_AWS_ROLE_ARN	 	    arn:aws:iam::581573444142:role/roleapril20250403

--From Snowflake 
STORAGE_AWS_IAM_USER_ARN	 	arn:aws:iam::779846784444:user/hvxx0000-s
STORAGE_AWS_EXTERNAL_ID	 	    TF93031_SFCRole=3_9tSBrTtKfuJsh1lwIbuyZ3w2biQ=
;

create stage s3_csv_stage
url='s3://bktapril20250403/stg_csv_files/'
storage_integration=S3_integration
;

create stage s3_json_stage
url='s3://bktapril20250403/stg_json_files/'
storage_integration=S3_integration
;

list @s3_csv_stage;
list @s3_json_stage; 


select $1:id::number as id,
$1:first_name::varchar as first_name  ,
$1:last_name::varchar as last_name  ,
$1:car_make::varchar as car_make  ,
$1:Car_Model::varchar as Car_Model  ,
$1:Car_Model_Year::number as Car_Model_Year  
from @s3_json_stage/car.json (file_format=>json_format);



create stage s3_xml_stage
url='s3://bktapril20250403/stg_xml_files/'
storage_integration=S3_integration
;

s3://bktapril20250403/stg_xml_files/
;

desc storage integration S3_integration;

s3://bktapril20250403/stg_csv_files/,s3://bktapril20250403/stg_json_files/
s3://bktapril20250403/stg_csv_files/,s3://bktapril20250403/stg_json_files/,s3://bktapril20250403/stg_xml_files/

;


alter storage integration S3_integration set 
storage_allowed_locations = ( 's3://bktapril20250403/stg_csv_files/', 's3://bktapril20250403/stg_json_files/','s3://bktapril20250403/stg_xml_files/' );

create stage s3_xml_stage
url='s3://bktapril20250403/stg_xml_files/'
storage_integration=S3_integration
;

list @s3_xml_stage;

select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from  @s3_xml_stage/emp_sample.xml (file_format=>xml_format),
lateral flatten($1:"$");


;
select * from information_schema.stages;
show stages;

select * from information_schema.tables where table_type='BASE TABLE';
show tables;


create schema marketing_Schema;


create or replace table viewers
(
viewerid number,
programmeid number,
viewername varchar(30) 
);

create or replace table programme
(
programmeid number,
channelid number,
programme_name varchar(40) 
);

create or replace table channel
(
channelid number,
category varchar(1),
channelname varchar(30) 
);

create or replace table channelcategory
(
categoryid varchar(1),
categoryname varchar(30) 
);

-----




create or replace table train_details_tbl
(
train_id int,
train_name varchar(50),
train_type varchar(5) ,
train_time varchar(4) ,
train_from varchar(5) ,
train_to varchar(5),
train_speed int
);

-- Permanent tables 
select * from information_schema.tables where table_type='BASE TABLE' and is_transient='NO';

RETENTION_TIME=1 day 
;
select * from information_schema.tables where table_type='BASE TABLE' and is_transient='NO' and table_name ='EMP';

alter table emp set data_retention_time_in_days=90; -- 90 days 

select dateadd('days',-90,current_timestamp());-- 2025-01-03 07:13:25.682 -0800 -- emp -- 100records
select dateadd('days',-90,current_timestamp());-- 2025-01-04 07:13:25.682 -0800 -- emp -- 200records
select dateadd('days',-90,current_timestamp());-- 2025-01-05 07:13:25.682 -0800 -- emp -- 800records
select dateadd('days',-90,current_timestamp());-- 2025-01-06 07:13:25.682 -0800 -- emp -- 600 records
select current_timestamp();--                     2025-04-02 07:12:58.314 -0700 -- emp -- 100 records 
select current_timestamp();--                     2025-04-03 07:12:58.314 -0700 -- emp -- 25 records 

select * from emp;


select current_timestamp(); -- 2025-04-03 07:16:32.343 -0700

update emp set sal=100 where empno=7369;

update emp set sal=100;

select * from emp where empno=7369;




select * from emp;
select * from emp at(offset=>-60*1); -- going back to 1 minute 
select * from emp at(offset=>-60*2); -- going back to 2 minute 
select * from emp at(offset=>-60*3); -- going back to 3 minute
select * from emp at(offset=>-60*4); -- going back to 4 minute

create table emp_bkp 
as 
select * from emp at(offset=>-60*4);


select * From emp_bkp;

select * from emp;


merge into <target_Table> t 
using <source_Table> s 
on (joining_condition)
when matched then 
update set t.column=s.column;

merge into emp t 
using emp_bkp s 
on (t.empno=s.empno)
when matched then 
update set t.sal=s.sal;

--4-April-2025 

-- Permanent tables 
select * from information_schema.tables where table_type='BASE TABLE' and is_transient='NO' and table_name ='T_KIDS_INFO';
retention_period or time travel=90  --> failsafe --> 7 days 
;

alter table T_KIDS_INFO set data_retention_time_in_Days=90;
alter table T_KIDS_INFO set data_retention_time_in_Days=91; -- Exceeds maximum allowable retention time (90 day(s)).

;

create table t_customer data_retention_time_in_days=0
as 
select * from snowflake_sample_data.tpcds_sf100tcl.customer;


select * from information_schema.tables where table_type='BASE TABLE' and is_transient='NO' and table_name ='T_CUSTOMER';

-- This view will be used to caluclate the size of the table 
select * from information_schema.table_storage_metrics where table_name ='T_CUSTOMER';


-- Transient table 
select * from information_schema.tables where table_type='BASE TABLE' and is_transient='YES' ;

create transient table tran_students(sno number,sname varchar,doj date);
retention_period or time travel=1 day --> failsafe --> No failsafe 
;
alter table tran_students set data_retention_time_in_Days=2;

-- Temporary table 
select * from information_schema.tables where table_type='LOCAL TEMPORARY' and is_temporary='YES' ;

create temporary table temp_students(sno number,sname varchar,doj date);
create temporary table temp_emp(empno number,ename varchar,doj date);
alter table temp_students set data_retention_time_in_Days=1;

show stages;

-- external table 
list @s3_csv_stage;

desc stage s3_csv_stage;

;

create stage s3_parquet_Stage
url='s3://bktapril20250403/stg_parquet_files/'
storage_integration=s3_integration;

desc storage integration S3_INTEGRATION;

alter storage integration S3_INTEGRATION set 
STORAGE_ALLOWED_LOCATIONS=('s3://bktapril20250403/stg_csv_files/','s3://bktapril20250403/stg_json_files/','s3://bktapril20250403/stg_xml_files/','s3://bktapril20250403/stg_parquet_files/');


create stage s3_parquet_Stage
url='s3://bktapril20250403/stg_parquet_files/'
storage_integration=s3_integration;

list @s3_parquet_Stage;

select $1 from @s3_parquet_Stage;

show file formats;

create file format parquet_format
type=parquet;

list  @s3_parquet_Stage;

select $1 from @s3_parquet_Stage (file_format=>parquet_format);
select $1:am::number as am,
$1:carb::number as carb
from @s3_parquet_Stage (file_format=>parquet_format);

select * from table(infer_schema(LOCATION => '@s3_parquet_Stage' , FILE_FORMAT => 'parquet_format' , 
FILES => 'MT_cars.parquet'));


select $1:model::TEXT,
$1:mpg::REAL,
$1:cyl::NUMBER(38, 0),
$1:disp::REAL,
$1:hp::NUMBER(38, 0),
$1:drat::REAL,
$1:wt::REAL,
$1:qsec::REAL,
$1:vs::NUMBER(38, 0),
$1:am::NUMBER(38, 0),
$1:gear::NUMBER(38, 0),
$1:carb::NUMBER(38, 0),
from @s3_parquet_Stage (file_format=>parquet_format);


select concat('My name is ','Krishna ', 'I am working as a ',' Architect');

select * from emp where empno=7839;
select concat(' My name is ',ename,' salary is ',sal,' working in deptno ',deptno, 'th department') 
from emp where empno=7839;


select concat(expression,' as ',COLUMN_NAME,',') from table(infer_schema(LOCATION => '@s3_parquet_Stage' , FILE_FORMAT => 'parquet_format' , 
FILES => 'MT_cars.parquet'));


select  $1:model::TEXT as model,
$1:mpg::REAL as mpg,
$1:cyl::NUMBER(38, 0) as cyl,
$1:disp::REAL as disp,
$1:hp::NUMBER(38, 0) as hp,
$1:drat::REAL as drat,
$1:wt::REAL as wt,
$1:qsec::REAL as qsec,
$1:vs::NUMBER(38, 0) as vs,
$1:am::NUMBER(38, 0) as am,
$1:gear::NUMBER(38, 0) as gear,
$1:carb::NUMBER(38, 0) as carb,
from @s3_parquet_Stage (file_format=>parquet_format);

;
list @s3_parquet_Stage;

create external table ext_cars_info 
location=@s3_parquet_Stage
file_Format=parquet_format;


select * from ext_cars_info;

select  concat(column_name ,' ', type,' as (','value',':',column_name,'::',type,'),') from table(infer_schema(LOCATION => '@s3_parquet_Stage' , FILE_FORMAT => 'parquet_format' , 
FILES => 'MT_cars.parquet'));

create external table ext_cars_info_new
(model TEXT as (value:model::TEXT),
mpg REAL as (value:mpg::REAL),
cyl NUMBER(38, 0) as (value:cyl::NUMBER(38, 0)),
disp REAL as (value:disp::REAL),
hp NUMBER(38, 0) as (value:hp::NUMBER(38, 0)),
drat REAL as (value:drat::REAL),
wt REAL as (value:wt::REAL),
qsec REAL as (value:qsec::REAL),
vs NUMBER(38, 0) as (value:vs::NUMBER(38, 0)),
am NUMBER(38, 0) as (value:am::NUMBER(38, 0)),
gear NUMBER(38, 0) as (value:gear::NUMBER(38, 0)),
carb NUMBER(38, 0) as (value:carb::NUMBER(38, 0))
)
location=@s3_parquet_Stage
file_Format=parquet_format;



select * from ext_cars_info_new;
select *exclude value from ext_cars_info_new;

show file formats;

list @s3_csv_stage;

create external table ext_emp_info
location=@s3_csv_stage
file_Format=FILE_CSV_FORMAT;

select * from ext_emp_info;

create external table ext_emp_info_new
(
empno number as (value:c1::number),
ename varchar as (value:c2::varchar),
job varchar as (value:c3::varchar),
mgr number as (value:c4::number),
HIREDATE date as (value:c5::date),
sal number as (value:c6::number),
comm number as (value:c7::number),
deptno number as (value:c8::number),
mobile number as (value:c9::number),
status boolean as (value:c10::boolean)
)
location=@s3_csv_stage
file_Format=FILE_CSV_FORMAT;


select * from ext_emp_info_new;
select * exclude value from ext_emp_info_new;


-- 7-April-2025 
create database test_Db data_retention_time_in_Days=2;
create schema test_schema data_retention_time_in_Days=2;

create table t_emp ( empno number,ename varchar,sal number);

select * from information_schema.tables where table_type='BASE TABLE';

show stages;

list @S3_CSV_STAGE;
rm @S3_CSV_STAGE;


desc stage S3_CSV_STAGE;

-- ["s3://bktapril20250403/stg_csv_files/"]

;

show file formats;
select * from information_schema.file_formats;

copy into emp from  @S3_CSV_STAGE  file_format=FILE_CSV_FORMAT;


--snowpipe
show pipes;
select * from information_schema.pipes;

create pipe pipe_load_Data 
auto_ingest=true
as 
copy into emp from  @S3_CSV_STAGE  file_format=FILE_CSV_FORMAT;

arn:aws:sqs:us-east-1:779846784444:sf-snowpipe-AIDA3LET5SW6O3GZWVSI4-s1Qc78e7uriS6p0Gy0TCCQ


;
select system$pipe_status('pipe_load_Data');
select parse_json(system$pipe_status('pipe_load_Data'));

select * from emp;

truncate table emp;
 
select * from table(information_Schema.copy_history(table_name=>'EMP',start_time=>dateadd('days',-1,current_timestamp())));


list @csv_stage;

rm @csv_stage;

put file://C:\Users\Balakrishna\Desktop\2025\March_2025\emp40.csv @csv_stage;

;

copy into emp from  @csv_stage  file_format=FILE_CSV_FORMAT;


select * from table(information_Schema.validate_pipe_load(pipe_name=>'pipe_load_data',start_time=>dateadd('days',-1,current_timestamp())));

;
select * from table(information_Schema.copy_history(table_name=>'EMP',start_time=>dateadd('days',-1,current_timestamp())));

delete from emp;

truncate table emp;

alter pipe pipe_load_Data refresh;

--loading 
from file to table 
-- unloading
table to file 
;
create stage unload_stage;

select * from emp;

alter table emp drop column mobile;
alter table emp drop column status;


insert into emp 
select xmlget(value,'EMPNO'):"$"::number as empno,
xmlget(value,'ENAME'):"$"::varchar as ename ,
xmlget(value,'JOB'):"$"::varchar as job ,
xmlget(value,'MGR'):"$"::number as mgr ,
xmlget(value,'HIREDATE'):"$"::date as hiredate ,
xmlget(value,'SAL'):"$"::number as sal ,
xmlget(value,'COMM'):"$"::number as comm ,
xmlget(value,'DEPTNO'):"$"::number as deptno ,
from  @xml_stage/emp_sample.xml.gz (file_format=>xml_format),
lateral flatten($1:"$");

;


list @S3_CSV_STAGE;

copy into @S3_CSV_STAGE from emp file_format=FILE_CSV_FORMAT;


truncate table emp;



copy into emp from @S3_CSV_STAGE file_format=FILE_CSV_FORMAT;

select * from emp;

copy into @S3_CSV_STAGE from emp file_format=JSON_FORMAT;


show file formats;



-- 8th april 
show pipes;
250MB --> min 
5 GB -->  max 
;
select get_ddl('TABLE','EMP');

create or replace TABLE EMP (
	EMPNO NUMBER(38,0),
	ENAME VARCHAR(16777216),
	JOB VARCHAR(16777216),
	MGR NUMBER(38,0),
	HIREDATE DATE,
	SAL NUMBER(38,0),
	COMM NUMBER(38,0),
	DEPTNO NUMBER(38,0)
);


select get_ddl('PIPE','PIPE_LOAD_DATA');

create or replace pipe PIPE_LOAD_DATA_NEW
auto_ingest=false 
as 
copy into emp from  @S3_CSV_STAGE  file_format=FILE_CSV_FORMAT;

desc stage S3_CSV_STAGE;
["s3://bktapril20250403/stg_csv_files/"]
;
select parse_json(system$pipe_status('pipe_load_Data'));
select parse_json(system$pipe_status('pipe_load_Data_new'));

{
  "executionState": "RUNNING",
  "pendingFileCount": 0
}

;

select * from emp;

delete from emp;

alter pipe pipe_load_Data_new refresh;

 
select * from table(information_Schema.validate_pipe_load(pipe_name=>'pipe_load_data_new',start_time=>dateadd('days',-1,current_timestamp())));

;
select * from table(information_Schema.copy_history(table_name=>'EMP',start_time=>dateadd('days',-1,current_timestamp())));


select * from emp;


alter table emp add mobile number;
alter table emp add status boolean;

copy into emp from  @S3_CSV_STAGE  file_format=FILE_CSV_FORMAT;


Snoowpipe is a  serverless feature 


copy into emp from  @S3_CSV_STAGE  file_format=FILE_CSV_FORMAT;

alter warehouse dev_wh set auto_resume=false;
alter warehouse dev_wh suspend;
alter warehouse dev_wh resume;


alter pipe pipe_load_Data_new refresh;


select * from emp;

--- 



create database prod_db;

create schema prod_Schema;

create storage integration S3_integration_prod
    type = external_stage
    storage_provider = s3
    storage_aws_role_arn = 'arn:aws:iam::581573444142:role/roleapril20250403'
    enabled = true
    storage_allowed_locations = ( 's3://bktapril20250403/stg_csv_files/', 's3://bktapril20250403/stg_json_files/' );


desc storage integration S3_integration_prod;

create stage s3_csv_stage
url='s3://bktapril20250403/stg_csv_files/'
storage_integration=S3_integration
;
list @s3_csv_stage;

create or replace TABLE EMP (
	EMPNO NUMBER(38,0),
	ENAME VARCHAR(16777216),
	JOB VARCHAR(16777216),
	MGR NUMBER(38,0),
	HIREDATE DATE,
	SAL NUMBER(38,0),
	COMM NUMBER(38,0),
	DEPTNO NUMBER(38,0),
    mobile number,
    status boolean,
    file_name varchar
);

show file formats;

create file format csv_format
type=csv
skip_header=1;

copy into EMP from @s3_csv_stage/emp.csv file_format=csv_format;

select * from emp;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) );


select 's3_csv_stage/emp.csv' ;
select split_part('s3_csv_stage/emp.csv','/',2) ;
select split_part(metadata$filename ,'/',2) ;


copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) );

select * from table(information_Schema.copy_history(table_name=>'EMP',start_time=>dateadd('hour',-1,current_timestamp())));


delete from emp;

select * from emp;

truncate table emp;

-- 9th April 
alter warehouse dev_wh resume;

select * from emp;

select * from table(information_Schema.copy_history(table_name=>'EMP',start_time=>dateadd('day',-1,current_timestamp())));


truncate table emp;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) );

desc stage s3_csv_stage;

desc storage integration S3_INTEGRATION;

["s3://bktapril20250403/stg_csv_files/"]

;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) force=true;

select * from emp;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) );

truncate table emp;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) purge=true;

select get_ddl('TABLE','EMP');

create or replace TABLE EMP (
	EMPNO NUMBER(38,0),
	ENAME VARCHAR(5),
	JOB VARCHAR(20),
	MGR NUMBER(38,0),
	HIREDATE DATE,
	SAL NUMBER(38,0),
	COMM NUMBER(38,0),
	DEPTNO NUMBER(38,0),
	MOBILE NUMBER(38,0),
	STATUS BOOLEAN,
	FILE_NAME VARCHAR(16777216)
);




copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) ;

select * from emp;

truncate table emp;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) on_error=continue;

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) TRUNCATECOLUMNS=true;

desc stage s3_csv_stage;


copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) on_error=continue;

alter table emp drop column file_name;

copy into EMP from  @s3_csv_stage/emp.csv  file_format=csv_format  validation_mode=return_all_errors;

select * from emp;

alter table emp modify ename varchar(100);

copy into EMP from  @s3_csv_stage/emp.csv  file_format=csv_format  validation_mode=return_all_errors;

copy into EMP from  @s3_csv_stage/emp.csv  file_format=csv_format  validation_mode=return_1_rows;




copy into EMP from (select $1,substr($2,1,5),$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) on_error=continue;

select * from table(information_Schema.copy_history(table_name=>'EMP',start_time=>dateadd('day',-1,current_timestamp())));

copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) force=true on_error=continue;


copy into EMP from (select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,split_part(metadata$filename ,'/',2) from  @s3_csv_stage/emp.csv  (file_format=>csv_format) ) force=true ;


create or replace table t_semi_structured_Data(c1 variant,file_name varchar);

copy into t_semi_structured_Data from @;

show stages;
show file formats;

list @S3_JSON_STAGE;
list @S3_XML_STAGE;
list @S3_PARQUET_STAGE;


copy into t_semi_structured_Data from (select $1,split_part(metadata$filename,'/',2) from @S3_JSON_STAGE (file_format=>JSON_FORMAT));
copy into t_semi_structured_Data from @S3_XML_STAGE file_format=xml_FORMAT;
copy into t_semi_structured_Data from @S3_PARQUET_STAGE file_format=PARQUET_format;

select * from t_semi_structured_Data;

copy into @S3_JSON_STAGE from (select c1 from t_semi_structured_Data where file_name='car.json')
file_format=JSON_FORMAT;

;


select * from t_semi_structured_Data where file_name='car.json';



select count(*) from t_customer;

copy into @S3_csv_STAGE from (select * from t_customer limit 100) file_format=FILE_CSV_FORMAT single=true;

show file formats;

--11-April-2025 


-----

show stages;
show integrations;
show file formats;

alter warehouse compute_wh resume;

create table s_customer 
as 
select * from snowflake_sample_data.tpch_sf1000.customer;

create or replace  table t_customer 
as 
select * from snowflake_sample_data.tpch_sf1000.customer;


select count(*) from s_customer; -- 150000000
select count(*) from t_customer; -- 150000000

select 150000000/1000000; -- 150M 

select * from s_customer limit 2;
select  C_CUSTKEY,C_NAME,c_address,c_phone from s_customer limit 2;

insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000001,'Babu','Hyderabad','8789988776');

update s_customer set C_NAME='Tharun',c_address='Chennai',c_phone='7678877667' where C_CUSTKEY=1;

select * from s_customer where C_CUSTKEY=150000001;
select * from t_customer where C_CUSTKEY in (150000001,1);

CDC --> Change Data Capture 
Change --> insert,udpate,delete, truncate 
;

alter warehouse dev_wh resume;

merge into t_customer t --> 150M
using s_customer s  --> 150M
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and s.C_NAME<>t.C_NAME  then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone;




insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000002,'Sunil','Hyderabad','8789988776');

update s_customer set C_NAME='Sai',c_address='Chennai',c_phone='7678877667' where C_CUSTKEY=2;



select * from s_customer where C_CUSTKEY in (150000002,2);
select * from t_customer where C_CUSTKEY in (150000002,2);

create table t_changes 
as 
select * from s_customer where C_CUSTKEY in (150000002,2);

select * from t_changes;

merge into t_customer t --> 150M
using t_changes s  --> 2
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and s.C_NAME<>t.C_NAME  then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone;


show streams;

1) standard stream => Mode= Default --> insert,udapte,delete , trucate 
2) append_only stream 
3) insert_only stream 
;

create stream standard_stream
on table s_customer;

select * from standard_stream;

select system$stream_has_Data('standard_stream');-- FALSE    TRUE




insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000003,'Krishna','Hyderabad','8789988776');

delete from s_customer where C_CUSTKEY=100;

update s_customer set C_NAME='Navya',c_address='Chennai',c_phone='7678877667' where C_CUSTKEY=22;


METADATA$ACTION          METADATA$ISUPDATE
-------------------------------------------------------
INSERT                   FALSE                    ---> Insert 
DELETE                   FALSE                    ---> Delete 
INSERT	                 TRUE                     --> Latest record
DELETE	                 TRUE                     --> Old record
;
select * from s_customer where c_custkey in (150000003,100,22);
select * from t_customer where c_custkey in (150000003,100,22);

merge into t_customer t --> 150M
using standard_stream s  --> 2
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched and metadata$action='INSERT' and metadata$isupdate='FALSE' then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and metadata$action='INSERT' and metadata$isupdate='TRUE' then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone
when matched  and metadata$action='DELETE' and metadata$isupdate='FALSE' then 
delete;


select * from standard_stream;

insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000004,'kishore','Hyderabad','8789988776');

delete from s_customer where C_CUSTKEY=200;

update s_customer set C_NAME='Navya',c_address='Chennai',c_phone='7678877667' where C_CUSTKEY=500;
update s_customer set C_NAME='Navya',c_address='Banglore',c_phone='7678877667' where C_CUSTKEY=500;
update s_customer set C_NAME='Navya',c_address='Hyderbad',c_phone='7678877667' where C_CUSTKEY=500;

-- 500	Customer#000000500	fy7qx5fHLhcbFL93duj9	14-194-736-4233
select C_CUSTKEY,C_NAME,c_address,c_phone from t_customer where C_CUSTKEY=500;


select * from standard_stream;

insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000005,'Durage','Hyderabad','8789988776');

update s_customer set C_NAME='Durga' where C_CUSTKEY=150000005;

insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000006,'Sirisha','Hyderabad','8789988776');

update s_customer set c_address='Delhi' where C_CUSTKEY=150000006;

------------
select * from standard_stream;

insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000007,'Vijay','Hyderabad','8789988776');

update s_customer set c_address='Delhi' where C_CUSTKEY=150000007;

delete from s_customer where C_CUSTKEY=150000007;


----------

insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000007,'Vijay','Hyderabad','8789988776');

update s_customer set c_address='Delhi' where C_CUSTKEY=150000007;

show streams;


select current_timestamp(); -- 2025-04-11 07:29:39.447 -0700
                stale_after -- 2025-04-25 07:26:25.975 -0700
--14th 
;
show streams;


select * from STANDARD_STREAM;

alter warehouse dev_wh resume;


merge into t_customer t --> 150M
using standard_stream s  --> 2
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched and metadata$action='INSERT' and metadata$isupdate='FALSE' then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and metadata$action='INSERT' and metadata$isupdate='TRUE' then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone
when matched  and metadata$action='DELETE' and metadata$isupdate='FALSE' then 
delete;

create stream append_only_stream
on table s_customer
append_only=true;


show streams;


select * from APPEND_ONLY_STREAM;
select * from standard_STREAM;

select system$stream_has_Data('APPEND_ONLY_STREAM'); -- false 
select system$stream_has_Data('standard_STREAM'); -- false 


insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000010,'Tharun','Hyderabad','8789988776');

update s_customer set c_address='Delhi' where C_CUSTKEY=234;

delete from s_customer where C_CUSTKEY=45;


show external tables;



select * from EXT_CARS_INFO_new;

desc table EXT_CARS_INFO_new;

select get_ddl('TABLE','EXT_CARS_INFO_new');

create or replace external table EXT_CARS_INFO_NEW(
	MODEL VARCHAR(16777216) AS (CAST(GET(VALUE, 'model') AS VARCHAR)),
	MPG FLOAT AS (CAST(GET(VALUE, 'mpg') AS FLOAT)),
	CYL NUMBER(38,0) AS (TO_NUMBER(GET(VALUE, 'cyl'))),
	DISP FLOAT AS (CAST(GET(VALUE, 'disp') AS FLOAT)),
	HP NUMBER(38,0) AS (TO_NUMBER(GET(VALUE, 'hp'))),
	DRAT FLOAT AS (CAST(GET(VALUE, 'drat') AS FLOAT)),
	WT FLOAT AS (CAST(GET(VALUE, 'wt') AS FLOAT)),
	QSEC FLOAT AS (CAST(GET(VALUE, 'qsec') AS FLOAT)),
	VS NUMBER(38,0) AS (TO_NUMBER(GET(VALUE, 'vs'))),
	AM NUMBER(38,0) AS (TO_NUMBER(GET(VALUE, 'am'))),
	GEAR NUMBER(38,0) AS (TO_NUMBER(GET(VALUE, 'gear'))),
	CARB NUMBER(38,0) AS (TO_NUMBER(GET(VALUE, 'carb'))))
location=@S3_PARQUET_STAGE/
file_format=parquet_format
;

desc stage S3_PARQUET_STAGE;

["s3://bktapril20250403/stg_parquet_files/"]
;

;

create stream insert_only_Stream
on external table EXT_CARS_INFO_NEW
insert_only=true;


select * from insert_only_Stream;

alter external table EXT_CARS_INFO_NEW refresh;

select * from information_schema.external_tables;

;

select * from APPEND_ONLY_STREAM;
select * from standard_STREAM;
select * from insert_only_Stream;

show tasks;


create task task1
warehouse='dev_wh'
schedule='2 minutes'
as
merge into t_customer t --> 150M
using standard_stream s  --> 2
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched and metadata$action='INSERT' and metadata$isupdate='FALSE' then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and metadata$action='INSERT' and metadata$isupdate='TRUE' then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone
when matched  and metadata$action='DELETE' and metadata$isupdate='FALSE' then 
delete;

alter task task1 resume;

select * from table(information_Schema.task_history(TASK_NAME => 'task1' ));-- schedueld --> EXECUTING -->SUCCEEDED

--
2025-04-14 06:57:50.638 -0700
2025-04-14 06:56:29.425 -0700
2025-04-14 06:59:50.638 -0700
;

select current_timestamp();

select * from standard_stream;

show tasks;

alter task task1 suspend;



create task task2
warehouse='dev_wh'
schedule='2 minutes'
when system$stream_has_data('standard_Stream')
as
merge into t_customer t --> 150M
using standard_stream s  --> 2
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched and metadata$action='INSERT' and metadata$isupdate='FALSE' then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and metadata$action='INSERT' and metadata$isupdate='TRUE' then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone
when matched  and metadata$action='DELETE' and metadata$isupdate='FALSE' then 
delete;

show tasks;

alter task task2 resume;

select * from table(information_Schema.task_history(TASK_NAME => 'task2' ));-- schedueld --> EXECUTING -->SUCCEEDED
--> SKIPPED

2025-04-14 07:04:18.357 -0700
2025-04-14 07:02:42.103 -0700
;
select current_timestamp();

7.15 on 14 april monday
;

alter task task2 suspend;

show parameters like 'timezone';

* * * * *
1 2 3 4 5 

1--> minutes 0-59 
2--> hours  0-23 
3--> day of the month 1-31, 1-30 , 1-28 , 1-29  L
4--> month --> JAN-DEC  1-12
5--> day of the week sun-sat 0-6 

* * * * * --> every minutes

7.15 on 14 april monday
;
create task task3
warehouse='dev_wh'
schedule='using cron 15 7 14 4 1 America/Los_Angeles'
when system$stream_has_data('standard_Stream')
as
merge into t_customer t --> 150M
using standard_stream s  --> 2
on (t.C_CUSTKEY=s.C_CUSTKEY)
when not matched and metadata$action='INSERT' and metadata$isupdate='FALSE' then 
insert (C_CUSTKEY,C_NAME,c_address,c_phone)
values(C_CUSTKEY,C_NAME,c_address,c_phone)
when matched and metadata$action='INSERT' and metadata$isupdate='TRUE' then 
update set t.C_NAME=s.C_NAME,t.c_address=s.c_address ,t.c_phone=s.c_phone
when matched  and metadata$action='DELETE' and metadata$isupdate='FALSE' then 
delete;

alter task task3 resume;

select * from table(information_Schema.task_history(TASK_NAME => 'task3' ));

2025-04-14 07:15:00.010 -0700
2025-04-14 07:12:08.338 -0700
;
select current_timestamp();


insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000022,'Sai','Hyderabad','8789988776');

update s_customer set c_address='Hyderabad' where C_CUSTKEY=800;

delete from s_customer where C_CUSTKEY=95;

select * from t_customer where C_CUSTKEY in (150000022,800,95);



insert into s_customer(C_CUSTKEY,C_NAME,c_address,c_phone)
values(150000023,'Srikanth','Hyderabad','8789988776');

select * from t_customer where C_CUSTKEY in (150000023);

execute task task3 ;

select * from table(information_Schema.task_history(TASK_NAME => 'task3' ));


create task task5
warehouse='dev_wh'
schedule='2 minutes'
as
create or replace table t_dept(deptno nuber);


create task task6
warehouse='dev_wh'
after task5
as
insert into t_Dept values(10);

select * from table(information_Schema.task_dependents(task_name=>'task6'));
select * from table(information_Schema.task_dependents(task_name=>'task5'));--> findout the tasks that are dependent on task5 


show tasks;


alter task task5 resume;
alter task task6 resume;

alter task task5 suspend;

select system$task_dependents_enable('task5');

--15th 
alter warehouse dev_wh resume;

--UDF's
User Defined functions 
1) Scalar 
2) Tabular 
select * from information_schema.functions;

;
select current_timestamp();
select * from table(information_Schema.task_dependents(task_name=>'task5'));


create or replace function <function_name>(parameter data_Type)
return data_type
language sql/javascript/python
as 
$$



$$;


select * from emp_details;

show stages;

list @S3_CSV_STAGE;

show file formats;


copy into emp from @S3_CSV_STAGE/emp.csv file_format=FILE_CSV_FORMAT;

update emp set comm=500;
select * from emp where empno=7902;

create or replace function fn_net_Sal(p_empno number)
returns number
language sql
as 
$$

  select sal+nvl(comm,0) from emp where empno=p_empno

$$;


select fn_net_Sal(7902);

select * from emp where empno=7902;

update emp set hiredate='2019-04-15',sal=100000 where empno=7902;

select round((15 * 100000 *6) / 26);


select round((15*sal*6)/26) from emp where  empno=7902;
select round((15*sal*datediff('years',hiredate,current_Date()))/26) from emp where  empno=7902;


create or replace function fn_gratuity_Cal(p_empno number)
returns number
language sql
as 
$$

  select round((15*sal*datediff('years',hiredate,current_Date()))/26) from emp where  empno=p_empno

$$;


select fn_gratuity_Cal(7902);


select * from emp where empno=7839;

update emp set hiredate='2022-04-15' where empno=7839;

select fn_gratuity_Cal(7839);






create or replace function fn_tabular_info(p_deptno number)
returns table(empno number,ename varchar,sal number)
language sql
as 
$$

  select empno,ename,sal from emp where  deptno=p_deptno

$$;

select * from table(information_Schema.task_dependents(task_name=>'task5'));

select * from table(fn_tabular_info(p_deptno=>10));


select * from information_schema.procedures;

--sql 
select empno,ename,sal from emp where empno=7902;
--procedure 
select empno,ename,sal into variable1,variable2,variable3 from emp where empno=7902;
-- How to decalre a varaible 
varible_name data_Type;

-- How to assign a value to a variable 
varible_name:=value;

--- when you referring input paramters or varables, you need to : operator
: 
--
create or replace procedure procedure_name(parameter_name data_type)
returns data_type
language sql
as 
$$
 [declare]
   <declare the variables>
   <declare the cursors>   
 begin

 [exception]


 end;
  
$$;

create or replace procedure pr_emp_details(p_Empno number)
returns varchar
language sql
as 
$$
 declare
     v_ename varchar;
     v_sal number;
     v_comm number;
     v_net_Sal number;
 begin

    select ename,sal,comm into v_ename,v_sal,v_comm from emp where empno=:p_Empno;
     v_net_Sal:=:v_sal+nvl(:v_comm,0);

     return v_net_Sal;
 end;
  
$$;


call pr_emp_details(7902);

alter table emp add doe date;
alter table emp add gratuity number;

select * from emp where empno=7902;

update emp set doe ='2025-04-01' where empno=7902;

1) experience >=5
2) DOE it should not be null 
3) (15 * your last drawn salary * tenure of working) / 26
;


if (condition1) then 
 <>
elseif (condition2) tehn 
<>
else 
<>
end if;

create or replace procedure pr_emp_gratuity_Cal(p_Empno number)
returns varchar
language sql
as 
$$
 declare
     v_ename varchar;
     v_sal number;
     v_comm number;
     v_net_Sal number;
     v_hiredate date;
     v_experience number;
     v_gratuity number;
     v_doe date;
     v_eligible varchar;
     v_message varchar;
 begin

    select ename,sal,comm,hiredate,doe into v_ename,v_sal,v_comm,v_hiredate,v_doe from emp where empno=:p_Empno;
     v_experience:=datediff('years',:v_hiredate,current_Date());

      if (:v_experience>=5 and :v_doe is not null) then 
         v_eligible:='Y';
      else 
         v_eligible:='N';
      end if;

      if (v_eligible='Y') then 
          v_message:='Eligible for Gratuity';
          v_gratuity:=round((15 * :v_sal* :v_experience) / 26);
          update emp set gratuity=:v_gratuity where empno=:p_Empno;
      else 
          v_message:='Not eligible for Gratuity';      
      end if;

     return v_message;
 end;
  
$$;


call pr_emp_gratuity_Cal(7369);
call pr_emp_gratuity_Cal(7902);

select * from emp where empno=7369;
select * from emp where empno=7902;


update emp set hiredate ='2022-04-01',sal=45000 where empno=7369;




create or replace procedure pr_emp_gratuity_Cal(p_Empno number)
returns varchar
language sql
as 
$$
 declare
     v_ename varchar;
     v_sal number;
     v_comm number;
     v_net_Sal number;
     v_hiredate date;
     v_experience number;
     v_gratuity number;
     v_doe date;
     v_eligible varchar;
     v_message varchar;
 begin

    select ename,sal,comm,hiredate,doe into v_ename,v_sal,v_comm,v_hiredate,v_doe from emp where empno=:p_Empno;
     v_experience:=datediff('years',:v_hiredate,current_Date());

      v_eligible:=case when :v_experience>=5 and :v_doe is not null then 'Y'
      else 'N' end;

      if (v_eligible='Y') then 
          v_message:='Eligible for Gratuity';
          v_gratuity:=round((15 * :v_sal* :v_experience) / 26);
          update emp set gratuity=:v_gratuity where empno=:p_Empno;
      else 
          v_message:='Not eligible for Gratuity';      
      end if;

     return v_message;
 end;
  
$$;


call pr_emp_gratuity_Cal(7902);



--16th 
select * from emp;

show warehouses;

alter warehouse dev_wh set auto_Resume=true;


call pr_emp_gratuity_Cal(7902);

select * from emp where empno=7902;
call pr_emp_gratuity_Cal(7698);
select * from emp where empno=7698;

update emp set doe=current_Date-2 where empno=7698;


-- cursor 
--1) if you want to process record by record we can use curosr 
--2) declare the cursor 
--3) open the cursor 
--4) for loop 
;

--declare the cursor 
cursor_name cursor for <select statement>;
--open the cursor 
open cursor_name;
--for loop 
for <varaible> in cursor_name loop


end loop;



create or replace procedure pr_emp_gratuity_by_Cursor()
returns varchar
language sql
as 
$$
 declare
     c1 cursor for 
     select empno,ename,sal,comm,hiredate,doe  from emp ;
     v_ename varchar;
     v_sal number;
     v_comm number;
     v_net_Sal number;
     v_hiredate date;
     v_experience number;
     v_gratuity number;
     v_doe date;
     v_eligible varchar;
     v_message varchar;
     v_empno number;
 begin
    open c1;
    for i in c1 loop
      v_empno:=i.empno;
      v_ename:=i.ename;   
      v_Sal:=i.sal;
      v_comm :=i.comm;
      v_hiredate:=i.hiredate;
      v_doe:=i.doe;
      
       
     v_experience:=datediff('years',:v_hiredate,current_Date());

      v_eligible:=case when :v_experience>=5 and :v_doe is not null then 'Y'
      else 'N' end;

      if (:v_eligible='Y') then 
          v_message:='Eligible for Gratuity';
          v_gratuity:=round((15 * :v_sal* :v_experience) / 26);
          update emp set gratuity=:v_gratuity where empno=:v_empno;
      else 
          v_message:='Not eligible for Gratuity';      
      end if;
   end loop;
     return v_message;
 end;
  
$$;


update emp set gratuity=null;
update emp set doe=current_Date-2;

call pr_emp_gratuity_by_Cursor();

Uncaught exception of type 'STATEMENT_ERROR' on line 16 at position 4 : 
A SELECT INTO statement expects exactly 1 returned row, but got 25.
;
select * from emp ;


update emp set gratuity=null;
update emp set doe=current_Date-2;



create or replace procedure pr_emp_gratuity_by_Cursor(p_deptno number)
returns varchar
language sql
as 
$$
 declare
     c1 cursor for 
     select empno,ename,sal,comm,hiredate,doe  from emp where deptno=?;
     v_ename varchar;
     v_sal number;
     v_comm number;
     v_net_Sal number;
     v_hiredate date;
     v_experience number;
     v_gratuity number;
     v_doe date;
     v_eligible varchar;
     v_message varchar;
     v_empno number;
 begin
    open c1 using(:p_deptno);
    for i in c1 loop
      v_empno:=i.empno;
      v_ename:=i.ename;   
      v_Sal:=i.sal;
      v_comm :=i.comm;
      v_hiredate:=i.hiredate;
      v_doe:=i.doe;
      
       
     v_experience:=datediff('years',:v_hiredate,current_Date());

      v_eligible:=case when :v_experience>=5 and :v_doe is not null then 'Y'
      else 'N' end;

      if (:v_eligible='Y') then 
          v_message:='Eligible for Gratuity';
          v_gratuity:=round((15 * :v_sal* :v_experience) / 26);
          update emp set gratuity=:v_gratuity where empno=:v_empno;
      else 
          v_message:='Not eligible for Gratuity';      
      end if;
   end loop;
     return v_message;
 end;
  
$$;


call pr_emp_gratuity_by_Cursor(10);
call pr_emp_gratuity_by_Cursor(20);

select * from emp where deptno=10;
select * from emp where deptno=20;

--21-April-2025 

create or replace procedure pr_emp_gratuity_by_Cursor(p_deptno number)
returns varchar
language sql
as 
$$
 declare
     c1 cursor for 
     select empno,ename,sal,comm,hiredate,doe  from emp where deptno=?;
     v_ename varchar;
     v_sal number;
     v_comm number;
     v_net_Sal number;
     v_hiredate date;
     v_experience number;
     v_gratuity number;
     v_doe date;
     v_eligible varchar;
     v_message varchar;
     v_empno number;
 begin
    open c1 using(:p_deptno);
    for i in c1 loop
      v_empno:=i.empno;
      v_ename:=i.ename;   
      v_Sal:=i.sal;
      v_comm :=i.comm;
      v_hiredate:=i.hiredate;
      v_doe:=i.doe;
      
       
     v_experience:=datediff('years',:v_hiredate,current_Date());

      v_eligible:=case when :v_experience>=5 and :v_doe is not null then 'Y'
      else 'N' end;

      if (:v_eligible='Y') then 
          v_message:='Eligible for Gratuity';
          v_gratuity:=round((15 * :v_sal* :v_experience) / 26);
          update emp set gratuity=:v_gratuity where empno=:v_empno;
      else 
          v_message:='Not eligible for Gratuity';      
      end if;
   end loop;
     return v_message;
 end;
  
$$;

select * from information_Schema.procedures;

select get_ddl('TABLE','EMP');
CREATE TABLE EMP
       (EMPNO NUMBER(4) NOT NULL,
        ENAME VARCHAR2(10),
        JOB VARCHAR2(9),
        MGR NUMBER(4),
        HIREDATE DATE,
        SAL NUMBER(7, 2),
        COMM NUMBER(7, 2),
        DEPTNO NUMBER(2));
 
INSERT INTO EMP VALUES
        (7369, 'SMITH',  'CLERK',     7902,
        TO_DATE('17-DEC-1980', 'DD-MON-YYYY'),  800, NULL, 20);
INSERT INTO EMP VALUES
        (7499, 'ALLEN',  'SALESMAN',  7698,
        TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600,  300, 30);
INSERT INTO EMP VALUES
        (7521, 'WARD',   'SALESMAN',  7698,
        TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250,  500, 30);
INSERT INTO EMP VALUES
        (7566, 'JONES',  'MANAGER',   7839,
        TO_DATE('2-APR-1981', 'DD-MON-YYYY'),  2975, NULL, 20);
INSERT INTO EMP VALUES
        (7654, 'MARTIN', 'SALESMAN',  7698,
        TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30);
INSERT INTO EMP VALUES
        (7698, 'BLAKE',  'MANAGER',   7839,
        TO_DATE('1-MAY-1981', 'DD-MON-YYYY'),  2850, NULL, 30);
INSERT INTO EMP VALUES
        (7782, 'CLARK',  'MANAGER',   7839,
        TO_DATE('9-JUN-1981', 'DD-MON-YYYY'),  2450, NULL, 10);
INSERT INTO EMP VALUES
        (7788, 'SCOTT',  'ANALYST',   7566,
        TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, NULL, 20);
INSERT INTO EMP VALUES
        (7839, 'KING',   'PRESIDENT', NULL,
        TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, NULL, 10);
INSERT INTO EMP VALUES
        (7844, 'TURNER', 'SALESMAN',  7698,
        TO_DATE('8-SEP-1981', 'DD-MON-YYYY'),  1500,    0, 30);
INSERT INTO EMP VALUES
        (7876, 'ADAMS',  'CLERK',     7788,
        TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, NULL, 20);
INSERT INTO EMP VALUES
        (7900, 'JAMES',  'CLERK',     7698,
        TO_DATE('3-DEC-1981', 'DD-MON-YYYY'),   950, NULL, 30);
INSERT INTO EMP VALUES
        (7902, 'FORD',   'ANALYST',   7566,
        TO_DATE('3-DEC-1981', 'DD-MON-YYYY'),  3000, NULL, 20);
INSERT INTO EMP VALUES
        (7934, 'MILLER', 'CLERK',     7782,
        TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, NULL, 10);
        
create or replace TABLE EMP (
	EMPNO NUMBER(4,0) NOT NULL,
	ENAME VARCHAR(10),
	JOB VARCHAR(9),
	MGR NUMBER(4,0),
	HIREDATE DATE,
	SAL NUMBER(7,2),
	COMM NUMBER(7,2),
	DEPTNO NUMBER(2,0)
);



select get_ddl('PROCEDURE','pr_emp_gratuity_by_Cursor(number)');


select empno,ename,sal from emp where deptno=10;
create or replace procedure pr_emp_info(p_deptno number)
returns varchar
language sql  
as 
$$
declare
   v_empno number;
   v_ename varchar;
   v_Sal number;
   v_net number;

begin
   select empno,ename,sal into v_empno,v_ename,v_Sal from emp where deptno=:p_deptno;

   return 'procedure completed successfully';
end;


$$;



-- Uncaught exception of type 'STATEMENT_ERROR' on line 9 at position 3 : 
--A SELECT INTO statement expects exactly 1 returned row, but got 3.
call pr_emp_info(10);

-- cursor 

select empno,ename,sal from emp where deptno=10;
select empno,ename,sal from emp where empno=7782;
select empno,ename,sal from emp where empno=7839;
select empno,ename,sal from emp where empno=7934;


select empno,ename,sal from emp where deptno=10;

alter table emp add net_Sal number;

create or replace procedure pr_emp_info(p_deptno number)
returns varchar
language sql  
as 
$$
declare
   v_empno number;
   v_ename varchar;
   v_Sal number;
   v_comm number;
   v_net number;
   c1 cursor for select empno,ename,sal,comm  from emp where deptno=?;

begin
  open c1 using(:p_deptno);
   for i in c1 loop 
      v_empno:=i.empno;
      v_ename:=i.ename;
      v_Sal:=i.sal;
      v_comm:=i.comm;
      v_net:=nvl(:v_sal,0)+nvl(:v_comm,0);
      update emp set net_Sal=:v_net where empno=:v_empno;
   end loop;
   return 'procedure completed successfully';
end;
$$;


select * from emp where deptno=10;
select * from emp where deptno=20;

call pr_emp_info(10);
call pr_emp_info(20);
call pr_emp_info(30);
select * from emp where deptno=30;



select get_ddl('PROCEDURE','pr_emp_info(number)');

create warehouse dev_wh;

create user babu 
password='Krishna@123';

create role marketing_role;

grant role marketing_role to user babu;

grant usage on database dev_Db to role marketing_role;
grant usage on schema dev_schema to role marketing_role;
grant usage on warehouse dev_Wh to role marketing_role;
grant usage on procedure pr_emp_info(number) to role marketing_role;


select * from emp ;

update emp set net_Sal=null;



create or replace procedure pr_emp_info_caller(p_deptno number)
returns varchar
language sql  
execute as caller
as 
$$
declare
   v_empno number;
   v_ename varchar;
   v_Sal number;
   v_comm number;
   v_net number;
   c1 cursor for select empno,ename,sal,comm  from emp where deptno=?;

begin
  open c1 using(:p_deptno);
   for i in c1 loop 
      v_empno:=i.empno;
      v_ename:=i.ename;
      v_Sal:=i.sal;
      v_comm:=i.comm;
      v_net:=nvl(:v_sal,0)+nvl(:v_comm,0);
      update emp set net_Sal=:v_net where empno=:v_empno;
   end loop;
   return 'procedure completed successfully';
end;
$$;


grant usage on procedure pr_emp_info_caller(number) to role marketing_role;

call pr_emp_info_caller(10);

update emp set net_Sal=null;

select * from emp;

grant select on emp to role marketing_role;
grant update on emp to role marketing_role;

select * from t_Emp;


create or replace procedure pr_emp_info_exp_1(p_deptno number)
returns varchar
language sql  
execute as caller
as 
$$
declare
   v_empno number;
   v_ename varchar;
   v_Sal number;
   v_comm number;
   v_net number;
   c1 cursor for select empno,ename,sal,comm  from t_emp where deptno=?;

begin
  open c1 using(:p_deptno);
   for i in c1 loop 
      v_empno:=i.empno;
      v_ename:=i.ename;
      v_Sal:=i.sal;
      v_comm:=i.comm;
      v_net:=nvl(:v_sal,0)+nvl(:v_comm,0);
      update emp set net_Sal=:v_net where empno=:v_empno;
   end loop;
   return 'procedure completed successfully';

exception
when STATEMENT_ERROR then 
return concat(sqlcode,'----',sqlerrm);
   
end;
$$;


call pr_emp_info_exp_1(10);


create or replace procedure pr_emp_info_exp_2(p_deptno number)
returns varchar
language sql  
execute as caller
as 
$$
declare
   v_empno number;
   v_ename number;
   v_Sal number;
   v_comm number;
   v_net number;
   c1 cursor for select empno,ename,sal,comm  from emp where deptno=?;

begin
  open c1 using(:p_deptno);
   for i in c1 loop 
      v_empno:=i.empno;
      v_ename:=i.ename;
      v_Sal:=i.sal;
      v_comm:=i.comm;
      v_net:=nvl(:v_sal,0)+nvl(:v_comm,0);
      update emp set net_Sal=:v_net where empno=:v_empno;
   end loop;
   return 'procedure completed successfully';

exception
when STATEMENT_ERROR then 
return concat(sqlcode,'----',sqlerrm);
when expression_ERROR then 
return concat(sqlcode,'----',sqlerrm);   
end;
$$;

call pr_emp_info_exp_2(10);



create or replace procedure pr_emp_info_exp_3(p_deptno number)
returns varchar
language sql  
execute as caller
as 
$$
declare
   v_empno number;
   v_ename varchar;
   v_Sal number;
   v_comm number;
   v_net number;
   c1 cursor for select empno,ename,sal,comm  from t_emp where deptno=?;

begin
  open c1 using(:p_deptno);
   for i in c1 loop 
      v_empno:=i.empno;
      v_ename:=i.ename;
      v_Sal:=i.sal;
      v_comm:=i.comm;
      v_net:=nvl(:v_sal,0)+nvl(:v_comm,0);
      update emp set net_Sal=:v_net where empno=:v_empno;
   end loop;
   return 'procedure completed successfully';

exception
when other then
return concat(sqlcode,'----',sqlerrm);   
end;
$$;

call pr_emp_info_exp_3(10);



create or replace procedure pr_emp_info_exp_3(p_deptno number)
returns varchar
language sql  
execute as caller
as 
$$
declare
   v_empno number;
   v_ename number;
   v_Sal number;
   v_comm number;
   v_net number;
   c1 cursor for select empno,ename,sal,comm  from emp where deptno=?;

begin
  open c1 using(:p_deptno);
   for i in c1 loop 
      v_empno:=i.empno;
      v_ename:=i.ename;
      v_Sal:=i.sal;
      v_comm:=i.comm;
      v_net:=nvl(:v_sal,0)+nvl(:v_comm,0);
      update emp set net_Sal=:v_net where empno=:v_empno;
   end loop;
   return 'procedure completed successfully';

exception
when other then
return concat(sqlcode,'----',sqlerrm);   
end;
$$;

call PR_EMP_INFO_EXP_3(10);

select * from emp; -- 7369 , 7900 



create or replace procedure pr_emp_info_exp_4(p_empno number)
returns varchar
language sql  
execute as caller
as 
$$
declare
   v_empno number;
   v_ename varchar;
   v_Sal number;
   v_comm number;
   v_net number;
   exp_Sal exception(-20002,'Employee salary is <1000..'); --> -20000 to -20999
  
begin
     select empno,ename,sal,comm into v_empno,v_ename,v_Sal,v_comm from emp where empno=:p_empno;

      if (:v_Sal<1000) then 
         raise exp_Sal;
      end if;
     
   return 'procedure completed successfully';

exception
when exp_Sal then
return concat(sqlcode,'----',sqlerrm);   
end;
$$;

call pr_emp_info_exp_4(7369);













---22nd 
show masking policies; --> column level security , row level security 

create table s_customer 
as 
select * from snowflake_sample_data.tpch_sf1.customer;

select * from s_customer;

show users;


create user rahul
password='Krishna@123';

create role dev_new_role;

grant role dev_new_role to user rahul;

grant usage on database test_db to role dev_new_role;
grant usage on schema test_schema to role dev_new_role;
grant usage on warehouse dev_wh to role dev_new_role;
grant select  on table s_customer to role dev_new_role;
grant select  on table emp to role dev_new_role;



create masking policy mask_phone as (C_PHONE varchar) returns varchar->
case when current_Role() in ('ACCOUNTADMIN') then C_PHONE
else '**-***-***-****'
end;

select * from s_customer;

select * from table(information_Schema.policy_references(POLICY_NAME => 'mask_phone'));

alter table s_customer modify column C_PHONE set masking policy mask_phone;

create sequence s1;

drop masking policy mask_balance;

create masking policy mask_balance as (val number) returns number->
case when current_Role() in ('ACCOUNTADMIN') then val
else s1.nextval
end;

select * from table(information_Schema.policy_references(POLICY_NAME => 'mask_balance'));

alter table s_customer modify column C_ACCTBAL set masking policy mask_balance;
alter table emp modify column sal set masking policy mask_balance;

select * from emp;

grant usage on sequence s1 to role dev_new_role;


create user ind_user
password='Krishna@123';

create role ind_role;

grant role ind_role to user ind_user;

grant usage on database test_db to role ind_role;
grant usage on schema test_schema to role ind_role;
grant usage on warehouse dev_wh to role ind_role;
grant select  on table s_customer to role ind_role;
grant select  on table emp to role ind_role;

--
create user germany_user
password='Krishna@123';

create role germany_role;

grant role germany_role to user germany_user;

grant usage on database test_db to role germany_role;
grant usage on schema test_schema to role germany_role;
grant usage on warehouse dev_wh to role germany_role;
grant select  on table s_customer to role germany_role;
grant select  on table emp to role germany_role;


ind_role     -->
germany_role -->
;

select * from s_customer; -- 150k

C_NATIONKEY;

create table t_nation 
as 
select * From snowflake_sample_data.tpch_sf1.nation;



select * From t_nation;

7	GERMANY
8	INDIA
;
select * From s_customer ; -- 150k 
select * From s_customer where c_nationkey=8; --> ind_role--> 6 k
select * From s_customer where c_nationkey=7; --> germany_role--> 5.9 k

grant usage on sequence s1 to role germany_role;
grant usage on sequence s1 to role ind_role;

create table t_role_map(role_name varchar,nation_key number);

insert into t_role_map values('IND_ROLE',8);
insert into t_role_map values('GERMANY_ROLE',7);


select * from t_role_map;


show row access policies;


create row access policy row_access_policy as (c_nation_name number) returns boolean->
current_Role() in ('ACCOUNTADMIN') 
or exists(
(select 1 from t_role_map where current_role()=role_name and c_nation_name=nation_key)
);

alter table s_customer add row access policy row_access_policy on (C_NATIONKEY);

select * from s_customer;

select * from t_role_map;


create or replace row access policy row_access_policy_new as (c_nation_name number) returns boolean->
current_Role() in ('ACCOUNTADMIN') 
or ( current_role() in('GERMANY_ROLE') and c_nation_name in (7))
or ( current_role() in('IND_ROLE') and c_nation_name in (8))
;


alter table s_customer drop row access policy row_access_policy ;

alter table s_customer add row access policy row_access_policy_new on (C_NATIONKEY);


alter table s_customer drop row access policy row_access_policy_new ;



--
--25th
show masking policies;

drop masking policy MASK_BALANCE;

select * from table(information_Schema.policy_references(POLICY_NAME => 'MASK_BALANCE'));

alter table EMP modify column sal unset masking policy;
alter table S_CUSTOMER modify column C_ACCTBAL unset masking policy;

;

select * from information_schema.table_storage_metrics where table_name='S_CUSTOMER';

drop table S_CUSTOMER;


create table S_CUSTOMER
as 
select * from snowflake_sample_data.tpch_sf1.customer;


Oracle --> T_CUSTOMER  --> Snowflake --> T_CUSTOMER

IICS --> 
Informatica--> 
1) Mapping --> source(oracle) --> Target(snowflake)
2) Task --> will be used to call the mapping
3) Run the task 


Mapping --> Dataintegraion

;

CREATE or replace TABLE EMP
       (EMPNO NUMBER(4) NOT NULL,
        ENAME VARCHAR2(10),
        JOB VARCHAR2(9),
        MGR NUMBER(4),
        HIREDATE DATE,
        SAL NUMBER(7, 2),
        COMM NUMBER(7, 2),
        DEPTNO NUMBER(2));

select * From emp;


Data Build Tool:-
---------------------
Transformations 

ETL --> 

Extation from Source 
Loading to Target 
Transformation --> DBT 
;


-- 
UI   --> Snowsight
CLI  --> snowsql 

DBT -->
-------------
UI   --> dbt cloud 
CLI  --> DBTcore 

DBTcore:
------------
1) Python 
2) Anaconda 
3) Visual Studio 


ORacle --> informatica/Fivetran --> Snowflake 

ELT 
Informatica,TAlesn,Datastage --> ETL 
DBT ---------------------------> ELT



Unable to complete this git action
Unable to complete a git action. If you think this is an error, please contact support.
git reset HEAD^
fatal: ambiguous argument 'HEAD^': unknown revision or path not in the working tree.
Use '--' to separate paths from revisions, like this:
'git <command> [<revision>...] -- [<file>...]'
Close


--- model1 
with c_india_customer as 
(
select * from test_db.test_Schema.s_customer where c_nationkey=8 and C_MKTSEGMENT='FURNITURE'
and C_ACCTBAL>9000
)
select * from c_india_customer
--model2












-- 
using DBT i want to do the tranforamtions 

-- 
Model is nothing but a select statment which contains the business logic or 
the transformation that you want to apply .
;
select * from s_customer;


create table  s_customer
as 
select * from snowflake_sample_data.tpch_sf1.customer;

select * from s_customer where c_nationkey=8 and C_MKTSEGMENT='FURNITURE'
and C_ACCTBAL>9000;

-- 1) Preapre the select statement 
with c_india_customer as 
(
select * from test_Db.test_Schema.s_customer where c_nationkey=8 and C_MKTSEGMENT='FURNITURE'
and C_ACCTBAL>9000
)
select * from c_india_customer;

-- create teh model 

-- run the model 
dbt run --select t_ind_customer.sql
;

select * from dbt_schema.t_ind_customer;

select * from information_schema.tables where is_transient='YES';

drop table t_ind_customer;

show tables;



show file formats;

create file format my_csv_format 
type=csv 
field_delimiter=','
skip_header=1;

create or replace table orders ( order_id number,customer_id number,order_Date date ,status varchar);
;

copy into orders (order_id,customer_id,order_Date,status)
from 's3://dbt-tutorial-public/jaffle_shop_orders.csv' file_format=(format_name=my_csv_format);

create or replace table customers ( customer_id number,first_name varchar,last_name varchar);

copy into customers (customer_id,first_name,last_name)
from 's3://dbt-tutorial-public/jaffle_shop_customers.csv' file_format=(format_name=my_csv_format);


create table payment ( id number,orderid number,paymentmethod varchar,
status varchar,amount number,created date,_batched_at timestamp default current_timestamp);

copy into payment (id,orderid,paymentmethod,status,amount,created)
from 's3://dbt-tutorial-public/stripe_payments.csv' file_format=(format_name=my_csv_format);

-- CTE 
--Common Table Expression 

with customers as (
select
customer_id as customer_id,
first_name,
last_name
from dev_db.dev_Schema.customers
),
orders as (
select
order_id as order_id,
customer_id as customer_id,
order_date,
status
from dev_db.dev_Schema.orders
),
customer_orders as (
select
customer_id,
min(order_date) as first_order_date,
max(order_date) as most_recent_order_date,
count(*) as number_of_orders
from dev_db.dev_Schema.orders
group by 1
),
final as (
select
customers.customer_id,
customers.first_name,
customers.last_name,
customer_orders.first_order_date, customer_orders.most_recent_order_date,
coalesce (customer_orders.number_of_orders, 0) as number_of_orders
from customers
left join customer_orders on customers.customer_id=customer_orders.customer_id
)
select * from final;

;



with customers as (
select * from {{ ref('customers') }}
),
orders as (
select * from {{ ref('orders') }}
),
customer_orders as (
select
order_id,
min(order_date) as first_order_date,
max(order_date) as most_recent_order_date,
count(order_id) as number_of_orders
from dev_db.dev_Schema.orders
group by 1
),
final as (
select
customers.customer_id,
customers.first_name,
customers.last_name,
customer_orders.first_order_date, customer_orders.most_recent_order_date,
coalesce (customer_orders.number_of_orders, 0) as number_of_orders
from customers
left join customer_orders on customer_id=customer_id
)
select * from final;

select id as payment_id, 
  orderid as order_id, 
  paymentmethod as payment_method, 
  status,
amount / 100 as amount, 
created as created_at
from payment;


-- How to execute one model in DBT 
dbt run --select stg_payments.sql


with order_new as (
select * from orders
),
payments as (
select * from  payment
),
order_payments as
(
select orderid,
sum(case when status = 'success' then amount end) as amount
 from payment
 group by 1
),
final as(
select
orders.order_id,
orders.customer_id,
orders.order_date,
coalesce (order_payments.amount, 0) as amount
from order_new orders
left join order_payments on orderid=order_id
)
select * from final;



models are nothing but sql statements. .sql 
.sql will be available in models directory 
here we have simple selects. or CTE ( with clause)



dbt run 


models build as  views if run the model 


The default behaviour of the DBT is to build a view when we execute a model .

config 



--------------------

ref  --> inside the model you are refering other models 



{{config(materialized='table')}}
select 1 as ticket_id , 'complete' ticket_Status, '2025-01-01' as update_Date
union all 
select 2 as ticket_id , 'new' ticket_Status, '2025-01-01' as update_Date
union all
select 3 as ticket_id , 'new' ticket_Status, '2025-01-01' as update_Date


{% snapshot change_track %}
{{

config(
    target_schema='dbt_Schema',
    strategy='check',
    unique_key='ticket_id',
    check_cols=['ticket_Status']
)
}}
select * from {{ref("customer")}}

{% endsnapshot %}




---

create database prod_db;

create schema prod_schema;



select 1 as ticket_id , 'new' ticket_Status, '2025-01-01' as update_Date
union all 
select 2 as ticket_id , 'new' ticket_Status, '2025-01-01' as update_Date
union all
select 3 as ticket_id , 'new' ticket_Status, '2025-01-01' as update_Date;

select * From dbt_Schema.customer;

select * From dbt_Schema.change_Track;

update dbt_Schema.customer set ticket_Status='closed' where ticket_id=1; 

update dbt_Schema.customer set ticket_Status='Archived' where ticket_id=1; 


create file format my_csv_format 
type=csv 
field_delimiter=','
skip_header=1;

create or replace table orders ( order_id number,customer_id number,order_Date date ,status varchar);
;

copy into orders (order_id,customer_id,order_Date,status)
from 's3://dbt-tutorial-public/jaffle_shop_orders.csv' file_format=(format_name=my_csv_format);

create table t_audit_log(id number autoincrement start 1 increment 1 order,
audit_type varchar,
model_name varchar,
created_Date timestamp default current_timestamp()
);


select * from t_audit_log;

insert into t_audit_log(audit_type,model_name) values('started','customer');
insert into t_audit_log(audit_type,model_name) values('ended','customer');


insert into t_audit_log(audit_type,model_name) values('started','orders');
insert into t_audit_log(audit_type,model_name) values('ended','orders');

delete from t_audit_log;

Prehook
Posthook
;
-----------------------------
------

select * from t_audit_log;


create table t_dbt_audit_log(id number autoincrement start 1 increment 1 order,
audit_type varchar,
created_Date timestamp default current_timestamp()
);


select * from t_dbt_audit_log;


show views;
show materialized views;


show users;

show roles;


grant usage on database prod_db to role dev_new_role;
grant usage on schema prod_schema to role dev_new_role;
grant usage on warehouse dev_wh to role dev_new_role;

show tables;


create table t_Customer 
as 
select * from snowflake_sample_data.tpch_sf1.customer;

create table t_nation
as 
select * from snowflake_sample_data.tpch_sf1.nation;

grant select on table t_Customer to role dev_new_role;
grant select on table t_nation to role dev_new_role;



select * from information_schema.views;
-- IS_SECURE



---***

show views;
show materialized views;

select * from information_schema.views;

show users;

create table s_customer
as 
select * from snowflake_sample_data.tpch_sf1.customer;


select * from s_customer;

create view v_ind_customers as 
select c_custkey,c_name,c_address from s_customer
where c_nationkey=8;

select * From v_ind_customers;

grant select on view v_ind_customers to role dev_new_role;
 
 
create secure view sv_ind_customers as 
select c_custkey,c_name,c_address from s_customer
where c_nationkey=8;


grant select on view v_ind_customers to role dev_new_role;
grant select on view sv_ind_customers to role dev_new_role;

show views;

create or replace table t_nation
as 
select * from snowflake_sample_data.tpch_sf1.nation;

select * from t_nation;
select * from s_customer;

create  view v_cntry_wise_info
as 
select c_custkey,c_name,c_address,n_name
from s_customer inner join t_nation on N_NATIONKEY=C_NATIONKEY;

create secure view sv_cntry_wise_info
as 
select c_custkey,c_name,c_address,n_name
from s_customer inner join t_nation on N_NATIONKEY=C_NATIONKEY;


grant select on view sv_cntry_wise_info to role dev_new_role;
grant select on view v_cntry_wise_info to role dev_new_role;

select * from information_schema.table_storage_metrics where table_name ='SV_CNTRY_WISE_INFO';

create table emp(empno number,ename varchar);

select * from information_schema.table_storage_metrics where table_name ='EMP';

select * from information_schema.table_storage_metrics where table_name ='S_CUSTOMER';  


create materialized view mv_cntry_wise_info
as 
select C_NATIONKEY,sum(c_acctbal) as acct_bal
from s_customer  
group by C_NATIONKEY;

select * from information_schema.table_storage_metrics where table_name ='MV_CNTRY_WISE_INFO';  

show views;


grant select on materialized view mv_cntry_wise_info to role dev_new_role;

create secure materialized view smv_cntry_wise_info
as 
select C_NATIONKEY,sum(c_acctbal) as acct_bal
from s_customer  
group by C_NATIONKEY;

grant select on materialized view smv_cntry_wise_info to role dev_new_role;

--Invalid materialized view definition. 
--More than one table referenced in the view definition

create materialized view mv_cntry_wise_info_new
as 
select C_NATIONKEY,n_name,sum(c_acctbal)
from s_customer inner join t_nation on N_NATIONKEY=C_NATIONKEY
group by C_NATIONKEY,n_name;

--
---1) if you are performing any aggrigate operations 
--2) if the data is not frequently changing 
--3) it will refresh automatically once the underlying table data got changed 
--4) There is strage cost and refresh cost 

create materialized view mv_cntry_wise_info
as 
select C_NATIONKEY,sum(c_acctbal) as total_Acct_bal
from s_customer 
group by C_NATIONKEY;


select * from information_schema.table_storage_metrics where table_name ='MV_CNTRY_WISE_INFO';  


select * from mv_cntry_wise_info;

select * from mv_cntry_wise_info where c_nationkey=8;

8	27293627.48
8	54587254.96
;

insert into s_customer 
select * from s_customer where c_nationkey=8;

grant select on view MV_CNTRY_WISE_INFO to share test_share;

create secure materialized view smv_ctry_wise_info
as 
select C_NATIONKEY,sum(c_acctbal) as total_Acct_bal
from s_customer 
group by C_NATIONKEY;

grant select on view smv_ctry_wise_info to role  dev_new_role;


show dynamic tables;


create or replace dynamic table t_refresh_Data
    target_lag = '2 minutes'
    warehouse = 'DEV_WH'
     comment='To refresh the data from multiple tables'
    as
select C_NATIONKEY,n_name,sum(c_acctbal) as acct_Bal
from s_customer inner join t_nation on N_NATIONKEY=C_NATIONKEY
group by C_NATIONKEY,n_name;

select * from table(information_schema.dynamic_table_refresh_history());

delete from t_nation where n_nationkey=9;

alter dynamic table T_REFRESH_DATA refresh;


select * from t_refresh_Data;


select * from t_nation;
select * From s_customer;



delete from t_nation where n_nationkey in (10,11,12);

--- 13th 
PyCharm Community Edition
snowflake-python-connector  --> package 




USE SCHEMA snowflake_sample_data.tpcds_sf10tcl;

select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from store_sales
    ,item
    ,time_dim, store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;


1) result cache 
2) local disk cache or warehouse cache 
3) metadata cache  --> Metadata absed result , metadata operation 

;

select count(*) from store_sales;

select 28800239865/1000000;

select * from information_schema.tables;


;

alter session set use_Cached_Result=false;



---15th 

1) result cache 
2) local disk cache or warehouse cache 
3) metadata cache  --> Metadata absed result , metadata operation 
;

select * from store_sales limit 2 ;

select count(*) from store_sales;
select max(SS_SOLD_DATE_SK) from store_sales;
select * from information_schema.tables where table_type='BASE TABLE';

alter session set use_Cached_Result=false;


use database dev_db;
use schema dev_schema;

select * from information_schema.tables where table_type='BASE TABLE';


create table store_sales
as 
select * from snowflake_sample_data.tpcds_sf10tcl.store_sales;

create table item
as 
select * from snowflake_sample_data.tpcds_sf10tcl.item;

create table time_dim
as 
select * from snowflake_sample_data.tpcds_sf10tcl.time_dim;

alter warehouse compute_wh suspend;

create table store
as 
select * from snowflake_sample_data.tpcds_sf10tcl.store;

select * from time_dim where T_HOUR=10;

Percentage scanned from cache 0.00%
Percentage scanned from cache 100.00%



alter session set use_Cached_Result=false;

show parameters like 'use_Cached_Result';


alter session set use_Cached_Result=true;


select * from time_dim where T_HOUR=10;

insert into time_dim
select * from time_dim where T_HOUR=10;


select * from time_dim where t_hour=10;

;

select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from snowflake_sample_data.tpcds_sf10tcl.store_sales
    ,snowflake_sample_data.tpcds_sf10tcl.item
    ,snowflake_sample_data.tpcds_sf10tcl.time_dim,
    snowflake_sample_data.tpcds_sf10tcl.store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;

Query Acceleration Service --> QAS 
8*warehouse size 

8--> Scaling Factor
16
32

without QAS  X-small        --> 10 mins 
with QAS     X-small   8    --> 5 mins      
with QAS     X-small   16   --> 1 min
with QAS     X-small   32   --> 2 seconds 

Scaling factor --> 8 , 16 ,32 


query_id or satement_id --> 01bc5ad5-3201-9cf5-000c-f5de000461fe  --> 10 mins 

;
show warehouses;

enable_query_acceleration =false 
query_acceleration_max_scale_factor=8
;
select system$estimate_query_acceleration('01bc5ad5-3201-9cf5-000c-f5de000461fe');

select parse_json(system$estimate_query_acceleration('01bc5ad5-3201-9cf5-000c-f5de000461fe'));


{
  "estimatedQueryTimes": {
    "1": 316,
    "2": 219,
    "26": 47,
    "4": 142,
    "8": 90
  },
  "originalQueryTime": 602.303,
  "queryUUID": "01bc5ad5-3201-9cf5-000c-f5de000461fe",
  "status": "eligible",
  "upperLimitScaleFactor": 26
}
;

alter warehouse compute_wh set enable_query_acceleration =true; 
alter warehouse compute_wh set query_acceleration_max_scale_factor=26;

show warehouses;

;

alter session set use_Cached_Result=false;

select * from time_dim where T_HOUR=10;




select parse_json(system$estimate_query_acceleration('01bc5ae4-3201-9cf5-000c-f5de00046226'));

{
  "estimatedQueryTimes": {},
  "originalQueryTime": 0.187,
  "queryUUID": "01bc5ae4-3201-9cf5-000c-f5de00046226",
  "status": "ineligible",
  "upperLimitScaleFactor": 0
}

;

select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from snowflake_sample_data.tpcds_sf10tcl.store_sales
    ,snowflake_sample_data.tpcds_sf10tcl.item
    ,snowflake_sample_data.tpcds_sf10tcl.time_dim,
    snowflake_sample_data.tpcds_sf10tcl.store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;

select * from snowflake.account_usage.query_acceleration_eligible;


--16th 



---16th
select * from information_schema.tables where table_type='BASE TABLE';


explain  using text
select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from snowflake_sample_data.tpcds_sf10tcl.store_sales
    ,snowflake_sample_data.tpcds_sf10tcl.item
    ,snowflake_sample_data.tpcds_sf10tcl.time_dim,
    snowflake_sample_data.tpcds_sf10tcl.store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;


explain  using tabular
select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from snowflake_sample_data.tpcds_sf10tcl.store_sales
    ,snowflake_sample_data.tpcds_sf10tcl.item
    ,snowflake_sample_data.tpcds_sf10tcl.time_dim,
    snowflake_sample_data.tpcds_sf10tcl.store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;


explain  using json
select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from snowflake_sample_data.tpcds_sf10tcl.store_sales
    ,snowflake_sample_data.tpcds_sf10tcl.item
    ,snowflake_sample_data.tpcds_sf10tcl.time_dim,
    snowflake_sample_data.tpcds_sf10tcl.store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;

select system$clustering_information('item');

alter table item cluster by (i_item_sk,i_item_id);
alter table item cluster by (I_REC_START_DATE);


select count(*) from item; -- 402000
select count(distinct i_item_sk,i_item_id) from item; -- 402000
select count(distinct I_REC_START_DATE) from item; -- 4
select * from item;

select distinct I_REC_START_DATE from item; -- 4


explain  using tabular
select store.s_store_id, item.i_item_id, sum(ss_sales_price) ss_sales_price
from store_sales
    ,item
    ,time_dim,
    store
where I_REC_START_DATE='2000-10-27'
and ss_sold_time_sk = time_dim.t_time_sk
    and ss_item_sk = item.i_item_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and store.s_store_name = 'ese'
group by store.s_store_id, item.i_item_id
;




select get_ddl('TABLE','ITEM');

create or replace TABLE ITEM cluster by (I_REC_START_DATE)(
	I_ITEM_SK NUMBER(38,0),
	I_ITEM_ID VARCHAR(16),
	I_REC_START_DATE DATE,
	I_REC_END_DATE DATE,
	I_ITEM_DESC VARCHAR(200),
	I_CURRENT_PRICE NUMBER(7,2),
	I_WHOLESALE_COST NUMBER(7,2),
	I_BRAND_ID NUMBER(38,0),
	I_BRAND VARCHAR(50),
	I_CLASS_ID NUMBER(38,0),
	I_CLASS VARCHAR(50),
	I_CATEGORY_ID NUMBER(38,0),
	I_CATEGORY VARCHAR(50),
	I_MANUFACT_ID NUMBER(38,0),
	I_MANUFACT VARCHAR(50),
	I_SIZE VARCHAR(20),
	I_FORMULATION VARCHAR(20),
	I_COLOR VARCHAR(20),
	I_UNITS VARCHAR(10),
	I_CONTAINER VARCHAR(10),
	I_MANAGER_ID NUMBER(38,0),
	I_PRODUCT_NAME VARCHAR(50)
);


create table item
as 
select * from snowflake_sample_data.tpcds_sf10tcl.item
cluster by I_REC_START_DATE;



C:\Users\Balakrishna>snowsql -a nbhvhdc-wp31641 -u krishna
Password:
* SnowSQL * v1.3.3
Type SQL statements or !help
krishna#COMPUTE_WH@(no database).(no schema)>use DATABASE DEV_DB;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.112s
krishna#COMPUTE_WH@DEV_DB.PUBLIC>use SCHEMA DEV_SCHEMA;
+----------------------------------+
| status                           |
|----------------------------------|
| Statement executed successfully. |
+----------------------------------+
1 Row(s) produced. Time Elapsed: 0.103s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>put file://C:\Users\Balakrishna\Desktop\New\STG_FILES\PD_58.csv @STG_CSV_FILES;
+-----------+--------------+-------------+-------------+--------------------+--------------------+----------+---------+
| source    | target       | source_size | target_size | source_compression | target_compression | status   | message |
|-----------+--------------+-------------+-------------+--------------------+--------------------+----------+---------|
| PD_58.csv | PD_58.csv.gz |        2254 |         512 | NONE               | GZIP               | UPLOADED |         |
+-----------+--------------+-------------+-------------+--------------------+--------------------+----------+---------+
1 Row(s) produced. Time Elapsed: 4.338s
krishna#COMPUTE_WH@DEV_DB.DEV_SCHEMA>


select * from t_Range;
show stages;
show file formats;

create file format csv_format 
type=csv 
;

create stage STG_CSV_FILES ;

alter stage STG_CSV_FILES set file_format=csv_format;

select * from t_prod_info;


delete from t_prod_info;

;

select * from information_schema.table_storage_metrics where table_name='STORE_SALES';

select table_name,(active_bytes/1024/1024/1024) as gb from information_schema.table_storage_metrics where table_name='STORE_SALES'
and TABLE_DROPPED is null;


create table bkp_store_item
as 
select * from STORE_SALES;
--- zero copy clonning 

create table bkp_store_item
clone STORE_SALES;

select count(*) from bkp_store_item; -- 28800239865
select count(*) from STORE_SALES;    -- 28800239865

select * from information_schema.table_storage_metrics where table_name in ('STORE_SALES','BKP_STORE_ITEM');
;

delete from STORE_SALES where SS_SOLD_DATE_SK =2451168;

select count(*) from STORE_SALES where SS_SOLD_DATE_SK =2451168; -- 0

select count(*) from BKP_STORE_ITEM where SS_SOLD_DATE_SK =2451168; -- 30052465


delete from BKP_STORE_ITEM where SS_SOLD_DATE_SK =2451167; --  30032483 

select count(*)  from STORE_SALES where SS_SOLD_DATE_SK =2451167; --  30032483







---20th 
show resource monitors;

create warehouse prod_Wh;
create warehouse qa_wh;


select current_Account(); -- RM18424 --> 4 warehouses 


on each warehouse --> 10 credits in a month 
accounts --> 40 credits 

account:-
20 credits --> Notify
24 credits --> Notify
32 credits --> suspend 
36 credits --> suspend immediately

;

show tables;

select * from T_PROD_INFO;


nbhvhdc-wp31641
krishna
Happybirthday9
dev_Db
dev_schema
qa_wh


select * from T_PROD_INFO


;

--Resource Monitor:-
warehouse :-

Credit Card:-
-------------
100000

50%   --> 
80%   --> 
100%  --> 


--> Warehouse 


import snowflake.connector

conn = (snowflake.connector.connect
    (
user='krishna',
password='Happybirthday9',
account='nbhvhdc-wp31641',
warehouse='QA_WH',
database='DEV_DB',
schema='DEV_SCHEMA'
))
cur=conn.cursor()
try:
    cur.execute("select * from T_PROD_INFO")
    f_row=cur.fetchall()
    print(f_row)
finally:
    cur.close()
conn.close()



 --snowpark 
import snowflake.snowpark as snowpark
def main(session: snowpark.Session):
    table_name="t_range"
    df_range=session.range(1,10,1).to_df(('c1'))
    df_range.write.mode("overwrite").save_as_table(table_name)
    return table_name + " table sussessfully created"

------------------

import snowflake.snowpark as snowpark
from snowflake.snowpark.types import *

schema_for_data_file = StructType([
StructField("c1", StringType()),
StructField("c2", StringType()),
StructField("c3", StringType())
])

fileLocation ="@dev_db.dev_schema.STG_CSV_FILES/PD_58.csv"
outputTableName="t_prod_info"

def main(session: snowpark.Session):
    df_reader = session.read.schema(schema_for_data_file)
    df=df_reader.csv(fileLocation)
    df.write.mode("overwrite").save_as_table(outputTableName)
    return outputTableName + " table sussessfully loaded"