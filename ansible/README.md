
# Ansible Essential Training

![Alt Image Text](images/0_1.png "Body image")

1. [Ansible Introductio](1ansible_intro.md)
   * What is Ansible
   * Why Ansible
   * Ansible Architecture
   * Ansible lanaguage basics
   * Ansible Simple Usage
   * [Sample Code](code/task1)

2. [Ansible Overview, Install(MacOs) and Environment Setup](2ansible_over_install.md)
   * Ansible Basic
   * Ansible Install
   * Environment Setup
3. [Task Execution management](2ansible_over_install.md)
   * Defining task execution with host groups
   * Using tags to limit play execution
   * Executing tasks on localhost
   * Limiting plays from the command line
   * Specifying variables via inventory
   * Defining inventory dynamically
   * Variables with dynamic playbooks
   * [Sample Code](code/task2)
4. [Ansible Variable Management](3play_task.md)
   * Jinja and templates
   * Host facts for `conditional` execution
   * Looping tasks with variable lists
   * Looping tasks with dictionaries
   * Looping in templates with variable lists
   * Looping in templates with dictionaries
   * Testing plays with check mode
   * [Sample Code](code/task2)
5. [Managing complex playbooks with roles and ansible galaxy (Create `group:user` on linux machine)](5Complex_roles.md)
   * Simple way to create `group:user`
   * Comprehenisve role to create `group:user` with `ansible galxy`
   * Variables in roles and variable precedence
   * Role-based templates
   * Documenting your role for reuse
   * Pushing a role to Galaxy
   * Finding roles via Ansible Galaxy
   * Centralizing roles with roles_path
   * [Sample Code](code/task3)
6. [Working with Secrets](6Secret_management.md)
   * Creating a secrets vault
   * Using secrets in plays
   * [Sample Code](code/task4)
7. [Network Management with Ansible](7Network_management.md)
   * `netaddr`
   * `netaddr_incremenet`
   * `Network interface config for hosts`
   * Network device interface config
   * [Sample Code](code/task5)
8. [Idempotentence with Ansible play](8idempotentence.md)
   * Idempotent "prototype" model
   * Registering discovered state
   * Creating an idempotent play
   * [Sample Code](code/task6)

9. [Exercise: Intsall kubeadm required resouce on centos](code/kubeadm)
