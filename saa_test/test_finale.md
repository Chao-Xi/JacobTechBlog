#### 1.EC2 instances types:

**HVM** and **PV**

#### 2.Natively encrypt data at rest with AES-256

**Storage Gateway and Glacier**

3.You can only specify one launch configuration for an Auto Scaling group at a time, and **you can't modify a launch configuration after you've created it**. Therefore, **if you want to change the launch configuration for your Auto Scaling group, you must create a new launch configuration and then update your Auto Scaling group with the new launch configuration.** 

**When you change the launch configuration for your Auto Scaling group, any new instances are launched using the new configuration parameters, but existing instances are not affected.**"


#### 4.Bucket policy and Bucket ACL

**Bucket policy: Action, Resources, Condition**

**Bucket ACL**
 
*  List object , write object , read bucket,   write bucket  
*  aws account , other aws account,  public access , **S3 log delivery group**


**Object ACL**    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  **No Object Policy**

1. Which features can be used to restrict access to data in S3?

* Set an S3 ACL on the bucket or the object.
* Set an S3 bucket policy.

#### 5. admin access: EC2 EMR BeanStalk Opswork

#### 6. EC2 placement group

* **Cluster group**: 1)low network latency, 2)high network throughput
* **Spread group**:  1)small number of critical instances that should kept separate from each other **(spread instance across underlying hardware)**

**Question: How to enhance inter-node communication?**

* Enhanced networking
* instance put in cluster group


#### 7.realtime e-commerce analysis: EMR

**Kinesis is for aggregating and temporarily storing high volume data.**

EMR is for running app like Hadoop and spark, for analyzing Big data.

**Big data analysis:**

1. **Amazon Athena**: Query Service **server-less** with **SQL** on the data stored in **S3** which without worrying data formatting
2. **Amazon EMR**: 'sophisticated data processing' **Hadoop, Spark**
3. **Amazon Redshift**: **Data warehouse**, **complex SQL with multiple join**, need transfer **multiple data resource** into a common format

**Data ETL Service:**

1. **Glue**: ETL Service on a **serverless** Apache Spak env. Move data by to glue **category** by **crawler**.
2. **data pipeline**: launch **EC2** and transfer data to EMR and Redshift, **between dynamodb, rds between S3**
3. **Kinesis**: **Standard SQL** on incoming data and specify destination


#### 8. Recored on who access S3: 

Enable server access log on the bucket

#### 9.Forget create public ip? 

assign the **Elastic IP** to the instance and this instance will publicly open

#### 10.Route 53 failover Active-Active: All  Active-passive: Primary and Second

1. Route 53 geolocation: **compliance and regulatory purpose**
2. Latency Based: **performance purpose**

**True about Amazon Route 53**

* **An Alias record can map one DNS name to another Amazon Route 53 DNS name.**
* **Create an A record aliased to the load balancer DNS name**

Questions: You need to create a simple, holistic check for your system’s general availability and uptime. Your system presents itself as an HTTP-speaking API. What is the simplest tool on AWS to achieve this with?

**Route53 Health Check**


#### 11.cloudwatch logs 

enable by installing a `cloud-agent on ec2 instance`

#### 13.cross-account access: 

**Permission policy(What). Trust policy(Who)**

#### 14.EBS Volume: root volume and data volume

only data volume can be **created/attached/detached** on the fly

1. Which of the following will occur when an EC2 instance in a VPC (Virtual Private Cloud) with an **associated Elastic IP** is **stopped and started**? 

* **All data on instance-store devices will be lost**
* **The underlying host for the instance is changed**

2.Which of the following are true regarding encrypted Amazon Elastic Block Store (EBS) volumes? Choose 2 answers

* **Supported on all Amazon EBS volume types**
* **Snapshots are automatically encrypted**
* **EBS encryption is also handled by user, not default**

3.you are running a database on an EC2 instance, with the data stored on Elastic Block Store (EBS) for persistence At times throughout the day, **you are seeing large variance in the response times of the database queries Looking into the instance** with the isolate command you see a lot of wait time on the disk volume that the database’s data is stored on. What two ways can you improve the performance of the database’s storage while maintaining the current persistence of the data?

