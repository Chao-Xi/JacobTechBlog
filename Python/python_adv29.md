# psutil

用`Python` 来编写脚本简化日常的运维工作是`Python`的一个重要用途。在`Linux`下，有许多系统命令可以让我们时刻监控系统运行的状态，**如`ps`，`top`，`free`等等。要获取这些系统信息，`Python`可以通过`subprocess`模块调用并获取结果。** 但这样做显得很麻烦，尤其是要写很多解析代

在`Python`中获取系统信息的另一个好办法是使用`psutil`这个第三方模块。顾名思义，`psutil = process and system utilities`，它不仅可以通过一两行代码实现系统监控，还可以跨平台使用，支持`Linux／UNIX／OSX／Windows`等，是系统管理员和运维小伙伴不可或缺的必备模块。

## 安装`psutil`

如果安装了`Anaconda`，`psutil`就已经可用了。否则，需要在命令行下通过`pip`安装：

```
$ pip install psutil
```
如果遇到`Permission denied`安装失败，请加上`sudo`重试。

## 获取`CPU`信息

我们先来获取`CPU`的信息：

```
import psutil
print(psutil.cpu_count())  # CPU逻辑数量
>>> 8

print(psutil.cpu_count(logical=False)) # CPU物理核心
>>> 4

# 4说明是4核超线程, 8则是8核非超线程
```

统计CPU的用户／系统／空闲时间：

```
print(psutil.cpu_times())

>>> scputimes(user=662130.5, nice=0.0, system=394890.72, idle=8865841.19)
```


再实现类似`top`命令的`CPU`使用率，每秒刷新一次，累计`10`次

```
for x in range(10):
	print(psutil.cpu_percent(interval=1, percpu=True))

[32.7, 2.0, 21.0, 1.0, 14.0, 2.0, 10.9, 0.0]
[38.4, 0.0, 33.7, 1.0, 27.0, 1.0, 23.0, 2.0]
[28.7, 2.0, 20.8, 2.0, 14.9, 2.0, 13.0, 1.0]
[32.7, 1.0, 18.0, 0.0, 12.1, 0.0, 8.9, 1.0]
[29.0, 1.0, 22.0, 2.0, 14.9, 2.0, 9.9, 1.0]
[32.0, 2.0, 17.0, 1.0, 15.0, 0.0, 8.1, 1.0]
[35.0, 2.0, 24.5, 3.0, 18.8, 2.9, 13.9, 2.0]
[33.7, 2.0, 21.2, 2.0, 18.2, 2.0, 12.0, 1.0]
[34.7, 2.0, 24.0, 1.0, 19.0, 2.0, 15.8, 2.0]
[27.0, 2.0, 14.9, 2.0, 12.9, 0.0, 10.0, 1.0]
```

## 获取内存信息

使用`psutil`获取**物理内存和交换内存信息**，分别使用：

```
print(psutil.virtual_memory())

>>> svmem(total=17179869184, available=4529786880, percent=73.6, used=10033971200, free=165109760, active=4370374656, inactive=4359385088, wired=5663596544)

sswap(total=3221225472, used=2224291840, free=996933632, percent=69.1, sin=363303735296, sout=7393566720)
>>> sswap(total=3221225472, used=2224291840, free=996933632, percent=69.1, sin=363303735296, sout=7393566720)
```

返回的是字节为单位的整数，可以看到，总内存大小是17179869184，已用9664053248，使用了`71.7%`。

而交换区大小是`1073741824` = `1 GB`。

## 获取磁盘信息

可以通过`psutil`获取磁盘分区、磁盘使用率和磁盘`IO`信息：

```
print(psutil.disk_partitions()) # 磁盘分区信息
>>> [sdiskpart(device='/dev/disk1s1', mountpoint='/', fstype='apfs', opts='rw,local,rootfs,dovolfs,journaled,multilabel'), sdiskpart(device='/dev/disk1s4', mountpoint='/private/var/vm', fstype='apfs', opts='rw,noexec,local,dovolfs,dontbrowse,journaled,multilabel,noatime')]

print(psutil.disk_usage('/'))  # 磁盘使用情况
>>> sdiskusage(total=499963170816, used=225492721664, free=269451145216, percent=45.6)

print(psutil.disk_io_counters()) # 磁盘IO
>>> sdiskio(read_count=59908282, write_count=33975316, read_bytes=1713947508736, write_bytes=1607001260032, read_time=25438266, write_time=19593425)
```

