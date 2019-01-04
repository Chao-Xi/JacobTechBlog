# 12 Chef Knife Cookbook Command Examples

When you are using Chef to manage all your servers and network equipments, you should first create cookbooks and appropriate recipes.

On all your remote servers, you’ll use chef-client to execute the recipes from the cookbook.

In this tutorial, we’ll explain how to use knife command to create and manage your Chef cookbooks.

## 1. Create New Chef Cookbook

To create a cookbook, use “`knife cookbook create`” command as shown below. The following will create a cookbook with name thegeekstuff.

```
$ knife cookbook create test
FATAL: knife cookbook create has been removed. Please use `chef generate cookbook` from the ChefDK
```

```
$ cd /home/vagrant/chef-repo/cookbooks
$ chef generate cookbook Sushi

$ chef generate cookbook Sushi
Generating cookbook Sushi
- Ensuring correct cookbook file content
- Ensuring delivery configuration
- Ensuring correct delivery build cookbook content

Your cookbook is ready. Type `cd Sushi` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list.

Why not start by writing a test? Tests for the default recipe are stored at:

test/integration/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb
```

For the above command, knife command creates a separate directory called “Sushi” under `~/chef-repo/cookbooks` as shown below.

The following is the cookbook folder structure.

```
$ tree Sushi/
Sushi/
├── Berksfile
├── CHANGELOG.md
├── chefignore
├── LICENSE
├── metadata.rb
├── README.md
├── recipes
│   └── default.rb
├── spec
│   ├── spec_helper.rb
│   └── unit
│       └── recipes
│           └── default_spec.rb
└── test
    └── integration
        └── default
            └── default_test.rb

7 directories, 10 files
```

## 2. Create New Cookbook with Custom Options

The **metadata.rb** file under the cookbook directory will have the following default values.

```
$ cat /home/vagrant/chef-repo/cookbooks/Sushi/metadata.rb
name 'Sushi'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures Sushi'
long_description 'Installs/Configures Sushi'
version '0.1.0'
chef_version '>= 13.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/Sushi/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/Sushi'
```

**The above values will be used to generate header in any of the `.rb` files that you create under this cookbook.**

While creating a cookbook, the best practice is to pass the following options.

```
$ chef generate cookbook COOKBOOK_PATH/COOKBOOK_NAME (options)
```

### Options:

This subcommand has the following options:

```
-g GENERATOR_COOKBOOK_PATH, --generator-cookbook GENERATOR_COOKBOOK_PATH
```
The path at which a cookbook named `code_generator` is located. This cookbook is used by the `chef generate` subcommands to generate cookbooks, cookbook files, templates, attribute files, and so on. Default value: `lib/chef-dk/skeletons`, under which is the default `code_generator` cookbook that is included as part of the Chef development kit.

`-b, --berks`

Create a **Berksfile** in the cookbook. **Default value: enabled**. This is disabled if the `--policy` option is given.

`-C COPYRIGHT, --copyright COPYRIGHT`

Generate a delivery config file and build cookbook inside the new cookbook. **Default value: disabled**. This option is disabled. It has no effect and exists only for compatibility with past releases

`-m EMAIL, --email EMAIL`

Specify the email address of the author. Default value: `you@example.com`.

`-a KEY=VALUE, --generator-arg KEY=VALUE`

**Sets a property named KEY to the given VALUE on the generator context object in the generator cookbook**. This allows custom generator cookbooks to accept optional user input on the command line.


`-I LICENSE, --license LICENSE`

Sets the license. Valid values are `all_rights`, `apache2`, `mit`, `gplv2`, or `gplv3`. **Default value: all_rights**.

`-P, --policy`

Create a Policyfile in the cookbook instead of a Berksfile. **Default value: disabled**.

`-h, --help`

Show help for the command.

`-v, --version`

The version of the chef-client.

## 3. Upload Cookbook to Chef Server

The following “knife cookbook upload” command will upload the cookbook that we created above to the Chef server.

