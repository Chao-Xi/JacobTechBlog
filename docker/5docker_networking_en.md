![Alt Image Text](images/headline12.jpg "Headline image")

# Customize the DOCKER networking

### Why to use custom Network subnet for Docker Networking

Docker container make uses of default subnet "172.17.0.0/16" for Networking. There are be scenarios where we can't use the default network due to some restrictions or in case subnet already used in the network

### Lab Tasks

In this quick session, we will change the network from default subnet `172.17.0.0/16` to `10.10.10.10/24`

### Configure the custom networking

**stop the Docker Service**

```
sudo systemctl stop docker.service
```
**Bring down the Docker bridge docker0**

```
ip link set dev docker0 down
```
**Verify Ip forwarding is enabled, if not enable it in sysctl.conf**

```
[vagrant@node1 ~]$ sudo sysctl net.ipv4.conf.all.forwarding
net.ipv4.conf.all.forwarding = 1
```


Update new subnet in /etc/sysconfig/docker-network add the following to:

```
# /etc/sysconfig/docker-network
DOCKER_NETWORK_OPTIONS=
```

```
"--bip=YOUR.CIDR.ADDRESS/24"
```

Example:

```
DOCKER_NETWORK_OPTIONS="--bip=10.10.10.10/24"
```

Remove default subnet's `MAQUERADE` rules from the `POSTROUTING` chain in network iptables.

```
iptables -t nat -F POSTROUTING
iptables -F DOCKER

```

Start Docker service

```
sudo systemctl start docker service
```

Verify that `MAQUERADE` rule have new subnet added to the `POSTROUTING` chain

```
iptables -t nat -L -n
```

### Practice

```
[vagrant@node1 ~]$ sudo iptables -t nat -L -n

-t [table to manipulate]     nat
-L list the rules in a chain or all chains
-n numeric output of address and ports

Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0
MASQUERADE  tcp  --  172.17.0.2           172.17.0.2           tcp dpt:5000
MASQUERADE  tcp  --  172.17.0.3           172.17.0.3           tcp dpt:80
MASQUERADE  tcp  --  172.17.0.3           172.17.0.3           tcp dpt:20

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:5000 to:172.17.0.2:5000
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:172.17.0.3:80
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:10122 to:172.17.0.3:20

```

```
sudo systemctl  start docker.service
sudo systemctl status docker.service

[vagrant@node1 ~]$ sudo ip add show docker0
5: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 02:42:d7:a0:d2:95 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:d7ff:fea0:d295/64 scope link
       valid_lft forever preferred_lft forever

[vagrant@node1 ~]$ sudo ip link set dev docker0 up

```

## Validation

### Check the new subnet is on the bridge now

```
$ sudo docker network inspect bridge
```
```
[
    {
        "Name": "bridge",
        "Id": "d7e7d27794bfcc45c0c07343b9a57096ee4a40b93aee554ea275e724a43a3443",
        "Created": "2018-08-02T15:58:27.879803995Z",
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
            "25b88f3e7e73943b4fc773da3ba0f136e9892691f8e6257d9d62c46ebe157f08": {
                "Name": "db3",
                "EndpointID": "29c91d7f206fcce48c031c41c207efad1e21c5b44b77d6bfe3f94e7e169fb102",
                "MacAddress": "02:42:ac:11:00:06",
                "IPv4Address": "172.17.0.6/16",
                "IPv6Address": ""
            },
            "27ac2d67622d6c4aa85ca9abfdda6a061f7e31761835364fa5f9ea9b5a682708": {
                "Name": "registry",
                "EndpointID": "5a53826ce68b1bf0b16f0c23bd538ba267f8016e75fc3bb75ce89628281bead8",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "58928eac9056561328525399c31fba04f00e4b611959954aaed463aa63cc8717": {
                "Name": "db1",
                "EndpointID": "ca97ba8c58a2ff9aca59a155fe69564d968f3d783a144ccfc0ae33dcdb1ba1b1",
                "MacAddress": "02:42:ac:11:00:05",
                "IPv4Address": "172.17.0.5/16",
                "IPv6Address": ""
            },
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

### Check IP Address of the container

```
sudo docker inspect -f '{{ .NetworkSettings.IPAddress }}' [container id]
```
```
sudo docker inspect -f '{{ .NetworkSettings.IPAddress }}' d583abb93a39
172.17.0.7
```

### Run an container and check container have

```
sudo docker run -it [container name] /bin/bash 
```



