-- Enhanced aggregations with grouping sentences
select
    ordermonthyear as OrderMonth,
    productcategory as Category,
    sum(saleamount) as TotalSales
from
    sales_all_years
where
    lower(ordermonthyear) != 'ordermonthyear'
group by
    ordermonthyear,
    productcategory
-- enhancing
grouping sets
    (ordermonthyear, productcategory) -- same as union of two queries with group by of a and b separately
    
    
-- get both individually and the combo. Identify which using GROUPING__ID
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
grouping sets
    ((ordermonthyear, productcategory), ordermonthyear, productcategory)
