# Python Tutorial Advance 1

## 1. OS Module - Use Underlying Operating System Functionality

### output current directory, list current directory and change to new directory

```
import os 
print(os.getcwd())

print(os.listdir())
os.chdir('new_location')
```


### create new directory and delete directory

```
os.mkdir('mkdir')
os.rmdir('mkdir')
```

### create multi-level directory and delete multi-level directory

```
os.makedirs('makedirs/subdir')
os.removedirs('makedirs/subdir')
```

### rename file

```
os.rename('rename.txt','rename_new.txt')

```

### stat() performs a stat system call on the given path.
```
print(os.stat('rename.txt'))
# os.stat_result(st_mode=33188, st_ino=8628252791, st_dev=16777220, st_nlink=1, st_uid=1641919302, st_gid=660531311, st_size=99, st_atime=1533883478, st_mtime=1530779236, st_ctime=1533883484)

print(os.stat('rename.txt').st_size)
# size of file, in bytes.

print(os.stat('rename.txt').st_mtime)
# time of most recent content modification.

from datetime import datetime
mod_time=os.stat('rename.txt').st_mtime
print(datetime.fromtimestamp(mod_time))
# 2018-07-05 16:27:16.962120 output readable time
```

### The method walk() generates the file names in a directory tree by walking the tree either top-down or bottom-up.

```
for dirpath, dirname, filenames in os.walk('/Users/jxi/python'):
	print('Current path:',dirpath)
	print('Directories:',dirname)
	print('Files:',filenames)
	print('')
	
# Current path: /Users/jxi/python
# Directories: ['uni_ttest', 'images', 'oop', '__pycache__', 'installpacks', 'nginx', 'md', 'adv1', 'base']
# Files: ['.DS_Store', 'methods.py', 'README.md', '0Setting.txt', 'module2.py', '1basic.txt'	
```

### output environment variable and join the relative path with env path

```
print(os.environ.get('HOME'))
# /Users/jxi

filepath=os.path.join(os.environ.get('HOME'), '/python/adv1/path_test.txt')
print(filepath)
#/python/adv1/path_test.txt
```

### os path functions

```
print(os.path.basename('/Users/jxi/python/adv1/path_test.txt'))
print(os.path.dirname('/Users/jxi/python/adv1/path_test.txt'))
print(os.path.split('/Users/jxi/python/adv1/path_test.txt'))
print(os.path.exists('/Users/jxi/python/adv1/path_test.txt'))
print(os.path.isfile('/Users/jxi/python/adv1/rename.txt'))
print(os.path.isdir('/Users/jxi/python/adv1/'))
print(os.path.splitext('/Users/jxi/python/adv1/rename.txt'))


# path_test.txt
# /Users/jxi/python/adv1
# ('/Users/jxi/python/adv1', 'path_test.txt')
# False
# True
# True
# ('/Users/jxi/python/adv1/rename', '.txt')
```

