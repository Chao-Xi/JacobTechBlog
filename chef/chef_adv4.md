# Chef Roles 


A role is a way to define certain patterns and processes that exist across nodes in an organization as belonging to a single job function. 

* Each role consists of zero (or more) attributes and a run-list. 
* Each node can have zero (or more) roles assigned to it. 



## Why Chef roles

Every organizations has serves to to specific things, some server act as database servers, some server act as load balancer, some servers act as HTTP server. Servers act differently and how you define what you do.

**Chef server does you define the role for that server, the definition for a server role is definition that you use a role for your server** 

**Servers can have multiple roles depending on where they're at, for example you may have different environments where you know work as an HTTP server at a development environment but maybe an actual database server at a production or a test environment, so you define what your server does or what role of your server**

## Role Attributes

At the beginning of a chef-client run, all attributes except for normal attributes are reset. The chef-client rebuilds them using automatic attributes collected by Ohai at the beginning of the chef-client run and then using default and override attributes that are specified in cookbooks or by roles and environments. All attributes are then merged and applied to the node according to attribute precedence. At the conclusion of the chef-client run, the attributes that were applied to the node are saved to the Chef server as part of the node object.


### For example

#### A role called webserver and defined by JSON file

```
{
  "name": "webserver",
  "default_attributes" : {
     "greeting" : "My greeting"
  }  
},
"run_list": [
  "receipe[apache]"
]
}

```

Here we create a role which name is webserver, we set a default Apache attribute, and we set a run list in this specific role and run it, it does apply the apache cookbook to the chef client


```
$ knife role from file webserver.json
Update Role Websrver
```

```
$ knife node show nodename
...
```

```
$ knife node run list remove nodename 'recipe[apache]'

```

```
$ knife node run list add nodename 'role[webserver']
```



## Role Formats

Role data is stored in two formats: as a **Ruby file** that contains d**omain-specific language** and as **JSON data**.


### Ruby DSL

A Ruby DSL file for each role must exist in the `roles/` subdirectory of the chef-repo. (If the repository does not have this subdirectory, then create it using knife.) Each Ruby file should have the `.rb` suffix. The complete roles Ruby DSL has the following syntax:

```
name "role_name"
description "role_description"
run_list "recipe[name]", "recipe[name::attribute]", "recipe[name::attribute]"
env_run_lists "name" => ["recipe[name]"], "environment_name" => ["recipe[name::attribute]"]
default_attributes "node" => { "attribute" => [ "value", "value", "etc." ] }
override_attributes "node" => { "attribute" => [ "value", "value", "etc." ] }
```

* **run_list**: A list of recipes and/or roles to be applied and the order in which they are to be applied
* **env_run_lists**	: Optional. A list of environments, each specifying a recipe or a role to be applied to that environment. 

```
env_run_lists 'prod' => ['recipe[apache2]'],
              'staging' => ['recipe[apache2::staging]'
```

* **default_attributes**: Optional. **A set of attributes to be applied to all nodes, assuming the node does not already have a value for the attribute**. This is useful for setting global defaults that can then be overridden for specific nodes

```
default_attributes 'apache2' => {
  'listen_ports' => [ '80', '443' ]
}
```

* **override_attributes**： Optional. **A set of attributes to be applied to all nodes, even if the node already has a value for an attribute**. This is useful for ensuring that certain attributes always have specific values. If more than one role attempts to set an override value for the same attribute, the last role applied wins

```
override_attributes(
  :apache2 => {
    :prefork => { :min_spareservers => '5' }
  },
  :tomcat => {
    :worker_threads => '100'
  }
)
```

### JSON

The JSON format for roles maps directly to the domain-specific Ruby format: same settings, attributes, and values, and a similar structure and organization. For example

```
{
  "name": "webserver",
  "chef_type": "role",
  "json_class": "Chef::Role",
  "default_attributes": {
    "apache2": {
      "listen_ports": [
        "80",
        "443"
      ]
    }
  },
  "description": "The base role for systems that serve HTTP traffic",
  "run_list": [
    "recipe[apache2]",
    "recipe[apache2::mod_ssl]",
    "role[monitor]"
  ],
  "env_run_lists" : {
    "production" : [],
    "preprod" : [],
    "dev": [
      "role[base]",
      "recipe[apache]",
      "recipe[apache::copy_dev_configs]",
    ],
    "test": [
      "role[base]",
      "recipe[apache]"
    ]
  },
  "override_attributes": {
    "apache2": {
      "max_children": "50"
    }
  }
}
```

## Manage Roles

* knife can be used to **create**, **edit**, **view**, **list**, **tag**, and **delete** roles.
* The Chef management console add-on can be used to create, edit, view, list, tag, and delete roles. In addition, role attributes can be modified and roles can be moved between environments.

```
knife search node "role:role_name AND learn_client_id:learn_client_id" -a run_list -c “/root/chef/client-ip-knife.rb
```









