# CKAD Exercises

https://github.com/dgkanatsios/CKAD-exercises

## Core Concepts - 13%

### 1.Create a namespace called 'mynamespace' and a pod with image nginx called nginx on this namespace

```
kubectl create namespace mynamespace
kubectl run nginx --image=nginx --restart=Never -n mynamespace
```

### 2.Create the pod that was just described using YAML

Easily generate YAML with:

```
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
```

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

* `imagePullPolicy: IfNotPresent`

Alternatively, you can run in one line

```
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml | kubectl create -n mynamespace -f -
```

### 3.Create a busybox pod (using kubectl command) that runs the command `"env"`. Run it and see the output

```
kubectl run busybox --image=busybox --command --restart=Never -it -- env # -it will help in seeing the output
# or, just run it without -it
kubectl run busybox --image=busybox --command --restart=Never -- env
# and then, check its logs
kubectl logs busybox
```

### 4.Create a busybox pod (using YAML) that runs the command `"env"`. Run it and see the output

```
# create a  YAML template with this command
kubectl run busybox --image=busybox --restart=Never --dry-run -o yaml --command -- env > envpod.yaml

# see it
cat envpod.yaml
```
```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  containers:
  - command:
    - env
    image: busybox
    name: busybox
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 5.Get the YAML for a new namespace called 'myns' without creating it

```
kubectl create namespace myns -o yaml --dry-run
```

### 6.Get the YAML for a new `ResourceQuota` called `'myrq'` with hard limits of `1 CPU`, `1G memory` and `2 pods` without creating it

```
kubectl create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run -o yaml
```

### 7.Get pods on all namespaces

```
kubectl get po --all-namespaces
```

### 8.Create a pod with image nginx called nginx and allow traffic on port 80

```
kubectl run nginx --image=nginx --restart=Never --port=80
```

### 9.Change pod's image to `nginx:1.7.1`. Observe that the pod will be killed and recreated as soon as the image gets pulled

```
# kubectl set image POD/POD_NAME CONTAINER_NAME=IMAGE_NAME:TAG
kubectl set image pod/nginx nginx=nginx:1.7.1
kubectl describe po nginx # you will see an event 'Container will be killed and recreated'
kubectl get po nginx -w # watch it
```

```
kubectl get po nginx -o jsonpath='{.spec.containers[].image}{"\n"}'
```

### 10.Get nginx pod's ip created in previous step, use a temp busybox image to wget its `'/'`

```
kubectl get po -o wide # get the IP, will be something like '10.1.1.131'
# create a temp busybox pod
kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- 10.1.1.131:80
```
Alternatively you can also try a more advanced option:

```
# Get IP of the nginx pod
NGINX_IP=$(kubectl get pod nginx -o jsonpath='{.status.podIP}')
# create a temp busybox pod
kubectl run busybox --image=busybox --env="NGINX_IP=$NGINX_IP" --rm -it --restart=Never -- wget -O- $NGINX_IP:80
```

### 11.Get pod's YAML

```
kubectl get po nginx -o yaml
# or
kubectl get po nginx -oyaml
# or
kubectl get po nginx --output yaml
# or
kubectl get po nginx --output=yaml
```

### 12.Get information about the pod, including details about potential issues (e.g. pod hasn't started)

```
kubectl describe po nginx
```

### 13.Get pod logs

```
kubectl logs nginx
```

### 14.If pod crashed and restarted, get logs about the previous instance

```
kubectl logs nginx -p
```

### 15.Execute a simple shell on the nginx pod

```
kubectl exec -it nginx -- /bin/sh
```

### 16.Create a busybox pod that echoes 'hello world' and then exits

```
kubectl run busybox --image=busybox -it --restart=Never -- echo 'hello world'
# or
kubectl run busybox --image=busybox -it --restart=Never -- /bin/sh -c 'echo hello world'
```

### 17.Do the same, but have the pod deleted automatically when it's completed

```
kubectl run busybox --image=busybox -it --rm --restart=Never -- /bin/sh -c 'echo hello world'
kubectl get po # nowhere to be found :)
```

### 18.Create an nginx pod and set an env value as 'var1=val1'. Check the env value existence within the pod

```
kubectl run nginx --image=nginx --restart=Never --env=var1=val1
# then
kubectl exec -it nginx -- env
# or
kubectl describe po nginx | grep val1
# or
kubectl run nginx --restart=Never --image=nginx --env=var1=val1 -it --rm -- env
```

## Multi-container Pods (10%)

### 19. Create a Pod with two containers, both with image busybox and command "echo hello; sleep 3600". Connect to the second container and run 'ls'

Easiest way to do it is create a pod with a single container and save its definition in a YAML file:

```
kubectl run busybox --image=busybox --restart=Never -o yaml --dry-run -- /bin/sh -c 'echo hello;sleep 3600' > pod.yaml
vi pod.yaml
```

Copy/paste the container related values, so your final YAML should contain the following two containers (make sure those containers have a different name):

```
containers:
  - args:
    - /bin/sh
    - -c
    - echo hello;sleep 3600
    image: busybox
    imagePullPolicy: IfNotPresent
    name: busybox
    resources: {}
  - args:
    - /bin/sh
    - -c
    - echo hello;sleep 3600
    image: busybox
    name: busybox2
