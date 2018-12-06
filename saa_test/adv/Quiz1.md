## Operation Excellence

#### 1.Which of the following services allows an administrator access to the underlying operating system? (Choose all that apply two) 

* A. DynamoDB 
* B. **Amazon EC2**
* C. ElastiCache 
* D. Amazon RDS 
* E. **Amazon EMR** 

#### 2.You business has two EC2 instances, one is located in `us-east`, the other in `us-west`. You need to allow both machines to communicate with an application integration project you are consulting for. What solution would you recommend? 

* A. Communication between VPCs in different regions is not possible with AWS. 
* B. Ensure that each VPC has a IGW attached and each machine has a public IP address. Configure communications between those public IP addresses. 
* **C. Configure an inter-region VPC peer between the VPCs and allow communications using the private IP addresses of the instances.**
* D. Configure a Hardware VPC VPN between the VPC in us-east-1 and the VPC in us-west-1. Configure the application to communicate using the private IP addresses of the instances. 


#### 3.Which of the following EC2 metrics will NOT be automatically collected by CloudWatch? 

* **A. The number of running processes on the instance**
* B. Instance Store IOPS 
* C. T2 Credit Balance 
* D. CPU Utilization 
* **E. Average Memory Utilization** 

#### 4.You need to migrate a legacy application into AWS. It currently runs on a Linux operating system and has a requirement for iSCSI based block storage. Which AWS Service would you utilize to meet this requirement? 

* A. EFS 
* B. S3 
* **C. Storage Gateway** 
* D. EBS 

#### 5.As part of a project implementation, you need to block IP traffic from a subnet to a specific internet IP address. How can this be accomplished? 

* **A. Attach a NACL to the subnet and add a DENY rule to it.** 
* B. Create a Security group, add a DENY rule to it, and attach to the subnet. 
* C. Attach a NACL to the VPC and add a DENY rule. 
* D. Create a Security group, add a DENY rule, and attach it to any resources in the subnet which need the DENY rule applied. 


#### 6.You are designing a VPC to host a small application. The VPC will be connected back to your on-premises network using a VPN. An EC2 instance runs the application, and will only need to connect to the internet for software updates. You have a list of the software update DNS names. How can you restrict this within the AWS VPC? 

* A. Place the EC2 instance in a public subnet and add an internet gateway. 
* B. This restriction isn't possible using an AWS VPC. 
* **C. Add an internet gateway to the VPC, and a proxy service running on a EC2 instance in a public subnet with an elastic IP.** 
* D. Use the DNS filtering option on a NAT gateway to restrict internet access to just the software updates. 

**C is correct** (A proxy, managed by you, would allow the flexibility needed. The proxy would gain internet access via the internet gateway, and could be used by your application to get its updates. It would not access anything else on the internet.)

