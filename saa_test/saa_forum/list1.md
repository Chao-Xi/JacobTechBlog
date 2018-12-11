## 1. Exam Feedback


1.Know what instance types can be launched from which types of AMIs, and which instance types require an HVM AMI.

2.Bastion hosts are instances that **sit within your public subnet** and are typically accessed using SSH or RDP. **Once remote connectivity has been established with the bastion host, it then acts as a ‘jump’ server**, **allowing you to use SSH or RDP to login to other instances (within private subnets) deeper within your network.** When properly configured through the use of security groups and Network ACLs, **the bastion essentially acts as a bridge to your private instances via the Internet."**

3.Know the difference between **Directory Service's AD Connector** and **Simple AD**. "Use Simple AD if you need an inexpensive Active Directory–compatible service with the common directory features.  AD Connector lets you simply connect your existing on-premises Active Directory to AWS."

4.Know how to **enable cross-account access with IAM**. "**To delegate permission to access a resource, you create an IAM role that has two policies attached.** The permissions policy grants the user of the role the needed permissions to carry out the desired tasks on the resource. The trust policy specifies which trusted accounts are allowed to grant its users permissions to assume the role. The trust policy on the role in the trusting account is one-half of the permissions. The other half is a permissions policy attached to the user in the trusted account that allows that user to switch to, or assume the role."

5.Route53 supports all of the different DNS record types, and when you would use certain ones over others.  CNAME, Alias and a record set

6.Know which services have native encryption at rest within the region,

**AWS Storage Gateway, by default, uploads data using SSL and provides data encryption at rest when stored in S3 or Glacier using AES-256**

Which of the following services natively encrypts data at rest within an AWS region?
AWS Storage Gateway & Amazon Glacier
What does the AWS Storage Gateway provide? It allows to integrate on-premises IT environments with Cloud Storage

7.If you associate additional EIPs with that instance, you will be charged for each additional EIP associated with that instance per hour on a pro rata basis. Additional EIPs are only available in Amazon VPC. To ensure efficient use of Elastic IP addresses, we impose a small hourly charge when these IP addresses are not associated with a running instance or when they are associated with a stopped instance or unattached network interface."

8.Know what four high level categories of information Trusted Advisor

* Cost Optimization
* Performance
* Security
* Fault Tolerance
* Service Limits

9.Know how to troubleshoot a connection time out error when trying to connect to an instance in your VPC. "**You need a security group rule that allows inbound traffic from your public IP address on the proper port**, **you need a route that sends all traffic destined outside the VPC (0.0.0.0/0) to the Internet gateway for the VPC**, the network **ACLs must allow inbound and outbound traffic from your public IP address on the proper port,**" etc. 

10.Understand how you might set up consolidated billing and cross-account access such that individual divisions' resources are isolated from each other, but corporate IT can oversee all of it.

11.You can only specify one launch configuration for an Auto Scaling group at a time, and **you can't modify a launch configuration after you've created it**. Therefore, **if you want to change the launch configuration for your Auto Scaling group, you must create a launch configuration and then update your Auto Scaling group with the new launch configuration.** 

**When you change the launch configuration for your Auto Scaling group, any new instances are launched using the new configuration parameters, but existing instances are not affected.**"


12.Know how **DynamoDB (durable, and you can pay for strong consistency)**, **Elasticache (great for speed, not so durable)**, and **S3 (eventual consistency results in lower latency)** compare to each other in terms of durability and low latency.

13.Know the difference between **bucket policies**, **IAM policies**, and **ACLs** for use **with S3**

* With IAM policies, companies can grant `IAM users fine-grained control` to their Amazon S3 **bucket or objects** while also retaining full control over everything the users do.
* With bucket policies, `companies can define rules which apply broadly across all requests to their Amazon S3 resources`, such as granting `write` privileges to a subset of Amazon S3 resources. Customers can also restrict access based on an aspect of the request, such as HTTP referrer and IP address.
* With ACLs, customers can grant specific permissions (i.e. READ, WRITE, FULL_CONTROL) to specific users for an individual bucket or object."

14.**"Public snapshots of encrypted volumes are not supported, but you can share an encrypted snapshot with specific accounts.**"


15.use **ELB cross-zone load balancing** to ensure even distribution of traffic to EC2 instances in multiple AZs registered with a load balancer

16.**EC2, EMR, BeanStalk and OpsWorks** allow you to retain full admin privileges of the underlying EC2 instances

17.Well Architected Framework - **Security, Cost, Performance and, Reliability of the solution**

## 2. Exam Topics

### 65 questions, 130 Minutes. 

### Topics:


* Lots of questions on EFS - Understand use, and comparison to EBS and S3

