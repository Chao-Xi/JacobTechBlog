# Daily Cap ops in Jam


### 1.Check all cap commands in Jam env

```
$ cap -S instance=integration3 -T
$ cap -S instance=integration3 -T | grep []
```

### 2.Check kernel and docker version from Devops Machine

```
$ cd ~/code/<ENV>/ct
```

```
$ bundle exec cap --verbose -S instance=integration3 invoke COMMAND='sudo uname -r'
$ bundle exec cap --verbose -S instance=integration3 invoke COMMAND='docker -v'
```

```
$ cap -S instance=integration3 -T | grep invoke
cap invoke # Invoke a single command on the remote servers.

$ cap -S instance=integration3 invoke COMMAND='sudo uname -r'
$ cap -S instance=integration3 invoke COMMAND='docker -v'
```

### 3.Change `secrets.yml` and push to git

```
$ cap -S instance=integration3 -T | grep edit_secrets_file
cap provision:edit_secrets_file        # Interactively edit the secrrets.yml
$ cap -S instance=jam12 provision:edit_secrets_file                                                                                                          
```

### 4.Restart servers or service

```
$ cap -S instance=integration3 -T | grep deploy:restart
cap deploy:restart          # Do a blue/green or normal r...                                                                                                                       
cap deploy:restart_all      # start the app servers from ...                                                                                                                   
cap deploy:restart_webapp   # Soft bounce of app servers ...                                                                                                                  
``` 

### 5.Manipulate Container service

```
# cap -S instance=integration3 -T | grep  containerservice:all

$ cap containerservice:all:deploy     # Deploy all container servic...                                                                                                          
cap containerservice:all:deploy_now   # Deploy all container servic...                                                                                                       
cap containerservice:all:kill         # Stop the container services...                                                                                                     
cap containerservice:all:pull         # Load all needed containers                                                                                                             
cap containerservice:all:restart      # Restart all the container s...                                                                                                         
cap containerservice:all:restart_now  # Restart all the container s...                                                                                                       
cap containerservice:all:start        # Start the container services                                                                                                         
cap containerservice:all:stop         # Stop all the container serv...
```

### 6.specify a machine


```
$ HOSTFILTER=x.x.x.x bundle exec cap ...
```

#### For instance

```
$ HOSTFILTER=10.8.71.55 cap -S instance=jam8 containerservice:all:deploy
```
```
$ HOSTFILTER=10.116.30.39 cap -S instance=integration3 diagnostics:elasticsearch:health
```

### 7.diagnostics

#### Example: diagnostics on elasticsearch

```
$ cap -S instance=<Env> diagnostics:elasticsearch:health
$ cap -S instance=integration3 diagnostics:elasticsearch:status
$ cap -S instance=integration3 diagnostics:elasticsearch:health
```


## Command-line usage

### Reference

`https://github.com/capistrano/capistrano/blob/master/README.md`

```
# list all available tasks
$ bundle exec cap -T

# deploy to the staging environment
$ bundle exec cap staging deploy

# deploy to the production environment
$ bundle exec cap production deploy

# simulate deploying to the production environment
# does not actually do anything
$ bundle exec cap production deploy --dry-run

# list task dependencies
$ bundle exec cap production deploy --prereqs

# trace through task invocations
$ bundle exec cap production deploy --trace

# lists all config variable before deployment tasks
$ bundle exec cap production deploy --print-config-variables
```

## Cap for JAM


