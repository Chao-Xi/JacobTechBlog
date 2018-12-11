1.**Question: EFS**

A media company asked a Solutions Architect to design a nighty available storage solution to serve as a centralized document store for their Amazon EC2 instances. The storage solution needs to be POSIX-compliant **scale dynamically and be able to serve up to 100 concurrent EC2 instances.**

Which solution meets these requirements?

A. Create an Amazon S3 bucket and store all of the documents in this bucket.

B. Create an Amazon EBS volume and allow multiple users to mount that volume to their EC2 instance(s)

C. Use Amazon Glacier to store all of the documents

**D. Create an Amazon Elastic File System (Amazon EFS) to store and share the documents.**


2.**Question: [/12AddExamTip/7AD_FS.md]**

Which technique can be used to integrate AWS IAM (Identity and Access Management) with an on-premise LDAP (Lightweight Directory Access Protocol) directory service?

a.Use an IAM policy that references the LDAP account identifiers and the AWS credentials.

b.Use SAML (Security Assertion Markup Language) to enable single sign-on between AWS and LDAP

**c.Use AWS Security Token Service from an identity broker to issue short-lived AWS credentials.**

d. Use IAM roles to automatically rotate the IAM credentials when LDAP credentials are updated.

e. Use the LDAP credentials to restrict a group of users from launching specific EC2 instance types.

### C

B is a reasonable answer but as the question does not state the ldap directory has SAML capabilities, I assume that it is not capable of issuing SAML assertions which rules it out as answer.

**The short answer is NO**. To make SAML Federation work in this scenario you would need a SAML Service Broker service that works with LDAP. In this scenario, LDAP is not synonymous with Active Directory. Active Directory bundles several services into one -- including LDAP. That is why for most purposes, you can use Active Directory as an LDAP service. However for SSO/ Federation capabilities, Active Directory uses a separate service called ADFS (Active Directory Federation Services) to enable SAML Service Broker capabilities. Another LDAP server could not use ADFS, only Active Directory.


3.**AWS - designing cost-effective solution that ensures scalability**

A Solutions Architect has a multi-layer application running in Amazon VPC. **The application has an ELB Classic Load Balancer as the front end in a public subnet**, and **an Amazon EC2-based reverse proxy that performs content-based routing to two backend Amazon EC2 instances hosted in a private subnet**. The Architect sees tremendous traffic growth and is concerned that the reverse proxy and current backend setup will be insufficient. Which actions should the Architect take to achieve a cost-effective solution that ensures the application automatically scales to meet traffic demand? **(Select TWO)**

A. Replace the Amazon EC2 reverse proxy with an EL8 internal Classic Load Balancer

**B. Add Auto Scaling to the Amazon EC2 backend fleet**

C. Add Auto Scaling to the Amazon EC2 reverse proxy layer

D. Use t2 burstable instance types for the backend fleet

**E. Replace both the frontend and reverse proxy layers with an ELB Application Load Balancer**


**B. the back end web servers via an Autoscaling Group vs standalone instances is obvious.**

**E.The Application Load Balancer supports content based routing, removing the need for the EC2 reverse proxy. As an AWS managed service, `the ALB is highly available and reasonably scalable` - both handled by AWS - unlike the single EC2 proxy.**

**4.AMAZON SQS**

A large real-estate brokerage is exploring the option of adding a **cost-effective** location based alert to their existing mobile application. The application backend infrastructure currently runs on AWS. Users who opt in to this service will receive alerts on their mobile device regarding real-estate offers in proximity to their location.For the alerts to be relevant delivery time needs to be in the low minute count. The existing mobile app has **5million users across the USA**. Which one of the following architectural suggestions would you make to the customer?
A. The mobile application will submit its location to a web service endpoint utilizing Elastic Load Balancing and EC2 instances: DynamoDB will be used to store and retrieve relevant offers. EC2 instances will communicate with mobile earners/device providers to push alerts back to mobile application.

B. Use AWS DirectConnect or VPN to establish connectivity with mobile carriers. EC2 instances will receive the mobile applications ‘ location through carrier connection: RDS will be used to store and relevant offers EC2 instances will communicate with mobile carriers to push alerts back to the mobile application

