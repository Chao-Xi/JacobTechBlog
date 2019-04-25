# kube2iam

[kube2iam](https://github.com/jtblin/kube2iam#readme)

IAM is the de-facto method of authorization in AWS.  Most Kubernetes “Quick Start” guides for AWS do not adequately cover how to manage IAM access in your pods

## The AWS Security Problem

### Background

I had a few years experience running microservices on EC2 before using Kubernetes, including managing dozens of IAM policies designed to isolate access to sensitive data to only services that needed it. When it came time to create our first Kubernetes cluster I read dozens of tutorials and patched together a kops installation that met our needs. 

![Alt Image Text](images/adv/adv53_1.png "Body image")

### Using IAM Roles

When we began running services in Kubernetes, I immediately ran into issues with IAM permissions. 

Like many, **I solved the issue by attaching IAM policies to the role my Kubernetes nodes used so that the pods could access all of the services via the metadata API.** This is a fine solution for very simple setups or non-production clusters, but it exposes your AWS account unnecessarily.


Kubernetes nodes running in AWS will often need access to some services in order to provide value: modifying Route53 records, creating Elastic Load Balancers, and access to the metadata API to help you identify nodes. 

Every pod running on that node also has access to perform these operations, so consider that every permission you add to the node you are also adding to every pod running on that node. Handling AWS authorization this way is a bad security practice and violates the principle of least privilege.


![Alt Image Text](images/adv/adv53_2.png "Body image")

***IAM Access for pods on EC2 nodes via instance profile***


### Principle of Least Privilege

**Once you begin adding third-party pods to your cluster, you should be very worried about their access to your AWS account.**

* Should your fluentd pods be able to delete items in S3? 
* Is Grafana really supposed to have access to your data in DynamoDB?

**These examples perfectly illustrate the principle of least privilege**. Applied to your Kubernetes cluster, i**t means that each pod should only have the access it needs to perform its own function.**


The ease of which we can run things in Kubernetes highlights this issue further. 

A one-line kubectl command can install very complex systems in your cluster that are capable of anything.  

Deploying your developer’s code is only too easy with the advent of Docker, and we all know that our devs make mistakes. 

**By restricting every pod’s AWS access, you can sleep easier knowing that a random container can’t delete your entire database without your permission.**


**In addition to violating the principle of least privilege, using the node IAM role to manage your pod permissions makes it nearly impossible to audit which containers have access to your AWS resources.**

Using the node role is a bad security practice when configuring IAM access for Kubernetes pods because 

1. it violates the principle of least privilege and 
2. it is not auditable.

![Alt Image Text](images/adv/adv53_3.png "Body image")


### Using IAM Users

An alternative to using the node role is to use **IAM users** instead. With this method, you can make an `IAM user` with correct permissions for each of your services, and **then pass in the credentials via environment variables**. 

This method does not violate the principle of least privilege because each pod has only the access it requires.


![Alt Image Text](images/adv/adv53_4.png "Body image")

**Use Kubernetes secrets to store the credentials and then inject them into the environment variables**

**Using a secret will get the credentials out of your config files, but secrets are really just base64 encoded.**

**It is easy enough to accidentally give access to read your secrets to random pods, even with RBAC enabled.**


```
    env:
      - name: AWS_ACCESS_KEY_ID
        valueFrom:
          secretKeyRef:
            name: aws_iam_user_1
            key: accessKeyId
      - name: AWS_SECRET_ACCESS_KEY
        valueFrom:
          secretKeyRef:
            name: aws_iam_user_1
            key: secretAccessKey
```


**Or just use it directly**


```
apiVersion: extensions/v1beta1 
kind: Deployment
metadata:
	kube2iam-demo 
spec:
	template:
		labels:
			app:  kube2iam-demo
		spec:
			container:
			- name: kube2iam-demo
			  image: bufferapp/kube2iam-demo
			  env:
			  - name: AWS.ACCESS_KEY_ID
			    value: AKIAJCRX2SVYRCZDKUSQ
 			  - name: AWS_SECRET_ACCESS_KEY 
 			    value qza98uno2wttUuyFS5LKeinivaievtiSs6R116Y24NDy 
```

```
env:
	- name: AWS.ACCESS_KEY_ID
	  value:
	- name: AWS_SECRET_ACCESS_KEY
	  value:
```

Storing credentials this way will make it more difficult to rotate your keys, which is done automatically with IAM roles. 

Some organizations also have restrictions on IAM users, either preventing users with access keys entirely, or requiring Two-Factor Authentication for all users. 

**Additionally, having access keys available in the pod poses some risks.**

* A developer may accidentally log all environment variables or hardcode access keys to avoid the hassle of managing a secret; 
* either of these could easily expose your keys.

## kube2iam Overview

[kube2iam](https://github.com/jtblin/kube2iam#readme) was the first major contender for solving the IAM issue in Kubernetes.

The project was started in 2016 and has been widely used in many deployments.

**It works by deploying a kube2iam pod to every node in your cluster as a DaemonSet.** 

It runs in the host network with privileged security access so it can create an **iptables rule** on each node to intercept calls to the **EC2 metadata api at `169.254.169.254`** which is used by **AWS SDKs to authenticate with IAM**. 

**The pods on each node intercept calls to the API and instead of authenticating directly,** will assume roles that are assigned to pods in your cluster via **annotations**, and **respond with the temporary credentials from assuming that role**.

**In this manner, your pods get the access from their annotated roles, and the only permissions needed for your nodes is the ability to assume the roles your pods use. **

No code changes should be needed if you are already using the default or instance credential provider chain in your AWS clients.


![Alt Image Text](images/adv/adv53_5.png "Body image")

### **Setup Process

The setup process for kube2iam is very simple:


* **Create roles for your pods to assume**
* Add permission to your Kubernetes nodes to assume these roles
* **Set up RBAC for kube2iam**
* **Deploy the kube2iam DaemonSet**
* Annotate your pods with `iam.amazonaws.com/role: <role arn>` and apply changes
* **Clean up your previous IAM access method** once you have verified access via `kube2iam`

While the steps are simple, you are very likely to run into issues when setting up `kube2iam`.

**For one, you will have to set the `--host-interface` argument on the kube2iam pod config to match the network layer your cluster uses.** 

It is easy to skip this step in documentation, and vital to get things working. Also, you may have a hard time debugging issues with IAM permissions themselves. 

While you can look at logs in the **kube2iam pod**, there is no indication on your application pods that something may be wrong with IAM authentication via kube2iam, and it can be tricky to track down issues properly using logs alone.


### Security Features

The architecture of `kube2iam` improves overall security by restricting IAM access. 

**The nodes only need permissions to assume the IAM roles that your pods will be using, so a malicious pod would have to know in advance which IAM roles to assume, and have that set in its annotations.**

This is considerably better than using the node role to have all possible pod permissions, or using IAM user keys which can be accidentally leaked.


### Extra Features

The README indicates support for the following network implementations:


* Calico
* kops (on kubenet),
* CNI
* EKS without calico/amazon-vpc-cni-k8s
* weave
* flannel
* kube-router
* OpenShift
* Cilium

The `--auto-discover-default-role` and `--default-role` can help with migration by letting `kube2iam` default to a certain IAM role if a pod does not have one specified. In production, I would not rely on this mechanism because it defeats the purpose of using kube2iam in the first place.

Some options such as `--auto-discover-base-arn`, `--base-role-arn`,` --iam-role-key`, and `--namespace-key` allow you to **customize your pod and namespace configuration**. 

Auto-discovering the base arn should honestly be on by default, and the key name options seem pretty frivolous in general.  There are also many options for customizing the log format, how the agent runs, and the length of the IAM session.

One option that seems very interesting is `--use-regional-sts-endpoint`, which configures the agent to use the regional STS endpoint instead of the global one if you also set the `AWS_REGION` environment variable. 

This can reduce latency for IAM requests generally, but also ties you to one region for authentication.

**Cross-account roles are supported as expected if you specify the full ARN of the role in your pod annotation.**


### Performance

When deploying any solution that will affect many of your production application, performance has to be considered. I always recommend having an application metric to measure performance with so you can get a sense for the real impact of a change. I compared performance using the following metrics that we send to Datadog:


* `app.diagnose.key_age`: measures the delay in processing on our back end system, measured in seconds
* `kubernetes.cpu.usage.total`: measures the total cpu usage in our cluster in cores (5 cores = 5000m)
* `kubernetes.network.rx_bytes/tx_bytes:` measures the total amount of data being received (rx) or transmitted (tx) from nodes in the cluster

The cluster I tested performance on has **3 c4.large masters and 6 m4.large nodes.** The application running on this cluster has many pods with occasional IAM access, and **one DaemonSet in particular that reads heavily from DynamoDB.**

**Kube2iam had essentially no noticeable impact on my performance metrics.** 

In order to get all pods actually using `kube2iam` instead of their cached IAM credentials from the node, I had to do a rolling release of almost every pod on the cluster, which caused a spike that is consistent with our normal releases. 

The approximate time of the release of `kube2iam` and all of the pods is 11:35.

![Alt Image Text](images/adv/adv53_6.png "Body image")

![Alt Image Text](images/adv/adv53_7.png "Body image")


## Installing kube2iam in production


### Creating IAM Roles

The first step to using kube2iam is to create IAM roles for your pods. T**he way kube2iam works is that each node in your cluster will need an IAM policy attached which allows it to assume the roles for your pods.**

Create an IAM policy for your nodes and attach it to the the role your Kubernetes nodes run on

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": “*”
    }
  ]
}
```
![Alt Image Text](images/adv/adv53_8.png "Body image")

```
{
  "Version": "2012-10-17", 
  "Statement": [
  	{
     "Effect": "Allow", 
     "Principal": { 
     	"Service": "ec2.amazonaws.com" 
    }, 
    "Action": "sts:AssumeRole" 
},
{
  "Sid": "",
  "Effect": "Allows", 
  "Principal": { 
    "AWS": "arn:aws:iam::980620087509:role/nodes.us-east1.buffer-k8s.com" 
   },
 	"Action": "sts:AssumeRole" 
  } 
 ]
} 
```


**Next create roles for each pod.** 

Each role will need a policy that has only the permissions that the pod needs to perform its function e.g. **listing s3 objects, writing to DynamoDB, reading from SQS, etc**. 

For each role you create, you need to update the assume role policy so that your nodes can assume the role. Replace `YOUR_NODE_ROLE` with the `arn` of the role your Kubernetes nodes run with.

**Assume role policy:**

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "YOUR_NODE_ROLE"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```
aws iam create-role --role-name kube2iam-demo --path /k8s/ --assume-role-policy-document file://policy.json
```
![Alt Image Text](images/adv/adv53_9.png "Body image")

### Annotating Resources

The next step is to annotate your pods with the role they should use. 

Just add an **annotation in the pod metadata spec**, and **`kube2iam` will use that role when authenticating with IAM for the pod.**

**`Kube2iam` will automatically detect the base arn for your role when configured to do so,**

but you can also specify a full arn (beginning with `arn:aws:iam`) if you need to assume roles in other AWS accounts.

```
annotations:
   iam.amazonaws.com/role: MY_ROLE_NAME
