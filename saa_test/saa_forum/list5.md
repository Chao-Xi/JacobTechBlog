### 1.Can we mount EBS volume of one EC2 instance to another in case that instance is terminated

we need to understand difference between **root “OS” volume** and **“data” volume.**

**EBS volume can be attached only to one instance at a time.**

EBS volume is AZ wide resource (in one specific AZ).

**Snapshot of EBS volume is Region wide resource.**

**AMI (image) created from root volume is Region wide resource.**

#### Root volumes:

* Option 1: You can detach root volume from stopped instance and attach it to another instance in the same AZ as data volume. 
* Option 2: Create root volume snapshot of running/stopped instance. From snapshot you can create a volume and attach it as data volume to another instance or create AMI (image) and start a new instance using this AMI

#### Data volumes:

* Option 1: Data volume can be created/attached/detached on the fly. 
* Option 2: **You can create snapshot of data volume**, create new volume from snapshot in desired AZ and attach it.


### 2.Route 53 policy comparaision


* Geolocation Based routing policy - **compliance and regulatory purpose**
* Latency Based routing policy - **performance purpose**


### 3.What is difference between stateless & statefull

* Security Groups control connectivity to and from an EC2 instance or instances 
* ACLs control connectivity to a subnet.

#### Stateful 

Any connection inbound will also allow the response to be returned outbound without additional rules or will override an explicit DENY.

#### Stateless

**you must explicitly ALLOW traffic in both directions.**
 
 
 
#### 3. you need to keep your storage costs to a minimum, and you are happy to temporally lose access to up to 0.1% of uploads per year."

The answer should be Storage-IA, not Storage-One Zone-IA

**One Zone IA only has 99.5% availability which means 0.5% of availability loss a year**, **not fitting the requirements.**

#### 4. Your application has been migrated from on-premise to AWS in your company and you will not be responsible for the ongoing maintenance of packages. Which of the below service allows for access to the underlying infrastructure. 

**A.Elastic Beanstalk**

**B.EC2**

C.DynamoDB

D.RDS


**Elastic Beanstalk:**

**AWS Elastic Beanstalk is an easy-to-use service for deploying and scaling web applications** and services developed with Java, .NET, PHP, Node.js, Python, Ruby, Go, and Docker on familiar **servers such as Apache, Nginx, Passenger, and IIS.**


#### 5.

A Solutions Architect must select the storage type tor a **big data application** that requires **very high sequential I/O**. **The data must persist if the instance is stopped**. Which of the following storage types will provide the best fit at the **LOWEST cost** for the application?

A. An Amazon EC2 instance store local SSD volume. (WRONG: The data must persist if the instance is stopped)

B. An Amazon EBS provisioned **IOPS SSD** volume (WRONG: LOWEST cost)

**C. An Amazon EBS throughput optimized HDD volume (Yes: Low cost HDD volume, Big data)**

D. An Amazon EBS general purpose SSD volume (WRONG: very high sequential I/O, Big data application)


#### 6.

A workload in an Amazon VPC consist of an Elastic Load Balancer that distributes incoming requests across a fleet of six Amazon EC2 instances. Each EC2 instance stores and retrieves data from an Amazon DynamoDB table.

**Which of the following provisions will ensure that this workload a highly available?**


A. Provision DynamoDB tables across a minimum of two Availability Zones

B. Provision the EC2 instances evenly across a minimum of two Availability Zones in two regions

**C. Provision the EC2 instances evenly across a minimum of two Availability Zones in a single region**.  (EC2 Placement group, **cluster** perform better than **spread**)

D. Provision the Elastic Load Balancer to distribute connections across multiple Availability Zones

#### 7.

Your Amazon EC2 instances must access the AWS API, so you created a NAT gateway in an existing subnet.

When you try to access the AWS API, you are unsuccessful.

What could be preventing access?


A. The instances need an IAM role granting access to the NAT gateway (wrong, concept confusion)

**B. The NAT gateway subnet does not have a route to an Internet gateway**

C. The NAT gateway does not have a route to the virtual private gateway (wrong, concept confusion)

D. The instances are not in the same subnet as the NAT gateway (Wrong, add default route table inbound , it works)


#### 8. AWS resource explorer

**System manger**


#### 9.

 A company has an application that uses Amazon CloudFront for content that is hosted on an Amazon S3 bucket. After an unexpected refresh, the users are still seeing old content. Which step should the Solutions Architect take to ensure that new content is displayed?
 
A. Perform a cache refresh on the CloudFront distribution that is serving the content

**B. Perform an invalidation on the CloudFront distribution that is serving the content**

**[Purging cached data in Cloudfront is referred to as an Invalidation. When you select a CloudFront distribution, you should see an Invalidations tab.]**

C. Create a new cache behavior path with the updated content

D. Change the TTL value tor removing the old objects.


#### 10. 

An application tier currently hosts **two web services on the same set of instances**, listening on different ports.

Which AWS service should a Solutions Architect use to route traffic to the service based on the incoming request path?

**A. AWS Application Load Balancer** (two web services on the same set of instances)

B. Amazon CloudFront

C. Amazon Route 53

D. AWS Classic Load Balancer


#### 11

You have an Amazon EC2 instance in a VPC that is in a **stopped state**. Which of the following actions can you perform on this instance?

**A. Change security groups**

B. Disable detailed monitoring

C. Attach to an Auto Scaling group 
(An instance in a stopped state cannot be connected to an AutoScaling Group)

D. Detach the network interface

**For your additional question about creating an ami from an instance in a stopped state. Yes you can**

#### 12. 

**/16 the biggest CIDR block provided by AWS**
 
#### 13 availability on S3

The S3 Standard storage class is designed for 99.99% availability, the S3 Standard-IA storage class is designed for 99.9% availability, and the S3 One Zone-IA storage class is designed for 99.5% availability
