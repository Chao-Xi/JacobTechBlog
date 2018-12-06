## AWS Trusted Advisor 

* Cost Optimization
* Security
* Fault Tolerance
* Performance
* Service Limits

1.The Trusted Advisor service provides insight regarding which five categories of an AWS account?

**Performance, cost optimization, security, and fault tolerance**

## AWS Storage Gateway

**AWS Storage Gateway, by default, `uploads data using SSL` and provides `data encryption` at rest when stored in S3 or Glacier using AES-256**

### Types

#### 1.Gateway-cached volumes

* Data is stored in S3 and acts as a Primary data storage
* Gateway retains a copy of recently read data locally for low latency access to the frequently accessed data
* Each gateway configured for gateway-cached volumes can support up to 32 volumes, with each volume ranging from 1GiB to 32TiB, for a total maximum storage volume of 1,024 TiB (1 PiB).
* Gateway-cached volumes can be attached as iSCSI devices from on-premises application servers

#### 2.Gateway-stored volumes

* Gateway-stored volumes maintain the entire data set locally to provide low latency access
* Gateway asynchronously backs up point-in-time snapshots (in the form of EBS snapshots) of the data to S3 which provides durable off-site backups

#### Gateway–virtual tape library (VTL)

* Virtual tape library
* Virtual tape shelf


### Questions

1.Which of the following services natively encrypts data at rest within an AWS region?Choose 2 answers

* AWS Storage Gateway
* Amazon Glacier

2.What does the AWS Storage Gateway provide?

**It allows to integrate on-premises IT environments with Cloud Storage**

3.A customer has a single 3-TB volume on-premises that is used to hold a large repository of images and print layout files. This repository is growing at 500 GB a year and must be presented as a single logical volume. The customer is becoming increasingly **constrained with their local storage capacity** and wants an off-site backup of this data, while maintaining low-latency access to their frequently accessed data. Which AWS Storage Gateway configuration meets the customer requirements?

**Gateway-Cached volumes with snapshots scheduled to Amazon S3**

4.A customer implemented AWS Storage Gateway with a gateway-cached volume at their main office. An event takes the link between the main and branch office offline. Which methods will enable the branch office to access their data? Choose 3 answers
Use

* Launch a new AWS Storage Gateway instance AMI in Amazon EC2, and restore from a gateway snapshot
* Create an Amazon EBS volume from a gateway snapshot, and mount it to an Amazon EC2 instance.
* Launch an AWS Storage Gateway virtual iSCSI device at the branch office, and restore from a gateway snapshot


## AWS Direct Connect 

AWS Direct Connect helps to create virtual interfaces directly to the AWS cloud for e.g, to EC2 & S3 and to Virtual Private Cloud (VPC), **bypassing Internet service providers in the network path.**

### Direct Connect Advantages

* Reduced Bandwidth Costs
* Consistent Network Performance
* AWS Services Compatibility
* Private Connectivity to AWS VPC
* Elastic

**VPN connections are very cheap compare to Direct Connect**

1.You are building a solution for a customer to extend their on-premises data center to AWS. The customer requires a 50-Mbps **dedicated and private connection** to their VPC. Which AWS product or feature satisfies this requirement?

**AWS Direct Connect**

2.Is there any way to own a direct connection to Amazon Web Services?

**Yes, it’s called Direct Connect**

3.An organization has established an Internet-based VPN connection between their on-premises data center and AWS. They are considering migrating from VPN to AWS Direct Connect. Which operational concern should drive an organization to consider switching from an Internet-based VPN connection to AWS Direct Connect?

**AWS Direct Connect provides greater bandwidth than an Internet-based VPN connection.**

4.Does AWS Direct Connect allow you access to all Availabilities Zones within a Region?

**Yes**

5.A customer has established an AWS Direct Connect connection to AWS. The link is up and routes are being advertised from the customer’s end, however the customer is unable to connect from EC2 instances inside its VPC to servers residing in its datacenter. Which of the following options provide a viable solution to remedy this situation? (Choose 2 answers)

* Enable route propagation to the Virtual Private Gateway (VGW)
* Modify the Instances VPC subnet route table by adding a route back to the customer’s on-premises environment.

6.A company has configured and peered two VPCs: VPC-1 and VPC-2. VPC-1 contains only private subnets, and VPC-2 contains only public subnets. The company uses a single AWS Direct Connect connection and private virtual interface to connect their on-premises network with VPC-1. Which two methods increase the fault tolerance of the connection to VPC-1? Choose 2 answers

