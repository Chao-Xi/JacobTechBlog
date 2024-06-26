# Linux 平均负载，附排查工具

## **什么是平均负载**


**简单的说平均负载是指单位时间内，系统处于可运行状态和不可中断状态的平均进程数，也就是说平均活跃进程数，它和CPU使用率并没有直接关系。**

这里解释一下可运行状态和不可中断这两个词。

### **可运行状态：**

指正在使用CPU或者正在等待CPU的进程，我们使用ps命令查看处于R状态的进程

### **不可中断状态**：

进程则是正处于内核态关键流程中的进程，并且这些流程是不可中断的。例如：常见的等待硬件设备I/O的响应，也就是我们在ps命令查看处于D状态的进程


比如，当一个进程向磁盘读写数据时，为了保证数据的一致性，在得到磁盘回复前，它是不能被其他进程中断或者打断的，这个时候的进程处于不可中断状态，如果此时的进程被打断了，就容易出现磁盘数据和进程数据不一致的问题。


所以，不可中断状态实际上是系统进程和硬件设备的一种保护机制。

因此，你可以简单理解为，平均负载就是平均活跃进程数。

**平均活跃进程数，直观上的理解就是单位时间内的活跃进程数，但它实际上是活跃进程数的指数衰减平均值**。

既然是平均活跃进程数，那么理想状态，就是每个CPU上都刚好运行着一个进程，这样每个CPU都会得到充分的利用。

**例如平均负载为2时，意味着什么呢？**

* 在只有2个CPU的系统上，意味着所有的CPU刚好被完全占用
* 在4个CPU的系统上，意味着CPU有50%的空闲
* 而在只有1个CPU的系统上，则意味着有一半的进程竞争不到CPU

## 平均负载和CPU使用率


现实工作中，我们经常容易把平均负载和CPU使用率混淆，所以在这里，我也做一个分区。

可能你会疑惑，既然平均负载代表的是活跃进程数，那平均负载高了，不就意味着CPU使用率高吗？

我们还是要回到平均负载的含义上来，平均负载是指单位时间内，处于可运行状态和不可中断状态的进程数，所以，它不仅包括了正常使用CPU的进程，还包括了等待CPU和等待I/O的进程。

而CPU使用率，是单位时间内CPU的繁忙情况的统计，跟平均负载并不一定完全对应，例如：

* CPU密集型进程，使用大量CPU会导致平均负载升高，此时这两者是一致的
* I/O密集型进程，等待I/O也会导致平均负载升高，但CPU使用率不一定很高
* 大量等待CPU的进程调度也会导致平均负载升高，此时的CPU使用率会很高


## 平均负载案例


这里我们需要安装几个工具**sysstat、stress、stress-ng**

这里Centos的sysstat版本会老一点，最好升级到最新版本。手动rpm安装或者源码安装

### 场景一、CPU密集型

**1、运行一个stress命令，模拟一个CPU使用率100%场景**

```
$ stress --cpu 1 --timeout 600
```

**2、开启第二个终端，uptime查看平均负载的变化情况**


```
$ watch -d uptime
 09:40:35 up 80 days, 18:41,  2 users,  load average: 1.62, 1.10, 0.87
```

**3、开启第三个终端，mpstat 查看CPU使用率的变化情况**

```
$ mpstat -P ALL 5 20
10:06:37 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:06:42 AM  all   31.50    0.00    0.35    0.00    0.00    0.00    0.00    0.00    0.00   68.15
10:06:42 AM    0    1.20    0.00    0.80    0.00    0.00    0.00    0.00    0.00    0.00   98.00
10:06:42 AM    1    7.21    0.00    0.40    0.00    0.00    0.00    0.00    0.00    0.00   92.38
10:06:42 AM    2  100.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00
10:06:42 AM    3   17.43    0.00    0.20    0.00    0.00    0.00    0.00    0.00    0.00   82.36
# -P ALL 表示监控所有CPU，后面数字5 表示间隔5秒输出一次数据
```

从第二个终端可以看到，1分钟平均负载增加到1.62，从第三个终端我们可以看到有一个CPU使用率100%，但iowait为0，这说明平均负载的升高正式由CPU使用率为100%

那我们查看是那个进程导致了CPU使用率为100%呢？我们可以使用pidstat来查看：

```
#每5秒输出一次数据
$ pidstat -u 5 1 
10:08:41 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
10:08:46 AM     0         1    0.20    0.00    0.00    0.00    0.20     0  systemd
10:08:46 AM     0       599    0.00    1.00    0.00    0.20    1.00     0  systemd-journal
10:08:46 AM     0      1043    0.60    0.00    0.00    0.00    0.60     0  rsyslogd
10:08:46 AM     0      6863  100.00    0.00    0.00    0.00  100.00     3  stress
10:08:46 AM     0      7303    0.20    0.20    0.00    0.00    0.40     2  pidstat
```

从这里我们可以看到是stress这个进程导致的。

### **场景二、I/O密集型进程**

**1、我们使用stress-ng命令，但这次模拟I/O压力，既不停执行sync:**

