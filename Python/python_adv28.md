# Itertools Module - Iterator Functions for Efficient Looping

### import the module

```
import itertools
```

## 1.`itertools.count()`

```
counter = itertools.count()

print(next(counter))
print(next(counter))
print(next(counter))

>>> 0
>>> 1
>>> 2
```

### 1.1 count with start `start` and `step`

```
counter = itertools.count(start=5, step=5)

print(next(counter))
print(next(counter))
print(next(counter))
print(next(counter))

>>> 5
>>> 10
>>> 15
>>> 20
```
```
counter = itertools.count(start=5, step=-2.5)

print(next(counter))
print(next(counter))
print(next(counter))
print(next(counter))

>>> 5
>>> 2.5
>>> 0.0
>>> -2.5
```


## 2.`zip()` and `tertools.zip_longest()`

### 2.1 zip

The `zip()` function take iterables (can be zero or more), **makes iterator that aggregates elements based on the iterables passed**, and **returns an iterator of tuples**.

```
data = [100, 200, 300, 400]
daily_data = zip(itertools.count(), data)
print(daily_data)

>>> <zip object at 0x107104888>

# transfer to list
daily_data=list(daily_data)
print(daily_data)
>>> [(0, 100), (1, 200), (2, 300), (3, 400)]
```

### 2.2 zip problems

```
print(type(range(10)))
daily_data = list(zip(range(10), data))
print(daily_data)

>>> <class 'range'>
>>> [(0, 100), (1, 200), (2, 300), (3, 400)]
```

### 2.3 zip tertools.zip_longest

```
daily_data = list(itertools.zip_longest(range(10), data))
print(daily_data)

>>> [(0, 100), (1, 200), (2, 300), (3, 400), (4, None), (5, None), (6, None), (7, None), (8, None), (9, None)]
```


## 3.`itertools.cycle()`

```
counter = itertools.cycle([1, 2, 3])

print(next(counter))
print(next(counter))
print(next(counter))
print(next(counter))
print(next(counter))
print(next(counter)) 

>>>	1
>>>	2
>>>	3
>>>	1
>>>	2
>>>	3
```

```
counter = itertools.cycle(('on','off'))

print(next(counter))
print(next(counter))
print(next(counter))
print(next(counter))

>>>on
>>>off
>>>on
>>>off
```

## 4.`itertools.repeat()`

```
counter = itertools.repeat(2 , times=3)

print(next(counter))
print(next(counter))
print(next(counter))

>>> 2
>>> 2
>>> 2
```

### 4.1 `map()` and `itertools.starmap()`

**The map() function executes a specified function for each item in a iterable. The item is sent to the function as a parameter**

```
map(function, iterables)
```

#### 4.1 `pow()`

The syntax of pow() method is:

```
pow(x, y[, z])
```

**The pow(x, y) is equivalent to:**

```
x**y
```

```
itertools.repeat(2)

2 2 2 2 2 2 2 2 2 2 2 ... 
```

```
square = map(pow, range(10), itertools.repeat(2))
print(list(square))

# pow is function
# range(10) => 0 ... 9
# 2 2 2 2 2 2 2 2 2 2 2 ... 
>>> [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```

### 4.2 `itertools.starmap()`

```
squares = itertools.starmap(pow, [(0,2), (1,2), (2,2)])
print(list(squares)) 

>>> [0, 1, 4]
```

## 5.`itertools.combinations()`, `itertools.permutations()`, `tertools.product()` and `itertools.combinations_with_replacement()`

```
letters = ['a', 'b', 'c', 'd']
numbers = [0, 1, 2]
names = ['Corey', 'Nicole']
```

### 5.1 `itertools.combinations()`

```
result = itertools.combinations(letters, 2)

for item in result:
	print(item)

> ('a', 'b')
> ('a', 'c')
> ('a', 'd')
> ('b', 'c')
> ('b', 'd')
> ('c', 'd')
```

### 5.2 `itertools.permutations()`

```
result = itertools.permutations(letters, 2)

for item in result:
	print(item, end=" ")
print() 

>>> ('a', 'b') ('a', 'c') ('a', 'd') ('b', 'a') ('b', 'c') ('b', 'd') ('c', 'a') ('c', 'b') ('c', 'd') ('d', 'a') ('d', 'b') ('d', 'c') 
```

### 5.3 `itertools.product()`

```
result = itertools.product(numbers, repeat=4)
for item in result:
	print(item)
	
(0, 0, 0, 0)
(0, 0, 0, 1)
(0, 0, 0, 2)
...
(1, 0, 0, 0)
(1, 0, 0, 1)
...
(2, 2, 2, 1)
(2, 2, 2, 2)
```

### 5.4 `itertools.combinations_with_replacement()`

```
result = itertools.combinations_with_replacement(numbers, 4)
for item in result:
	print(item)
	
> (0, 0, 0, 0)
> (0, 0, 0, 1)
> (0, 0, 0, 2)
> (0, 0, 1, 1)
> (0, 0, 1, 2)
> (0, 0, 2, 2)
> (0, 1, 1, 1)
> (0, 1, 1, 2)
> (0, 1, 2, 2)
> (0, 2, 2, 2)
> (1, 1, 1, 1)
> (1, 1, 1, 2)
> (1, 1, 2, 2)
> (1, 2, 2, 2)
> (2, 2, 2, 2)
```


## 6.`itertools.chain()`