As we see, since this is the first version of this cookbook, it is showing the version number as 0.1.0.

```
$ sudo knife cookbook upload Sushi
Uploading Sushi          [0.1.0]
Uploaded 1 cookbook.
```

When you have multiple cookbooks that has multiple versions, you can upload all of your cookbooks using option `-a`.

In the following example, we have 3 cookbooks, and the latest version of all these cookbooks are getting uploaded.

```
$ sudo knife cookbook upload -a
Uploading ApacheWebserver [0.1.0]
Uploading Sushi          [0.1.0]
Uploading starter        [1.0.0]
Uploaded all cookbooks.
```
**The following command will not only upload “Sushi” cookbook, but it will also upload all the dependent cookbooks.**


```
$ sudo knife cookbook upload Sushi -d
Uploading Sushi          [0.1.0]
Uploaded 1 cookbook.
```

## 4. Lock a Cookbook from Future Edits


**When you don’t want anybody else to be modifying a particular cookbook version, use the `–freeze` option.**

In the following example, after this command, nobody can upload the 0.1.0 version of “Sushi” cookbook anymore. You have to create a new version.

```
$ sudo knife cookbook upload Sushi --freeze
Uploading Sushi          [0.1.0]
Uploaded 1 cookbook.
```

If you are trying to upload the same version, you’ll get the following error message.

```
$ sudo knife cookbook upload Sushi
Uploading Sushi          [0.1.0]
ERROR: Version 0.1.0 of cookbook Sushi is frozen. Use --force to override.
WARNING: Not updating version constraints for Sushi in the environment as the cookbook is frozen.
ERROR: Failed to upload 1 cookbook.
```

**For some reason, if you want to edit and upload a cookbook that is frozen, use the –force option.**

```
$ sudo knife cookbook upload Sushi --force
Uploading Sushi          [0.1.0]
Uploaded 1 cookbook.
```
**When you are uploading lot of cookbooks that are big, you can use the `–-concurrency` option. By default this is set to `10`. In the following example, we are setting the concurrency to 15 while uploading the cookbook.**

```
# knife cookbook upload -a --concurrency 15
```


## 5. Get a List of ALL Cookbooks

The following “knife cookbook list” command will display all the cookbooks that are available on your Chef server. The 2nd column in the following output is the latest version of that cookbook

```
$ knife cookbook list
ApacheWebserver   0.1.0
Sushi             0.1.0
starter           1.0.0
```

To view how many versions are available for the cookbooks, use the `-a` option which will display ALL versions. You can also use `–all` option.

```
$ knife cookbook list -a
ApacheWebserver   0.1.0
Sushi             0.1.0
starter           1.0.0
```

The `-w` option will display all the cookbook versions along with their corresponding URIs as shown below. You can also use `–with-uri` option. You can combine `-a` option with `-w` as shown below.

```
$ knife cookbook list -aw
ApacheWebserver:
  0.1.0: https://chefserver/organizations/devops-jxi/cookbooks/ApacheWebserver/0.1.0
Sushi:
  0.1.0: https://chefserver/organizations/devops-jxi/cookbooks/Sushi/0.1.0
starter:
  1.0.0: https://chefserver/organizations/devops-jxi/cookbooks/starter/1.0.0
```

## 6. Delete a Single Cookbook

```
$ knife cookbook delete Sushi
Do you really want to delete Sushi version 0.1.0? (Y/N) y
Deleted cookbook[Sushi version 0.1.0]
```


The `-p` option will delete the cookbook, and permanently purge the cookbook from the Chef server. Use this option with caution.

```
# knife cookbook delete dev-db -p
Files that are common to multiple cookbooks are shared, so purging the files may disable other cookbooks. Are you sure you want to purge files instead of just deleting the cookbook? (Y/N) Y
Do you really want to delete dev-db version 0.1.0? (Y/N) Y
Deleted cookbook[dev-db version 0.1.0]
```

## 7. Delete One (or All) Versions of a Cookbook

