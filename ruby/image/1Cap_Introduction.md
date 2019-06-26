# Cap Introduction

### Getting started

[Capistrano: A deployment automation tool built on Ruby, Rake, and SSH.](https://github.com/capistrano/capistrano/blob/master/README.md)

## Structure

The **root path** of this structure can be defined with the configuration variable `:deploy_to`.

Assuming your `config/deploy.rb` contains this:

```
set :deploy_to, '/var/www/my_app_name'
```


Then inspecting the directories inside `/var/www/my_app_name` looks like this:

```
├── current -> /var/www/my_app_name/releases/20150120114500/
├── releases
│   ├── 20150080072500
│   ├── 20150090083000
│   ├── 20150100093500
│   ├── 20150110104000
│   └── 20150120114500
├── repo
│   └── <VCS related data>
├── revisions.log
└── shared
    └── <linked_files and linked_dirs>
```

* `current` is a **symlink pointing to the latest release.**
* `releases` holds all deployments in a timestamped folder. **These folders are the target of the `current` symlink.**
* **`repo` holds the version control system configured.** In case of a git repository the content will be a raw git repository 
* **`revisions.log` is used to log every deploy or rollback. Each entry is timestamped and the executing user (`:local_user`, defaulting to the local username) is listed.** Depending on your VCS data like branch names or revision numbers are listed as well.
* **shared** contains the **linked_files** and **linked_dirs** which are symlinked into each release. 

## Configuration

### Location

Configuration variables can be either global or specific to your stage.

#### global

```
config/deploy.rb
```

#### stage specific

```
config/deploy/<stage_name>.rb
```

### Access

**deploy.rb**

```
set :application, 'MyLittleApplication'

# use a lambda to delay evaluation
set :special_thing, -> { "SomeThing_#{fetch :other_config}" }
```

A value can be retrieved from the configuration at any time:

```
fetch :application
# => "MyLittleApplication"

fetch(:special_thing, 'some_default_value')
# will return the value if set, or the second argument as default value
```

```
append :linked_dirs, ".bundle", "tmp"
```
```
remove :linked_dirs, ".bundle", "tmp"
```

### Variables

```
set :application, 'capistrano_example'
```

* `:application`:  The name of the application.
* `:deploy_to ` : `default: -> { "/var/www/#{fetch(:application)}" }` The path on the remote server where the application should be deployed.
* `:scm`: `default: :git` The Source Control Management used.
* `repo_url`: URL to the repository and Must be a valid URL for the used SCM.

```
set :repo_url, 'git@github.com:/capistrano-example.git'
```

*  `:branch`: **default: 'master'**
*  `:svn_username`, `:svn_password`, `:svn_revision`, `:repo_tree`
*  `:linked_files`: Listed files will be symlinked from the shared folder of the application into each release directory during deployment.
*  `:linked_dirs`: Listed directories will be symlinked into the release directory during deployment.
*  `:default_env`: Default shell environment used during command execution
*  `:keep_releases`: The last n releases are kept for possible rollbacks.
*  `:tmp_dir`: Temporary directory used during deployments to store data.
*  `:local_user`: Username of the local machine used to update the revision log.
*  `:pty`, `:log_level`, `:format`, `:shared_directory`, `:releases_directory`, `:current_directory`

## User Input

User input can be required in a task or during configuration:

```
# used in a configuration
ask(:database_name, "default_database_name")

# used in a task
desc "Ask about breakfast"
task :breakfast do
  ask(:breakfast, "pancakes")
  on roles(:all) do |h|
    execute "echo \"$(whoami) wants #{fetch(:breakfast)} for breakfast!\""
  end
end
```

When using ask to get user input, you can pass `echo: false` to prevent the input from being displayed. This option should be used to ask the user for passwords and other sensitive data during a deploy run.

```
ask(:database_password, 'default_password', echo: false)
```

```
ask(:database_encoding, 'UTF-8')
# Please enter :database_encoding (UTF-8):

fetch(:database_encoding)
# => contains the user input (or the default)
#    once the above line got executed
```








