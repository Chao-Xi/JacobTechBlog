#!/bin/bash
ansible-playbook -i ../inventory.ini task2-1.yaml -e file_state=touch
# -e EXTRA_VARS, set additional variables as key=value or YAML/JSON, if filename prepend with @

# If `touch` (new in 1.4), an empty file will be created if the `path` does not exist, 
# while an existing file or directory will receive updated file access and modification times 
# (similar to the way `touch` works from the command line).

