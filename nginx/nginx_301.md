![Alt Image Text](images/301.jpg "proxy server")
# Nginx中如何设置301跳转

网站中带`www`和不带都可以访问，但是这样却会不利于网站SEO的，会分权，所以需要将二者的访问合并到一起，这特别在网站架设之初就应该好好规划。

有很多的第三方DNS解析服务，提供了直接的显示跳转的服务，比如`dnspod`，但是最近我在使用的过程中发现该服务非常的不稳定，导致网站经常性的访问不了。所以就打算自己来做，方法很简单，就是`301跳转`，**301是永久跳转，302是临时性跳转**。

## nginx 配置

下面是我nginx中配置301跳转的方法：

`sudo vim /etc/nginx/sites-availables node-app`

```
server{

         listen 80;
         server_name ngtest.net www.ngtest.net;

         location / {
            proxy_pass http://192.168.33.17:3000;
         }

       if ($host != "www.ngtest.net" ) {
        rewrite ^/(.*)$ http://www.ngtest.net/$1 permanent;
      }
}
```

`sudo vim /etc/hosts`

```
192.168.33.17  ngtest.net servertest.net www.ngtest.net
```

reload nginx.conf

```
sudo nginx -s reload
```

```
curl http://www.ngtest.net/
Hello World
```

```
curl ngtest.net/
<html>
<head><title>301 Moved Permanently</title></head>
<body bgcolor="white">
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.14.0</center>
</body>
```

## Reference

[http://atulhost.com/301-redirect-in-nginx](http://atulhost.com/301-redirect-in-nginx)


