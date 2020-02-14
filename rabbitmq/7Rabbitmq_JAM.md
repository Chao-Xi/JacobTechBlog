# JAM Rabbitmq Operation

### Issue 1: `rabbitmq-stats.timer` is not active

#### Solution: 

```
cd ~/code/\<INSTANCE\>/ct

HOSTFILTER=X.X.X.X bundle exec cap --verbose -S instance=datacenter invoke COMMAND='sudo systemctl start rabbitmq.service'

HOSTFILTER=x.x.x.x bundle exec cap -Sinstance=datacenter rabbitmq:start_stats_reporting
```

#### Validation: 

```
cap -Sinstance=datacenter diagnostics:rabbitmq:all
```

### Issue 2: CT scheduled job is not running since xxx time

#### Solution: 

```
cap -Sinstance=datacenter rabbitmq:rolling_restart_ha_cluster
```

### Issue 3:rabbitmq `node_health_check` fail and service run normally

#### Check

```
cap -S instance= datacenter diagnostics:rabbitmq:highly_available:node_health_check
```

#### `rabbitmq.service` service run normally

```
# systemctl status rabbitmq
rabbitmq.service - SAP Jam RabbitMQ Service
   Loaded: loaded (/etc/systemd/system/rabbitmq.service; disabled)
   Active: active (running) since Tue 2019-06-11 09:10:41 UTC; 3 weeks 1 days ago
...
```

```
$ rabbitmqctl node_health_check
fail
```

#### Solution: 

```
$ rabbitmqctl start
```

**Then**

```
rabbitmqctl node_health_check
Timeout: 70.0 seconds
Checking health of node 'rabbit@mo-d52a11d70.lab-rot.saas.sap.corp'
Health check passed
```

### Issue 4: `diagnostics:rabbitmq:transient:node_health_check` timeout

Go to 

https://stats.jam.only.sap/es#deployment=g_prod&component=&tag=0&server=g_all&endpoint=undefined&display=livedisplay&range=lasthour 

and check queue size

If any queue size is too large and never reduces, ssh to any rabbitmq node and check log at

```
/app/rabbitmq-<version>/log/rabbit@<HOSTNAME>
```

If there's error like

```
=ERROR REPORT==== 11-Jul-2019::03:20:25 ===
Error on AMQP connection <0.31114.5398> (10.10.70.51:49893 -> 10.10.71.51:5672, vhost: '/jam', user: 'jamproduction', state: running), channel 1:
operation channel.close caused a connection exception channel_error: "expected 'channel.open'"
```

It means some worker cannot connect to target queue.

To resolve this, you need to go to devops node and run

```
cd ~/code/<INSTANCE>/ct
cap -Sinstance=datacenter rabbitmq:rolling_restart_ha_cluster
```

To verify, ssh to rabbitmq node and run

```
rabbitmqctl list_queues -p /jam | grep '<YOUR_QUEUE_NAME>'
```

To check the queue size is reduces or not

## rabbitMQ cluster needs to start/stop in a pre-determined order

In each DC, rabbitMQ servers are configured working in cluster mode.
Although already handles the start/stop the rabbitMQ cluster in pre-determined order, we still need to highlight the details for further diagnostic purpose.

For your quick reference, here is brief quote from those links:

```
# "There are some important caveats:
# When the entire cluster is brought down, the last node to go down must be the first node to be brought online.
# If this doesn't happen, the nodes will wait 30 seconds for the last disc node to come back online, and fail afterwards.... "
```

### Issue 5: rabbitmq failed to boot with error description badmatch nomatch

When diagnose reports the rabbitMQ nodes are not in good state, check the status on the node server:

```
HOSTFILTER=x.x.x.x bundle exec cap -Sinstance=<INSTANCE> invoke COMMAND='sudo systemctl status rabbitmq.service -l'
```

You might get some outputs:

```
{"init terminating in do_boot",{could_not_start,rabbit,{{badmatch,{error,{{{badmatch....erl"},
```

####  Solution:

1. SSH to the rabbit node
2. Switch to the rabbitmq app path
3. Move the default `recovery.dets` file to tmp folder


```
mkdir -p /tmp/rabbit-recovery/ && mv /<RABBITMQ>/mnesia/rabbit@x.x.x.x/recovery.dets /tmp/rabbit-recovery/recovery.dets
```

* Restart the rabbitmq service and check the status

```
systemctl restart rabbitmq.service
systemct status rabbitmq.service
```

Note: You might encounter 'rabbitMQ cluster needs to start/stop in a pre-determined order', please check the process for more details.

### Issue 6: Incase need reinstall RabbitMQ via chef

```
$ cd ~/code/<INSTANCE>/chef-repo && HOSTS=<hosts> cap -Sinstance=<INSTANCE> push_run_chef RUNLIST="role[rabbitmq_ha_host]"
$ cd ~/code/<INSTANCE>/chef-repo && HOSTS=<hosts> cap -Sinstance=<INSTANCE> push_run_chef RUNLIST="role[rabbitmq_transient_host]"
```

### Issue 7:  `systemctl status rabbitmq-stats-service` returns active forever.

Its a stats-console related issue.  
We have three types of rabbitMQ services running on a VM:  

```
systemctl status rabbitmq
systemctl status rabbitmq-stats.timer
systemctl status rabbitmq-stats.service
```

* `rabbitmq-stats-service` is a script which will send the MQ bindings into `stats-console` by temporarily starting an unnamed container  
* Is will be triggered every now and then by `rabbitmq-stats.timer`  
* However, sometimes the container will be started and hangout forever. 
* Run `docker ps` will see that there is a random named container and the image's RXX number will mismatch the current release.  
Stop the container will might fail, so try to kill it: `docker kill [the random name]`  
* Then docker client might not be work with docker daemon correctly.
* Restart docker, check the `systemctl status rabbitmq-stats.service` returns inactive.  Issue fixed.  