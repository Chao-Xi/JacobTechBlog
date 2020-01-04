-- PARTITION BY Range



CREATE TABLE iot_measurement 
	(location_id int not null, 
	measure_date date not null, 
	temp_celcius int, 
	rel_humidity_pct int) 
	PARTITION BY RANGE (measure date); 

CREATE TABLE iot_measurement_wk1_2019 
PARTITION OF iot_measurement FOR VALUES 
FROM ('2019-01-01') TO ('2019-01-08');
 
CREATE TABLE iot_measurement_wk2_2019  
PARTITION OF iot_measurement FOR VALUES 
FROM ('2019-01-08') TO ('2019-01-15'); 

CREATE TABLE iiot_measurement_wk3_2019  
PARTITION OF iot_measurement FOR VALUES 
FROM ('2019-01-15') TO ('2019-01-22'); 

-- PARTITION BY LIST

CREATE TABLE products 
	(prod_id int not null, 
	prod_name text not null, 
	prod_short_descr text not null, 
	prod_long_descr text not null, 
	prod_category varchar) 
	PARTITION BY LIST (prod_category); 

CREATE TABLE product_clothing PARTITION OF products 
FOR VALUES IN ('casual_clothing', 'business_attire', 'formal_clothing');

CREATE TABLE product_electronics PARTITION OF products 
FOR VALUES IN ('mobile_phones', 'tablets', 'laptop_computers'); 

CREATE TABLE product_kitchen PARTITION OF products 
FOR VALUES IN ('food processor', 'cutlery', 'blenders'); 

-- PARTITION BY HASH

CREATE TABLE customer_interaction 
	(ci_id int not null, 
	ci_url text not null, 
	time_at_url int not null, 
	click_sequence int not null) 
PARTITION BY HASH (ci_id); 

CREATE TABLE customer_interaction_1 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 0); 

CREATE TABLE customer_interaction_2 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 1); 

CREATE TABLE customer_interaction_3 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 2); 

CREATE TABLE customer_interaction_4 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 3); 

CREATE TABLE customer_interaction_5 PARTITION OF customer_interaction 
	FOR VALUES WITH (MODULUS 5, REMAINDER 4); 