# 用`Chef`户端管理节点 

* 什么是节点
* 在一个节点上创建沙盒环境 
* 用`Test Kitchen`在节点上安装`Chef`客户端 
* 第一次运行`Chef`客户端 
* `Chef`客户端的三种模式
* 命令行工具`Ohai` 
* 访问节点信息 

## 什么是节点 


在讲述如何使用`Test Kitchen`在虚拟机中安装Chef客户端之前先来介绍一下我们用来描述不同举型的电脑的`Chef`术语。 

用来写`Chef`代码的电脑我们称作`Chef`开发者工作站或`Chef`管理员工作站（或简称开发机器和工作机器）。这是你使用的宿主机器。在第2章中在宿主机器上安装了`Chef`开发包（或Chef客户端和额外工具），因此你有足够多的工其来使用一个文本编辑器或集成开发环境来写`Chef`配方单以及使用一个版本控制系统来管理`Chef`代码的改变。


受`Chef`管理的机器称作节点。当一个机器执行`Chef`配方单井因此保证机器是在理想的配 置下时，我们说这是一台受`Chef`管理的机器，像在第4章中展示的一样个节点可以是一个物理机器、虚拟机、云实例或容器实例`Chef`并不在平这些。

**只要这个节点安装了`Chef`客户端，就可以受`Chef`管理并运行`Chef`配方单。** 


**由干`Chef`开发包是`Chef`客户端的一个超集你可以在节点上安装`Chef`开发包。**

让你的宿主机器同时成为一个`Chef`开发工作站和一个受`Chef`管理的节点。然而`Chef`开发包占用几乎双倍于`Chef`客户端的空间，所有其包含的额外的工具都是为了帮助撰写`Chef`代码，而不是运行`Chef`代码。


## 在一个节点上创建沙盒环境 

```
$ cd chap05/node
$ kitchen init --create-gemfile
      create  kitchen.yml
      create  chefignore
      create  test/integration/default
      create  Gemfile
      append  Gemfile
You must run `bundle install' to fetch any new gems.
```

在运行`kitchen init`之后运行`bundle install`,是一个值得养成的好习惯。 


```
$ bundle install
```

**编辑`node/kitchen.yml`**

```
---
driver:
  name: vagrant
  provider: vmware_desktop

provisioner:
  name: chef_solo

platforms:
  - name: centos65
    driver:
      box: learningchef/centos65
      box_url: learningchef/centos65

suites:
  - name: default
    run_list:
    attributes:
```

```
$ kitchen list
Instance          Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-centos65  Vagrant  ChefSolo     Busser    Ssh        <Not Created>  <None>
```

```
$ kitchen create default-centos65
-----> Starting Kitchen (v2.3.3)
-----> Creating <default-centos65>...
       Bringing machine 'default' up with 'vmware_desktop' provider...
       ==> default: Cloning VMware VM: 'learningchef/centos65'. This can take some time...
       ==> default: Checking if box 'learningchef/centos65' version '1.0.7' is up to date...
       ==> default: Verifying vmnet devices are healthy...
       ==> default: Preparing network adapters...
       WARNING: The VMX file for this box contains a setting that is automatically overwritten by Vagrant
       WARNING: when started. Vagrant will stop overwriting this setting in an upcoming release which may
       WARNING: prevent proper networking setup. Below is the detected VMX setting:
       WARNING: 
       WARNING:   ethernet0.pcislotnumber = "33"
       WARNING: 
       WARNING: If networking fails to properly configure, it may require this VMX setting. It can be manually
       WARNING: applied via the Vagrantfile:
       WARNING: 
       WARNING:   Vagrant.configure(2) do |config|
       WARNING:     config.vm.provider :vmware_desktop do |vmware|
       WARNING:       vmware.vmx["ethernet0.pcislotnumber"] = "33"
       WARNING:     end
       WARNING:   end
       WARNING: 
       WARNING: For more information: https://www.vagrantup.com/docs/vmware/boxes.html#vmx-whitelisting
       ==> default: Starting the VMware VM...
       ==> default: Waiting for the VM to receive an address...
       ==> default: Forwarding ports...
           default: -- 22 => 2222
       ==> default: Waiting for machine to boot. This may take a few minutes...
           default: SSH address: 127.0.0.1:2222
           default: SSH username: vagrant
           default: SSH auth method: private key
           default: 
           default: Vagrant insecure key detected. Vagrant will automatically replace
           default: this with a newly generated keypair for better security.
           default: 
           default: Inserting generated public key within guest...
           default: Removing insecure key from the guest if it's present...
           default: Key inserted! Disconnecting and reconnecting using new SSH key...
       ==> default: Machine booted and ready!
       ==> default: Setting hostname...
       ==> default: Configuring network adapters within the VM...
       ==> default: Machine not provisioned because `--no-provision` is specified.
       [SSH] Established
       Vagrant instance <default-centos65> created.
       Finished creating <default-centos65> (0m39.92s).
