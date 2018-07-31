![Alt Image Text](images/headline1.jpg "headline")
# Nginx Tutorial #0: Install

## prerequisite:
install based on your machine
check my Linux Version, name & Kernel version

`uname -a`
`Linux ubuntu-xenial 4.4.0-98-generic #121-Ubuntu SMP Tue Oct 10 14:24:03 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux`

## install on  Ubuntu 16.04 (Xenial)

Append the appropriate stanza to `/etc/apt/sources.list`. If there is concern about persistence of repository additions (i.e. DigitalOcean Droplets), the appropriate stanza may instead be added to a different list file under `/etc/apt/sources.list.d/`, such as `/etc/apt/sources.list.d/nginx.list`.

```
## Replace $release with your corresponding Ubuntu release.
deb http://nginx.org/packages/ubuntu/ $release nginx
deb-src http://nginx.org/packages/ubuntu/ $release nginx
```

e.g. Ubuntu 16.04 (Xenial):

```
deb http://nginx.org/packages/ubuntu/ xenial nginx
deb-src http://nginx.org/packages/ubuntu/ xenial nginx
```

To install the packages, execute in your shell:

```
sudo apt-get update
sudo apt-get install nginx
```

> If a W: GPG error: http://nginx.org/packages/ubuntu xenial Release: The following signatures could not be verified because the public key is not available: NO_PUBKEY $key is encountered during the NGINX repository update, execute the following:

```
## Replace $key with the corresponding $key from your GPG error.
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
sudo apt-get update
sudo apt-get install nginx
```

## After installation

check nginx version:

```
nginx -v
nginx version: nginx/1.14.0

```

Tou may encouter permission deny problem to `/var/log/nginx`

```
sudo chown -R ubuntu-xenial:ubuntu-xenial /var/log/nginx
sudo chown -R ubuntu:ubuntu /var/log/nginx
```