* **Move the database to an EBS-Optimized Instance**
* **Use Provisioned IOPs EBS**

4.A user has stored data on an encrypted EBS volume. The user wants to share the data with his friend’s AWS account.

**Copy the data to an unencrypted volume and then share**

#### 15. Purging cached data in cloudfront 

**Use Invalidation tab, purging an invalidation on the cloudfront distrubtion**

#### 16. Endpoints: S3 AND DynamoDB using private ip cannot cross-region

#### 17. Information you gathered whether S3 is right choice

The size of individual object => multi-part upload

#### 18. EBS VS. Snapshot VS. AMI

* **EBS Volume are bound to one AZ**
* **snapshot of ebs in S3, SO it's regional**
* **AMI are just registered snapshots, so it's also Regional**

**Public AMI only be used to launch EC2 instances in the same AWS region as the AMI is stored.**

#### 19. EC2 cloudwatch default metrics

**CPU utilization**, **Disk read/write**, **Network In/Out**

**YOU CAN CUSTOM memory utilization**

#### 20. Redshift: is fast, scalable data warehouse to analyze data warehouse and data lake or premise data

AWS CLUE: ELT service, organize, load and move data

it's **serverless**, automatically generate data ETL script, and store in data warehouse

#### 21.NACL need ab `outbound rule` for the` high ephermal port range` (1024-65535)

#### 22 IOPS

| GP2 | IO1 | SC1 | ST1|
|:------------- |:---------------:| -------------:| -------------:|
| 16000 | 64000 |   250|   500 |

#### 23.S3 performance

* **Upload**: multipart upload
* **Download**: add random prefix to the key names
* **instanceID_log-HH-DD-MM-YYYY**. => **random prefix with instance id and hh**
* **Enhanced network**

#### 24.AWS VPN two components

* Virtual Private Gateway &nbsp;&nbsp;  =>  &nbsp;&nbsp; two endponints
* Customer Gateway

#### 25.VPC FLOW logs is storing using Amazon Cloudwatch Logs

#### 26 Nat security

public subnet don't have to add route to nat Instance. Nat instance already set in public subnet

**Edit 'default route table' , and add 'NAT instance' to it. Destination: 0.0.0.0/0, target: nat instance to ensure private subnet connect with internet**

**NAT instance sg:**

* **Outbound internet traffic** from instances in the private subnet
* **disallow inbound from everywhere** and **allow only from private subnet**

For example:

ICMP ping:  **sg for monitoring instance need allow outbound icmp** and **the application sg need to be inbound ICMP** and **subnet nacl of application need outbound  icmp traffic**


#### 27.AWS two components connect external networks: `IGW` AND `VGW`

#### 28.sg and NACL

1. **one instance can be assigned with multiple sgs, up to 5, one sg up to 50 rules**
2. **default and new sg start with `no inbound` and `all outboud`**
3. **default NANCL `ALLOW all inbound and outbound `**
4. **Newly created NACL `DENY ALL inbound and outbound`**
5. **one subnet <=> one NACL**


#### 29.EC2 troubleshooting with connection timeout

* **CPU load on the instance is too high**
* **User key not recognized by server**

#### 30.ENI attach

**running <=> hot** &nbsp;&nbsp;&nbsp;&nbsp;**stopped<=>warm** &nbsp;&nbsp;&nbsp;&nbsp;**launched<=>cold**

#### 31. RDS cloudwatch metrics

```
data transfer /  data storage / i/o request
```

#### 32. RDS backup

1. Automated backup and snapshots only support **innoDB** AND store in **S3**
2. **Manually created snapshot will `keep` after instance is deleted**


#### 33.RDS mutli-AZ vs Read Replica

1. Maintenance: primary->stand by->maintenance->stand by &nbsp; &nbsp;  stand by-> primary
2. **mutli-AZ -> synchronize**
3. **read-replica -> asynchronously**


#### 34.dynamodb usecase

web sessions     &nbsp; &nbsp;      json document   &nbsp; &nbsp;  metadata data for s3

