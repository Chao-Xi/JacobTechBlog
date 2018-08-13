# Python Tutorial Advance 4

## Datetime Module -- How to work with Dates, Times, Timedeltas and TimeZone

### output special date 

```
import datetime

tday = datetime.date(2018, 7, 10)
print(tday)
```

```
2018-07-10
```

### output today date 

```
today=datetime.date.today()
print(today)
```

```
2018-08-11
```

### output weekday

```
#Weekday 0 is monday and 6 is sunday
print(today.weekday())
```
```
5    #saturday
```

```
#Oweekday 1 is monday and 7 is sunday
print(today.isoweekday() )
```

```
6   #saturday
```

### Timedeltas 

```
tdelta= datetime.timedelta(days=7)

print('Dans 7 jours: ',today + tdelta)
print('Last 7 days:',today - tdelta)
```

### Time Difference 
```
Ufday = datetime.date(2018, 8, 15)
tillday= Ufday - today
print(tillday.days)
print(tillday. total_seconds())
```

```
4                   #days
345600.0            #seconds
```

```
dt=datetime.datetime(2018, 7, 10, 10, 9, 31, 100000)
print(dt)
print(dt.date())
print(dt.time())
print(dt + tdelta)
```

```
2018-07-10 10:09:31.100000
2018-07-10
10:09:31.100000
2018-07-17 10:09:31.100000
```

```
timedelta= datetime.timedelta(hours=12)
print(dt + timedelta )

dt_today=datetime.datetime.today()
dt_now=datetime.datetime.now()
dt_utcnow=datetime.datetime.utcnow()

print(dt_today)
print(dt_now)
print(dt_utcnow)

``` 

```
2018-07-10 22:09:31.100000
2018-08-11 16:48:25.415332
2018-08-11 16:48:25.415338
2018-08-11 08:48:25.415340
```


### Python time zone

```
pip3 install pytz
```

```
import pytz 

dt_pytz=datetime.datetime(2018, 8, 11, 10, 9, 31, tzinfo=pytz.UTC)
print(dt)
# utz time:  2018-08-11 10:09:31+00:00

tz=pytz.timezone('Asia/Shanghai')
dt_pytz_now = datetime.datetime.now(tz=tz)
print(dt_pytz_now)
# shanghai time: 2018-08-11 17:14:17.727609+08:00


dt_pytz_now_newyork = dt_now.astimezone(pytz.timezone('America/New_York'))
print(dt_pytz_now_newyork)
# New_York time: 2018-08-11 05:14:17.680815-04:00
```

### list all timezones

```
for tz in pytz.all_timezones:
	print(tz)

```

```
Africa/Abidjan
Africa/Accra
Africa/Addis_Ababa
Africa/Algiers
....
```

```
dt_navie=datetime.datetime.now()
newyork_tz=pytz.timezone('America/New_York')
dt_ny=newyork_tz.localize(dt_navie)
print(dt_ny)
print(dt_ny.isoformat())
```

```
2018-08-11 17:26:08.267038-04:00
2018-08-11T17:26:08.267038-04:00
August 11, 2018
```

### string format timezone to digit datetime

```
dt_str ='August 10, 2018'
dt_strptime  = datetime.datetime.strptime(dt_str,  '%B %d, %Y')
print(dt_strptime)

# 2018-08-10 00:00:00
```
