# Working with Secrets

* Creating a secrets vault
* Using secrets in plays

## Creating a secrets vault

```
$ tree .
.
├── group_vars
│   └── all
│       ├── vars
│       └── vault
├── templates
│   └── password.j2
└── vault.yml

3 directories, 4 files
```

* **`vars`**

```
password: '{{vault_password}}'
```

* **`vault`**

```
vault_password: thisIsnotAgoodPassword
```

```
$ ansible-vault -h

encryption/decryption utility for Ansible data files
Options:
  --ask-vault-pass      ask for vault password
  -h, --help            show this help message and exit
  --new-vault-id=NEW_VAULT_ID
                        the new vault identity to use for rekey
  --new-vault-password-file=NEW_VAULT_PASSWORD_FILE
                        new vault password file for rekey
  --vault-id=VAULT_IDS  the vault identity to use
  --vault-password-file=VAULT_PASSWORD_FILES
                        vault password file
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)
  --version             show program's version number, config file location,
                        configured module search path, module location,
                        executable location and exit

 See 'ansible-vault <command> --help' for more information on a specific
command.
```

### Encrypt password

```
ansible-vault encrypt vault
New Vault password: (12345)
Confirm New Vault password: (12345)
Encryption successful
```

```
$ more vault
$ANSIBLE_VAULT;1.1;AES256
39366238636135663636323265363238613163363138633964643965613330373562623261306366
6139623430343038383734353730323035656231663562310a613866383935376434313637613236
37666265333162666561643964323630363234336364383232623034336435396330346137643936
3437373636356532330a666437393866346661353239326562363431666564616134646535613738
65653434373736376335663237663131386561663934353866386635363030346436383435333839
3430656637363034386337366562333638636537333261373463
```
### Edit vault

```
$ ansible-vault edit vault
Vault password: (12345)
vault_password: NewthisIsnotAgoodPassword
```
```
$ more vault 
$ANSIBLE_VAULT;1.1;AES256
39383639343364616130396164643665353564396535373739373337353764333132356364373065
6563303034393431373863353136323564356137633462620a373832623862633036613339303539
32616163663763653463313463613566306238346438373439656463306430666635303637623061
6561343732353835330a393633346532623666643039663162633763653335393261623966356262
66383032643566613437346362353436306461393434366262366336303961663062616238383330
3534346664303139346630343665656237306564373062383034
```

**It's changed**

## Using secrets in plays

**`vault.yml`**

```
---
- hosts: all
  tasks:
  - name: embed the secure password in a file
    template:
      src: templates/password.j2
      dest: $HOME/tmp/password
      mode: 0600
    tags:
      - create
  - name: clean up the secure passwords file
    file:
      name: $HOME/tmp/password
      state: absent
    tags:
      - destroy
  - name: debug the password that was encrypted
    debug:
      msg: 'the password is {{password}}'
    tags:
      - create
      - destroy
```

**`password.j2`**

```
The password is {{password}}
```

### No password offered will report error

```
$ ansible-playbook -i ../inventory.ini vault.yml --tags create

PLAY [all] *********************************************************************************
ERROR! Attempting to decrypt but no vault secrets found
```

### `--ask-vault-pass`: import encrypt password

```
$ ansible-playbook -i ../inventory.ini vault.yml --tags create --ask-vault-pass
Vault password: (12345)
...
TASK [debug the password that was encrypted] ***********************************************
ok: [githost] => {
    "msg": "the password is NewthisIsnotAgoodPassword"
}
ok: [k8s-jx] => {
    "msg": "the password is NewthisIsnotAgoodPassword"
}
ok: [k8s-jx1] => {
    "msg": "the password is NewthisIsnotAgoodPassword"
}
ok: [k8s-jx2] => {
    "msg": "the password is NewthisIsnotAgoodPassword"
}
...
```

```
$ ansible-playbook -i ../inventory.ini vault.yml --tags destroy --ask-vault-pass
Vault password: (12345)
```
