# Nginx Practice #1: Reverse proxy for node web application

## What is Reverse proxy server

A proxy server is a go‑between or intermediary server that forwards requests for content from ***multiple clients*** to **different servers** across the Internet.

![Alt Image Text](proxy_server.jpg "proxy server")

A **reverse proxy server** is a type of **proxy server** that typically sits behind the firewall in a private network and directs client requests to the appropriate backend server. 

A reverse proxy provides an additional level of abstraction and control to ensure the smooth flow of network traffic between clients and servers.

![Alt Image Text](reverse_proxy.jpg "reverse server")

Common uses for a **[reverse proxy server](https://www.nginx.com/resources/admin-guide/reverse-proxy/)** include:

* **Load balancing** – A reverse proxy server can act as a “traffic cop,” sitting in front of your backend servers and distributing client requests across a group of servers in a manner that maximizes speed and capacity utilization while ensuring no one server is overloaded, which can degrade performance. If a server goes down, the [load balancer](http://nginx.org/en/docs/http/load_balancing.html) redirects traffic to the remaining online servers.
* **Web acceleration** – Reverse proxies can compress inbound and outbound data, as well as cache commonly requested content, both of which speed up the flow of traffic between clients and servers. They can also perform additional tasks such as SSL encryption to take load off of your web servers, thereby [boosting their performance](https://www.nginx.com/resources/glossary/web-acceleration/).
* **Security and anonymity** – By intercepting requests headed for your backend servers, a reverse proxy server protects their identities and acts as an additional defense against security attacks. It also ensures that multiple servers can be accessed from a single record locator or URL regardless of the structure of your local area network.

## Quick install nodejs on Linux

### Reference: 
[https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-16-04](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-16-04)

### Install Using NVM

```
sudo apt-get update
sudo apt-get install build-essential libssl-dev

curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh -o install_nvm.sh
nano install_nvm.sh

bash install_nvm.sh
source ~/.profile

nvm ls-remote.  #v10.7.0
nvm install v10.7.0
nvm use v10.7.0

node -v   #v10.7.0

nvm ls 
```

## Start simple 'hello world' nodejs 

```
mkdir hello && cd hello
vim hello.js
```

The content of hello.js

```
var http = require('http');

http.createServer(function (request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.end('Hello World\n');
}).listen(3000);

console.log('Server started');

```

**Use screen to start this nodejs**

```
screen
cd cd hello
node hello.js         #output: Server started
ctrl + a + d          #detaching from screen and keep nodejs running
                      #output [detached from 16988.pts-0.ubuntu-xenial]

screen -r 16988.pts-0.ubuntu-xenial.  #Reattach to Screen
```

check the nodejs run correctly:

```
curl http://127.0.0.1:3000
#or
curl http://192.168.33.17:3000
#output: Hello World
```

## Create Reverse proxy for nodejs 

Find out the nginx real conf path

`systemctl status nginx.service`

```
● nginx.service - nginx - high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2018-07-29 07:49:29 UTC; 20h ago
     Docs: http://nginx.org/en/docs/
  Process: 13250 ExecStop=/bin/kill -s TERM $MAINPID (code=exited, status=0/SUCCESS)
  Process: 13304 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 13308 (nginx)
    Tasks: 2
   Memory: 1.5M
      CPU: 28ms
   CGroup: /system.slice/nginx.service
           ├─13308 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.con
           └─17244 nginx: worker process

Jul 29 07:49:29 ubuntu-xenial systemd[1]: Starting nginx - high performance web server...
Jul 29 07:49:29 ubuntu-xenial systemd[1]: Started nginx - high performance web server.
```
The nginx.conf located in `/etc/nginx/`

create two folders, one of available conf and one for enable conf 

```
cd /etc/nginx/
sudo mkdir sites-availables
sudo mkdir sites-enabled
cd sites-availables
```

create special conf file for nodejs

`sudo vim node-app`

```
server{

         listen 80;
         location / {
            proxy_pass "http://192.168.33.17:3000";
         }

}
```
create soft link of node-app from sites-availables to sites-enabled

`sudo ln -s /etc/nginx/sites-availables/node-app /etc/nginx/sites-enabled/node-app`

change the nginx.conf for this new conf file

```
sudo cp nginx.conf.bak nginx.conf
sudp vim nginx.conf
# comment: include /etc/nginx/conf.d/*.conf;
# add new: include /etc/nginx/sites-enabled/node-app;

```

reload nginx.conf

```
sudo nginx -s reload
```
check the reverse proxy run correctly:

```
curl http://192.168.33.17/
Hello World
```
