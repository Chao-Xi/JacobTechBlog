# Adv Fluentd ES configmap


## `<source>`

###  `@id`: `path`

* `fluentd-containers.log`: `/var/log/containers/*.log`
* `fluentd-containers-agent-server.log`: `/var/log/containers/agent-server-*.log`
* `fluentd-containers-ct.log`: `/var/log/containers/ct-*.log`
* `fluentd-containers-doc.log`: `/var/log/containers/doc-*.log`
* `fluentd-containers-elasticsearch.log`:`/var/log/containers/elasticsearch-*.log`
* `fluentd-containers-jod.log`: `/var/log/containers/jod-*.log`
* `fluentd-containers-load-balancer.log`: `/var/log/containers/load-balancer-*.log`
* `fluentd-containers-memcached.log`: `/var/log/containers/memcached-*.log`
* `fluentd-containers-opensocial.log`: `/var/log/containers/opensocial-*.log`
* `fluentd-containers-ps.log`: `/var/log/containers/ps-*.log`
* `fluentd-containers-rabbitmq.log`: `/var/log/containers/rabbitmq-*.log`


### `record_transformer` :`containers.**`

```
 <filter containers.**>
      @type record_transformer
      enable_ruby
      <record>
        log_level ${/(?<level>info|notice|debug|warn|error|err|fatal)/i.match(record["log"])[:level].downcase.tap { |level| level << "or" if (level == "err") } rescue (record["stream"] == "stderr") ? "error" : "info"}
      </record>
    </filter>
```

### Save different containers' logs to S3 different location

**Exp: `agent-server`**

```
<match containers.agent-server>
    @type s3
    @log_level info
    include_tag_key true
    logstash_format true
    aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
    aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
    s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
    s3_region  "#{ENV['LOG_BUCKET_REGION']}"
    path log/{{ .Values.jam.namespace }}/containers/agent-server/%Y/%m/%d/%Y-%m-%d
    s3_object_key_format %{path}_containers_agent-server_%{index}.%{file_extension}
    <buffer>
      @type file
      path /var/log/fluentd-buffers/s3/containers/agent-server
      timekey 3600  # 1 hour
      timekey_wait 10m
      chunk_limit_size 256m
    </buffer>
    time_slice_format %Y-%m-%d/%H
</match>
```

### `@log_level info`

```
path log/{{ .Values.jam.namespace }}/jam/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_jam_%{index}.%{file_extension}
```

## `fluentd-es-configmap.yaml`

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: fluentd-es-config-v0.1.4
  namespace: logging
