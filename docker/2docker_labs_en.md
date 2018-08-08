![Alt Image Text](images/headline11.jpg "Headline image")

# Docker Lab Tasks

### Download Docker images 

```
sudo docker pull centos:centos7
```
```
Trying to pull repository docker.io/library/centos ...
centos7: Pulling from docker.io/library/centos
7dc0dca2b151: Pull complete
Digest: sha256:b67d21dfe609ddacf404589e04631d90a342921e81c40aeaf3391f6717fa5322
Status: Downloaded newer image for docker.io/centos:centos7
```

### To display the list if locally available images, type

```
$ sudo docker images

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker.io/centos    centos7             49f7960eb7e4        8 weeks ago         200 MB
```

### To test your new image, type

```
sudo docker run centos:centos7 /bin/ping google.com -c 5
```

### List Docker containers

```
sudo docker ps -a
```

### Checking Docker Networking

```
$ sudo docker network ls 
NETWORK ID          NAME                DRIVER              SCOPE
1677444689e9        bridge              bridge              local
534730f8ecca        docker_gwbridge     bridge              local
38dc9c676fc3        host                host                local
e372cc1a0ba2        none                null                local
```
```
sudo docker network inspect [Network Name]
```
```
$ sudo docker network inspect docker_gwbridge

[
    {
        "Name": "docker_gwbridge",
        "Id": "534730f8ecca7002e2db481d85e356c1814ec649ae29f44ae69087368ec762a9",
        "Created": "2017-11-16T09:14:18.60650687Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.enable_icc": "false",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.name": "docker_gwbridge"
        },
        "Labels": {}
    }
]
```

### Check resource consumption by running containers

```
$ sudo docker stats
```
### setting Resource limits for docker container

```
$ sudo docker run -it -c 256 -m 300M centos:centos7 /bin/bash
#[run the container and assign it 300M memory]
```

### Stop/Start/Restart operations

```
$ docker start [container id]
$ docker stop [container id]
$ docker restart [container id]
```

### Get into a Docker container

```
$ sudo docker exec -it container_id bash
```

### Committing the Docker Updates (This command turns your container to an image)

```
sudo docker commit [container id]
```
```
docker commit [option] <container_id or container_id > [<REPOSITORY>[:<tag>]]

```
```
sudo docker commit 4be2470c1199 centos:jxi
```

### List all Docker images
```
sudo docker images -a
```
```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              jxi                 beb0d5b15871        15 seconds ago      200 MB
docker.io/centos    centos7             49f7960eb7e4        8 weeks ago         200 MB
```

### Adding a Repository/Tag value to a image

```
sudo docker tag [container id] <repo : tags>
```

### Removing / Deleting a container

```
sudo docker rm [containerID]
```

### Checking the docker container Logs

```
sudo docker logs [containerID]
```

### Lets create our container and host a demo website quickly using python SimpleHTTPserver module which listen on port 8080

**List all packages**

```
rpm -a     #list all installed packages
rpm –qa | grep httpd
```

**create webpage run as container**

```
sudo mkdir -p /var/www/html 
su -
echo "This is Jacob' Test Docker website" > /var/www/html/demowebpage.txt
```

**use docker to run the webpage on the server**

```
docker run -d -p 8080:8080 --name="python_web" -v /usr/sbin:/usr/sbin -v /usr/bin:/usr/bin -v /usr/lib64:/usr/lib64 -w /var/www/html -v /var/www/html:/var/www/html centos:centos7 /bin/python -m SimpleHTTPServer 8080 
```

1. -d "--detach " Run container in background and print container ID
2. --name=""      Assign a name to the container
3. -v --volume=[host-src:] : container-dest[:] 
4. -w --workdir="" Working directory inside the container
5. IMAGE centos:centos7
6.  -m, --memory=""  Memory limit
7. /bin/python -m SimpleHTTPServer 8080  using Python's SimpleHTTPServer module

Reference: [https://docs.docker.com/v1.11/engine/reference/commandline/run/](https://docs.docker.com/v1.11/engine/reference/commandline/run/)


```
curl localhost:8080/demowebpage.txt
This is Jacob' Test Docker website
```
**Use different port**

```
docker run -d -p 8081:8081 --name="python_web1"  centos:centos7 /bin/python -m SimpleHTTPServer 8082
```

**list all docker container**

```
$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
577dfcffa38b        centos:centos7      "/bin/python -m Si..."   2 minutes ago       Up 2 minutes        0.0.0.0:8081->8081/tcp   python_web1
99f3ee29179b        centos:centos7      "/bin/python -m Si..."   17 minutes ago      Up 17 minutes       0.0.0.0:8080->8080/tcp   python_web
4be2470c1199        centos:centos7      "/bin/bash"              4 hours ago         Up 4 hours                                   lucid_wing
```
*** Committing the Docker Updates into image ***

```
sudo docker commit  99f3ee29179b jacob/python-web:testpythonwebserver
```
```
$ sudo docker images -a

sudo docker images -a
REPOSITORY          TAG                   IMAGE ID            CREATED             SIZE
jacob/python-web    testpythonwebserver   274abed832d4        43 seconds ago      200 MB
centos              jxi                   beb0d5b15871        2 hours ago         200 MB
docker.io/centos    centos7               49f7960eb7e4        8 weeks ago         200 MB
```