-----> Kitchen is finished. (0m40.34s)
```

## 用`Test Kitchen`在节点上安装`Chef`客户端 

使用`kitchen login`到节点（沙盒环魂）井访问其命令行。然后通过运行`chef client --version` 看看`Chef`客户端是否己经安装:

```
$ kitchen login default-centos65
Last login: Sat Nov 23 10:50:26 2019 from 172.16.72.2
Welcome to your Packer-built virtual machine.
[vagrant@default-centos65 ~]$ chef-client --version
-bash: chef-client: command not found
```

安装`chef-clinet`可以，单不需要，因为有更简单的方式 

```
curl -Lk https://www.getchef.com/chef/install.sh | sudo bash
```

```
[vagrant@default-centos65 ~]$ exit
logout
Connection to 127.0.0.1 closed.
```

确定你使用你的宿主机器,在沙盒中安装`chef-client`

```
$ kitchen setup default-centos65
-----> Starting Kitchen (v2.3.3)
-----> Converging <default-centos65>...
       Preparing files for transfer
       Preparing dna.json
       Policyfile, Berksfile, cookbooks/, or metadata.rb not found so Chef Infra Client will run, but do nothing. Is this intended?
       Removing non-cookbook files before transfer
       Preparing solo.rb
-----> Installing Chef install only if missing package
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Trying curl...
       Download complete.
       ...
       
       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
       
       You are installing a package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.
       
       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
       
       Installing chef 
       installing with rpm...
       warning: /tmp/install.sh.3205/chef-15.5.17-1.el6.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
       Preparing...                ########################################### [100%]
          1:chef                   ########################################### [100%]
       Thank you for installing Chef Infra Client! For help getting started visit https://learn.chef.io
       Transferring files to <default-centos65>
       +---------------------------------------------+
       ✔ 2 product licenses accepted.
       +---------------------------------------------+
       Starting Chef Infra Client, version 15.5.17
       Creating a new client identity for default-centos65 using the validator key.
       resolving cookbooks for run list: []
       Synchronizing Cookbooks:
       Installing Cookbook Gems:
       Compiling Cookbooks...
       [2019-11-23T11:03:01+00:00] WARN: Node default-centos65 has an empty run list.
       Converging 0 resources
       
       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 0/0 resources updated in 01 seconds
       Downloading files from <default-centos65>
       Finished converging <default-centos65> (1m19.05s).
-----> Setting up <default-centos65>...
       Finished setting up <default-centos65> (0m0.00s).