```

```
kubectl create -f pod.yaml
# Connect to the busybox2 container within the pod
kubectl exec -it busybox -c busybox2 -- /bin/sh
ls
exit

# or you can do the above with just an one-liner
kubectl exec -it busybox -c busybox2 -- ls

# you can do some cleanup
kubectl delete po busybox
```

## Pod design (20%)

### 20.Create 3 pods with names nginx1,nginx2,nginx3. All of them should have the `label app=v1`

```
kubectl run nginx1 --image=nginx --restart=Never --labels=app=v1
kubectl run nginx2 --image=nginx --restart=Never --labels=app=v1
kubectl run nginx3 --image=nginx --restart=Never --labels=app=v1
```

### 21.Show all labels of the pods

```
kubectl get po --show-labels
```

### 22.Change the labels of pod 'nginx2' to be app=v2

```
kubectl label po nginx2 app=v2 --overwrite
```

### 23.Get the label 'app' for the pods

```
kubectl get po -L app
# or
kubectl get po --label-columns=app
```

### 24.Get only the `'app=v2'` pods

```
kubectl get po -l app=v2
# or
kubectl get po -l 'app in (v2)'
# or
kubectl get po --selector=app=v2
```

### 25.Remove the 'app' label from the pods we created before

```
kubectl label po nginx1 nginx2 nginx3 app-
# or
kubectl label po nginx{1..3} app-
# or
kubectl label po -lapp app-
```

### 26.Create a pod that will be deployed to a Node that has the label `'accelerator=nvidia-tesla-p100'`

We can use the `'nodeSelector'` property on the Pod YAML:

```
apiVersion: v1
kind: Pod
metadata:
  name: cuda-test
spec:
  containers:
    - name: cuda-test
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
  nodeSelector: # add this
    accelerator: nvidia-tesla-p100 # the selection label
```

You can easily find out where in the YAML it should be placed by:

```
kubectl explain po.spec
```

### 27.`Annotate` pods `nginx1, nginx2, nginx3` with `"description='my description'"` value

```
kubectl annotate po nginx1 nginx2 nginx3 description='my description'

#or

kubectl annotate po nginx{1..3} description='my description'
```

### 28.Check the annotations for pod nginx1

```
kubectl describe po nginx1 | grep -i 'annotations'

