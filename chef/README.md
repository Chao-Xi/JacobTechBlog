# Chef Automation Tool

![Alt Image Text](images/chef_readme.jpg "Headline image")

## Chef Basic

1. [Chef Introduction and Chef architecture](chef_basic1.md)
2. [Deployment Automation with Chef](chef_basic2.md)
3. [Chef Recipes Introduction](chef_basic3.md)
4. [Chef Cookbook run local and remote chef client](chef_basic4.md)


## Learning Chef

* [1. Chef 介绍和安装](chef_tutorial1.md)
   * Chef是什么 
   * 为什么企业需要Chef 
   * 在Linux下安装Chef开发工具
   * 在`Mac OS X`下安装`Chef`开发工具
   
```
$ chef verify
$ chef-client --version
```

* [2. Ruby和Chef语法](chef_tutorial2.md)
  * `Ruby`语法和案例 
  * `Chef`语法和案例
  * 常用的`Chef`语法
* [3. 如何写`Chef`配方](chef_tutorial3.md)
  * `chef-apply` 
  * 验证第一个`Chef`配方单
  * 用配方指定理想配置

```
$ chef-apply hello.rb  # chef solo
```

* [4. 用`Test Kitchen`管理沙盒测试环境](chef_tutorial4.md)
  * 宿主和虚拟机
  * 启动自己的虚拟机
  * YAML Overview
  * 用`kitchen.yml`配置`Test Kitchen`

```
$ kitchen init --create-gemfile
$ bundle install
$ kitchen list
$ kitchen login default-centos65
$ kitchen destroy default-centos65
$ kitchen create
```

* [5. 用`Chef`户端管理节点](chef_tutorial5.md)
  * 什么是节点
	* 在一个节点上创建沙盒环境 
	* 用`Test Kitchen`在节点上安装`Chef`客户端 
	* 第一次运行`Chef`客户端 
	* `Chef`客户端的三种模式
	* 命令行工具`Ohai` 
	* 访问节点信息 

```
$ chef-client --local-mode hello.rb
$ chef-client --local-mode hello.rb --log_level info
$ ohai | more
$ chef-client --local-mode info.rb --log_level info
```

* [6. 撰写和使用菜谱](chef_tutorial6.md)
  * 第一个菜谱：每日消息
  * 第一个菜谱：每日消息（使用`Chef`开发包）
  * `Cookbook_file`资源简介 
  * 第一个菜谱：每日消息（`Chef`客户端)
  * 第一次运行`Chef`
  * 剖析`Chef`运行 
  * 菜谱架构
  * The Four Resources You Need to Know
  * Apache菜谱：手把手教你创建菜谱
	 * 生成菜谱结构
	 * 编辑`README.md`文件 
	 * 更新`metadata.rb`
	 * `Package`资源简介
	 * `Service`资源简介
	 * `Template`资源简介 
	 * 验证达到成功标准 
 * 小结

```
$ chef generate cookbook motd    # chef-dk

# chef-client
$ knife cookbook create motd --cookbook-path .
$ cd motg
$ kitchen init --create-gemfile
$ bundle install


$ kitchen converge default-centos65
```

* [7. 属性](chef_tutorial7_attributes.md)
	* `Motd-Attributes`菜谱 
	* `Setting Attributes`
	* 属性优先级基础 
	* `Include_Recipe`
	* 属性优先级
	* 属性排错 

```
$ chef generate attribute default #chef-dk
$ touch attributes/default.rb  #chef-client

$ chef generate recipe message  #chef-dk
$ touch recipes/message.rb  #chef-client
```

* [8. `Chef`服务器同时管理多个节点](chef_tutorial8.md)
  * 使用菜谱来自动化安装企业`Chef`服务器 
	* 幂等性简介(`Idempotence`)
	* 配置企业`Chef`服务器 
	* 准备一个新节点(`chef-client`)
	* 用`Knife`启动并准备节点
	* 用`Chef Solo`配置`Chef`服务器 

```
$ chef generate recipe adduser
$ knife client list
$ knife ssl fetch
$ knife bootstrap node-centos65.vagrantup.com --sudo --connection-user vagrant --connection-password vagrant --node-ssl-verify-mode none --no-host-key-verify
$ chef-solo -h
```

* [9. 社区以及Chef-Client菜谱](chef_tutorial9.md)
  * 使用社区菜谱 
	* `Chef-Client`菜谱 
	* `Knife Cookbook Site`插件 
	* 使用`Knife Cookbook Site`搜索社区菜谱 
	* 通过`Knife Cookbook Site`管理`Chef`服务器中的社区菜谱
	* `Chef-Client`配方单 
	* 配置`Knife`使用生产环境`SSL`设置 
	* 配置`Chef-client`使用生产环境的`SSL`设置 
 