**C. The mobile application will send device location using SQS. EC2 instances will retrieve the relevant offers from DynamoDB. AWS Mobile Push will be used to send offers to the mobile application**

D. The mobile application will send device location using AWS Mobile Push. EC2 instances will retrieve the relevant offers from DynamoDB. EC2 instances will communicate with mobile carriers/device providers to push alerts back to the mobile application.


A: The infrastructure was not idea. **EC2 + ELB still cannot handle 5M users**
B: **VPN is overkill and not feasible for user apps used by end users**
C: Based on the question, **SQS is nice choice for scalable and low response time. DynamoDB can handle high volume of read query.** **AWS mobile push is the right way to push back from AWS infrastructure to mobile device**
D: AWS Mobile push cannot initiated from mobile app end

**5.What happens when source/destination checks are disabled? What exactly happens during source/destination checks?**

When EC2 instances send or receive internet traffic there is a check of the network packet to ensure it is either the source or destination of that traffic. **When acting as a NAT instance it is neither the source nor the destination of the routed traffic (traffic from/to private subnet). NAT Instances merely act as a forwarding gateway for that traffic.** 

So in order to allow the forwarded traffic to pass through the Nat, the Source/Destination checks need to be disabled on NAT instance itself so that the NAT instance can serve that traffic.

6.EBS Root volumes, can be encrypted or not ?

### No

7.What must you do to create a record of who accessed your Amazon Simple Storage Service (Amazon S3) data and from where?

A. Enable Amazon CloudWatch logs.

B. Enable versioning on the bucket.

C. Enable website hosting on the bucket.

**D. Enable server access logs on the bucket.**

### 8.AWS Direct connect

You are designing the network infrastructure for an application server in Amazon VPC Users will access all the application instances from the Internet as well as from an on-premises network. **The on-premises network is connected to your VPC over an AWS Direct Connect link.** How would you design routing to meet the above requirements?

A. Configure a single routing Table with a default route via the Internet gateway Propagate a default route via BGP on the AWS Direct Connect customer router Associate the routing table with all VPC subnets.

B. Configure a single routing table with a default route via the internet gateway Propagate specific routes for the on-premises networks via BGP on the AWS Direct Connect customer router Associate the routing table with all VPC subnets.

**C. Configure a single routing table with two default routes: one to the internet via an Internet gateway the other to the on-premises network via the VPN gateway use this routing table across all subnets in your VPC.**

D. Configure two routing tables one that has a default route via the Internet gateway and another that has a default route via the VPN gateway Associate both routing tables with each VPC subnet.


#### 9. Why is S3 Reduced Redundancy storage expensive?

**Any question suggesting that RRS is the least expensive option should be corrected because it isn't, and has not been for some time.** 

I suspect that price raise was made to start incentivizing a move away from RRS, **so Amazon could start decommissioning it in favor of One Zone IA**.

#### 10. The Automated snapshots will be deleted automatically after around 4-5 hrs after user delete RDS instance. 

#### 11. Elastic Beanstalk

Elastic Beanstalk **is a way deploy web applications** and **web services** **without having to manually provision, monitor or scale the underlying infrastructure.** You can still access the instances and load-balancers but all you need to get started is your code.

#### 12. Internet gateway and Elastic IP address

You have just created a 2nd VPC and launched an EC2 instance in a subnet of that VPC. You want this instance to be publicly available, but you forgot to assign a public IP address during creation. How might you make your instance reachable from the outside world?

a.Go back and create a Public IP address. Associate it with your Internet Gateway.

**b.Create an Internet gateway and an Elastic IP address. Associate the Elastic IP with the EC2 instance.**

c.Create an Internet Gateway and associate it with the private IP address of your instance with it.

d.Create an Elastic IP address for your instance.


A. **IP addresses cannot be assigned to the Internet Gateway,** so answer A is incorrect.
C. A Private IP will not help with Internet connectivity (and cannot be "associated" with your IG anyway),
D. Answer D is incomplete: in the initial description it is said that you "just created" a new VPC, **so the assumption is that you have not yet created an IG**, hence answer B being more appropriate than D in this scenario.


