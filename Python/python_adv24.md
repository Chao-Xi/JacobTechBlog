# Else Clauses on Loops

```
my_list = [1,2,3,4,5]

for i in my_list:
	print(i)
else:
	print('Hit the for/Else Statement')

>>> 1
>>> 2
>>> 3
>>> 4
>>> 5
>>> Hit the for/Else Statement
```

So else clauses on loop, all statement execute, **Unless encounter break statement**


### for loop with else clauses

```
for i in my_list:
	print(i)
	if i == 3:
		break
else:
	print('Hit the for/Else Statement')


print("-"*15+" Next Part "+"-"*15)

>>> 1
>>> 2
>>> 3
```

### while loop with else clauses

```
i = 1
while i <=5:
	print(i)
	i += 1
	if i == 3:
		break
else:
	print('Hit the While/Else Statement')

>> 1
>> 2
```

### Pragmatic Sample

```
def find_index(to_search, target):
	for i,value in enumerate(to_search):
		if value == target:
			break
	else:
		return -1
	return i


my_list = ['K8S', 'AWS', 'Python', 'Chef']
index_location = find_index(my_list,'Python')
print(f'Location of target is index: {index_location}')
>>> Location of target is index: 2

index_location1 = find_index(my_list,'Ansible')
print(f'Location of target is index: {index_location1}')
>>> Location of target is index: -1
```

