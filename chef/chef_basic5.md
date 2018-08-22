# Creating My First Chef Cookbook


**Cookbooks are one of the key components in Chef.**

They describe the desired state of your nodes, and allow Chef to push out the changes needed to achieve this state. Creating a cookbook can seem like an arduous task at first, given the sheer number of options provided and areas to configure, so in this guide we will walk through the creation of one of the first things people often learn to configure: 

**A LAMP stack.**


## Bootstap a new machine as new node

[https://docs.chef.io/install_bootstrap.html](https://docs.chef.io/install_bootstrap.html)

```
$ knife bootstrap 123.45.6.789 -x username -P password --sudo
```

```
$ knife bootstrap 192.168.33.14 -x vagrant -P vagrant --sudo

ERROR: You must pass a node name with -N when bootstrapping with user credentials
```

```
$ knife bootstrap 192.168.33.14 -x vagrant -P vagrant --sudo --use-sudo-password --node-name node2
Creating new client for node2
Creating new node for node2
Connecting to 192.168.33.14
192.168.33.14 -----> Existing Chef installation detected
192.168.33.14 Starting the first Chef Client run...
192.168.33.14 YAML safe loading is not available. Please upgrade psych to a version that supports safe loading (>= 2.0).
192.168.33.14 Starting Chef Client, version 11.8.2
192.168.33.14
192.168.33.14 ================================================================================
192.168.33.14 Chef encountered an error attempting to load the node data for "node2"
192.168.33.14 ================================================================================
192.168.33.14
192.168.33.14
192.168.33.14 Networking Error:
192.168.33.14 -----------------
192.168.33.14 Error connecting to https://chefserver/organizations/devops-jxi/nodes/node2 - getaddrinfo: Name or service not known
192.168.33.14
192.168.33.14 Your chef_server_url may be misconfigured, or the network could be down.
192.168.33.14
192.168.33.14
192.168.33.14
192.168.33.14 Relevant Config Settings:
192.168.33.14 -------------------------
192.168.33.14 chef_server_url  "https://chefserver/organizations/devops-jxi"
192.168.33.14
192.168.33.14
192.168.33.14
192.168.33.14 [2018-08-17T08:48:43+00:00] FATAL: Stacktrace dumped to /var/chef/cache/chef-stacktrace.out
192.168.33.14 Chef Client failed. 0 resources updated
192.168.33.14 [2018-08-17T08:48:43+00:00] ERROR: Error connecting to https://chefserver/organizations/devops-jxi/nodes/node2 - getaddrinfo: Name or service not known
192.168.33.14 [2018-08-17T08:48:43+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
```

**On the new node machine `192.168.33.14`**

```
$ sudo vi /etc/hosts
192.168.33.19 chefserver chefserver
```

**Try it again**

```
$ knife bootstrap 192.168.33.14 -x vagrant -P vagrant --sudo --use-sudo-password --node-name node2

Node node2 exists, overwrite it? (Y/N) y
Client node2 exists, overwrite it? (Y/N) y
Creating new client for node2
Creating new node for node2
Connecting to 192.168.33.14
192.168.33.14 -----> Existing Chef installation detected
192.168.33.14 Starting the first Chef Client run...
192.168.33.14 YAML safe loading is not available. Please upgrade psych to a version that supports safe loading (>= 2.0).
192.168.33.14 Starting Chef Client, version 11.8.2
192.168.33.14 resolving cookbooks for run list: []
192.168.33.14 Synchronizing Cookbooks:
192.168.33.14 Compiling Cookbooks...
192.168.33.14 [2018-08-17T08:50:28+00:00] WARN: Node node2 has an empty run list.
192.168.33.14 Converging 0 resources
192.168.33.14 Chef Client finished, 0 resources updated
```

```
$ knife client list
devops-jxi-validator
node1
node2
```

```
$ knife client show node2
admin:     false
chef_type: client
name:      node2
validator: false
```

## Create the Cookbook

1.From your workstation, move to your `cookbooks` directory in `chef-repo`:

```
cd chef-repo/cookbooks
```

2.Create the cookbook. In this instance the cookbook is titled `lamp_stack`:

```
chef generate cookbook lamp_stack
```
3.List the files located in the newly-created cookbook to see that a number of directories and files have been created:

```
$ cd lamp_stack/
$ ls
Berksfile  CHANGELOG.md  chefignore  LICENSE  metadata.rb  README.md  recipes  spec  test
```

## default.rb

The `default.rb` file in `recipes` contains the “default” recipe resources.

Because each section of the LAMP stack (Apache, MySQL, and PHP) will have its own recipe, the `default.rb` file is used to prepare your servers.

From within your `lamp_stack` directory, navigate to the recipes folder:

```
cd recipes
```
Open `default.rb` and add the Ruby command below, which will run system updates:

```
execute "update-upgrade" do
  command "sudo apt-get update && sudo apt-get upgrade -y"
  action :run
end
```
[https://docs.chef.io/resource_execute.html](https://docs.chef.io/resource_execute.html)

Recipes are comprised of a series of resources. In this case, the execute resource is used, which calls for a command to be executed once. The `apt-get update && apt-get upgrade -y` commands are defined in the `command` section, and the `action` is set to `:run` the commands.

This is one of the simpler Chef recipes to write, and a good way to start out. Any other startup procedures that you deem important can be added to the file by mimicking the above code pattern.

3.To test the recipe, add the LAMP stack cookbook to the Chef server:

```
$ sudo knife cookbook upload lamp_stack
Uploading lamp_stack     [0.1.0]
Uploaded 1 cookbook.
```
4.Test that the recipe has been added to the chef server:

```
knife cookbook lists
```

5.Add the recipe to your chosen node’s run list, replacing `nodename` with your node’s name:

```
knife node run_list add node2 "recipe[lamp_stack]"
```
```
node2:
  run_list: recipe[lamp_stack]
```

Because this is the default recipe, the recipe name does not need to be defined after `lamp_stack` cookbook in the code above.

6.Access your chosen node and run the `chef-client`:


## Apache

### Install and Enable

1.In your Chef workstation, Create a new file under the `~/chef-repo/cookbooks/lamp_stack/recipes` directory called `apache.rb`. This will contain all of your Apache configuration information.

2.Open the file, and define the `package resource` to install Apache:

```
package "apache2" do
  action :install
end
```
Again, this is a very basic recipe. The package resource calls to a package (`apache2`). This value must be a legitimate package name. The action is install because Apache is being installed in this step. There is no need for additional values to run the install.

3.Set Apache to enable and start at reboot. In the same file, add the additional lines of code:

```
service "apache2" do
  action [:enable, :start]
end
```
This uses the service resource, which calls on the Apache service. The `enable` action enables it upon startup, and `start` starts Apache.

Save and close the `apache.rb` file.

4.To test the Apache recipe, update the LAMP Stack recipe on the server:

```
sudo knife cookbook upload lamp_stack
```

5.Add the recipe to a node’s run-list, replacing `nodename` with your chosen node’s name:

```
knife node run_list add node2 "recipe[lamp_stack::apache]"
```

```
node2:
  run_list:
    recipe[lamp_stack]
    recipe[lamp_stack::apache]
```

Because this is not the `default.rb` recipe, the recipe name, `apache`, must be appended to the recipe value.

6.From that node, run `chef-client`:

```
sudo chef-client
```
```
YAML safe loading is not available. Please upgrade psych to a version that supports safe loading (>= 2.0).
Starting Chef Client, version 11.8.2
resolving cookbooks for run list: ["lamp_stack", "lamp_stack::apache"]
Synchronizing Cookbooks:
  - lamp_stack
Compiling Cookbooks...
Converging 3 resources
Recipe: lamp_stack::default
  * execute[update-upgrade] action run
    - execute sudo apt-get update && sudo apt-get upgrade -y

Recipe: lamp_stack::apache
  * package[apache2] action install
    - install version 2.4.7-1ubuntu4.20 of package apache2

  * service[apache2] action enable
    - enable service service[apache2]

  * service[apache2] action start (up to date)
Chef Client finished, 3 resources updated
```

If the recipe fails due to a syntax error, Chef will note it during the output.

7.After a successful `chef-client` run, check to see if Apache is running:

```
$ service apache2 status
 * apache2 is running
```

It should say that `apache2` is running.


## Configure Virtual Hosts

1.Because multiple websites may need to be configured, use Chef’s attributes feature to define certain aspects of the virtual hosts file(s). The ChefDK has a built-in command to generate the attributes directory and `default.rb` file within a cookbook. Replace `~/chef-repo/cookbooks/lamp_stack` with your cookbook’s path:

```
$ chef generate attribute ~/chef-repo/cookbooks/lamp_stack default

  * directory[/home/vagrant/chef-repo/cookbooks/lamp_stack/attributes] action create
    - create new directory /home/vagrant/chef-repo/cookbooks/lamp_stack/attributes
    - restore selinux security context
  * template[/home/vagrant/chef-repo/cookbooks/lamp_stack/attributes/default.rb] action create
    - create new file /home/vagrant/chef-repo/cookbooks/lamp_stack/attributes/default.rb
    - update content in file /home/vagrant/chef-repo/cookbooks/lamp_stack/attributes/default.rb from none to e3b0c4
    (diff output suppressed by config)
    - restore selinux security context
```

2.Within the new `default.rb`, create the default values of the cookbook:

`~/chef-repo/cookbooks/lamp_stack/attributes/default.rb`

```
default["lamp_stack"]["sites"]["example.com"] = { "port" => 80, "servername" => "cheftest.com", "serveradmin" => "cheftest@example.com" }
```

The prefix `default` defines that these are the normal values to be used in the `lamp_stack` where the site `cheftest.com` will be called upon. This can be seen as a hierarchy: Under the cookbook itself are the site(s), which are then defined by their URL.

The following values in the array (defined by curly brackets (`{}`)) are the values that will be used to configure the virtual hosts file. Apache will be set to listen on port 80 and use the listed values for its server name, and administrator email.

```
$ cd ~/chef-repo/cookbooks/lamp_stack/attributes/default.rb

default["lamp_stack"]["sites"]["example.com"] = { "port" => 80, "servername" => "example.com", "serveradmin" => "webmaster@example.com" }
default["lamp_stack"]["sites"]["example.org"] = { "port" => 80, "servername" => "example.org", "serveradmin" => "webmaster@example.org" }
```

3.Return to your `apache.rb` file under `recipes` to call the attributes that were just defined. Do this with the `node` resource:

```
#Install & enable Apache

package "apache2" do
  action :install
end

service "apache2" do
  action [:enable, :start]
end


# Virtual Hosts Files

node["lamp_stack"]["sites"].each do |sitename, data|
end
```

This calls in the values under `["lamp_stack"]["sites"]`. 

Code added to this block will be generated for each value, which is defined by the word `sitename`. 

The data value calls the values that are listed in the array of each `sitename` attribute.

4.Within the `node` resource, define a document root. This root will be used to define the public HTML files, and any log files that will be generated:

```
node["lamp_stack"]["sites"].each do |sitename, data|
  document_root = "/var/www/html/#{sitename}"
end
```

5.However, this does not create the directory itself. To do so, the `directory` resource should be used, with a `true` recursive value so all directories leading up to the `sitename` will be created. A permissions value of `0755` allows for the file owner to have full access to the directory, while group and regular users will have read and execute privileges:

```
$ vi ~/chef-repo/cookbooks/lamp_stack/apache.rb

node["lamp_stack"]["sites"].each do |sitename, data|
  document_root = "/var/www/html/#{sitename}"

  directory document_root do
    mode "0755"
    recursive true
  end

end 
```

6.The template feature will be used to generate the needed virtual hosts files. Within the `chef-repo` directory run the `chef generate template` command with the path to your cookbook and template file name defined:

```
$ chef generate template ~/chef-repo/cookbooks/lamp_stack virtualhosts

Recipe: code_generator::template
  * directory[/home/vagrant/chef-repo/cookbooks/lamp_stack/templates] action create
    - create new directory /home/vagrant/chef-repo/cookbooks/lamp_stack/templates
    - restore selinux security context
  * template[/home/vagrant/chef-repo/cookbooks/lamp_stack/templates/virtualhosts.erb] action create
    - create new file /home/vagrant/chef-repo/cookbooks/lamp_stack/templates/virtualhosts.erb
    - update content in file /home/vagrant/chef-repo/cookbooks/lamp_stack/templates/virtualhosts.erb from none to e3b0c4
    (diff output suppressed by config)
    - restore selinux security context
```

7.Open and edit the `virtualhosts.erb` file. Instead of writing in the true values for each VirtualHost parameter, use Ruby variables. Ruby variables are identified by the `<%= @variable_name %>` syntax. The variable names you use will need to be defined in the recipe file:

```
$ vi ~/chef-repo/cookbooks/lamp_stack/templates/default/virtualhosts.erb

<VirtualHost *:<%= @port %>>
        ServerAdmin <%= @serveradmin %>
        ServerName <%= @servername %>
        ServerAlias www.<%= @servername %>
        DocumentRoot <%= @document_root %>/public_html
        ErrorLog <%= @document_root %>/logs/error.log
        <Directory <%= @document_root %>/public_html>
                Require all granted
        </Directory>
</VirtualHost>
```

Some variables should look familiar. They were created in Step 2, when naming default attributes.

```
$ vi ~/chef-repo/cookbooks/lamp_stack/recipes/apache.rb

#Virtual Hosts Files

node["lamp_stack"]["sites"].each do |sitename, data|
  document_root = "/var/www/html/#{sitename}"

  directory document_root do
    mode "0755"
    recursive true
  end

  template "/etc/apache2/sites-available/#{sitename}.conf" do
    source "virtualhosts.erb"
    mode "0644"
    variables(
      :document_root => document_root,
      :port => data["port"],
      :serveradmin => data["serveradmin"],
      :servername => data["servername"]
    )
  end

end
```

The name of the template resource should be the location where the virtual host file is placed on the nodes. The `source` is the name of the template file. Mode `0644` gives the file owner read and write privileges, and everyone else read privileges. The values defined in the variables section are taken from the attributes file, and they are the same values that are called upon in the template.

9.The sites now need to be enabled in Apache, and the server restarted. This should only occur if there are changes to the virtual hosts, so the `notifies` value should be added to the `template` resource. `notifies` tells Chef when things have changed, and only then runs the commands:

```
template "/etc/apache2/sites-available/#{sitename}.conf" do
  source "virtualhosts.erb"
  mode "0644"
  variables(
    :document_root => document_root,
    :port => data["port"],
    :serveradmin => data["serveradmin"],
    :servername => data["servername"]
  )
  notifies :restart, "service[apache2]"
end
```

The `notifies` command names the `:action` to be committed, then the resource, and resource name in square brackets.

10.`notifies` can also call on `execute` commands, which will run `a2ensiteand` enable the sites we’ve made virtual hosts files for. Add the following `execute` command above the `template` resource code to create the `a2ensite` script:

```
$vi ~/chef-repo/cookbooks/lamp_stack/recipes/apache.rb

# [...]

directory document_root do
  mode "0755"
  recursive true
end

execute "enable-sites" do
  command "a2ensite #{sitename}"
  action :nothing
end

template "/etc/apache2/sites-available/#{sitename}.conf" do

# [...]
```

The `action :nothing` directive means the resource will wait to be called on. Add a new `notifies` line above the previoues `notifies` line to the `template` resource code to use it:

```
$ vi ~/chef-repo/cookbooks/lamp_stack/recipes/apache.rb

# [...]

template "/etc/apache2/sites-available/#{sitename}.conf" do
  # [...]
  notifies :run, "execute[enable-sites]"
  notifies :restart, "service[apache2]"
end

# [...]
```

11.The paths referenced in the virtual hosts files need to be created. Once more, this is done with the `directory` resource, and should be added before the final `end` tag:

```
$ vi ~/chef-repo/cookbooks/lamp_stack/recipes/apache.rb

# [...]

node["lamp_stack"]["sites"].each do |sitename, data|
  # [...]

  directory "/var/www/html/#{sitename}/public_html" do
    action :create
  end

  directory "/var/www/html/#{sitename}/logs" do
    action :create
  end
end
```

## Apache Configuration

With the virtual hosts files configured and your website enabled, configure Apache to efficiently run on your servers. Do this by enabling and configuring a multi-processing module (MPM), and editing apache2.conf.

The MPMs are all located in the `mods_available` directory of Apache. In this example the event MPM will be used, located at `/etc/apache2/mods-available/mpm_event.conf`. If we were planning on deploying to nodes of varying size we would create a template file to replace the original, which would allow for more customization of specific variables. In this instance, a cookbook file will be used to edit the file.

Cookbook files are static documents that are run against the document in the same locale on your servers. If any changes are made, the cookbook file makes a backup of the original file and replaces it with the new one.


1.To create a cookbook file navigate to `files/default` from your cookbook’s main directory. If the directories do not already exist, create them:

```
mkdir -p ~/chef-repo/cookbooks/lamp_stack/files/default/
cd ~/chef-repo/cookbooks/lamp_stack/files/default/
vi mpm_event.conf
```

2.Create a file called `mpm_event.conf` and copy the MPM event configuration into it, changing any needed values:

```
<IfModule mpm_event_module>
        StartServers        2
        MinSpareThreads     6
        MaxSpareThreads     12
        ThreadLimit         64
        ThreadsPerChild     25
        MaxRequestWorkers   25
        MaxConnectionsPerChild  3000
</IfModule>
```

3.Return to `apache.rb`, and use the `cookbook_file` resource to call the file we just created. Because the MPM will need to be enabled, we’ll use the `notifies` command again, this time to execute `a2enmod mpm_event`. Add the `execute` and `cookbook_file` resources to the `apache.rb` file prior to the final `end` tag:

```
# [...]

node["lamp_stack"]["sites"].each do |sitename, data|
  # [...]

  execute "enable-event" do
    command "a2enmod mpm_event"
    action :nothing
  end

  cookbook_file "/etc/apache2/mods-available/mpm_event.conf" do
    source "mpm_event.conf"
    mode "0644"
    notifies :run, "execute[enable-event]"
  end
end
```

4.Within the `apache2.conf` the `KeepAlive` value should be set to `off`, which is the only change made within the file. This can be altered through templates or cookbook files, although in this instance a simple `sed` command will be used, paired with the `execute` resource. Update `apache.rb` with the new `execute` resource:

```
# [...]

directory "/var/www/html/#{sitename}/logs" do
  action :create
end

execute "keepalive" do
  command "sed -i 's/KeepAlive On/KeepAlive Off/g' /etc/apache2/apache2.conf"
  action :run
end

execute "enable-event" do

# [...]
```

Your `apache.rb` is now complete.

```
$ vi

package "apache2" do
  action :install
end

service "apache2" do
  action [:enable, :start]
end

#Virtual Hosts Files

node["lamp_stack"]["sites"].each do |sitename, data|
  document_root = "/var/www/html/#{sitename}"

  directory document_root do
    mode "0755"
    recursive true
  end

  execute "enable-sites" do
    command "a2ensite #{sitename}"
    action :nothing
  end

  template "/etc/apache2/sites-available/#{sitename}.conf" do
    source "virtualhosts.erb"
    mode "0644"
    variables(
      :document_root => document_root,
      :port => data["port"],
      :serveradmin => data["serveradmin"],
      :servername => data["servername"]
    )
    notifies :run, "execute[enable-sites]"
    notifies :restart, "service[apache2]"
  end

  directory "/var/www/html/#{sitename}/public_html" do
    action :create
  end

  directory "/var/www/html/#{sitename}/logs" do
    action :create
  end

  execute "keepalive" do
    command "sed -i 's/KeepAlive On/KeepAlive Off/g' /etc/apache2/apache2.conf"
    action :run
  end

  execute "enable-event" do
    command "a2enmod mpm_event"
    action :nothing
  end

  cookbook_file "/etc/apache2/mods-available/mpm_event.conf" do
    source "mpm_event.conf"
    mode "0644"
    notifies :run, "execute[enable-event]"
  end

end
```
```
$ sudo knife cookbook upload lamp_stack
Uploading lamp_stack     [0.1.0]
Uploaded 1 cookbook.

$ knife node run_list add node2 "recipe[lamp_stack]"
node2:
  run_list:
    recipe[lamp_stack]
    recipe[lamp_stack::apache]
```

## MySQL

## Download the MySQL

1.The Chef Supermarket has an OpsCode-maintained [MySQL cookbook](https://supermarket.chef.io/cookbooks/mysql) that sets up MySQL lightweight resources/providers (LWRPs) to be used. From the workstation, download and install the cookbook:

```
knife cookbook site install mysql
```

This will also install any and all dependencies required to use the cookbook. These dependencies include the `smf` and `yum-mysql-community` cookbooks, which in turn depend on the `rbac` and `yum` cookbooks.

2.From the main directory of your LAMP stack cookbook, open the `metadata.rb` file and add a dependency to the MySQL cookbook:

```
$ vi ~/chef-repo/cookbooks/lamp_stack/metadata.rb

depends          'mysql', '~> 8.5.1'
```

3.Upload these cookbooks to the server:

```
knife cookbook upload mysql --include-dependencies
```

```
sudo knife cookbook upload lamp_stack --force
```


## Create and Encrypt Your MySQL Password

Chef contains a feature known as `data bags`. Data bags store information, and can be encrypted to store passwords, and other sensitive data.

1.On the workstation, generate a secret key:

```
openssl rand -base64 512 > ~/chef-repo/.chef/encrypted_data_bag_secret
```

2.Upload this key to your node’s `/etc/chef` directory, either manually by `scp` (an example can be found in the [Setting Up Chef](https://www.linode.com/docs/applications/configuration-management/install-a-chef-server-workstation-on-ubuntu-14-04/#add-the-rsa-private-keys) guide), or through the use of a recipe and cookbook file.

3.On the workstation, create a `mysql` data bag that will contain the file `rtpass.json` for the root password:

```
knife data bag create mysql rtpass.json --secret-file ~/chef-repo/.chef/encrypted_data_bag_secret
```
```
Created data_bag[mysql]
ERROR: RuntimeError: Please set EDITOR environment variable. See https://docs.chef.io/knife_setup.html for details.
```

```
cd ../../.chef
vi knife.rb

knife[:editor] = "/usr/bin/vim"
```

You will be asked to edit the `rtpass.json` file:

```
{
  "id": "rtpass.json",
  "password": "password123"
}
```

4.Confirm that the rtpass.json file was created:

```
$ knife data bag show mysql

rtpass.json
```

It should output `rtpass.json`. To ensure that is it encrypted, run:

```
$ knife data bag show mysql rtpass.json

WARNING: Encrypted data bag detected, but no secret provided for decoding. Displaying encrypted data.
id:       rtpass.json
password:
  auth_tag:       +EoLhhpYKrHtyrbyx9oC7g==

  cipher:         aes-256-gcm
  encrypted_data: dON+BYY9+vu0JexTVwmiGftpftiv+glLIta7tvL0

  iv:             FrD0NUPg78t4GJCr

  version:        3
```

## Set Up MySQL

With the MySQL library downloaded and an encrypted root password prepared, you can now set up the recipe to download and configure MySQL

1.Open a new file in `recipes` called `mysql.rb` and define the data bag that will be used:

`vi ~/chef-repo/cookbooks/lamp_stack/recipes/mysql.rb`

```
mysqlpass = data_bag_item("mysql", "rtpass.json")
```

2.Thanks to the LWRPs provided through the MySQL cookbook, the initial installation and database creation for MySQL can be done in one resource:

```
mysqlpass = data_bag_item("mysql", "rtpass.json")

mysql_service "mysqldefault" do
  version '5.7'
  initial_root_password mysqlpass["password"]
  action [:create, :start]
end
```

`mysqldefault` is the name of the MySQL service for this container. The `inital_root_password` calls to the value defined in the text above, while the action creates the database and starts the MySQL service.

```
sudo knife cookbook upload lamp_stack --force
knife node run_list add node2 "recipe[lamp_stack::mysql]"

node2:
  run_list:
    recipe[lamp_stack]
    recipe[lamp_stack::apache]
    recipe[lamp_stack::mysql]
```


When running MySQL from your nodes you will need to define the socket:

```
mysql -S /var/run/mysql-mysqldefault/mysqld.sock -p
```

## PHP

1.Under the recipes directory, create a new `php.rb` file. The commands below install PHP and all the required packages for working with Apache and MySQL:

```
$ vi php.rb

package "php" do
  action :install
end

package "php-pear" do
  action :install
end

package "php-mysql" do
  action :install
end
```

2.For easy configuration, the `php.ini` file will be created and used as a cookbook file, much like the MPM module above. You can either:

* Add the PHP recipe, run `chef-client` and copy the file from a node (located in `/etc/php/7.0/cli/php.ini`), or:
* Copy it from this [chef-php.ini](https://www.linode.com/docs/applications/configuration-management/creating-your-first-chef-cookbook/chef-php.ini) sample. The file should be moved to the `chef-repo/cookbooks/lamp_stack/files/default/` directory. This can also be turned into a template, if that better suits your configuration.

3.`php.ini` is a large file. Search and edit the following values to best suit your Linodes. The values suggested below are for 2GB Linodes:

```
vi ~/chef-repo/cookbooks/lamp_stack/files/default/php.ini
```

```
max_execution_time = 30
memory_limit = 128M
error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
max_input_time = 30
```

4.Return to `php.rb` and append the `cookbook_file` resource to the end of the recipe:

```
cookbook_file "/etc/php/7.0/cli/php.ini" do
  source "php.ini"
  mode "0644"
  notifies :restart, "service[apache2]"
end
```

5.Because of the changes made to `php.ini`, a `/var/log/php` directory needs to be made and its ownership set to the Apache user. This is done through a `notifies` command and execute resource, as done previously. Append these resources to the end of `php.rb`:

```
execute "chownlog" do
  command "chown www-data /var/log/php"
  action :nothing
end

directory "/var/log/php" do
  action :create
  notifies :run, "execute[chownlog]"
end
```
The PHP recipe is now done! 

6.Ensure that your Chef server contains the updated cookbook, and that your node’s run list is up-to-date. Replace nodename with your Chef node’s name:

```
$ sudo knife cookbook upload lamp_stack --force
$ knife node run_list add node2 "recipe[lamp_stack],recipe[lamp_stack::apache],recipe[lamp_stack::mysql],recipe[lamp_stack::php]"
node2:
  run_list:
    recipe[lamp_stack]
    recipe[lamp_stack::apache]
    recipe[lamp_stack::mysql]
    recipe[lamp_stack::php]
```

You have just created a LAMP Stack cookbook. Through this guide, you should have learned to use the execute, package, service, node, directory, template, cookbook_file, and mysql_service resources within a recipe, as well as download and use LWRPs, create encrypted data bags, upload/update your cookbooks to the server, and use attributes, templates, and cookbook files, giving you a strong basis in Chef and cookbook creation for future projects.