![Alt Image Text](TechBlog/Python/images/headline.jpg "Headline image")
# Python 虚拟环境学习
对于每个python项目依赖的库版本都有可能不一样，如果将依赖包都安装到公共环境的话显然是没法进行区分的，甚至是不同的项目使用的python版本都不尽相同，有的用python2.7，有的用python3.6，所以对于python项目的环境进行隔离管理就成为一个必然的需求了。

## 需求

* 可以区分不同的项目间依赖包的脚本
* 可以区分不同的项目间的python版本
* 可以自由在不同的版本间切换

## 解决方案
* 解决依赖包的问题： `virtualenv`
* 解决python的版本问题： `pyenv`
* 最终解决方案： `docker`

## virtualenv
运行`pip install virtualenv`既可以安装`virtualenv`,当然了还可以用`easy_install`安装，即使是没有安装任何Python包管理器(比如pip)，也可以直接获取[virtualenv.py](https://raw.githubusercontent.com/pypa/virtualenv/master/virtualenv.py)并运行`python virtualenv.py`，效果也是一样的，当然我还是强烈推荐你安装包管理工具：pip，他一定能为你带来很多便利的(新版本的virtualenv也包含了pip管理工具)。

```
$ sudo pip install virtualenv  
Downloading/unpacking virtualenv
  Downloading virtualenv-16.0.0-py2.py3-none-any.whl (1.9MB): 1.9MB downloaded
Installing collected packages: virtualenv
Successfully installed virtualenv
Cleaning up... 
```
安装完成后，就可以直接创建一个虚拟环境了(`virtualenv 环境名称`):

```
$ virtualenv virenvtest
New python executable in /home/vagrant/virtualenv/virenvtest/bin/python
Installing setuptools, pip, wheel...done.
```

创建完成后，用下面的命令即可激活当前虚拟环境：

```
~/virtualenv$ source virenvtest/bin/activate
(virenvtest)
```
现在就可以随意的安装你的依赖包了，现在安装的包只会对当前环境`virenvtest`有效，比如安装`ansible`

```
(virenvtest) $ sudo pip install --upgrade pip setuptools
(virenvtest) $ sudo pip install ansible
```

```
(virenvtest) $ pip list
Package    Version
---------- -------
pip        18.0
setuptools 40.0.0
wheel      0.31.1
```

要退出当前虚拟环境也是非常简单的，如下：

`$ deactivate`

virtualenv还有很多高级的用法，可以前往该[文档查看](https://virtualenv-chinese-docs.readthedocs.io/en/latest/)。

## virtualenvwrapper

`virtualenvwrapper`是`virtualenv`的一个扩展包，可以让你更加方便的使用`virtualenv`，优点:

* 将所有虚拟环境整合在一个目录下
* 管理（新增，删除，复制）虚拟环境
* 方便切换虚拟环境

安装也很方便，我们[使用pip3安装virtualenvwrapper](https://medium.com/@gitudaniel/installing-virtualenvwrapper-for-python3-ad3dfea7c717)：

```
$ sudo apt-get install python3-pip
$ sudo pip3 install virtualenvwrapper
```

安装完成以后还需要小小的配置一下才可以使用，首先我们找到`virtualenvwrapper.sh`的文件，通常会是：`/usr/local/bin/virtualenvwrapper.sh`：

```
$ sudo find / -name virtualenvwrapper.sh
/usr/local/bin/virtualenvwrapper.sh
```

然后我们可以在.bashrc(取决于你用的终端，我用的bash)添加一行命令：

`source /usr/local/bin/virtualenvwrapper.sh`

然后让我们的配置生效：

$ source ~/.bashrc

可能会遇到的问题

```
/usr/bin/python: No module named virtualenvwrapper
virtualenvwrapper.sh: There was a problem running the initialization hooks.

If Python could not import the module virtualenvwrapper.hook_loader,
check that virtualenvwrapper has been installed for
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python and that PATH is
set properly.
```

解决方案

`export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3`

```
$ source ~/.bashrc
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/initialize
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/premkvirtualenv
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/postmkvirtualenv
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/prermvirtualenv
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/postrmvirtualenv
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/predeactivate
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/postdeactivate
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/preactivate
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/postactivate
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/get_env_details
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/premkproject
virtualenvwrapper.user_scripts creating /home/vagrant/.virtualenvs/postmkproject
```

现在我们就可以使用`virtualenvwrapper`的基本命令了：

* 创建基本环境：mkvirtualenv [环境名]
* 删除环境：rmvirtualenv [环境名]
* 激活环境：workon [环境名]
* 退出环境：deactivate
* 列出所有环境：workon或者lsvirtualenv -b

参考文档：[https://virtualenvwrapper.readthedocs.io/en/latest/](https://virtualenvwrapper.readthedocs.io/en/latest/)

## pyenv

`pyenv`是`Python`版本管理工具，可以改变全局的`Python`版本，安装多个版本的`Python`，设置目录级别的Python版本，还能创建和管理虚拟环境。所有的设置都是用户级别的操作，不需要sudo命令。 **`pyenv`通过系统修改环境变量来实现`Python`不同版本的切换。**而`virtualenv` 通过将Python包安装到一个目录来作为`Python` 包虚拟环境，通过切换目录来实现不同包环境间的切换。

安装方式

```
sudo apt update
curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash

WARNING: seems you still have not added 'pyenv' to the load path.

# Load pyenv automatically by adding
# the following to ~/.bash_profile:

export PATH="/home/vagrant/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

安装完成以后，可以添加几条命令到`.bashrc`中开启自动补全功能：

```
export PATH=$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```
然后同样激活上面的配置：

`source ~/.bashrc`

现在我们就可以使用pyenv了：

* 查看本机安装`Python`版本：

```
$ pyenv versions
* system (set by /home/vagrant/.pyenv/version)
```

现在我们就可以使用pyenv下还没有安装任何版本的python

星号表示当前正在使用的Python版本

* 查看所有可安装的`Python`版本：

`pyenv install -l`

* 安装与卸载：

安装时可能会报错，所以请提前pyenv的[官方安装文档](https://github.com/pyenv/pyenv/wiki/Common-build-problems)

Pre-requirement you may need:

```
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev

```

安装与卸载：

```
$ pyenv install -v 2.7.15   # 安装python
$ pyenv uninstall 2.7.15 # 卸载python
```
安装完成后：

```
pyenv versions
* system (set by /home/vagrant/.pyenv/version)
  2.7.15
  3.6.4
```
* 版本切换：

```
$ pyenv global 2.7.15
$ pyenv local 3.6.4
```
为整个系统设置python的版本，`pyenv global 2.7.15`

```
$ pyenv global 2.7.15
$ pyenv versions
  system
* 2.7.15 (set by /home/vagrant/.pyenv/version)
  3.6.4
```

在某个特定的目录下，使用`pyenv local 3.6.4`

```
cd ~/virtualenv
~/virtualenv$ pyenv versions
~/virtualenv$ pyenv local 3.6.4
  system
  2.7.15
* 3.6.4 (set by /home/vagrant/virtualenv/.python-version)
```

`global`用于设置全局的`Python`版本，通过将版本号写入`~/.pyenv/version`文件的方式。`local`用于设置本地版本，通过将版本号写入当前目录下的`.python-version`文件的方式。通过这种方式设置的`Python`版本优先级比`global`高。

`python`优先级：**`shell > local > global pyenv`**会从当前目录开始向上逐级查找`.python-version`文件，直到根目录为止。若找不到，就用`global`版本。

```
$ pyenv shell 2.7.3 # 设置面向 shell 的 Python 版本，通过设置当前 shell 的 PYENV_VERSION 环境变量的方式。这个版本的优先级比 local 和 global 都要高。
$ pyenv shell --unset  # –unset 参数用于取消当前 shell 设定的版本。
```

## pyenv-virtualenv

自动安装`pyenv`后，它会自动安装部分插件，通过`pyenv-virtualenv`插件可以很好的和`virtualenv`进行结合：

```
ls -la ~/.pyenv/plugins
total 36
drwxrwxr-x  8 vagrant vagrant 4096 Jul 24 02:59 .
drwxrwxr-x 13 vagrant vagrant 4096 Jul 24 04:10 ..
-rw-rw-r--  1 vagrant vagrant   52 Jul 24 02:59 .gitignore
drwxrwxr-x  4 vagrant vagrant 4096 Jul 24 02:59 pyenv-doctor
drwxrwxr-x  5 vagrant vagrant 4096 Jul 24 02:59 pyenv-installer
drwxrwxr-x  5 vagrant vagrant 4096 Jul 24 02:59 pyenv-update
drwxrwxr-x  7 vagrant vagrant 4096 Jul 24 02:59 pyenv-virtualenv
drwxrwxr-x  4 vagrant vagrant 4096 Jul 24 02:59 pyenv-which-ext
drwxrwxr-x  5 vagrant vagrant 4096 Jul 24 02:59 python-build
```

基本使用命令：

* 列出当前虚拟环境：`pyenv virtualenvs`
* 激活虚拟环境：`pyenv activate 环境名称`
* 退出虚拟环境：`pyenv deactivate`
* 删除虚拟环境：`pyenv uninstall 环境名称` 或者 `rm -rf ~/.pyenv/versions/环境名称`
* 创建虚拟环境：`pyenv virtualenv 3.6.4 env3.6.4`

总结：利用`pyenv`和`pyenv-virtualenv`插件就能够简单方便的将python版本和依赖包进行环境隔离了，在实际开发过程中比较推荐这种方式。

参考文档：[https://github.com/pyenv/pyenv](https://github.com/pyenv/pyenv)。

## Docker

有没有一种方式能够不按照这些工具来进行环境隔离的呢？当然有，那就是大名鼎鼎的`Docker`。如果你的服务都是容器化的话，应该对Docker不陌生，将当前项目跑在一个隔离的容器中，对系统中的其他服务或者项目是没有任何影响的，不用担心会污染环境，唯一不友好的地方是项目中的代码改变后需要重新构建镜像。

[快速安装从package中安装docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-from-a-package)

```
sudo apt-get update
sudo apt-get install libsystemd-journal0
sudo dpkg -i docker-ce_17.03.0_ce-0_ubuntu-trusty_amd64.deb

#Only users with sudo access can run docker commands. Optionally, add non-sudo access to the Docker socket by adding your user to the docker group.
sudo usermod -a -G docker $USER
#Log out and log back in to have your new permissions take effect.
```

在项目根目录下面新建文件`requirements.txt`：

`Django==2.0`

然后我们在根目录下面创建一个`Dockerfile`文件：

```
FROM python:3.6.4

# 设置工作目录
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# 添加依赖（利用Docker 的缓存）
ADD ./requirements.txt /usr/src/app/requirements.txt

# 安装依赖
RUN pip install -r requirements.txt

# 添加应用
ADD . /usr/src/app

# 运行服务
CMD python manage.py runserver 0.0.0.0:8000
```

因为`django2.0`只支持`python3`以上了，所以我们这里基础镜像使用`python:3.6.4`，然后是添加应用代码，安装依赖，运行服务等。然后我们构建一个镜像：

`$ sudo docker build -t jxi/testpyenv:v1 .`

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
jxi/testpyenv       v1                  433f65159140        2 minutes ago       920 MB
python              3.6.4               07d72c0beb99        4 months ago        689 MB
```

构建完成以后，在我们项目根目录中新建一个start.sh的脚本来启动容器：

`docker run -d -p 8000:8000 --name testpyenv jxi/testpyenv:v1`

将本地的8000端口和容器的8000进行映射，执行我们的启动脚本：

`$ source start.sh`

```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
8daa427b8705        jxi/testpyenv:v1    "/bin/sh -c 'pytho..."   6 seconds ago       Exited (2) 6 seconds ago                       testpyenv
```

启动完成后，我们就可以在本地通过http://127.0.0.1:8000进行访问了。

但是如果只这样配置的话，的确能够解决我们的环境隔离问题，但是现在有一个最大的一个问题是，每次代码更改过后都需要重新构建镜像才能生效，这对于开发阶段是非常不友好的，有什么解决方案呢？你是否还记得当你更改了代码后django项目会自动加载的，要是每次更改了项目代码后，容器中的代码也变化的话那岂不是容器中的服务也自动加载了？是不是？

幸好`Docker`为我们提供了`volume`挂载的概念，我们只需要将我们的代码挂载到容器中的工作目录就行了，现在来更改`start.sh`脚本：

```
work_path=$(pwd)
docker run -d -p 8000:8000 --name testpyenv -v ${work_path}:/usr/src/app jxi/testpyenv:v1
```
然后激活启动脚本，随意更改一次代码，看看是否能够及时生效，怎样查看呢？查看日志就行了：

`$ docker logs -f testpyenv`

最后，如果是生产环境记得把代码挂载给去掉，因为线上不需要这样做，只需要构建一次就行。
