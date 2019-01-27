# Set Methods (Remove duplicate)

Set data structure in-depth and discovering how it can help us solve some common problems. The set can not only solve certain problems more quickly but is also more efficient in many cases.

## Create and update Set

### 1.Method one

```
s1 = {1, 2, 3 ,4, 5}
print(s1)

>>> {1, 2, 3, 4, 5}
```

### 2.Method two

```
s2 = set([1, 2, 3, 4, 5])
print(s2)

>>> {1, 2, 3, 4, 5}
```


### 3.Remove duplicate

```
s3 = {1, 2, 3 ,4, 5, 1, 2 ,3}
print(s3)

>>> {1, 2, 3, 4, 5}
```

### 4.Add element

```
s1.add(6)
print(s1)

>>> {1, 2, 3, 4, 5, 6}
```

### 5.Update element

```
s2.update([6, 7, 8])
print(s2)
>>> {1, 2, 3, 4, 5, 6, 7, 8}


s4 = {7, 8, 9}

s2.update([6, 7, 8], s4)
print(s2)           # remove duplciate
>>> {1, 2, 3, 4, 5, 6, 7, 8, 9}
```

### 6.Remove and discard

```
s2.remove(8)  #8 is value in set
print(s2)
>>> {1, 2, 3, 4, 5, 6, 7, 9}

s2.remove(8)  
print(s2)
>>> KeyError: 8, 
>>> 8 is not exist

s2.discard(8)
print(s2)
>>> {1, 2, 3, 4, 5, 6, 7, 9}.  # no error report
```

## Multiple Sets interact

```
s1 = {1, 2, 3}
s2 = {2, 3, 4}
s3 = {3, 4, 5}

### intersection()
s4 = s1.intersection(s2)
print(s4)
>>> {2, 3}


s5 = s1.intersection(s2,s3)
print(s5)
>>> {3}

### difference() give a number in s1 but not in s2
s6 = s1.difference(s2)
print(s6)
>>> {1}

### give an number in s2 but neither in s1 or s3
s7 = s2.difference(s1, s3)
print(s7)
>>> set()

### symmetric_difference() give the different numbers from s1 and s2
s8 = s1.symmetric_difference(s2) 
print(s8)
>>> {1, 4}
```

## Quick remove duplicate from a `list`

**list -> set -> list**

```
l1 = [1, 2, 3, 1, 2, 3]
l2 = list(set(l1))   
print(l2)
>>> [1, 2, 3]
```

## Pragmatic example

```
employees = ['Corey', 'Jim', 'Steven', 'April', 'Judy', 'Jenn', 'John', 'Jane']

gym_members = ['April', 'John', 'Corey']

developers = ['Judy', 'Corey', 'Steven', 'Jane', 'April']

result1 = set(gym_members).intersection(developers)
print(result1)
>>> {'April', 'Corey'}

result2 =set(employees).difference(gym_members, developers)
print(result2)
>>> {'Jim', 'Jenn'}

### Similar to and short for

if 'Steven' in developers:
	print('Found!')
>>> Found!
```
 


