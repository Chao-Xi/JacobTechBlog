![Alt Image Text](image/awk.jpg "Headline image")

# 用awk做基本运算

`awk`是非常强大的文本处理工具，之前经常见到脚本里面有使用，但是没有自己完完整整来写过awk命令。现在有一个非常的大的日志文件需要分析。需求是将日志文件中记录的耗时时间评价值、最大值、最小值计算出来。日志的格式如下：

```
[2016-03-30 00:02:02,475] [17243] [140344433927936] [MainThread] [tasks.py:733] DEBUG [upload to oss] upload file /data/image5/user_upload_image/20160330/00/1458483897397580_101183475_1459267295740.jpg to oss cost time 28 ms

```

其中的数字`28`就是我们需要统计的数据。

```
[2016-03-30            1
00:02:02,475]          2
[17243]                3
[140344433927936]      4
[MainThread]           5
[tasks.py:733]         6
DEBUG                  7
[upload                8
to                     9
oss]                   10
upload                 11
file                   12 
/data/...              13
to                     14
oss                    15
cost                   16
time                   17
28                     18
```

## awk用法

数据`28`按照空格’ ‘分割过后是第18位，所以在命令里面用`$18`就能获取到对应的数据了，如下

```
$ cat test.log | grep 'cost' | awk 'BEGIN {sum=0}{sum+=$18}END{print "avg=",sum/NR}'
avg= 34.6
```

其中`NR`表示总的行数。该命令计算出评价值是完完全全没有问题的。但是在计算最小值的时候：

```
cat test.log |grep 'cost'| awk 'BEGIN {min = 199999}{if ($18<min) min=$18 fi} END {print "min=",min}'
min= 100
```
计算出来却始终是100，按同样的方法计算最大值是999，这显然和评价值不符，而且我查看了日志里面有很多小于100的数据，所以肯定是计算有误。

后面用如下排序命令查看了下结果：

```
cat test.log |grep 'cost'| awk 'BEGIN {min = 199999}{if ($18<min) min=$18 fi} END {print "min=",min}'
```

结果是100在20的前面，这肯定不符合要求。原来这是因为**`默认情况下，awk是按字符串方式进行比较的`**,但我们这里是想让其按照数字的方式进行比较，所以为了能正确获取到最大值，需要让awk按数字的方式去比较，在比较前需要先将变量强制转换为整数型，这样获取到的最大值才会是正确的

```
cat test.log |grep 'cost' |awk 'BEGIN {min=19999} {if ($18+0 < min + 0) min=$18 fi}END{print "Min=",min}'

Min= 12
```

```
cat test.log |grep 'oss cost time'|awk 'BEGIN {max=0}{if($18+0>max+0)max=$18 fi}END{print "Max=",max}'

Max= 6262
```
这里可以看到在比较前对两个变量先加0（两个变量需要同时做转换，不然也得不到预期效果），就相当于是做从字符串到数字类型的转换操作。

相关链接: 

1. [test.log](test.log)
2. [AWK程序设计语言(AWK入门指南)](https://awk.readthedocs.io/en/latest/chapter-one.html)