#### 35. ELB AND ASG

1. ELB Send traffic if instance is health, no traffic if unhealthy
2. user can add instance to elb on fly which can realize asg->elb
3. scaleout: pending-> pending wait -> pending processed -> in service
4. scalein: terminating -> terminating wait -> terminating wait processed -> terminated 
5. inservice -> stand by -> pending -> in servce

#### 36.absorb attack

asg&elb &nbsp; &nbsp; ec2 vertical scaling &nbsp; &nbsp; enhanced network &nbsp; &nbsp; cloudfront &nbsp; &nbsp; route 53

#### 37.SWF VS SQS

SQS -> 14 days &nbsp; &nbsp; SWF -> 1 YEAR

#### 38. Storage Options: S3 VS. EFS 

1. **S3**: **Object** storage
2. **EFS**: **can be used as shared drive by multi instances**. & **cannot used as root volume**
3. **EBS**: **Can used as root volume**

#### 39.AWS resource explorer

**System manager**

#### 40. When EC2 is stopped, the only action you can do:

* Change security group
* create AMI

#### 41.Optimizing ASG

1. Modify the asg cool-down time.
2. Modify the Amazon Cloudwatch alarm period that triggers your asg scale down policy

**`reboot instance` is not preformed by ASG, `schedule actions`, `replace unhealthy`, `AZ re-balancing` is by asg**

**recommend launch asg with in the az with fewest instances**

#### 42. Beanstalk USE:

1. Web application using RDS
2. **A long running work process**

#### 43.IAM roles and IAM users recommend

**IAM best practice:**

* **Configure MFA** on the **root account** and for **privileged IAM users**
* Assign IAM users and groups configured with policies **granting least privilege access**
* Rotate credentials regularly

#### 44 Cannot connect to a running EC2 instance using SSH

* The **security group** is not configured properly
* The **private key** used to launch the instance is not correct
* The **instance CPU** is heavily loaded

**The access key to connect to the instance is wrong** => NOT ANSWER (access key is different from ssh private key)

#### 45.In the shared security model, AWS is responsible 

**Penetration testing / Threat modeling / Static code analysis / Protect against IP spoofing or packet sniffing**

#### 46.A user has launched an EC2 instance. The user is planning to setup the CloudWatch alarm. Which of the below mentioned actions is `not supported` by the CloudWatch alarm?

