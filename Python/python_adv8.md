# Generators

通过列表生成式，我们可以直接创建一个列表。但是，受到内存限制，列表容量肯定是有限的。而且，创建一个包含100万个元素的列表，不仅占用很大的存储空间，如果我们仅仅需要访问前面几个元素，那后面绝大多数元素占用的空间都白白浪费了。

所以，如果列表元素可以按照某种算法推算出来，那我们是否可以在循环的过程中不断推算出后续的元素呢？这样就不必创建完整的list，从而节省大量的空间。在Python中，这种一边循环一边计算的机制，称为生成器：`generator`。

## `() tuple` Generator

要创建一个`generator`，有很多种方法。第一种方法很简单，只要把一个列表生成式的`[]`改成`()`，就创建了一个`generator`：

```
L = [x * x for x in range(10)]
print(L)

>>> [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```


```
g = (x * x for x in range(10))
print(g)

>>> <generator object <genexpr> at 0x1092c1200>
```

创建`L`和`g`的区别仅在于最外层的`[]`和`()`，`L`是一个`list`，而`g`是一个`generator`。

我们可以直接打印出`list`的每一个元素，但我们怎么打印出`generator`的每一个元素呢？

如果要一个一个打印出来，可以通过`next()`函数获得`generator`的下一个返回值：


```
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))
print(next(g))


>>>
0
1
4
9
16
25
36
49
64
81
Traceback (most recent call last):
  File "/Users/jxi/python/adv1/11_generator.py", line 51, in <module>
    print(next(g))
StopIteration
```

我们讲过，`generator`保存的是算法，每次调用`next(g)`，就计算出`g`的下一个元素的值，直到计算到最后一个元素，没有更多的元素时，抛出`StopIteration`的错误。

当然，上面这种不断调用`next(g)`实在是太变态了，正确的方法是使用`for`循环，因为`generator`也是可迭代对象

```
g = (x * x for x in range(10))
for n in g:
	print(n, end=',')

0,1,4,9,16,25,36,49,64,81,
```

所以，我们创建了一个`generator`后，基本上永远不会调用`next()`，而是通过`for`循环来迭代它，并且不需要关心`StopIteration`的错误。

`generator`非常强大。如果推算的算法比较复杂，用类似列表生成式的`for`循环无法实现的时候，还可以用函数来实现。

## `yield` Generator

### Normal list append

```
def squre_numbers(nums):
	result = []
	for i in nums:
		result.append(i*i)
	return result


my_nums = squre_numbers([1,2,3,4,5])

print(my_nums)

>>> [1, 4, 9, 16, 25]
```

###  Tuple yield generator

#### The generator don't hold entire result in memory it yields(cache in mem) one result at a time

```
def squre_numbers2(nums):
	for i in nums:
		yield(i*i)               # yield 
 
my_nums = squre_numbers2([1,2,3,4,5])

print(my_nums)
>>> <generator object squre_numbers2 at 0x103a28200>


for num in my_nums:
	print(num,  end=', ')
>>> 1, 4, 9, 16, 25, 
```


####  generator的函数，在每次调用`next()`的时候执行，遇到`yield`语句返回，再次执行时从上次返回的`yield`语句处继续执行。


## Generator Performance

### `mem_profile.py`

```
from pympler import summary, muppy
import psutil
import resource
import os
import sys

def memory_usage_psutil():
    # return the memory usage in MB
    process = psutil.Process(os.getpid())
    mem = process.memory_info()[0] / float(2 ** 20)
    return mem

def memory_usage_resource():
    rusage_denom = 1024
    if sys.platform == 'darwin':
        # ... it seems that in OSX the output is different units ...
        rusage_denom = rusage_denom * rusage_denom
    mem = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / rusage_denom
    return mem
```

### `11_gengerator2_performance.py`

```
import mem_profile
import random
import time

names = ['John', 'Corey', 'Adam', 'Steve', 'Rick', 'Thomas']
majors = ['Math', 'Engineering', 'CompSci', 'Arts', 'Business']

print(f'Memory (Before): {mem_profile.memory_usage_psutil()}MB')

>>> Memory (Before): 24.05078125MB


def people_list(num_people):
	result = []
	for i in range(num_people):
		person = {
                   'id': 1,
                   'name': random.choice(names),
		           'major': random.choice(majors)
		          }
		result.append(person)
	return result

# put 1000000 number of person inside the list
t1 = time.clock()
people = people_list(1000000)
t2 = time.clock()

# output memory usage and time usage
print(f'Memory (After) : {mem_profile.memory_usage_psutil()}Mb')
print(f'Took {t2-t1} Seconds')

>>> Memory (After) : 256.453125Mb     #The usage is huge 
>>> Took 2.1111489999999997 Seconds  
```

### use `generator` 

```
def people_generator(num_people):
	for i in range(num_people):
		person = {
                   'id': 1,
                    'name': random.choice(names),     # random module
		             'major': random.choice(majors)
		          }
		yield person       # use generator not append to list

t1 = time.clock()
people = people_generator(1000000)
t2 = time.clock()

print(f'Memory (After) : {mem_profile.memory_usage_psutil()}Mb')
print(f'Took {t2-t1} Seconds')

>>>  24.078125Mb                      # The usage is teeny-tiny and so much quick
>>>  3.999999999976245e-06 Seconds
```
