#!/bin/bash
# ansible-playbook -i ../inventory.ini task2-2-tag.yaml --tags create-file
ansible-playbook -i ../inventory.ini task2-2-tag.yaml --skip-tags create-file --tags delete-file