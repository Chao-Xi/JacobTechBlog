# Install Grafana-Loki in Ubertest Cluster

### Prerequisites

Make sure you already install **Grafana (6.0+)** in Cluster. We have already installed **Grafana (6.2+)** in Ubertest Cluster by install **prometheus-operator**. Therefore, you can install **prometheus-operator** before install loki.

Please check: [Install prometheus-operator with Helm in Ubertest Cluster](https://github.wdf.sap.corp/sap-jam/ubertest-console/blob/master/kubernetes/prometheus-operator/README.md) to install **prometheus-operator** in Ubertest Cluster

Make sure you have **Helm** installed and **tiller** deployed to your cluster. 

### Step One: Add Loki's chart repository to Helm

```
helm repo add loki https://grafana.github.io/loki/charts
```

You can update the chart repository by running:

```
$ helm repo update
```

### Step two: Deploy Loki in Ubertest Cluster

```
$ helm upgrade --install -f loki-config.yaml loki --namespace=logging loki/loki-stack 
```

**`launch-config.yaml`**

```
loki:
  persistence:
    enabled: true
    storageClassName: cinder-default
  nodeSelector: 
      jam/ubertest: monitoring
  tolerations:
  - operator: Exists
  
promtail:
  tolerations:
  - operator: Exists
```

* namespace: `logging`
* Loki `nodeSelector`: `jam/ubertest: monitoring`
* Enable default `10G` PV in Cluster with `storageClassName: cinder-default`

### Step Three: Add Loki datasource in Grafana (built-in support for Loki is in 6.0 and newer releases)

1. Log into your Grafana. (`https://kubertest-grafana.jam.only.sap/`)
2. Go to `Configuration` >` Data Sources` via the cog icon in the left sidebar.
3. Click the big `+ Add data source` button.
4. Choose Loki from the list.
5. The http URL field should be the address or internal DNS of your Loki server: `http://loki.logging.svc.cluster.local:3100`
6. Save and Test


### Step Four: See your logs in the “Explore” view

1. Select the **“Explore”** view on the sidebar.
2. Select the **Loki data source**.
3. Choose a log stream using the “Log labels” button.


## Instruction for Loki User: Log Stream Selector

For the label part of the query expression, wrap it in curly braces `{}` and then use the key value syntax for selecting labels. Multiple label expressions are separated by a comma:

```
{namespace="monitoring", container_name="grafana"}
```

The following label matching operators are currently supported:

* `=` exactly equal.
* `!=` not equal.
* `=~ `regex-match.
* `!~` do not regex-match.


Examples:

* `{name=~"mysql.+"}`
* `{name!~"mysql.+"}`

### Search Expression

After writing the Log Stream Selector, you can filter the results further by writing a search expression. The search expression can be just text or a regex expression.

Example queries:

* `{job="mysql"} error`
* `{name="kafka"} tsdb-ops.*io:2003`
* `{instance=~"kafka-[23]",name="kafka"} kafka.server:type=ReplicaManager`


#### Reference

[https://grafana.com/docs/features/datasources/loki/](https://grafana.com/docs/features/datasources/loki/)	