data:
  system.conf: |-
    <system>
      root_dir /tmp/fluentd-buffers/
    </system>
  containers.input.conf: |-
    # This configuration file for Fluentd / td-agent is used
    # to watch changes to Docker log files. The kubelet creates symlinks that
    # capture the pod name, namespace, container name & Docker container ID
    # to the docker logs for pods in the /var/log/containers directory on the host.
    # If running this fluentd configuration in a Docker container, the /var/log
    # directory should be mounted in the container.
    #
    # These logs are then submitted to Elasticsearch which assumes the
    # installation of the fluent-plugin-elasticsearch & the
    # fluent-plugin-kubernetes_metadata_filter plugins.
    # See https://github.com/uken/fluent-plugin-elasticsearch &
    # https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter for
    # more information about the plugins.
    #
    # Example
    # =======
    # A line in the Docker log file might look like this JSON:
    #
    # {"log":"2014/09/25 21:15:03 Got request with path wombat\n",
    #  "stream":"stderr",
    #   "time":"2014-09-25T21:15:03.499185026Z"}
    #
    # The time_format specification below makes sure we properly
    # parse the time format produced by Docker. This will be
    # submitted to Elasticsearch and should appear like:
    # $ curl 'http://elasticsearch-logging:9200/_search?pretty'
    # ...
    # {
    #      "_index" : "logstash-2014.09.25",
    #      "_type" : "fluentd",
    #      "_id" : "VBrbor2QTuGpsQyTCdfzqA",
    #      "_score" : 1.0,
    #      "_source":{"log":"2014/09/25 22:45:50 Got request with path wombat\n",
    #                 "stream":"stderr","tag":"docker.container.all",
    #                 "@timestamp":"2014-09-25T22:45:50+00:00"}
    #    },
    # ...
    #
    # The Kubernetes fluentd plugin is used to write the Kubernetes metadata to the log
    # record & add labels to the log record if properly configured. This enables users
    # to filter & search logs on any metadata.
    # For example a Docker container's logs might be in the directory:
    #
    #  /var/lib/docker/containers/997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b
    #
    # and in the file:
    #
    #  997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b-json.log
    #
    # where 997599971ee6... is the Docker ID of the running container.
    # The Kubernetes kubelet makes a symbolic link to this file on the host machine
    # in the /var/log/containers directory which includes the pod name and the Kubernetes
    # container name:
    #
    #    synthetic-logger-0.25lps-pod_default_synth-lgr-997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b.log
    #    ->
    #    /var/lib/docker/containers/997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b/997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b-json.log
    #
    # The /var/log directory on the host is mapped to the /var/log directory in the container
    # running this instance of Fluentd and we end up collecting the file:
    #
    #   /var/log/containers/synthetic-logger-0.25lps-pod_default_synth-lgr-997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b.log
    #
    # This results in the tag:
    #
    #  var.log.containers.synthetic-logger-0.25lps-pod_default_synth-lgr-997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b.log
    #
    # The Kubernetes fluentd plugin is used to extract the namespace, pod name & container name
    # which are added to the log message as a kubernetes field object & the Docker container ID
    # is also added under the docker field object.
    # The final tag is:
    #
    #   kubernetes.var.log.containers.synthetic-logger-0.25lps-pod_default_synth-lgr-997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b.log
    #
    # And the final log record look like:
    #
    # {
    #   "log":"2014/09/25 21:15:03 Got request with path wombat\n",
    #   "stream":"stderr",
    #   "time":"2014-09-25T21:15:03.499185026Z",
    #   "kubernetes": {
    #     "namespace": "default",
    #     "pod_name": "synthetic-logger-0.25lps-pod",
    #     "container_name": "synth-lgr"
    #   },
    #   "docker": {
    #     "container_id": "997599971ee6366d4a5920d25b79286ad45ff37a74494f262e3bc98d909d0a7b"
    #   }
    # }
    #
    # This makes it easier for users to search for logs by pod name or by
    # the name of the Kubernetes container regardless of how many times the
    # Kubernetes pod has been restarted (resulting in a several Docker container IDs).
    # Json Log Example:
    # {"log":"[info:2016-02-16T16:04:05.930-08:00] Some log text here\n","stream":"stdout","time":"2016-02-17T00:04:05.931087621Z"}
    # CRI Log Example:
    # 2016-02-17T00:04:05.931087621Z stdout F [info:2016-02-16T16:04:05.930-08:00] Some log text here
    <source>
      @id fluentd-containers.log
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/es-containers.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag raw.kubernetes.*
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-agent-server.log
      @type tail
      path /var/log/containers/agent-server-*.log
      pos_file /var/log/containers-agent-server.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.agent-server
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-ct.log
      @type tail
      path /var/log/containers/ct-*.log
      pos_file /var/log/containers-ct.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.ct
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-doc.log
      @type tail
      path /var/log/containers/doc-*.log
      pos_file /var/log/containers-doc.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.doc
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-elasticsearch.log
      @type tail
      path /var/log/containers/elasticsearch-*.log
      pos_file /var/log/containers-elasticsearch.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.elasticsearch
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-jod.log
      @type tail
      path /var/log/containers/jod-*.log
      pos_file /var/log/containers-jod.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.jod
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-load-balancer.log
      @type tail
      path /var/log/containers/load-balancer-*.log
      pos_file /var/log/containers-load-balancer.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.load-balancer
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-memcached.log
      @type tail
      path /var/log/containers/memcached-*.log
      pos_file /var/log/containers-memcached.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.memcached
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-opensocial.log
      @type tail
      path /var/log/containers/opensocial-*.log
      pos_file /var/log/containers-opensocial.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.opensocial
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-ps.log
      @type tail
      path /var/log/containers/ps-*.log
      pos_file /var/log/containers-ps.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.ps
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    <source>
      @id fluentd-containers-rabbitmq.log
      @type tail
      path /var/log/containers/rabbitmq-*.log
      pos_file /var/log/containers-rabbitmq.log.pos
      time_format %Y-%m-%dT%H:%M:%S.%NZ
      tag containers.rabbitmq
      @label @containers
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_format %Y-%m-%dT%H:%M:%S.%NZ
        </pattern>
        <pattern>
          format /^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/
          time_format %Y-%m-%dT%H:%M:%S.%N%:z
        </pattern>
      </parse>
    </source>
    # Support rolling Java stack traces into one log event
    <source>
      @type tail
      path raw.kubernetes.*_doc*
      tag java_exception
      format multiline
      format_firstline /^java/
      format1 /^(?<exception>[^\n])/
      format2 /(?<log>at.*)/
    </source>
    # attempt to parse log level from the log and apply it as it's own field
    # default to "info" if no log level detected
    # this does not attempt to parse the loglevel "token", but scans the whole string
    # TODO: properly scan log format, individually from different application services
    <filter raw.kubernetes.**>
      @type record_transformer
      enable_ruby
      <record>
        log_level ${/(?<level>info|notice|debug|warn|error|err|fatal)/i.match(record["log"])[:level].downcase.tap { |level| level << "or" if (level == "err") } rescue (record["stream"] == "stderr") ? "error" : "info"}
      </record>
    </filter>
    <filter containers.**>
      @type record_transformer
      enable_ruby
      <record>
        log_level ${/(?<level>info|notice|debug|warn|error|err|fatal)/i.match(record["log"])[:level].downcase.tap { |level| level << "or" if (level == "err") } rescue (record["stream"] == "stderr") ? "error" : "info"}
      </record>
    </filter>
    # Detect exceptions in the log output and forward them as one log entry.
    <match raw.kubernetes.**>
      @id raw.kubernetes
      @type detect_exceptions
      remove_tag_prefix raw
      message log
      stream stream
      multiline_flush_interval 5
      max_bytes 500000
      max_lines 1000
    </match>
  system.input.conf: |-
    # Example:
    # 2015-12-21 23:17:22,066 [salt.state       ][INFO    ] Completed state [net.ipv4.ip_forward] at time 23:17:22.066081
    <source>
      @id minion
      @type tail
      format /^(?<time>[^ ]* [^ ,]*)[^\[]*\[[^\]]*\]\[(?<severity>[^ \]]*) *\] (?<message>.*)$/
      time_format %Y-%m-%d %H:%M:%S
      path /var/log/salt/minion
      pos_file /var/log/salt.pos
      tag salt
    </source>
    # Example:
    # Dec 21 23:17:22 gke-foo-1-1-4b5cbd14-node-4eoj startupscript: Finished running startup script /var/run/google.startup.script
    <source>
      @id startupscript.log
      @type tail
      format syslog
      path /var/log/startupscript.log
      pos_file /var/log/es-startupscript.log.pos
      tag startupscript
    </source>
    # Examples:
    # time="2016-02-04T06:51:03.053580605Z" level=info msg="GET /containers/json"
    # time="2016-02-04T07:53:57.505612354Z" level=error msg="HTTP Error" err="No such image: -f" statusCode=404
    # TODO(random-liu): Remove this after cri container runtime rolls out.
    <source>
      @id docker.log
      @type tail
      format /^time="(?<time>[^)]*)" level=(?<severity>[^ ]*) msg="(?<message>[^"]*)"( err="(?<error>[^"]*)")?( statusCode=($<status_code>\d+))?/
      path /var/log/docker.log
      pos_file /var/log/es-docker.log.pos
      tag docker
    </source>
    # Example:
    # 2016/02/04 06:52:38 filePurge: successfully removed file /var/etcd/data/member/wal/00000000000006d0-00000000010a23d1.wal
    <source>
      @id etcd.log
      @type tail
      # Not parsing this, because it doesn't have anything particularly useful to
      # parse out of it (like severities).
      format none
      path /var/log/etcd.log
      pos_file /var/log/es-etcd.log.pos
      tag etcd
    </source>
    # Multi-line parsing is required for all the kube logs because very large log
    # statements, such as those that include entire object bodies, get split into
    # multiple lines by glog.
    # Example:
    # I0204 07:32:30.020537    3368 server.go:1048] POST /stats/container/: (13.972191ms) 200 [[Go-http-client/1.1] 10.244.1.3:40537]
    <source>
      @id kubelet.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/kubelet.log
      pos_file /var/log/es-kubelet.log.pos
      tag kubelet
    </source>
    # Example:
    # I1118 21:26:53.975789       6 proxier.go:1096] Port "nodePort for kube-system/default-http-backend:http" (:31429/tcp) was open before and is still needed
    <source>
      @id kube-proxy.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/kube-proxy.log
      pos_file /var/log/es-kube-proxy.log.pos
      tag kube-proxy
    </source>
    # Example:
    # I0204 07:00:19.604280       5 handlers.go:131] GET /api/v1/nodes: (1.624207ms) 200 [[kube-controller-manager/v1.1.3 (linux/amd64) kubernetes/6a81b50] 127.0.0.1:38266]
    <source>
      @id kube-apiserver.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/kube-apiserver.log
      pos_file /var/log/es-kube-apiserver.log.pos
      tag kube-apiserver
    </source>
    # Example:
    # I0204 06:55:31.872680       5 servicecontroller.go:277] LB already exists and doesn't need update for service kube-system/kube-ui
    <source>
      @id kube-controller-manager.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/kube-controller-manager.log
      pos_file /var/log/es-kube-controller-manager.log.pos
      tag kube-controller-manager
    </source>
    # Example:
    # W0204 06:49:18.239674       7 reflector.go:245] pkg/scheduler/factory/factory.go:193: watch of *api.Service ended with: 401: The event in requested index is outdated and cleared (the requested history has been cleared [2578313/2577886]) [2579312]
    <source>
      @id kube-scheduler.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/kube-scheduler.log
      pos_file /var/log/es-kube-scheduler.log.pos
      tag kube-scheduler
    </source>
    # Example:
    # I1104 10:36:20.242766       5 rescheduler.go:73] Running Rescheduler
    <source>
      @id rescheduler.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/rescheduler.log
      pos_file /var/log/es-rescheduler.log.pos
      tag rescheduler
    </source>
    # Example:
    # I0603 15:31:05.793605       6 cluster_manager.go:230] Reading config from path /etc/gce.conf
    <source>
      @id glbc.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/glbc.log
      pos_file /var/log/es-glbc.log.pos
      tag glbc
    </source>
    # Example:
    # I0603 15:31:05.793605       6 cluster_manager.go:230] Reading config from path /etc/gce.conf
    <source>
      @id cluster-autoscaler.log
      @type tail
      format multiline
      multiline_flush_interval 5s
      format_firstline /^\w\d{4}/
      format1 /^(?<severity>\w)(?<time>\d{4} [^\s]*)\s+(?<pid>\d+)\s+(?<source>[^ \]]+)\] (?<message>.*)/
      time_format %m%d %H:%M:%S.%N
      path /var/log/cluster-autoscaler.log
      pos_file /var/log/es-cluster-autoscaler.log.pos
      tag cluster-autoscaler
    </source>
    # Logs from systemd-journal for interesting services.
    # TODO(random-liu): Remove this after cri container runtime rolls out.
    <source>
      @id journald-docker
      @type systemd
      filters [{ "_SYSTEMD_UNIT": "docker.service" }]
      <storage>
        @type local
        persistent true
      </storage>
      read_from_head true
      tag docker
    </source>
    <source>
      @id journald-container-runtime
      @type systemd
      filters [{ "_SYSTEMD_UNIT": {{ "{{ container_runtime }}.service" | quote }} }]
      <storage>
        @type local
        persistent true
      </storage>
      read_from_head true
      tag container-runtime
    </source>
    <source>
      @id journald-kubelet
      @type systemd
      filters [{ "_SYSTEMD_UNIT": "kubelet.service" }]
      <storage>
        @type local
        persistent true
      </storage>
      read_from_head true
      tag kubelet
    </source>
    <source>
      @id journald-node-problem-detector
      @type systemd
      filters [{ "_SYSTEMD_UNIT": "node-problem-detector.service" }]
      <storage>
        @type local
        persistent true
      </storage>
      read_from_head true
      tag node-problem-detector
    </source>
    <source>
      @id kernel
      @type systemd
      filters [{ "_TRANSPORT": "kernel" }]
      <storage>
        @type local
        persistent true
      </storage>
      <entry>
        fields_strip_underscores true
        fields_lowercase true
      </entry>
      read_from_head true
      tag kernel
    </source>
  forward.input.conf: |-
    # Takes the messages sent over TCP
    <source>
      @type forward
    </source>
  monitoring.conf: |-
    # Prometheus Exporter Plugin
    # input plugin that exports metrics
    <source>
      @type prometheus
    </source>
    <source>
      @type monitor_agent
    </source>
    # input plugin that collects metrics from MonitorAgent
    <source>
      @type prometheus_monitor
      <labels>
        host ${hostname}
      </labels>
    </source>
    # input plugin that collects metrics for output plugin
    <source>
      @type prometheus_output_monitor
      <labels>
        host ${hostname}
      </labels>
    </source>
    # input plugin that collects metrics for in_tail plugin
    <source>
      @type prometheus_tail_monitor
      <labels>
        host ${hostname}
      </labels>
    </source>
  output.conf: |-
    # Enriches records with Kubernetes metadata
    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>
    <filter containers.**>
      @type kubernetes_metadata
    </filter>
    # <match **>
    #    @id elasticsearch
    #    @type elasticsearch
    #    @log_level info
    #    include_tag_key true
    #    host elasticsearch-logging
    #    port 9200
    #    logstash_format true
    #    <buffer>
    #      @type file
    #      path /var/log/fluentd-buffers/kubernetes.system.buffer
    #      flush_mode interval
    #      retry_type exponential_backoff
    #      flush_thread_count 2
    #      flush_interval 5s
    #      retry_forever
    #      retry_max_interval 30
    #      chunk_limit_size 2M
    #      queue_limit_length 8
    #      overflow_action block
    #    </buffer>
    # </match>
    <label @containers>
      <match containers.agent-server>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/agent-server/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_agent-server_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/agent-server
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.ct>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/ct/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_ct_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/ct
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.doc>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/doc/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_doc_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/doc
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.elasticsearch>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/elasticsearch/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_elasticsearch_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/elasticsearch
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.jod>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/jod/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_jod_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/jod
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.load-balancer>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/load-balancer/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_load-balancer_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/load-balancer
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.memcached>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/memcached/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_memcached_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/memcached
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.opensocial>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/opensocial/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_opensocial_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/opensocial
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.ps>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/ps/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_ps_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/ps
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
      <match containers.rabbitmq>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/containers/rabbitmq/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_containers_rabbitmq_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/containers/rabbitmq
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </match>
    </label>
    <match **>
      @type copy
      <store>
        @id elasticsearch
        @type elasticsearch
        @log_level info
        include_tag_key true
        host elasticsearch-logging
        port 9200
        logstash_format true
        <buffer>
          @type file
          path /var/log/fluentd-buffers/kubernetes.system.buffer
          flush_mode interval
          retry_type exponential_backoff
          flush_thread_count 2
          flush_interval 5s
          retry_forever
          retry_max_interval 30
          chunk_limit_size 2M
          queue_limit_length 8
          overflow_action block
        </buffer>
      </store>
      <store>
        @type s3
        @log_level info
        include_tag_key true
        logstash_format true
        aws_key_id  "#{ENV['LOG_BUCKET_KEY']}"
        aws_sec_key  "#{ENV['LOG_BUCKET_SECRET']}"
        s3_bucket  "#{ENV['LOG_BUCKET_NAME']}"
        s3_region  "#{ENV['LOG_BUCKET_REGION']}"
        path log/{{ .Values.jam.namespace }}/jam/%Y/%m/%d/%Y-%m-%d
        s3_object_key_format %{path}_jam_%{index}.%{file_extension}
        <buffer>
          @type file
          path /var/log/fluentd-buffers/s3/jam
          timekey 3600  # 1 hour
          timekey_wait 10m
          chunk_limit_size 256m
        </buffer>
        time_slice_format %Y-%m-%d/%H
      </store>
    </match>
```

