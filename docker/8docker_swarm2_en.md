![Alt Image Text](images/headline15.jpg "Headline image")

# Docker Swarm cluster creation and management
## Docker swarm

Swarm is native clustering for the Docker. When the Docker Engine run in swarm node, manager nodes implement the [Raft Consensus Algorithm](https://raft.github.io/) to manage the global cluster state. The reason why Docker Swarm is using consensus algorithm is to make sure that all the manager nodes that are in charge of managing and scheduling tasks in the cluster, are storing the same consistent state.

## LAB Setup
In this LAB we are going to create a SWARM with single manager and 2 work nodes

**Operating System**: CentOS Linux release 7.4.1708 (Core)

```
[vagrant@localhost ~]$ cat /etc/redhat-release
CentOS Linux release 7.4.1708 (Core)
```
**Platform**: Vagrant Machines

Manager Node:  manger |  192.168.33.16/24
Worker Node 1: node1  |  192.168.33.13/24
Worker Node 2: node1  |  192.168.33.18/24

Change the name for three nodes, from localhost to node names 

```
sudo hostnamectl set-hostname manager
hostnamectl status

sudo hostnamectl set-hostname node1
hostnamectl status

sudo hostnamectl set-hostname node2
hostnamectl status
```

## Pre-Requsites:

1. Install Docker Engine. We going to install "ce" (community engine)

* Uninstall old versions

```
$ sudo yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine

```

* set up the repository install required packages

```
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

```

* Use the following command to set up the stable repository

```
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

```

* install docker ce

```
sudo yum install docker-ce
```

* list available docker versions

```
yum list docker-ce --showduplicates | sort -r
```

* start docker service

```
systemctl start docker
systemctl enable docker
systemctl status docker

```

2. Network connectivity between all nodes and manager
3. Following Open network ports

```
TCP port 2377 for cluster management communications
TCP and UDP port 7946 for communication and manager
UDP port 4789 for overlay traffic
```

## Start Swarm Cluster:

### start cluster on your manger node

```
docker swarm init --advertise-addr manager_node_ip
docker swarm init --advertise-addr 192.168.33.16

[vagrant@localhost ~]$ docker swarm init --advertise-addr 192.168.33.16
Swarm initialized: current node (nxxovwnbe336z68u2n5vrrwvw) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-32hw9gpdh1c3rp1qvbsc3er8lgkeofkrh8kcjiiiatkwooiade-6ty733r90el4jh1ggure9ejpw \
    192.168.33.16:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

```

### join other node into the swarm, and on each work node, run:

```
docker swarm join \
    --token SWMTKN-1-32hw9gpdh1c3rp1qvbsc3er8lgkeofkrh8kcjiiiatkwooiade-6ty733r90el4jh1ggure9ejpw \
192.168.33.16:2377

```

### list nodes on the manger node

```
[vagrant@localhost ~]$ docker node ls
ID                           HOSTNAME               STATUS  AVAILABILITY  MANAGER STATUS
j1f1a6kz3fwf17ldc86psfjnp    node1                  Ready   Active
nxxovwnbe336z68u2n5vrrwvw *  localhost.localdomain  Ready   Active        Leader
vytan0cgsj95d5y5s58xqlz4l    node2                  Ready   Active
```

### check docker info and swarm info

```
[vagrant@localhost ~]$ docker info
Containers: 5
 Running: 1
 Paused: 0
 Stopped: 4
Images: 23
Server Version: 1.13.1
Storage Driver: overlay2
 Backing Filesystem: xfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: journald
Cgroup Driver: systemd
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
Swarm: active
 NodeID: nxxovwnbe336z68u2n5vrrwvw
 Is Manager: true
 ClusterID: jpozkbregmlx3mexyac4bho8v
 Managers: 1
 Nodes: 3
 Orchestration:
  Task History Retention Limit: 5
 Raft:
  Snapshot Interval: 10000
  Number of Old Snapshots to Retain: 0
  Heartbeat Tick: 1
  Election Tick: 3
 Dispatcher:
  Heartbeat Period: 5 seconds
 CA Configuration:
  Expiry Duration: 3 months
 Node Address: 192.168.33.16
 Manager Addresses:
  192.168.33.16:2377
Runtimes: docker-runc runc
Default Runtime: docker-runc
Init Binary: docker-init
containerd version:  (expected: aa8187dbd3b7ad67d8e5e3a15115d3eef43a7ed1)
runc version: N/A (expected: 9df8b306d01f59d3a8029be411de015b7304dd8f)
init version: N/A (expected: 949e6facb77383876aeff8a6944dde66b3089574)
Security Options:
 seccomp
  WARNING: You're not using the default seccomp profile
  Profile: /etc/docker/seccomp.json
Kernel Version: 3.10.0-693.5.2.el7.x86_64
Operating System: CentOS Linux 7 (Core)
OSType: linux
Architecture: x86_64
Number of Docker Hooks: 3
CPUs: 1
Total Memory: 488.4 MiB
Name: localhost.localdomain
ID: GBS4:ATVX:UHPW:OELX:7ZFT:6X2I:67OO:PVG5:FFWH:I6EY:UBBX:AOPE
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
WARNING: bridge-nf-call-ip6tables is disabled
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
Registries: docker.io (secure)
```
### swarm info

```
Swarm: active
 NodeID: nxxovwnbe336z68u2n5vrrwvw
 Is Manager: true
 ClusterID: jpozkbregmlx3mexyac4bho8v
 Managers: 1
 Nodes: 3
 Orchestration:
  Task History Retention Limit: 5
 Raft:
  Snapshot Interval: 10000
  Number of Old Snapshots to Retain: 0
  Heartbeat Tick: 1
  Election Tick: 3
 Dispatcher:
  Heartbeat Period: 5 seconds
 CA Configuration:
  Expiry Duration: 3 months
 Node Address: 192.168.33.16
 Manager Addresses:
  192.168.33.16:2377
```

### To see the token

``` 
# docker swarm join-token manager             #Display the token for manager to join
# docker swarm join-token worker              #Display the token for worker to join   
```

```
[vagrant@localhost ~]$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-32hw9gpdh1c3rp1qvbsc3er8lgkeofkrh8kcjiiiatkwooiade-4wcerxsbuai4d580ucvb8adg8 \
    192.168.33.16:2377
    

[vagrant@localhost ~]$ docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-32hw9gpdh1c3rp1qvbsc3er8lgkeofkrh8kcjiiiatkwooiade-6ty733r90el4jh1ggure9ejpw \
    192.168.33.16:2377  
```

## Swarm Cluster Mangement

Managing a cluster is one of the regular tasks and Admins need have understanding of the Swarm and its management commands

##  States

### Availability: column shows whether or not the scheduler can assign taksks to the nodes

**active:** scheduler can assign tasks to the node

**pause:** scheduler doesn't assign new tasks to the node, but existing task remain running

**drain:** scheduler doesn't assign new tasks to the node, but existing task will move to other nodes


###  Manger Status: column shows node participation in the raft consensus

**No value:** indicates a worker node that does not participate in swarm management

**leader:** node is the primary manager that makes all swarm management and decisions

**reachable:** node is manager node participating in Raft consensus quorum.

**unavailable:** node is manager node that is not able to communicate with other managers.

## Management commands

```
# docker node update --availability drain <node>    #update the states of manager/work node
# docker node promote <node>                        #promote the node as manager
# docker node demote <node>                         #demote the node from manager role
# docker node update --label-add Env=Dev <node>     #Add labels to the node's metadata
# docker swarm leave                                #Node leaves the cluster
# docker node rm <node>                             #Removes the node from cluter
```

### promote `node1` and demote `localhost.localdomain`

```
[vagrant@localhost ~]$ docker node promote node1
Node node1 promoted to a manager in the swarm.


[vagrant@localhost ~]$ docker node ls
ID                           HOSTNAME               STATUS  AVAILABILITY  MANAGER STATUS
j1f1a6kz3fwf17ldc86psfjnp    node1                  Ready   Active        Reachable
nxxovwnbe336z68u2n5vrrwvw *  localhost.localdomain  Ready   Active        Leader
vytan0cgsj95d5y5s58xqlz4l    node2                  Ready   Active


[vagrant@localhost ~]$ docker node demote localhost.localdomain
Manager localhost.localdomain demoted in the swarm.

[vagrant@localhost ~]$ docker node ls
Error response from daemon: This node is not a swarm manager. Worker nodes can't be used to view or modify cluster state. Please run this command on a manager node or promote the current node to a manager.
```

Currently, we need list the node on the new manager node, on node1

```
[vagrant@node1 ~]$ sudo docker node ls
ID                           HOSTNAME               STATUS  AVAILABILITY  MANAGER STATUS
j1f1a6kz3fwf17ldc86psfjnp *  node1                  Ready   Active        Leader
nxxovwnbe336z68u2n5vrrwvw    localhost.localdomain  Ready   Active
vytan0cgsj95d5y5s58xqlz4l    node2                  Ready   Active
```

### Check every node state on manager node

```
[vagrant@localhost ~]$ docker node inspect node1 --pretty
ID:			j1f1a6kz3fwf17ldc86psfjnp
Hostname:		node1
Joined at:		2018-08-08 02:49:06.419481534 +0000 utc
Status:
 State:			Ready
 Availability:		Active
 Address:		192.168.33.13
Platform:
 Operating System:	linux
 Architecture:		x86_64
Resources:
 CPUs:			1
 Memory:		488.4 MiB
Plugins:
  Network:		bridge, host, macvlan, null, overlay
  Volume:		local
Engine Version:		1.13.1
```

### Add label to current nodes

```
[vagrant@localhost ~]$ docker node update --label-add Env=Dev node1
node1

[vagrant@localhost ~]$ docker node inspect node1 --pretty
ID:			j1f1a6kz3fwf17ldc86psfjnp
Labels:
 - Env = Dev
Hostname:		node1
Joined at:		2018-08-08 02:49:06.419481534 +0000 utc
Status:
 State:			Ready
 Availability:		Active
 Address:		192.168.33.13
Platform:
 Operating System:	linux
 Architecture:		x86_64
Resources:
 CPUs:			1
 Memory:		488.4 MiB
Plugins:
  Network:		bridge, host, macvlan, null, overlay
  Volume:		local
Engine Version:		1.13.1

```

### Node leave from swarm

```
docker swarm leave --force
docker swarm leave 
```
### Remove node from swarm on manager node

```
docker node rm node_name
```


