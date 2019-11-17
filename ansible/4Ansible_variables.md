# Ansible Variable Management 

## 1. Jinja and templates

**template – Template a file out to a remote server**


Templates are processed by the [Jinja2 templating language](https://jinja.palletsprojects.com/en/2.10.x/).

`task2-8jinja2.yaml`

```
---
- hosts: all
  tasks:
  - name: deploy a simple template file
    template:
      src: templates/2-8-template.j2
      dest: $HOME/tmp/2-8-template.txt
    tags:
      - create
  - name: remove templated file
    file:
      dest: $HOME/tmp/2-8-template.txt
      state: absent
    tags:
      - destroy
```


`templates/2-8-template.j2`

```
This file is a template on {{hostvars[inventory_hostname]['ansible_fqdn']}}
backup_file {% if backup_file is defined %} is defined {% else %} is not defined {% endif %}
```
```
$ ansible-playbook -i ../inventory.ini task2-8jinja2.yaml --tags create

TASK [deploy a simple template file] *****************************************************
changed: [githost]
changed: [k8s-jx]
changed: [k8s-jx2]
changed: [k8s-jx1]

PLAY RECAP *******************************************************************************
githost                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx1                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx2                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

**jabox**

```
This file is a template on jabox
backup_file  is not defined
```

**jabox-node1**

```
This file is a template on jabox-node1
backup_file  is not defined
```

**jabox-node2**

```
This file is a template on jabox-node2
backup_file  is not defined
```

```
ansible-playbook -i ../inventory.ini task2-8jinja2.yaml --tags destroy
```


## 2. Host facts for `conditional` execution

```
---
- hosts: web
  tasks:
  - name: create
    file:
      dest: $HOME/tmp/k8s-master-on-githost 
      state: '{{file_state}}'
    when: hostvars[inventory_hostname]['inventory_hostname'] == 'githost'  #where the file gonna be created

  - name: create
    file:
      dest: $HOME/tmp/githost-on-k8s-master
      state: '{{file_state}}'
    when: inventory_hostname == 'k8s-jx' #where the file gonna becreated
```

### `Conditionals`

Sometimes you will want to skip a particular step on a particular host. This could be something as simple as not installing a certain package if the operating system is a particular version, or it could be something like performing some cleanup steps if a filesystem is getting full.

**This is easy to do in Ansible with the when clause, which contains a raw `Jinja2 expression` without double curly braces. It’s actually pretty simple:**

```
---
- hosts: web
  tasks:
  - name: create
    file:
      dest: $HOME/tmp/k8s-master-on-githost 
      state: '{{file_state}}'
    when: hostvars[inventory_hostname]['inventory_hostname'] == 'githost'  #where the file gonna be created

  - name: create
    file:
      dest: $HOME/tmp/githost-on-k8s-master
      state: '{{file_state}}'
    when: inventory_hostname == 'k8s-jx' #where the file gonna becreated
```


* `when: hostvars[inventory_hostname]['inventory_hostname']` 
* `when: inventory_hostname == 'k8s-jx'`

```
ansible -m debug -i ../inventory.ini -a "var=hostvars['k8s-jx1']" k8s-jx2
```

### debug module

This is information that I could use on the `k8s-jx2` host, basically in `k8s-jx2` host plays, but that's coming from `k8s-jx1`. gather `k8s-jx2` fact from all ther machine

```
ansible-playbook -i ../inventory.ini task2-9fact.yaml -e file_state=touch
```

```
TASK [create] ****************************************************************************************
skipping: [k8s-jx]
changed: [githost]

TASK [create] ****************************************************************************************
skipping: [githost]
changed: [k8s-jx]

PLAY RECAP *******************************************************************************************
githost                    : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
k8s-jx                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0  
```

* On `githost`: `k8s-master-on-githost`
* On `k8s-master`: `githost-on-k8s-master`


```
ansible-playbook -i ../inventory.ini task2-9fact.yaml -e file_state=absent
```

## 3. Looping tasks with variable lists

`task2-10loopvar.yaml`

```
---
- hosts: all
  vars:
    packages: [git,vim,ruby]
  tasks:
  - name: install packages for Debian style OSs
    apt:
      name: '{{item}}'
      state: '{{pkg_state}}'
    with_items: '{{packages}}'
    when: ansible_os_family == "Debian"
    sudo: yes
    tags:
      - handle-pkg

  - name: install pacakges for Redhat style OSs
    yum:
      name: '{{item}}'
      state: '{{pkg_state}}'
    with_items: '{{packages}}'
    when: ansible_os_family == "RedHat"
    sudo: yes
    tags:
      - handle-pkg

  - name: create files based on package names
    file:
      dest:  $HOME/tmp/{{item}}
      state: '{{file_state}}'
    with_items: '{{packages}}'
    when: ansible_os_family == "RedHat"
    tags:
      - handle-files
```

```
$ ansible-playbook -i ../inventory.ini task2-10loopvar.yaml -e file_state=touch -e  pkg_state=latest
$ ansible-playbook -i ../inventory.ini task2-10loopvar.yaml -e file_state=absent -e  pkg_state=absent

$ ansible-playbook -i ../inventory.ini task2-10loopvar.yaml --skip-tags handle-pkg --tags handle-files -e file_state=absent
```


* ansible list variable

```
vars:
    packages: [git,vim,ruby]
```

* Loops in ansible

`with_items` is replaced by `loop` and the `flatten` filter.

`loop: "{{ items|flatten(levels=1) }}"`

```
with_items: '{{packages}}'
```

*  `ansible_os_family`

[https://riptutorial.com/ansible/example/12268/-when--condition----ansible-os-family--lists](https://riptutorial.com/ansible/example/12268/-when--condition----ansible-os-family--lists)

* when: ansible_os_family == "CentOS"
* when: ansible_os_family == "Redhat"
* when: ansible_os_family == "Darwin"
* when: ansible_os_family == "Debian"
* when: ansible_os_family == "Windows"

* `sudo: yes`

[https://docs.ansible.com/ansible/latest/user_guide/become.html#understanding-privilege-escalation](https://docs.ansible.com/ansible/latest/user_guide/become.html#understanding-privilege-escalation)


* `apt.state:` and `yum.state:`

yum state:  `absent`, `installed`, `latest`,  `present`, `removed`

Whether to install (`present` or `installed`, `latest`), or remove (`absent` or `removed`) a package.

> `present` and `installed` will simply ensure that a desired package is installed.
> 
> `latest` will update the specified package if it's not of the latest available version.
> 
> `absent` and removed will remove the specified package.
> 
> `Default` is None, however in effect the default action is present unless the autoremove option is enabled for this module, then `absent` is inferred.

```
# [DEPRECATION WARNING]: Invoking "apt" only once while using a loop via squash_actions is deprecated. Instead of using a loop to supply multiple 
# items and specifying `name: "{{item}}"`, please use `name: '{{packages}}'` and remove the loop. This feature will be removed in version 2.11. 
# Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.

- name: "Install dependencies"
  apt:
    pkg:
      - libnss3
      - libasound2
      - xcb
      - xinit
    state: present
```

## 4. Looping tasks with dictionaries

```
---
- hosts: all
  vars:
    animals:
      cats:
        tabby:
          color: grey
          persnickityness: high
        calico:
          color: orange
          persnickityness: medium
      dogs:
        doberman:
          color: black
          persnickityness: extreme
        retriever:
          color: golden
          persnickityness: low
  tasks:
  - name: iterate over animal array
    file:
      name: '$HOME/tmp/{{item.key}}-{{item.value.color}}'
      state: '{{file_state}}'
    with_dict: '{{animals.cats}}'

  - name: iterate over animals array
    file:
      name: '$HOME/tmp/{{item.key}}-{{item.value.color}}'
      state: '{{file_state}}'
    with_dict: '{{animals.dogs}}'
    when: 'item.value.persnickityness == "low"'
```

* dictionary variable

```
vars:
  animals:
    cats:
      ...
    dogs:
      ...
```

* **dict key and value**: `{{item.key}}-{{item.value.color}}'`
     
* `with_dict: '{{animals.cats}}`
* `with_dict: '{{animals.dogs}}'`
* `when: 'item.value.persnickityness == "low"'`

```
$ ansible-playbook -i ../inventory.ini task2-11loopdict.yaml -e file_state=touch
$ ansible-playbook -i ../inventory.ini task2-11loopdict.yaml -e file_state=absent
```

Alphabetical order

```
calico-orange
retriever-golden
tabby-grey
```

## 5. Looping in templates with variable lists

```
---
- hosts: all
  vars:
    packages: [git,vim,ruby]
  tasks:
  - name: deploy a template file with a loop
    template:
      src: templates/2-12-template.j2
      dest: $HOME/tmp/2-12-template.txt
    tags:
      - create
  - name: remove the templated file
    file:
      dest: $HOME/tmp/2-12-template.txt
      state: absent
    tags:
      - destroy
```

`templates/2-12-template.j2`

```
We are on host {{inventory_hostname}}
We installed: {% for package in packages %}{{package}}{% if not loop.last %}, {% endif %}{% endfor %}
```

```
ansible-playbook -i ../inventory.ini task2-12looptemplist.yaml --tags create
ansible-playbook -i ../inventory.ini task2-12looptemplist.yaml --tags absent
```
```
We are on host k8s-jx
We installed: git, vim, ruby

We are on host githost
We installed: git, vim, ruby
```

## 6. Looping in templates with dictionaries

```
---
- hosts: all
  vars:
    animals:
      cats:
        tabby:
          color: grey
          persnickityness: high
        calico:
          color: orange
          persnickityness: medium
      dogs:
        doberman:
          color: black
          persnickityness: extreme
        retriever:
          color: golden
          persnickityness: low
  tasks:
  - name: deploy a dictionary looping template file
    template:
      src: templates/2-13-template.j2
      dest: $HOME/tmp/2-13-template.txt
    tags:
      - create
  - name: remove the templated file
    file:
      dest: $HOME/tmp/2-13-template.txt
      state: absent
    tags:
      - destroy
```

`templates/2-13-template.j2`

```
We are in groups: {% for group in hostvars[inventory_hostname]['group_names'] %}{{group}}{% if not loop.last %}, {% endif %}{% endfor %}

We like both {% for key,value in animals.items() %}{{key}}{% if not loop.last %} and {% endif %}{% endfor %}

W{% for key,value in animals.items() %}e like{% for animal,name in animals[key].items() %} {{name.color}} {{animal}}s{% if not loop.last %} and{% endif %}{% endfor %}{% if not loop.last %} and w{% endif %}{% endfor %}
```

```
$ ansible-playbook -i ../inventory.ini task2-13looptempdict.yaml --tags create
$ ansible-playbook -i ../inventory.ini task2-13looptempdict.yaml --tags destroy

# k8s-jx
# We are in groups: k8s_master, k8s_servers, web
# We like both cats and dogs
# We like grey tabbys and orange calicos and we like black dobermans and golden retrievers

# githost
# We are in groups: githost_servers, web
# We like both cats and dogs
# We like grey tabbys and orange calicos and we like black dobermans and golden retrievers

# k8s-jx1
# We are in groups: db, k8s_servers
# We like both cats and dogs
# We like grey tabbys and orange calicos and we like black dobermans and golden retrievers

# k8s-jx2
# We are in groups: backup, db, k8s_servers
# We like both cats and dogs
# We like grey tabbys and orange calicos and we like black dobermans and golden retrievers
```

## 7. Testing plays with check mode


> 2-14 Check mode Check Mode (“Dry Run”)

> When ansible-playbook is executed with `--check` it will not make any changes on remote systems. 

> check s a way of validating that our ansible is actually valid in advance of impacting our systems.
> 
> 