kubectl get po nginx -o jsonpath='{.metadata.annotations}{"\n"}'
```

### 29.Remove the annotations for these three pods

```
kubectl annotate po nginx{1..3} description-
```

### 30.Remove these pods to have a clean state in your cluster

```
kubectl delete po nginx{1..3}
```

## Deployments

### 31.Create a deployment with image `nginx:1.7.8`, called `nginx`, having `2 replicas`, defining `port 80` as the port that this container exposes (don't create a service for this deployment)

```
kubectl run nginx --image=nginx:1.7.8 --replicas=2 --port=80
```

**However**, `kubectl run` for Deployments is Deprecated and will be removed in a future version. What you can do is:

```
kubectl create deployment nginx  --image=nginx:1.7.8  --dry-run -o yaml > deploy.yaml
vi deploy.yaml
# change the replicas field from 1 to 2
# add this section to the container spec and save the deploy.yaml file
# ports:
#   - containerPort: 80
kubectl apply -f deploy.yaml
```

or, do something like:

```
kubectl create deployment nginx  --image=nginx:1.7.8  --dry-run -o yaml | sed 's/replicas: 1/replicas: 2/g'  | sed 's/image: nginx:1.7.8/image: nginx:1.7.8\n        ports:\n        - containerPort: 80/g' | kubectl apply -f -
```

### 32.View the YAML of this deployment


```
kubectl get deploy nginx -o yaml
```

### 33.View the YAML of the replica set that was created by this deployment

```
kubectl describe deploy nginx # you'll see the name of the replica set on the Events section and in the 'NewReplicaSet' property
# OR you can find rs directly by:
kubectl get rs -l run=nginx # if you created deployment by 'run' command
kubectl get rs -l app=nginx # if you created deployment by 'create' command
# you could also just do kubectl get rs
kubectl get rs nginx-7bf7478b77 -o yaml
```

### 34.Get the YAML for one of the pods

```
kubectl get po # get all the pods
# OR you can find pods directly by:
kubectl get po -l run=nginx # if you created deployment by 'run' command
kubectl get po -l app=nginx # if you created deployment by 'create' command
kubectl get po nginx-7bf7478b77-gjzp8 -o yaml
```

### 35.Check how the deployment rollout is going

```
kubectl rollout status deploy nginx
```

### 36.Update the nginx image to `nginx:1.7.9`

```
kubectl set image deploy nginx nginx=nginx:1.7.9
# alternatively...
kubectl edit deploy nginx # change the .spec.template.spec.containers[0].image
```

### 37.Check the rollout history and confirm that the replicas are OK

```
kubectl rollout history deploy nginx
kubectl get deploy nginx
kubectl get rs # check that a new replica set has been created
kubectl get po
```

### 38.Undo the latest rollout and verify that new pods have the old image (nginx:1.7.8)

```
kubectl rollout undo deploy nginx
# wait a bit
kubectl get po # select one 'Running' Pod
kubectl describe po nginx-5ff4457d65-nslcl | grep -i image # should be nginx:1.7.8
```

### 39.Do an on purpose update of the deployment with a wrong image nginx:1.91

```
kubectl set image deploy nginx nginx=nginx:1.91
# or
kubectl edit deploy nginx
# change the image to nginx:1.91
# vim tip: type (without quotes) '/image' and Enter, to navigate quickly
```

### 40.Verify that something's wrong with the rollout

```
kubectl rollout status deploy nginx
# or
kubectl get po # you'll see 'ErrImagePull'
```

### 41.Return the deployment to the `second revision` (number 2) and verify the image is `nginx:1.7.9`

```
kubectl rollout undo deploy nginx --to-revision=2
kubectl describe deploy nginx | grep Image:
kubectl rollout status deploy nginx # Everything should be OK
```

### 42. Check the details of the fourth revision (number 4)

```
kubectl rollout history deploy nginx --revision=4 # You'll also see the wrong image displayed here
```

### 43. Scale the deployment to 5 replicas


```
kubectl scale deploy nginx --replicas=5
kubectl get po
kubectl describe deploy nginx
```

### 44.Autoscale the deployment, pods between 5 and 10, targetting CPU utilization at 80%

```
kubectl autoscale deploy nginx --min=5 --max=10 --cpu-percent=80
```

### 45.Pause the rollout of the deployment

```
kubectl rollout pause deploy nginx
```

### 46.Update the image to nginx:1.9.1 and check that there's nothing going on, since we paused the rollout

```
kubectl set image deploy nginx nginx=nginx:1.9.1
# or
kubectl edit deploy nginx
# change the image to nginx:1.9.1
kubectl rollout history deploy nginx # no new revision
```

### 47.Resume the rollout and check that the nginx:1.9.1 image has been applied

```
kubectl rollout resume deploy nginx
kubectl rollout history deploy nginx
kubectl rollout history deploy nginx --revision=6 # insert the number of your latest revision
```

### 48.Delete the deployment and the horizontal pod autoscaler you created

```
kubectl delete deploy nginx
kubectl delete hpa nginx

#Or
kubectl delete deploy/nginx hpa/nginx
```

## Jobs


### 49.Create a job with image perl that runs the command with arguments `"perl -Mbignum=bpi -wle 'print bpi(2000)'"`

```
kubectl run pi --image=perl --restart=OnFailure -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

**However**, kubectl run for Job is Deprecated and will be removed in a future version. What you can do is:

```
kubectl create job pi  --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

### 50.Wait till it's done, get the output

```
kubectl get jobs -w # wait till 'SUCCESSFUL' is 1 (will take some time, perl image might be big)
kubectl get po # get the pod name
kubectl logs pi-**** # get the pi numbers
kubectl delete job pi
```

### 51.Create a job with the image busybox that executes the command 'echo hello;sleep 30;echo world'

```
kubectl run busybox --image=busybox --restart=OnFailure -- /bin/sh -c 'echo hello;sleep 30;echo world'
```

```
kubectl create job busybox --image=busybox -- /bin/sh -c 'echo hello;sleep 30;echo world'
```

### 52.Follow the logs for the pod (you'll wait for 30 seconds)

```
kubectl get po # find the job pod
kubectl logs busybox-ptx58 -f # follow the logs
```

### 53.See the status of the job, describe it and see the logs

```
kubectl get jobs
kubectl describe jobs busybox
kubectl logs job/busybox
```

### 54.Delete the job

```
kubectl delete job busybox
```

### 55.Create a job but ensure that it will be automatically terminated by kubernetes if it takes more than 30 seconds to execute

```
kubectl create job busybox --image=busybox --dry-run -o yaml -- /bin/sh -c 'while true; do echo hello; sleep 10;done' > job.yaml
vi job.yaml
```

Add `job.spec.activeDeadlineSeconds=30`

```
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  activeDeadlineSeconds: 30 # add this line
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: busybox
    spec:
      containers:
      - args:
        - /bin/sh
        - -c
        - while true; do echo hello; sleep 10;done
        image: busybox
        name: busybox
        resources: {}
      restartPolicy: OnFailure
