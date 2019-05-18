/* structure
SELECT <columns>
FROM <table>
JOIN <other tables>
WHERE <filter condition>
GROUP BY <grouping>
HAVING <aggregate filter>
ORDER BY <column list>
LIMIT <number of rows>
*/


-- the most basic select
select * -- all columns from table
from sales --table to pull from
limit 100 --only return the top 100 rows
    
-- out of order
from sales
select *
limit 100

-- aliasing tables and picking columns
select 
    s.orderdate,   
    s.saleamount,
    s.rowid
from 
    sales s
limit 100;

-- aliasing columns
select 
    s.orderdate as OrderDate,   
    s.saleamount as Sales,
    s.rowid as RowNum
from 
    sales s
limit 100;