[Using Capistrano for deploying Jam](https://jam4.sapjam.com/wiki/show/LZJQfTp3VWh8x3di3YzfKk)
 

We are using Capistrano v2.14, and the source can be found here: [https://github.com/capistrano/capistrano/tree/v2.14.2](https://github.com/capistrano/capistrano/tree/v2.14.2)

### How it is used

Capistrano is used as a command line tool that allows for running a set of tasks that are either built-in, or specific to the repository it is running in. A Capistrano command commonly looks like this:

```
cap -S `some-argument`=`some-value` `some-command` `SOME_ENV_VAR=SOME_VAL`
```

Where an arbitrary number of arguments can be passed, and commands can be chained.

For example:

```
cap -S instance=development diagnostics:all invoke COMMAND='echo helloworld'

```

Hooks：

```
task :dostuff do

end

task :before1 do

end

task :before2 do

end

before 'dostuff', 'before1'

before 'dostuff, 'before2'
```

Would result in the following execution when dostuff is called:

**`before1 -> before2 -> dostuff`**

### Structure

Each Capistrano project has a main settings file called the **Capfile** at the root of the repository.

This file is used to load our plugins (ie. the instances plugin, which forces users to specify an instance variable as well as the `deploy_tasks` plugin). Furthermore, it loads all the Capistrano task definitions.

By default, each project has a Capistrano definition file at `./config/deploy.rb`.

##### Some conventions that we have set up for ct

We moved all of our definitions into a subdirectory at `./config/capistrano/*` for clarity. The file at `config/deploy.rb` is merely a file include, so when adding new Capistrano definition files remember to include it here (or alternatively directly in the Capfile).


Some commonly modified files:


* `diagnostics.rb` -- all diagnostics tasks can be found in this file
* `hooks.rb` -- all deployment-related hooks are defined here
* `methods.rb` -- some common or general method declarations
* `provision.rb` -- to do with setting up environments
* `settings.rb` -- capistrano variables are defined here

#### Roles

In Capistrano we assign roles to hosts. 

In the simple case, we simply assign roles based on the general role of the host: for instance, **app hosts are assigned the app role and workers assigned worker and so forth**. 

The same hosts, however, could also be assigned other roles. Eventually we would want to use this feature to allow for development of tasks that communicate only to blue nodes, or green nodes.

Tasks can filter based on role, so that when we run it it will only target the desired host type; this can also be specified within a command, for example:

```
run "echo doing something", :roles => :some-role
```

### Common commands

A few commands that we commonly use are:

* `any`:`cap -vT	`

```
Lists all available tasks. Useful for reference in combination with grep.
```

* `any` : `deploy:setup	`

```
Creates the base directory structure needed for deployment, and ensures that the
directory permissions are set correctly.
```

* `any` : `deploy `

```
Deploys the project. This actually just triggers a series of other built-in tasks:

1) deploy:update_code - creates a local tarball of the current project (ignoring either 
a preset list of files in .rsyncignore or defined in :rsync_excludes)

2) deploy:create_symlink - Capistrano releases are directories of the form `DATESTAMP`, 
and there is a symlink called "current" that points to the latest release. After 
copying the code to a new release directory, this task will then point "current" to it.

3) deploy:restart - restarts the service daemons if necessary.
```

* `any` : `invoke`

```
Runs an arbitrary bash command on all specified roles by specifying the COMMAND 
environment variable. Example:

cap -S instance=<instance> invoke COMMAND="sudo touch /tmp/creating_new_file_on_remote"
```

* `any` : `deploy:exec_deploy_tasks`

```
This is not defined in our deploy.rb file, but through an in-house gem developed at 
https://github.wdf.sap.corp/sap-jam/deploy_tasks

This is automatically triggered by running deploy, but can be skipped by setting 
SKIP_DEPLOY_TASKS=1 in the environment.

When this is run, all the task files in the ./deploy_tasks directory that haven't 
succeeded yet will be run.


The status of the runs is stored at ~/code/`INSTANCE`/deploy_tasks/`PROJECT`-status.yml
```

* `ct` : `diagnostics:all`

```
Runs all diagnostics checks and displays results.

Useful options:

1) -S mode=quiet - only output failures

2) -q - this is a built-in quiet option for Capistrano and will remove all output from calling hooks
```

Built-in variables that are relevant, or that we have overridden:


![Alt Image Text](images/0_1.png "body image")

Note that any of these variables can be overridden at run time using the `-S <variable>=<value>` notation.

Eg.

```
cap -S instance=new-jam-instance -S user=root do-something
```

Built-in environment variables that are commonly used:


First Header  | Second Header
------------- | -------------
ROLES	  | Specify the Capistrano roles to run on
HOSTS	  | Specify the Capistrano hosts to run on

#### Deploy tasks

An in-house Capistrano plugin. Basically allows for arbitrary commands to be run in groupings as a "task", and we keep track of the status, errors, responsible persons in case it fails. Any Capistrano task can be run from within the execute and validate blocks; though deploy.default should now be avoided since deploy_tasks are chained to deploy (we would create a permanent loop).


**In this gem the main task that we define is this:**

```
deploy:exec_deploy_tasks
```

This runs all tasks that either don't have an entry in `~/code/INSTANCE/deploy_tasks/repo-name-status.yml`


#### Running Capistrano locally

To run local commands within a Capistrano task, there is the `run_locally` command. Any native Ruby code, such as that creating a new file would also be run locally.

*The development instance*

It is also possible to run tasks that generally run on remote nodes locally. For instance, if we want to execute deploy tasks on the current host the following command can be used:


```
cap -S instance=development deploy:exec_deploy_tasks
```