status: {}
```

Create the same job, make it run 5 times, one after the other. Verify its status and delete it

```
kubectl create job busybox --image=busybox --dry-run -o yaml -- /bin/sh -c 'echo hello;sleep 30;echo world' > job.yaml
vi job.yaml
```

Add `job.spec.completions=5`

```
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  completions: 5 # add this line
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: busybox
    spec:
      containers:
      - args:
        - /bin/sh
        - -c
        - echo hello;sleep 30;echo world
        image: busybox
        name: busybox
        resources: {}
      restartPolicy: OnFailure
status: {}
```

Verify that it has been completed:


```
kubectl get job busybox -w # will take two and a half minutes
kubectl delete jobs busybox
```

### 56.Create the same job, but make it run 5 parallel times

```
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  parallelism: 5 # add this line
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: busybox
    spec:
      containers:
      - args:
        - /bin/sh
        - -c
        - echo hello;sleep 30;echo world
        image: busybox
        name: busybox
        resources: {}
      restartPolicy: OnFailure
status: {}
```


## Cron jobs

### 57. Create a cron job with image busybox that runs on a schedule of `"*/1 * * * *"` and writes `'date; echo Hello from the Kubernetes cluster'` to standard output

```
kubectl run busybox --image=busybox --restart=OnFailure --schedule="*/1 * * * *" -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster'
```

**However**, `kubectl run` for CronJob is Deprecated and will be removed in a future version. What you can do is:

```
kubectl create cronjob busybox --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster'
```

### 58.See its logs and delete it

```
kubectl get cj
kubectl get jobs --watch
kubectl get po --show-labels # observe that the pods have a label that mentions their 'parent' job
kubectl logs busybox-1529745840-m867r
# Bear in mind that Kubernetes will run a new job/pod for each new cron job
kubectl delete cj busybox
```

### 59. Create a cron job with image busybox that runs every minutes and writes 'date; echo Hello from the Kubernetes cluster' to standard output. The cron job should be terminated if it takes more than 17 seconds to execute.

```
kubectl create cronjob time-limited-job --image=busybox --restart=Never --dry-run --schedule="* * * * *" -o yaml -- /bin/sh -c 'date; echo Hello from the Kubernetes cluster' > time-limited-job.yaml
vi time-limited-job.yaml
```

Add `job.spec.activeDeadlineSeconds=30`

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  creationTimestamp: null
  name: time-limited-job
spec:
  jobTemplate:
    metadata:
      creationTimestamp: null
      name: time-limited-job
    spec:
      activeDeadlineSeconds: 17 # add this line
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
            image: busybox
            name: time-limited-job
            resources: {}
          restartPolicy: Never
  schedule: '* * * * *'
status: {}
```

## Configuration (18%)

### 60.Create a configmap named config with values `foo=lala,foo2=lolo`

```
kubectl create configmap config --from-literal=foo=lala --from-literal=foo2=lolo
```

### 61.Display its values

```
kubectl get cm config -o yaml
# or
kubectl describe cm config
```

### 62.Create and display a configmap from a file

```
echo -e "foo3=lili\nfoo4=lele" > config.txt
```

```
kubectl create cm configmap2 --from-file=config.txt
kubectl get cm configmap2 -o yaml
```

### 63.Create and display a configmap from a `.env` file

```
echo -e "var1=val1\n# this is a comment\n\nvar2=val2\n#anothercomment" > config.env
```

```
kubectl create cm configmap3 --from-env-file=config.env
kubectl get cm configmap3 -o yaml
```

### 64.Create and display a configmap from a file, giving the key `'special'`

```
echo -e "var3=val3\nvar4=val4" > config4.txt
```

```
kubectl create cm configmap4 --from-file=special=config4.txt
kubectl describe cm configmap4
kubectl get cm configmap4 -o yaml
```

### 65.Create a configMap called 'options' with the value `var5=val5.` Create a new nginx pod that loads the value from variable `'var5'` in an `env` variable called `'option'`