-----> Kitchen is finished. (1m19.50s)
```

**检查`kitchen setup`命令的输出，它为你安装了`chef-client` (Che喀户端）我们使用 `kitchen setup`命令来运行一个启动器(`provisioner`)。**

**启动器是一个表示任何配置管理工具的综合术语，因为`Test Kitchen`也可以和`Chef`以外的其他配置管理工具一起使用在默认情况下，`Test Kitchen`使用`ChefSolo`启动器。**

**`Chef Solo`安装`Chef`客户端但不把它配置为使用`Chef`服务器。如果`chef-client`不存在，`kitchen setup`会自动安装`Chef`客户端**


### SSL WARNING

During the Chef run, you might have noticed the following SSL warning:

```
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
SSL validation of HTTPS requests is disabled. HTTPS connections are still
encrypted, but chef is not able to detect forged replies or man in the middle
attacks.

To fix this issue add an entry like this to your configuration file:

   ```
     # Verify all HTTPS connections (recommended)
     ssl_verify_mode :verify_peer

     # OR, Verify only connections to chef-server
     verify_api_cert true
   ```

   To check your SSL configuration, or troubleshoot errors, you can use the
   `knife ssl check` command like so:

   ```
     knife ssl check -c /tmp/kitchen/solo.rb
   ```

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
```

在开发`Chef`代码的时候不验证`Chef`服务的`HTTPS`诗求是完全没问题的。事实上现在连一个`Chef`服务器都没有因此如果开启验证，会得到错误 


**为了支持开发的便捷性, `Chef`默认不验证`HTTPS`连接的证书**。


`chef-client`通过以上警告指出证书没有通过验证。当开发`Chef`代码的时候往往不需要使用`Chef`务器, 即使使用`Chef`服务器通常也是类似`Chef Zero`的全内存版本， 通常并不需要要配置一个有效的`SSL`配置


**然而在生产环境应该在`/etc/chef/client.rb`配置文件中开启证书验证。**

如果现在运行`kitchen list`会发现`Last Action`从`Created`（已创建）变成`Set Up`（已配置）:

```
$ kitchen list
Instance          Driver   Provisioner  Verifier  Transport  Last Action  Last Error
default-centos65  Vagrant  ChefSolo     Busser    Ssh        Set Up       <None>
```

```
$ kitchen login default-centos65
Last login: Sat Nov 23 11:02:58 2019 from 172.16.72.2
Welcome to your Packer-built virtual machine.

[vagrant@default-centos65 ~]$ chef-client --version
Chef Infra Client: 15.5.17
```


## 第一次运行`Chef`客户端 

我们可以使用`log`资源来在配方单中打印字符串。比如，在配方单中使用`log` "Hello"会打印字符串`Hello`。

让我们来试试这个。假设你仍然登录在节点的环境中， 请使用下列命令在节点上创建一个`hello.rb`文件： 

```
[vagrant@default-centos65 ~]$ cd node
[vagrant@default-centos65 ~]$ echo 'log "Hello, this is an important message."' > hello.rb
[vagrant@default-centos65 ~]$ ls node
hello.rb
[vagrant@default-centos65 ~]$ more node/hello.rb 
log "Hello, this is an important message."
```

**通过使用`chef-client`程序来执行配方单中指定的动作通常被称作一次`Chef`运行**

在命令行中输人`chef-client --local-mode hello.rb --log_level info`将执行你的第一次`Chef`运行。

* `--local-mode`选项防止`chef-client`在寻找不存在的`Chef`服务器时超时。
* 我们同时需要`--log_level info`选项，因为默认情况下`chef-client`只打印错误，而非信息消息， 
* 这个选项将告诉`chef-client`打印来自`Chef::Log.info`命令的所有字符串。 

```
[vagrant@default-centos65 node]$ chef-client --local-mode hello.rb
[2019-11-24T07:50:04+00:00] WARN: No config file found or specified on command line. Using command line options instead.
[2019-11-24T07:50:04+00:00] WARN: No cookbooks directory found at or above current directory.  Assuming /home/vagrant/node.
Starting Chef Infra Client, version 15.5.17
resolving cookbooks for run list: []
Synchronizing Cookbooks:
Installing Cookbook Gems:
Compiling Cookbooks...
[2019-11-24T07:50:06+00:00] WARN: Node default-centos65.vagrantup.com has an empty run list.
Converging 1 resources
Recipe: @recipe_files::/home/vagrant/node/hello.rb
  * log[Hello, this is an important message.] action write
  