```

### Deploying kube2iam

Now you are ready to deploy kube2iam. 

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube2iam
  namespace: kube-system
---
apiVersion: v1
items:
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kube2iam
    rules:
      - apiGroups: [""]
        resources: ["namespaces","pods"]
        verbs: ["get","watch","list"]
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: kube2iam
    subjects:
    - kind: ServiceAccount
      name: kube2iam
      namespace: kube-system
    roleRef:
      kind: ClusterRole
      name: kube2iam
      apiGroup: rbac.authorization.k8s.io
kind: List
```

#### Since `kube2iam` modifies the `iptables` on your Kubernetes nodes to `hijack traffic` to the EC2 metadata service

I recommend adding a new node to your cluster that is tainted so you can do a controlled test to make sure everything is set up correctly without affecting your production pods. 

**Add a node to your cluster and then taint it so other pods will not run on it:**

```
kubectl taint nodes NODE_NAME kube2iam=kube2iam:NoSchedule 
```

Now we can configure the agent to run only on that node. 

**Add the `nodeName` key to the `pod spec` with the name of your new node and then add the `tolerations` so it will run on that node.**

Set the image to a tagged release of `kube2iam` instead of using latest. You also need to set the `--host-interface` command arg to match your `CNI`. The `kube2iam` page has a full list of supported values for this. I also recommend setting the `--auto-discover-base-arn` and `--auto-discover-default-role` flags to make configuring and migrating easier. 