```
kubectl create cm options --from-literal=var5=val5
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
vi pod.yaml
```

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    env:
    - name: option # name of the env variable
      valueFrom:
        configMapKeyRef:
          name: options # name of config map
          key: var5 # name of the entity in config map
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl create -f pod.yaml
kubectl exec -it nginx -- env | grep option # will show 'option=val5'
```

### 66.Create a `configMap 'anotherone'` with values `'var6=val6', 'var7=val7`'. Load this configMap as env variables into a new nginx pod

```
kubectl create configmap anotherone --from-literal=var6=val6 --from-literal=var7=val7
kubectl run --restart=Never nginx --image=nginx -o yaml --dry-run > pod.yaml
vi pod.yaml
```
```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    envFrom: # different than previous one, that was 'env'
    - configMapRef: # different from the previous one, was 'configMapKeyRef'
        name: anotherone # the name of the config map
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 67.Create a configMap `'cmvolume'` with values `'var8=val8', 'var9=val9'`. Load this as a volume inside an nginx pod on path `'/etc/lala'`. Create the pod and `'ls'` into the `'/etc/lala'` directory.

```
kubectl create configmap cmvolume --from-literal=var8=val8 --from-literal=var9=val9
kubectl run nginx --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
vi pod.yaml
```

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  volumes: # add a volumes list
  - name: myvolume # just a name, you'll reference this in the pods
    configMap:
      name: cmvolume # name of your configmap
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    volumeMounts: # your volume mounts are listed here
    - name: myvolume # the name that you specified in pod.spec.volumes.name
      mountPath: /etc/lala # the path inside your container
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl exec -it nginx -- /bin/sh
cd /etc/lala
ls # will show var8 var9
cat var8 # will show val8
```

## SecurityContext

### 68. Create the YAML for an nginx pod that runs with the user ID 101. No need to create the pod

```
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  securityContext: # insert this line
    runAsUser: 101 # UID for the user
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

### 69.Create the YAML for an nginx pod that has the capabilities "NET_ADMIN", "SYS_TIME" added on its single container

```
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    securityContext: # insert this line
      capabilities: # and this
        add: ["NET_ADMIN", "SYS_TIME"] # this as well
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

## Requests and limits

### 70.Create an nginx pod with requests `cpu=100m,memory=256Mi` and limits `cpu=200m,memory=512Mi`

```
kubectl run nginx --image=nginx --restart=Never --requests='cpu=100m,memory=256Mi' --limits='cpu=200m,memory=512Mi'
```

## Secrets

### 71.Create a secret called mysecret with the values `password=mypass`

```
kubectl create secret generic mysecret --from-literal=password=mypass
```

### 72.Create a secret called mysecret2 that gets key/value from a file

```
echo -n admin > username
```

```
kubectl create secret generic mysecret2 --from-file=username
```

### 73.Get the value of mysecret2

```
kubectl get secret mysecret2 -o yaml
echo YWRtaW4K | base64 -d # on MAC it is -D, which decodes the value and shows 'admin'
```

```
kubectl get secret mysecret2 -o jsonpath='{.data.username}{"\n"}' | base64 -d  # on MAC it is -D
```

### 74.Create an nginx pod that mounts the secret `mysecret2` in a volume on path `/etc/foo`

```
kubectl run nginx --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  volumes: # specify the volumes
  - name: foo # this name will be used for reference inside the container
    secret: # we want a secret
      secretName: mysecret2 # name of the secret - this must already exist on pod creation
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    volumeMounts: # our volume mounts
    - name: foo # name on pod.spec.volumes
      mountPath: /etc/foo #our mount path
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl create -f pod.yaml
kubectl exec -it nginx /bin/bash
ls /etc/foo  # shows username
cat /etc/foo/username # shows admin
```

### 75.Delete the pod you just created and mount the variable 'username' from secret `mysecret2` onto a new nginx pod in `env variable` called `'USERNAME'`

```
kubectl delete po nginx
kubectl run nginx --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    env: # our env variables
    - name: USERNAME # asked name
      valueFrom:
        secretKeyRef: # secret reference
          name: mysecret2 # our secret's name
          key: username # the key of the data in the secret
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl create -f pod.yaml
kubectl exec -it nginx -- env | grep USERNAME | cut -d '=' -f 2 # will show 'admin'
```

## ServiceAccounts

### 76.See all the service accounts of the cluster in all namespaces

```
kubectl get sa --all-namespaces
```

### 77.Create a new serviceaccount called 'myuser'

```
kubectl create sa myuser
```

```
# let's get a template easily
kubectl get sa default -o yaml > sa.yaml
vim sa.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: myuser
  
kubectl create -f sa.yaml
```