```

#--hdd表示读写临时文件
#-i 生成几个worker循环调用sync()产生io压力
$ stress-ng -i 4 --hdd 1 --timeout 600
```

**2、开启第二个终端运行uptime查看平均负载情况**

```
$ watch -d uptime 
 10:30:57 up 98 days, 19:39,  3 users,  load average: 1.71, 0.75, 0.69
```

**3、开启第三个终端运行mpstat查看CPU使用率**

```
3、开启第三个终端运行mpstat查看CPU使用率

$ mpstat -P ALL 5 20
10:32:09 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:32:14 AM  all    6.80    0.00   33.75   26.16    0.00    0.39    0.00    0.00    0.00   32.90
10:32:14 AM    0    4.03    0.00   69.57   19.91    0.00    0.00    0.00    0.00    0.00    6.49
10:32:14 AM    1   25.32    0.00    9.49    0.00    0.00    0.95    0.00    0.00    0.00   64.24
10:32:14 AM    2    0.24    0.00   10.87   63.04    0.00    0.48    0.00    0.00    0.00   25.36
10:32:14 AM    3    1.42    0.00   36.93   14.20    0.00    0.28    0.00    0.00    0.00   47.16
```

从这里可以看到，1分钟平均负载会慢慢增加到1.71，其中一个CPU的系统CPU使用率升到63.04。这说明，平均负载的升高是由于iowait升高。

那么我们到底是哪个进程导致的呢？我们使用pidstat来查看：

```
$ pidstat -u 5 1
Average:      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
Average:        0         1    0.00    0.19    0.00    0.00    0.19     -  systemd
Average:        0        10    0.00    0.19    0.00    1.56    0.19     -  rcu_sched
Average:        0       599    0.58    1.75    0.00    0.39    2.33     -  systemd-journal
Average:        0      1043    0.19    0.19    0.00    0.00    0.39     -  rsyslogd
Average:        0      6934    0.00    1.56    0.00    1.17    1.56     -  kworker/2:0-events_power_efficient
Average:        0      7383    0.00    0.39    0.00    0.78    0.39     -  kworker/1:0-events_power_efficient
Average:        0      9411    0.00    0.19    0.00    0.58    0.19     -  kworker/0:0-events
Average:        0      9662    0.00   97.67    0.00    0.19   97.67     -  kworker/u8:0+flush-253:0
Average:        0     10793    0.00    0.97    0.00    1.56    0.97     -  kworker/3:2-mm_percpu_wq
Average:        0     11062    0.00   21.79    0.00    0.19   21.79     -  stress-ng-hdd
Average:        0     11063    0.00    1.95    0.00    1.36    1.95     -  stress-ng-io
Average:        0     11064    0.00    2.72    0.00    0.39    2.72     -  stress-ng-io
Average:        0     11065    0.00    1.36    0.00    1.75    1.36     -  stress-ng-io
Average:        0     11066    0.00    2.72    0.00    0.58    2.72     -  stress-ng-io
```

可以发现是stress-ng导致的

### **场景三、大量进程的场景**

当系统中运行进程超出CPU运行能力时，就会出现等待CPU的进程。


比如：我们使用stress,但这次模拟8个进程：

```
$ stress -c 8 --timeout 600
```
我们的系统只有4颗CPU，这时候要运行8个进程，是明显不够的，系统的CPU后严重过载,这时候负载值达到了4点多：

```
$  uptime
 10:56:22 up 98 days, 20:05,  3 users,  load average: 4.52, 2.82, 2.67
 ```
 
 接着我们运行pidstat来查看一下进程的情况：

```
$ pidstat -u 5 1
Linux 5.0.5-1.el7.elrepo.x86_64 (k8s-m1)     07/11/2019     _x86_64_    (4 CPU)

10:57:33 AM   UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
10:57:38 AM     0         1    0.20    0.00    0.00    0.00    0.20     1  systemd
10:57:38 AM     0       599    0.00    0.99    0.00    0.20    0.99     2  systemd-journal
10:57:38 AM     0      1043    0.60    0.20    0.00    0.00    0.79     1  rsyslogd
10:57:38 AM     0     12927   51.59    0.00    0.00   48.21   51.59     0  stress
10:57:38 AM     0     12928   44.64    0.00    0.00   54.96   44.64     0  stress
10:57:38 AM     0     12929   45.44    0.00    0.00   54.56   45.44     2  stress
10:57:38 AM     0     12930   45.44    0.00    0.00   54.37   45.44     2  stress
10:57:38 AM     0     12931   51.59    0.00    0.00   48.21   51.59     3  stress
10:57:38 AM     0     12932   48.41    0.00    0.00   51.19   48.41     1  stress
10:57:38 AM     0     12933   45.24    0.00    0.00   54.37   45.24     3  stress
10:57:38 AM     0     12934   48.81    0.00    0.00   50.99   48.81     1  stress
10:57:38 AM     0     13083    0.00    0.40    0.00    0.20    0.40     0  pidstat
```

可以看出，8个进程抢占4颗CPU，每个进程等到CPU时间(%wait)高达50%，这些都超出CPU计算能力的进程，最终导致CPU过载。

