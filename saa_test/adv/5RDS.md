## AWS RDS Monitoring & Notification

* RDS integrates with CloudWatch and provides metrics for monitoring
* CloudWatch alarms can be created over a single metric that sends an SNS message when the alarm changes state
* RDS also provides SNS notification whenever any RDS event occurs

### RDS Event Notification

* RDS uses the SNS to provide notification when an RDS event occurs
* **RDS groups the events into categories**, which can be subscribed so that a notification is sent when an event in that category occurs.
* **Event category for a DB instance, DB cluster, DB snapshot, DB cluster snapshot, DB security group or for a DB parameter group can be subscribed**

1.You run a web application with the following components Elastic Load Balancer (ELB), 3 Web/Application servers, 1 MySQL RDS database with read replicas, and Amazon Simple Storage Service (Amazon S3) for static content. Average response time for users is increasing slowly. What three CloudWatch RDS metrics will allow you to identify if the database is the bottleneck? Choose 3 answers

* The number of outstanding **IOs waiting** to access the disk
* **The amount of write latency**
* The amount of time a **Read Replica DB Instance** lags behind the source DB Instance

2.Typically, you want your application to check whether a request generated an error before you spend any time processing results. The easiest way to find out if an error occurred is to look for an _____Error_____ node in the response from the Amazon RDS API.

3.In the Amazon CloudWatch, which metric should I be checking to ensure that your DB Instance has enough free storage space?

**FreeStorageSpace**

4.A user is receiving a notification from the RDS DB whenever there is a change in the DB security group. The user does not want to receive these notifications for only a month. Thus, he does not want to delete the notification. How can the user configure this?

**Change the Enable button for notification to “No” in the RDS console**

5.A sys admin is planning to subscribe to the RDS event notifications. For which of the below mentioned source categories the subscription cannot be configured?

**DB options group**

6.A user is planning to setup notifications on the RDS DB for a snapshot. Which of the below mentioned event categories **is not supported** by RDS for this snapshot source type?

**Backup**

7.A system admin is planning to setup event notifications on RDS. Which of the below mentioned services will help the admin setup notifications?

**AWS SNS**

8.A user has setup an RDS DB with Oracle. The user wants to get notifications when someone modifies the security group of that DB. How can the user configure that?

**Configure event notification on the DB security group**

9.It is advised that you watch the Amazon CloudWatch “_____” metric (available via the AWS Management Console or Amazon Cloud Watch APIs) carefully and recreate the Read Replica should it fall behind due to replication errors.

**Replica Lag**

## AWS RDS Security

* Secure Socket Layer (SSL) connections with DB instances
* RDS encryption to secure RDS instances and snapshots at rest.

### Once encryption is enabled for an RDS instance,

* logs are encrypted
* snapshots are encrypted
* automated backups are encrypted
* read replicas are encrypted

**Cross region replicas and snapshots copy does not work since the key is only available in a single region**

### RDS DB Snapshot considerations

* DB snapshot encrypted using an KMS encryption key can be copied
* An unencrypted DB snapshot can be copied to an encrypted snapshot, a quick way to add encryption to a previously unencrypted DB instance.
* Encrypted snapshot can be restored only to an encrypted DB instance
* Copying an encrypted snapshot shared from another AWS account, requires access to the KMS encryption key used to encrypt the DB snapshot.
* Because KMS encryption keys are specific to the region that they are created in, encrypted snapshot cannot be copied to another region

### SSL to Encrypt a Connection to a DB Instance

**Encrypt connections using SSL for data in transit between the applications and the DB instance**

### RDS Security Groups

### RDS Security questions

1.Can I encrypt connections between my application and my DB Instance using SSL?

**Yes**

2.Which of these configuration or deployment practices is a security risk for RDS?

**RDS in a public subnet** 

## Relation Database Service – RDS Overview

### However, as it is a managed service, shell (root ssh) access to DB instances is not provided  (No admin access)

