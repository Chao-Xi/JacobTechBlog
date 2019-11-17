# Ansible Overview, Install(MacOs) and Environment Setup

## Ansible Overview

* Ansible is designed to automate systems management tasks (modifying and managing a configuration file, for example) 
* Allows creation of idempotent scripts 


## Ansible Basic

* Ansible "programs" are called plays, and are a collection of tasks in a playbook 

```
---
- hosts: all 
  tasks: 
  - name: Do something 
    module: 
      parameter: value 
      parameter: '{{variable}}'
```
 
* Plays are run against target hosts defined in an inventory 

```
[web] 
web1 ansible_ssh_host=web1.example.com variable=value 
web2 ansible_ssh_host=web2.example.com variable=value2
```  
  
## Ansible Install

`https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#basics-what-will-be-installed`


### brew

```
$ brew install ansible
```

### pip

```
$ pip3 search ansible
$ pip3 install ansible==2.8.4
```

```
$ ansible --version
ansible 2.8.4
  config file = None
  configured module search path = ['/Users/i515190/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.7.4 (default, Jul  9 2019, 18:13:23) [Clang 10.0.1 (clang-1001.0.46.4)]
```

## Environment Setup

[Working with Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

**`default inventory`(`/etc/ansible/hosts`)**

**You can specify a different inventory file using the `-i <path>` option on the command line.**

### `inventory.ini` for all roles and servers

```
[all:children]
githost_servers
k8s_servers
# [DEPRECATION WARNING]: The TRANSFORM_INVALID_GROUP_CHARS settings is set to allow bad characters in group names by default
# dont use "-" dash as "group name"
# "." dot and "_" underline are working fine
[githost_servers]
githost ansible_ssh_host=192.168.33.10 

[k8s_servers]
k8s-jx  ansible_ssh_host=10.151.30.11
k8s-jx1 ansible_ssh_host=10.151.30.22
k8s-jx2 ansible_ssh_host=10.151.30.23

[k8s_servers:vars]
ansible_ssh_user=vagrant

[githost_servers:vars]
ansible_ssh_user=vagrant

[web]
githost
k8s-jx

[db]
k8s-jx1
k8s-jx2

[backup]
k8s-jx2


# [servers:vars]
# ansible_python_interpreter=/usr/local/bin/python3
```

#### Hosts and group

```
[githost_servers]
githost ansible_ssh_host=192.168.33.10 

[k8s_servers]
k8s-jx  ansible_ssh_host=10.151.30.11
k8s-jx1 ansible_ssh_host=10.151.30.22
k8s-jx2 ansible_ssh_host=10.151.30.23
```

#### group and variable

```
[k8s_servers:vars]
ansible_ssh_user=vagrant

[githost_servers:vars]
ansible_ssh_user=vagrant
```

#### groups and groups

* all group (because it is the ‘parent’ of all other groups)
* parent group
* child group
* host


```
[all:children]
githost_servers
k8s_servers
```

### `ad-hoc.sh`

```
#!/bin/bash
ansible -m ping -i ../inventory.ini all
# ansible -m ping -i ../inventory web1 -u vagrant
```

```
k8s-jx1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
k8s-jx | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
githost | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
k8s-jx2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```








