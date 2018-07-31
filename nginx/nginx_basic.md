![Alt Image Text](images/headline2.jpg "headline")
# Nginx Tutorial #1: Basic Concepts

## Introduction

This tutorial will tell you how Nginx works, speak about the concepts behind it, how could you optimise it to boost up your app's performance, and how to set it up to have it up and running.

## This tutorial will have three parts:

* Basics concepts: get to know the difference between directive and context, the inheritance model, and the order in which Nginx picks server blocks and locations.
* Performance: tips and tricks to improve speed. We will discuss gzip, caching, buffers, and timeouts.
* SSL setup: set up the configuration to serve content through HTTPS.

The goal is to create a series in which you can easily find the proper configuration for a particular topic (like gzip, SSL, etc.), or simply read it all through. For the best learning experience, we suggest you set Nginx up on your own machine and fiddle with it yourself.

## What is Nginx?

Nginx was originally created as a web server to solve the [C10k problem](https://en.wikipedia.org/wiki/C10k_problem). And as a web server, it can serve your data with blazing speed. But Nginx is so much more than just a web server. You can use it as a reverse proxy, making an easy integration with slower upstream servers (like Unicorn, or Puma). You can distribute your traffic properly (load balancer), stream media, resize your images on the fly, cache content, and much more.

**The basic nginx architecture consists of a master process and its workers. The master is supposed to read the configuration file and maintain worker processes, while workers do the actual processing of requests.**

Base commands

To start nginx, you simply type:

`[sudo] nginx` or `sudo service nginx start`

```
ps aux | grep nginx
root     13308  0.0  0.0  32436   848 ?        Ss   07:49   0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx    13309  0.0  0.2  32840  2560 ?        S    07:49   0:00 nginx: worker process
ubuntu   13311  0.0  0.0  12944   940 pts/0    S+   07:49   0:00 grep --color=auto nginx
```

While your nginx instance is running, you can manage it, by sending proper signals:

`[sudo] nginx -s signal`

Available signals:

`stop`: fast shutdown
`quit`: graceful shutdown (wait for workers to finish their processes)
`reload`: reload the configuration file
`reopen`: reopening the log files

## Directive and Context

By default, the nginx configuration file can be found in:

* `/etc/nginx/nginx.conf,`
* `/usr/local/etc/nginx/nginx.conf,` or
* `/usr/local/nginx/conf/nginx.conf`

```
systemctl status nginx.service
● nginx.service - nginx - high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2018-07-29 07:49:29 UTC; 5s ago
     Docs: http://nginx.org/en/docs/
  Process: 13250 ExecStop=/bin/kill -s TERM $MAINPID (code=exited, status=0/SUCCESS)
  Process: 13304 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 13308 (nginx)
    Tasks: 2
   Memory: 1.3M
      CPU: 4ms
   CGroup: /system.slice/nginx.service
           ├─13308 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.con
           └─13309 nginx: worker process

Jul 29 07:49:29 ubuntu-xenial systemd[1]: Starting nginx - high performance web server...
Jul 29 07:49:29 ubuntu-xenial systemd[1]: Started nginx - high performance web server.
```

The orginal configuration of nginx

`sudo vim /etc/nginx/nginx.conf`

```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

This file consists of:

* directive: the option that contains of name and parameters, it should end with a semicolon

`gzip on;`

* context: the section where you can declare directives (similar to scope in programming languages)

```
worker_processes 2; # directive in global context

http {              # http context
    gzip on;        # directive in http context

  server {          # server context
    listen 80;      # directive in server context
  }
}
```

## Directive types
You have to care when using the same directive in multiple contexts, as the inheritance model differs for different directives. There are 3 types of directives, each with its own inheritance model.

### Normal
It has one value per context. Also, it can be defined only once in the context. Subcontexts can override the parent directive, but this override will be valid only in given subcontext.

**Illegal to have 2 normal directives in same context**

```
gzip on;
gzip off; # illegal to have 2 normal directives in same context

server {
  location /downloads {
    gzip off;
  }

  location /assets {
    # gzip is on here
  }
}

```

### Array

**Adding multiple directives in the same context will add to the values**, instead of overwriting them altogether. Defining a directive in a subcontext will override ALL parent values in the given subcontext.

```
error_log /var/log/nginx/error.log;
error_log /var/log/nginx/error_notive.log notice;      #add thevalues
error_log /var/log/nginx/error_debug.log debug;

server {
  location /downloads {
    # this will override all the parent directives
    error_log /var/log/nginx/error_downloads.log;
  }
}
```

### Action directive

Actions are directives that change things. Their inheritance behaviour will depend on the module.

For example, in the case of the `rewrite` directive, every matching one will be executed:

```
server {
  rewrite ^ /foobar;

  location /foobar {
    rewrite ^ /foo;
    rewrite ^ /bar;
  }
}
```

If the user tries to fetch `/sample:`

* the server rewrite is executed, rewriting from `/sample`, to `/foobar`
* the location /foobar is matched
* the first location rewrite is executed, rewriting from `/foobar`, to `/foo`
* the second location rewrite is executed, rewriting from `/foo`, to `/bar`

This is the different behaviour than the `return` directive provides:

```
server {
  location / {
    return 200;
    return 404;
  }
}
```
In the above case, the 200 status is returned immediately.

## Processing requests
Inside nginx, you can specify multiple virtual servers, each described by a `server { } `context.

```
server {
  listen      *:80 default_server;
  server_name netguru.co;

  return 200 "Hello from netguru.co";
}

server {
  listen      *:80;
  server_name foo.co;

  return 200 "Hello from foo.co";               
}

server {
  listen      *:81;
  server_name bar.co;

  return 200 "Hello from bar.co";
}
```

This will give nginx some insights on how to handle incoming requests. Nginx will first check the `listen` directive to test which virtual server is listening on the given IP:port combination. Then, the value from `server_name` directive is tested against the `Host` header, which stores domain name of the server.

Nginx will choose the `virtual server` in the following order:

1. Server listing on IP:port, with a matching `server_name` directive
2. Server listing on IP:port, with `default_server` flag
3. Server listing on IP:port, first one defined
4. If there are no matches, refuse the connection.

In the example above, this will mean:

```
Request to foo.co:80     => "Hello from foo.co"
Request to www.foo.co:80 => "Hello from netguru.co"
Request to bar.co:80     => "Hello from netguru.co"
Request to bar.co:81     => "Hello from bar.co"
Request to foo.co:81     => "Hello from bar.co"
```
### The `server_name` directive

The `server_name` directive accepts multiple values. It also handles wildcard matching and regular expressions.

```
server_name netguru.co www.netguru.co; # exact match
server_name *.netguru.co;              # wildcard matching
server_name netguru.*;                 # wildcard matching
server_name  ~^[0-9]*\.netguru\.co$;   # regexp matching
```

When there is ambiguity, nginx uses the following order:

1. Exact name
2. Longest wildcard name starting with an asterisk, e.g. “*.example.org”
3. Longest wildcard name ending with an asterisk, e.g. “mail.*”
4. First matching regular expression (in the order of appearance in the configuration file)

Nginx will store 3 hash tables: exact names, wildcards starting with an asterisk, and wildcards ending with an asterisk. If the result is not in any of the tables, regular expressions will be tested sequentially.

It is worth keeping in mind that

`server_name .netguru.co;`

is an abbreviation of:

`server_name  netguru.co  www.netguru.co  *.netguru.co;`

With one difference: `.netguru.co` is stored in the second table, which means that it is a bit slower than explicit declaration.

### `listen` directive

In most cases, you’ll find that the `listen` directive accepts IP:port values

```
listen 127.0.0.1:80;
listen 127.0.0.1;    # by default port :80 is used

listen *:81;
listen 81;           # by default all ips are used

listen [::]:80;      # IPv6 addresses
listen [::1];        # IPv6 addresses
```
However, it is also possible to specify UNIX-domain sockets

`listen unix:/var/run/nginx.sock;`

You can even use hostname

```
listen localhost:80;
listen netguru.co:80;
```

This should be used with caution, as the hostname may not be resolved upon nginx launch, causing nginx to be unable to bind on given TCP socket.

**Finally, if the directive is not present, *:80 is used.**

Minimal configuration

```
# /etc/nginx/nginx.conf

events {}                   # events context needs to be defined to consider config valid

http {
 server {
    listen 80;
    server_name  netguru.co  www.netguru.co  *.netguru.co;

    return 200 "Hello";
  }
}
```

### `root`, `location`, and `try_files` directives

`root` directive

`root` directive sets the root directory for requests, allowing nginx to map the incoming request onto the file system.

```
server {
  listen 80;
  server_name netguru.co;
  root /var/www/netguru.co;
}
```

Which allows nginx to return server content according to the request

```
netguru.co:80/index.html     # returns /var/www/netguru.co/index.html
netguru.co:80/foo/index.html # returns /var/www/netguru.co/foo/index.html
```

`location` directive

The `location` directive sets the configuration depending on requested URI.

`location [modifier] path`

```
location /foo {
  # ...
}
```

When no modifier is specified, the path is treated as prefix, after which anything can follow.
Above example will match

```
/foo
/fooo
/foo123
/foo/bar/index.html
...
```

Also, multiple `location` directives can be used in a given context

```
server {
  listen 80;
  server_name netguru.co;
  root /var/www/netguru.co;

  location / {
    return 200 "root";
  }

  location /foo {
    return 200 "foo";
  }
}
```

```
netguru.co:80   /       # => "root"
netguru.co:80   /foo    # => "foo"
netguru.co:80   /foo123 # => "foo"
netguru.co:80   /bar    # => "root"
```

Nginx also provide few modifiers, that can be used in conjunction with `location`. Those modifiers impact which location block will be used, as each modifier, has assigned precedence.

```
=           - Exact match
^~          - Preferential match
~ && ~*     - Regex match
no modifier - Prefix match
```

Nginx will first check for any exact matches. If it doesn't find any, it'll look for preferential ones. If this match also fails, regex matches will be tested in order of their appearance. If everything else fails, the last prefix match will be used.

```
location /match {
  return 200 'Prefix match: matches everything that starting with /match';
}

location ~* /match[0-9] {
  return 200 'Case insensitive regex match';
}

location ~ /MATCH[0-9] {
  return 200 'Case sensitive regex match';
}

location ^~ /match0 {
  return 200 'Preferential match';
}

location = /match {
  return 200 'Exact match';
}
```

```
/match     # => 'Exact match'
/match0    # => 'Preferential match'
/match1    # => 'Case insensitive regex match'
/MATCH1    # => 'Case sensitive regex match'
/match-abc # => 'Prefix match: matches everything that starting with /match'
```

the `try_files` directive

The `directive` will try different paths, returning whichever is found.

`try_files $uri index.html =404;`

So for `/foo.html` , it will try to return files in following order:

1. $uri ( /foo.html )
2. index.html
3. If none is found: 404.

What’s interesting, if we define `try_files` in a `server` context, and then define a location that matches all requests, our `try_files` will not be executed. This will happen because `try_files` in a `server` context defines its own pseudo-location, that is the least specific location possible. Therefore, defining `location /` will be more specific than our pseudo-location.

```
server {
  try_files $uri /index.html =404;

  location / {
  }
}
```

Thus, you should avoid `try_files` in a `server` context:

```
server {
  location / {
    try_files $uri /index.html =404;
  }
}
```

Reference:

[https://www.netguru.co/codestories/nginx-tutorial-basics-concepts](https://www.netguru.co/codestories/nginx-tutorial-basics-concepts)

