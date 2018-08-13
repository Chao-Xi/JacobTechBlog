# Python Tutorial Advance 3

## CSV Module - How to Read, Parse, and write CSV Files

```
import csv

with open('name.csv','r') as csv_file:
	csv_reader = csv.reader(csv_file)
	# next(csv_reader)
	with open('new_name.csv','w') as new_file:
		csv_writer=csv.writer(new_file, delimiter='\t')
		for line in csv_reader:
			csv_writer.writerow(line)
```

**name.csv** 

```
first_name,last_name,email
John,Doe,john-doe@bogusemail.com
Mary,Smith-Robinson,maryjacobs@bogusemail.com
Dave,Smith,davesmith@bogusemail.com
```

### csv.reader(csv_file_new, delimiter='\t')

```
with open('new_name.csv','r') as csv_file_new:
	csv_reader_new = csv.reader(csv_file_new, delimiter='\t')
	for line in csv_reader_new:
		print(line)

```

```
['first_name', 'last_name', 'email']
['John', 'Doe', 'john-doe@bogusemail.com']
['Mary', 'Smith-Robinson', 'maryjacobs@bogusemail.com']
```


### csv.DictReader(csv_file_dict, delimiter='\t')
```
with open('new_name.csv','r') as csv_file_dict:
	csv_reader_dict = csv.DictReader(csv_file_dict, delimiter='\t')
	for line in csv_reader_dict:
		print(line)		
```

```
OrderedDict([('first_name', 'John'), ('last_name', 'Doe'), ('email', 'john-doe@bogusemail.com')])
OrderedDict([('first_name', 'Mary'), ('last_name', 'Smith-Robinson'), ('email', 'maryjacobs@bogusemail.com')])
OrderedDict([('first_name', 'Dave'), ('last_name', 'Smith'), ('email', 'davesmith@bogusemail.com')])
```


### Delete special row when using copy but still keep 1st line

```
with open('name.csv','r') as csv_file_dict_new:

	csv_reader_dict_new = csv.DictReader(csv_file_dict_new)

	with open('new_name_dict_new.csv','w') as new_file:
		fieldnames = ['first_name', 'last_name', 'email']
		csv_writer=csv.DictWriter(new_file, fieldnames=fieldnames, delimiter='\t')
		csv_writer.writeheader()
		for line in csv_reader_dict_new:
			del line['email']  
			#delete all email data except title
			csv_writer.writerow(line)	
```

## CSV read and copy function

```
import csv
def read_csv_file(path):
	with open(path, 'r') as f: # r表示读取，b表示读取的文件
		reader = csv.reader(f)
		for row in reader:
			print(row)
	f.close()

read_csv_file('C2SectionRobot.csv')
```
```
['Section Name', 'Menu Name', 'Channel ID', 'Editor (User Name)']
['Joe Smith', 'Joe Smith', '3711', 'kcraig']
['Jason Jones', 'Jason Jones', '3711', 'vcraig']
['Rick Jones', 'Rick Jones', '3711', 'scraig']
['Jessica Rogers', 'Jessica Rogers', '3711', 'vcraig']
['Zachery Smith', 'Zachery Smith', '3711', 'scraig']
['Mathematics', 'Mathematics', '3710', '']
['Social Studies', 'Social Studies', '3710', '']
['Music', 'Music', '3710', '']
['Visual Arts', 'Visual Arts', '3710', '']
```

```
def read_csv_data(path):
	data_lines = []
	with open(path,'r') as f:
		reader = csv.reader(f)
		fields = next(reader) # write next(reader) in python3
		for row in reader:
			items = dict(zip(fields, row))
			data_lines.append(items)
	f.close()
	return data_lines

print(read_csv_data('C2SectionRobot.csv'))		
```


```
def write_csv_file(path):
	with open(path, 'w') as f:
		writer = csv.writer(f)
		writer.writerow(['name', 'address', 'age']) #writerow是写入一行数据
		data=[
              ( 'ych ','china','25'),
              ( 'Lily', 'USA', '24')]
		writer.writerows(data)
	f.close() 

write_csv_file('write.csv')

```

## Real World Example - Parsing Names From a CSV to an HTML list

```
import csv

html_output = ''
names = []

with open('patron.csv','r') as data_file:
	csv_data = csv.DictReader(data_file) 
	#we dont want first line as dummy line
	next(csv_data)

	for line in csv_data:
		if line['FirstName'] == "No Reward":
			break
		names.append(f"{line['FirstName']} {line['LastName']}")

# for name in names:
# 	print(name)
html_output += f'<p>There are currently {len(names)} public contributors. Thank you!</p>'
html_output += '\n<ul>'
for name in names:
	html_output += f'\n\t<li>{name}</li>'
html_output += '\n</ul>'

print(html_output)

with open ('patrons.html', 'w') as wf:
	for line in html_output:
		wf.write(line)	
		
```		
			
```
<p>There are currently 30 public contributors. Thank you!</p>
<ul>
	<li>John Doe</li>
	<li>Dave Smith</li>
	<li>Mary Jacobs</li>
	<li>Jane Stuart</li>
    ...
</ul>
```	