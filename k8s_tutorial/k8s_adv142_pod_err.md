# K8s Pod 故障排查：崩溃日志分析背后的实现原理(--previous)

当pod处于crash状态的时候，容器不断重启，此时用 kubelet logs 可能出现一直捕捉不到日志。解决方法

kubectl previous 参数作用：`If true, print the logs for the previous instance of the container in a pod if it exists`.

单容器pod：

```
kubectl logs pod-name --previous
```

多容器pod：

```
kubectl logs pod-name --previous -c container-name
```

比如：

```
NAME                              READY       STATUS             RESTARTS   AGE
nginx-7d8b49557c-c2lx9            2/2        Running            5   

kubectl logs nginx-7d8b49557c-c2lx9 --previous
Error: xxxxxxxxxxx
```

kubelet会保持pod的前几个失败的容器，这个是查看的前提条件。

kubelet实现previous的原理：


**将pod的日志存放在 `/var/log/pods/podname`，并且是链接文件，链接到docker的容器的日志文件，同时kubelet还会保留上一个容器，同时有一个链接文件链接到pod上一个崩溃的容器的日志文件**，使用`previous`就是查看的这个文件

比如查看一个pod：

```
ubuntu@~$ kubelet get pod
NAME                     READY   STATUS    RESTARTS   AGE
busybox                  1/1     Running   2394       99d
nginx-deployment-6wlhd   1/1     Running   0          79d
redis                    1/1     Running   0          49d
```

到pod所在node查看kubelet放的两个日志文件：

```
 ls /var/log/pods/default_busybox_f72ab71a-5b3b-4ecf-940d-28a5c3b30683/busybox
2393.log  2394.log
```

数字的含义：2393 证明是第 2393 次重启后的日志，2394 代表是第2394次重启后的日志。

实际这两个日志文件是链接文件，指向了docker的日志文件：

```
/busybox# stat 2393.log
  File: 2393.log -> /data/kubernetes/docker/containers/68a5b32c9fdb1ad011b32e6252f9cdb759f69d7850e6b7b8591cb4c2bf00bcca/68a5b32c9fdb1ad011b32e6252f9cdb759f69d7850e6b7b8591cb4c2bf00bcca-json.log
  Size: 173           Blocks: 8          IO Block: 4096   symbolic link
Device: fc02h/64514d    Inode: 529958      Links: 1
Access: (0777/lrwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-01-31 13:32:03.751514283 +0800
Modify: 2023-01-31 13:32:03.039526838 +0800
Change: 2023-01-31 13:32:03.039526838 +0800
 Birth: -

 /busybox# stat 2394.log
  File: 2394.log -> /data/kubernetes/docker/containers/2ed9ebf0585215602874b076783e12191dbb010116038b8eb4646273ebfe195c/2ed9ebf0585215602874b076783e12191dbb010116038b8eb4646273ebfe195c-json.log
  Size: 173           Blocks: 8          IO Block: 4096   symbolic link
Device: fc02h/64514d    Inode: 529955      Links: 1
Access: (0777/lrwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-01-31 14:32:03.991106950 +0800
Modify: 2023-01-31 14:32:03.183119308 +0800
Change: 2023-01-31 14:32:03.183119308 +0800
 Birth: -
```
 
看到分别指向了这两个容器的日志文件，**一个是当前pod里在跑的容器，一个是pod上次跑的容器，现在已经退出**了

```
docker ps -a
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS                      PORTS               NAMES
2ed9ebf05852        ff4a8eb070e1           "sleep 3600"             24 minutes ago      Up 24 minutes                                   k8s_busybox_busybox_default_f72ab71a-5b3b-4ecf-940d-28a5c3b30683_2394
68a5b32c9fdb        ff4a8eb070e1           "sleep 3600"             About an hour ago   Exited (0) 24 minutes ago                       k8s_busybox_busybox_default_f72ab71a-5b3b-4ecf-940d-28a5c3b30683_2393
```

使用logs的时候读的是当前容器那个文件，使用 `–previous` 的时候，读的是上次退出的容器的日志文件，由于kubelet为pod保留了上次退出的容器。

我们手动编辑这两个文件的内容，看kubelet是否读的是这两个文件

```
/busybox# cat 2393.log
{"log":"last crash logs\n","stream":"stderr","time":"2022-11-05T08:11:27.31523845Z"}

/busybox# cat 2394.log
{"log":"now pod log\n","stream":"stderr","time":"2022-11-05T08:11:27.31523845Z"}

ubuntu@10-234-32-51:~$ k logs busybox --previous
last crash logs
ubuntu@10-234-32-51:~$ k logs busybox
now pod log
```

由于是链接文件，那么可能实际是从别的地方读的，或者说直接读容器目录下的，由于链接文件我们改了后容器目录下的日志文件也跟着改了，我们直接创建两个文件来做验证：

```
ubuntu@10-234-32-51:~$ k get pod
NAME                     READY   STATUS    RESTARTS   AGE
busybox                  1/1     Running   2395       99d
nginx-deployment-6wlhd   1/1     Running   0          79d
redis                    1/1     Running   0          49d

/busybox# ls
2394.log  2395.log

/busybox# rm 2394.log  2395.log

我们删除，然后自己创建，这时是regular file，而不是链接文件了：
/busybox# ls
2394.log  2395.log

/busybox# stat 2394.log
  File: 2394.log
  Size: 100           Blocks: 8          IO Block: 4096   regular file
Device: fc02h/64514d    Inode: 529965      Links: 1
Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-01-31 15:42:11.307170422 +0800
Modify: 2023-01-31 15:42:07.711225229 +0800
Change: 2023-01-31 15:42:07.711225229 +0800
 Birth: -

/busybox# stat 2395.log
  File: 2395.log
  Size: 86            Blocks: 8          IO Block: 4096   regular file
Device: fc02h/64514d    Inode: 529967      Links: 1
Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-01-31 15:41:17.539989934 +0800
Modify: 2023-01-31 15:41:14.348038586 +0800
Change: 2023-01-31 15:41:14.352038525 +0800
 Birth: -

/busybox# cat 2394.log
{"log":"previous logs create by myself\n","stream":"stderr","time":"2022-11-05T08:11:27.31523845Z"}
/busybox# cat 2395.log
{"log":"create by myself\n","stream":"stderr","time":"2022-11-05T08:11:27.31523845Z"}

ubuntu@10-234-32-51:~$ k logs busybox
create by myself
ubuntu@10-234-32-51:~$ k logs busybox --previous
previous logs create by myself
```

得出结论：kubelet读的是 `/var/log/pods/` 下的日志文件，`–previous` 读的也是 `/var/log/pods/ `下的日志文件，且专门有个链接文件来指向上一个退出容器的日志文件，以此来获取容器崩溃前的日志。