### 78.Create an nginx pod that uses 'myuser' as a service account

```
kubectl run nginx --image=nginx --restart=Never --serviceaccount=myuser -o yaml --dry-run > pod.yaml
kubectl apply -f pod.yaml
```

or you can add manually:

```
kubectl run nginx --image=nginx --restart=Never -o yaml --dry-run > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  serviceAccountName: myuser # we use pod.spec.serviceAccountName
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}

kubectl create -f pod.yaml
kubectl describe pod nginx # will see that a new secret called myuser-token-***** has been mounted
```

## Observability (18%)

## Liveness and readiness probes

### 79. Create an nginx pod with a `liveness probe` that just runs the command `'ls'`. Save its YAML in `pod.yaml`. Run it, check its probe status, delete it.

```
kubectl run nginx --image=nginx --restart=Never --dry-run -o yaml > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    livenessProbe: # our probe
      exec: # add this line
        command: # command definition
        - ls # ls command
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl create -f pod.yaml
kubectl describe pod nginx | grep -i liveness # run this to see that liveness probe works
kubectl delete -f pod.yaml
```

### 80.Modify the `pod.yaml` file so that liveness probe starts kicking in after `5 seconds` whereas the interval between probes would be `5 seconds`. Run it, check the probe, delete it.

```
kubectl explain pod.spec.containers.livenessProbe # get the exact names
```

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    livenessProbe: 
      initialDelaySeconds: 5 # add this line
      periodSeconds: 5 # add this line as well
      exec:
        command:
        - ls
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl create -f pod.yaml
kubectl describe po nginx | grep -i liveness
kubectl delete -f pod.yaml
```

### 81.Create an nginx pod (that includes `port 80`) with an HTTP `readinessProbe` on path `'/'` on `port 80`. Again, run it, check the readinessProbe, delete it.

```
kubectl run nginx --image=nginx --dry-run -o yaml --restart=Never --port=80 > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
    ports:
      - containerPort: 80 # Note: Readiness probes runs on the container during its whole lifecycle. Since nginx exposes 80, containerPort: 80 is not required for readiness to work.
    readinessProbe: # declare the readiness probe
      httpGet: # add this line
        path: / #
        port: 80 #
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```

```
kubectl create -f pod.yaml
kubectl describe pod nginx | grep -i readiness # to see the pod readiness details
kubectl delete -f pod.yaml
```

## Logging

### 82.Create a busybox pod that runs `'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done'`. Check its logs

```
kubectl run busybox --image=busybox --restart=Never -- /bin/sh -c 'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done'
kubectl logs busybox -f # follow the logs
```

## Debugging

### 83.Create a busybox pod that runs `'ls /notexist'`. Determine if there's an error (of course there is), see it. In the end, delete the pod

```
kubectl run busybox --restart=Never --image=busybox -- /bin/sh -c 'ls /notexist'
# show that there's an error
kubectl logs busybox
kubectl describe po busybox
kubectl delete po busybox
```

### 84.Create a busybox pod that runs 'notexist'. Determine if there's an error (of course there is), see it. In the end, delete the pod forcefully with a 0 grace period

```
kubectl run busybox --restart=Never --image=busybox -- notexist
kubectl logs busybox # will bring nothing! container never started
kubectl describe po busybox # in the events section, you'll see the error
# also...
kubectl get events | grep -i error # you'll see the error here as well
kubectl delete po busybox --force --grace-period=0
```

### 85.Get CPU/memory utilization for nodes

```
kubectl top nodes
```

## Services and Networking (13%)

### 85.Create a pod with image nginx called nginx and expose its port 80

```
kubectl run nginx --image=nginx --restart=Never --port=80 --expose
# observe that a pod as well as a service are created
```

### 86.Confirm that ClusterIP has been created. Also check endpoints

```
kubectl get svc nginx # services
kubectl get ep # endpoints
```

### 87.Get service's ClusterIP, create a temp busybox pod and 'hit' that IP with wget

```
kubectl get svc nginx # get the IP (something like 10.108.93.130)
kubectl run busybox --rm --image=busybox -it --restart=Never -- sh
wget -O- IP:80
exit
```

or

```
IP=$(kubectl get svc nginx --template={{.spec.clusterIP}}) # get the IP (something like 10.108.93.130)
kubectl run busybox --rm --image=busybox -it --restart=Never --env="IP=$IP" -- wget -O- $IP:80 --timeout 2
# Tip: --timeout is optional, but it helps to get answer more quickly when connection fails (in seconds vs minutes)
```

### 88.Convert the ClusterIP to NodePort for the same service and find the NodePort port. Hit service using Node's IP. Delete the service and the pod at the end.

```
kubectl edit svc nginx
```

```
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2018-06-25T07:55:16Z
  name: nginx
  namespace: default
  resourceVersion: "93442"
  selfLink: /api/v1/namespaces/default/services/nginx
  uid: 191e3dac-784d-11e8-86b1-00155d9f663c