* Regions and Availability Zones
* Security Groups
* DB Parameter Groups： A DB parameter group contains engine configuration values that can be applied to one or more DB instances of the same instance type
* DB Option Groups

### RDS Interfaces

* AWS RDS Management console
* Command Line Interface
* Programmatic Interfaces which include SDKs, libraries in different languages, and RDS API

### Questions

1.If I modify a DB Instance or the DB parameter group associated with the instance, should I reboot the instance for the changes to take effect?

**Yes**

2.What is the name of licensing model in which I can use your existing Oracle Database licenses to run Oracle deployments on Amazon RDS?

**Bring Your Own License**

3.Will I be charged if the DB instance is idle?

**Yes**

4.What is the minimum charge for the data transferred between Amazon RDS and Amazon EC2 Instances in the same Availability Zone?

**No charge. It is free.**

5.Does Amazon RDS allow direct host access via Telnet, Secure Shell (SSH), or Windows Remote Desktop Connection?

**No**

6.What are the two types of licensing options available for using Amazon RDS for Oracle?

**BYOL and License Included**

7.A user plans to use RDS as a managed DB platform. Which of the below mentioned features is **not supported** by RDS?

**Automated scaling to manage a higher load**

* Automated backup
* Automated failure detection and recovery     => YES
* Automated software patching

8.A user is launching an AWS RDS with MySQL. Which of the below mentioned options allows the user to configure the InnoDB engine parameters?

**Parameter groups**

9.A user is planning to use the AWS RDS with MySQL. Which of the below mentioned services the user is **not going** to pay?

**RDS CloudWatch metrics**

* Data transfer
* Data storage           =>   PAY
* I/O requests per month

## Amazon RDS Basic Operational Guidelines

* Monitoring : Memory, CPU, and storage usage should be monitored.
* Scaling: 
* Backups
* Performance
* Multi-AZ & Failover


### DB Instance RAM Recommendations

* If scaling up the DB instance class with more RAM, results in a dramatic drop in ReadIOPS, the working set was not almost completely in memory.

### Using Enhanced Monitoring to Identify Operating System Issues

Amazon RDS provides metrics in real time for the **operating system (OS)** that your DB instance runs on.

### Using Metrics to Identify Performance Issues

A DB instance has a number of different categories of metrics which **includes CPU, memory, disk space, IOPS, db connections and network traffic,** and how to determine acceptable values depends on the metric.

1.You are running a database on an EC2 instance, with the data stored on Elastic Block Store (EBS) for persistence At times throughout the day, you are seeing large variance in the response times of the database queries Looking into the instance with the isolate command you see a lot of wait time on the disk volume that the database’s data is stored on. What two ways can you improve the performance of the database’s storage while maintaining the current persistence of the data? Choose 2 answers

* Move the database to an EBS-Optimized Instance
* Use Provisioned IOPs EBS

2.Amazon RDS automated backups and DB Snapshots are currently supported for only the _____InnoDB_____ storage engine.

## RDS Back Up, Restore and Snapshots

RDS creates a **storage volume snapshot** of the DB instance, **backing up the entire DB instance and not just individual databases.**

RDS provides two different methods **Automated and Manual for backing up your DB instances**:

### Automated backups

* Automated backups are enabled by default for a new DB instance.
* Backups created during the backup window are retained for a user-configurable number of days , known as **backup retention period**
* **for Multi-AZ DB deployments, there is No I/O suspension since the backup is taken from the standby instance**
* Automated DB snapshots are deleted when
  * **the retention period expires**
  * **the automated DB snapshots for a DB instance is disabled**
  * **the DB instance is deleted**
* When a DB instance is deleted, **all automated backups are deleted and cannot be recovered**


### DB Snapshots (User Initiated)

**RDS keeps all manual DB snapshots until explicitly deleted**

* Creating DB snapshot on a Single-AZ DB instance results in a brief I/O suspension that typically lasting no more than a few minutes.
* Multi-AZ DB instances are not affected by this I/O suspension since the backup is taken on the standby instance

### DB Snapshot Restore

A DB instance can be restored with a **different storage type** and **different edition of the DB engine**