* Lots of questions on RDS 
* Lots of questions on ELBs. Specifically, ALBs and Classic ELBs, and choosing which, when.
* Quite a few questions on KMS, encryption, choosing what product when. Understand all options/scenarios synced with S3.
* Several questions on Dedicated instance types for EC2, again what to choose/when scenario
* Several on EBS Types, and needing to choose the correct type - SSD, Provisioned IOPs, Throughput Optimized
* Several on/with VPC Endpoints
* Several on Cloud Watch and Cloud Trail - API tracks, Flow Logging, Metrics, etc
* 5+ on Lambda
* 5+ on DynamoDb (Including one involving DAX)
* 2+ on Kinesis
* 2-3 on Docker
* 2-3 API Gateway
* 1 on Redshift
* AWS Glue was one option
* VPCs and subnet structure. Including communication between them, with ELBs, and off-premise.
* of course security groups and use, as well.


* Know the different database types and when to use DynamoDB, RDS etc
* Know Bastion Hosts (Jump Servers) hosted in public subnet etc 
* Understand when to use various types of ELBs
* Know your encryption techniques, volumes , Snapshot creation etc
* API Gateway functions and Cloudfront
* Quite a few questions on Autoscaling, types of instances, Launch configurations
* Understand VPC - quite a few questions on Public / Private Subnet communications
* Cloud Watch and Cloud Trail - when to use, VPC Logs etc
* Know the differences between Kinesis streams, Firehose etc
* Use of Elastic Beanstalk / Docker
* Security groups , NACLs and use within VPC were also asked

## 3. RRS - barely mentioned in the lectures but lots of questions in the quiz

### S3 Reduced Redundancy Storage is:

Reduced Redundancy Storage (RRS) is an Amazon S3 storage option that enables customers to store noncritical, reproducible data at lower levels of redundancy than Amazon S3’s standard storage. 

* Backed with the Amazon S3 Service Level Agreement for availability.
* Designed to provide 99.99% durability and 99.99% availability of objects over a given year. This durability level corresponds to an average annual expected loss of 0.01% of objects.
* Designed to sustain the loss of data in a single facility.
 
**Durability: 99.99%   Availability: 99.99% Concurrent facility fault tolerance: 1**

The Reduced Redundancy Storage (RRS) storage class is designed for noncritical, reproducible data that can be stored with less redundancy than the STANDARD storage class. Important We recommend that you not use this storage class. **The STANDARD storage class is more cost effective**.

* S3-Standard
 
* S3-Standart-IA
 
* S3-OneZone-IA 

* S3-RRS
 
* Glacier

A. Low Cost(starting with Lowest)

1. Glacier

2. One Zone -IA

3. S3 -IA

B. Best Availability (Highest Availability)

1. S3

2. S3 -IA

3. OZ-IA

4. Glacier

C. Long Retention

**One and Only : Glacier**

Best Retrial Time:

1. S3

2. S3 -IA

3. OZ-IA

4. Glacier

D. Production / Critical Data

**One and Only - S3**


 
## 4. mounting multiple instances.

**EFS can mount to multiple instances**


## 5 Route 53 geoproximity routing

Geoproximity routing lets Amazon Route 53 route traffic to your resources based on the geographic location of your users and your resources. 

**You can also optionally choose to route more traffic or less to a given resource by specifying a value, known as a bias**, that expands or shrinks the size of the geographic region from which traffic is routed to a resource

## 6.Copy s3 data from one bucket to another bucket don't have to use `--region` anymore

## 7.Resizing a volume on fly

You can change EBS volumes on the fly. Maybe it would make sense to verify that you can only increase an EBS volumes size on the fly, you cannot decrease the size of it.


## 8.You can a standard magnetic volume now

## 9. S3 - Versioning  Cross-Region Replication(CRR)

### Deleted an object from the source bucket, but the object is still present in the destination bucket.

If you specify an object version ID to delete in a DELETE request, Amazon S3 deletes that object version in the source bucket, but it doesn't replicate the deletion in the destination bucket. In other words, it doesn't delete the same object version from the destination bucket. This protects data from malicious deletions. 

* Amazon S3 does not replicate the delete marker.

## 10.Cross-region VPC peering

## 11.What is the difference between ElastiCache and CloudFront?

ElastiCache uses redis and memcached to improve the performance of web applications by allowing you to retrieve information from fast, managed, in-memory data stores, instead of relying entirely on slower disk-based databases.

While CloudFront is a global content delivery network (CDN) service that accelerates delivery of your websites, APIs, video content or other web assets


## 12. Question

To serve Web traffic for a popular product your chief financial officer and IT director have purchased 10 ml

large heavy utilization Reserved Instances (RIs) evenly spread across two availability zones: Route 53 is used to

deliver the traffic to an Elastic Load Balancer (ELB). After several months, the product grows even more

popular and you need additional capacity As a result, your company purchases two C3.2xlarge medium

utilization Ris You register the two c3 2xlarge instances with your ELB and quickly find that the ml large

instances are at 100% of capacity and the c3 2xlarge instances have significant capacity that’s unused Which

option is the most cost effective and uses EC2 capacity most effectively?

**Use a separate ELB for each instance type and distribute load to ELBs with Route 53 weighted round robin**

**A solves the problem, however you are adding another ELB which will increase your bill by $10 per month.**

## 13. Free test practice
https://www.whizlabs.com/aws-solutions-architect-associate/
