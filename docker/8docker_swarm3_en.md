![Alt Image Text](images/headline16.jpg "Headline image")

# Docker Swarm service

**Service is the definition of the tasks to execute on the worker nodes.** It's the central structure of swarm system and the primary root of user interaction with the swarm. When you create a service, you specify which container image to use and which commands to execute inside running containers

## Running Services in the Docker Swarm 
We have swarm cluster up and we are ready to deploy the services. In this demo we will deploy service name "webserver" which will be using "nginx" docker images

```
[vagrant@localhost ~]$ docker service create -p 8080:80 --name webserver nginx
bj7v664y9okt5za7ysxt3em6j
```

In the above example, we're mapping `port 80` in the Nginx container to `port 8080` on the cluster so that we can access the default Nginx from anywhere

**list service and check which node is being used to run the serive**

```
[vagrant@localhost ~]$ docker service ls
ID            NAME       MODE        REPLICAS  IMAGE
bj7v664y9okt  webserver  replicated  0/1       nginx:latest


[vagrant@localhost ~]$ docker service ps webserver
ID            NAME         IMAGE         NODE   DESIRED STATE  CURRENT STATE               ERROR  PORTS
jz9xmozrpukg  webserver.1  nginx:latest  node1  Running        Running about a minute ago

```
```
[vagrant@localhost ~]$ curl  192.168.33.16:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## Swarm Service modes

Swarm service support 2 modes, **Replicated** and **Global** (replicated mode is default)

**Replicated mode** - you can pass number of replica of the service and swarm maintain that count

***Example of Replicated mode***

```
[vagrant@localhost ~]$ docker service create --name replicated_server --replicas 3 nginx
wyr2hin1jan1jbwwuyablyg69
```

```
[vagrant@localhost ~]$ docker service ps replicated_server
ID            NAME                 IMAGE         NODE                   DESIRED STATE  CURRENT STATE           ERROR  PORTS
cidvzpggj9zz  replicated_server.1  nginx:latest  localhost.localdomain  Running        Running 6 seconds ago
evmqd0fqfst3  replicated_server.2  nginx:latest  node2                  Running        Running 2 seconds ago
5t46c51zzy3z  replicated_server.3  nginx:latest  node1                  Running        Running 22 seconds ago
```
```
[vagrant@localhost ~]$ docker service ls
ID            NAME               MODE        REPLICAS  IMAGE
bj7v664y9okt  webserver          replicated  1/1       nginx:latest
wyr2hin1jan1  replicated_server  replicated  3/3       nginx:latest
```

**Global mode** - To start a global service on each available node, pass --mode global to docker service create. Every time a new node becomes available, the scheduler places a task for the global service on the new node.

***Example of Global mode***

```
[vagrant@localhost ~]$ docker service create --name global_service --mode global nginx
kna2z1h3gqtag9qlgky9q0h5h
```

```
[vagrant@localhost ~]$ docker service ls
ID            NAME               MODE        REPLICAS  IMAGE
bj7v664y9okt  webserver          replicated  1/1       nginx:latest
kna2z1h3gqta  global_service     global      3/3       nginx:latest
wyr2hin1jan1  replicated_server  replicated  3/3       nginx:latest

```

### To view services on a cluster

```
docker service ls 
docker service inspect --pretty <ServiceName | ServiceID>
```
```
[vagrant@localhost ~]$ docker service inspect --pretty bj7v664y9okt

ID:		bj7v664y9okt5za7ysxt3em6j
Name:		webserver
Service Mode:	Replicated
 Replicas:	1
Placement:
UpdateConfig:
 Parallelism:	1
 On failure:	pause
 Max failure ratio: 0
ContainerSpec:
 Image:		nginx:latest@sha256:d85914d547a6c92faa39ce7058bd7529baacab7e0cd4255442b04577c4d1f424
Resources:
Endpoint Mode:	vip
Ports:
 PublishedPort 8080
  Protocol = tcp
  TargetPort = 80
```


### To determine which nodes the services is running on by using docker service ps followed by the service name

```
docker service ps <ServiceNAME | ServiceID>
```
Docker by default use mesh networking, a service running on a node can be accessed on any other node of the cluster

###  Scale Up/Down the service

```
docker service scale <Service> = <number of replica>
```

### Remove the service

```
docker service rm <ServiceNAME|ServiceID>

```

```
[vagrant@localhost ~]$ docker service scale replicated_server=2
replicated_server scaled to 2