When a cookbook has multiple versions, the delete command will display all the versions and prompt the user to choose either one of the version, or all versions as shown below.


```
# knife cookbook delete thegeekstuff
Which version(s) do you want to delete?
1. thegeekstuff 2.1.0
2. thegeekstuff 2.0.0
3. thegeekstuff 1.0.0
4. thegeekstuff 0.1.0
5. All versions
```

In the above example, I choose 1 to delete “`thegeekstuff`” cookbook with version `2.1.0`

```
1
Deleted cookbook[thegeekstuff][2.1.0]
```
You can also specify the version number to delete directly in the command lien as shown below.

```
# knife cookbook delete 2.1.0 thegeekstuff
Do you really want to delete 2.1.0 version thegeekstuff? (Y/N) N
Deleted cookbook[thegeekstuff][2.1.0]
```

If you want to delete ALL the version of a specific cookbook, use option `-a` as shown below. You can also use `–all` instead of `-a`.

```
# knife cookbook delete thegeekstuff -a
Do you really want to delete all versions of thegeekstuff? (Y/N) Y
Deleted cookbook[thegeekstuff][2.1.0]
Deleted cookbook[thegeekstuff][2.0.0]
Deleted cookbook[thegeekstuff][1.0.0]
Deleted cookbook[thegeekstuff][0.1.0]
```

## 8. Delete Multiple Cookbooks using Bulk Delete

In the following example, we are using “knife cookbook bulk delete” command to delete multiple cookbooks at the same time. You can pass regular-expressions as parameter to this command.

The following example will delete all the cookbooks that start with “dev-“.

This this example, we have three cookbooks that matches the given regular expression. But, each of these cookbooks have multiple versions. So, this command will delete all the version of these three cookbooks.

```
$  knife cookbook bulk delete "^dev-*"
All versions of the following cookbooks will be deleted:



Do you really want to delete these cookbooks? (Y/N) n
You said no, so I'm done here.
```

## 9. Download Cookbook from Chef Server


When you have chef-client installed on multiple machine, and when you want to download a cookbook that someone has modified on your client, then use the “`knife cookbook download`” command as shown below.

The following command will download the “`ApacheWebserver`” cookbook from the Chef server to your local machine.

The cookbook will be downloaded to the current directory. The downloaded cookbook folder will also have the version number appended at the end.

```
$ sudo knife cookbook download ApacheWebserver
Downloading ApacheWebserver cookbook version 0.1.0
Downloading root_files
Downloading test
Downloading spec
Downloading recipes
Cookbook downloaded to /home/vagrant/chef-repo/ApacheWebserver-0.1.0
```

When you are trying to download a cookbook that has multiple versions, it will prompt you to choose a specific version.

In the following example, since “ApacheWebserver” cookbook has multiple versions, it will display the following option, and you can choose one from the list.

```
$  sudo knife cookbook download ApacheWebserver
Which version do you want to download?
1. ApacheWebserver 0.1.0
2. ApacheWebserver 0.2.0
```
**You can also pass the cookbook version number in the command-line as shown below, to directly download that particular version to your local machine.**


If you just want to download the latest version of a cookbook without having to specify a version number, use `-N` option (or `–latest` option) as shown below.

```
$ sudo knife cookbook download ApacheWebserver -N
Downloading ApacheWebserver cookbook version 0.2.0
Downloading root_files
Downloading test
Downloading spec
Downloading recipes
Cookbook downloaded to /home/vagrant/chef-repo/cookbooks/ApacheWebserver/ApacheWebserver-0.2.0
```

When a version of the cookbook that you are downloading has already been downloaded before, you’ll get the following error message.

```
$ sudo knife cookbook download ApacheWebserver 0.2.0
Downloading ApacheWebserver cookbook version 0.2.0
FATAL: Directory /home/vagrant/chef-repo/cookbooks/ApacheWebserver/ApacheWebserver-0.2.0 exists, use --force to overwrite
```
In that case, use the `-f `option (or `–force`) to download the cookbook and overwrite the local directory with the version that was downloaded from the Chef server.