```
$ knife cookbook site search chef-client
$ knife cookbook site show chef-client
$ knife cookbook site download chef-client 11.4.0
$ knife cookbook upload chef-client 


$ knife node list
$ knife node -h
$ knife node run_list add node-centos65.vagrantup.com "recipe[chef-client]"
$ knife node run_list add <node> \
"recipe[<cookbook>::<recipe>],recipe[<cookbook>::<recipe>]"

$ knife ssl check
$ knife ssl fetch

$ knife node show --attribute "chef_client.config.ssl_verify_mode" \
> node-centos65.vagrantup.com

$ knife node show --attribute "chef_client.config.ssl_verify_mode" \
> node-centos65.vagrantup.com

$ knife node show --attribute "chef_client.config.ssl_ca_file" \
> node-centos65.vagrantup.com
```

* [10. Chef zero](chef_tutorial10_zero.md)

 * Test Kitchen and Chef Zero
 * 用`Chef-Playground` 在宿主机器上运行`Chef-Zero` 

```
$ chef-client --local-mode  --chef-zero-port 8889
$ chef-zero --port 9501
$ knife client list
$ knife client list --local-mode 
$ knife upload nodes


$ knife search <index> <search_query>
$ knife search node "*:*"
$ knife search node "ipaddress:192.168.33.32"
$ knife search node "ipaddress:192.*"
$ knife search node "platfo*:centos"
$ knife search node "platform_version:14.0?"
$ knife node show  snowman --long
$ knife search node "name:susu OR name:atwood"
$ knife search node "ipaddress:192* AND platform:ubuntu"
$ knife search node "*:*" -a ipaddress
```

* [11. 数概包](chef_tutorial11_databag.md)
  * 使用Knife在命令行进行数据包的基本操作
  * 在配方单中使用数据包项目的数据创建本地用户
  * 加密数据包 
  * `Chef-valut`

```
$ knife data_bag create users
$ knife data_bag from file users alice.json
$ knife search users "*:*"
$ knife search users "*:*"
$ knife search users "id:alice OR id:bob" 
$ knife search users "*:*" -a shell


$ knife data bag create api_keys
$ knife data bag from file api_keys payment.json \
--secret-file encrypted_data_bag_secret data_bag_item[api_keys::payment]
$ knife data bag show api_keys payment

$ sudo gem install chef-vault --no-ri --no-rdoc
$ knife client create devhost  --disable-editing --file .chef/devhost.pem
$ knife client list
$ knife node create devhost --disable-editing
$ knife vault create passwords mysql_root --json data_bags/passwords/mysql_root.json --search "*:*"  --mode client
$ knife data bag show passwords mysql_root
$ knife vault show passwords mysql_root --mode client
```

* [12 角色roles](chef_tutorial12.md)
	* 创建一个网页服务器角色
	* 属性和角色 
	* 角色和搜索
	* 角色菜谱 

```
$ knife role from file webserver.json
$ knife role show webserver
$ knife node run_list set snowman "role[webserver]"
$ knife search role "run_list:recipe\[apache\]"
$ knife search node "recipes:<recipe name>"
$ knife search node "recipe:apache"
$ knife search node "roles:<role_name>"
$ knife search node role:webserver
```

* [13 环境](chef_tutorial13_env.md)

	* 创建一个开发环境 
	* 属性和环境 
	* 完整实例

```
$ knife environment from file dev.json
$ knife environment show dev
$ knife environment show production
$ chef generate template index.html
$ chef generate template custom
```

* [14 测试](chef_tutorial14_test.md)

	* 重温Apache菜谱 
	* 使用`Serverspec`进行自动化测试
	* `RSpec DSL`语法 
	* 使用`Foodcritic`进行自动化测试 
	* 使用`ChefSpec`进行自动化测试
	* 使用`Let`进行惰性求值 
	* 在`spec_helper.rb`中共享测试代码

```
# chef client
$ sudo gem install foodcritic --no-ri --no-rdoc
$ sudo gem install chefspec --no-ri --no-rdoc

$ chef generate template index.html
$ kitchen verify
$ kitchen test

$ foodcritic .
$ rspec --color
```

* [15 词汇表](chef_tutorial15_term.md)



## Chef Operations

1. [knife search](chef_op1_kinfe_search.md)

## Chef Components

1. [Chef Roles](chef_adv4.md)
2. [Cookbook Versioning](chef_adv5.md)

## Chef Adv.

1. [How to Perform Chef Knife SSL Check and Fetch to Verify Certificate](chef_adv1.md)
2. [12 Chef Knife Cookbook Command Examples](chef_adv2.md)
3. [Chef Quick CheatSheet](chef_adv3.md)

## Chef Practice

1. [LAMP Chef Cookbook](chef_basic5.md)
2. [LAMP Chef Cookbook Analysis](chef_basic6.md)