可以看到，磁盘'/'的总容量是`499963170816` = `465 GB`，使用了'45.6'。文件格式是'**apfs**'，`opts`中包含`rw`表示可读写，`journaled`表示支持日志。

## 获取网络信息

`psutil`可以获取网络接口和网络连接信息：

```
print(psutil.net_io_counters()) # 获取网络读写字节／包的个数
>>> snetio(bytes_sent=67106052096, bytes_recv=77179185152, packets_sent=57977512, 
packets_recv=60027094, errin=0, errout=0, dropin=0, dropout=0)


print(psutil.net_if_addrs())   # 获取网络接口信息
>>> {'lo0': [snicaddr(family=<AddressFamily.AF_INET: 2>, address='127.0.0.1', netmask='255.0.0.0', 
broadcast=None, ptp=None), snicaddr(family=<AddressFamily.AF_INET6: 30>, address='::1', 
netmask='ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', broadcast=None, ptp=None), 
snicaddr(family=<AddressFamily.AF_INET6: 30>, address='fe80::1%lo0', 
netmask='ffff:ffff:ffff:ffff::', broadcast=None, ptp=None)], 'en0': 
[snicaddr(family=<AddressFamily.AF_INET: 2>, address='192.168.199.214', 
netmask='255.255.255.0', broadcast='192.168.199.255', ptp=None), 
snicaddr(family=<AddressFamily.AF_LINK: 18>, address='8c:85:90:4d:b2:29', netmask=None, 
broadcast=None, ptp=None)], 'vboxnet0': [snicaddr(family=<AddressFamily.AF_INET: 2>, 
address='192.168.33.1', netmask=None, broadcast='192.168.33.255', ptp=None), 
snicaddr(family=<AddressFamily.AF_LINK: 18>, address='0a:00:27:00:00:00', netmask=None, 
broadcast=None, ptp=None)], 'en3': [snicaddr(family=<AddressFamily.AF_LINK: 18>, address='5a:
00:0c:f1:2b:01', netmask=None, broadcast=None, ptp=None)], 'en15': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='5a:00:0c:f1:2b:00', netmask=None, 
broadcast=None, ptp=None)], 'en4': [snicaddr(family=<AddressFamily.AF_LINK: 18>, address='5a:
00:0c:f1:2b:05', netmask=None, broadcast=None, ptp=None)], 'en16': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='5a:00:0c:f1:2b:04', netmask=None, 
broadcast=None, ptp=None)], 'bridge0': [snicaddr(family=<AddressFamily.AF_LINK: 18>, 
address='5a:00:0c:f1:2b:01', netmask=None, broadcast=None, ptp=None)], 'p2p0': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='0e:85:90:4d:b2:29', netmask=None, 
broadcast=None, ptp=None)], 'awdl0': [snicaddr(family=<AddressFamily.AF_LINK: 18>, 
address='72:22:1c:72:87:2f', netmask=None, broadcast=None, ptp=None), 
snicaddr(family=<AddressFamily.AF_INET6: 30>, address='fe80::7022:1cff:fe72:872f%awdl0', 
netmask='ffff:ffff:ffff:ffff::', broadcast=None, ptp=None)], 'vboxnet1': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='0a:00:27:00:00:01', netmask=None, 
broadcast=None, ptp=None)], 'vboxnet2': [snicaddr(family=<AddressFamily.AF_LINK: 18>, 
address='0a:00:27:00:00:02', netmask=None, broadcast=None, ptp=None)], 'vboxnet3': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='0a:00:27:00:00:03', netmask=None, 
broadcast=None, ptp=None)], 'vboxnet4': [snicaddr(family=<AddressFamily.AF_LINK: 18>, 
address='0a:00:27:00:00:04', netmask=None, broadcast=None, ptp=None)], 'vboxnet5': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='0a:00:27:00:00:05', netmask=None, broadcast=None, ptp=None)], 'vboxnet6': [snicaddr(family=<AddressFamily.AF_LINK: 18>, 
address='0a:00:27:00:00:06', netmask=None, broadcast=None, ptp=None)], 'vboxnet7': 
[snicaddr(family=<AddressFamily.AF_LINK: 18>, address='0a:00:27:00:00:07', netmask=None, 
broadcast=None, ptp=None)], 'en5': [snicaddr(family=<AddressFamily.AF_LINK: 18>, 
address='ac:de:48:00:11:22', netmask=None, broadcast=None, ptp=None), 
snicaddr(family=<AddressFamily.AF_INET6: 30>, address='fe80::aede:48ff:fe00:1122%en5', 
netmask='ffff:ffff:ffff:ffff::', broadcast=None, ptp=None)], 'utun0': 
[snicaddr(family=<AddressFamily.AF_INET6: 30>, address='fe80::c5e2:6d0e:25bc:fa54%utun0', 
netmask='ffff:ffff:ffff:ffff::', broadcast=None, ptp=None)]}


print(psutil.net_io_counters()) # 获取网络接口状态
>>> {'lo0': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=16384), 
'gif0': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1280), 
'stf0': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1280), 
'XHC1': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=0), 
'XHC0': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=0), 
'XHC20': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=0), 
'en0': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500), 
'en3': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1500), 'en15': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1500), 'en4': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1500), 'en16': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_FULL: 2>, speed=0, mtu=1500), 'bridge0': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500), 'p2p0': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=2304), 'awdl0': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1484), 'vboxnet0': 
snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500), 'vboxnet1': 
snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500), 
'vboxnet2': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, 
mtu=1500), 'vboxnet3': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, 
speed=0, mtu=1500), 'vboxnet4': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 
0>, speed=0, mtu=1500), 'vboxnet5': snicstats(isup=False, 
duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500), 'vboxnet6': 
snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, mtu=1500), 
'vboxnet7': snicstats(isup=False, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, 
mtu=1500), 'utun0': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, 
mtu=2000), 'en5': snicstats(isup=True, duplex=<NicDuplex.NIC_DUPLEX_UNKNOWN: 0>, speed=0, 
mtu=1500)}
```

