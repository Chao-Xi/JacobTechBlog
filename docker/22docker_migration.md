# **Docker容器迁移到其他服务器的5种方法**

迁移在许多情况下都是不可避免的。硬件升级、数据中心变化、过时的操作系统，所有这些都可能成为迁移的触发点。


Docker容器迁移通常是迁移任务的一部分。今天我们将看到将Docker容器从现有服务器迁移到另一台服务器的不同方法。


**如何将Docker容器迁移到另一台服务器**，没有直接将Docker容器从一台服务器迁移到另一台服务器的方法，我们通过使用下面这些方法中的一个或多个来解决Docker容器迁移的问题。


## **1、导出和导入容器**

导出容器意味着从容器的文件系统创建压缩文件，**导出的文件保存为“gzip”文件**。

```
docker export container-name | gzip > container-name.gz
```

**然后通过文件传输工具（如scp或rsync）将压缩文件复制到新服务器**。在新服务器中，这个gzip文件随后被导入到一个新容器中。

```
zcat container-name.gz | docker import - container-name
```

可以使用“docker run”命令访问在新服务器中创建的新容器。


导出容器工具的一个缺点是，它不导出容器的端口和变量，也不导出包含容器的底层数据。

当尝试在另一台服务器中加载容器时，这可能会导致错误。在这种情况下，我们选择Docker镜像迁移来将容器从一台服务器迁移到另一台服务器。


## **2、容器镜像迁移**

将Docker容器迁移到另一台服务器的最常用方法是迁移容器关联到的镜像。

对于必须迁移的容器，首先使用“Docker commit”命令将其Docker镜像保存到压缩文件中。

```
docker commit container-id image-name
```

生成的镜像将被压缩并上传到新服务器上，在新服务器中，将使用“docker run”创建一个新容器。

使用此方法，数据卷不会被迁移，但它会保留在容器内创建的应用程序的数据。

## **3、保存和加载镜像**

docker镜像是应用程序的代码、库、配置文件等的包。Docker容器是由这些镜像创建的。

可以使用“docker save”压缩镜像并将其迁移到新服务器。

```
docker save image-name > image-name.tar
```

**在新服务器中，使用“docker load”将压缩镜像文件用于创建新镜像。**

```
cat image-name.tar | docker load
```

## **4、迁移数据卷**

Docker容器中的数据卷是共享目录，其中包含特定于容器的数据。卷中的数据是持久的，在容器重新创建期间不会丢失。

使用导出或提交工具将Docker容器或镜像从一台服务器迁移到另一台服务器时，不会迁移基础数据卷。


在这种情况下，包含数据的目录将手动迁移到新服务器。然后在新服务器创建容器，引用该目录作为其数据卷。

另一个简单的方法是通过在“docker run”命令中传递“-volumes from”参数来备份和恢复数据卷。

```
docker run --rm --volumes-from datavolume-name -v $(pwd):/backup image-name tar cvf backup.tar /path-to-datavolume
```

这里，`datavolume`名称是`/path/to/volume`。

此命令提供数据卷的备份。要指定工作目录，还可以指定`-w/backup`。在/`backup`文件夹中生成的备份可以通过scp或ftp工具复制到新服务器。然后提取复制的备份并将其还原到新容器中的数据卷中。

```
docker run --rm --volumes-from datavolume-name -v $(pwd):/backup image-name bash -c "cd /path-to-datavolume && tar xvf /backup/backup.tar --strip 1"
```

## **5、迁移整个Docker容器**

我们在这里看到的方法适用于单个容器。但是将所有容器都要从一台服务器迁移到另一台服务器的情况下，我们采用另一种方法。


此方法包括将整个docker目录（`“/var/lib/docker”`）复制到新服务器。为了使这种方法成功，需要确定几个关键点。


* 保留文件夹的权限和所有权。
* 迁移前停止Docker服务。
* 验证两台服务器中的Docker版本是否兼容。
* 迁移前后验证容器列表和功能。
* 环境变量和其他配置文件的路径。

如果此方法由于任何故障而无法工作，我们将配置自定义脚本以将容器和镜像从一台服务器迁移到另一台服务器。




