#!/bin/bash
ansible -m ping -i ../inventory.ini all
# ansible -m ping -i ../inventory web1 -u vagrant