Running handlers:
Running handlers complete
Chef Infra Client finished, 1/1 resources updated in 01 seconds
```

在`chef-client`运行时，以下输出表示`“Hello, this is an important message."`字符串在`chef`运行时被写入了日志 

```
log[Hello, this is an important message.] action write
```

**要想查看实际的日志消息内容需要更改`chef-client`的日志级别**

每一个写在日志的消息已都有个级别， 这些级别根据优先级从低到高依次为`debug`、`Info`\ `warn`、`error`和`fatal`。 

`log`资源默认使用`Info`级别, 对于你的"Hello"， 消息来讲是合适的。然而`chef client` 默认只打印`Warn`或更高级别的消息， 除非改`chef-client`的日志级别 

要改变日志级别，使用`--log-level`选项。`--log_level`选项需要个参数(`--log_level` <级别＞)，用来告诉`chef-client`最低的写向日志的级别。

如果在`chef-client`命令后面加上`--log-level info` 则会显示你刚刚添加的日志消息。

```
$ chef-client --local-mode hello.rb --log_level info

[2019-11-24T08:11:52+00:00] WARN: No config file found or specified on command line. Using command line options instead.
[2019-11-24T08:11:52+00:00] WARN: No cookbooks directory found at or above current directory.  Assuming /home/vagrant/node.
[2019-11-24T08:11:52+00:00] INFO: Started Chef Infra Zero at chefzero://localhost:1 with repository at /home/vagrant/node
[vagrant@default-centos65 node]$ chef-client --local-mode hello.rb --log_level info
[2019-11-24T08:12:20+00:00] WARN: No config file found or specified on command line. Using command line options instead.
[2019-11-24T08:12:20+00:00] WARN: No cookbooks directory found at or above current directory.  Assuming /home/vagrant/node.
[2019-11-24T08:12:20+00:00] INFO: Started Chef Infra Zero at chefzero://localhost:1 with repository at /home/vagrant/node
  One version per cookbook

Starting Chef Infra Client, version 15.5.17
[2019-11-24T08:12:20+00:00] INFO: *** Chef Infra Client 15.5.17 ***
[2019-11-24T08:12:20+00:00] INFO: Platform: x86_64-linux
[2019-11-24T08:12:20+00:00] INFO: Chef-client pid: 3680
[2019-11-24T08:12:21+00:00] INFO: Run List is []
[2019-11-24T08:12:21+00:00] INFO: Run List expands to []
[2019-11-24T08:12:21+00:00] INFO: Starting Chef Infra Client Run for default-centos65.vagrantup.com
[2019-11-24T08:12:21+00:00] INFO: Running start handlers
[2019-11-24T08:12:21+00:00] INFO: Start handlers complete.
resolving cookbooks for run list: []
[2019-11-24T08:12:21+00:00] INFO: Loading cookbooks []
Synchronizing Cookbooks:
Installing Cookbook Gems:
Compiling Cookbooks...
[2019-11-24T08:12:21+00:00] WARN: Node default-centos65.vagrantup.com has an empty run list.
Converging 1 resources
Recipe: @recipe_files::/home/vagrant/node/hello.rb
  * log[Hello, this is an important message.] action write[2019-11-24T08:12:21+00:00] INFO: Processing log[Hello, this is an important message.]
 action write (@recipe_files::/home/vagrant/node/hello.rb line 1)
[2019-11-24T08:12:21+00:00] INFO: Hello, this is an important message.

  
[2019-11-24T08:12:21+00:00] INFO: Chef Infra Client Run complete in 0.037831751 seconds

Running handlers:
[2019-11-24T08:12:21+00:00] INFO: Running report handlers
Running handlers complete
[2019-11-24T08:12:21+00:00] INFO: Report handlers complete
Chef Infra Client finished, 1/1 resources updated in 01 seconds
```

 
默认情况下`chef-client`将日志打印至屏幕。现在你改变了日志级别可以在日志输出中看到添加的消急（以及一些其他同时在`info`级别的消息）。

