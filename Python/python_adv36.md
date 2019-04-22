# Comprehensions - How they work in lists, dicts, and sets

Python comprehensions are a very natural and easy way to create lists, dicts, and sets. 

They are also a great alternative to using maps and filters within python. 

**If you are using maps, filters, or for loops to create your lists,** then most likely you could and should be using comprehensions instead.

## 1.Lists using Comprehensions，maps and filters

### Traditional way to loop the array and append it

```
nums = [1,2,3,4,5,6,7,8,9,10]

my_list = []
for n in nums:
	my_list.append(n)

print(my_list)

> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

### Comprehension way one line to loop the array

```
my_list  = [n for n in nums]
print(my_list)

> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

## I want 'n*n' for each 'n' in nums

```
my_list1 = []

for n in nums:
  my_list1.append(n*n)

print(my_list1)
> [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```



### Comprehension way one line to loop and do the calculation

```
my_list1 = [n*n for n in nums]
print(my_list1)

> [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```


### Mapping and filter in lists

**Using a map + lambda + list() in python3**

```
my_list1 = list(map(lambda n: n*n, nums))
print(my_list1)

> [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```

## I want 'n' for each 'n' in nums if 'n' is even

### Traditional Way

```
my_list2 = []
for n in nums:
  if n%2 == 0:
    my_list2.append(n)
print(my_list2)

> [2, 4, 6, 8, 10]
```

### Comprehension way

```
my_list2 = [n for n in nums if n%2 == 0 ]
print(my_list2)

> [2, 4, 6, 8, 10]
```

### Using a filter + lambda

```
my_list2 = list(filter(lambda n: n%2 == 0, nums))
print(my_list2)

> [2, 4, 6, 8, 10]
```

## 2.Double Loop


**I want a (letter, num) pair for each letter in 'abcd' and each number in '0123'**

### Traditional way

```
my_list3 = []
for letter in 'abcd':
  for num in range(4):
    my_list3.append((letter,num))
print(my_list3)

> [('a', 0), ('a', 1), ('a', 2), ('a', 3), ('b', 0), ('b', 1), ('b', 2), ('b', 3), ('c', 0), ('c', 1), ('c', 2), ('c', 3), ('d', 0), ('d', 1), ('d', 2), ('d', 3)]
```

### Comprehension way

```
my_list3 = [(letter, num) for letter in 'abcd' for num in range(4)]
print(my_list3)

> [('a', 0), ('a', 1), ('a', 2), ('a', 3), ('b', 0), ('b', 1), ('b', 2), ('b', 3), ('c', 0), ('c', 1), ('c', 2), ('c', 3), ('d', 0), ('d', 1), ('d', 2), ('d', 3)]
```

## 3.Dictionary Comprehensions

### zip() function

```
names = ['Bruce', 'Clark', 'Peter', 'Logan', 'Wade']
heros = ['Batman', 'Superman', 'Spiderman', 'Wolverine', 'Deadpool']
print(list(zip(names, heros)))

> [('Bruce', 'Batman'), ('Clark', 'Superman'), ('Peter', 'Spiderman'), ('Logan', 'Wolverine'), ('Wade', 'Deadpool')]
```

#### I want a `dict{'name': 'hero'}` for each name,hero in `zip(names, heros)`

**Traditional way**

```
my_dict = {}
for name, hero in zip(names, heros):
    my_dict[name] = hero
print(my_dict)

> {'Bruce': 'Batman', 'Clark': 'Superman', 'Peter': 'Spiderman', 'Logan': 'Wolverine', 'Wade': 'Deadpool'}
```

### Comprehension way

```
my_dict2 = {name: hero for name, hero in zip (names, heros)}
print(my_dict2)

> {'Bruce': 'Batman', 'Clark': 'Superman', 'Peter': 'Spiderman', 'Logan': 'Wolverine', 'Wade': 'Deadpool'}
```

### If name not equal to Peter

```
my_dict3 = {name: hero for name, hero in zip (names, heros) if name != 'Peter'}
print(my_dict3)

> {'Bruce': 'Batman', 'Clark': 'Superman', 'Logan': 'Wolverine', 'Wade': 'Deadpool'}
```

## 4.Set Comprehensions

```
nums = [1,1,2,1,3,4,3,4,5,5,6,7,8,7,9,9]
my_set = set()
for n in nums:
    my_set.add(n)
print(my_set)

> {1, 2, 3, 4, 5, 6, 7, 8, 9}
```

### Comprehension way

```
my_set2 = {n for n in nums}
print(my_set2)

> {1, 2, 3, 4, 5, 6, 7, 8, 9}
```

## 5.Generator Expressions

**I want to yield `'n*n'` for each 'n' in nums**

```
nums = [1,2,3,4,5,6,7,8,9,10]

def gen_func(nums):
    for n in nums:
        yield n*n

my_gen = gen_func(nums)

for i in my_gen:
    print(i)

1
4
9
16
25
36
49
64
81
100
```
### Comprehension way

```
my_gen2 = (n*n for n in nums)

for i in my_gen2:
    print(i)

1
4
9
16
25
36
49
64
81
100
```