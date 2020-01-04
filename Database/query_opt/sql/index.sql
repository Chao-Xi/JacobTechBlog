explain select * from staff where email='jmurray3@gov.uk';
create index idx_staff_email on staff(email);

select distinct job_title from staff order by job_title;
select * from staff where job_title='operator';

create index index_staff_job_title on staff(job_title);
explain select * from staff where job_title='Operator';

create index index_staff_email on staff using hash(email);
explain select * from staff where email='jmurray3@gov.uk';