* Establish a hardware VPN over the internet between VPC-1 and the on-premises network
* Establish a new AWS Direct Connect connection and private virtual interface in the same AWS region as VPC-1

7.Your company previously configured a heavily used, dynamically routed VPN connection between your on premises data center and AWS. You recently provisioned a Direct Connect connection and would like to start using the new connection. After configuring Direct Connect settings in the AWS Console, which of the following options will provide the most seamless transition for your users?

**Update your VPC route tables to point to the Direct Connect connection configure your Direct Connect router with the appropriate settings verify network traffic is leveraging Direct Connect and then delete the VPN connection.**


8.You are implementing AWS Direct Connect. You intend to use AWS public service end points such as Amazon S3, across the AWS Direct Connect link. You want other Internet traffic to use your existing link to an Internet Service Provider. What is the correct way to configure AWS Direct Connect for access to services such as Amazon S3?

**Create a public interface on your AWS Direct Connect link. Redistribute BGP routes into your existing routing infrastructure advertise specific routes for your network to AWS**

9.You are tasked with moving a legacy application from a virtual machine running inside your datacenter to an Amazon VPC. Unfortunately this app requires access to a number of on-premises services and no one who configured the app still works for your company. Even worse there’s no documentation for it. What will allow the application running inside the VPC to reach back and access its internal dependencies without being reconfigured? (Choose 3 answers)

* An AWS Direct Connect link between the VPC and the network housing the internal services
* An IP address space that does not conflict with the one on-premises 
* A VM Import of the current virtual machine 

## AWS Consolidated Billing Overview

Consolidated billing enables consolidating payments from multiple **AWS accounts (Linked Accounts)** within the organization to a **single account by designating it to be the Payer Account.**

#### Payer account is billed for all charges of the linked accounts.
#### Each linked account is still an independent account in every other way
#### Payer account cannot access data belonging to the linked account owners

### Questions

1.An organization is planning to create 5 different AWS accounts considering various security requirements. The organization wants to use a single payee account by using the consolidated billing option. Which of the below mentioned statements is true with respect to the above information?

**Master (Payee) account can view only the AWS billing details of the linked accounts**

2.An organization has setup consolidated billing with 3 different AWS accounts. Which of the below mentioned advantages will organization receive in terms of the AWS pricing?

**All AWS accounts will be charged for S3 storage by combining the total storage of each account**

3.An organization has added 3 of his AWS accounts to consolidated billing. One of the AWS accounts has purchased a Reserved Instance (RI) of a small instance size in the us-east-1a zone. All other AWS accounts are running instances of a small size in the same zone. What will happen in this case for the RI pricing?

**Any single instance from all the three accounts can get the benefit of AWS RI pricing if they are running in the same zone and are of the same size**

4.An organization is planning to use AWS for 5 different departments. The finance department is responsible to pay for all the accounts. However, they want the cost separation for each account to map with the right cost centre. How can the finance department achieve this?

**Create 5 separate accounts and make them a part of one consolidated billing**

5.An AWS account wants to be part of the consolidated billing of his organization’s payee account. How can the owner of that account achieve this?

**The payee account will send a request to the linked account to be a part of consolidated billing**

6.You are looking to migrate your Development (Dev) and Test environments to AWS. You have decided to use separate AWS accounts to host each environment. You plan to link each accounts bill to a Master AWS account using Consolidated Billing. To make sure you keep within budget you would like to implement a way for administrators in the Master account **to have access to stop, delete and/or terminate resources in both the Dev and Test accounts. Identify which option will allow you to achieve this goal**.


**Create IAM users in the Master account. Create cross-account roles in the Dev and Test accounts that have full Admin permissions and grant the Master account access.**

7.When using consolidated billing there are two account types. What are they?

**Paying account and Linked account**

8.An organization has 10 departments. The organization wants to track the AWS usage of each department. Which of the below mentioned options meets the requirement?

**Create separate accounts for each department, but use consolidated billing for payment and tracking**

9.A customer needs corporate IT governance and cost oversight of all AWS resources consumed by its divisions. The divisions want to maintain administrative control of the discrete AWS resources they consume and keep those resources separate from the resources of other divisions. Which of the following options, when used together will support the autonomy/control of divisions while enabling corporate IT to maintain governance and cost oversight? Choose 2 answers

* Enable IAM cross-account access for all corporate IT administrators in each child account

* Use AWS Consolidated Billing to link the divisions’ accounts to a parent corporate account