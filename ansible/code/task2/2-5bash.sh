#!/bin/bash
# ansible-playbook -i ../2-5-inventory.ini task2-5-var.yaml -e file_state=touch
ansible-playbook -i ../2-5-inventory.ini task2-5-var.yaml -e file_state=absent