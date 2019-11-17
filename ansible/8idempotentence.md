# Idempotentence with Ansible play

```
$ tree .
.
├── create.yml
├── files
│   └── idempotent.txt
├── idempotent.yml
└── state.yml

1 directory, 4 files
```

## Idempotent "prototype" model

```
---
- hosts: k8s_master
  tasks:
  - name: an idempotent create command
    copy:
      src: files/idempotent.txt
      dest: $HOME/tmp/idempotent.txt
    tags:
      - create
  - name: an idempotent command
    lineinfile:
      dest: $HOME/tmp/idempotent.txt
      regexp: '^(.*)is an(.*)$'
      backrefs: true
      line: '\1is really an\2'
    tags:
      - create
  - name: a non idempotent command
    shell: "echo this is a non-idempotent file >> $HOME/tmp/non-idempotent.txt"
    tags:
      - create

  - name: remove the file we created
    file:
      path: $HOME/tmp/{{ item }}
      state: absent
    with_items:
    - non-idempotent.txt
    - idempotent.txt
    tags:
      - destroy
```

```
$ ansible-playbook -i ../inventory.ini idempotent.yml --tags create
```

#### `lineinfile` – Manage lines in text files

* This module ensures a particular line is in a file, or replace an existing line using a back-referenced regular expression.
* This is primarily useful when you want to change a single line in a file only.
* `regexp`: The regular expression to look for in every line of the file.
* `backrefs: true`: If set, `line` can contain backreferences (both positional and named) that will get populated if the `regexp` matches.
* `line`: The line to insert/replace into the file.


#### After run twice and check non-idempotent file

```
$ cat non-idempotent.txt
this is a non-idempotent file
this is a non-idempotent file
```

#### #### After run twice and check idempotent file

```
$ cat idempotent.txt
this is really an idempotent file
```

### Remove multiple files inside directory

```
- name: remove the file we created
    file:
      path: $HOME/tmp/{{ item }}
      state: absent
    with_items:
    - non-idempotent.txt
    - idempotent.txt
    tags:
      - destroy
```

```
$ ansible-playbook -i ../inventory.ini idempotent.yml --tags destroy
TASK [remove the file we created] **********************************************************************
changed: [k8s-jx] => (item=non-idempotent.txt)
changed: [k8s-jx] => (item=idempotent.txt)
```

## Registering discovered state

```
- hosts: k8s_master
  vars:
    target: $HOME/tmp/idempotent.txt
  tasks:
  - name: an idempotent create command
    copy:
      src: files/idempotent.txt
      dest: '{{target}}'
    tags:
      - create

  - name: modify the file
    command: sed -ie 's/is an/is really an/' {{target}}
    tags:
      - create

  - name: remove the file
    file:
       path: '{{target}}'
       state: absent
    tags:
      - destroy
    
  - name: remove the backup file
    file:
       path: $HOME/tmp/idempotent.txte
       state: absent
    tags:
      - destroy

  - name: discover state
    command: grep 'is really an' {{target}}
    register: grep_state
    tags:
      - create
      - destroy
    ignore_errors: true

  - name: show the state of the file
    debug:
      var: grep_state.rc
    tags:
      - create
      - destroy
```

### `sed -ie`

* `-i[SUFFIX]`(-ie) 

Edit files in place **(this makes a backup with file extension SUFFIX, if SUFFIX is supplied)**.

#### After run `modify the file`, generate a new backup file `idempotent.txte`

### `register` and `debug`

```
register: grep_state
```
```
debug:
	var: grep_state.rc
```

When you execute a task and save the return value in a variable for use in later tasks, you create a registered variable.

### Ignoring Failed Commands

Generally playbooks will stop executing any more steps on a host that has a task fail. Sometimes, though, you want to continue on. To do so, write a task that looks like this:

```
ignore_errors: true
```

### `grep_state` return true after create

```
ansible-playbook -i ../inventory.ini state.yml --tags create

TASK [show the state of the file] ********************************************************************
ok: [k8s-jx] => {
    "grep_state.rc": "0"
}
```

### `grep_state` return false after destroy

```
$ ansible-playbook -i ../inventory.ini state.yml --tags destroy

TASK [show the state of the file] ********************************************************************
ok: [k8s-jx] => {
    "grep_state.rc": "2"
}
```

## Creating an idempotent play

```
---
- hosts: k8s_master
  vars:
    target: $HOME/tmp/idempotent.txt
  tasks:
  - name: discover state
    command: grep 'is really an' {{target}}
    register: grep_state
    tags:
      - create
      - destroy
    ignore_errors: true

  - name: show the state of the file
    debug:
      var: grep_state.rc

  - name: an idempotent create command
    copy:
      src: files/idempotent.txt
      dest: '{{target}}'
    when: grep_state.rc != 0
    tags:
      - create
      - destroy

  - name: modify the file
    command: sed -ie 's/is/is really an/' {{target}}
    when: grep_state.rc != 0
    tags:
      - create
      - destroy

  - name: remove the file
    file:
      path: '{{target}}'
      state: absent
    tags:
      - destroy
  
  - name: remove the backup file
    file:
       path: $HOME/tmp/idempotent.txte
       state: absent
    tags:
      - destroy
```

1. Check the state of file
2. Show the state of the file
3. Create and modify file when `grep_state` is fasle
4. delete both


**So after first run, the task `an idempotent create command` and `modify the file` will skip**