**D is incorrect** (This isn't a feature available using NAT gateways)


#### 7.You run a single instance application on an EC2 instance in AWS. Your architecture teams are looking to make changes and convert the application to operate on multiple servers. The app runs on Linux and currently accesses millions of flat file data files in the /data/... folder structure. This database is stored on an EBS volume attached to the EC2 instance. How can this be moved to work on multiple servers, with as little application changes as possible? What product would you suggest? 

* **A. EFS**
* B. Use EBS to mount the existing volume on all the new instances. 
* C. S3 
* D. EMR and HDFS 

#### 8.A solution you are working on within AWS requires the use of a hadoop cluster for big data analysis. What AWS service is an appropriate selection? 

* A. Athena 
* B. Redshift 
* C. Elasticache 
* **D. EMR**

#### 9.What steps are required to allow an EC2 instance to access the internet while being as secure as possible? Assume all security rules/ACL's and subnets are in place already. (Choose all that apply 4) 

* **A. Create a default route from the EC2 instance's subnet to the NAT Gateway.**
* **B. Add a NAT gateway** 
* **C. Attach an internet gateway to the VPC.** 
* **D. Create a default route from the NAT gateway's subnet to the Internet Gateway.** 
* E. Provide the instance with a Public or Elastic IP address. 
* F. Create a default route from the EC2 instance's subnet to the internet gateway. 


#### 10.Your business generates a large amount of financial data within its SQL-backed financial application. You have been asked to suggest an AWS product which will allow storage of that data to be used for long term reporting, querying, forecasting, and business intelligence. Which AWS product should you suggest? 

* A. Athena 
* B. Glacier 
* C. EMR 
* **D. Redshift** 


#### 11.You are consulting for a company with a limited budget for on-premises hardware. Their tape-based backup system has reached end-of-life and needs an immediate upgrade. What AWS solution could replace their tape system with minimal or no configuration changes? 

* A. S3 Buckets configured as Tape Libraries 
* **B. Storage Gateway in Tape Gateway configuration** 
* C. Glacier 
* D. S3 Buckets with Encryption and Versioning Enabled 


#### 12.You have inherited a VPC which has a CIDR of 10.0.0.0/16. You need to design a subnet layout which allows for four availability zones to be used. Which option below is valid for this criteria? Pick the one which uses the least number of subnets to decrease management overhead. 

* A. Create a single subnet, 10.0.0.0/16, which spans all four availability zones. 
* **B. Create four subnets: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24 and 10.0.3.0/24, and put each one in its own availability zone.** 
* C. Create two subnets, 10.0.0.0/24 and 10.0.1.0/24, and set each subnet in an HA configuration. Set each subnet to use two of the four availability zones. 
* D. Create four subnets, all using the 10.0.0.0/16 range, and put each subnet into its own availability zone. 

#### 13.A custom CloudWatch metric has determined that your web application is returning a high number of 404 errors. How could you automatically create a message in your online Help Desk system for your webmaster? (Choose all that apply 2) 

* A. **Set an alarm for the metric that sends a notification to an SNS topic.** 
* B. **Create an SNS topic and subscribe the Create Ticket url for your Help Desk to the topic.** 
* C. Use the Zen Desk plugin for CloudWatch 
* D. Run a report in AWS Config to find the source of the error, and send a message to an SNS topic. 
* E. Run a scan with Amazon Inspector to locate the source of the error, and send a message to an SNS topic. 


## Reliability

#### 1.Which of the following services/service features is `natively` highly available in a region, and can cope with a AZ failure without itself failing? (2)

* A. VPC Subnet 
* B. EC2 
* **C. DynamoDB**  
* **D. S3**

#### 2.You have designed a small VPC deployment for a highly-available web application. The VPC is in a Three Availability Zone region, and you have created nine subnets. Three are private (one per AZ), three are public (one per AZ), and three are database subnets (one per AZ). You have provisioned the three web servers in the public subnets, three application servers in the private subnets, and a three-node Aurora cluster. How many load balancers do you need to create, and in what subnets should they be placed, to ensure each tier is highly available? 

* **A. 2 - One placed in the public subnets, the other in the private**
* B. 3 - One placed in each tier 
* C. 9 - One placed in each subnet in each tier 
* D. 2 - One placed in the private subnet, the other placed in the DB subnet

#### 3.You have been asked to provide a recommendation on the most resilient database solution available within AWS. The business requirements are that the data is structured. They require multiple availability zones and `very low latency` between mirrors. Right now, two availability zones are required, but whatever solution is selected needs to be able to cope with three or more. Which product would you recommend? 

* A. Athena 
* B. DynamoDB 
* **C. Aurora** 
* D. RDS 


####4.You are designing an environment with four VPCs serving unique functions. Each VPC is in a four-AZ region and has four subnets, one in each AZ. You need to ensure that the public subnets in those VPCs can access the internet. What is the minimum number of internet gateways required to provide internet access to all VPCs, while being able to deal with availability zones within any of them? The business is budget conscious and wants the minimum number possible. 

* **A. 4** 
* B. 1 
* C. 16 
* D. 0 

####5.Which EC2 features can help mask the failure of an instance? (Choose all that apply 2) 

* A. AWS CloudFail 
* **B. EC2 Autorecovery**
* C. AWS Glue 
* D. NAT Gateway 
* **E. Elastic IP**

**B is correct** [On supported instance types, EC2 Autorecovery will replace an instance with an identical one,preserving IP addresses.] 

**C is incorrect** [Glue is a service for Extract, Transform, and Load of data.]

####6.Why does stopping and starting an instance usually fix a System Status Check error? 

* **A. Stopping and starting an instance causes the instance to be provisioned on different AWS hardware.** 
* B. Stopping and starting an instance causes the instance to change the AMI. 
* C. None of the these 
* D. Stopping and starting an instance reboots the operating system. 

 
####7.You are designing the implementation of a new application deployment. The application is capable of using a number of different DB engines, including MySQL, PostgreSQL and Microsoft SQL Server. The resilience of the application is critical. It needs to operate in three availability zones, and have the ability operate effectively even with the failure of two zones. Which DB platform should you select? 

* A. Pick MySQL running on an EC2 instance that is enabled for cross-az roaming. 
* B. Using the MySQL engine, ensure that Multi-AZ is enabled and that at least three AZs are selected within the HA configuration. 
* C. Pick RDS using the MySQL engine, selecting to use Multi-AZ . 
* **D. Select Aurora as the DB platform**


####8.Your businesses risk team has asked you to add additional resiliency to a critical business application. The application uses RDS and the MySQL engine and is based in `us-east-1.` The risk team would like to protect the application against an AZ failure and region issues, and wants to do it in a way which is as cost effective as possible. What two options could you suggest? 

* A. Enable Multi-AZ mode in three AZs to protect against an AZ failure within the `us-east-1` region. 
* **B. Enable Multi-AZ mode in two AZs to protect against an AZ failure within the `us-east-1` region.**
* **C. Add one or more read replicas in other regions.**
* D. Add one or more read replicas in `us-east-1`
* E. Enable `Multi-AZ` mode, but select the `cross region` option to allow synchronous replication to another global region. 


**C is correct** [This adds another layer of protection by Asynchronously replicating data to another region. This can be used for higher performance reads in that region, or (it's primary purpose in this scenario) allowing recovery if us-east-1 fails.]

**E is incorrect** Multi-AZ mode can only operate within AZs **in a single region.**


#### 9.Which of the following services or service features are `natively` highly available in a region and can cope with a AZ failure without itself failing.  (3)

* A. Software VPN (Open VPN running on EC2) 
* **B. Internet Gateway**
* **C. Dynamic Hardware VPC VPN**  
* **D. Virtual Private Gateway**


#### 10.You have a single EC2 instance, which is automatically built from a Cloud Formation template, that runs some business-critical scripts on an hourly basis. The EC2 instance currently operates in a single AZ in us-east-1 and the business has asked that you add resilience to the instance, They would like to be able to cope with one or more AZ failures, and maintain its functionality. Which option below would you present as a possible solution? 

* **A. Adjust the CloudFormation template. Add an LC and ASG, and add bootstrapping. Set the min/max/desired to 1/1/1. Optionally, add app specific health checking.** 
* B. Create a load balancer, attach the instance, and enable health checks to recover the instance if it fails. 
* C. Create an AMI of the EC2 instance, and configure CloudWatch to Auto Recovery from that AMI in another AZ. 
* D. Use the EC2 Auto Recovery feature to detect a failure, and start the instance up in another AZ. 

#### 11.Which of the following services or service features are global features, that is, they operate globally and will continue working if a region fails? 

* **A. Route 53**
* B. S3 
* C. Elastic Load Balancer 
* D. VPC 

**A is correct:** Route 53 is globally distributed, as is DNS. All elements of the service are globally resilient. Route 53 is used when you want to provide global HA in most cases. 

**B is incorrect:**
S3, while having a global namespace, isn't globally resilient. If you have an S3 bucket in a certain region and that region fails, access to that bucket will fail. 

#### 12.Which of the following services or service features are `natively highly available` in a region and can cope with a AZ failure without itself failing. 

* **A. EBS Snapshot** 
* B. EBS 
* **C. VPC** 
* D. NAT Gateway 

**C is correct**  A VPC is a highly available service. Components of it can fail if an AZ fails (subnets), but the VPC runs across a region. 

**D IS incorrect** NAT gateway is not HA. It occupies a specific subnet in an AZ. If the AZ fails it can fail.

#### 13.You need to design a VPC which is resilient to AZ failure from an internet access perspective. The VPC is in a four AZ region. How many Internet gateways are required to ensure multiple AZ failures won't disrupt internet connectivity. 

* **A. 1** 
* B. 2 
* C. 0 
* D. 4 


## Security

#### 1.You have been asked how to provide another organization with access to an S3 bucket in your company's account. Your company owns the bucket, and must own all files within it. There will be about 10,000 users from the other organization accessing the bucket. What solution matches these requirements? 

* A. Use an S3 bucket policy to provide full access to the account ID of the remote organization. 
* B. Provision each member of the remote organization with an IAM user account, and set a policy allowing them to manage their own account. 
* C. Provision a single group for the remote organisation. Generate access keys for the group, and provide this to a member of the remote organisation. 
* D. **Create an IAM role within your AWS account that has access rights to the bucket. Using a trust policy, trust the account number of the remote organizations AWS account.** 


#### 2.A medical company concerned about security compliance has asked you, a consultant, to perform an audit of their AWS environment. The company administrator provides you with the `root` login to the AWS account. After beginning the audit, you discover that the nurses who work for the company are all using a shared single login account called `nurse_user1` to upload and download daily shift change reports from S3. After further investigation, you discover that the `nurse_user1` account has full administrator privileges to EC2 and S3. When you document your findings, what security issues would you note in the report and what suggestion would you make to resolve the problem? (2)


* A. To resolve the security issues you would recommend the following: (1) create individual accounts for the nurses and put all of the nurse accounts into a group, (2) grant read/write permissions for the newly created group to the appropriate S3 bucket. 
* **B. There are three security issues: (1) you were given access to the root account, (2) the nurses are sharing an account, and (3) the nurses have full administrator privileges to EC2 and S3.** 
* C. There are two security issues: (1) the nurses are sharing an account, and (2) the nurses have full administrative privileges to EC2 and S3. 
* D. There is only one security issue. The nurses should not have full privileges to all EC2 instances and S3. 
* **E. To resolve the security issues you would recommend the following: (1) create individual accounts for the nurses and put all of the nurse accounts into a group, (2) grant read/write permissions for the newly created group to the appropriate S3 bucket, and (3) recommend as a best practice that temporary accounts be created for consultants.** 


**A is incorrect** [As a best practice, AWS recommends following the principle of least privilege. The nurses would only need read/write access to the specific S3 bucket where they upload/download their shift change reports, and users sharing accounts is not best practice. Therefore, the medical company should create a group to hold all of the newly created nurse accounts, and the read/write permissions should be assigned for the group to the S3 bucket. ]

**E is correct** [The principle of least privilege recommends that the minimal access required to complete the task be provided. Therefore, to resolve the issue, you would recommend that the company no longer allow shared accounts, especially the root account. Groups should be used to simplify management for multiple accounts, and a temporary account should be created for consultants using Security Token Service, so that the account will expire when the access is no longer required. ]


#### 3.One of the projects you have designed and implemented has a new requirement. The product uses an Amazon RDS database, and is located within a VPC isolated from your corporate network. The RDS instance is not itself accessible publicly, but certain subnets of the VPC are. You need to give members of your business IT team the ability to perform operations on the RDS instance. But not everyone in the business should have this access, just certain people. What is the `least expensive` way to accomplish this? 

* A. Provision an AWS Direct Connect link between the corporate network and AWS. Use your internal Active Directory credentials to log in to RDS using federation. 
* B. Using a VPC Virtual private gateway, create a 1:1 VPN between the RDS instance and individual user workstations, for the staff members who need to access it. 
* C. **Create an EC2 instance in the public subnet. Configure federation on this instance so that certain corporate users can log in with their AD credentials. Then install RDS DB management tools on this bastion host.**
* D. Make the RDS instance public, and allow federated sign-on using your business credentials.

**A is incorrect** **Direct connect is expensive**, and RDS is incapable of directly federating with an on-premises ID provider. 

**C is correct** This is a low cost solution which would work. 

#### 4.You just created a VPC. For security purposes you are using NACLs and Security Groups. You launched an EC2 into a subnet, where you have set an Inbound Rule for SSH (22) in the SG, and both inbound and outbound rules for Port 22 on the subnet NACL. However, you are not able to SSH to the instance. What is the most likely issue? 

* A. You need to add an outbound rule allowing SSH for the Security Group. 
* **B. The NACL needs an outbound rule for the high ephemeral port range (1024-65535).** 
* C. You have not enabled IPv6 for the VPC. 
* D. Your IAM User does not have SSH permissions. 


#### 5.A team of developers within your business has developed a mobile application, and it needs to access a DynamoDB table. The mobile application will be used by somewhere near 1,000,000 users. Which security access method would you suggest the developers use in order to minimize costs and admin overhead, while maximizing security. 

* A. Configure the DynamoDB and Twitter firehose integrations to allow connectivity between the mobile app (using Twitter IDs) and DyanmoDB. 
* B. Create an IAM user for the application. Allow the application to connect to AWS, and create an IAM user for every new user of the application. Generate access keys for that user, and use those keys to connect to DynamoDB. 
* C. Create a single IAM user, a service user for the mobile app. Hardcode the username and password into the application, and allow all instances of it to connect to DynamoDB using those credentials. 
* **D. Configure web identity federation in the mobile app. Use AWS Cognito, and set up an IAM role with permissions to connect to DynamoDB.**

#### 6.Your company has just employed ten student for one week, and it is your task to provide them with access to AWS through IAM. Your supervisor has come to you and said that he wants to be able to track these students as a group, rather than individually. Because of this, he has requested for them to all have the same login ID but completely different passwords. Which of the following is the best way to achieve this? 

* A. It isn't possible to have the same login ID for multiple IAM users of the same account. 
* B. **Use Multi Factor Authentication to verify each user, and they will all be able to use the same login.**
* C. Create various groups. and add each user with the same login ID to different groups. The user can login with their own group ID 
* D. Create a separate login ID, but give each IAM user the same alias so that each one can login with their alias. 

**A is incorrect** [It's not possible for a good reason. If you check the CloudTrail logs, you won't be able to see which user actually misconfigured a resource or deleted critical data.]

**B is correct, Only one MFA device is allowed per login ID.**


#### 7.You have been asked to advise a junior colleague how to explicitly deny traffic from an EC2 instance to a specific remote internet FQDN. What advice would you give? 

* A. Use a security group attached to the VPC and explicitly `deny` traffic to the FQDN. 
* B. Use a security group attached to the instance and explicitly `deny` traffic to the FQDN. 
* C. Implement a proxy service in the VPC, adjust route tables, and use the proxy server to deny access to the remote hostname. 
* **D. Use a NACL on the subnet that the EC2 instance is on, and `deny` traffic from the EC2 instance to the FQDN.**

**A fully qualified domain name (FQDN)**

**C is correct** This is the only valid option. AWS has no products capable of handling this type of denying traffic to a FQDN. 

**D is incorrect** An NACL is incapable of blocking traffic to a hostname, even a FQDN. 


#### 8.You are an EC2 administrator. You create an EC2 instance, and attach an EBS volume. Two weeks later, your supervisor informs you that the data on the EBS volume must be encrypted. What must you do to encrypt the existing EBS volume? 

* A. In the EC2 Dashboard, select the EBS volume, and under Actions select the Encrypt volume option. 
* B. You can enable encryption on a volume by changing the volume type to an instance store volume. Instance store volumes are automatically encrypted. 
* C. It is not possible to encrypt an existing EBS volume. You must delete the existing volume and all existing data will be lost. You will have to recreate the data on the new encrypted volume. 
* **D. It is not possible to encrypt an existing EBS volume. You can take a snapshot of the unencrypted volume. Once the snapshot is taken, copy the snapshot and enable encryption on the copy so that the target snapshot is encrypted. Once the target snapshot is created, you can attach a new encrypted volume to the EC2 instance, and restore the encrypted snapshot to a new volume.**

#### 9.Multiple directors in your company have opened AWS accounts. The Chief Security Officer has expressed a concern that accounts may be using unapproved AWS services and wants your advice. What would you recommend? 

* A. Create a new Account. Contact AWS Support and have them move all IAM Users into the new Account. 
* B. Create a Lambda function to delete the IAM users in each account. 
* C. Create a CloudTrail trail to monitor the API calls in each account. 
* **D. Create a root account as the Master in AWS Organizations, and have each account join your organization. Then apply Service Control Policies to the child accounts**


#### 10.You have an EC2 instance located in a private subnet. The instance is using an private IP Version 4 address in the 10.0.0.0/24 range and has no public IP or elastic IP attached. How can you provide this instance with access to the internet for updates.

* A. Attach an internet gateway to the VPC and update routes. 
* B. Use privatelink to access AWS provided update servers. 
* **C. Attach an internet gateway to the VPC, provision a NAT gateway, then update routes.** 
* D. Provision a NAT gateway into the VPC. 


#### 11.Your company has been thinking about moving its networking resources over to AWS. Your boss is particularly interested in the AWS shared responsibility model, as it will allow him to offload some traditional responsibilities to AWS. He says that he is happy that AWS will now handle the following responsibilities listed below. However, you know that he is wrong, and that AWS does not handle all of them as part of the shared responsibility model. Which of the following four items do you need to tell him are not handled by AWS?  (2)

* A. Datacenter Access 
* B. Storage Device Decommissioning 
* **C. Applying an SSL Certificate to an ELB** 
* D. Change Management of Host Servers 
* **E. Security groups** 


#### 12.You are about to create an AWS Lambda function, and need to give it the permissions to log in to Amazon S3. How do you best perform this (pick the best approach) 

* A. Store the credentials inside an S3 bucket and have the Lambda function retrieve them upon execution. 
* **B. Create an IAM role, assign a policy to the role, and set the Lambda function to use the role** 
* C. Create an IAM user, set the username and password in the Lambda function authentication options, and then set the method to interactive 
* D. Create an IAM user, create access keys, and enter them into your function code. 


#### 13.You are the system administrator for your company's AWS account, and it has approximately 200 IAM users. Your company has just introduced a new policy that will change the access for 50 of the IAM users to have unlimited access to S3 buckets. How can you implement this effectively so that there is no need to apply the policy at the individual user level? 

* A. Create a new role and add each user to the IAM role. 
* B. Create a policy and apply it to multiple users using a JSON script. 
* C. Create an S3 bucket policy with unlimited access which includes each user's AWS account ID. 
* **D. Create an IAM group, add the 50 users, and apply the policy to group** 


## Performance Efficiency

#### 1.Your business has a image processing application. It runs on a single x1.16xl EC2 instance. The instance is extremely expensive, and operations staff have noticed that CPU and memory usage fluctuates between around 20-30% during non busy periods and 100% at other times.

#### The application consists of two components, one allows image uploading, and one processes the images. You have been asked to rearchitect the application, aiming for reduced costs and optimized performance. What AWS products would you select?  (4)

* A. Elastic Transcoder 
* **B. Cloudwatch** 
* C. CloudTrail 
* D. EMR 
* **E. SQS** 
* **F. Launch Configuration** 
* **G. Auto Scaling Group** 

#### 2.Your development team runs a web application which provides dynamic content using query strings. They have requested a solution to provide better performance globally for the application, at the lowest running and maintenance costs. What should you suggest? 

* A. Run the application from S3 using its web hosting feature. 
* **B. Configure CloudFront to cache dynamic content with query strings. Run the EC2 instance in the most appropriate region to be accessed by the dev team.**
* C. Provision multiple EC2 instances in all regions where the application is used. 
* D. Use S3 acceleration and static hosting for the application. 

#### 3.You are in the middle designing a media processing application, which runs on a fleet of EC2 instances. You need to make a choice on the most suitable EBS disk type to utilize. The business is concerned first about meeting its performance requirements, and second about being as cost effective as possible. 

#### The business needs storage which can provide 500 MB/s. The IOPS requirements are a secondary consideration, so around 500 is fine. Which volume type is required? 

* A. SC1 
* B. IO1
* C. GP2 
* **D. ST1** 


**B is incorrect** [IO1, or provisioned throughput SSD, can provide 32,000 IOPS and 500MB/s throughput, but costs significantly more than st1.]

**D is correct** [Throughput-optimised HDDs can provide up to 500MB/s and 500 IOPS per volume. This offers the best value of all the volumes, which meet the business's requirements.]

#### 4.Your application needs to perform 100 eventually consistent reads per second from DynamoDB. Each read is 7KB is size. What is the minimum number of RCUs required to meet this demand? 

* A. 200 
* B. 350 
* C. 700 
* **D. 100**

**C is incorrect** Writes are 1KB , reads are 4KB 

**D is correct** Since eventually consistent reads are needed, then 100 RCUs is enough. Each read is 2 RCU (7KB rounded to 8KB), but eventually consistent reads are half the cost of strongly consistent ones. 

#### 5.What can help boost performance of an HPC application that relies heavily on inter-node communication? (2)

* A. Adding a secondary ENI to each instance, to increase network capacity 
* B. Enabling T2 Unlimited 
* **C. Making sure all instances are using Enhanced Networking** 
* **D. Putting all instances in a Cluster Placement Group**
* E. Enabling VPC Peering 


#### 6.You've been asked to design a solution for a high volume website, and it needs to be highly available. In your proof of concept environment, you chose to use RDS using the MySQL engine. In your failover testing, you have noticed that when a failover occurs, there is sometimes data loss. It's as though the DB instance which takes over is behind the primary instance. What options do you have to resolve this? 


* **A. Migrate to Aurora, which uses a higher performing shared storage architecture.** 
* B. Migrate from MySQL to PostgresSQL, which offers zero-latency replication between master and slave. 
* C. Use the privatelink feature to improve the latency between the Master and Slave instances. 
* D. Create additional read replicas of the database. This will extend the capacity and allow replication to occur with less lag. 

#### 7.Someone has informed you of performance problems on one of your DB instances. The normal performance demands are met by the SSD storage allocated to the instance, but at periods of heavy demand there seems to be a large variance in the time taken for DB operations. Some take significantly longer than others. 

#### Your product uses RDS and the MySQL engine. What is the best suggestion you can make without having any further information? 

* A. Reboot the DB instances 
* B. Migrate from RDS MySQL to DynamoDB. This will provide much better performance. 
* C. Move some of the read load over to the slave member of the Multi-AZ set. 
* D. Check the memory utilisation of the DB instance. If commonly accessed data is larger than the member allocated to the instance, consider increasing memory. 

**C is incorrect** The Slave of a Multi-AZ set isn't available for access, unless failover occurs.

**D is correct** If data is being accessed from memory you should expect much lower latency than if accessed from disk. The large variance or access times suggests disk is being used as well as memory. A memory upgrade would resolve this.

#### 8.You are the solutions architect for a busy photo management website. Your business receives about 200 high resolution photo uploads per minute, and you store these in an S3 bucket. The business wants to do some analysis on all uploaded photos, then store the metadata in DynamoDB. They have asked you to suggest the cheapest option that can scale as the business grows. 


* A. Use Data Pipeline to constantly scan S3, and run an EMR cluster to perform the analysis. 
* **B. Create a Lambda function that is capable of processing metadata, so that when a new object is uploaded to S3, the Lambda function will be invoked. The data from processing will then be uploaded into DynamoDB.** 
* C. Create an EC2 instance running the AWS CLI. Have it constantly poll the S3 Bucket, listing the objects in there, then locating new images and processing them all before terminating. 
* D. Create a Lambda function which is capable of processing metadata. Scheduled it to run once a minute, listing the objects in the S3 bucket, locating new images and processing them all before terminating. 

#### 9.You have implemented an application used by millions of people worldwide. As they use it, they are adding, deleting, and modifying objects on S3. These objects have a YYYYMMDD-ObjectID.dat naming format. Your users are experiencing performance issues at scale. What would you suggest to resolve the issue? 

* A. Purchase reserved capacity for S3. 
* **B. Add random data at the start of the object name.** 
* C. Increase the read and write allocation on the S3 bucket. 
* D. Add random data at the end of the object name. 


#### 10.You are in the middle designing a media processing application, which runs on a fleet of EC2 instances. You need to make a choice on the most suitable EBS disk type to utilize. The business is concerned first about meeting its performance requirements, and second about being as cost effective as possible. 

#### The business needs storage which can provide 20,000 IOPS on a single volume. Which storage type should be used? 

* A. SC1 
* B. GP2 
* C. ST1 
* **D. IO1** 


#### 11.You've been asked to upgrade an old AWS environment which is suffering from slow internet throughout. Which option below represents a potential solution?

* A. Add a virtual private gateway to the VPC. 
* B. Enable enhanced networking on the Nat instance. 
* C. Change the NAT instance from T2 large to T2 medium. 
* D. Add another internet gateway to the VPC, for a total of two, which will provide twice the current internet throughput. 
* **E. Replace the NAT instance in the VPC with a NAT Gateway.** 


#### 12.What are two ways you could reduce the execution time of a Lambda Function? 

* **A. Increase the RAM allocated to it.** 
* B. Enable sessions in your Lambda function memory to maintain state between invocations. 
* C. Run it on a larger instance. 
* D. Associate it with a VPC. 
* **E. Optimize your code.** 


#### 13.You have been asked to design some scaling upgrades on a legacy web application which utilises a MySQL RDS instance. The application is suffering from increasing reports of performance issues during peak periods. The application is used for archival information storage, where data is reviewed constantly and very rarely updated. Which option provides the best possibility of performance improvements for the least cost? 

* A. Upgrade the application server instance and the DB instance, picking a size four to eight times the size, to allow for ongoing growth. 
* B. Enable Multi-AZ. This adds a second read/write instance, and has the benefit of adding resiliency for no extra cost. 
* C. Add additional read/write nodes to the MySQL cluster, picking disks with read performance preference. 
* **D. Add RDS read replicas, and adjust the application to move a percentage of reads to the read replica.**


## Cost Optimization 

#### 1.You are designing infrastructure for an application which handles multiple petabytes per month of data transfer. It's utilized by customers globally, and you have been asked to develop a solution that provides the lowest costs and best user experience. The data consists of static large video clips. You already have datacenter infrastructure, and the business is keen to re-use that if possible. Which option would you suggest, in order to meet the requirements? 


* A. Migrate the media to an EC2 instance, store the media on an attached PIOPS EBS volume, and configure CloudFront to use that server as an origin. 
* B. Use internal servers within your datacenter and serve the content from a single location. 
* **C. Migrate the media to AWS S3, and Configure CloudFront to use that server as an origin.** 
* D. Store the media on an on-premises web server and configure CloudFront to use that server as an origin. 

#### 2.One of your systems is suffering from performance problems. It's a critical system and you have been asked to design an upgrade to resolve the issues. Checking CloudWatch, you can see that the instance is historically running at 20% CPU and 99% Memory utilization. It currently runs on the 2nd smallest C type instance. What should your suggestion be, for the most economical way to resolve the performance issues? 

A. Rebuild the application, reinstalling all components and the data into a new memory optimized instance type. 
B. Edit the EC2 instance properties and select the custom memory option. Add additional memory until the performance issues are resolved. 
**C. Power down the instance and change the instance to a memory optimised instance type**. 
D. Increase the size of the instance moving from the current C class instance to next step. 

#### 3.You have an environment which consists of ten classic load balancers, each serving HTTPS requests to two EC2 instances each. You have been asked to reduce costs while maintaining high availability. What would you suggest? 

* A. Purchase a commercial load balancer and submit a request for AWS support to install it in the AWS datacenter for your region. 
* **B. Merge the ten classic load balancers into two Application Load Balancers.**
* C. Merge the ten classic load balancers into a single classic load balancer. 
* D. Inform the business that the solution cannot be optimised from a cost perspective. 

#### 4.You are a solutions architect for a software development company. You have noticed that the business is currently running a lot of small admin scripts. They're written in Python, on a C3 instance type which is running constantly and using on-demand billing. The scripts run once per hour, each one completes in around 45 seconds, and utilize around 88MB while running. You have been asked to design a way to optimize the costs of this platform. It's worth noting that the business is about to launch a new product which would mean hundreds or thousands of these C3 instances. It's essential that these scripts run when scheduled. 

* **A. Ask the developers to migrate the scripts to AWS Lambda functions. Use timed events to schedule the invocation of these functions.**  
* B. Migrate all the scripts to run on Spot instances to reduce costs. 
* C. Combine all scripts for all clients onto a single EC2 instance, and purchase a reservation for this instance. 
* D. Purchase instance reservations to reduce the costs of the existing instance. Make a forecast for how many instances you will need, and purchase reservations in advance for future instances. 


#### 5.You have millions of objects in an S3 bucket. You are storing irreplaceable data that requires constant real-time access. Which of the following is the cheapest suitable storage class. 

* A. Amazon S3 One Zone-Infrequent Access 
* B. Amazon Glacier 
* **C. Amazon S3 Standard**
* D. Amazon S3 Standard-Infrequent Access 


#### 6.You are designing the storage needs for a movie processing application. Large videos are uploaded to your website and stored on S3. AWS Elastic Transcoder processes these master copies out into multiple formats and stores them on S3. There are over 20 size and bitrate variations for each master movie file. 90% of users of your website use only two of these size variants. Storage costs are increasing rapidly, and you have been asked to optimize the running costs. 

* A. Store the master video files on Glacier immediately, and all resized versions on S3 One Zone-IA 
* B. Store the master video files on S3 One Zone-IA and migrate them to Glacier after 12 months. Store the resized versions on S3 Standard-IA. 
* C. Store the master video files on Glacier immediately, and all resized versions on S3 Standard. 
* **D. Store the master video files on S3 Standard-IA, and migrate them to Glacier after 12 months. Store the popular resized versions on S3 Standard, and the less popular resized versions on S3 One Zone-IA.**

#### 7.Your internal development team wants to create an API and have it accessible over the internet. They have no infrastructure skills , and want to utilize whatever option has the least infrastructure requirements and maintenance needs. Which set of AWS products meets this criteria? 

* A. Opsworks, CloudFormation, and API Gateway 
* **B. API Gateway + Lambda** 
* C. API Gateway + EC2 
* D. Elastic Beanstalk + API Gateway 

#### 8.Which of the following suggestions could help reduce DynamoDB running costs? 

* A. Use SCAN rather than query operations. 
* B. Utilize indexes. 
* C. Limit the attributes read from a table. 
* D. Increase RCU 

#### 9.You launch a large cluster of instances every night, to process log files from the previous day. Depending upon the size of the logs, processing time is between 3 and 5 hours. Which EC2 pricing model will provide the lowest cost? 

A. On-Demand 
B. Convertible 
**C. Spot**
D. Scheduled Reserved 

#### 10.A client has asked you to advise them on some AWS cost related questions. The client has over 1000 EC2 instances that are preconfigured and used during peak periods of the year for their application. Those are currently in a `stopped` state now, but they are still incurring costs in that region. What's a possible reason for this? 

* A. Every EC2 instance performs automatic snapshots as a backup mechanism, The costs are for snapshots on S3. 
* **B. The instances have attached EBS volumes, and those come with monthly charges while the volumes exist.** 
* C. EC2 instances in a stopped state still have an hourly cost. Terminate the instances to resolve this. 
* D. The cost is for the VPC that the instances operate in. 


##### When you stop an EC2 instance, the instance will be shutdown and the virtual machine that was provisioned for you will be permanently taken away and you will no longer be charged for instance usage.  The key difference between stopping and terminating an instance is that the attached bootable EBS volume will not be deleted.

#### 11.You have been asked for your advice on optimizing a client's EC2 costs. The client has 20 EC2 instances which are used 24/7/365. The EC2 instances are generally the same size and are spread across multiple availability zones. The client wants to achieve the maximum possible savings and doesn't care about capacity reservations. What would you suggest? 

* A. Purchase zonal Reserved Instances. 
* **B. Purchase regional Reserved Instances.** 
* C. Purchase Convertible Reserved Instances. 
* D. Purchase Scheduled Reserved Instances. 


#### 12.Your business needs a small database for storing simple names, addresses, and ID picture information for 1000 employees. The usage will be low, queries will occur every day, and the business wants the most suitable low cost solution available within AWS. Which database would you suggest? 

* **A. DynamoDB**
* B. Elasticache 
* C. RDS Aurora 
* D. Redshift 

DynamoDB can save images less than 64kb

#### 13.Your business stores high resolution media imaging in one of its S3 buckets accessible internally to it's applications. The number of objects increase daily, and approximately 100,000 objects are added daily. After discussing the situation with your medical consultants you have learned a few things. First, images are used extensively for 7 days, after that there maybe be some images accessed extensively for up to 60 days after arrival. Beyond that point, images are only accessed for scheduled consultations. What is the most economical solution to these mounting costs? 


* A. Hire a small team of admin staff to move images to archival storage when they are no longer used. 
* B. Implement an S3 lifecycle policy to move images between storage classes, Standard, Standard_IA and Glacier. Train staff to access images via the Glacier console once archived. 
* C. Transition Images from S3 Standard to Glacier after 7 days. 
* **D. Transition images from Standard to Standard_IA after 30 days. After another 30 days, transition them from Standard_IA to Glacier. Glacier objects can be accessed from the S3 console if necessary.** 


**B is incorrect** S3 Standard objects moved to Glacier are accessed via the S3 console

**D is correct** This solution design will provide the best value to the business, while matching the requirements. Objects transitioned to Glacier from S3 classes are accessed via the S3 console
 
