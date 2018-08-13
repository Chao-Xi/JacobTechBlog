# Python Tutorial Advance 2

## File Objects - Reading and Writing to Files

### copy a file 

```
with open('rename.txt', 'r') as rf:               #  with open and read as rf
	with open('copy_rename.txt', 'w') as wf:      # with open and write as wf
		for line in rf:                           # read this file line by line
			wf.write(line)                         # write this line to the new file
			
```

### copy an image

```
#b for binary

with open('test.jpg', 'rb') as rf:
	with open('copy_test.jpg', 'wb') as wf:
		for line in rf:
			wf.write(line)
```

### copy an image with chunk size

**If you don't want to store the entire file in memory, you can transfer it in pieces.**

```
with open('test.jpg', 'rb') as rf:
	with open('copy_test2.jpg', 'wb') as wf:
		chunk_size = 1024
		rf_chunk = rf.read(chunk_size)
		while len(rf_chunk)	> 0:
			wf.write(rf_chunk)
			rf_chunk = rf.read(chunk_size)
```


```
#File Object, read file as obecjt
f = open('rename.txt', 'r')

print(f.name)
# <_io.TextIOWrapper name='rename.txt' mode='r' encoding='US-ASCII'>

print(f)
# rename.txt

f.close()
```

**Dont have to close file, it will do it automatically**

```
#Dont have to close file, it will do it automatically

with open('rename.txt','r') as f:
	print(f.mode)
# r 
```

**Read file content line by line**

```
with open('rename.txt','r') as f:
	f_contents = f.read()
	print(f_contents)	
```	

**Read file content line by line**

```
with open('rename.txt','r') as f:

	# f_content = f.readline()
	# print(f_content, end='')	
	
	for line in f:
		print(line, end='')
	print()
```	

**Read file content line by line with special size**

```
with open('rename.txt','r') as f:
	f_contents=f.read(20)
	print(f_contents)
```	

**Read file content line by line with special size and add `star` to the line**

```
with open('rename.txt','r') as f:
	size_to_read=10

	f_contents=f.read(size_to_read)
	print(f.tell())

	while len(f_contents) > 0:
		print(f_contents, end='*')
		f_contents = f.read(size_to_read)
	print('')
```

```
with open('rename.txt','r') as f:
	size_to_read=10

	f_contents=f.read(size_to_read)
	print(f_contents, end='*')
    
	f_contents=f.read(size_to_read)
	print(f_contents, end='=')
		
# start o once again
	f.seek(0)
	f_contents=f.read(size_to_read)
	print(f_contents, end=')')
```


**change write content to another**

```
with open('write.txt','w') as f:
	f.write('Test')
	f.seek(0)
	f.write('R')

# first output `Test`	
# Then output `Rest`
```

## Automate Parsing and Renaming of Multiple Files

```
import os

os.chdir('/Users/jxi/python/adv1/parse_dir')

for f in os.listdir():
	# print(f)
	f_name, f_ext = os.path.splitext(f)

# get the filename and file extension

	f_series, f_title, f_year = f_name.split('-')
	f_series=f_series.strip()
	f_title=f_title.strip()
	f_year=f_year.strip()
	
	new_name='{}-{}{}'.format(f_year, f_title, f_ext)
	os.rename(f, new_name)
# rename all files with new name

#input:  ac-blackflag-14.txt
#output: 14-blackflag.txt 	
```