**AWS now allows copying encrypted DB snapshots between accounts and across multiple regions as seamlessly as unencrypted snapshots.**

### DB Snapshot Sharing

* Manual DB snapshot or DB cluster snapshot can be shared with up to 20 other AWS accounts.
* DB snapshots that have been encrypted “at rest” using the AES-256 encryption algorithm can be shared

1.Amazon RDS automated backups and DB Snapshots are currently supported for only the _____InnoDB_____ storage engine

2.Automated backups are enabled by default for a new DB Instance.

**TRUE**

3.Amazon RDS DB snapshots and automated backups are stored in

**Amazon S3**

4.You receive a frantic call from a new DBA who accidentally dropped a table containing all your customers. Which Amazon RDS feature will allow you to reliably restore your database to within 5 minutes of when the mistake was made?

**RDS automated backup**

5.Changes to the backup window take effect ___mmediately___.

6.You can modify the backup retention period; valid values are 0 (for no backup retention) to a maximum of _____35______ days.

7.Amazon RDS automated backups and DB Snapshots are currently supported for only the ___InnoDB ___ storage engine

8.What happens to the I/O operations while you take a database snapshot?

**I/O operations to the database are suspended for a few minutes while the backup is in progress.**

9.True or False: When you perform a restore operation to a point in time or from a DB Snapshot, a new DB Instance is created with a new endpoint.

**TRUE**

10.True or False: Manually created DB Snapshots are deleted after the DB Instance is deleted.

**FALSE**

11.A user is running a MySQL RDS instance. The user will not use the DB for the next 3 months. How can the user save costs?

**Create a snapshot of RDS to launch in the future and terminate the instance now**


## AWS RDS DB Maintenance & Upgrades

**Required patching is automatically scheduled only for patches that are related to security and instance reliability**

**Multi-AZ deployment for the DB instance reduces the impact of a maintenance event by following these steps:**

* Perform maintenance on the standby.
* Promote the standby to primary.
* Perform maintenance on the old primary, which becomes the new standby.

**If a maintenance event is scheduled for a given week, it will be initiated during the `30` minute maintenance window as defined**

1.A user has launched an RDS MySQL DB with the Multi AZ feature. The user has scheduled the scaling of instance storage during maintenance window. What is the correct order of events during maintenance window? 1. Perform maintenance on standby 2. Promote standby to primary 3. Perform maintenance on original primary 4. Promote original master back as primary

**1, 2, 3**

2.Can I control if and when MySQL based RDS Instance is upgraded to new supported versions?

**Yes**

3.A user has scheduled the maintenance window of an RDS DB on Monday at 3 AM. Which of the below mentioned events may force to take the DB instance offline during the maintenance window?

**Security patching**


4.A user has launched an RDS postgreSQL DB with AWS. The user did not specify the maintenance window during creation. The user has configured RDS to update the DB instance type from micro to large. If the user wants to have it during the maintenance window, what will AWS do?

**AWS will select the default maintenance window if the user has not provided it**

## AWS RDS Storage

**RDS storage uses Elastic Block Store (EBS) volumes for database and log storage.**

**RDS storage provides three storage types: Magnetic, General Purpose (SSD), and Provisioned IOPS (input/output operations per second).**

### Adding Storage and Changing Storage Type

DB instance can be modified to use additional storage and converted to a different storage type.

* **However, storage allocated for a DB instance cannot be decreased**

* During the scaling process, the DB instance will be available for reads and writes, but may experience performance degradation


### Performance Metrics

* IOPS
* Latency
* Throughput
* Queue Depth

### Factors That Impact Storage Performance

System related activities also consume I/O capacity and may r**educe database instance performance** while in progress:

* DB snapshot creation
* Nightly backups
* Multi-AZ peer creation
* Read replica creation
* Scaling storage

System resources can constrain the throughput of a DB instance, but there can be other reasons for a bottleneck. Database could be the issue if :-

