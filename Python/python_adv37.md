# 5 Common Python Mistakes and How to Fix Them

## 1.Indentation and Spaces

### How to avoid `IndentationError: expected an indented block`

**On sublime**

`sublime -> preference -> settings` 

**Add this line**

```
 "translate_tabs_to_spaces": true
```

```
{
    "font_size": 13,
    "ignored_packages":
    [
        "Vintage"
    ],
    "translate_tabs_to_spaces": true
}
```

### `One tab == four spaces`

```
nums = [11, 30, 44, 54]

for num in nums:
    square = num ** 2  # One tab
    print(square)      # four spaces

121
900
1936
2916
```

## 2.Naming Conflicts


### Instance one

In **`math.py`, module name = file name**

```
from math import radians, sin

rads = radians(90)

print(sin(rads))

Traceback (most recent call last):
  File "/Users/jxi/python/adv1/math.py", line 1, in <module>
    from math import radians, sin
  File "/Users/jxi/python/adv1/math.py", line 1, in <module>
    from math import radians, sin
ImportError: cannot import name 'radians' from 'math' (/Users/jxi/python/adv1/math.py)
```

### Instance two

**Variable name equals to module name**

```
from math import radians, sin

radians = radians(90)
print(sin(radians))
> 1.0

rad45 = radians(45)
print(rad45)

rad45 = radians(45)
TypeError: 'float' object is not callable
```


## 3.Mutable Default Args

### (1).Instance one

### Traditional way

```
def add_employee(emp, emp_list=[]):
    emp_list.append(emp)
    print(emp_list)

emps = ['Kate','Jon']

add_employee('Clark', emps)

add_employee('Jacob')
add_employee('Olivia')
```
### Suppose two single element list as new list

#### Actual output which is not right

```
['Jacob']
['Jacob', 'Olivia']
```

#### Mutable Default Args

```
def add_employee(emp, emp_list=None):

    if emp_list is None:
            emp_list = []
            
    emp_list.append(emp)
    print(emp_list)
    
add_employee('Jacob')
add_employee('Olivia')
```

#### Right output

```
['Jacob']
['Olivia']
```

### (2).Instance two display time

#### traditional way with wrong output

```
import time
from datetime import datetime

def display_time(time=datetime.now()):
    print(time.strftime('%B %d, %Y:%M:%S'))

display_time()
time.sleep(1)
display_time()
time.sleep(1)
display_time()

> April 23, 2019:37:45
> April 23, 2019:37:45
> April 23, 2019:37:45
```

#### Mutable Default Args with correct output

```
def new_display_time(time=None):
    if time is None:
        time = datetime.now()
    print(time.strftime('%B %d, %Y:%M:%S'))

new_display_time()
time.sleep(1)
new_display_time()
time.sleep(1)
new_display_time()

> April 23, 2019:37:47
> April 23, 2019:37:48
> April 23, 2019:37:49
```

## 4.Python3 Exhausting Iterators

### Need add list() for Comprehensions in python3

```
names = ['Bruce', 'Clark', 'Peter', 'Logan', 'Wade']
heros = ['Batman', 'Superman', 'Spiderman', 'Wolverine', 'Deadpool']

# print(list(zip(names, heros)))

indentities = list(zip(names, heros))
print(indentities)

[('Bruce', 'Batman'), ('Clark', 'Superman'), ('Peter', 'Spiderman'), ('Logan', 'Wolverine'), ('Wade', 'Deadpool')]
```

## 5. Importing with * (asterisks)

### import asterisks is bad practice like:

```
from os import *
```

### Why? 

```
from html import * 
from glob import * 
# They both have escape() module, html escape will be overwritten by glob escape()

print(help(escape))

# Help on function escape in module glob:
```



