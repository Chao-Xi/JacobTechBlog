INSERT 0 1

Query returned successfully in 200 msec.

refrsh tables will show all new tables

select * from company_divisions;
select * from company_regions;
select * from staff;

-- ### 2
select * from staff limit 10;
select count(*) from staff;
select count(*) from staff GROUP BY gender;
select gender, count(*) from staff GROUP BY gender;
select department, count(*) from staff GROUP BY department;
select max(salary) from staff;
select min(salary) from staff;
select max(salary), min(salary) from staff;
select department, max(salary), min(salary) from staff GROUP BY department;
select gender, max(salary), min(salary) from staff GROUP BY gender;

-- ### 3

select sum(salary) from staff;
select department, sum(salary) from staff group by department;
select department, sum(salary), avg(salary) from staff group by department;
-- # get variance 
select department, sum(salary), avg(salary),var_pop(salary) from staff group by department;
select department, sum(salary), round(avg(salary),2),round(var_pop(salary),2), round(stddev_pop(salary),2) from staff group by department;

-- # 3
select last_name, department, salary from staff where salary>100000;
select last_name, department, salary from staff where department='Tools';
select last_name, department, salary from staff where department='Tools' and salary>100000;
select last_name, department, salary from staff where department='Tools' or salary>100000;
select department, sum(salary) from staff where department like 'B%' group by department;
select department, sum(salary) from staff where department like 'Bo%' group by department;
select department, sum(salary) from staff where department like 'B%y' group by department;