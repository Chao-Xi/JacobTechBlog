![Alt Image Text](images/headline2.jpg "headline")
# Docker三大概念及安装

## 一、Docker的三大核心概念

* 镜像（Image）
* 容器（Container）
* 仓库（Repository）

### 1、Docker镜像
Docker镜像类似于虚拟机镜像，镜像是创建Docker容器的基础；通过版本管理和增量的文件系统，Docker提供了一套十分简单的机制来创建和更新现有的镜像，用户甚至可以从网上下载一个已经做好的应用镜像使用。

### 2、Docker容器
Docker容器类似一个轻量级的沙箱，容器从镜像创建的应用来运行和隔离。可以将其启动、开始、停止、删除，容器都是彼此相互隔离的、互不可见的。

### 3、Docker仓库
Docker仓库可以分为公开仓库（Public）和私有仓库（Private）两种形式；类是与代码仓库，是Docker集中存放镜像文件的场所。目前，最大的公开仓库是官方提供的Docker Hub，其中存放了数量庞大的镜像供用户下载。

## 二、安装Docker

        Docker在主流的操作系统和云平台上都可以使用，包括Linux操作系统（如Ubuntu、Debian、CentOS、Redhat等），MasOS和Windows操作系统，以及AWS等云平台。
        用户可以访问Docker官网的Get Docker（https://docs.docker.com/install/linux/docker-ce/ubuntu/）页面，查看获取Docker的方式，以及Docker支持的平台类型。
        
## 三、Ubuntu Xenial 16.04环境中安装Docker

## Uninstall old versions
```
$ sudo apt-get remove docker docker-engine docker.io
```

## Install Docker CE
Before you install Docker CE for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

### SET UP THE REPOSITORY

1. Update the `apt` package index:

```
$ sudo apt-get update
```

2. Install packages to allow `apt` to use a repository over HTTPS:

```
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```

3. Add Docker’s official GPG key:

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
Verify that you now have the key with the fingerprint `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`, by searching for the last 8 characters of the fingerprint.

```
$ sudo apt-key fingerprint 0EBFCD88

pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22
```

4. Use the following command to set up the `stable` repository. You always need the `stable` repository, even if you want to install builds from the edge or test repositories as well. To add the `edge` or `test` repository, add the word edge or test (or both) after the word stable in the commands below.

```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

### INSTALL DOCKER CE

1. Update the apt package index.

```
sudo apt-get update
```

2. Install the `latest version` of Docker CE, or go to the next step to install a specific version:

```
$ sudo apt-get install docker-ce
```

3. To install a `specific version` of Docker CE, list the available versions in the repo, then select and install:

a. List the versions available in your repo:

```
$ apt-cache madison docker-ce
docker-ce | 18.06.0~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 18.03.1~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 18.03.0~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.12.1~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.12.0~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.09.1~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.09.0~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.06.2~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.06.1~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.06.0~ce-0~ubuntu | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.03.2~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
 docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages

```

b. Install a specific version by its fully qualified package name, which is package name `(docker-ce) “=”` version string (2nd column), for example, `docker-ce=18.03.0~ce-0~ubuntu`.

```
$ sudo apt-get install docker-ce=<VERSION>
```

4. Verify that Docker CE is installed correctly by running the hello-world image.

```
$ sudo docker run hello-world
```
```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
```

## Post-installation steps for Linux

## Manage Docker as a non-root user

To create the `docker` group and add your user:

1. Create the docker group.

```
$ sudo groupadd docker
```

2. Add your user to the docker group.

```
$ sudo usermod -aG docker $USER
```

3.Log out and log back in so that your group membership is re-evaluated.

If testing on a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.

4. Verify that you can run `docker` commands without `sudo`.

```
$ docker run hello-world
```

This command downloads a test image and runs it in a container. When the container runs, it prints an informational message and exits.

If you initially ran Docker CLI commands using `sudo` before adding your user to the `docker` group, you may see the following error, which indicates that your `~/.docker/` directory was created with incorrect permissions due to the `sudo` commands.

```
ocker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.38/containers/create: dial unix /var/run/docker.sock: connect: permission denied.
See 'docker run --help'.
```
To fix this problem, either remove the `~/.docker/` directory (it is recreated automatically, but any custom settings are lost), or change its ownership and permissions using the following commands:

```
$ sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
$ sudo chmod g+rwx "/home/$USER/.docker" -R
```

## Reference

### Install 

[https://docs.docker.com/install/linux/docker-ce/ubuntu/](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

### Post-installation

[https://docs.docker.com/install/linux/linux-postinstall/](https://docs.docker.com/install/linux/linux-postinstall/)