* Channel throughput limit is not reached
* Queue depths are consistently low
* CPU utilization is under 80%
* Free memory available
* No swap activity
* Plenty of free disk space
* Application has dozens of threads all submitting transactions as fast as the database will take them, but there is clearly unused I/O capacity

1.When should I choose Provisioned IOPS over Standard RDS storage?

**If you use production online transaction processing (OLTP) workloads**

2.Because of the extensibility limitations of striped storage attached to Windows Server, Amazon RDS does not currently support increasing storage on a __SQL Server__ DB Instance.

3.If I want to run a database in an Amazon instance, which is the most recommended Amazon storage option?

**Amazon EBS**

## RDS Multi-AZ & Read Replica

### Multi-AZ

Mulit-AZ RDS automatically provisions and manages a **synchronous** standby replica in a different AZ

**Multi-AZ is a High Availability feature is not a scaling solution for read-only scenarios; standby replica can’t be used to serve read traffic. To service read-only traffic, use a Read Replica.**

**Failover mechanism automatically changes the DNS record of the DB instance to point to the standby DB instance.**

### Read Replica

Updates made to the source DB instance are **asynchronously** copied to the Read Replica.

I/O suspension typically lasts about one minute and can be avoided if the source DB instance is a Multi-AZ deployment (in the case of Multi-AZ deployments, DB snapshots are taken from the standby).

If the source DB instance is deleted without deleting the replicas, each replica is promoted to a stand-alone, single-AZ DB instance.

### Questions

1.A company is deploying a new two-tier web application in AWS. The company has limited staff and requires high availability, and the application requires complex queries and table joins. Which configuration provides the solution for the company’s requirements?

**Amazon RDS for MySQL with Multi-AZ**


Amazon DynamoDB (Not suitable for complex queries and joins)

2.Your company is getting ready to do a major public announcement of a social media site on AWS. The website is running on EC2 instances deployed across multiple Availability Zones with a Multi-AZ RDS MySQL Extra Large DB Instance. The site performs a high number of small reads and writes per second and relies on an eventual consistency model. After comprehensive tests you discover that there is read contention on RDS MySQL. Which are the best approaches to meet these requirements? 

* Deploy ElastiCache in-memory cache running in each availability zone

* Add an RDS MySQL read replica in each availability zone

3.Your business is building a new application that will store its entire customer database on a RDS MySQL database, and will have various applications and users that will query that data for different purposes. Large analytics jobs on the database are likely to cause other applications to not be able to get the query results they need to, before time out. Also, as your data grows, these analytics jobs will start to take more time, increasing the negative effect on the other applications. How do you solve the contention issues between these different workloads on the same data?

**Create RDS Read-Replicas for the analytics work**

4.Will my standby RDS instance be in the same Availability Zone as my primary?

**No**

5.When you run a DB Instance as a Multi-AZ deployment, the “_____” serves database writes and reads

**primary**

6.When running my DB Instance as a Multi-AZ deployment, can I use the standby for read or write operations?

**No**

7.Read Replicas require a transactional storage engine and are only supported for the ____ InnoDB_____ storage engine

8.If I have multiple Read Replicas for my master DB Instance and I promote one of them, what happens to the rest of the Read Replicas?

**The remaining Read Replicas will still replicate from the older master DB Instance**

9.When automatic failover occurs, Amazon RDS will emit a DB Instance event to inform you that automatic failover occurred. You can use the _____ to return information about events related to your DB Instance

**DescribeEvents**

10.The new DB Instance that is created when you promote a Read Replica retains the backup window period.

**TRUE**

11.Will I be alerted when automatic failover occurs?

**Only if SNS configured**

12.Can I initiate a “forced failover” for my MySQL Multi-AZ DB Instance deployment?

**yes**

13.A user is accessing RDS from an application. The user has enabled the Multi-AZ feature with the MS SQL RDS DB. During a planned outage how will AWS ensure that a switch from DB to a standby replica will not affect access to the application?

**RDS uses DNS to switch over to standby replica for seamless transition**

14.Which of these is not a reason a Multi-AZ RDS instance will failover?

