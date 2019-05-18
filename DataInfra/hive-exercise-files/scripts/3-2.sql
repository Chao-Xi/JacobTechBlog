-- Get email survey opt-in values for all customers
SELECT
  c.id,
  c.name,
  c.email_preferences.categories.surveys
FROM customers c;



-- Select customers for a given shipping ZIP Code
SELECT
  customers.id,
  customers.name
FROM customers
WHERE customers.addresses['shipping'].zip_code = '76710';

-- Get customers and their first order only
SELECT
    c.id,
    c.name,
    orders[0]
FROM
    customers c
    
-- Get customers and all of their Order IDs
SELECT
  c.id AS customer_id,
  c.name AS customer_name,
  ords.order_id AS order_id
FROM
  customers c
LATERAL VIEW EXPLODE(c.orders) o AS ords


-- Get total of each order for these customers
SELECT
  c.id AS customer_id,
  c.name AS customer_name,
  ords.order_id AS order_id,
  order_items.price * order_items.qty AS total_amount
FROM
  customers c
LATERAL VIEW EXPLODE(c.orders) o AS ords
LATERAL VIEW EXPLODE(ords.items) i AS order_items
limit 1000;
