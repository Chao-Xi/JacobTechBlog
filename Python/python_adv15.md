# Calculate Number of Days, Weeks, or Months to Reach Specific Goals(datetime and calendar module)


### 1.`calendar.monthrange(today.year, today.month)`

```
import datetime
import calendar

balance = 5000
interest_rate = 13 * .01
monthly_payment = 500

today = datetime.date.today()


range_ince_current_month = calendar.monthrange(today.year, today.month)
days_in_current_month = calendar.monthrange(today.year, today.month)[1]


print(range_ince_current_month)
print(days_in_current_month)

>>> (1, 31)
>>> 31
```

```
# Today is 2019/1/13


days_till_end_month = days_in_current_month - today.day

print(days_till_end_month)

>>> 18
```

### 2.`datetime.timedelta(days=days_in_current_month)`

```
start_date= today + datetime.timedelta(days=days_till_end_month + 1)
end_date = start_date

print(start_date)

>>> 2019-02-01

while balance > 0:
	interest_charge  = (interest_rate / 12) * balance

	balance += interest_charge
	balance -= monthly_payment

	balance = round(balance, 2)  # dont use math module

	if balance < 0:
		balance = 0
	print(end_date, balance)
	
	days_in_current_month = calendar.monthrange(end_date.year, end_date.month)[1]
	end_date = end_date + datetime.timedelta(days=days_in_current_month)

>>> 2019-02-01 4554.17
>>> 2019-03-01 4103.51
>>> 2019-04-01 3647.96
>>> 2019-05-01 3187.48
>>> 2019-06-01 2722.01
>>> 2019-07-01 2251.5
>>> 2019-08-01 1775.89
>>> 2019-09-01 1295.13
>>> 2019-10-01 809.16
>>> 2019-11-01 317.93
>>> 2019-12-01 0

```

### Reach goal with timedelta example

#### example 1

```
import datetime

current_weight = 220
goal_weight = 180
avg_lbs_week = 2

start_date = datetime.date.today()
end_date = start_date

while current_weight > goal_weight:
	end_date += datetime.timedelta(days=7)
	current_weight -= avg_lbs_week

print(end_date)

>>> 2019-06-02
>>> Reach goal in 20 weeks
```

#### example two

```
import datetime
import math

goal_subs = 150000
current_subs = 85000
subs_to_go = goal_subs - current_subs

avg_sub_day = 200
days_to_go = math.ceil(subs_to_go / avg_sub_day)

today = datetime.date.today()

>>> 2019-12-04
```





