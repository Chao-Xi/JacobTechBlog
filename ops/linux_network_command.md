# Linux Basic Networking Commands

* **hostname** - HOST/Domain name and IP address
* **netstat** - Network connections, routing tables
* **ping** - Test NeWORK Connections
* **ifconfig / ip addr**: Getting network configuration
* **nslookup**: **Query DNS lookup name**
* **telnet**: Communicate with other hostname
* **traceroute**: Outing steps that packages to get to network host / shows paths to the destination IP address

## hostname

* **hostname**:  displays the machines host name
* **hostname -d**: displays the domain name the machine belongs to
* **hostname -f**: displays the fully qualified host and domain name
* **hostname -i**: displays the IP address for the current machine

```
$ hostname -f
jacob
```
```
$ hostname -i
127.0.0.1
```


## Networking Command

### `ping`

It sends packets of information to the user-defined source. If the packets are received, the destination device sends packets back. Ping can be used for two purposes 

1. Network connection can be established. 
2. Speed of the connection. 


If you **do ping www.google.com** it will display its IP address. Use `Ctrl+C` to stop the test. 

### `netstat`

Most useful and very versatile for finding connection to and from the host. You can find out all the multicast groups (network) subscribed by this host by issuing `"netstat -g" `

* `netstat -nap | grep port ` - display process id of application which is using that port 
* `netstat -a` or `netstat -all` - display all connections including TCP and UDP 


#### `sudo netstat -lnotp | grep port`

```
$ sudo netstat -lnotp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name Timer
tcp        0      0 0.0.0.0:60932           0.0.0.0:*               LISTEN      726/rpc.statd    off (0.00/0/0)
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      656/rpcbind      off (0.00/0/0)
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      2701/sshd        off (0.00/0/0)
tcp6       0      0 :::111                  :::*                    LISTEN      656/rpcbind      off (0.00/0/0)
tcp6       0      0 :::57429                :::*                    LISTEN      726/rpc.statd    off (0.00/0/0)
tcp6       0      0 :::22                   :::*                    LISTEN      2701/sshd        off (0.00/0/0)
```

#### `grep port-number`

```
$ sudo netstat -lnotp | grep 22
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      2701/sshd        off (0.00/0/0)
tcp6       0      0 :::22                   :::*                    LISTEN      2701/sshd        off (0.00/0/0)
```

#### `netstat -all`

```
$ sudo netstat -all
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 *:60932                 *:*                     LISTEN
tcp        0      0 *:sunrpc                *:*                     LISTEN
tcp        0      0 *:ssh                   *:*                     LISTEN
tcp        0      0 Jacob:ssh               10.0.2.2:56706          ESTABLISHED
tcp6       0      0 [::]:sunrpc             [::]:*                  LISTEN
tcp6       0      0 [::]:57429              [::]:*                  LISTEN
tcp6       0      0 [::]:ssh                [::]:*                  LISTEN
udp        0      0 localhost:902           *:*
udp        0      0 *:bootpc                *:*
udp        0      0 *:sunrpc                *:*
udp        0      0 *:15077                 *:*
udp        0      0 *:35589                 *:*
udp        0      0 *:830                   *:*
udp6       0      0 [::]:56354              [::]:*
udp6       0      0 [::]:sunrpc             [::]:*
udp6       0      0 [::]:33972              [::]:*
udp6       0      0 [::]:830                [::]:*
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node   Path
unix  2      [ ACC ]     STREAM     LISTENING     8457     /var/run/dbus/system_bus_socket
unix  2      [ ACC ]     STREAM     LISTENING     7954     /run/rpcbind.sock
...
```

* `netstat --tcp or netstat —t `- display only TCP connection 
* `netstat --udp or netstat —u` - display only UDP connection 
* `netstat -g` - display all multicast network subscribed by this host. 
* `netstat —l` - **List only listening ports** 

```
$ netstat -l
Active Internet connections
Proto Recv-Q Send-Q  Local Address          Foreign Address        (state)
tcp4       0      0  10.75.106.64.58825     52.109.76.33.https     ESTABLISHED
tcp4       0      0  localhost.65000        localhost.58824        ESTABLISHED
...
```

### `ifconfig`

The "**ifconfig**" command is used for displaying current network configuration information, setting up an ip address, netmask or broadcast address to an network interface, creating an alias for network interface. setting up hardware address and enable or disable network interfaces. 

* `$> ifconfig -a` - View all network configuration & settings 
* `$> ifconfig eth0` - **View specific network settings **
* `$> ifconfig eth0 UP` or `ifup eth0` - **Enabling eth0 interface**
* `$> ifconfig eth0 down` or `ifdown eth0` - Disabling eth0 interface 

```
$ ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 08:00:27:9e:58:5a
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe9e:585a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:116168 errors:0 dropped:0 overruns:0 frame:0
          TX packets:81046 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:59531228 (59.5 MB)  TX bytes:62531177 (62.5 MB)
```

### `nslookup`
 
1. Discovers Hostname from IP Address 
2. Discovers IP Address from Host Name 

```
$  nslookup google.com
Server:		10.0.2.3
Address:	10.0.2.3#53

Non-authoritative answer:
Name:	google.com
Address: 172.217.168.206
```
### `traceroute`

A handy utility to view the number of hops and response time to get to a remote system or web site is traceroute. Again you need an internet connection to make use of this tool. 


```
$ traceroute google.com
traceroute to google.com (172.217.168.206), 30 hops max, 60 byte packets
 1  10.0.2.2 (10.0.2.2)  0.235 ms  0.117 ms  0.196 ms
 2  10.75.106.1 (10.75.106.1)  2.337 ms  2.571 ms  2.952 ms
 3  ip-220-232-211-41.asianetcom.net (220.232.211.41)  1.548 ms  1.865 ms  1.975 ms
 4  10.240.96.45 (10.240.96.45)  2.402 ms  2.371 ms  2.386 ms
...
```