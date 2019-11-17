#!/bin/bash
ansible-playbook -i ../inventory.ini task2-1.yaml -e file_state=absent

# If `absent`, directories will be recursively deleted, and files or symlinks will be unlinked. 
# Note that `absent` will not cause `file` to fail if the path does not exist as the state did not change.