要获取当前网络连接信息，使用`net_connections()`：

```
print(psutil.net_connections())

>>> Traceback (most recent call last):
  File "/usr/local/lib/python3.7/site-packages/psutil/_psosx.py", line 342, in wrapper
    return fun(self, *args, **kwargs)
  File "/usr/local/lib/python3.7/site-packages/psutil/_psosx.py", line 529, in connections
    rawlist = cext.proc_connections(self.pid, families, types)
PermissionError: [Errno 1] Operation not permitted

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/Users/jxi/python/adv1/33psutil.py", line 37, in <module>
    print(psutil.net_connections())
  File "/usr/local/lib/python3.7/site-packages/psutil/__init__.py", line 2126, in net_connections
    return _psplatform.net_connections(kind)
  File "/usr/local/lib/python3.7/site-packages/psutil/_psosx.py", line 255, in net_connections
    cons = Process(pid).connections(kind)
  File "/usr/local/lib/python3.7/site-packages/psutil/_psosx.py", line 347, in wrapper
    raise AccessDenied(self.pid, self._name)
psutil._exceptions.AccessDenied: psutil.AccessDenied (pid=17158)
```

你可能会得到一个`AccessDenied`错误，原因是`psutil`获取信息也是要走系统接口，而获取网络连接信息需要`root`权限，这种情况下，可以退出`Python`交互环境，用`sudo`重新启动：

```
$ sudo python3 33psutil.py

import psutil
print(psutil.net_connections())

>>> [sconn(fd=3, family=<AddressFamily.AF_INET: 2>, type=2, laddr=addr(ip='0.0.0.0', port=137), 
raddr=(), status='NONE', pid=16675), sconn(fd=4, family=<AddressFamily.AF_INET: 2>, type=2, 
...
family=<AddressFamily.AF_INET: 2>, type=2, laddr=addr(ip='0.0.0.0', port=137), raddr=(), 
status='NONE', pid=1)]
```

## 获取进程信息

通过`psutil`可以获取到所有进程的详细信息：

```
print(psutil.pids()) # 所有进程ID

>>> [16995, 16994, 16992, 16991, 16990, 16981, 16978, 16961, 16956, 16955, 16954, 16912, 16907,
...
114, 112, 111, 110, 105, 104, 103, 101, 100, 98, 95, 94, 93, 92, 90, 86, 85, 81, 80, 73, 71, 
68, 67, 64, 61, 59, 57, 56, 55, 51, 50, 1, 0]
```

