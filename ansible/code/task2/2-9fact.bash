#!/bin/bash
ansible -m debug -i ../inventory.ini -a "var=hostvars['k8s-jx1']" k8s-jx2
# debug module
# This is information that I could use on the k8s-jx2 host, basically in k8s-jx2 host plays, 
# but that's coming from k8s-jx1.
# gather k8s-jx2 fact from all ther machine

# k8s-jx2 | SUCCESS => {
#     "hostvars['k8s-jx1']": {
#         "ansible_check_mode": false,
#         "ansible_diff_mode": false,
#         "ansible_facts": {},
#         "ansible_forks": 5,
#         "ansible_inventory_sources": [
#             "/Users/i515190/Devops_sap/ansible/code/inventory.ini"
#         ],
#         "ansible_playbook_python": "/usr/local/opt/python/bin/python3.7",
#         "ansible_ssh_host": "10.151.30.22",
#         "ansible_ssh_user": "vagrant",
#         "ansible_verbosity": 0,
#         "ansible_version": {
#             "full": "2.8.4",
#             "major": 2,
#             "minor": 8,
#             "revision": 4,
#             "string": "2.8.4"
#         },
#         "group_names": [
#             "db",
#             "k8s_servers"
#         ],
#         "groups": {
#             "all": [
#                 "githost",
#                 "k8s-jx",
#                 "k8s-jx1",
#                 "k8s-jx2"
#             ],
#             "backup": [
#                 "k8s-jx2"
#             ],
#             "db": [
#                 "k8s-jx1",
#                 "k8s-jx2"
#             ],
#             "githost_servers": [
#                 "githost"
#             ],
#             "k8s_servers": [
#                 "k8s-jx",
#                 "k8s-jx1",
#                 "k8s-jx2"
#             ],
#             "ungrouped": [],
#             "web": [
#                 "githost",
#                 "k8s-jx"
#             ]
#         },
#         "inventory_dir": "/Users/i515190/Devops_sap/ansible/code",
#         "inventory_file": "/Users/i515190/Devops_sap/ansible/code/inventory.ini",
#         "inventory_hostname": "k8s-jx1",
#         "inventory_hostname_short": "k8s-jx1",
#         "omit": "__omit_place_holder__c9e42029ac432d30cea899c242b04de327d27366",
#         "playbook_dir": "/Users/i515190/Devops_sap/ansible/code/task2"
#     }
# }

#

# This can be used to getting information of other hosts
# ansible-playbook -i ../inventory.ini task2-9fact.yaml -e file_state=touch
# ansible-playbook -i ../inventory.ini task2-9fact.yaml -e file_state=absent