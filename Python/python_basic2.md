# Python Tutorial for Beginners

## 1.List functions and methods

###Part 1 Intro

```
list = [" ", " ", " ", " " ," "]
len(list)

list[num]
list[-num]
list[num:]
```

```
AC_list = ['Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey']
print (AC_list)
print ('Lenth of assassin creed list:', len(AC_list))    #Lenth of assassin creed list: 5
           
print (AC_list[4])                              # Odyssey             
print (AC_list[-1])                             # Odyssey
print (AC_list[2:])                             # ['Syndicate', 'Chronicles', 'Odyssey']
```

###Part 2  

```
Common List methods:
list.append('new ele')  or  list1.append(list2)
list.insert(num, 'new ele') or  list1.insert(num, list2)    num: insert position
list1.extend(list2)
list.remove('new ele')
list.index('val')

Common List functios:
list_popped = list.pop()
print('pop:', list)
print('popped:', list_popped)
```

```
AC_list.append('Black flag')
print (AC_list)        
# ['Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey', 'Black flag']


AC_list.insert(0, 'IV Black Flag')
print(AC_list)
# ['IV Black Flag', 'Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey']


AC_list_old = ['IV Black Flag', 'Rogue']

AC_list.extend(AC_list_old)
print('extend:', AC_list)
# extend: ['Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey', 'IV Black Flag', 'Rogue']

AC_list1 = ['Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey']
AC_list2 = ['Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey']

AC_list1.append(AC_list_old)
print('append:', AC_list1)
# append: ['Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey', ['IV Black Flag', 'Rogue']]

AC_list2.insert(0, AC_list_old)
print('insert:', AC_list2)
# insert: [['IV Black Flag', 'Rogue'], 'Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey']

AC_list1.remove('Odyssey')
print('remove:', AC_list1)
# remove: ['Origin', 'Revolution', 'Syndicate', 'Chronicles', ['IV Black Flag', 'Rogue']]

AC_list2_popped = AC_list2.pop()
print('pop:', AC_list2)
print('popped:', AC_list2_popped)
# pop: [['IV Black Flag', 'Rogue'], 'Origin', 'Revolution', 'Syndicate', 'Chronicles']
# popped: Odyssey
```
###Part 3

```
List sort methods:
list.reverse()

list.sort()
list.sort(reverse=True)

List sort functions:
new_sorted_list = sorted (list)

for i in range(1, 7):
	print('.', end =" ")
# loop without newline
```

```
AC_list.reverse()
print('reverse:', AC_list)  
# reverse: ['Rogue', 'IV Black Flag', 'Odyssey', 'Chronicles', 'Syndicate', 'Revolution', 'Origin']

num_list = [0, 32, 98, 27, 19, 20]
num_list1 = [0, 32, 98, 27, 19, 20]
num_list2 = [0, 32, 98, 27, 19, 20]

num_list.sort()
print('sort method:', num_list)
# sort method: [0, 19, 20, 27, 32, 98]

num_list1.sort(reverse=True)
print('reverse sort:', num_list1 )
# reverse sort: [98, 32, 27, 20, 19, 0]

num_list3 = sorted (num_list2 )
print('sort function:', num_list2 )
print('sort function:', num_list3 )
# sort function: [0, 32, 98, 27, 19, 20]
# sort function: [0, 19, 20, 27, 32, 98]

print('index:', AC_list )
print('index:', AC_list.index('Syndicate'))
# index: ['Rogue', 'IV Black Flag', 'Odyssey', 'Chronicles', 'Syndicate', 'Revolution', 'Origin']
# index: 4

for i in range(1, 7):
	print('.', end =" ")
# . . . . . . 
```

###Part 4   loop the list and enumerate

```
Loop the list:
for var in list:
	print(var)

for index, var in enumerate(list):
	print(index, var)

for index, var in enumerate(list, start=num):
	print(index, var)
```


