# Task Execution management

## 1. Defining task execution with host groups

```
---
- hosts: all
  tasks:
  - name: create tmp folder on all servers
    file:
      dest: $HOME/tmp/
      state: directory


- hosts: all
  tasks:
  - name: create a file on a remote machine
    file:
      dest: $HOME/tmp/file
      state: '{{file_state}}'

- hosts: web
  tasks:
  - name: create file on web machines
    file:
      dest: $HOME/tmp/web-file
      state: '{{file_state}}'

- hosts: all:!db
  tasks:
  - name: create file on web machines
    file:
      dest: $HOME/tmp/web-not-db-file
      state: '{{file_state}}'

- hosts: all:&backup:!web
  tasks:
  - name: create file on web machines
    file:
      dest: $HOME/tmp/backup-file
      state: '{{file_state}}'

# operators '& and' and '! not'
# Set "file_state" as variable passed in  '{{file_state}}'
```

### 1.`file.state: directory`

If directory, all intermediate subdirectories will be created if they do not exist. Since Ansible 1.7 they will be created with the supplied permissions.

### 2.`file.state: '{{file_state}}'`

* File module: [https://docs.ansible.com/ansible/latest/modules/file_module.html#file-module](https://docs.ansible.com/ansible/latest/modules/file_module.html#file-module)

* once with the **state of touch**, create this file if it doesn't exist
* Seoncd time, we'll run it with the **state of absent**

### 3.`hosts: all:!db` and `all:&backup:!web`

* operators `'& and'` and `'! not'`
* Set "file_state" as variable passed in  `'{{file_state}}'`

### Touch file

```
#!/bin/bash
ansible-playbook -i ../inventory.ini task2-1.yaml -e file_state=touch
```

* `-e` **EXTRA_VARS**, set additional variables as `key=value` or `YAML/JSON`, if filename prepend with `@`

* If `touch` (new in 1.4), an empty file will be created if the `path` does not exist, while an existing file or directory will receive updated file access and modification times, (similar to the way `touch` works from the command line).

### Delete file

```
#!/bin/bash
ansible-playbook -i ../inventory.ini task2-1.yaml -e file_state=absent
```

* **If `absent`, directories will be recursively deleted, and files or symlinks will be unlinked.** 

* Note that `absent` will not cause `file` to fail if the path does not exist as the state did not change.


## 2. Using tags to limit play execution

**task2-2-tag.yaml**

```
---
- hosts: all
  tasks:
  - name: create a file
    file:
      dest: $HOME/tmp/file
      state: touch
    tags:
      - create-file

- hosts: all:k8s_servers:!db
  tags:
    - delete-file
  tasks:
  - name: delete a file
    file:
      dest: $HOME/tmp/file
      state: absent

- hosts: web:githost
  tasks:
  - name: delete a file
    file:
      dest: /tmp/file
      state: absent
    tags:
      - delete-file

- hosts: all
  tags:
    - list-file
  tasks:
  - name: Recursively find /tmp files
    find:
      paths: $HOME/tmp/
      recurse: yes
    register: all_files

  - debug:
      msg: "{{ all_files.files[0].path }}"
```

### Add tags 

```
- name: delete a file
  file:
    dest: $HOME/tmp/file
    state: absent

tags:
  - create-file
```

```
- hosts: all:k8s_servers:!db
  tags:
    - delete-file
```

### Take advantage tags

```
$ ansible-playbook -i ../inventory.ini task2-2-tag.yaml --skip-tags create-file --tags delete-file
```

```
$ ansible-playbook -i ../inventory.ini task2-2-tag.yaml --tags create-file


PLAY RECAP *********************************************************************************************************************************************
githost                    : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx1                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx2                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```



**Tags**

When you execute a playbook, you can filter tasks based on tags in two ways:

On the command line, with the `--tags` or `--skip-tags` options

```
ansible-playbook -i ../inventory.ini task2-2-tag.yaml --skip-tags create-file --tags delete-file
```

*  `--tags` or `--skip-tags` can be **used both or just one**


### List files in directory

```
- hosts: all
  tags:
    - list-file
  tasks:
  - name: Recursively find /tmp files
    find:
      paths: $HOME/tmp/
      recurse: yes
    register: all_files

  - debug:
      msg: "{{ all_files.files[0].path }}"
```

**Show output**

```
- debug:
      msg: "{{ all_files.files[0].path }}"
```

```

TASK [debug] *******************************************************************************************************************************************
ok: [githost] => {
    "msg": "/home/vagrant/tmp/file"
}
ok: [k8s-jx] => {
    "msg": "/home/vagrant/tmp/file"
}
ok: [k8s-jx1] => {
    "msg": "/home/vagrant/tmp/file"
}
ok: [k8s-jx2] => {
    "msg": "/home/vagrant/tmp/file"
}

PLAY RECAP *********************************************************************************************************************************************
githost                    : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx                     : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx1                    : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
k8s-jx2                    : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```


## 3. Executing tasks on localhost

### You dont have to create host for `localhost` in`inventory.ini` 

```
---
- hosts: localhost
  tasks:
  - name: Create a file via ssh connection
    file:
      dest: $HOME/Devops_sap/ansible/code/task2/2-3ssh-created
      state: touch

- hosts: localhost
  connection: local

  tasks:
  - name: Create a file via sdirect local connection
    file:
      dest: $HOME/Devops_sap/ansible/code/task2/2-3direct-created
      state: touch
```

## 4. Limiting plays from the command line

```
---
- hosts: all
  tasks:
  - name: the first task
    file:
      dest: $HOME/tmp/first-task
      state: '{{file_state}}'
  - name: the second task
    file:
      dest: $HOME/tmp/second-task
      state: '{{file_state}}'
  - name: the last task
    file:
      dest: $HOME/tmp/last-task
      state: '{{file_state}}'
```

### execute from `Start` and `Step` by **name**

```
$ ansible-playbook -i ../inventory.ini task2-4-limit.yaml -e file_state=touch --start-at-task='the second task'
```

```
$ ansible-playbook -i ../inventory.ini task2-4-limit.yaml -e file_state=touch --start-at-task='the second task'
```

**`--start-at-task='the second task'`**


## 5. Specifying variables via inventory

When we start an Ansible run, one of the very first things that we see is that Ansible wants to gather facts from a host. This is effectively a set of variables that we can consume in our playbooks to make certain actions happen on a host-by-host basis. 

A very powerful tool. We also find though that sometimes we want to pass specific variables on a **host-by-host** or **group-by-group** basis, sort of extending the function of what the inventory provides.

### `2-5-invetory.ini`

```
...

[backup]
k8s-jx2 backup_file=$HOME/tmp/backup_file

[all:vars]
all_file=$HOME/tmp/all_file

[web:vars]
web_file=$HOME/tmp/web_file
```

* `[all:vars]`
* `[web:vars]`


### `task2-5-var.yaml`

```
---
- hosts: web
  tasks:
  - name: create a web file
    file:
      dest: '{{web_file}}'
      state: '{{file_state}}'

- hosts: backup
  tasks:
  - file:
      dest: '{{backup_file}}'
      state: '{{file_state}}'


- hosts: db
  tasks:
  - file:
      dest: '{{db_file}}'
      state: '{{file_state}}'
    when: db_file is defined 

- hosts: all
  tasks:
  - file:
      dest: '{{all_file}}'
      state: '{{file_state}}'
```

### when

`when: db_file is defined `

* Sometimes you will want to skip a particular step on a particular host. 
This could be something as simple as not installing a certain package if the operating system is a particular version, or it could be something like performing some cleanup steps if a filesystem is getting full.


*  **check db_file is defined**: https://medium.com/opsops/is-defined-in-ansible-d490945611ae

### Run the command 

```
$ ansible-playbook -i ../2-5-inventory.ini task2-5-var.yaml -e file_state=touch
$ ansible-playbook -i ../2-5-inventory.ini task2-5-var.yaml -e file_state=absent
```

#### Becasue the `db_file` is not defined

```
TASK [file] *************************************************************************
skipping: [k8s-jx1]
skipping: [k8s-jx2]

...

k8s-jx1   : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
k8s-jx2   : ok=5    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0  
```