### NOTE


If you would prefer to write the `chef-client` log to a file, use the `--logfile <LOGLOCATION>` option (or the short form `-l`). 

## Chef客户端的三种模式 

`Chef`客户端可以在以下三种模式的任何一种下运行 

* 本地模式 
* 客户端模式 
* `Solo`模式 

### 本地模式 

当`chef-client`以本地模式运行时，它在内存中模拟一个完整的`Chef`服务器。任何本应保存到服务器的数据会被写入一个本地文件夹。 将服务器数据写在本地的过程叫做回写(`writeback`)。这是为什么`chef-client`创建了`nodes/`目录。 本地模式是设计来支持通过使用完全在内存的`Chef Zero`服务器来进行快速的`Chef`配方单开发 

```
$ ls -la
total 16
drwxrwxr-x  3 vagrant vagrant 4096 Nov 24 07:50 .
drwx------. 5 vagrant vagrant 4096 Nov 24 07:50 ..
-rw-rw-r--  1 vagrant vagrant   43 Nov 24 07:37 hello.rb
drwx------  2 vagrant vagrant 4096 Nov 24 07:50 nodes
```


### 客户端模式 

当`chef-client`以客户端模式运行时，它假设你在网络中已经让`Chef`服务器正在运行。人们在生产环境中就是这样使用`chef`的. 在客户端模式中，`chef-client`是一个在被`Chef`管理的机器本地运行的代理人程序（或服务、后台程序). `Chef`服务器集中存储需要管理的基础架构的信息。如果需要同时管理多余一台机器，推荐使用`Chef`服务器 


###  `Solo`模式 

在版本`11.8`中`chef-client`支持本地模式之前，唯一不需要`Chef`服务器运行`Chef`代码的方法是使用`chef-solo`.

**`chef-solo`提供一个额外的客户端模式叫做`Solo`模式**。`Solo`模式提供了让`Chef`够本地运行的`Chef`功能的有限的子集。`chef-solo`不支持回写, 在大多数时候，本地模式都远远比`Solo`模式更方便使用。

在未来，`Chef`软件公司计划当本地模式拥有的功能以及大多数客户都使用版本`11.8`或更高的时候，不再提供对`Solo`模式的支持。`Solo`模式在仍然使用老版本`Chef`的组织中更受欢迎。 


## 命令行工具`Ohai` 

当`Chef`客户端运行时, 它使用一个额外的命令行工具`ohai`来收集系统信息。`ohai`将收集 
到的节点信包储存在`Chef`的自动属性中 


可以试试手动运行`ohai`, 输出的信息就是它储存在`Chef`节点的信息。在我们的系统上，`ohai` 输出了`1058`行结果， 所以你最好配合使用`more`此命令来一屏一屏查看结果。不必看完整个结果， 任何时候都可以通过`q`键退出  


```
$ ohai | more
{
  "kernel": {
    "name": "Linux",
    "release": "2.6.32-431.el6.x86_64",
    "version": "#1 SMP Fri Nov 22 03:15:09 UTC 2013",
    "machine": "x86_64",
    "processor": "x86_64",
    "os": "GNU/Linux",
    "modules": {
      "vmhgfs": {
        "size": "49607",
        "refcount": "1",
        "version": "1.4.1.1"
      },
      "vsock": {
        "size": "46422",
        "refcount": "2",
        "version": "9.6.1.0"
      },
      "ipv6": {
        "size": "317340",
        "refcount": "24"
      },
      "ppdev": {
        "size": "8537",
        "refcount": "0"
      },
      "vmware_balloon": {
        "size": "7199",
        "refcount": "0",
        "version": "1.2.1.1-k"
      },
      "parport_pc": {
        "size": "22690",
/address
...skipping
        "addresses": {
          "127.0.0.1": {
            "family": "inet",
            "prefixlen": "8",
            "netmask": "255.0.0.0",
            "scope": "Node"
          },
          "::1": {
            "family": "inet6",
            "prefixlen": "128",
            "scope": "Node",
            "tags": [

            ]
          }
...
```

