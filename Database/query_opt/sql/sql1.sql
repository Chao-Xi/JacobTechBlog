Explain select * from staff;

-- In this example, the cost spans from 00 to 24.00. So the command starts at the first step of the execution time, or at time 0. It completes after 24 units of computation

Explain Analyze select * from staff;
Explain Analyze select last_name from staff;
explain select * from staff; 


explain select * from staff where salary > 75000;
explain select * from staff;

explain analyze select * from staff where salary > 75000;
explain analyze select * from staff;

create index idx_staff_salary on staff(salary);
explain analyze select * from staff where salary > 75000;

-- create index idx_staff_salary on staff(salary);
explain analyze select * from staff where salary > 75000;
explain analyze select * from staff where salary > 150000;