spec:
  clusterIP: 10.97.242.220
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  sessionAffinity: None
  type: NodePort # change cluster IP to nodeport
status:
  loadBalancer: {}
```

```
kubectl get svc

# result:
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        1d
nginx        NodePort    10.107.253.138   <none>        80:31931/TCP   3m

wget -O- NODE_IP:31931 # if you're using Kubernetes with Docker for Windows/Mac, try 127.0.0.1
#if you're using minikube, try minikube ip, then get the node ip such as 192.168.99.117

kubectl delete svc nginx # Deletes the service
kubectl delete pod nginx # Deletes the pod
```

### 89.Create a deployment called foo using image 'dgkanatsios/simpleapp' (a simple server that returns hostname) and 3 replicas. Label it as `'app=foo'`. Declare that containers in this pod will accept traffic on port 8080 (do NOT create a service yet)

```
kubectl run foo --image=dgkanatsios/simpleapp --labels=app=foo --port=8080 --replicas=3
```

Or, you can use the more recent approach of creating the requested deployment as kubectl run has been deprecated.


```
kubectl create deploy foo --image=dgkanatsios/simpleapp --dry-run -o yaml > foo.yml

vi foo.yml
```

Update the yaml to update the replicas and add container port.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: foo
  name: foo
spec:
  replicas: 3 # Update this
  selector:
    matchLabels:
      app: foo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: foo
    spec:
      containers:
      - image: dgkanatsios/simpleapp
        name: simpleapp
        ports:                   # Add this
          - containerPort: 8080  # Add this
        resources: {}
status: {}
```

### 90.Get the pod IPs. Create a temp busybox pod and trying hitting them on port 8080

```
kubectl get pods -l app=foo -o wide # 'wide' will show pod IPs
kubectl run busybox --image=busybox --restart=Never -it --rm -- sh
wget -O- POD_IP:8080 # do not try with pod name, will not work
# try hitting all IPs to confirm that hostname is different
exit
```

### 91.Create a service that exposes the deployment on port 6262. Verify its existence, check the endpoints

```
kubectl expose deploy foo --port=6262 --target-port=8080
kubectl get service foo # you will see ClusterIP as well as port 6262
kubectl get endpoints foo # you will see the IPs of the three replica nodes, listening on port 8080
```

### 92.Create a temp busybox pod and connect via wget to foo service. Verify that each time there's a different hostname returned. Delete deployment and services to cleanup the cluster

```
kubectl get svc # get the foo service ClusterIP
kubectl run busybox --image=busybox -it --rm --restart=Never -- sh
wget -O- foo:6262 # DNS works! run it many times, you'll see different pods responding
wget -O- SERVICE_CLUSTER_IP:6262 # ClusterIP works as well
# you can also kubectl logs on deployment pods to see the container logs
kubectl delete svc foo
kubectl delete deploy foo
```

### 93.Create an nginx deployment of 2 replicas, expose it via a ClusterIP service on port 80. Create a NetworkPolicy so that only pods with labels 'access: granted' can access the deployment and apply it

```
kubectl run nginx --image=nginx --replicas=2 --port=80 --expose
kubectl describe svc nginx # see the 'run=nginx' selector for the pods
# or
kubectl get svc nginx -o yaml

vi policy.yaml
```

```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: access-nginx # pick a name
spec:
  podSelector:
    matchLabels:
      run: nginx # selector for the pods
  ingress: # allow ingress traffic
  - from:
    - podSelector: # from pods
        matchLabels: # with this label
          access: granted
```

```
# Create the NetworkPolicy
kubectl create -f policy.yaml

# Check if the Network Policy has been created correctly
# make sure that your cluster's network provider supports Network Policy (https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/#before-you-begin)
kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- http://nginx:80 --timeout 2                          # This should not work. --timeout is optional here. But it helps to get answer more quickly (in seconds vs minutes)
kubectl run busybox --image=busybox --rm -it --restart=Never --labels=access=granted -- wget -O- http://nginx:80 --timeout 2  # This should be fine
```


## State Persistence (8%)

### 94.Create busybox pod with two containers, each one will have the image busybox and will run the `'sleep 3600'` command. Make both containers mount an `emptyDir` at `'/etc/foo'`. Connect to the second busybox, write the first column of `'/etc/passwd'` file to` '/etc/foo/passwd'`. Connect to the first busybox and write `'/etc/foo/passwd'` file to standard output. Delete pod.