The **`--use-regional-sts-endpoint`** is great if your cluster is in a single region, but you must also set the **`AWS_REGION`** environment variable for it to work. All together, your config should look something like this:

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube2iam
  namespace: kube-system
  labels:
    app: kube2iam
spec:
  selector:
    matchLabels:
      name: kube2iam
  template:
    metadata:
      labels:
        name: kube2iam
    spec:
      nodeName: NEW_NODE_NAME
      tolerations:
       - key: kube2iam
         value: kube2iam
         effect: NoSchedule
      serviceAccountName: kube2iam
      hostNetwork: true
      containers:
        - image: jtblin/kube2iam:0.10.6
          imagePullPolicy: Always
          name: kube2iam
          args:
            - "--app-port=8181"
            - "--auto-discover-base-arn"
            - "--iptables=true"
            - "--host-ip=$(HOST_IP)"
            - "--host-interface=weave"
            - "--use-regional-sts-endpoint"
            - "--auto-discover-default-role"
            - "--log-level=info"
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: AWS_REGION
              value: "us-east-1"
          ports:
            - containerPort: 8181
              hostPort: 8181
              name: http
          securityContext:
            privileged: true
```
Now you can create the agent and verify that only a single agent is running on your new node. There should be no change to your pods running on other nodes.


### Testing

At this point, you will want to get started with testing that everything works. You can do this by deploying a pod to the quarantine node and then using the AWS CLI to test access to resources in your pod. While you are doing this, check the logs of the kube2iam agent to debug any issues you encounter. Here’s an example of a deployment where you can specify a role and then test access:


```
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: aws-iam-tester
  labels:
    app: aws-iam-tester
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: aws-iam-tester
  template:
    metadata:
      labels:
        app: aws-iam-tester
      annotations:
        iam.amazonaws.com/role: TEST_ROLE_NAME
    spec:
      nodeSelector:
        kubernetes.io/role: node
      nodeName: NEW_NODE_NAME
      tolerations:
       - key: kube2iam
         value: kube2iam
         effect: NoSchedule
      containers:
      - name: aws-iam-tester
        image: garland/aws-cli-docker:latest
        imagePullPolicy: Always
        command:
          - /bin/sleep
        args:
          - "3600"
        env:
          - name: AWS_DEFAULT_REGION
            value: us-east-1
