# Data Scientists SQL 

0.[Using Kubernetes to Deploy PostgreSQL and Pgadmin](postgres_sql_k8s_install.md)

* Traditional Way
* Helm Way 

```
email: chart@example.local
password: SuperSecret
```

1.[SQL as Tool for Data Science](ds_sql1.md)

**SQL data manipulation features**

* Insert

```
insert into company_regions (region_id, region_name, country) values (1, 'Northeast', 'USA')
```

* Update

```
update company_regions set country='Unites States' where country = 'USA'
```

* Delete

```
delete from company_regions where country = 'Canada'
```

* Select

```
select * from country_regions where id in (1,2)
```

**SQL data definition features**

* Tables: Tables are used to organize related sets of data, like information about employees, products, and events.

```
CREATE TABLE staff 
    (id INTEGER, 
    last name VARCHAR(30), 
    department name VARCHAR(25), 
    start_date DATE, 
    PRIMARY KEY (id) 
)
```

* Indexes: INDEX command lets us build an index to quickly look up rows and tables.

```
CREATE INDEX idx_staff_last_name 
ON staff 
USING (last_name) 
```

* Views: Views are structures that help us focus on the most important data for a particular use.

```
CREATE VIEW staff div AS 
 SELECT 
  s.id, 
  siast_name, 
  cd.company division 
FROM 
  staff s 
LEFT JOIN 
  company divisions cd 
ON 
  s.department = cd.department 
```

* Schemas: Schemas are like floor plans. They organize groups of related structures such as database, tables, and views

```
CREATE SCHEMA data sci 
```

2.[Basic Statistics with SQL](ds_sql2.md)


* CREATE TABLE and INSERT DATA
* The COUNT, MIN, and MAX functions
* Filtering and grouping data


```
select count(*) from staff;
select count(*) from staff GROUP BY gender;
select max(salary) from staff;
select min(salary) from staff;
select department, max(salary), min(salary) from staff GROUP BY department;
select department, sum(salary), avg(salary),var_pop(salary) from staff group by department;
select department, sum(salary), avg(salary),var_pop(salary), stddev_pop(salary) from staff group by department;
select department, sum(salary), round(avg(salary),2),round(var_pop(salary),2), round(stddev_pop(salary),2) from staff group by department;

select last_name, department, salary from staff where salary > 100000;
select last_name, department, salary from staff where department='Tools';
select last_name, department, salary from staff where department='Tools' and salary>100000;
select last_name, department, salary from staff where department='Tools' or salary > 100000;
select department, sum(salary) from staff where department like 'B%' group by department;select department, sum(salary) from staff where department like 'B%y' group by department;
```

3.[Data Munging with SQL](ds_sql3.md)

* Reformatting character data
* Extracting or Replaccing strings from character data
* Filtering with regular expressions
* Reformatting numeric data


```
select distinct department from staff;
select distinct upper(department) from staff;
select distinct lower(department) from staff;
select job_title || '-' || department from staff;
select job_title || '-' || department title_dept from staff;
select trim(' Software Engineer ');
select length(' Software Engineer ');
select length(trim(' Software Engineer '));
select job_title from staff where job_title like 'Assistant%'
select job_title, (job_title like '%Assistant%') is_asst from staff


select substring('abcdefghijkl' from 1 for 3) test_string;
select substring('abcdefghijkl' from 5 for 3) test_string;
select substring('abcdefghijkl' from 5) test_string;
select substring(job_title from 10) from staff where job_title like 'Assistant%';
select overlay('abcdefghijkl' placing 'CDEF' from 3 for 4);
select overlay(job_title placing 'Asst.' from 1 for 9) from staff where job_title like 'Assistant%';

select job_title from staff where job_title like '%Assistant%';
select job_title from staff where job_title similar to '%Assistant%(III|IV)';
select job_title from staff where job_title similar to '%Assistant I_';
select job_title from staff where job_title similar to '[EPS]%';
select job_title from staff where job_title similar to '%Assistant%(I)*';

select department, avg(salary), trunc(avg(salary)) from staff group by department;
select department, avg(salary), round(avg(salary)) from staff group by department;
select department, avg(salary), round(avg(salary),2), trunc(avg(salary),2) from staff group by department;
select department, avg(salary), round(avg(salary),3), trunc(avg(salary),4) from staff group by department;
select department, avg(salary), trunc(avg(salary)), floor(avg(salary)) from staff group by department;
select department, avg(salary), trunc(avg(salary)), ceil(avg(salary)) from staff group by department;
```


4.[Filtering, Join, and Aggregation](ds_sql4.md)

* Subqueries in SELECT clauses
* Subqueries in FROM clauses
* Subqueries in WHERE clauses
* Joining tables
* Creating a view
* Grouping and totaling
* ROLLUP and CUBE to create subtotals
* FETCH FIRST to find top results


```
select s1.last_name, s1.salary, s1.department, 
    (select round(avg(salary)) from staff s2 where s2.department = s1.department)
from staff s1;


select department, round(avg(salary)) from
(select s2.department, s2.salary from staff s2 where salary > 100000) s1
group by department;


select s1.department from staff s1 where 
    (select max(salary) from staff s2) = s1.salary;


select s.last_name, s.department, cd.company_division 
    from staff s join company_divisions cd 
    on s.department = cd.department;
select s.last_name, s.department, cd.company_division 
    from staff s left join company_divisions cd 
    on s.department = cd.department;
select s.last_name, s.department, cd.company_division 
    from staff s left join company_divisions cd 
    on s.department = cd.department where cd.company_division is NULL;
 

create view staff_div_reg as 
select s.*, cd.company_division, cr.company_regions
    from staff s left join company_divisions cd 
    on s.department = cd.department left join  company_regions cr 
    on s.region_id = cr.region_id;



select company_regions,company_division, count(*) 
from staff_div_reg 
group by 
    grouping sets(company_regions, company_division)  
    order by company_regions, company_division;

select company_regions,country, count(*) from staff_div_reg_country 
group by company_regions, country 
order by company_regions,country;

select company_regions,country, count(*) from staff_div_reg_country group by 
    cube(company_regions, country)
    

select last_name, job_title, salary from staff 
order by salary desc fetch first 10 row only;


select
   company_division, count(*)
from
   staff_div_reg
group by
   company_division
order by
   count(*) desc
fetch first
   5 rows only;
```


5.[Window functions and ordered data](ds_sql5.md)

* Window functions: `OVER PARTITION`
* Window functions: `FIRST_VALUE`
* Window functions: `RANK`
* LAG and LEAD
* NTILE functions



```
select department, last_name, salary, avg(salary) over (partition by department) from staff;
select department, last_name, salary, max(salary) over (partition by department) from staff;
select company_region, last_name, salary, min(salary) over (partition by department) from staff_div_reg;


select department, last_name, salary, first_value(salary) 
over (partition by department order by salary DESC) 
from staff;

select department, last_name, salary,
rank() over (partition by department order by salary desc) 
from staff;

select department, last_name, salary, lag(salary) over (partition by department order by last_name desc) from staff;

select department, last_name, salary, lead(salary) over (partition by department order by salary desc) from staff;

select department, last_name, salary, ntile(4) over (partition by department order by salary desc) from staff;
```