```
kubectl run busybox --image=busybox --restart=Never -o yaml --dry-run -- /bin/sh -c 'sleep 3600' > pod.yaml
vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  dnsPolicy: ClusterFirst
  restartPolicy: Never
  containers:
  - args:
    - /bin/sh
    - -c
    - sleep 3600
    image: busybox
    imagePullPolicy: IfNotPresent
    name: busybox
    resources: {}
    volumeMounts: #
    - name: myvolume #
      mountPath: /etc/foo #
  - args:
    - /bin/sh
    - -c
    - sleep 3600
    image: busybox
    name: busybox2 # don't forget to change the name during copy paste, must be different from the first container's name!
    volumeMounts: #
    - name: myvolume #
      mountPath: /etc/foo #
  volumes: #
  - name: myvolume #
    emptyDir: {} #
```

Connect to the second container:

```
kubectl exec -it busybox -c busybox2 -- /bin/sh
cat /etc/passwd | cut -f 1 -d ':' > /etc/foo/passwd 
cat /etc/foo/passwd # confirm that stuff has been written successfully
exit
```

Connect to the first container:

```
kubectl exec -it busybox -c busybox -- /bin/sh
mount | grep foo # confirm the mounting
cat /etc/foo/passwd
exit
kubectl delete po busybox
```

### 95. Create a `PersistentVolume of 10Gi`, called `'myvolume'`. Make it have `accessMode of 'ReadWriteOnce'` and `'ReadWriteMany'`, `storageClassName 'normal'`, mounted on `hostPath '/etc/foo'`. Save it on `pv.yaml`, add it to the cluster. Show the `PersistentVolumes` that exist on the cluster

```
vi pv.yaml


kind: PersistentVolume
apiVersion: v1
metadata:
  name: myvolume
spec:
  storageClassName: normal
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
    - ReadWriteMany
  hostPath:
    path: /etc/foo
```


### 96.Create a `PersistentVolumeClaim` for this storage class, called `mypvc`, a request of `4Gi` and an `accessMode` of `ReadWriteOnce`, with the `storageClassName` of `normal`, and save it on `pvc.yaml`. Create it on the cluster. Show the PersistentVolumeClaims of the cluster. Show the PersistentVolumes of the cluster

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mypvc
spec:
  storageClassName: normal
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi
```

Show the PersistentVolumeClaims and PersistentVolumes:

```
kubectl get pvc # will show as 'Bound'
kubectl get pv # will show as 'Bound' as well
```

### 97.Create a `busybox` pod with command `'sleep 3600'`, save it on `pod.yaml`. Mount the `PersistentVolumeClaim` to `'/etc/foo'`. Connect to the `'busybox'` pod, and copy the `'/etc/passwd'` file to `'/etc/foo/passwd'`

```
kubectl run busybox --image=busybox --restart=Never -o yaml --dry-run -- /bin/sh -c 'sleep 3600' > pod.yaml
vi pod.yaml
```
Add the lines that finish with a comment:

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busybox
  name: busybox
spec:
  containers:
  - args:
    - /bin/sh
    - -c
    - sleep 3600
    image: busybox
    imagePullPolicy: IfNotPresent
    name: busybox
    resources: {}
    volumeMounts: #
    - name: myvolume #
      mountPath: /etc/foo #
  dnsPolicy: ClusterFirst
  restartPolicy: Never
  volumes: #
  - name: myvolume #
    persistentVolumeClaim: #
      claimName: mypvc #
status: {}
```

Connect to the pod and copy `'/etc/passwd'` to `'/etc/foo/passwd'`:

```
kubectl exec busybox -it -- cp /etc/passwd /etc/foo/passwd
```

### 98.Create a second pod which is identical with the one you just created (you can easily do it by changing the 'name' property on pod.yaml). Connect to it and verify that `'/etc/foo'` contains the `'passwd'` file. Delete pods to cleanup

Create the second pod, called busybox2:

```
vim pod.yaml
# change 'metadata.name: busybox' to 'metadata.name: busybox2'
kubectl create -f pod.yaml
kubectl exec busybox2 -- ls /etc/foo # will show 'passwd'
# cleanup
kubectl delete po busybox busybox2
```

### 99.Create a busybox pod with `'sleep 3600'` as arguments. Copy `'/etc/passwd'` from the pod to your local folder

```
kubectl run busybox --image=busybox --restart=Never -- sleep 3600
kubectl cp busybox:/etc/passwd ./passwd # kubectl cp command
# previous command might report an error, feel free to ignore it since copy command works
cat passwd
```

