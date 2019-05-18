-- Find tables in the product list
SELECT DISTINCT order_items.name
FROM customers c
LATERAL VIEW EXPLODE(c.orders) o AS ords
LATERAL VIEW EXPLODE(ords.items) i AS order_items
-- WHERE lower(order_items.name) like '%table%'
LIMIT 1000;

-- Gather some stats about orders of table products
SELECT 
    c.name AS CustName,
    addy.city as CustCity,
    addy.state as CustState,
    addy.zip_code as CustZip,
    count(distinct ords.order_id) as OrderCount,
    sum(order_items.price * order_items.qty) as OrderAmount
FROM customers c
-- get address information
LATERAL VIEW EXPLODE(c.addresses) a AS a_key, addy

-- get order details
LATERAL VIEW EXPLODE(c.orders) o AS ords
LATERAL VIEW EXPLODE(ords.items) i AS order_items

--filter results
WHERE 
    lower(order_items.name) like '%table%'
    
GROUP BY
    c.name,
    addy.city,
    addy.state,
    addy.zip_code
    
    
    

    

    

