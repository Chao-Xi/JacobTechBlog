# Nginx Tutorial #3: SSL Setup
## SSL and TLS

SSL (standing for Socket Secure Layer) is a protocol providing a secure connection over HTTP.

SSL 1.0 was developed by Netscape, and never publicly released due to serious security flaws. SSL 2.0 was released in 1995, with some issues, which lead to final SSL 3.0, released in 1996.

The first version of TLS (Transport Layer Security) was written as an upgrade to SSL 3.0. Then TLS 1.1, and 1.2 came out. Right now, just behind the door, there is TLS 1.3 coming soon (which is truly something worth waiting for).
Technically SSL and TLS are different (as each is describing the different version of a protocol) - but many use those names interchangeably.

## Base SSL/TLS setup

In order to handle HTTPS traffic, you need to have SSL/TLS certificate in place. You can check appendix to generate free certificate via Let’s encrypt.

When you have the certificate in place, you can simply turn HTTPS by:

* start listening on a port `443` (default port that browsers will use when you type `https://sample.co`)
* providing certificate, and its key

```
server {
  listen 443 ssl default_server;
  listen [::]:443 ssl default_server;

  ssl_certificate /etc/nginx/ssl/netguru.crt;
  ssl_certificate_key /etc/nginx/ssl/netguru.key;
}
```

## TLS Session Resumption

Using HTTPS, **imposes TLS handshake**, on top of TCP one. **This increase significantly time**, before actual data transfer is made. Assuming that you are requesting `/image.jpg` from Warsaw, and connecting to the nearest server in Berlin:

```
Open connection

TCP Handshake:
Warsaw  ->------------------ synchronize packet (SYN) ----------------->- Berlin
Warsaw  -<--------- synchronise-acknowledgement packet (SYN-ACK) ------<- Berlin
Warsaw  ->------------------- acknowledgement (ACK) ------------------->- Berlin

TLS Handshake:
Warsaw  ->------------------------ Client Hello  ---------------------->- Berlin
Warsaw  -<------------------ Server Hello + Certificate ---------------<- Berlin
Warsaw  ->---------------------- Change Ciper Spec -------------------->- Berlin
Warsaw  -<---------------------- Change Ciper Spec --------------------<- Berlin

Data transfer:
Warsaw  ->---------------------- /image.jpg --------------------------->- Berlin
Warsaw  -<--------------------- (image data) --------------------------<- Berlin

Close connection
```
To save one roundtrip during TLS handshake, and computational cost of generating a new key, **we could reuse session parameters generated during the first request**. Client and the server could store session parameters behind the Session ID key. **During the next TLS handshake, the client can send the Session ID, and if the server will still have a proper entry in cache - parameters generated during the previous session will be reused**.

```
server {
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
}
```

## OCSP Stapling

SSL certificate can be revoked at any time. Browsers, in order to know if given certificate is no longer valid, need to perform an additional query via Online Certificate Status Protocol (OCSP). Instead of requiring users to perform given OCSP query, we could do it on the server, cache the result, and serve OCSP response to our clients, during TLS handshake. It is called OCSP stapling.

```
server {
  ssl_stapling on;
  ssl_stapling_verify on;                               # verify OCSP response
  ssl_trusted_certificate /etc/nginx/ssl/lemonfrog.pem; # tell nginx location of all intermediate certificates

  resolver 8.8.8.8 8.8.4.4 valid=86400s;                # resolution of the OCSP responder hostname
  resolver_timeout 5s;
}
```

## Security headers

Here some headers, worth turning on to grant more security. For more headers & detailed information you definitely should check the [OWASP Secure Headers Project.](https://www.owasp.org/index.php/OWASP_Secure_Headers_Project)

## HTTP Strict-Transport-Security

Or HSTS, in short, enforces user-agent to send all request to the origin over HTTPS.

```
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";
```

## X-Frame-Options

Indicates whether the browser should render or not a page in a frame, an iframe or an object tag.

```
add_header X-Frame-Options DENY;
```

## X-Content-Type-Options

This will prevent the browsers from [sniffing](https://en.wikipedia.org/wiki/Content_sniffing) the file, to deduct file type. The file will be interpreted as thing declared in the `Content-Type `header.

`add_header X-Content-Type-Options nosniff;`

## Server tokens

Another good practice is to hide information about your web server, in the HTTP response header field:

```
Server : nginx/1.13.2
```

This can be accomplished by disabling `server_tokens` directive:

```
server_tokens off;
```

## Appendix :: Let’s Encrypt

### Installation
Up to date can be found [here](https://certbot.eff.org/lets-encrypt/ubuntuother-nginx).

For testing purposes use [staging environment](https://letsencrypt.org/docs/staging-environment/), to not exhaust [rate limits](https://letsencrypt.org/docs/rate-limits/).

### Generate new certificate

```
certbot certonly --webroot --webroot-path /var/www/netguru/current/public/  \
          -d foo.netguru.co \
          -d bar.netguru.co
```

Make sure it can be properly renewed

```
certbot renew --dry-run
```

Make sure you have automatic renewing added to crontab. Run `crontab -e` and add the following line

```
0 3 * * * /usr/bin/certbot renew --quiet --renew-hook "/usr/sbin/nginx -s reload"
```

Check if SSL is working properly via [ssllabs](https://www.ssllabs.com/ssltest/)
