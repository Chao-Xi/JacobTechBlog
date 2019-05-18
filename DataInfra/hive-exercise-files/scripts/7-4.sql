-- find difference between two dates
select
    orderid,
    productcategory,
    productsubcategory,
    orderdate,
    projectcompletedate,
    datediff(projectcompletedate, orderdate) duration
from sales_all_years

-- get some stats by month
select
    productcategory,
    productsubcategory,
    year(orderdate) y,
    month(orderdate) m,
    avg(datediff(projectcompletedate, orderdate)) duration
from sales_all_years
group by    
    productcategory,
    productsubcategory,
    year(orderdate),
    month(orderdate)
order by
    3,4

-- find the last day of the month
select distinct
	date_sub(
		to_date(
			concat(cast(year(orderdate) as string),"-",cast(month(orderdate)+1 as string),"-01")
		)
	,1 ),
	orderdate
from sales_all_years
limit 100;
