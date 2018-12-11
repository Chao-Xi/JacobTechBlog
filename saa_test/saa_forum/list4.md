### 1.Topic1

1. Route 53 (**Active-Active Failover vs Active-Passive Failover**)
2. EC2 spot instance request states
3. encryption: migrating data from an s3 -> redshift and **you want to ensure data is encrypted at rest on both**
4. client-side encryption and AWS KMS CMK vs client-side encryption and a client master key
5. **Cloudwatch logs** enabled by installing a **cloud-agent on ec2 instances**
6. if you want to monitor request information for instances do you use cloudwatch or cloudTrail

#### * client-side encryption and AWS KMS CMK vs client-side encryption and a client master key

S3 Security & Encryption

##### `SSE-S3` requires that Amazon S3 manage the data and master encryption keys. 
##### `SSE-C` requires that you manage the encryption key
##### `SSE-KMS` requires that AWS manage the data key but you manage the master key in AWS KMS.

#### * Cloudwatch logs enabled by installing a cloud-agent on ec2 instances

* Create an IAM role your instances will use to export logs to CloudWatch
* Install the agent
* Create the configuration file
* Start the agent

### 2.Topic2

* **1.E2 Instance types**
 * On Demand
 * Spot
 * Reserved

* **2.Amazon Athena**
  
Amazon Athena is an interactive query service that makes it easy to **analyze data in Amazon S3 using standard SQL**. 

**Athena is serverless**, so **there is no infrastructure to manage**, and **you pay only for the queries that you run**.  
  
* **3.System Manager**

Systems Manager provides a unified **user interface** so you can **view operational data from multiple AWS services** and **allows you to automate operational tasks across your AWS resources.**

With Systems Manager,

**You can group resources, like Amazon EC2 instances, Amazon S3 buckets, Amazon RDS instances, by application,** 

view operational data for **monitoring and troubleshooting**, and **take action on your groups of resources**. 


  * SHORTEN THE TIME TO DETECT PROBLEMS
  * EASY TO USE AUTOMATION
  * IMPROVE VISIBILITY AND CONTROL
  * MANAGE HYBRID ENVIRONMENTS
  * MAINTAIN SECURITY AND COMPLIANCE


* **4.AWS Directory Services (Simple AD / AD Connector)**

AWS Directory Service provides multiple ways to set up and run Amazon Cloud Directory, Amazon Cognito, and Microsoft AD with other AWS services. Amazon Cloud Directory provides a highly scalable directory store for your application’s multihierarchical data.

#####  Amazon Cloud Directory

With Cloud Directory, you can organize application data into multiple hierarchies to support many organizational pivots and relationships across directory information.

##### Amazon Cognito

Amazon Cognito is a user directory that adds sign-up and sign-in to your mobile app or web application using Amazon Cognito User Pools.

##### AD Connector

AD Connector uses your existing on-premises Microsoft Active Directory to access AWS applications and services.

##### Simple AD

Simple AD is a **Microsoft Active Directory–compatible directory** that is powered by Samba 4 and hosted on the AWS cloud.

##### Microsoft AD

Microsoft AD is a Microsoft Active Directory hosted on the AWS Cloud. It integrates most Active Directory features with AWS applications.


* **5.Cross Account Permissions**

You can create **Role for cross-account access**, 
  
   * **Role for cross-account access**
   * provide access between AWS accounts you own
   * Then add ARN to the `sts:AssumeRole` in `across_account` policy
 
 
* **6.Trusted Advisor**

1. Cost Optimization
2. Fault Tolerance
3. Performance
4. Service Limits
5. security

* **7.Amazon Aurora user permissions**

You can choose to use IAM for database user authentication by simply selecting a checkbox during the DB instance creation process. 

**Existing DB instances can also be modified to enable IAM authentication**.

**8.What are dynamoDB streams**

* Time ordered and partitioned change log 
* Provides a stream of updates, inserts, deletes 
* Guaranteed to be delivered only once 
* Use Kinesis Client Library (KCL). Lambda, or API to query pre-image, post-image, key, timestamp 
* Scales with your table 

**9.EC2 Placement Groups**

You can launch or start instances in a **placement group**, which d**etermines how instances are placed on underlying hardware**

* **Cluster**—clusters instances into a `low-latency group` in a `single Availability Zone`
* **Spread**— **spreads instances across underlying hardware**

There is no charge for creating a placement group.

Cluster placement groups are recommended for applications that benefit from **low network latency, high network throughput, or both, and if the majority of the network traffic is between the instances in the group**. 


Spread placement groups are recommended for applications that have a **small number of critical instances that should be kept separate from each other**. Launching instances in a spread placement group reduces the risk of simultaneous failures that might occur when instances share the same underlying hardware. Spread placement groups provide access to distinct hardware, and are therefore suitable for mixing instance types or launching instances over time.

### 3.Topic3

### 1) Storage Options:

a) About 3 questions on EFS: Be able to identify object storage (S3) VS Elastic file System (EFS) that can be used as a shared drive by multiple instances.

b) Also know when you need to use EBS vs EFS. EFS can not be used as the root volume.

### 2) Micro-Services:

a) Implement low cost & Scalable solutions. I found Lambda, API Gateway, Dynamo ELB, and S3 to play a big part on this.

### 3) Security:

a) know that you can allow access based on security groups, which might be a better option than specific IPs of instances.

b) Roles and VPC endpoints (PrivateLinks are preferred instead of Access keys.

c) Use VPC endpoint to access S3 from a private instance.

### 3) High Availability
a) know that NAT Gateways should be deployed in multiple AZs.

b) Route 53 should be used when routing between regions.....not load balancers.

c) Multi-AZ is used for high resiliency and not for performance improvement.

### 4) High Performance

a) Use a caching system in front of your db for better performance.

b) You can write metadata to Dynamo.

c) Use RDS Read replicas to improve DBs performance.

Other Services that appeared, but not very frequently were: CloudFormation, ECS, Elastic BeanStalk

### 4.Topic4 Which combination of two policies enables AWS identity and access management cross- account access?

A. Permission policy

D. Trust policy

