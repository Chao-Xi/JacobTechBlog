-- WITH CUBE returns subtotals of all possible comibnations. Be careful with large datasets!
-- This is nice if you're unsure of the aggregation level you'll want but certainly can cause slowness
select
    ordermonthyear as OrderMonth,
    productcategory as Category,
    GROUPING__ID as Grp,
    sum(saleamount) as TotalSales
from
    sales_all_years
where
    lower(ordermonthyear) != 'ordermonthyear'
group by
    ordermonthyear,
    productcategory
-- enhancing
with cube


-- WITH ROLLUP is similar in that it creates multiple aggregation levels, but as a hierarchy instead
-- Same query, except this time the grouping levels are defined as a hierarchy
select
    ordermonthyear as OrderMonth,
    productcategory as Category,
    GROUPING__ID as Grp,
    sum(saleamount) as TotalSales
from
    sales_all_years
where
    lower(ordermonthyear) != 'ordermonthyear'
group by
    ordermonthyear,
    productcategory
-- enhancing
with rollup
