select department, last_name, salary, avg(salary) over (partition by department) from staff;

select department, last_name, salary, max(salary) over (partition by department) from staff;

select company_region, last_name, salary, min(salary) over (partition by department) from staff_div_reg;


-- # first value

select department, last_name, salary, first_value(salary) over (partition by department order by salary) from staff;

select department, last_name, salary, first_value(salary) over (partition by department order by last_name) from staff;

-- # rank

select department, last_name, salary, rank() over (partition by department order by last_name desc) from staff;

-- LAG and LEAD

select department, last_name, salary, lag(salary) over (partition by department order by salary desc) from staff;

select department, last_name, salary, lead(salary) over (partition by department order by salary desc) from staff;

-- NTILE functions

select department, last_name, salary, ntile(4) over (partition by department order by salary desc) from staff;
