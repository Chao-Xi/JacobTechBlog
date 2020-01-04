select s.id, s.last_name, s.job_title, cr.country
from 
    staff s 
inner join
    company_regions cr 
on 
    s.region_id = cr.region_id;

set enable_nestloop=true;
set enable_hashjoin=false;
set enable_mergejoin=false;

explain select s.id, s.last_name, s.job_title, cr.country
from 
    staff s 
inner join
    company_regions cr 
on 
    s.region_id = cr.region_id;


set enable_nestloop=false;
set enable_hashjoin=true;
set enable_mergejoin=false;

explain select s.id, s.last_name, s.job_title, cr.country
from 
    staff s 
inner join
    company_regions cr 
on 
    s.region_id = cr.region_id;


set enable_nestloop=false;
set enable_hashjoin=false;
set enable_mergejoin=true;

explain select s.id, s.last_name, s.job_title, cr.country
from 
    staff s 
inner join
    company_regions cr 
on 
    s.region_id = cr.region_id;

