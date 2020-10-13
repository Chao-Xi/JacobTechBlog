1. REST API response codes: 400 vs 500 vs 200
2. Python **list vs tuple**
3. [CDN_Cloudfront](https://github.com/Chao-Xi/JacobTechBlog/blob/master/saa_test/5S3/4CDN_Cloudfront.md)
4. Linux code network troubleshooting
5. Linux CPU and Memory troubleshooting


## 1、REST API response codes: 400 vs 500 vs 200

**A 4xx code indicates an error caused by the user**, whereas **5xx codes tell the client that they did everything correctly and it’s the server itself who caused the problem.** 

* 401 (unauthorized), 403 (forbidden), 404 (not found), and so on all mean the client has to fix the problem on their side before trying again.
* On the contrary, 501 (not implemented), 502 (bad gateway), etc mean the request can be resent as is at a later time, when the server overcomes its current problems.

### Summary

* 4xx codes indicate errors caused by the user. They are basically validation errors.
* 5xx codes indicate errors caused by the server itself. They are unexpected situations (bugs and hardware failures).


## 2、Python **list vs tuple**

*  Tuples difference between list [immutable, assignment unsupported]
*  Sets: order of set always change

## 3、CDN_Cloudfront

1. Multiple users suited in multiple countries
2. Users make request to get content and these request will be routed firstly to the local edge locations
3. **Edge locations will check objects whether or not cached in this edge location**
4. If not, edge location pulls down object from S3 and cache in it and live with the special time to live (TTL)
5. First batch respond may be not that quick.

* Web Distribution - Typically used for Websites
* RTMP - Used for Media Streaming

## 4、How to troubleshoot Linux server memory issues

### 4-1 Process stopped unexpectedly

If a task gets killed to save memory, it gets logged into various log files stored at `/var/log/`

```
sudo grep -i -r 'out of memory' /var/log/
```

### 4-2 Current resource usage

```
free -h
```

```
top
```

### 4-3 Check if your process is at risk

Linux keeps a score for each running process, which represents the likelihood at which the process would be killed in OOM situation.

This score is stored on file in `/proc/<pid>/oom_score`, where pid is the identification number for the process you are looking into. The pid can be easily found using the following command.

 
```
ps aux | grep <process name>
```

```
cat /proc/5872/oom_score
```

## 6. Understand Linux Load Averages and Monitor Performance of Linux

### What is Load Averages

* **System load/CPU Load** – is a measurement of CPU over or under-utilization in a Linux system; the number of processes which are being executed by the CPU or in waiting state.
* **Load average** – is the **average system load calculated over a given period of time of 1, 5 and 15 minutes**.


In Linux, the **load-average is technically believed to be a running average of processes** in it’s (kernel) **execution queue tagged as running or uninterruptible**.

### How to Monitor Linux System Load Average

```
$ uptime

07:13:53 up 8 days, 19 min,  1 user,  load average: 1.98, 2.15, 2.21
```

```
The numbers are read from left to right, and the output above means that:

load average over the last 1 minute is 1.98
load average over the last 5 minutes is 2.15
load average over the last 15 minutes is 2.21
```

High load averages imply that a system is overloaded; many processes are waiting for CPU time.

## 7. What is inode and where is that saved 

An inode is a data structure. **It defines a file or a directory on the file system and is stored in the directory entry**


Inodes point to blocks that make up a file. 

The inode contains all the administrative data needed to read a file. Every file’s metadata is stored in inodes in a table structure.

**The operating system kernel's in-memory representation of this data is called struct inode in Linux**

## 8. Tcp handshake

**The TCP protocol, on which HTTP is based, requires performing a three-way handshake to initiate the connection.** It means that before the server can send you data (e.g. images), three full roundtrips between the client and the server need to be made.

Assuming that you are requesting `/image.jpg` **_from Warsaw,_** and ***connecting to the nearest server in Berlin***:

```
Open connection

TCP Handshake:
Warsaw  ->------------------ synchronise packet (SYN) ----------------->- Berlin
Warsaw  -<--------- synchronise-acknowledgement packet (SYN-ACK) ------<- Berlin
Warsaw  ->------------------- acknowledgement (ACK) ------------------->- Berlin

Data transfer:
Warsaw  ->---------------------- /image.jpg --------------------------->- Berlin
Warsaw  -<--------------------- (image data) --------------------------<- Berlin

Close connection
```

**SYN is a TCP packet sent to another computer requesting that a connection be established between them. If the SYN is received by the second machine, an SYN/ACK is sent back to the address requested by the SYN.**

## 10 SNI

https://www.cloudflare.com/learning/ssl/what-is-sni/

When multiple websites are hosted on one server and share a single IP address, and each website has its own SSL certificate, the server may not know which SSL certificate to show when a client device tries to securely connect to one of the websites. 

**This is because the SSL/TLS handshake occurs before the client device indicates over HTTP which website it's connecting to.**


Server Name Indication (SNI) is designed to solve this problem. 

**SNI is an extension for the TLS protocol (formerly known as the SSL protocol)**, which is used in HTTPS. 

**It's included in the TLS/SSL handshake process in order to ensure that client devices are able to see the correct SSL certificate for the website they are trying to reach**. 

**The extension makes it possible to specify the hostname, or domain name, of the website during the TLS handshake, instead of when the HTTP connection opens after the handshake.**


## 11. Scheduler

* Predicates

	* PodFitsResources：节点上剩余的资源是否大于 Pod 请求的资源
	* PodFitsHost：如果 Pod 指定了 NodeName，检查节点名称是否和 NodeName 匹配
	* PodFitsHostPorts：节点上已经使用的 port 是否和 Pod 申请的 port 冲突
	* PodSelectorMatches：过滤掉和 Pod 指定的 label 不匹配的节点
	* NoDiskConflict：已经 mount 的 volume 和 Pod 指定的 volume 不冲突，除非它们都是只读的
	* CheckNodeDiskPressure：检查节点磁盘空间是否符合要求
	* CheckNodeMemoryPressure：检查节点内存是否够用

* Priorities 优先级是由一系列键值对组成的，键是该优先级的名称，值是它的权重值
	* LeastRequestedPriority：通过计算 CPU 和内存的使用率来决定权重，使用率越低权重越高，当然正常肯定也是资源是使用率越低权重越高，能给别的 Pod 运行的可能性就越大
	* SelectorSpreadPriority：为了更好的高可用，对同属于一个 Deployment 或者 RC 下面的多个 Pod 副本，尽量调度到多个不同的节点上，当一个 Pod 被调度的时候，会先去查找该 Pod 对应的 controller，然后查看该 controller 下面的已存在的 Pod，运行 Pod 越少的节点权重越高
	* ImageLocalityPriority：就是如果在某个节点上已经有要使用的镜像节点了，镜像总大小值越大，权重就越高
	* NodeAffinityPriority：这个就是根据节点的亲和性来计算一个权重值，后面我们会详细讲解亲和性的使用方法


## 11. Monitor on what


## 12. Get all object attributes in Python? 

```
Use the built-in function dir().
```

## 13. Test your code when coding

## 14.  3Sum

Given an array nums of n integers, are there elements a, b, c in nums such that a + b + c = 0? Find all unique triplets in the array which gives the sum of zero.

**Notice that the solution set must not contain duplicate triplets.**

```
def three_sum(s):
    s = sorted(s) # O(nlogn)
    output = set()
    for k in range(len(s)):
        target = -s[k]
        i,j = k+1, len(s)-1
        while i < j:
            sum_two = s[i] + s[j]
            if sum_two < target:
                i += 1
            elif sum_two > target:
                j -= 1
            else:
                output.add((s[k],s[i],s[j]))
                i += 1
                j -= 1
    return output
```

