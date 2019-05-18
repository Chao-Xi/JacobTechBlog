-- basic calculations using mathmatical operators
select
    orderid,
    orderdate,
    quantity,
    rate,
    discountpct,
    quantity*rate*(1-discountpct) as QuoteAmt,
    round(quantity*rate*(1-discountpct)) as QuoteAmtRound
from sales_all_years
where yr=2009

-- use rand and others to simulate new data
select 
    rand(), 
    saleamount,
    orderid,
    wagemargin,
    round(saleamount*rand()) as RandSaleAmount,
    floor(wagemargin) as WageMarginFlr,
    ceiling(wagemargin) as WageMarginCl
from sales_all_years
where yr=2009
