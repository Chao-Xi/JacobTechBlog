drop table vip_clients;
-- create new vip table
create table if not exists vip_clients(name string);
-- load some data
insert into vip_clients values
    ('Apple Inc.'), 
    ('Google Inc.'), 
    ('Facebook, Inc.'), 
    ('Amazon.com, Inc.'),
    ('QUALCOMM Incorporated'),
    ('America Movil, S.A.B. de C.V.'),
    ('Starbucks Corporation'),
    ('Costco Wholesale Corporation'),
    ('DIRECTV'),
    ('Adobe Systems Incorporated'),
    ('Netflix, Inc.');
