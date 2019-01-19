# What is the difference between `str()` and `repr()`


* The goal of `__repr__` is to be unambiguous
* The goal of `__str__` is to be readable

```
a = [1,2,3,4]
b = 'sample string'

print(str(a))
print(repr(a))

# Identiical output
>>> [1, 2, 3, 4]
>>> [1, 2, 3, 4]

print(str(b))
print(repr(b))

# Different output
>>> sample string
>>> 'sample string'
```

## What's meaning of unambiguous

```
# pip3 install pytz
import datetime
import pytz

a = datetime.datetime.utcnow().replace(tzinfo=pytz.UTC)

b = str(a)

print(f'str(a): {str(a)}')
print(f'str(b): {str(b)}')

# String output same and readable output
>>> str(a): 2019-01-14 03:36:12.278631+00:00
>>> str(b): 2019-01-14 03:36:12.278631+00:00


print()


print(f'repr(a): {repr(a)}')
print(f'repr(b): {repr(b)}')

# repr output different and programmable output
>>> repr(a): datetime.datetime(2019, 1, 14, 3, 36, 12, 278631, tzinfo=<UTC>)
>>> repr(b): '2019-01-14 03:36:12.278631+00:00'
```

