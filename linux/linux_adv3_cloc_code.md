# 使用cloc进行代码统计

## 简单的linux命令

```
$ find . | xargs cat | wc -l
```

* `find .` 当前目录下的所有文件
* `xargs cat` 传递给`cat`
* `wc -l`统计行数

```
$ cd /Users/jxi/python/riot
$ $ find . | xargs cat | wc -l
cat: .: Is a directory
cat: ./log-percentile: Is a directory
cat: ./log-percentile/memory_time_Test: Is a directory
cat: ./logs: Is a directory
    1472
```

**总共： 1472 lines**


## cloc 

`CLOC`是一个使用`python`编写的代码统计工具。

[http://cloc.sourceforge.net/](http://cloc.sourceforge.net/)

```
$ sudo apt install cloc
```

```
$ cd /home/vagrant/git
$ cloc python_learn
      22 text files.
      22 unique files.
     107 files ignored.

http://cloc.sourceforge.net v 1.60  T=0.09 s (216.2 files/s, 4767.9 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Python                          19            116             28            275
-------------------------------------------------------------------------------
SUM:                            19            116             28            275
-------------------------------------------------------------------------------
```

```
$ cloc sshWebProject/
   11697 text files.
   10986 unique files.
    6158 files ignored.

http://cloc.sourceforge.net v 1.60  T=37.77 s (143.5 files/s, 32552.9 lines/s)
--------------------------------------------------------------------------------
Language                      files          blank        comment           code
--------------------------------------------------------------------------------
PHP                            3585          97032         241003         518491
Javascript                      861          38583          50614         195490
CSS                             223           3149           2503          40726
HTML                            246           1480            117          12115
SQL                             330           1456           2205           7771
LESS                             54            625            802           3143
Pascal                           12            551           2016           1761
XSD                              11            362            414           1430
Ruby                             30            163            198            990
XML                              19             47             55            893
Perl                              2            145             86            777
Bourne Shell                     17            137            110            561
Python                            2             75             95            520
YAML                             15             72             53            404
make                              7             67             29            189
Lua                               2             10              4             30
Bourne Again Shell                3              2              0             23
DOS Batch                         1              0              0              1
--------------------------------------------------------------------------------
SUM:                           5420         143956         300304         785315
--------------------------------------------------------------------------------
```

```
$ cloc TechBlog
     740 text files.
     734 unique files.
    5644 files ignored.

http://cloc.sourceforge.net v 1.60  T=5.09 s (22.0 files/s, 933.3 lines/s)
--------------------------------------------------------------------------------
Language                      files          blank        comment           code
--------------------------------------------------------------------------------
YAML                             72            132             75           2522
Python                           15            141             68            291
CSS                               2             48              2            231
Bourne Shell                      6             44             41            183
Groovy                            5             30             22            169
Java                              5             46              0            136
SASS                              1             36              0            134
HTML                              1              1              0             93
Bourne Again Shell                1             25             45             66
C#                                1             12              0             64
Maven                             1              7              0             57
Go                                1              3              1             22
MSBuild scripts                   1              2              0              6
--------------------------------------------------------------------------------
SUM:                            112            527            254           3974
```

### cloc  展示所有可用语言

```
$ cloc --show-lang
ABAP                       (abap)
ActionScript               (as)
Ada                        (ada, adb, ads, pad)
ADSO/IDSM                  (adso)
AMPLE                      (ample, dofile, startup)
Ant                        (build.xml)
Apex Trigger               (trigger)
Arduino Sketch             (ino, pde)
...
XSD                        (XSD, xsd)
XSLT                       (XSL, xsl, xslt, XSLT)
yacc                       (y)
YAML                       (yaml, yml)
```

### cloc 替换所有的注释

```
$ cloc --strip-comments=nc filename
```

```
$ cat test.py
#Print Welcome Message
message = """Assassain Creed
Nothing is true, everthing is permitted"""
print(message)
print(len(message))

print(message[10:15])
#first bracket include the letter, but the second does not

```

```
$ cloc --strip-comments=nc test.py
       1 text file.
       1 unique file.
Wrote test.py.nc
       0 files ignored.

http://cloc.sourceforge.net v 1.60  T=0.01 s (193.7 files/s, 6586.9 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Python                           1              8              3             23
-------------------------------------------------------------------------------

$ ls -la
-rw-rw-r-- 1 vagrant vagrant  815 May  7 08:10 test.py
-rw-rw-r-- 1 vagrant vagrant  664 May  7 08:11 test.py.nc
```

### check help

```
$ cloc --help
```

