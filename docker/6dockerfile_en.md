![Alt Image Text](images/headline13.jpg "Headline image")

# Docker Image Creation

## Docker image
Docker image can be described as a template with all required configuration. Whereas a container is a running instance of Docker image. Like containers, image are not bound to the states i.e. image does not have states.

There are different images available from OS/Application along with the custom images from community.

When working on container a Devops/Application engineer generally crate their all docker image with all customizations, this enable them to launch a container quickly

## Methods for custom image creation 

### Interactive Method:

In this way, you can download the 

**base Docker OS image -> create container -> manually launch a shell -> perform the customization -> commit the changes**


This process will save your container to a Docker image and that image can be stored/distributed.

### Automated method using Dockerfile:

Dockerfile is text file with directives/intructions for the image creation. "docker build" command is used to build the image with create/configures images automatically by reading the dockerfile. Dockerfile accept the information in the following format.

```
Directives   Arguments 
```

### LAB

Using the Dockerfile, we are going to create an `Apache HTTPD Web server on Centos7 image`. At high level below configuration will be performed/applied to the Docker mage

* Download the offical Centos7 image
* Perform package update on the image
* Install Apache HTTP Server
* Add a directive to include/copy the index.html from Docker gmt server to document root (i.e /var/www/html) of the image
* Enable port 80 of automatically whenever a container created from this image
* Configure the start-up of Apache HTTPD service

Below are the directives we going to use in the dockerfile

* FROM: this directive tells which base image to be used to create the custom image, example centos/ubuntu/fedora etc.
* RUN: this directive is used to define commands to be executed during the image build
* ADD: this directive is used to define the files/directories to be copied from the source(local server) to the image during image build
* ENTRYPOINT: this directive defines container as executable
* CMD: this directive is used to define the arguments for the ENTRYPOINT command
* EXPOSE: this directive defines the network ports on which container will listen

### Dockerfile Sample

**same dockerfile**

```
# use latest centos7 image
FROM centos:latest

# add the image maintainer name and email id
MAINTAINER Jacob email: xichao2017@gmail.com

# update the centos image with latest available updates
RUN yum update -y
RUN yum clean all

# install networks utilities, such as (ifconfig, netstat, etc)
RUN yum install net-tools -y

# install apache httpd web server
RUN yum install httpd -y
RUN yum clean all

#copy the index.html file from current directory to image's document root
ADD index.html /var/www/html/

# define image to allow listen on port 80 (whenever a container created)
EXPOSE 80

#define the commands to be executed when the container boots(created from this image)
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]
```

### Build image

```
sudo docker build -t [repository/image]:[tag] .
```

### Test the newly created image by creating a container

```
sudo docker run -it -d -P [image id]
curl [container IP]:80
```


###index.html Sample

```
<html>
<head><title> Docker image - Apache HTTPD Web Server on Centos</title></head>
<body>
    <p>This is demo page to confirm, Apache is configured and started</p>
    <p>With start of the container</p>
    <p>Jacob </p>
</body>
</html>
```

### Practice: build apache-centos:latest image

```
[vagrant@localhost apache]$ sudo docker build -t jacob/apache-centos:lastest .
Sending build context to Docker daemon 3.584 kB
Step 1/11 : FROM centos7:latest
Trying to pull repository docker.io/library/centos7 ...
repository docker.io/centos7 not found: does not exist or no pull access
[vagrant@localhost apache]$ sudo docker build -t jacob/apache-centos:latest .
Sending build context to Docker daemon 3.584 kB
Step 1/11 : FROM centos7:latest
Trying to pull repository docker.io/library/centos7 ...
repository docker.io/centos7 not found: does not exist or no pull access
[vagrant@localhost apache]$ vi index.html
[vagrant@localhost apache]$ vi Dockerfile
[vagrant@localhost apache]$ sudo docker build -t jacob/apache-centos:latest .
Sending build context to Docker daemon 3.584 kB
Step 1/11 : FROM centos:latest
 ---> e934aafc2206
Step 2/11 : MAINTAINER Jacob email: xichao2017@gmail.com
 ---> Running in fcdf11fb14cf
 ---> 36ddb65c5a69
Removing intermediate container fcdf11fb14cf
Step 3/11 : RUN yum update -y
 ---> Running in d9413b1d2c54

Loaded plugins: fastestmirror, ovl
Determining fastest mirrors
 * base: mirrors.163.com
 * extras: ftp.sjtu.edu.cn
 * updates: ftp.sjtu.edu.cn
Resolving Dependencies
--> Running transaction check
---> Package acl.x86_64 0:2.2.51-12.el7 will be updated
---> Package acl.x86_64 0:2.2.51-14.el7 will be an update
.....

Removing intermediate container 4be78ca2b083
Successfully built b353e1067ad6

```

* Jacob/apache-centos => repository
* Latest => tag


```
[vagrant@localhost apache]$ sudo docker images -a
REPOSITORY               TAG                 IMAGE ID            CREATED              SIZE
jacob/apache-centos      latest              b353e1067ad6        38 seconds ago       683 MB
```

```
#   docker run –it –d –P –h centos-apache image-id
#   [-h set hostname as centos-apache]


vagrant@localhost apache]$ sudo docker run -it -d -P -h centos-apache b353e1067ad6
436e3be78fdd8b7363e5156b6c7ac540e50435e1579eb324e3c2eb353b10384b
[vagrant@localhost apache]$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                   NAMES
436e3be78fdd        b353e1067ad6        "/usr/sbin/httpd -..."   6 seconds ago       Up 6 seconds        0.0.0.0:32768->80/tcp   gracious_ramanujan

```

```
[vagrant@localhost apache]$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "23decdfa721d3951ee791db0bbac77056cd88bd531b4fcc3c81c8c71d1ec64e9",
        "Created": "2018-08-05T10:04:23.711246451Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Containers": {
            "436e3be78fdd8b7363e5156b6c7ac540e50435e1579eb324e3c2eb353b10384b": {
                "Name": "gracious_ramanujan",
                "EndpointID": "3bc50b3dc2aa71b3d3cbcd672fc1525b77f5b8588c0b0f85ce2bb2a49c20a7dc",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

```
# "IPv4Address": "172.17.0.2/80"

[vagrant@localhost apache]$ curl 172.17.0.2:80
<html>
<head><title> Docker image - Apache HTTPD Web Server on Centos</title></head>
<body>
    <p>This is demo page to confirm, Apache is configured and started</p>
    <p>With start of the container</p>
    <p>Jacob </p>
</body>
</html>
```

```
[vagrant@localhost apache]$ sudo yum install links -y
[vagrant@localhost apache]$  links 172.17.0.2

```