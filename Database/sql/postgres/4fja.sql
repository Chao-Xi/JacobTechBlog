# subquery
select s1.last_name, s1.salary, s1.department, 
    (select round(avg(salary)) from staff s2 where s2.department = s1.department)
from staff s1;

select department, round(avg(salary)) from
(select s2.department, s2.salary from staff s2 where salary > 100000) s1
group by department;

select s1.department from staff s1 where 
	(select max(salary) from staff s2) = s1.salary;


-- # join

select s.last_name, s.department, cd.company_division 
    from staff s join company_divisions cd 
    on s.department = cd.department;

select s.last_name, s.department, cd.company_division 
    from staff s left join company_divisions cd 
    on s.department = cd.department;

select s.last_name, s.department, cd.company_division 
    from staff s left join company_divisions cd 
    on s.department = cd.department where cd.company_division is NULL;

select s.*, cd.company_division, cr.company_regions
    from staff s left join company_divisions cd 
    on s.department = cd.department left join  company_regions cr 
    on s.region_id = cr.region_id;

create view staff_div_reg as 
select s.*, cd.company_division, cr.company_regions
    from staff s left join company_divisions cd 
    on s.department = cd.department left join  company_regions cr 
    on s.region_id = cr.region_id;

select count(*) from staff_div_reg;

-- # view

select company_regions, count(*) from staff_div_reg group by company_regions order by company_regions;

select company_regions,company_division, count(*) from staff_div_reg group by 
    grouping sets(company_regions, company_division)  order by company_regions, company_division;


select company_regions,company_division, gender, count(*) from staff_div_reg group by 
    grouping sets(company_regions, company_division, gender)  order by company_regions, company_division, gender;


create or replace view staff_div_reg_country as 
    select s.*, cd.company_division, cr.company_regions, cr.country
    from staff s
    left join company_divisions cd
    on s.department = cd.department
    left join company_regions cr
    on s.region_id = cr.region_id;


select company_regions,country, count(*) from staff_div_reg_country group by company_regions, country order by company_regions,country;


select company_regions,country, count(*) from staff_div_reg_country group by 
    rollup(company_regions, country) order by company_regions,country;


select company_regions,country, count(*) from staff_div_reg_country group by 
    cube(company_regions, country)

-- # top

select last_name, job_title, salary from staff order by salary desc fetch first 10 row only;

select company_division, count(*) from staff_div_reg_country 
group by company_division order by count(*);

select company_division, count(*) from staff_div_reg_country 
group by company_division order by count(*) desc;