```
knife cookbook download  ApacheWebserver  2.1.0 -f
```
Instead of downloading it under the current directory, you can also specify a download directory using `-d` option (or –dir option).

The following command will download “ApacheWebserver” version 0.2.0 cookbook to `~/tmp/download` directory.

```
$ sudo knife cookbook download ApacheWebserver 0.2.0 -d ~/tmp/download/
Downloading ApacheWebserver cookbook version 0.2.0
Downloading root_files
Downloading test
Downloading spec
Downloading recipes
Cookbook downloaded to /home/vagrant/tmp/download/ApacheWebserver-0.2.0

$ ls -lt ~/tmp/download/
total 0
drwxr-xr-x. 5 root root 171 Jan  4 07:17 ApacheWebserver-0.2.0
```


## 10. Generate Cookbook Metadata

You can generate metadata file for your cookbook using “knife cookbook metadata” command as shown below. The following command will generate the `metadata.rb `for all the cookbooks.

```
# knife cookbook metadata -a
Generating metadata for dev-cluster from /root/chef-repo/cookbooks/dev-cluster/metadata.rb
Generating metadata for dev-db from /root/chef-repo/cookbooks/dev-db/metadata.rb
Generating metadata for dev-web from /root/chef-repo/cookbooks/dev-web/metadata.rb
Generating metadata for thegeekstuff from /root/chef-repo/cookbooks/thegeekstuff/metadata.rb
```

If you want to generate metadata only for a specific cookbook, then specify the direct path of the metadata.rb file for that particular cookbook using the “from file” option as shown below.

The following command will generate metadata for “ApacheWebserver” cookbook using the given `metadata.rb` file.

```
# knife cookbook metadata from file ~/chef-repo/cookbooks/thegeekstuff/metadata.rb 

Generating metadata for thegeekstuff from /root/chef-repo/cookbooks/thegeekstuff/metadata.rb
```


## 11. View Cookbook Details


You can view the details of a cookbook using “`knife cookbook show`” command.

When you don’t specify a version number for a cookbook, the show command will display list of all the version numbers available for the given cookbook

```
$ knife cookbook show ApacheWebserver
ApacheWebserver   0.2.0  0.1.0
```
But when you specify a version number, this will display lot more information about the cookbook as shown below.

```
$ knife cookbook show ApacheWebserver 0.2.0
cookbook_name: ApacheWebserver
frozen?:       false
metadata:
  attributes:
  chef_versions:
    >= 13.0
  dependencies:
  description:      Installs/Configures ApacheWebserver
  gems:
  issues_url:
  license:          All Rights Reserved
  long_description: Installs/Configures ApacheWebserver
  maintainer:       The Authors
  maintainer_email: you@example.com
  name:             ApacheWebserver
  ohai_versions:
  platforms:
  privacy:          false
  providing:
    ApacheWebserver:        >= 0.0.0
    ApacheWebserver::hello: >= 0.0.0
  recipes:
    ApacheWebserver:
    ApacheWebserver::hello:
  source_url:
  version:          0.2.0
name:          ApacheWebserver-0.2.0
...
```
The default output of the above command will display lot of information.

You can also specify a section number to the show command as shown below, which will display only that particular section in the show command output.

For example, the following will display only the “attributes” section from the `docker_custom.rb` file of “thegeekstuff” cookbook.

```
knife cookbook show thegeekstuff 1.2.0 attributes docker_custom.rb
```

The following show command will display only the “recipies” PART (section) from the given `.rb` file of the “`thegeekstuff`” cookbook.


```
knife cookbook show thegeekstuff 1.2.0 recipies deploy/testserver/tomcat_custom.rb
```

The following are the possible sections that you can pass as a parameter to the above show command.

* attributes
* definitions
* files
* libraries
* providers
* recipes
* resources
* templates


Also, use `-F` option to specify a output format for the knife cookbook show command. The following will display the output of the show command in JSON format.