**Master database corruption occurs**

15.How does Amazon RDS multi Availability Zone model work?

**A second, standby database is deployed and maintained in a different availability zone from master, using synchronous replication.**

16.You need to scale an RDS deployment. You are operating at 10% writes and 90% reads, based on your logging. How best can you scale this in a simple way?

**Create read replicas for RDS since the load is mostly reads.**

17.A customer is running an application in US-West (Northern California) region and wants to setup disaster recovery failover to the Asian Pacific (Singapore) region. The customer is interested in achieving a low Recovery Point Objective (RPO) for an Amazon RDS multi-AZ MySQL database instance. Which approach is best suited to this need?

**Asynchronous replication**

18.A user is using a small MySQL RDS DB. The user is experiencing high latency due to the Multi AZ feature. Which of the below mentioned options may not help the user in this situation?

**Take a snapshot from standby Replica**

19.Are Reserved Instances available for Multi-AZ Deployments?

**Yes for all instance types**

20.My Read Replica appears “stuck” after a Multi-AZ failover and is unable to obtain or apply updates from the source DB Instance. What do I do?

**You will need to delete the Read Replica and create a new one to replace it.**

21.What is the charge for the data transfer incurred in replicating data between your primary and standby?

**No charge. It is free.**

22.A user has enabled the Multi AZ feature with the MS SQL RDS database server. Which of the below mentioned statements will help the user understand the Multi AZ feature better?

**In a Multi AZ, AWS runs just one DB but copies the data synchronously to the standby replica**

## AWS Storage Options – RDS, DynamoDB & Database on EC2

### RDS:

* fully-managed relational database
* structured data that requires more sophisticated querying and joining capabilities 
* full compatibility with the databases supported and direct access to native database engines, code and libraries

### DynamoDB:

* don’t require advanced features such as joins and complex transactions
* **makes heavy use of files (audio files, videos, images, etc), it is a better choice to use S3 to store the object**
* DynamoDB may be a better choice on scalability
* RDS does not provide admin access and does not enable the full feature set of the database engines.

DynamoDB provides both eventually-consistent reads (by default), and strongly-consistent reads (optional)

#### Ideal Usage Patterns:

* DynamoDB is ideal for existing or new applications that need a flexible NoSQL database with low read and write latencies

* Use cases require a highly available and scalable database because downtime or performance degradation has an immediate negative impact

#### Anti-Patterns

* If the application uses structured data and required joins, complex transactions or other relationship infrastructure

* If uses large blob data for e.g. media, files, videos etc.
 
* Large Objects with Low I/O rate

#### Durability

DynamoDB has **built-in fault tolerance that automatically and synchronously replicates data across three AZ’s in a region**

### Databases on EC2

**EC2 with EBS volumes allows hosting a self managed relational database**

### Questions

1.Which of the following are use cases for Amazon DynamoDB? Choose 3 answers

* Managing web sessions
* Storing JSON documents
* Storing metadata for Amazon S3 objects

2.A client application requires operating system privileges on a relational database server. What is an appropriate configuration for highly available database architecture?


**Amazon EC2 instances in a replication configuration utilizing two different Availability Zones**

3.You are designing a file -sharing service. This service will have millions of files in it. Revenue for the service will come from fees based on how much storage a user is using. You also want to store metadata on each file, such as title, description and whether the object is public or private. How do you achieve all of these goals in a way that is economical and can scale to millions of users?

**Store all files in Amazon 53. Create Amazon DynamoDB tables for the corresponding key -value pairs on the associated metadata, when objects are uploaded.**

4.Company ABCD has recently launched an online commerce site for bicycles on AWS. They have a “Product” DynamoDB table that stores details for each bicycle, such as, manufacturer, color, price, quantity and size to display in the online store. Due to customer demand, they want to include an image for each bicycle along with the existing details. Which approach below provides the least impact to provisioned throughput on the “Product” table?

**Store the images in Amazon S3 and add an S3 URL pointer to the “Product” table item for each image**