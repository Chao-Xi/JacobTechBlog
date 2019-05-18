--Let's understand monthly sales figures
select
    ordermonthyear as OrderMonth,
    count(1) as OrderCount, --if every row represents one order we just count 1
    sum(s.saleamount) as TotalSales,
    avg(s.saleamount) as AvgSales,
    min(s.saleamount) as MinSales,
    max(s.saleamount) as MaxSales
    
from 
    sales_all_years s
where
    lower(ordermonthyear) != 'ordermonthyear'
group by
    ordermonthyear
order by
    ordermonthyear desc


-- Now let's break it down further by category by month
select
    ordermonthyear as OrderMonth,
    productcategory as Category,
    count(1) as OrderCount, --if every row represents one order we just count 1
    sum(s.saleamount) as TotalSales,
    avg(s.saleamount) as AvgSales,
    min(s.saleamount) as MinSales,
    max(s.saleamount) as MaxSales
    
from 
    sales_all_years s
where
    lower(ordermonthyear) != 'ordermonthyear'
group by
    ordermonthyear,
    productcategory
order by
    ordermonthyear desc
