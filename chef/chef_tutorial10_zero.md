# Chef zero

* Test Kitchen and Chef Zero
* 用`Chef-Playground` 在宿主机器上运行`Chef-Zero` 

### 搜索

* 用`Knife`从命令行搜索 
* 使用`Test Kitchen`从配方单中搜索
 

更少的内存启动一个Chef服务器作为测试用途岂不是很好。为此`Chef`开发包包含个精简版本的`Chef`服务器称作`chef-zero`.

`chef_zero`可以使用址少`20MB`内存来运行因为它很小所以启动很快因此很适合用 作测试。由于要让`Chef`服务器用极少的内存即可运行，`chef-zero`也作出了一些牺牲它没有网页用户界面也小会永久存储任何数据一旦`Chef Zero`停止运行, 所有数据都将丢失但对于测试环境你井不需要网页用户界面或永久数据保存。 

`Test-Kitchen`提供对`chef-zero`的内建支持。让我们用一个例子来展示如何通过`Test-Kitchen`来使用`chef-zero`。 通过使用`chef-zero`作为模拟的`chef `服务器来在沙盒环境中运行`chef-client`测试菜谱，你可以测试到菜谱中使用`Chef`服务器功能的部分


## Test Kitchen and Chef Zero


**Chef Development Kit:**

```
$ chef generate cookbook zero
$ cd zero
```

**Chef Client:**

```
$ knife cookbook create zero --cookbook-path .
$ cd zero
$ kitchen init --create-gemfile
$ bundle install
```

```
$ chef generate cookbook zero
Generating cookbook zero
- Ensuring correct cookbook content
- Committing cookbook files to git

Your cookbook is ready. Type `cd zero` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list of local testing commands.

Why not start by writing an InSpec test? Tests for the default recipe are stored at:

test/integration/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb
```

**`chap10/zero/kitchen.yml`**

```
---
driver:
  name: vagrant
  provider: vmware_desktop

provisioner:
  name: chef_zero
  always_update_cookbooks: true
# client_rb:
#   chef_license: accept

platforms:
  - name: centos65
    driver:
      box: learningchef/centos65
      box_url: learningchef/centos65

suites:
  - name: default
    run_list:
      - recipe[zero::default]
    attributes:
```

```
$ kitchen converge
```


`Test-Kitchen`在沙盒环境中配置`chef-zero`的内建支持

1. 安装`Chef`客户端
2. 在`/tmp/kitchen` 创建假的 `validation.pem` and `client.pem` 
3. 在`/tmp/kitchen` 生成 `client.rb` (`chef-client`的配置文件) 
4. 在 `/tmp/kitchen`生成包含运行清单`dna.json`的文件
5. 在 `/tmp/kitchen/cookbooks`同步宿主机上的菜谱
6. 本地模式运行`chef-client`

```
cd zero/
chef-client --local-mode --log_level --chef-zero-port 8889 --json-attributes dna.json
```

```
$ chef-client --local-mode  --chef-zero-port 8889
[2019-12-04T10:39:59+08:00] WARN: No config file found or specified on command line. Using command line options instead.
[2019-12-04T10:39:59+08:00] WARN: No cookbooks directory found at or above current directory.  Assuming /Users/i515190/Devops_sap/Chef_Doc/learningchef/chap10/zero.
Starting Chef Infra Client, version 15.4.45
resolving cookbooks for run list: []
Synchronizing Cookbooks:
Installing Cookbook Gems:
Compiling Cookbooks...
[2019-12-04T10:40:03+08:00] WARN: Node C02Z155JLVDR has an empty run list.
Converging 0 resources

Running handlers:
Running handlers complete
Chef Infra Client finished, 0/0 resources updated in 03 seconds
```


需要记住的一个重要的事情是运行`Chef`客户端时`Test Kitchen`在后台运行`chef-zero` 井在`Chef`行结束后将其停止。

它并不会保持`chef-zero`运行也不会配置`knife`在沙盒环境中运行。`knife`是和`Chef`服务器交互的主要命令行工具在测试环境中模拟`knife`将带来更多便利


## 用`Chef-Playground` 在宿主机器上运行`Chef-Zero` 

也可以在宿主机器上运行`chef-zero`。你可能想这样做的原因大概会是这样可以使用`knife`工具。 

