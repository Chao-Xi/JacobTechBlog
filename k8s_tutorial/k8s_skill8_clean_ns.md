# Kubernetes namespace deleting stuck in Terminating state

```
$ kubectl proxy
Starting to serve on 127.0.0.1:8001

kubectl get namespace argocd -o json > argocd.json
vim argocd.json 
###
spec:
finalizers:
###
   
curl -k -H "Content-Type: application/json" -X PUT --data-binary @argocd.json http://127.0.0.1:8001/api/v1/namespaces/argocd/finalize   
```

```
$ kubectl get ns
NAME                STATUS        AGE
argo                Active        31d
default             Active        54d
docker              Active        54d
gatekeeper-system   Active        10d
kube-mon            Active        21d
kube-node-lease     Active        54d
kube-ops            Terminating   49d
kube-public         Active        54d
kube-system         Active        54d
postgres            Terminating   22d
```

So it turns out I had to remove the `finalizer` for kubernetes. But the catch was not to just apply the change using `kubectl apply -f`, it had to go via the cluster API for it to work.

## Step 1: Dump the descriptor as JSON to a file

```
kubectl get namespace postgres -o json > pg.json
```

Open the file for editing:

```
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "creationTimestamp": "2019-12-15T08:57:18Z",
        "deletionTimestamp": "2020-01-07T02:21:18Z",
        "name": "postgres",
        "resourceVersion": "1393191",
        "selfLink": "/api/v1/namespaces/postgres",
        "uid": "9247a936-c223-4f2b-8b7d-4e5d896b7f7d"
    },
    "spec": {
        "finalizers": [
         	""kubernetes"
        ]
    },
    "status": {
        "phase": "Terminating"
    }
}
```

Remove `kubernetes` from the `finalizers` array:

```
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "creationTimestamp": "2019-12-15T08:57:18Z",
        "deletionTimestamp": "2020-01-07T02:21:18Z",
        "name": "postgres",
        "resourceVersion": "1393191",
        "selfLink": "/api/v1/namespaces/postgres",
        "uid": "9247a936-c223-4f2b-8b7d-4e5d896b7f7d"
    },
    "spec": {
        "finalizers": [
        ]
    },
    "status": {
        "phase": "Terminating"
    }
}
```

## Step 2: Connect to your Kubernetes cluster

Open up your terminal (shell) and then create a reverse proxy to your Kubernetes cluster: 

`$kubectl proxy`

You should see the output as: `Starting to serve on 127.0.0.1:8001`

**Open a new terminal (shell)**, preferably bash, we will define some environment variables to assist us to connect to our Kubernetes cluster:

### Line 1: define a variable with our authentication token;

```
$ export TOKEN=$(kubectl describe secret $(kubectl get secrets | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t')

$ echo $TOKEN
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tbTluZnMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY....
```

### Line 2: use `cURL` to test connectivity and authorization.

```
$ curl http://localhost:8001/api/v1/namespaces --header "Authorization: Bearer $TOKEN" --insecure
{
  "kind": "NamespaceList",
  "apiVersion": "v1",
  "metadata": {
    "selfLink": "/api/v1/namespaces",
    "resourceVersion": "1394877"
  },
  "items": [
    ...
    {
      "metadata": {
        "name": "postgres",
        "selfLink": "/api/v1/namespaces/postgres",
        "uid": "9247a936-c223-4f2b-8b7d-4e5d896b7f7d",
        "resourceVersion": "1393191",
        "creationTimestamp": "2019-12-15T08:57:18Z",
        "deletionTimestamp": "2020-01-07T02:21:18Z"
      },
      "spec": {
        "finalizers": [
          "kubernetes"
        ]
      },
      "status": {
        "phase": "Terminating"
      }
    }
  ]
```

### Step 3: Executing our cleanup command

 
Now that we have that setup we can instruct our cluster to get rid of that annoying namespace:

```
curl -X PUT --data-binary @logging.json http://localhost:8001/api/v1/namespaces/logging/finalize -H "Content-Type: application/json" --header "Authorization: Bearer $TOKEN" --insecure
```

```
$ curl -X PUT --data-binary @pg.json http://localhost:8001/api/v1/namespaces/postgres/finalize -H "Content-Type: application/json" --header "Authorization: Bearer $TOKEN" --insecure
{
  "kind": "Namespace",
  "apiVersion": "v1",
  "metadata": {
    "name": "postgres",
    "selfLink": "/api/v1/namespaces/postgres/finalize",
    "uid": "9247a936-c223-4f2b-8b7d-4e5d896b7f7d",
    "resourceVersion": "1393191",
    "creationTimestamp": "2019-12-15T08:57:18Z",
    "deletionTimestamp": "2020-01-07T02:21:18Z"
  },
  "spec": {
    
  },
  "status": {
    "phase": "Terminating"
  }
}
```

After running that command, the namespace should now be absent from your namespaces list.

The key thing to note here is the resource you are modifying, in our case, it is for namespaces, it could be pods, deployments, services, etc. This same method can be applied to those resources stuck in `Terminating` state.



