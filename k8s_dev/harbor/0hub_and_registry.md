# What is the difference between hub.docker.com and registry.docker.io?


## What is `http://hub.docker.com`

`http://hub.docker.com` is the **public docker image registry**. Here you’ll find both **official images** as well as images that are uploaded by anyone wishing to share what they’ve built. There’s also provisions for you to upload images you’d like to keep private for a fee. **It’s a SaaS platform**.

Simply, it's the **DNS name for Docker Hub** - the web UI for Docker’s container image registry for either public or private container images.


For example my docker hub:

### Docker Pull Command

```
docker pull nyjxi/jenkins-demo
```

### To push a new tag to this repository

```
docker push nyjxi/jenkins-demo:tagname
```


## What is `registry.docker.io`

`registry.docker.io` is actually a **CNAME** pointing to `registry-1.docker.io`, which is utilized if you would like to **setup a self-hosted registry as a pull-through cache**. 

**Say you don’t want multiple engines headed out to grab the same NGINX base image every time there’s a pull…that’s where a cache comes into play.**

### Registry as a pull through cache

#### [Configure the cache](https://docs.docker.com/registry/recipes/mirror/#configure-the-cache)

To configure a Registry to run as a pull through cache, the addition of a `proxy` section is required to the config file.

To access private images on the Docker Hub, a username and password can be supplied.

```
proxy:
  remoteurl: https://registry-1.docker.io
  username: [username]
  password: [password]
```

Simply, This is where the actual registry that images are pulled from. When you issue a command to download an image from Docker Hub (say `docker pull ubuntu:latest`), the command makes an API call to registry-1 to initiate the download (list the layers and then download each layer).


