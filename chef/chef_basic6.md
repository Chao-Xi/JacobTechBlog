# Creating LAMP Chef Cookbook Analysis

## 1.Add new Client Node

```
knife bootstrap client_ip -x username -P password --sudo --use-sudo-password --node-name node2
```

```
knife client list
```

```
knife client show node_name
```

## 2.Create the Cookbook on workstation


```
cd chef-repo/cookbooks
chef generate cookbook cookbook_name
```


## 3.default recipes

### default.rb

```
execute "update-upgrade" do
  command "sudo apt-get update && sudo apt-get upgrade -y"
  action :run
end
```

### execute:

Commands are often run in combination with other Chef resources. 

Actions:

`:nothing`

Prevent a command from running. This action is used to specify that a command is run ***only when another resource notifies it***

`:run`

Default. Run a command.

**Examples:**

Commands are often run in combination with other Chef resources. The following example shows the template resource run with the execute resource to add an entry to a LDAP Directory Interchange Format (LDIF) file:

```
execute 'slapadd' do
  command 'slapadd < /tmp/something.ldif'
  creates '/var/lib/slapd/uid.bdb'
  action :nothing
end

template '/tmp/something.ldif' do
  source 'something.ldif'
  notifies :run, 'execute[slapadd]', :immediately
end

```

### Upload to the chef server and upload to client

```
sudo knife cookbook upload cookbook_name
knife cookbook lists

knife node run_list add node_name "recipe[cookbook_name]"
```

## 3.Install Apache and Configuration

### apache.rb

package: [https://docs.chef.io/resource_package.html](https://docs.chef.io/resource_package.html)

```
package "apache2" do
  action :install
end

service "apache2" do
  action [:enable, :start]
end
```

Add  the new recipe to the chef node

```
knife node run_list add node2 "recipe[lamp_stack::apache]"
```

On the chef node

```
sudo chef-client
```


## 4.Configure Virtual Hosts

### Add attributes

```
chef generate attribute ~/chef-repo/cookbooks/lamp_stack default
```

### attributes/default.rb

```
default["lamp_stack"]["sites"]["example.com"] = { "port" => 80, "servername" => "example.com", "serveradmin" => "webmaster@example.com" }
default["lamp_stack"]["sites"]["example.org"] = { "port" => 80, "servername" => "example.org", "serveradmin" => "webmaster@example.org" }
```

**loop the attributes**

```
node["lamp_stack"]["sites"].each do |sitename, data|
end
```

```
sitename => ["example.com"] ["example.org"]
datat    => { "port" => 80, "servername" => "example.com", "serveradmin" => "webmaster@example.com" }
```


```
node["lamp_stack"]["sites"].each do |sitename, data|

  document_root = "/var/www/html/#{sitename}"

  directory document_root do
    mode "0755"
    recursive true
  end

end 
```

### Add template

```
chef generate template ~/chef-repo/cookbooks/lamp_stack virtualhosts
```

### templates/default/virtualhosts.erb

```
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
The name of the template resource should be the location where the virtual host file is placed on the nodes. The source is the name of the template file. `Mode 0644 ` gives the file owner read and write privileges, and everyone else read privileges. The values defined in the variables section are taken from the attributes file, and they are the same values that are called upon in the template

## Apache Configuration for Virtual host

**configuring a multi-processing module (MPM)**

```
/files/default/mpm_event.conf
```

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

### **apache.rb**


```
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


## MySQL

```
knife cookbook site install mysql
```

**add dependency**


```
vi ~/chef-repo/cookbooks/lamp_stack/metadata.rb

depends          'mysql', '~> 8.5.1
```

```
knife cookbook upload mysql --include-dependencies
sudo knife cookbook upload lamp_stack --force
```


## Create and Encrypt Your MySQL Password

On the workstation, create a **mysql data bag** that will contain the file `rtpass.json` for the root password


```
openssl rand -base64 512 > ~/chef-repo/.chef/encrypted_data_bag_secret
knife data bag create mysql rtpass.json --secret-file ~/chef-repo/.chef/encrypted_data_bag_secret
```

**vi knife.rb **

```
knife[:editor] = "/usr/bin/vim"
```

**vi rtpass.json **

```
{
  "id": "rtpass.json",
  "password": "password123"
}
```

```
$ knife data bag show mysql

rtpass.json

$ knife data bag show mysql rtpass.json
```

## Set Up MySQL

### mysql.rb

```
mysqlpass = data_bag_item("mysql", "rtpass.json")

mysql_service "mysqldefault" do
  version '5.7'
  initial_root_password mysqlpass["password"]
  action [:create, :start]
end
```

```
sudo knife cookbook upload lamp_stack --force
knife node run_list add node2 "recipe[lamp_stack::mysql]"
```

## PHP

```
vi php.rb

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

The file will be put on node 

**files/default/php.ini**

```
max_execution_time = 30
memory_limit = 128M
error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
max_input_time = 30
```

### php.rb

```
package "php" do
  action :install
end

package "php-pear" do
  action :install
end

package "php-mysql" do
  action :install
end

cookbook_file "/etc/php/7.0/cli/php.ini" do
  source "php.ini"
  mode "0644"
  notifies :restart, "service[apache2]"
end

execute "chownlog" do
  command "chown www-data /var/log/php"
  action :nothing
end

directory "/var/log/php" do
  action :create
  notifies :run, "execute[chownlog]"
end
```



