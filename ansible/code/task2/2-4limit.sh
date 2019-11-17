#!/bin/bash
# ansible-playbook -i ../inventory.ini task2-4-limit.yaml -e file_state=touch --start-at-task='the second task'
ansible-playbook -i ../inventory.ini task2-4-limit.yaml -e file_state=absent --start-at-task='the second task'