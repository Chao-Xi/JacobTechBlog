# Linux硬盘性能检测 - 基础

**介绍Linux下如何使用`dd`或`hdparm`命令对硬盘进行基础性能测试，包括读取及写入速度测试。**

## `dd`

```
$ dd if=/dev/zero of=testfile bs=1M count=512 conv=fdatasync
```

* **if**: 读取数据=>`/dev/zero`
* **of**: **写入的数据** => `testfile`
* **bs**: block size
* **count**: 读取数据的大小， 例如从`/dev/zero`读取`512M`的信息,写入`testfile`
* **fdatasync**: 保证数据直接写入硬盘，而非内存

### 1.清除`cache`缓存

```
$ echo 3 > /proc/sys/vm/drop_caches
```

### 2.多次运行命令，取平均值,获得磁盘性能

```
$ su -
$ echo 3 > /proc/sys/vm/drop_caches

# dd if=/dev/zero of=testfile bs=1M count=512 conv=fdatasync
512+0 records in
512+0 records out
536870912 bytes (537 MB) copied, 0.61208 s, 877 MB/s
```

```
# dd if=/dev/zero of=testfile bs=1M count=512 conv=fdatasync
512+0 records in
512+0 records out
536870912 bytes (537 MB) copied, 0.515241 s, 1.0 GB/s
```


## `hdparm`获取修改磁盘信息

### `-t`测试硬盘I/O (多次运行命令，取平均值,获得磁盘性能)

```
# hdparm -t /dev/sda1

/dev/sda1:
 Timing buffered disk reads: 1562 MB in  3.00 seconds = 520.41 MB/sec
```
**速度： seconds = 520.41 MB/sec**


### `-T`内存缓存读取速率

```
# hdparm -T /dev/sda1

/dev/sda1:
 Timing cached reads:   20052 MB in  2.00 seconds = 10034.32 MB/sec
```


## `dmesg`查看硬件`stata`信息

```
$ dmesg
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.13.0-135-generic (buildd@lgw01-amd64-028) (gcc version 4.8.4 (Ubuntu 4.8.4-2ubuntu1~14.04.3) ) #184-Ubuntu SMP Wed Oct 18 11:55:51 UTC 2017 (Ubuntu 3.13.0-135.184-generic 3.13.11-ckt39)
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-3.13.0-135-generic root=UUID=97cea586-4b5c-4710-8d23-5cae6c12ae40 ro console=tty1 console=ttyS0
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
```

```
$ dmesg | grep sata
```

# Linux硬盘性能检测 - 高级

介绍Linux下如何使用`bonnie++`或`iozone`工具对系统IO进行详尽的性能测试，包括读取、写入、随机访问、`seek`、`rewrite`、`reread`等等。

## bonnie++

```
$ man bonnie++
NAME
       bonnie++ - program to test hard drive performance.

Bonnie++ is a program to test hard drives and file systems for performance or the lack therof. There are a many different types of file system oper‐
       ations which different applications use to different degrees. Bonnie++ tests some of them and for each test gives a result of  the  amount  of  work
       done  per  second  and the percentage of CPU time this took. For performance results higher numbers are better, for CPU usage lower are better (NB a
       configuration scoring a performance result of 2000 and a CPU result of 90% is better in terms of CPU use than a configuration delivering performance
       of 1000 and CPU usage of 60%).
```

```
$ sudo bonnie++ -u root
Using uid:0, gid:0.
Writing a byte at a time...done
Writing intelligently...done
Rewriting...done
Reading a byte at a time...done
Reading intelligently...done
start 'em...done...done...done...done...done...
Create files in sequential order...done.
Stat files in sequential order...done.
Delete files in sequential order...done.
Create files in random order...done.
Stat files in random order...done.
Delete files in random order...done.
Version  1.97       ------Sequential Output------ --Sequential Input- --Random-
Concurrency   1     -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
Jacob            2G  1380  99 761540  63 444916  31 +++++ +++ 1433008  42 +++++ +++
Latency              7842us   55943us   23162us    3599us    7704us   12339us
Version  1.97       ------Sequential Create------ --------Random Create--------
Jacob               -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16 +++++ +++ +++++ +++ +++++ +++ +++++ +++ +++++ +++ +++++ +++
Latency               848us     507us     782us     651us      66us     802us
1.97,1.97,Jacob,1,1557290182,2G,,1380,99,761540,63,444916,31,+++++,+++,1433008,42,+++++,+++,16,,,,,+++++,+++,+++++,+++,+++++,+++,+++++,+++,+++++,+++,+++++,+++,7842us,55943us,23162us,3599us,7704us,12339us,848us,507us,782us,651us,66us,802us
```

* `Sequential Output`,顺序输出  **Write**
* `Sequential Input`,顺序输入   **read**
* `Random Seek`, 随机寻址
* `Sequential Create`，顺序创建
* `Random Create`，随机创建
* `+++++`,**值过小，不准确**

## `iozone`适合高并发的I/O测试

```
$ sudo apt install iozone3
```

```
$ iozone -l 1 -u 1 -r 16k -s 128m -F tmpfile1
```

* `-l -u` **多进程，并发操作**
* `-l`： **lower**
* `-u`:  **upper**
* `-r`: **基本的读写的大小==应用的block大小**
* `-s`: **默认读写的大小(建议2 times 内存大小)**
* `-F`: **输出文件**


```
$ iozone -l 1 -u 1 -r 16k -s 128m -F tmpfile1
	Iozone: Performance Test of File I/O
	        Version $Revision: 3.420 $
		Compiled for 64 bit mode.
		Build: linux-AMD64

	Contributors:William Norcott, Don Capps, Isom Crawford, Kirby Collins
	             Al Slater, Scott Rhine, Mike Wisner, Ken Goss
	             Steve Landherr, Brad Smith, Mark Kelly, Dr. Alain CYR,
	             Randy Dunlap, Mark Montague, Dan Million, Gavin Brebner,
	             Jean-Marc Zucconi, Jeff Blomberg, Benny Halevy, Dave Boone,
	             Erik Habbinga, Kris Strecker, Walter Wong, Joshua Root,
	             Fabrice Bacchella, Zhenghua Xue, Qin Li, Darren Sawyer,
	             Vangel Bojaxhi, Ben England, Vikentsi Lapa.

	Run began: Wed May  8 07:18:57 2019

	Record Size 16 KB
	File size set to 131072 KB
	Command line used: iozone -l 1 -u 1 -r 16k -s 128m -F tmpfile1
	Output is in Kbytes/sec
	Time Resolution = 0.000001 seconds.
	Processor cache size set to 1024 Kbytes.
	Processor cache line size set to 32 bytes.
	File stride size set to 17 * record size.
	Min process = 1
	Max process = 1
	Throughput test with 1 process
	Each process writes a 131072 Kbyte file in 16 Kbyte records

	Children see throughput for  1 initial writers 	= 1672475.62 KB/sec
	Parent sees throughput for  1 initial writers 	=  830168.70 KB/sec
	Min throughput per process 			= 1672475.62 KB/sec
	Max throughput per process 			= 1672475.62 KB/sec
	Avg throughput per process 			= 1672475.62 KB/sec
	Min xfer 					=  131072.00 KB
...
```


```
$ iozone -l 1 -u 1 -r 16k -s 1g -F tmpfile2
```