```
combined = itertools.chain(letters, numbers, names)

for item in combined:
	print(item, end=" ")
print()

>>> a b c d 0 1 2 Corey Nicole 
```

## 7.`itertools.islice()`

**islice(seq, [start,] stop [, step])**

### 7.1 `islice(seq, stop)`

```
result = itertools.islice(range(10), 5)

for item in result:
	print(item, end=" ")
print()

>>> 0 1 2 3 4 
```

### 7.2 islice(seq, start, stop)

```
result = itertools.islice(range(10), 1, 5)

for item in result:
	print(item, end=" ")
print()

>>> 1 2 3 4 
```

### 7.3 `islice(seq, start, stop, step)`

```
result = itertools.islice(range(10), 1, 5, 2)

for item in result:
	print(item, end=" ")
print()

>>> 1 3 
```

### 7.4 pragmatic example

**`32test.log`**

```
Date: 2018-11-08
Author: Corey
Description: This is a sample log file

Okay, so this is a sample entry.
I'm going to write a few more lines here.
For the sake of this video, let's pretend this log file is thousands and thousands of lines... okay?
```

```
with open('32test.log', 'r') as f:
	header = itertools.islice(f, 3)

	for line in header:
		print(line, end='')

Date: 2018-11-08
Author: Corey
Description: This is a sample log file
```


## 8.`itertools.compress(items, selectors)`

```
selectors = [True, True, False, True]

result = itertools.compress(letters, selectors)

for item in result:
	print(item)
	
>>> a
>>> b
>>> d
```

## 9.`filter()`, `itertools.filterfalse()` , `itertools.dropwhile()` and `itertools.takewhile()` 

```
filter(function, iterable)
```

### 9.1 `filter()`

```
numbers = [0, 1, 2]

def lt_2(n):
	if n < 2:
		return True
	else:
		return False
		
result = filter(lt_2, numbers)

for item in result:
	print(item)

>>> 0
>>> 1
```

### 9.2 `itertools.filterfalse()`

```
result = itertools.filterfalse(lt_2, numbers)

for item in result:
	print(item)

>>> 2
```

### 9.3 `itertools.dropwhile()`


**2 is not less than 2, so stop apply the filter**

```
numbers = [0, 1, 2, 3, 2, 1, 0]

result = itertools.dropwhile(lt_2, numbers)

for item in result:
	print(item, end="")
print()

23210
```
### 9.4 `itertools.takewhile()`

**0, 1 is less than 2, until 2 return false**

```
result = itertools.takewhile(lt_2, numbers)

for item in result:
	print(item)

>>> 0
>>> 1
```	

## 10.`itertools.accumulate()`

```
result = itertools.accumulate(numbers)

for item in result:
	print(item, end=' ')
print()

>>> 0 1 3 6 8 9 9 
```

### 10.1 operator

```
import operator

numbers = [1, 2, 3, 2, 1, 0]

result = itertools.accumulate(numbers, operator.mul) # multiply
for item in result:
	print(item, end=' ')
print()

>>> 1 2 6 12 12 0 
```

## 11.`itertools.groupby()`

```
people = [
    {
        'name': 'John Doe',
        'city': 'Gotham',
        'state': 'NY'
    },
    {
        'name': 'Jane Doe',
        'city': 'Kings Landing',
        'state': 'NY'
    },
    {
        'name': 'Corey Schafer',
        'city': 'Boulder',
        'state': 'CO'
    },
    {
        'name': 'Al Einstein',
        'city': 'Denver',
        'state': 'CO'
    },
    {
        'name': 'John Henry',
        'city': 'Hinton',
        'state': 'WV'
    },
    {
        'name': 'Randy Moss',
        'city': 'Rand',
        'state': 'WV'
    },
    {
        'name': 'Nicole K',
        'city': 'Asheville',
        'state': 'NC'
    },
    {
        'name': 'Jim Doe',
        'city': 'Charlotte',
        'state': 'NC'
    },
    {
        'name': 'Jane Taylor',
        'city': 'Faketown',
        'state': 'NC'
    }
]

def get_state(person):
	return person['state']
	
person_group = itertools.groupby(people, get_state)

for key, group in person_group:
	print(key)
	
>>> NY
>>> CO
>>> WV
>>> NC

for key, group in person_group:
	for person in group:
		print(person)
	print()

>>> {'name': 'John Doe', 'city': 'Gotham', 'state': 'NY'}
>>> {'name': 'Jane Doe', 'city': 'Kings Landing', 'state': 'NY'}

>>> {'name': 'Corey Schafer', 'city': 'Boulder', 'state': 'CO'}
>>> {'name': 'Al Einstein', 'city': 'Denver', 'state': 'CO'}

>>> {'name': 'John Henry', 'city': 'Hinton', 'state': 'WV'}
>>> {'name': 'Randy Moss', 'city': 'Rand', 'state': 'WV'}

>>> {'name': 'Nicole K', 'city': 'Asheville', 'state': 'NC'}
>>> {'name': 'Jim Doe', 'city': 'Charlotte', 'state': 'NC'}
>>> {'name': 'Jane Taylor', 'city': 'Faketown', 'state': 'NC'}


for key, group in person_group:
	print(key, len(list(group)))

>>> NY 2
>>> CO 2
>>> WV 2
>>> NC 3
```


### 11.1 `itertools.tee()`

```
copy1, copy2 = itertools.tee(person_group)
```






