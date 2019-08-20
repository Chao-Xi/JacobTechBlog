# Calling External Commands Using the Subprocess Module

```
import subprocess
subprocess.run('ls', shell=True)

$ python3 25sub_process.py 
0VScode_Script.py       18time_plot.py          25sub_process.py        9StackPlot.py
10stackplot.py          19live_realtime.py      25text.txt              data.csv
...
```

#### `shell=True`

```
subprocess.run('ls -la', shell=True)


total 10152
drwxr-xr-x  37 i515190  staff     1184 Aug 25 16:04 .
drwxr-xr-x  24 i515190  staff      768 Jun 23 19:19 ..
-rw-r--r--   1 i515190  staff      295 Jun 15 17:01 0VScode_Script.py
-rw-r--r--   1 i515190  staff      567 Jun 16 18:48 10stackplot.py
-rw-r--r--   1 i515190  staff      773 Jun 16 19:28 11Fill_betweens.py
-rw-r--r--   1 i515190  staff      867 Jun 16 19:23 12Fill_betweens2.py
-rw-r--r--   1 i515190  staff      470 Jun 17 09:38 13Histogram_plot.py
-rw-r--r--   1 i515190  staff      593 Jun 16 19:51 14Histogram_plot.py
```

#### passing whole command as argument 

* **Without `shell=True`**

```
p1 = subprocess.run(['ls','-la']) # 1st is command and 2nd is argument
```

```
p1 = subprocess.run(['ls','-la'])

print(p1)
print(p1.args)
print(p1.returncode) # return 0 error 
```

* argument: `args`
* returncode: `returncode`, `0 is right`, `1 is error` 

```
# print(p1)

$ python3 25sub_process.py 
total 10152
drwxr-xr-x  37 i515190  staff     1184 Aug 25 16:04 .
drwxr-xr-x  24 i515190  staff      768 Jun 23 19:19 ..
-rw-r--r--   1 i515190  staff      295 Jun 15 17:01 0VScode_Script.py
-rw-r--r--   1 i515190  staff      567 Jun 16 18:48 10stackplot.py
-rw-r--r--   1 i515190  staff      773 Jun 16 19:28 11Fill_betweens.py
-rw-r--r--   1 i515190  staff      867 Jun 16 19:23 12Fill_betweens2.py
...


# print(p1.args)
CompletedProcess(args=['ls', '-la'], returncode=0)


# print(p1.returncode) # return 0 error 

print(p1.returncode) # return 0 error 
```

###  `standard output` and `standard error`


#### `standard output`

```
print(p1.stdout)
```

* `capture_output=True`
* `text=True`

```
p1 = subprocess.run(['ls','-la'], capture_output=True, text=True)
print(p1.stdout)
```

**Output and write the context to a file:**

```
with open('25output.txt', 'w') as f:
    p1 = subprocess.run(['ls','-la'], stdout=f, text=True)
```

#### `standard error`


```
p1 = subprocess.run(['ls','-la', 'dne'], capture_output=True, text=True)
print(p1.returncode)
```

* `dne` is directory name

```
$ python3 25sub_process.py 
1
```

* `p1.returncode`: returned non-zero exit status 1

```
print(p1.stderr)
ls: dne: No such file or directory
```

* `p1.stderr`: ls: dne: No such file or directory

##### More comprehensive way to output error `check=True`

```
p1 = subprocess.run(['ls','-la', 'dne'], capture_output=True, text=True, check=True)

$ python3 25sub_process.py 
Traceback (most recent call last):
  File "25sub_process.py", line 21, in <module>
    p1 = subprocess.run(['ls','-la', 'dne'], capture_output=True, text=True, check=True)
  File "/Library/Frameworks/Python.framework/Versions/3.7/lib/python3.7/subprocess.py", line 487, in run
    output=stdout, stderr=stderr)
subprocess.CalledProcessError: Command '['ls', '-la', 'dne']' returned non-zero exit status 1.
```

#### redirect subprocess to dev null

```
p1 = subprocess.run(['ls','-la', 'dne'], stderr=subprocess.DEVNULL)
print(p1.stderr)
```

```
None
```


### grep from output in subprocess

```
p2 = subprocess.run('cat 25text.txt | grep -n text', capture_output=True, text=True, shell=True)
print(p2.stdout)

4:text
```

```
p3 = subprocess.run(['grep','-n','text'], capture_output=True, text=True, input=p2.stdout)
print(p3.stdout)
4:text
```

#### Input from subprocess

```
p2 = subprocess.run('cat 25text.txt', capture_output=True, text=True, shell=True)
p3 = subprocess.run(['grep','-n','text'], capture_output=True, text=True, input=p2.stdout)
print(p3.stdout)
```

```
4:text
```

