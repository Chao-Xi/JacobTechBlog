
-- checkout client data
select *
from clients;

-- how many rows do we have?
-- 35,749
select count(1)
from sales_all_years

-- inner join from sales
-- 35,749
select count(1)
from sales_all_years s
join clients c on s.companyname = c.name

-- Add details about clients for a more comprehensive answer
select 
    c.marketcaplabel, 
    c.marketcapamount,
    c.name, 
    c.ipoyear, 
    c.symbol,
    count(distinct s.orderid) OrderCount,
    sum(s.saleamount) as TotalSales
from sales_all_years s
join clients c on s.companyname = c.name
group by
    c.marketcaplabel, 
    c.marketcapamount,
    c.name, 
    c.ipoyear,
    c.symbol
order by
    c.marketcapamount desc