To view information in JSON format, use the -F common option as part of the command like this:

```
$ knife cookbook show  ApacheWebserver  0.1.0 -F json
{
  "cookbook_name": "ApacheWebserver",
  "name": "ApacheWebserver-0.1.0",
  "frozen?": false,
  "metadata": {
    "name": "ApacheWebserver",
    "description": "Installs/Configures ApacheWebserver",
    "long_description": "Installs/Configures ApacheWebserver",
    "maintainer": "The Authors",
    "maintainer_email": "you@example.com",
    "license": "All Rights Reserved",
    "platforms": {

    },
    "dependencies": {

    },
...
```

The following are the available formats:

* json – for JSON format
* text – for plain text
* yaml – Standard YAML format
* pp – Post processing format


## 12. Validate Cookbook Syntax

The following “`knife cookbook test`” command will do a syntax check validation on the cookbook files.

**In the following example, we have an error in “ApacheWebserver” cookbook. As you see in the last line, it says that the method “author” in the metadata.rb file is undefined and not recognized by Chef.**

```
$ sudo knife cookbook test ApacheWebserver
WARNING: DEPRECATED: Please use ChefSpec or Cookstyle to syntax-check cookbooks.
checking ApacheWebserver
Running syntax check on ApacheWebserver
Validating ruby files
Validating templates
```


### `$ cookstyle /path/to/cookbook`

```
$ sudo cookstyle cookbooks/ApacheWebserver/
Inspecting 14 files
.....CC.....CC

Offenses:

cookbooks/ApacheWebserver/recipes/default.rb:7:9: C: Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
service "httpd" do
        ^^^^^^^
cookbooks/ApacheWebserver/recipes/default.rb:8:1: C: Layout/IndentationWidth: Use 2 (not 8) spaces for indentation.
        action [:enable, :start]
^^^^^^^^
cookbooks/ApacheWebserver/recipes/default.rb:12:1: C: Layout/IndentationWidth: Use 2 (not 8) spaces for indentation.
        content "<html><body bgcolor='#D2D2D3'><h1>Hello World, This is my 1st cookbook recipe </h1></body></html>"
^^^^^^^^
cookbooks/ApacheWebserver/recipes/hello.rb:2:1: C: Layout/IndentationWidth: Use 2 (not 8) spaces for indentation.
        content "<html><body>Hello World, This is my first cookbook <br/> This is 2nd version </body></html>"
^^^^^^^^
cookbooks/ApacheWebserver/recipes/hello.rb:2:17: C: Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
        content "<html><body>Hello World, This is my first cookbook <br/> This is 2nd version </body></html>"
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
cookbooks/ApacheWebserver/ApacheWebserver-0.2.0/recipes/default.rb:7:9: C: Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
service "httpd" do
        ^^^^^^^
cookbooks/ApacheWebserver/ApacheWebserver-0.2.0/recipes/default.rb:8:1: C: Layout/IndentationWidth: Use 2 (not 8) spaces for indentation.
        action [:enable, :start]
^^^^^^^^
cookbooks/ApacheWebserver/ApacheWebserver-0.2.0/recipes/default.rb:12:1: C: Layout/IndentationWidth: Use 2 (not 8) spaces for indentation.
        content "<html><body bgcolor='#D2D2D3'><h1>Hello World, This is my 1st cookbook recipe </h1></body></html>"
^^^^^^^^
cookbooks/ApacheWebserver/ApacheWebserver-0.2.0/recipes/hello.rb:2:1: C: Layout/IndentationWidth: Use 2 (not 8) spaces for indentation.
        content "<html><body>Hello World, This is my first cookbook <br/> This is 2nd version </body></html>"
^^^^^^^^
cookbooks/ApacheWebserver/ApacheWebserver-0.2.0/recipes/hello.rb:2:17: C: Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
        content "<html><body>Hello World, This is my first cookbook <br/> This is 2nd version </body></html>"
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

14 files inspected, 10 offenses detected
```