**Notify the Auto Scaling launch config to scale up  (it's asg action not notify, while cloudwatch will send notification)**

* Send an SMS using SNS  =>
* Notify the Auto Scaling group to **scale down**   =>   can be trigged by cloudwatch
* **Stop the EC2 instance** => 


#### 47.elb and alb features

#### BOTH:

**Stick Sessions (Cookies)**, Idle Connection Timeout, **Connection Draining**, **SSL Termination**,  **Cross-zone Load Balancing**, **Health Checks**, CloudWatch Metrics, Access Logs, 

#### ALB:

Back-end Server Authentication(ALB), Host-based Routing & Path-based Routing(ALB), **Dynamic Ports**, **Deletion Protection**, Request Tracing, IPv6 in VPC, AWS WAF

1.A user has created an ELB with three instances. How many security groups will ELB create by default?

**2 (One for ELB to allow inbound and Outbound to listener and health check port of instances and One for the Instances to allow inbound from ELB)**

2.The application uses a three-tier architecture where data flows through the load balancer and is stored on Amazon EBS volumes for processing, and the results are stored in Amazon S3 using the AWS SDK. Which of the following two options satisfy the security requirements?

* **Use TCP load balancing on the load balancer, SSL termination on the Amazon EC2 instances**, OS-level disk encryption on the Amazon EBS volumes, and Amazon S3 with server-side encryption.

* **Use SSL termination on the load balancer, an SSL listener on the Amazon EC2 instances**, Amazon EBS encryption on EBS volumes containing PHI, and Amazon S3 with server-side encryption.

#### 48.gate-way cached and gateway-stored

* gate-way cached: 
  * **Data is stored in S3 (NOT ON on-premise data center) and acts as a Primary data storage**,  
  * **Retains a copy of `recently read data locally` for low latency access to the frequently accessed data**

* Gateway-stored 
  * **Maintain the `entire data set locally` to provide low latency access**
  * **Gateway asynchronously backs up point-in-time snapshots of the data to S3**

#### 49.Direct connection  (VGW(VPC) + route table)

* Enable route propagation to the Virtual Private Gateway (VGW) IN VPC
* **Modify the Instances VPC subnet route table by adding a route back to the customer’s on-premises environment.** in VPC

#### 50. Master (Payee) account can view only the AWS billing details of the linked accounts

Each linked account is still independent from paying account and paying account can't access data from linked accounts, but **Enable IAM cross-account access for all corporate IT administrators in each child account**

## 1.DynamoDB

### Attributes

#### DynamoDB uses `optimistic concurrency control`
#### DynamoDB uses `conditional writes for consistency`

#### Scalability

* **Millions of reads/sec from single DAX Cluster**
* **Unlimited items and storage**
* **Auto scale through based on consumption**

#### Performance

* Optimized for analytics workloads with **native indexing**
* Microsecond response times with **DynamoDB Accelerator(DAX) (read/write through)**

#### Security

* **Monitor with Cloudwatch metrics & logging with CloudTrail**
* **Secure, private, VPC endpoints**

#### Availability & Data Protection

* 99.9% high availability
* **Built-in replication across 3 zones**

#### Manageability & TCO

* **Track table level spending with tagging**
* **purge data automatically (Time to. live)**
* **DMS connector for DynamoDB**

#### Dev Platform $ tools

* Event-driven programming with trigger & Lambda
* **Advanced analytics with EMR & Amazon Redshift**
* **Full-text query amazon elasticserach service**
* **Real-time stream processing with Amazon Kinesis**

### Auto Scaling (somewhat predictable generally periodic fashion)

#### Features:

* Fully-managed, automatic scaling of **throughput capacity for read and write** of tables and global secondary indexes
* **Set only target utilization %** (consumed capacity/provisioned capacity), **minimum and maximum limits** 
* **Powered by Application Auto Scaling which also supports EC2, ECS, EMR, AppStream**

##### `default asg settings` read and write capacity of 5 reads and 5 writes, and 70% utilization

### Time to Live

* Time To Live (TTL) for DynamoDB allows you to define when items in a table expire so that they can be automatically deleted from the database.
* **TTL Attribute** – **The TTL attribute can be indexed or projected, but it cannot be an element of a JSON document.** 

### DynamoDB DAX (Accelerator)

**If you need to accommodate `unpredictable bursts` of `read activity`, you should use Auto Scaling in combination with DAX**

* It operates in **write-through** mode, **making DAX a great fit for eventually-consistent read-intensive workloads**
* **Each DAX cluster can contain 1 to 10 nodes; Clusters run within a VPC, with nodes spread `across Availability Zones`**

#### Features:

**1.Consistency** 

**2.Write-Throughs** - DAX is a write-through cache. However, **if there is a weak correlation between what you read and what you write, you may want to direct your writes to DynamoDB**.

### VPC EndPoint for DynamoDB

* VPC: **Access DynamoDB via secure Amazon VPC endpoint**
* Access Control: **restrict table access for each VPC endpoint** with a **unique IAM role and permissions**

#### Data pipeline Export DynamoDB Table to S3 and import data from s3 to dynamoDB

The Export DynamoDB table to S3 template schedules an Amazon EMR cluster to export data from a DynamoDB table to an Amazon S3 bucket. This template uses an Amazon EMR cluster, which is sized proportionally to the value of the throughput available to the DynamoDB table. 

**USAGE**

Using AWS Data Pipeline, you can quickly and easily provision pipelines that remove the development and maintenance effort required to manage your daily data operations, **letting you focus on generating insights from that data**

**AWS Data Pipeline provides built-in activities for common actions such as copying data between Amazon Amazon S3 and Amazon RDS, or running a query against Amazon S3 log data.**

## 2.RDS Performance 

#### For RDS, the `memory metrics` is highly critical 

### Vertical scaling 

#### Storage and instance type are decoupled:

* Scale compute/memory vertically up or down
* **change storage type**: gp2  iops
* **change storage size**: (scale ebs storage up to 16TB)
* **No downtime for storage scaling** and **instances Can re-provision 10PS on the fly**

### Horizontal Scaling

1. **Amazon Aurora can have up to 15 read replicas. and spread in `different AWS Regions`**
2. The Elastic Load Balancing (ELB) load balancer **does not support the routing of traffic to RDS instance**, other options such as **HAProxy** or we can use Route53 for lb, (`https://www.youtube.com/watch?v=sMEvCBwugLk&t=273s`).

### RDS HA (high availability)

#### Multi-AZ

* **Always in two Availability Zones within a Region**
* Database engine version upgrades happen on primary
* Synchronous replication—highly durable

#### Read Replicas

* **Asynchronous replication**—highly scalable
* **All replicas are active and can be used for read scaling**
* Can be within an Availability Zone, cross-AZ, or **cross-region**
* Database engine version upgrades independently from source instance
* **Can be manually promoted to a standalone database**

### RDS Manage backups

* **Amazon EBS snapshots stored in Amazon S3**
* **Snapshots can be copied across regions or shared with other accounts**
* **I/O operations to the database are suspended for a few minutes while the backup is in progress.**


### Performance Metrics

IOPS /   Latency   / Throughput / Queue Depth

### RDS cost optimization

1. **Amazon RDS `Reserved Instance`**
2. **Stop instance only pay for storage charge**


### Questions

1.A company is deploying a new two-tier web application in AWS. The company has limited staff and requires high availability, and the application requires **complex queries and table joins**. Which configuration provides the solution for the company’s requirements?

* **Amazon RDS for MySQL with Multi-AZ**     
* **complex queries and table joins** is not suitable for DynamoDB

**2.Read contention on RDS MySQL**

* **Deploy ElastiCache in-memory cache running in each availability zone**
* **Add an RDS MySQL read replica in each availability zone**

3.If I have multiple Read Replicas for my master DB Instance and I promote one of them, what happens to the rest of the Read Replicas?

**The remaining Read Replicas will still replicate from the older master DB Instance**

4.A user is accessing RDS from an application. The user has enabled the Multi-AZ feature with the MS SQL RDS DB. During a planned outage how will AWS ensure that a switch from DB to a standby replica **will not affect access to the application**?

**RDS uses DNS to switch over to standby replica for seamless transition**

**The DNS record for the RDS endpoint is changed from primary to standby.**

## 3.Aurora Performance

### Aurora cluster

* primary instance: **read-write**, **DML**, **DDL**
* 15 read-replicasds:  **read-only query**

### Amazon Aurora Connection

#### 1.Cluster endpoint

* **one cluster one primary instance connect to one cluster-endpoint**
* **cluster-point is only one point for all write such as DDL and DML** and Can used for **QUERY**

#### 2.Reader endpoint

* **one reader-endpoint for read-only connection for cluster**
* **provide `load-balancing mechanisms`** 
* **handle query intensive workload**

#### 3.custom endpoint

* **customer create endpoint up to 5 endpoints in one cluster**
* **can `perform load balancing` and chose one instance as connection**

#### 4.instance endpoint

* **connect to specific instance**
* **use for trouble shooting and diagnosis**


### Amazon Aurora Scaling

### vertical 

* **Compute scaling with cpu, ecu, memory, max_connections**
* **Need restart and have downtime**

### Horizontal

* **15 read replicas and `reader endpoint` offer load balancing**
* **database clone in one region, up to 15**
* **database dml and ddl `roll back`**

### auto scaling

* To meet your connectivity and workload requirements, **Aurora Auto Scaling dynamically adjusts the number of Aurora Replicas provisioned for an Aurora DB cluster.**
* **Target metrics: `CPU utilization ASG` & `Connections ASG`**
* Minimum and maximum capacity
* **Although Aurora Auto Scaling manages Aurora Replicas, the Aurora DB cluster must `start with at least one Aurora Replica`**


## 4.SQS (poll)

**support HTTP over SSL and TLS protocols for security**

### Standard SQS

#### features

* **At-least-one delivery**: ensure delivery of each message at least once, **but occasionally more than one copy or message is delivered**   
* Message level delivery, not data stream
* **don't guaranty FIFO delivery of message**
* variable message size, up to **256kb**
* **Access control and delay queue**
* **visibility timeout**

**How to minimize chances of duplicate processing in sqs**

Retrieve the message with an **increased visibility timeout**, **process the message**, **delete the message** from the queue

**Delay message: how to deal with empty queue to waste cpu and memory**

increase `ReceiveMessageTimeSeconds` 

#### use cases:

* fan out message
* **autoscaling can be used to determine the load of applications**

#### Questions

Your company plans to host a large **donation website** on Amazon Web Services (AWS). You anticipate a large and **undetermined amount of traffic that will create many database writes**. **To be certain that you do not drop any writes to a database hosted on AWS.** Which service should you use?

**Amazon Simple Queue Service (SQS) for capturing the writes and draining the queue to write to the database**


### SNS (push)

* Producers push messages to the topic, they created or have access to, 
* **SNS matches the topic to a list of subscribers who have subscribed to that topic,** 
* **Delivers the message to each of those subscribers**

#### support transport protocols

HTTP, HTTPS, Email, Email-JSON, SQS, SMS

**JSON:**

**MessageId, Timestamp, TopicArn, Type, UnsubscribeURL, Message, Subject, Signature**

### SWF (once assigned the tasks and never duplicate)

* **Managing a multi-step and multi-decision checkout process of an e-commerce website**
* **Orchestrating the execution of distributed and audible business processes**

## 5.Kinesis

Collect and process **large streams of data records** in **real time** Support **rapid and continuous data** intake and aggregation Kinesis applications are **data-processing applications or consumers**

* **Real-time aggregation of data**
* **Multiple applications can consume data from a stream** 
* **Kinesis stream** supports ordering of records, reading or replaying records **in the same order** 
* **Able to Read or process records in the same order after few hours or days from a stream** 
* Easy to say:
  * **stream of data**
  * real time analysis 
  * **multiple times process**
  * **highly durable, elastic and parallel**
  * in order 

#### Kinesis Stream

**Build your own custom applications that process or analyze streaming data**

#### Kinesis Firehose

**Easily load massive volumes of streaming data into Amazon S3 and Amazon Redshift**

#### Kinesis Analytics

**Easily analyze data streams using `standard SQL queries`.**

## 6.S3

### S3 Protecting Data

#### 1.KMS

S3 encrypt the uploaded object using plaintext data key to generate an encrypted version of your object, the s3 will associate the encrypted data key alongside your encrypted object and At last, **the plaintext data key will deleted from memory**

#### 2.S3 Master Encrypted Key

**Amazon S3 Server Side Encryption handles all encryption, decryption, and key management in a totally transparent fashion.**

**When you GET an encrypted object, s3 fetch and decrypt the key, and then use it to decrypt your data.**

#### 3.Customer master key with SSE

**simply supply your encryption key as part of a PUT and S3 will take care of the rest.** 

when you need the object, **you simply supply the same key as part of a GET**. 

#### 4.Questions

1.A user has enabled server side encryption with S3. The user downloads the encrypted object from S3. How can the user decrypt it?

* S3 does not support server side encryption
* S3 provides a server side key to decrypt the object
* The user needs to decrypt the object using their own private key
* **S3 manages encryption and decryption automatically**

what request header can be explicitly specified in a request to Amazon S3 to encrypt object data when saved on the server side?

2.**x-amz-server-side-encryption**

3.**After the object is restored the storage class still remains GLACIER**

4.[FOR SSEC-C] **It is possible to have different encryption keys for different versions of the same object**

5.[FOR SSEC-C] **The admin should send the keys and encryption algorithm with each API call**
 

### S3 new lifecycle

* Standard => **FA**.  (frequently access)
* Intelligent-Tiering => **Long-lived with changing or unknown access patterns**
* Standard-IA => **Long-lived, IFA**
* One zone-IA => **Long-lived, IFA, non-critical data**
* Glacier => **Data archiving with retrieval times (3-5 hours)** 
* Reduced Redundancy => **FA, non-critical, not recommended**
* **Glacier [3-5 hours]**
* **One-Zone IA, designed for 99.50% availability, and data will lost in AZ destruction**

### Cloudfront: Web / RTMP

#### CloudFront OAI (origin access identity)

**Features**

* **Only authorized users can access content from edge locations which stored in S3 bucket**
* **Prevent direct access to your Amazon S3 Bucket**
* **Only Cludfront can access Amazon S3 bucket**
* **After created, the new OAI bucket policy will apply to the S3 bucket**

### WAF (Web Application Firewall) Control Access to Your Content

**AWS WAF is a web application firewall that lets you monitor the HTTP and HTTPS requests that are forwarded to CloudFront, and lets you control access to your content.**

**Based on conditions that you specify, such as the IP addresses that requests originate from or the values of query strings, CloudFront responds to requests either with the requested content or with an HTTP 403 status code (Forbidden).**

**Add a WAF tier by creating a new ELB and an AutoScaling group of EC2 Instances running a host-based WAF. They would redirect Route 53 to resolve to the new WAF tier ELB. The WAF tier would their pass the traffic to the current web tier The web tier Security Groups would be updated to only allow traffic from the WAF tier Security Group**

### EFS VS S3

* EFS looks like a local filesystem to the whatever it is mounted to. So that means you can use operating system level commands **like: mv, copy, vi, nano**, etc 
* S3 you will need clients to interact with object in S3.
* If you wanted to **edit a file in EFS you could just use nano or vi and edit it**. 
* With S3 you would **need to download it, edit it, and load it backup**. 

### S3 User Policy

Allow an **IAM user** access to **one of your buckets** or **a folder in a bucket** or **group to have a shared folder in Amazon S3**

### S3 bucket policy

MFA, Read-Only Permission to an Anonymous User, **Specific IP Addresses**, **Specific HTTP Referrer**, **Amazon CloudFront Origin Identity**, Granting Cross-Account Permissions, **VPC Endpoints for Amazon S3**

##### Object permission (like ACL)

## 7.HTTPS

**AWS Certificate Manager(ACM)**: ACM make to easy to provision, manage, deploy, and renew SSL/TLS certificated on the AWS Cloud

**Example: ACM applied to Cloudfront and custom SSL certificate with cloudfront** 

When you use HTTPS for your load balancer listener, **you must deploy an SSL certificate on your load balancer**. **The load balancer uses this certificate to terminate the connection and decrypt requests from clients before sending them to the targets**. 

### VPC Flowlog

* Agentless 
* **Enable per ENI, per subnet, or per VPC**
* **Logged to AWS CloudWatch Logs** 

## 8.Redis

### Redis Security & Encryption

* **In-Transit:** Encrypt all communications between clients, server, nodes 
* **At-Rest**: Encrypt backups on disk and in Amazon S3 
* **Support for Redis AUTH: requiring the user to enter a password before they are granted permission to execute Redis commands on a password-protected Redis server** 


### Redis Cluster Auto Scaling

* **Scale memory and compute** 
* **Scale up to a cluster of 6.1 TiB of in-memory data** 
* **A cluster consists of 1 to 15 shards**
* **Each shard has a primary node and up to 5 replica nodes across multiple AZs for read scaling** 
* **Increase writes by adding shards** 

## 9.Lambda

#### Lambda function with specific AWS resources: particular Amazon S3 bucket, Amazon DynamoDB table, Amazon Kinesis stream, or Amazon SNS notification

**Lambda schedule functions**: Use timed event to schedule the invocation of the functiuon

lambda functions: **S3, DynamonDB, Kinesis, SNS notification**

#### How does AWS Lambda secure my code? 

* **AWS Lambda stores code in Amazon S3 and encrypts it at rest**. 
* **AWS Lambda performs additional integrity checks while your code is in use.** 

#### Components of Lambda

1. Source Service where events captured(S3, Dynamo, Kinesis, etc)
2. Lambda Service with your code
3. CloudWatch log group and log stream to capture logs
4. IAM Role and the following policy

### Lambda Adv. Setting

1. **Memory: change performance and cost**
2. DLQ Resource: SQS, SNS
3. VPC
4. KMS Key

### 10.ECS components

#### 1.ECS agent (kubelet)

* On every ec2 instance
* **ecs communicate with docker dameon docker ec2 instance**

#### 2.ecs cluster (nodes)

* group of ec2
* on demand, reserved, spot instances

#### 3.ecs task(spec)

* docker image, cpu, memory
* links between container, network, port, setting, IAM role

#### 4.ecs service (deployment)

* manage long-running workloads

## 11. additional

### Launching `Spot Instances` in Your Auto Scaling Group

When your Spot Instance is terminated, the Auto Scaling group attempts to launch a replacement instance to maintain the desired capacity for the group. If your maximum price is higher than the Spot market price, then it launches a Spot Instance.

### API Beanstalk with External RDS

* Create web app with application name: Docker & Multi-container docker
* You can configure additional RDS DB resource

#### Beanstalk uses proven AWS features and services:

**EC2, RDS, ELB, ASG, S3, SNS**

### AWS SFTP (SSH File Transfer Protocol)

#### ec2 mask failure

* **EC2 autorecovery**,  instance -> action -> cloudwatch monitoring (recover instance, stop, terminate, reboot)
* elastic ip

#### identity federation -> aws cognito -> iam role -> dynamoDB

#### AWS no cost api: ASG and cloudwatchs

### NACL and SG

**Private subnet nacl**

![Alt Image Text](adv/f1.jpg "Body image")

#### sg

* inbound: source, protocol, port range(80,443,22,3389),
* outbound: destination(sg), protocol, port range(1433, 3306)

![Alt Image Text](adv/f2.jpg "Body image")

### AWS CICD

![Alt Image Text](adv/f3.jpg "Body image")

## SAA failed test

1. Redis password set: **redis auth**
2. Aurora ELB check?  **reader endpoint**
3. S3 server encrypted data upload, what about get data?  **S3 decrypt object automatically s3 generate encrypt key to decrypt**
4. **How increase RDS write**？ **I think only way to increase RDS compute**
5. Cloudfront visit private object in s3 OAI specific url, Restricting Access to Amazon S3 Content by Using an Origin Access Identity
6. EFS and S3 1000 users access different files, which is choice?  **S3**. **EFS need login in**
7. DynamoDB 7 days HIGH available and after that become infrequent access,  only access by the end of year,  which is cost efficiency?      **time to live**
8. Api gateway export public ip to third party api
9. SSl to alb, how to resolve it?  **The load balancer uses this certificate to terminate the connection and decrypt requests from clients before sending them to the targets**
10. only allow HTTPS SG or **NACL**
11. Ordered incoming data event, which one is better SQS or Kinesis **Kinesis**. => **stream of data, multiple times process,real time analysis, highly durable, elastic and parallel, in order**
12. Event triggers lambda
13. Increase dynamodb performance better **1.ASG 2.DAX**
14. aws cognito
15. beanstalk with ECS which is better, ECS web server with rds or beanstalk with ECS.  **beanstalk with docker web sever and additional  RDS**
16. Elasticserach
17. aws sftp. => **SSH file transfer protocl**
18. asg with spot vs reserved instance =>  **Launching `Spot Instances` in Your Auto Scaling Group**
19. aws batch / elb stick session 
20. Amazon EC2 Dedicated instance / Placement group
21. aws codecommit & aws codedeploy / aws codepipeline and beanstalk
22. kinesis `update-shard-count` or merge
23. cloudformation sg `80 443 21`
24. anthena query in s3 / dynamnodb datapipeline => cost optimization
25. cloudwatch merics on calls / sqs on calls
26. terminate unbalance:  most instances/oldest launch configuration