可以看出，`ohai`收集许多关于电脑当前状态的信息：**网络配置, Cpu状态、操作系统类型和版本、内存使用量等**。

 
举例而言，让我们看看ohaj产生的信息的一部分。就像下面展示的，chai收集节点的`IP`地址、`MAC`地址、操作系统信急、主机名，它甚至知道我们在一个虚拟环境中运行： 

```
{
...
  "ipaddress": "10.0.2.15",
  "macaddress": "08:00:27:1C:AD:B6",
...
  "os": "linux",
  "os_version": "2.6.32-431.el6.x86_64",
  "platform": "centos",
  "platform_version": "6.5",
  "platform_family": "rhel",
...
  "virtualization": {
    "system": "vbox",
    "role": "guest"
  }
...
  "hostname": "default-centos65"
...
}
```


通过以下属性，可以在代码里引用节点的`IP`地址。属属性是`Chef`管理的一个变量。在你的代码中，在中括号中用引号包围的字符串指定属胜的名称，Chef会返回属性的值。在我们的例子中，我们要知道`IP`地址，在之前的`ohaI`输出中，我们知道其`IP`地址属胜的名称是`ipaddress`,因此可以用此名称在`Chef`代码中访问节点的属胜： 

```
node['ipaddress']
```

我们在前面"配方单指定理想配置”小节的`Chef`代码中使用了属性变量， node是另外－个`Chef`代码中可以使用的属性。它包含在节点上运行`ohai`输出的所有信息和我们使用的`ENV`属性类似，`node`属性是一个键值对儿集合

**键值对儿集合支持嵌套，这是为什么在`ohai`输出中会有多层缩进。因此，如果要访问节点使用用的虚拟软件信急（"虚拟系统”)，使用以下的嵌套键值对儿，`system`是 `virtualization`集合中的一个键**

```
node['virtualization']['system']
```

说明：以字符串来访问属性的值，例如`node["virtualization"]["system"]`，是最常用的访问方法。然而，因为属性是`Mash`对象，所以也可以通过其他形式来访问属性的值 

```
node[:virtualization][:system]
node['virtualization']['system']
node.virtualization.system
```

## 访问节点信息

**上一节我们讲述了`chef-client`使用`ohai`来收集节点的许多信息。**

**收集这些信息是必要的因为这样`Chef`才可以智能地判断如何将节点转换至配方单中指定的理想的配置。`Chef`将这些信息作为节点属胜来让你可以在代码中访问**。

属胜是`Chef`维护的一个变量 

```
$ vi info.rb

log "IP Address: #{node['ipaddress']}"
log "MAC Address: #{node['macaddress']}"
log "OS Platform: #{node['platform']} #{node['platform_version']}"
log "Running on a #{node['virtualization']['system']} #{node['virtualization']['role']}"
log "Hostname: #{node['hostname']}"
```

你应该对使用料`#{<变量＞｝`来打印在变量中的信息的语法并不陌生，这跟我们在第4章中用来访问`＃{ENV['HOME']}`时很类似。在这个例子中，`node`是我们的变量。 

