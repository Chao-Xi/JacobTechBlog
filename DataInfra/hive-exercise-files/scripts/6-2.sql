-- ANSI SQL method using exists
select *
from sales_all_years s
where exists(
    select *
    from vip_clients v
    where s.companyname = v.name);

-- get info about vip customers only
select 
    s.companyname,
    s.productcategory,
    count(distinct s.orderid) OrderCount,
    sum(s.saleamount) as TotalSales
from sales_all_years s
left semi join vip_clients v on (s.companyname = v.name) 
group by
    s.companyname,
    s.productcategory
