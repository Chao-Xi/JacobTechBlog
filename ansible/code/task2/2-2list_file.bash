#!/bin/bash
# ansible-playbook -i ../inventory.ini task2-2-tag.yaml --tags create-file
ansible-playbook -i ../inventory.ini task2-2-tag.yaml --tags list-file