[vagrant@localhost ~]$ docker service ls
ID            NAME               MODE        REPLICAS  IMAGE
bj7v664y9okt  webserver          replicated  1/1       nginx:latest
kna2z1h3gqta  global_service     global      3/3       nginx:latest
wyr2hin1jan1  replicated_server  replicated  2/2       nginx:latest
```

## How to stop the Manager to act as Worker

### Docker swarm manager act as worker too?

Yes, by default all managers act worker node. Main reason is , in a single manager node cluster, you can run commands like docker service create and the scheduler will place all tasks on local engine

### How can I stop the manager to act as worker

To prevent the scheduler from placing tasks on a manager node in multi-node swarm, set the availability for the manager node to Drain. The scheduler gracefully stop tasks on nodes in Drain mode and schedules the tasks on Active node. The scheduler does not assign tasks to nodes with Drain availability

```
docker node update --availability drain <MangerNode>
```
```
[vagrant@localhost ~]$ docker node update --availability drain localhost.localdomain
localhost.localdomain

[vagrant@localhost ~]$ docker node ls
ID                           HOSTNAME               STATUS  AVAILABILITY  MANAGER STATUS
j1f1a6kz3fwf17ldc86psfjnp    node1                  Ready   Active
nxxovwnbe336z68u2n5vrrwvw *  localhost.localdomain  Ready   Drain         Leader
vytan0cgsj95d5y5s58xqlz4l    node2                  Ready   Active


[vagrant@localhost ~]$ docker service ls
ID            NAME               MODE        REPLICAS  IMAGE
bj7v664y9okt  webserver          replicated  1/1       nginx:latest
kna2z1h3gqta  global_service     global      2/2       nginx:latest
wyr2hin1jan1  replicated_server  replicated  2/2       nginx:latest

[vagrant@localhost ~]$ docker service ps replicated_server
ID            NAME                 IMAGE         NODE   DESIRED STATE  CURRENT STATE          ERROR  PORTS
evmqd0fqfst3  replicated_server.2  nginx:latest  node2  Running        Running 4 minutes ago
5t46c51zzy3z  replicated_server.3  nginx:latest  node1  Running        Running 5 minutes ago

[vagrant@localhost ~]$ docker node update --availability active localhost.localdomain
localhost.localdomain

[vagrant@localhost ~]$ docker node ls
ID                           HOSTNAME               STATUS  AVAILABILITY  MANAGER STATUS
j1f1a6kz3fwf17ldc86psfjnp    node1                  Ready   Active
nxxovwnbe336z68u2n5vrrwvw *  localhost.localdomain  Ready   Active        Leader
vytan0cgsj95d5y5s58xqlz4l    node2                  Ready   Active


 # replicated_service only two start
[vagrant@localhost ~]$ docker service ps replicated_server
ID            NAME                     IMAGE         NODE                   DESIRED STATE  CURRENT STATE            ERROR  PORTS
u89k8yavs4js  replicated_server.1      nginx:latest  node2                  Running        Running 58 seconds ago
xsdsgtcmv9xr   \_ replicated_server.1  nginx:latest  localhost.localdomain  Shutdown       Shutdown 58 seconds ago
evmqd0fqfst3  replicated_server.2      nginx:latest  node2                  Running        Running 10 minutes ago
5t46c51zzy3z  replicated_server.3      nginx:latest  node1                  Running        Running 10 minutes ago


 # global_service three start three following number of node
[vagrant@localhost ~]$ docker service ps global_service
ID            NAME                                          IMAGE         NODE                   DESIRED STATE  CURRENT STATE         ERROR  PORTS
0wyyhh42vmtb  global_service.nxxovwnbe336z68u2n5vrrwvw      nginx:latest  localhost.localdomain  Running        Running 5 hours ago
j4o5061iu8lj   \_ global_service.nxxovwnbe336z68u2n5vrrwvw  nginx:latest  localhost.localdomain  Shutdown       Shutdown 5 hours ago
i8bu6ytcgu6c  global_service.vytan0cgsj95d5y5s58xqlz4l      nginx:latest  node2                  Running        Running 5 hours ago
no0any5511r2  global_service.nxxovwnbe336z68u2n5vrrwvw      nginx:latest  localhost.localdomain  Shutdown       Shutdown 5 hours ago
17qn7c98zxkz  global_service.j1f1a6kz3fwf17ldc86psfjnp      nginx:latest  node1                  Running        Running 5 hours ago

```
 