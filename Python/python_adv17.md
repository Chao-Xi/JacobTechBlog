# Context Managers - Efficiently Managing Resources

Context Managers are great for when we need to setup or teardown some resources during use. So these can be used for: open and closing files, opening and closing database connections, acquiring and releasing locks, and much much more.

### Without context manager

Need remember to close file, after operations done

```
f = open('20_sample.txt', 'w')
f.write('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
f.close()
```

### With context manager

```
with open('20_sample.txt', 'w') as f:
	f.write('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
```

**file close automatically**

### Self define context manager

```
class Open_File():

    def __init__(self, filename, mode):
    	self.filename = filename
    	self.mode = mode

    def __enter__(self):
        self.file = open(self.filename, self.mode)
        return self.file

    def __exit__(self, exc_type, exc_val, traceback):
        self.file.close()

with Open_File('20_sample.txt','w') as f:
	f.write('Testing')

print(f.closed)

>>> True
```

## contextmanager module

```
$ pip3 install contextlib2
```

```
from contextlib2 import contextmanager

@contextmanager
def open_file(file, mode):
	f = open(file, mode)
	yield f
	f.close()

with open_file('20_sample.txt', 'w') as f:
	f.write('Lorem ipsum dolor sit amet, consectetur adipiscing elit.')
```

## contextmanager module with change dir

### Old one, need change forward and back

```
from contextlib2 import contextmanager
import os

cwd = os.getcwd()      # get current dir
os.chdir('parse_dir')  # change to "parse_dir" dir
print(os.listdir())    # list files inside the dir
os.chdir(cwd)          # change back to current dir

cwd = os.getcwd()
os.chdir('demo_folder')
print(os.listdir())
os.chdir(cwd)

>>> ['ac-blackflag-14.txt', '14-blackflag.txt']
>>> ['file3', 'file2', 'file1']
```

### New one, can be easily reused

```
@contextmanager
def change_dir(destination):
	try:
		cwd = os.getcwd()
		os.chdir(destination)
		yield
	finally:
		os.chdir(cwd)

with change_dir("parse_dir"):
	print(os.listdir())

with change_dir("demo_folder"):
	print(os.listdir())

>>> ['ac-blackflag-14.txt', '14-blackflag.txt']
>>> ['file3', 'file2', 'file1']
```

