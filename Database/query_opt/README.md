# Advanced SQL for Query Tuning and Performance Optimization


## How SQL Executes a Query

* Advanced SQL for Query Tuning and Performance Optimization
* Scanning tables and indexes
* Joining tables
* Partitioning data

## Postgresql tools for tuning

* Explain and analyze
* Example plan: Selecting with a WHERE clause
* Indexes


```
Explain Analyze select * from staff;
Explain select * from staff;
Explain select * from staff where salary > 75000;
Explain analyze select * from staff where salary > 75000;
```

```
create index idx_staff_salary on staff(salary);
explain analyze select * from staff where salary > 75000;
explain analyze select * from staff where salary > 150000;
```

## Types of Indexing

* Indexing
* B-tree indexes
* B-tree index example plan
* Bitmap indexes (few distinct values and low-cardinality values)
* Bitmap index example plan
* Hash indexes
* Hash index example plan
* PostgreSQL-specific indexes

```
explain select * from staff where email='jmurray3@gov.uk';

<!--B-tree index example plan-->
create index idx_staff_email on staff(email);
explain select * from staff where email='jmurray3@gov.uk';

<!--Bitmap index example plan-->
create index index_staff_job_title on staff(job_title);
explain select * from staff where job_title='Operator';

<!--Hash indexes-->
create index index_staff_email on staff using hash(email);
explain select * from staff where email='jmurray3@gov.uk';
```

## Tuning Join

* What affects joins performance?
* Nested loops
* Nested loop example plan
* Hash joins
* Hash join example plan
* Merge joins
* Merge join example
* Subqueries vs. joins


```
select * 
from 
	company_region cr,
inner join 
	staff s
on
	cr.region_id = s.region_id
	

select * 
from 
	company_region cr,
left outer join
	staff s
on
	cr.region_id = s.region_id


select * 
from 
	company_region cr,
right outer join
	staff s
on
	cr.region_id = s.region_id

select * 
from 
	company_region cr,
fuller outer join
	staff s
on
	cr.region_id = s.region_id

<!--nestloop-->
set enable_nestloop=true;
set enable_hashjoin=false;
set enable_mergejoin=false;


<!--Hash join -->
set enable_nestloop=false;
set enable_hashjoin=true;
set enable_mergejoin=false;

<!--Merge joins-->
set enable_nestloop=false;
set enable_hashjoin=false;
set enable_mergejoin=true;
```

## Partitioning Data

* Horizontal vs. vertical partitioning
* Partition by range
* Partition by list
* Partition by hash

 
```
<!--Partition by range-->
CREATE TABLE iot_measurement 
	(location_id int not null, 
	measure_date date not null, 
	temp_celcius int, 
	rel_humidity_pct int) 
	PARTITION BY RANGE (measure date); 
	
CREATE TABLE iot_measurement_wk1_2019 
PARTITION OF iot_measurement FOR VALUES 
FROM ('2019-01-01') TO ('2019-01-08');

CREATE TABLE iot_measurement_wk2_2019  
PARTITION OF iot_measurement FOR VALUES 
FROM ('2019-01-08') TO ('2019-01-15'); 

CREATE TABLE iiot_measurement_wk3_2019  
PARTITION OF iot_measurement FOR VALUES 
FROM ('2019-01-15') TO ('2019-01-22'); 



<!--Partition by list-->
CREATE TABLE products 
	(prod_id int not null, 
	prod_name text not null, 
	prod_short_descr text not null, 
	prod_long_descr text not null, 
	prod_category varchar) 
	PARTITION BY LIST (prod_category); 
	
CREATE TABLE product_clothing PARTITION OF products 
FOR VALUES IN ('casual_clothing', 'business_attire', 'formal_clothing'); 

CREATE TABLE product_electronics PARTITION OF products 
FOR VALUES IN ('mobile_phones', 'tablets', 'laptop_computers'); 

CREATE TABLE product_kitchen PARTITION OF products 
FOR VALUES IN ('food processor', 'cutlery', 'blenders'); 


<!--Partition by hash-->
CREATE TABLE customer_interaction 
	(ci_id int not null, 
	ci_url text not null, 
	time_at_url int not null, 
	click_sequence int not null) 
PARTITION BY HASH (ci_id); 

CREATE TABLE customer_interaction_1 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 0); 

CREATE TABLE customer_interaction_2 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 1); 

CREATE TABLE customer_interaction_3 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 2); 

CREATE TABLE customer_interaction_4 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 3); 

CREATE TABLE customer_interaction_5 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 4); 
```

## Materialized views

* Materialized views
* Creating materialized views
* Refreshing materialized views

```
CREATE MATERIALIZED VIEW my_staff AS 
	SELECT 
		s.last name, s.department, s.job_title, cr.company_regions 
	FROM 
		staff s 
	INNER JOIN 
		company_regions cr 
	ON 
		s.region_id = cr.region_id；  
		

refresh materialized views my_staff
```

##  Other Optimization Techniques

* Collect statistics about data in tables
* Hints to the query optimizer
* Improving SELECT Queries