```
[vagrant@default-centos65 node]$  chef-client --local-mode info.rb --log_level info
[2019-11-24T09:41:03+00:00] WARN: No config file found or specified on command line. Using command line options instead.
[2019-11-24T09:41:03+00:00] WARN: No cookbooks directory found at or above current directory.  Assuming /home/vagrant/node.
[2019-11-24T09:41:03+00:00] INFO: Started Chef Infra Zero at chefzero://localhost:1 with repository at /home/vagrant/node
  One version per cookbook

Starting Chef Infra Client, version 15.5.17
[2019-11-24T09:41:03+00:00] INFO: *** Chef Infra Client 15.5.17 ***
[2019-11-24T09:41:03+00:00] INFO: Platform: x86_64-linux
[2019-11-24T09:41:03+00:00] INFO: Chef-client pid: 3930
[2019-11-24T09:41:04+00:00] INFO: Run List is []
[2019-11-24T09:41:04+00:00] INFO: Run List expands to []
[2019-11-24T09:41:04+00:00] INFO: Starting Chef Infra Client Run for default-centos65.vagrantup.com
[2019-11-24T09:41:04+00:00] INFO: Running start handlers
[2019-11-24T09:41:04+00:00] INFO: Start handlers complete.
resolving cookbooks for run list: []
[2019-11-24T09:41:04+00:00] INFO: Loading cookbooks []
Synchronizing Cookbooks:
Installing Cookbook Gems:
Compiling Cookbooks...
[2019-11-24T09:41:04+00:00] WARN: Node default-centos65.vagrantup.com has an empty run list.
Converging 5 resources
Recipe: @recipe_files::/home/vagrant/node/info.rb
  * log[IP Address: 172.16.72.138] action write[2019-11-24T09:41:04+00:00] INFO: Processing log[IP Address: 172.16.72.138] action write (@recipe_files::/home/vagrant/node/info.rb line 1)
[2019-11-24T09:41:04+00:00] INFO: IP Address: 172.16.72.138

  
  * log[MAC Address: 00:0C:29:71:DE:FB] action write[2019-11-24T09:41:04+00:00] INFO: Processing log[MAC Address: 00:0C:29:71:DE:FB] action write (@recipe_files::/home/vagrant/node/info.rb line 2)
[2019-11-24T09:41:04+00:00] INFO: MAC Address: 00:0C:29:71:DE:FB

  
  * log[OS Platform: centos 6.5] action write[2019-11-24T09:41:04+00:00] INFO: Processing log[OS Platform: centos 6.5] action write (@recipe_files::/home/vagrant/node/info.rb line 3)
[2019-11-24T09:41:04+00:00] INFO: OS Platform: centos 6.5

  
  * log[Running on a  ] action write[2019-11-24T09:41:04+00:00] INFO: Processing log[Running on a  ] action write (@recipe_files::/home/vagrant/node/info.rb line 4)
[2019-11-24T09:41:04+00:00] INFO: Running on a  

  
  * log[Hostname: default-centos65] action write[2019-11-24T09:41:04+00:00] INFO: Processing log[Hostname: default-centos65] action write (@recipe_files::/home/vagrant/node/info.rb line 5)
[2019-11-24T09:41:04+00:00] INFO: Hostname: default-centos65

  
[2019-11-24T09:41:04+00:00] INFO: Chef Infra Client Run complete in 0.040802177 seconds

Running handlers:
[2019-11-24T09:41:04+00:00] INFO: Running report handlers
Running handlers complete
[2019-11-24T09:41:04+00:00] INFO: Report handlers complete
Chef Infra Client finished, 5/5 resources updated in 01 seconds
```


```
$ exit
logout
Connection to 127.0.0.1 closed.
```

```
$ kitchen destroy default-centos65
-----> Starting Kitchen (v2.3.3)
-----> Destroying <default-centos65>...
       ==> default: Stopping the VMware VM...
       ==> default: Deleting the VM...
       Vagrant instance <default-centos65> destroyed.
       Finished destroying <default-centos65> (0m19.61s).
-----> Kitchen is finished. (0m20.10s)
```

