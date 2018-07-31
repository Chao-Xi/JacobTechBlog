# Nginx Practice #2: Nginx reverse proxy based on request urls

## Reference:
[https://gist.github.com/soheilhy/8b94347ff8336d971ad0](https://gist.github.com/soheilhy/8b94347ff8336d971ad0)


## Start another node application on different port

```
screen -r 16988.pts-0.ubuntu-xenial
ctrl + a + c  # create enw window
mkdir blog && cd blog
sudo vim blog.js
```

Another nodejs 'blog.js' with another 'port : 3001'

```
var http = require('http');

http.createServer(function (request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.end('Hello Blog');
}).listen(3001);

console.log('Server started');
```

```
node blog.js
curl http://192.168.33.17:3001
#output Hello Blog
```

## Add /blog to nginx config

`sudo vim /etc/nginx/sites-availables node-app`

```
server{

         listen 80;
         location / {
            proxy_pass "http://192.168.33.17:3000";
         }

         location /blog {
           # rewrite ^/blog(.*) $1 break;
            proxy_pass "http://192.168.33.17:3001";
         }

}
```

Reload nginx Configuration

`sudo nginx -s reload`

check the reverse proxy run correctly:

```
curl http://192.168.33.17  # output Hello World
curl http://192.168.33.17/blog   #output Hello Blog

```

# Nginx Practice #3: Nginx reverse proxy for multiple hostnames

##Redirecting Based on Host Name

Let say you want to host `ngtest.net`, `servertest.net` on your machine, respectively to `localhost:3000`, `localhost:3001`

Note: Since you don't have access to a DNS server, you should add domain name entries to your /etc/hosts:

```
sudo vim /etc/hosts
192.168.33.17  ngtest.net servertest.net
```
To proxy `ngtest.ne`t we can't use the location part of the default server. Instead we need to add another server section with a server_name set to our virtual host (e.g., `ngtest.net`, ...), and then a simple location section that tells nginx how to proxy the requests:

`sudo vim node-app`

```
server{

         listen 80;
         server_name ngtest.net;

         location / {
            proxy_pass http://192.168.33.17:3000;
         }
}

server{
         listen 80;
         server_name servertest.net;

         location / {
            proxy_pass http://192.168.33.17:3001;
         }
}
```

Reload nginx Configuration

`sudo nginx -s reload`

check the reverse proxy run correctly:

```
curl ngtest.net       #Hello World
curl servertest.net   #Hello Blog
```