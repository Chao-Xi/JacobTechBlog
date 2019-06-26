# Cap Filtering

Filtering is the term given to reducing the entire set of servers declared in a stage file to a smaller set. 


There are three types of filters used in Capistrano **(Host, Role and Property)** and they take effect in two quite different ways because of the two distinct uses to which the declarations of servers, roles and properties are put in tasks.

### On-Filtering


On-filters apply only to the `on()` method that invokes SSH. There are two default types:

## Host filtering

You may encounter situations where you only want to deploy to a subset of the servers defined in your configuration. 

For example, a single server or set of servers may be misbehaving, and you want to re-deploy to just these servers without deploying to every server.

You can use the host filter to restrict Capistrano tasks to only servers that match a given set of hostnames.

**If the filter matches no servers, no actions will be taken.**

If you specify a filter, it will match servers that have the listed hostnames, and it will run all the roles for each server. In other words, it only affects the servers the task runs on, not what tasks are run on a server.

### Specifying a host filter

There are three ways to specify the host filter.

#### Environment variable

Capistrano will read the host filter from the environment variable HOSTS if it is set. You can set it inline:

```
HOSTS=server1,server2 cap production deploy
```
**Specify multiple hosts by separating them with a comma.**

In configuration

You can set the host filter inside your deploy configuration. For example, you can set the following inside `config/deploy.rb`:

```
set :filter, :hosts => %w{server1 server2}
```

**On the command line**

```
cap --hosts=server1,server2 production deploy
```

**Using Regular Expressions**

```
cap --hosts=^localrubyserver production deploy
```


## Role filtering

If you specify a filter, it will match any servers that have that role, and it will run all tasks for each of the roles that server has. For example, if you filtered for servers with the web role, and a server had both the web and db role, both the **web** and **db** role tasks would be executed on it

**Environment variable**

Capistrano will read the role filter from the environment variable **ROLES** if it is set. You can set it inline:

```
ROLES=app,web cap production deploy
```

**In configuration**

You can set the role filter inside your deploy configuration. For example, you can set the following inside `config/deploy.rb`:

```
set :filter, :roles => %w{app web}
```

**On the command line**

```
cap --roles=app,web production deploy
```

Like the environment variable method, specify multiple roles by separating them with a comma.