当你想和`Chef`服务器交互时即使使用`Test Kitchen`也会发现需要在宿主开发机器上运行`knife`。

即使在测试的时候某些, `Chef`服务器的功能， 比如数据包或搜索， 都能得益干使用`knife`工具。 

我们会创建一个叫`chef-playground`的项目目录，其作用类似章中的`chef_repo`但使用`chef-zero`。我们执行的步骤与前面的类似。 l

1. 假设`Chef`可户端或`Chef`开发包已经安装 
2. 创建假的和`validation.pem` and `client.pem`钥匙。 
3. 创建`knife.rb`(`knife`配置文件）。 
4. 运行`chef-zero`。 
5. 与模拟`Chef`服务器`chef-zero`来同步菜谱 
6. 运行`knife`

```
$ mkdir chef-playground
$ cd chef-playground/
$ mkdir .chef
$  cd .chef/
```

`ssh-keygen`生成客户钥匙(-P 选项提供为钥匙添加密码的功能在此我们不需要密码，所以使用两个双引号来提供一个空密码。） 


```
$ ssh-keygen -f devhost.pem -t rsa -P ""
$ ssh-keygen -f validation.pem -P ""
```

```
$ ls
devhost.pem             devhost.pem.pub         validation.pem          validation.pem.pub
```

在`chef-playground/.chef`目录中创建名为`knife.rb`的文件 

**`chef-playground/.chef/knife.rb`**

```
chef_repo = File.join(File.dirname(__FILE__), "..")

chef_server_url "http://127.0.0.1:9501"
node_name       "devhost"
client_key      File.join(File.dirname(__FILE__), "devhost.pem")
cookbook_path   "#{chef_repo}/cookbooks"
cache_type      "BasicFile"
cache_options   :path => "#{chef_repo}/checksums"
```

最后打开一个新的命令行窗口井运行`chef-zero`

像以下代码一样运行`chef-zero`传递一个默认端口`8889`以外的端口， 以避免和其他本地模式运行的`Chef`工具冲突。如果这里建议的`9501`端口也有冲突可以试试其他端口 

```
$ cd chef-playground
$ chef-zero --port 9501
>> Starting Chef Zero (v14.0.13)...
>> WEBrick (v1.5.0) on Rack (v2.0.7) is listening at http://127.0.0.1:9501
>> Press CTRL+C to stop

```
> You can run chef-zero in “daemonized” mode by passing in the --daemon parameter. Chef-zero will detach itself from the current command line process and run in the background.


```
$ tree -al ../chef-playground/
../chef-playground/
└── .chef
    ├── devhost.pem
    ├── devhost.pem.pub
    ├── knife.rb
    ├── validation.pem
    └── validation.pem.pub

1 directory, 5 files
```

knife工具将会默认在`＄HOME/.chef`目录中寻找配置文件及钥匙。如果在默认位置没找到，它会在当前目录树中的每层结构寻找`chef`目录。假设你和几个不同项目的`chef`服务器群集工作，可以将不同的`.chef`目录放在合适的项目目录中，比如`chef-playground/.chef` 

```
$ knife client list
ERROR: Chef::Exceptions::InvalidPrivateKey: The file /Users/i515190/Devops_sap/Chef_Doc/learningchef/chap10/chef-playground/.chef/devhost.pem 
or :raw_key option does not contain a correctly formatted private key or the key is encrypted.
       The key file should begin with '-----BEGIN RSA PRIVATE KEY-----' and end with '-----END RSA PRIVATE KEY-----'
```

**I have an OpenSSH format key and want a PEM format key.**

Changed from `BEGIN OPENSSH PRIVATE KEY` to `BEGIN RSA PRIVATE KEY`

```
$  cd .chef/
$ ssh-keygen -p -N "" -m pem -f devhost.pem
Key has comment '@C02Z155JLVDR'
Your identification has been saved with the new passphrase
```

```
$ knife client list
chef-validator
chef-webui
```


说明：本书中我们不会使用`knife --local-mode`,但需要提及的是和`chef-client`一样,`knife`工具通过`--local-mode`选项支持本地模式`chef一zero`。 使用本地模式的优点是`knife`会自动为你启动`chef-zero`

因此也可以通过以下命令来在本地模式运行`knife`来查看客户端，它已会自动启动`chef-zero`。运行以下命令不会与已经开启的`chef-zero`实例冲突， 因为你没有使用默认端口 `8889`。 

```
$knife client list --local-mode 
```

然而，你会注意到它的输出与`knife`在客户端模式运行时有所不同.

```
$ mkdir nodes
$ cd nodes
```

创建三个文件

```
$ touch atwood.json snowman.json susu.json
```

```
$ tree -a .
.
├── .chef
│   ├── devhost.pem
│   ├── devhost.pem.pub
│   ├── knife.rb
│   ├── validation.pem
│   └── validation.pem.pub
└── nodes
    ├── atwood.json
    ├── snowman.json
    └── susu.json

2 directories, 8 files
```

**`nodes/atwood.json`**

```
{
  "name": "atwood",
  "chef_type": "node",
  "json_class": "Chef::Node",
  "chef_environment": "_default",
  "run_list": ["recipe[apache]", "recipe[motd]"],
  "automatic": {
    "ipaddress": "192.168.33.31",
    "hostname": "atwood",
    "fqdn": "atwood.playground.local",
    "os": "linux",
    "os_version": "2.6.32-431.el6.x86_64",
    "platform": "centos",
    "platform_version": "6.5",
    "platform_family": "rhel",
    "recipes": ["apache", "motd"]
  }
}
```

**`nodes/snowman.json`**

```
{
  "name": "snowman",
  "chef_type": "node",
  "json_class": "Chef::Node",
  "chef_environment": "_default",
  "run_list": ["recipe[apache]", "recipe[motd]", "recipe[motd-attributes]"],
  "automatic": {
    "ipaddress": "192.168.33.32",
    "hostname": "snowman",
    "fqdn": "snowman.playground.local",
    "os": "linux",
    "os_version": "3.13.0-24-generic",
    "platform": "ubuntu",
    "platform_version": "14.04",
    "platform_family": "debian",
    "recipes": ["apache", "motd", "motd-attributes"]
  }
}
```

**`nodes/susu.json`**

```
{
  "name": "susu",
  "chef_type": "node",
  "json_class": "Chef::Node",
  "chef_environment": "_default",
  "run_list": ["recipe[apache]", "recipe[motd]"],
  "automatic": {
    "ipaddress": "192.168.33.33",
    "hostname": "susu",
    "fqdn": "susu.playground.local",
    "os": "linux",
    "os_version": "2.6.32-431.el6.x86_64",
    "platform": "centos",
    "platform_version": "6.5",
    "platform_family": "rhel",
    "recipes": ["apache", "motd"]
  }
}
```

一旦在`nodes/`目录创建这些文件. 确保回到`chef-playground`作为当前目录。然后运行`knife upload`命令来在服务器上创建这些节点。在

后面的章节中我们将经常在运行其他`knife`命令前使用`knife upload`来上传节点信息到服务器： 

```
$ knife upload nodes
Created nodes/snowman.json
Created nodes/susu.json
Created nodes/atwood.json
```

# 搜索 

`Chef`的搜索功能提供代询在`Chef`服务器上索引的数据的能力。`Chef`服务器执行指定的搜 索先询井将结果返回给客户端可以在命令行使用`knife`命令或在配方单中用代码执行搜索查询。比如可以光询运行某个特定援作系统或软件的所有系统的名宇和急数 

从命令行搜索让我们从在命令行使用`knife`命令执行搜素代询开始， 让我们中创建的`chef-playground/`目录， 以及一样的双命令行模式， 在其中中一个命令行中用一个开放的端口启动`chef-zero`服务器。

```
$ chef-zero --port 9501
>> Starting Chef Zero (v14.0.13)...
>> WEBrick (v1.5.0) on Rack (v2.0.7) is listening at http://127.0.0.1:9501
>> Press CTRL+C to stop
```

```
$  knife upload nodes
Created nodes/snowman.json
Created nodes/susu.json
Created nodes/atwood.json
```

## 用`Knife`从命令行搜索 

也可以在生产环境中`knife search`命令执行搜索。`knife`的杳询语法如下 

```
$ knife search <index> <search_query>
```

索引可以是以下任意一项

* `node`(节点） 
* `client`（客户端） 
* `environment`（环境） 
* `role`（角色） 
* <效据包的名字＞ 

![Alt Image Text](images/10_1.png "body image")

Chef使用`Apache solr`来进行搜索和索引。以下命令将执行个对所有节点的搜索查询井利用`solar`搜柔查询`“*:*.”`返回结果。 

可以看到刚刚通过`knife upload`上传到服务器的节点数据。结果显示`Chef`正在管理三个节点． 

```
$ knife search node "*:*"
3 items found

Node Name:   atwood
Environment: _default
FQDN:        atwood.playground.local
IP:          192.168.33.31
Run List:    recipe[apache], recipe[motd]
Roles:       
Recipes:     apache, motd
Platform:    centos 6.5
Tags:        

Node Name:   snowman
Environment: _default
FQDN:        snowman.playground.local
IP:          192.168.33.32
Run List:    recipe[apache], recipe[motd], recipe[motd-attributes]
Roles:       
Recipes:     apache, motd, motd-attributes
Platform:    ubuntu 14.04
Tags:        

Node Name:   susu
Environment: _default
FQDN:        susu.playground.local
IP:          192.168.33.33
Run List:    recipe[apache], recipe[motd]
Roles:       
Recipes:     apache, motd
Platform:    centos 6.5
Tags:  
```

Chef search queries use the Solr `“<attribute>:<search_pattern>”` form:

```
$ knife search node "ipaddress:192.168.33.32"

1 items found

Node Name:   snowman
Environment: _default
FQDN:        snowman.playground.local
IP:          192.168.33.32
Run List:    recipe[apache], recipe[motd], recipe[motd-attributes]
Roles:       
Recipes:     apache, motd, motd-attributes
Platform:    ubuntu 14.04
Tags:  
```

Use an asterisk (`“*”`) within a search query to perform a wildcard search matching 0 or more characters:

```
knife search node "ipaddress:192.*"
knife search node "platfo*:centos"
```

Use a question mark (`“?”`) to match any single character:

```
knife search node "platform_version:14.0?"

```

You can add specific **key-value** pairs in the query part of the knife search command line.

```
$ knife search node "hostname:snowman"
1 items found

Node Name:   snowman
Environment: _default
FQDN:        snowman.playground.local
IP:          192.168.33.32
Run List:    recipe[apache], recipe[motd], recipe[motd-attributes]
Roles:       
Recipes:     apache, motd, motd-attributes
Platform:    ubuntu 14.04
Tags:        
```

> 说明可以通过使`--long`选项运行`knife ＜索引> show`命令得到一个可以在搜索中使用的属性名字的列表。它会显示所有你指定的索引中的可用的属性。比如说，我们通过运行以下命令 

```
$ knife node show  snowman --long
Node Name:   snowman
Environment: _default
FQDN:        snowman.playground.local
IP:          192.168.33.32
Run List:    recipe[apache], recipe[motd], recipe[motd-attributes]
Roles:       
Recipes:     apache, motd, motd-attributes
Platform:    ubuntu 14.04
Tags:        
Attributes:
tags:

Default Attributes:

Override Attributes:

Automatic Attributes (Ohai Data):
fqdn:             snowman.playground.local
hostname:         snowman
ipaddress:        192.168.33.32
os:               linux
os_version:       3.13.0-24-generic
platform:         ubuntu
platform_family:  debian
platform_version: 14.04
recipes:
  apache
  motd
  motd-attributes
```

**搜索查询可以通过使用类似`OR`的布尔关键字指定多个键值对儿**。比如以下查询返是`alice`或`bob`的节点： 

```
 knife search node "name:susu OR name:atwood"
2 items found

Node Name:   atwood
Environment: _default
FQDN:        atwood.playground.local
IP:          192.168.33.31
Run List:    recipe[apache], recipe[motd]
Roles:       
Recipes:     apache, motd
Platform:    centos 6.5
Tags:        

Node Name:   susu
Environment: _default
FQDN:        susu.playground.local
IP:          192.168.33.33
Run List:    recipe[apache], recipe[motd]
Roles:       
Recipes:     apache, motd
Platform:    centos 6.5
Tags:        
```

同理如果想返回所有的条件的总和查询中也可以使用逻辑`AND`来替代逻辑`OR` 

```
$ knife search node "ipaddress:192* AND platform:ubuntu"
1 items found

Node Name:   snowman
Environment: _default
FQDN:        snowman.playground.local
IP:          192.168.33.32
Run List:    recipe[apache], recipe[motd], recipe[motd-attributes]
Roles:       
Recipes:     apache, motd, motd-attributes
Platform:    ubuntu 14.04
Tags:       
```

我们可以使用`-a`参数来过滤搜索结果。比如使用`-a ipaddress`选项将只返回`ipaddress`属性； 

```
$ knife search node "*:*" -a ipaddress
3 items found

atwood:
  ipaddress: 192.168.33.31

snowman:
  ipaddress: 192.168.33.32

susu:
  ipaddress: 192.168.33.33
```

## 使用Test Kitchen从配方单中搜索 

在`Chef`代码里面，也可以执行搜索查询本节我们会用`Test Kitchen`写一个菜谱并用`chef_zero`执行搜索。

```
$ mkdir cookbooks
$ cd cookbooks
```

**Chef Development Kit:**

```
$ chef generate cookbook nodes
$ cd nodes
```
**Chef Client:**

```
$ knife cookbook create nodes --cookbook-path .
$ cd nodes
$ kitchen init --create-gemfile
$ bundle install
```


```
$ chef generate cookbook nodes
Generating cookbook nodes
- Ensuring correct cookbook content
- Committing cookbook files to git

Your cookbook is ready. Type `cd nodes` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list of local testing commands.

Why not start by writing an InSpec test? Tests for the default recipe are stored at:

test/integration/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb
```

* **`cookbooks/nodes/kitchen.yml`**

```
---
driver:
  name: vagrant
  provider: vmware_desktop

provisioner:
  name: chef_zero
  nodes_path: ../../nodes
  always_update_cookbooks: true

platforms:
  - name: centos65
    driver:
      box: learningchef/centos65
      box_url: learningchef/centos65

suites:
  - name: default
    run_list:
      - recipe[nodes::default]
    attributes:
```

让我们来写一个执行像上一节一样的搜索查询的配方单。`Chef`提供了一个可在代码中使用的`search(）`方法。

它接受两个参数和在命令行中使用`knife search`类似

**search(索引搜索查询）**: 

* 索引 

支持的索引有：`node`, `client`, `environment`, `role`和`＜数据包的名字＞`


* 搜索查询

搜索查询`Apache Solr`式的 

**`/nodes/recipes/default.rb`**

```
#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright (C) 2014
#
#
#

# Print every node name matching the search pattern
search("node", "*:*").each do |matching_node|
  log matching_node.to_s
end
```

The `.each` statement in `recipes/default.rb` is a looping construct specific to Ruby.

```
counter = 0
while counter < 5
  puts counter
  counter = counter + 1
end
```

虽然以上代码是完全有效的`Ruby`代码，在Ruby中更通俗的写法是使用．each迭代器从一 个数组中遍历并返回所有的元素。
 
`do..end`代码块比我们到现在为止所讲述过的更复杂。它可以用来定义一个没有名字的方法。同时，你可以给这个没有名字的方法通过两个竖线符号（`II`)传递一个或更多参数，就像以下例子中的`|counter|`. 

在以下例子中，我们传递一个代码块给`(0..5).each`。当你给一个迭代器传递一个代码块对它将为每一个元素执行指定的方法。在这个例子中`（0..5)`范围中的每个元素都会被以`|counter|`变量传递到我们的代码块。

代码块中的代码使用这个变量来打印每个值： 

```
(0..5).each do |counter|
  puts counter
end
```

我们做了类似的事情, 遍历每个`search()`返回的结果, 将每个结果的内容在后面的代码块以`matching_node`变全代表。`matching_node`是一个包含节点属性键值对儿的哈希。
 
代码块中的代码读取`matching_node的`内容并使用`to_s`方法通过使用`log`打印`matchimg_node`对象的字符串表达形式。在本例中`matching_node`的宇符串表达形式就是节点的名 

```
$ kitchen converge
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
       ==> default: Fixed port collision for 22 => 2222. Now on port 2201.
       ==> default: Starting the VMware VM...
       ==> default: Waiting for the VM to receive an address...
       ==> default: Forwarding ports...
           default: -- 22 => 2201
       ==> default: Waiting for machine to boot. This may take a few minutes...
           default: SSH address: 127.0.0.1:2201
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
       Finished creating <default-centos65> (0m46.40s).
-----> Converging <default-centos65>...
       Preparing files for transfer
$$$$$$ You must set your run_list in your Policyfile instead of kitchen config. The run_list in your config will be ignored.
$$$$$$ Ignored run_list: ["recipe[nodes::default]"]
       Policy lock file doesn't exist, running `chef install` for Policyfile /Users/i515190/Devops_sap/Chef_Doc/learningchef/chap10/chef-playground/cookbooks/nodes/Policyfile.rb...
       Building policy nodes
       Expanded run list: recipe[nodes::default]
       Caching Cookbooks...
       Installing nodes >= 0.0.0 from path
       
       Lockfile written to /Users/i515190/Devops_sap/Chef_Doc/learningchef/chap10/chef-playground/cookbooks/nodes/Policyfile.lock.json
       Policy revision id: c2340b0ef105fd212326f7001a4309c5bcb2d73d39e6cec5e6d23fee42fa0d68
       Updating policy lock using `chef update`
       Attributes already up to date
       Building policy nodes
       Expanded run list: recipe[nodes::default]
       Caching Cookbooks...
       Installing nodes >= 0.0.0 from path
       
       Lockfile written to /Users/i515190/Devops_sap/Chef_Doc/learningchef/chap10/chef-playground/cookbooks/nodes/Policyfile.lock.json
       Policy revision id: c2340b0ef105fd212326f7001a4309c5bcb2d73d39e6cec5e6d23fee42fa0d68
       Preparing dna.json
       Exporting cookbook dependencies from Policyfile /var/folders/r7/nml_dsbn44gcd2jlqh7s2w940000gn/T/default-centos65-sandbox-20191205-75016-n73yz4...
       Exported policy 'nodes' to /var/folders/r7/nml_dsbn44gcd2jlqh7s2w940000gn/T/default-centos65-sandbox-20191205-75016-n73yz4
       
       To converge this system with the exported policy, run:
         cd /var/folders/r7/nml_dsbn44gcd2jlqh7s2w940000gn/T/default-centos65-sandbox-20191205-75016-n73yz4
         chef-client -z
       Removing non-cookbook files before transfer
       Preparing nodes
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef install only if missing package
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Trying curl...
       Download complete.
       el 6 x86_64
       Getting information for chef stable  for el...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=el&pv=6&m=x86_64
         to file /tmp/install.sh.3170/metadata.txt
       trying wget...
       trying curl...
       sha1     c332e5aef6cf70d1df1e1786926c474eedae1dc2
       sha256   ddb6e94a65568e6247aa335ef7d2dd69c300c9d2e2df098997b08cf9f6f0c473
       url      https://packages.chef.io/files/stable/chef/15.5.17/el/6/chef-15.5.17-1.el6.x86_64.rpm
       version  15.5.17
       downloaded metadata file looks valid...
       downloading https://packages.chef.io/files/stable/chef/15.5.17/el/6/chef-15.5.17-1.el6.x86_64.rpm
         to file /tmp/install.sh.3170/chef-15.5.17-1.el6.x86_64.rpm
       trying wget...
       trying curl...
       Comparing checksum with sha256sum...
       
       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
       
       You are installing a package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.
       
       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
       
       Installing chef 
       installing with rpm...
       warning: /tmp/install.sh.3170/chef-15.5.17-1.el6.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
       Preparing...                ########################################### [100%]
          1:chef                   ########################################### [100%]
       Thank you for installing Chef Infra Client! For help getting started visit https://learn.chef.io
       Transferring files to <default-centos65>
       +---------------------------------------------+
       ✔ 2 product licenses accepted.
       +---------------------------------------------+
       Starting Chef Infra Client, version 15.5.17
       Creating a new client identity for default-centos65 using the validator key.
       Using policy 'nodes' at revision 'c2340b0ef105fd212326f7001a4309c5bcb2d73d39e6cec5e6d23fee42fa0d68'
       resolving cookbooks for run list: ["nodes::default@0.1.0 (f791f0b)"]
       Synchronizing Cookbooks:
         - nodes (0.1.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 4 resources
       Recipe: nodes::default
         * log[node[atwood]] action write
         
         * log[node[default-centos65]] action write
         
         * log[node[snowman]] action write
         
         * log[node[susu]] action write
         
       
       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 4/4 resources updated in 01 seconds
       Downloading files from <default-centos65>
       Finished converging <default-centos65> (0m33.65s).
-----> Kitchen is finished. (1m20.65s)
```
