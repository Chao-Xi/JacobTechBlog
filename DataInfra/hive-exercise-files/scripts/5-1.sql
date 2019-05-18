-- add "where" to filter to a specific partition
select  *
from    sales_all_years
where   yr=2009
limit   1000;

-- remove the header row with a second where clause
select  *
from    sales_all_years
where   yr = 2009
and     lower(rowid) != 'rowid'
limit   1000;

-- when working with dates, use between
select  *
from    sales_all_years
where   orderdate between '2010-01-01' and '2010-12-31'