```
print('Brotherhood in the list:', 'Brotherhood' in AC_list)
print('Chronicles in the list:', 'Chronicles' in AC_list)
# Brotherhood in the list: False
# Chronicles in the list: True


for ac in AC_list:
	print('for loop:', ac)

for index, ac in enumerate(AC_list):
	print('index', index, 'in loop is', ac)

print('###########################')

for index, ac in enumerate(AC_list, start=1):
	print('index', index, 'in loop is', ac)

# for loop: Rogue
# for loop: IV Black Flag
# for loop: Odyssey
# for loop: Chronicles
# for loop: Syndicate
# for loop: Revolution
# for loop: Origin

# index 0 in loop is Rogue
# index 1 in loop is IV Black Flag
# index 2 in loop is Odyssey
# index 3 in loop is Chronicles
# index 4 in loop is Syndicate
# index 5 in loop is Revolution
# index 6 in loop is Origin	

###########################
# index 1 in loop is Rogue
# index 2 in loop is IV Black Flag
# index 3 in loop is Odyssey
# index 4 in loop is Chronicles
# index 5 in loop is Syndicate
# index 6 in loop is Revolution
# index 7 in loop is Origin
```

###Part 5    join and split

```
join list to str:
new_str= ','.join(list)   //u use any sign to concat the list

split string to arra:
new_list=new_str.split(',')
```

```
AC_list_Arrow = ' ->  '.join(AC_list)
print('join:', AC_list_Arrow )

print(type(AC_list_Arrow))
new_AC_List = AC_list_Arrow.split(' -> ')
print('split:' ,new_AC_List )


# join: Rogue ->  IV Black Flag ->  Odyssey ->  Chronicles ->  Syndicate ->  Revolution ->  Origin
# <class 'str'>
# split: ['Rogue', ' IV Black Flag', ' Odyssey', ' Chronicles', ' Syndicate', ' Revolution', ' Origin']
```

## 2. Tuples difference between list [immutable, assignment unsupported]

```
# Tuples  ()
Tuples is almost like list, except it's immutable [unchanged]
tuples=('',''，''，'')
typles[0]=new_value
//TypeError: 'tuple' object does not support item assignment
```

```
# Tuples with () is immutable
tuple_1 = ('History', 'Math', 'Physics', 'CompSci')
tuple_2 = tuple_1

print(tuple_1)
print(tuple_2)

tuple_1[0] = 'Art'
#TypeError: 'tuple' object does not support item assignment

('History', 'Math', 'Physics', 'CompSci')
('History', 'Math', 'Physics', 'CompSci')
Traceback (most recent call last):
  File "/Users/jxi/python/base/2Arrays/tuples.py", line 21, in <module>
    tuple_1[0] = 'Art'
TypeError: 'tuple' object does not support item assignment
```

## 3. Sets: order of set always change 

```
Sets is another kind of list except the order of set always change 
set={'', '', '', '', ''}

set1.intersection(set2)   //The same part of set1 and set2, output as set also
set1.difference(set2)     //The different part from set1 to set2, which means set1 has but set2 doesn't, output as set also
set1.difference(set2) != set2.difference(set1)
set1.union(set2)          //concat set1 and set2

```

```
#Sets
AC_list = {'Origin', 'Revolution', 'Syndicate', 'Chronicles', 'Odyssey'}
print('Sets order alway change:', AC_list)
#Sets dont care about order
# Sets order alway change: {'Origin', 'Revolution', 'Odyssey', 'Syndicate', 'Chronicles'}

AC_list1 = {'Origin', 'Unity', 'Syndicate', 'Chronicles', 'Rogue'}
AC_list2 = {'Origin', 'IV Black Flag', 'Syndicate', 'Odyssey', 'Rogue'}
print('intersection same : ', AC_list1.intersection(AC_list2))
# intersection same :  {'Syndicate', 'Rogue', 'Origin'}

print('difference : ', AC_list1.difference(AC_list2))
print('difference : ', AC_list2.difference(AC_list1))
# difference :  {'Chronicles', 'Unity'}
# difference :  {'Odyssey', 'IV Black Flag'}

print(AC_list1.union(AC_list2))
# {'Syndicate', 'Chronicles', 'Rogue', 'IV Black Flag', 'Origin', 'Odyssey', 'Unity'}
```