```
import os

print(os.getpid())
# get python process id
>>> 17194

print(psutil.Process(17194)) 
>>> psutil.Process(pid=17180, name='Python', started='22:37:36')

p = psutil.Process(17186) # 获取指定进程ID=17194，其实就是当前Python交互环境
print(p.name())           # 进程名称
>>> Python

print(p.exe())   #进程exe路径
>>> /usr/local/Cellar/python/3.7.2/Frameworks/Python.framework/Versions/3.7/Resources/Python.app/Contents/MacOS/Python

print(p.cwd())   #进程工作目录
>>> /Users/jxi/python/adv1

print(p.cmdline())  # 进程启动的命令行
>>> ['/usr/local/Cellar/python/3.7.2/Frameworks/Python.framework/Versions/3.7/Resources/Python.app/Contents/MacOS/Python', '-i', '-u', '/Users/jxi/python/adv1/33psutil.py']

print(p.ppid())    # 父进程ID
>>> 11241

print(p.parent())   # 父进程 
>>> psutil.Process(pid=11241, name='plugin_host', started='2019-01-28 10:04:34')

print(p.children()) # 子进程列表
>>> [] 

print(p.status())   # 进程状态 
>>> running

print(p.username()) # 进程用户名
>>> jxi

print(p.create_time()) # 进程创建时间
>>> 1548772893.928754

print(p.terminal()) # 进程终端
>>> None

print(p.cpu_times()) # 进程使用的CPU时间
>>> pcputimes(user=0.057264432, system=0.031873772, children_user=0.0, children_system=0.0)

print(p.memory_info()) # 进程使用的内存
>>> pmem(rss=9641984, vms=4368527360, pfaults=5402, pageins=0)

print(p.open_files()) # 进程打开的文件
>>> []

print(p.connections()) # 进程相关网络连接
>>> []

print(p.num_threads()) # 进程的线程数量
>>> 1

print(p.threads()) #所有线程信息
>>> [pthread(id=1, user_time=0.050133, system_time=0.019791)]

print(p.environ()) # 进程环境变量
>>> {'__CF_USER_TEXT_ENCODING': '0x61DDB346:0x0:0x0', 'Apple_PubSub_Socket_Render': '/private/tmp/com.apple.launchd.YnKXVljOor/Render', 'PATH': '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin', 
'TMPDIR': '/var/folders/c7/fv6jn35n16j21nv15hmb5hrjhxvct6/T/', 'XPC_FLAGS': '0x0', 
'COMMAND_MODE': 'unix2003', 'SHELL': '/bin/bash', 'SSH_AUTH_SOCK': '/private/tmp/
com.apple.launchd.zOT4XrOxzU/Listeners', 'LOGNAME': 'jxi', 'XPC_SERVICE_NAME': '0', 
'SECURITYSESSIONID': '18a6a', 'AWS_SECRET_ACCESS_KEY': 
'7w2kZhpWVbiU7lWaeqVJauMS9JjLfBaRAwaqpZyb', 'USER': 'jxi', 'AWS_ACCESS_KEY_ID': 
'AKIAJTHZRPTDI7PMX4UQ', 'HOME': '/Users/jxi', '__PYVENV_LAUNCHER__': '/usr/local/bin/python3'}

print(p.terminate()) # 结束进程
>>> None
```

和获取网络连接类似，获取一个`root`用户的进程需要`root`权限，启动`Python`交互环境或者`.py`文件时，需要`sudo`权限。

`psutil`还提供了一个`test()`函数，可以模拟出`ps`命令的效果：

```
import psutil
psutil.test()

SER         PID %MEM     VSZ     RSS TTY           START    TIME  COMMAND
root           0    ?       ?       ? ?             Dec31   00:00  kernel_task
root           1    ?       ?       ? ?             Dec31   00:00  launchd
root          50    ?       ?       ? ?             Dec31   00:00  syslogd
root          51    ?       ?       ? ?             Dec31   00:00  UserEventAgent
root          55    ?       ?       ? ?             Dec31   00:00  uninstalld
root          56    ?       ?       ? ?             Dec31   00:00  kextd
root          57    ?       ?       ? ?             Dec31   00:00  fseventsd
root          59    ?       ?       ? ?             Dec31   00:00  vpnagentd
root          61    ?       ?       ? ?             Dec31   00:00  mediaremoted
_appleeven    64    ?       ?       ? ?             Dec31   00:00  appleeventsd
root          67    ?       ?       ? ?             Dec31   00:00  configd
root          68    ?       ?       ? ?             Dec31   00:00  powerd
root          71    ?       ?       ? ?             Dec31   00:00  logd
...
```
