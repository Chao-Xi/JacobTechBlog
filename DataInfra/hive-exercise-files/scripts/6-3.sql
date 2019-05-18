-- first join to filter just on vip_clients
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
    
-- now add clients table for additional context
select 
    s.companyname,
    s.productcategory,
    c.marketcaplabel, 
    c.marketcapamount,
    c.name, 
    c.ipoyear, 
    c.symbol,
    count(distinct s.orderid) OrderCount,
    sum(s.saleamount) as TotalSales
from sales_all_years s
left semi join vip_clients v on (s.companyname = v.name) 
join clients c on s.companyname = c.name
group by
    s.companyname,
    s.productcategory,
    c.marketcaplabel, 
    c.marketcapamount,
    c.name, 
    c.ipoyear, 
    c.symbol
