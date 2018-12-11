###  1.VPC Endpoints

A VPC endpoint enables you to privately connect your VPC to supported AWS services and VPC endpoint services powered by **PrivateLink** **without requiring an internet gateway, NAT device, VPN connection**, or **AWS Direct Connect connection**. 

Traffic between your VPC and the other service does not leave the Amazon network.

**Endpoints are virtual devices**. **They are horizontally scaled, redundant, and highly available VPC components** that allow communication between instances in your VPC and services without imposing availability risks or bandwidth constraints on your network traffic.

#### Gateway Endpoints

* Amazon S3
* DynamoDB

### 2.Duplicate answers in Final Exam S3 URL examples

* http://s3-aws-region.aws.com/mynewbucket  => **path-style URL**
* http://mynewbucket.s3-aws-region.aws.com  => **the bucket is in N.Virginia**

### Questions

Q1: In reviewing the Auto Scaling events for your application you notice that your application is scaling up and down multiple times in the same hour. What design choice could you make to optimize for cost while preserving elasticity?

Choose 2 answers

A. Modify the Auto Scaling group termination policy to terminate the oldest instance first.

**B. Modify the Auto Scaling group cool-down timers.**

C. Modify the Auto Scaling policy to use scheduled scaling actions

**D. Modify the Amazon CloudWatch alarm period that triggers your Auto Scaling scale down policy.**

E. Modify the Auto Scaling group termination policy to terminate the newest instance first.

Q2: What action is required to establish an Amazon Virtual Private Cloud (VPC) VPN connection between an on-premises data center and an Amazon VPC virtual private gateway?

A. Assign a static Internet-routable IP address to an Amazon VPC customer gateway.

B. Use a dedicated network address translation instance in the public subnet.

**C. Establish a dedicated networking connection using AWS Direct Connect.**

D. Modify the main route table to allow traffic to a network address translation instance.

Q3: A startup company hired you to help them build a mobile application, that will ultimately store billions of images and videos in Amazon Simple Storage Service (S3). The company is lean on funding, and wants to minimize operational costs, however, they have an aggressive marketing plan, and expect to double their current installation base every six months. Due to the nature of their business, they are expecting sudden and large increases in traffic to and from S3, and need to ensure that it can handle the performance needs of their application.   What other information must you gather from this customer in order to determine whether S3 is the right option?

A. You must know how many customers the company has today, because this is critical in understanding what their customer base will be in two years.

B. You must find out the total number of requests per second at peak usage.

**C. You must know the size of the individual objects being written to S3, in order to properly design the key namespace.**

D. In order to build the key namespace correctly, you must understand the total amount of storage needs for each S3 bucket.

### Question:  How far apart are availability zones?

1.Your company has a security compliance that states all data must be duplicated at least 200 miles apart. Which solution would fit this requirement?

**A: 2 buckets in 2 different AZ's.**


2.You are auditing your RDS estate and you discover an RDS production database that is not encrypted at rest. This violates company policy and you need to rectify this immediately. What should you do to encrypt the database as quickly and as easy as possible.

A. Use AWS Database Migration Service

B. Create a new DB Instance with encryption enabled and then manually migrate your data into it.

**C. Take a snapshot of your unencrypted DB Instance and then restore it making sure you select to encrypt the new copy.**

D. Use the RDS Import/Export Wizard to migrate the unencrypted RDS instance across to a new encrypted database.

3.You've been tasked with the implementation of an offsite backup/DR solution. You'll only be responsible only for flat files and server backup. Which of the following would you include in your proposed solution?

A. EC2

**B. S3**

**C. Snowball**

**D. Storage Gateway**

**B, C, and D are storage technologies that can be used to transfer onsite data into the cloud, along with Glacier as well** 

4.Which of the following will occur when an EC2 instance in a VPC (Virtual Private Cloud) with an associated Elastic IP is stopped and started? (Choose 2 answers)

A. The Elastic IP will be dissociated from the instance 

**B. All data on instance-store devices will be lost**

C. All data on EBS (Elastic Block Store) devices will be lost 

D. The ENI (Elastic Network Interface) is detached 

**E. The underlying host for the instance is changed**

5.To protect S3 data from both accidental deletion and accidental overwriting, you should:

**A. enable S3 versioning on the bucket**

B. access S3 data using only signed URLs 

C. disable S3 delete using an IAM bucket policy 

D. enable S3 Reduced Redundancy Storage 

**E. enable Multi-Factor Authentication (MFA) protected access**

**6.Multiple subnets in the same AZ. It's a one (AZ) to many (subnet) relationship.**


7.You are planning on hosting a web application which consists of a web server and database server. They are going to be hosted on different EC2 Instances in different subnets in a VPC. Which of the following can be used to ensure that the database server only allows traffic from the web server.

**A. Make Use of SG**
B. Make Use of VPC flow logs
C. Make use of NACL
D. Make use of IAM roles.


### Question:  EMR and Kinesis?

* **Kinesis is for aggregating and temporarily storing high volume data**, like IoT or weather sensors etc, that report lots of data frequently. The data is kept in the stream for 24 hours, and multiple workers can pick up the same data for processing.

* **EMR is for running apps like Hadoop and Spark**, **for analyzing Big Data** (meaning huge amounts of data), and gaining insights on trends and patterns in that data.


### Elastic Beanstalk Question on AWS practice Test

For which of the following workloads should a solution architect consider using elastic beanstalk (choose 2)

**1) A web application using Amazon RDS**

2) An enterprise data warehouse

**3) A long running worker process**

4) A static website

5) A management task run once nightly.


### RDS Bottlenecking

You have a production application that is on the largest RDS instance possible, and you are still approaching CPU utilization bottlenecks. You have implemented read replicas, ElastiCache and even CloudFront and S3 to cache static assets, but you are still bottlenecking. What should be your next step?

**A. You should implement database partitioning and spread your data across multiple DB instances**

B. You have reached the limits of public cloud. You should get a dedicated database server and host this locally within your data center

C. You should consider using RDS Multi AZ and using the secondary AZ nodes as read only nodes to further offset load （disaster recovery）

D. You should provision a secondary RDS instance and then implement ELB to spread the load between the two RDS instances (doesn't solve questions)


### snapshot vs AMI

1. snapshot for data-volume

2. **While you can create an AMI from a snapshot of a root volume, you can only create a functional image from a Linux OS snapshot.**