```

The pod will exit after an hour, and you can get use kubectl to get a `TTY` to the pod 

```
kubectl exec -it POD_NAME /bin/sh 
```

Once you are satisfied that your roles work, and that the `kube2iam` agent is correctly set up, you can then deploy the agent to every node.

### Full Deployment

Remove the **nodeName** key and **kube2iam:kube2iam** tolerations from your **kube2iam DaemonSet** to allow it to run on every node. 

Once it is installed on each node, you should roll out an update to critical pods to ensure that those pods begin using kube2iam for authentication immediately. Other pods that were using the node role to authenticate will begin going to kube2iam when their temporary credentials expire (usually about an hour). Check your application logs and the kube2iam logs for any IAM errors.

Once everything is running correctly, you can remove the quarantine node that was added earlier.

If you encounter issues, you can delete the agent from all nodes, but it will not automatically clean up the iptables rule it created. This will cause all of the calls to EC2 metadata to go nowhere. You will have to ssh into each node individually and remove the iptable rule yourself.

**First list the iptable rules to find the one set up by kube2iam**

```
sudo iptables -t nat -S PREROUTING | grep 169.254.169.254 
```

The output should be similar to

```
-A PREROUTING -d 169.254.169.254/32 -i weave -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.0.101.101:8181 
```

You may see multiple results if you deployed the agent with different **`--host-interface`** options on accident. You can delete them one at a time. To delete a rule, use the **-D** option of iptables and specify the entire line of output from above after **-A**. For example:

```
sudo iptables -t nat -D PREROUTING -d 169.254.169.254/32 -i weave -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.0.101.101:8181 
```

As this is done on each node, EC2 metadata requests will no longer go to kube2iam.