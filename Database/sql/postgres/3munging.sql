select distinct upper(department) from staff;
select distinct lower(department) from staff;
select job_title || '-' || department from staff;
select job_title || '-' || department title_dept from staff;
select trim(' Software Engineer ')
select length(' Software Engineer ');
select length(trim(' Software Engineer '));
select job_title from staff where job_title like 'Assistant%'
select job_title, (job_title like '%Assistant%') is_asst from staff


select 'abcdefghijkl' test_string;
select substring('abcdefghijkl' from 1 for 3) test_string;
select substring('abcdefghijkl' from 5 for 3) test_string;
select substring('abcdefghijkl' from 5) test_string;
select substring(job_title from 10) from staff where job_title like 'Assistant%';
select overlay(job_title placing 'Asst.' from 1 for 10) from staff where job_title like 'Assistant%';
select overlay(job_title placing 'Asst.' from 1 for 9) from staff where job_title like 'Assistant%';


select job_title from staff where job_title like '%Assistant%';
select job_title from staff where job_title similar to '%Assistant%(III|IV)';
select job_title from staff where job_title similar to '%Assistant I_';

select department, avg(salary), trunc(avg(salary)) from staff group by department;
select department, avg(salary), round(avg(salary)) from staff group by department;
select department, avg(salary), round(avg(salary),2) from staff group by department;
select department, avg(salary), round(avg(salary),2), trunc(avg(salary),2) from staff group by department;
select department, avg(salary), round(avg(salary),3), trunc(avg(salary),4) from staff group by department;
select department, avg(salary), trunc(avg(salary)), ceil(avg(salary)) from staff group by department;