# Python Tutorial for Beginners

## Import self defined module

```
import self defined module

import module1 as m1
m1.func(x)
m1.func(y)
```


```
# module1
print('Imported module1')

def find_index(to_search, target):
	'''Find the index of a value of in a sequence'''
	for i, value in enumerate(to_search):
		if value == target:
			return i
	return -1	

```

```
import module1 as m1
courses = ['History', 'Math', 'Français', 'Physics', 'Compsci']

index = m1.find_index(courses, 'Français')
# Imported module1
# 2
```

**from module import m1, m2**  

```
#import one module as multiple mode
```

```
from module1 import find_index, test 
import sys
sys.path.append('/Users/jxi/python')

courses = ['History', 'Math', 'Français', 'Physics', 'Compsci']
index = find_index(courses, 'Français')

print(index)
# 2
```

## python basic modules

### 1. sys
```
import sys
sys.path.append('/A/B/C')
```

### 2. random

```
import random
random_element = random.choice(list)
for _ in range(10):
	print(random_element)
```

```
import random
courses = ['History','Math','Francais','Physics','Compsci']

random_course=random.choice(courses)

for _ in range(10):
	print(random_course)
#output 10 times random_element	
```

### 3. math

```
import math
rads = math.adians(90)
print(rads)

# print(rads)
```

### 4. datetime calendar

```
import datetime
import calendar
today = datetime.date.today()
#2018-07-23
print(calendar.isleap(2016))
#True
```

### 5. os 

```
import os 
print(os.getcwd())
# /Users/jxi/python/base/6module
# current working directory of a process

print(os.__file__)
#/usr/local/Cellar/python3/3.6.4_2/Frameworks/Python.framework/Versions/3.6/lib/python3.6/os.py
# output os lcoation
```

### 6. import antigravity

```
open a web
```