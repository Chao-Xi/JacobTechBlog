# Python Tutorial for Beginners

## 1.Dictionaries - Working with Key-Value Pairs

### Part 1

```
dict = {'key':'value', 'key':[]}   //list can be played as value
print(dict['key'])
```
```
AS_dict_old = {'1': "Assassin's Creed", '2':["Assassin's Creed II", 'Brotherhood', 'Revelations'], "3":"Assassin's Creed III"}
print('dict:', AS_dict_old)
print('dict:', AS_dict_old['2'])

#  dict: {'1': "Assassin's Creed", '2': ["Assassin's Creed II", 'Brotherhood', 'Revelations'], '3': "Assassin's Creed III"}
#  dict: ["Assassin's Creed II", 'Brotherhood', 'Revelations']
```

### Part 2

```
//add new pair to the dict
dict_old['new_key']=new_value

//get dict value by key
print(dict.get('key_value'))

//update value
dict_old.update({'old_key':'new_value'})

popped_dict= dict_old.pop('key_value')
```

```
AS_dict_old['4'] = 'IV Black Flag'
print('get:', AS_dict_old.get('3'))
print('get:', AS_dict_old.get('4'))
# get: Assassin's Creed III
# get: IV Black Flag

print('dict:', AS_dict_old)
AS_dict_old.update({'4':"Assassin's Creed IV Black Flag"})
print('dict after update:', AS_dict_old)
# dict: {'1': "Assassin's Creed", '2': ["Assassin's Creed II", 'Brotherhood', 'Revelations'], '3': "Assassin's Creed III", '4': 'IV Black Flag'}
# dict after update: {'1': "Assassin's Creed", '2': ["Assassin's Creed II", 'Brotherhood', 'Revelations'], '3': "Assassin's Creed III", '4': "Assassin's Creed IV Black Flag"}

as4 = AS_dict_old.pop('4')
print('dict after pop:', AS_dict_old)
print(as4)
# dict after pop: {'1': "Assassin's Creed", '2': ["Assassin's Creed II", 'Brotherhood', 'Revelations'], '3': "Assassin's Creed III"}
# Assassin's Creed IV Black Flag

```
### Part 3

```
//dict methods
len(dict)
dict.keys()
dict.values()
dict.items()   output key-value pairs

//loop dict
for key, value in dict.items():
	print(key, value)
```

```
print(len(AS_dict_old)) 
print(AS_dict_old.keys())
print(AS_dict_old.values())
print(AS_dict_old.items ())
# 3
# dict_keys(['1', '2', '3'])
# dict_values(["Assassin's Creed", ["Assassin's Creed II", 'Brotherhood', 'Revelations'], "Assassin's Creed III"])
# dict_items([('1', "Assassin's Creed"), ('2', ["Assassin's Creed II", 'Brotherhood', 'Revelations']), ('3', "Assassin's Creed III")])


for key, value in AS_dict_old.items():
	print(key, value)
	
# 1 Assassin's Creed
# 2 ["Assassin's Creed II", 'Brotherhood', 'Revelations']
# 3 Assassin's Creed III	
```

## 2.Empty data type

```
empty_list = []   or   empty_list=list()
empty_tuple = ()  or   empty_tuple=tuple()
empty_set = set()    {} doesn't work for empty set
empty_dict = {}  or    empty_dict = dict()
```



