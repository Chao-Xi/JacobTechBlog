# Whitepaper

## Security

###  AWS Security Responsibilities

* AWS is responsible for protecting the global infrastructure
* AWS provide several reports from third-party auditors 
* AWS is responsible for the security configuration of its products that are considered managed services
* **For Managed Services**, AWS will handle basic **security tasks** like guest **operating system (OS)** and **database patching**, **firewall configuration,** and **disaster recovery.**

### Customer Security Responsibilities

* EC2, VPC, S3 are completely under your control and require you to perform all of the necessary security configuration
* Management of the guest OS (including updates and security patches), any application software or utilities installed on the instance
* For most of these managed services, all you have to do is configure logical access controls for the resources and protect the account credentials


### Networking Monitoring & Protection

* DDOS
* Man in the Middle attacks
* IP spoofing 
* Port Scanning

### Questions

1.In the shared security model, AWS is responsible for which of the following security best practices (check all that apply) :

* Penetration testing
* Threat modeling
* Static code analysis 

#### Not:

* Operating system account security management
* Static code analysis 

2.You are running a web-application on AWS consisting of the following components an Elastic Load Balancer (ELB) an Auto-Scaling Group of EC2 instances running Linux/PHP/Apache, and Relational DataBase Service (RDS) MySQL. Which security measures fall into AWS’s responsibility?

**Protect against IP spoofing or packet sniffing**

3.In AWS, which security aspects are the customer’s responsibility? Choose 4 answers

#### User responsibility:

* Patch management on the EC2 instances operating system
* Encryption of EBS (Elastic Block Storage) volumes
* Life-cycle management of IAM credentials
* Security Group and ACL (Access Control List) settings

#### AWS responsibility

* Controlling physical access to compute resources
* Decommissioning storage devices

4.Per the AWS Acceptable Use Policy, penetration testing of EC2 instances:

**May be performed by the customer on their own instances with prior authorization from AWS.**

5.Which is an operational process performed by AWS for data security?

**Decommissioning of storage devices using industry-standard practices**


## AWS Storage Options

1.You are developing a highly available web application using **stateless web servers**. Which services are suitable for storing session state data? Choose 3 answers.


* Amazon Relational Database Service (RDS)
* Amazon ElastiCache
* Amazon DynamoDB


2.A company is building a voting system for a popular TV show, viewers would watch the performances then visit the show’s website to vote for their favorite performer. It is expected that in a short period of time after the show has finished the site will receive millions of visitors. The visitors will first login to the site using their Amazon.com credentials and then submit their vote. After the voting is completed the page will display the vote totals. The company needs to build the site such that can handle the rapid influx of traffic while maintaining good performance but also wants to keep costs to a minimum. Which of the design patterns below should they use

**Use CloudFront and an Elastic Load Balancer in front of an auto-scaled set of web servers, the web servers will first call the Login. With Amazon service to authenticate the user, the web servers would process the users vote and store the result into an SQS queue using IAM Roles for EC2 Instances to gain permissions to the SQS queue. A set of application servers will then retrieve the items from the queue and store the result into a DynamoDB table**

3.For the alerts to be relevant delivery time needs to be in the low minute count. The existing mobile app has 5 million users across the US. Which one of the following architectural suggestions would you make to the customer?

**Mobile application will send device location using SQS. EC2 instances will retrieve the relevant offers from DynamoDB. AWS Mobile Push will be used to send offers to the mobile application**

4.How would you improve page load times for your users? 

* Add an Amazon ElastiCache caching layer to your application for storing sessions and frequent DB queries
* Configure Amazon CloudFront dynamic content support to enable caching of re-usable content from your site
* Switch Amazon RDS database to the high memory extra-large Instance type

5.A read only news reporting site with a combined web and application tier and a database tier that receives large and unpredictable traffic demands must be able to respond to these traffic fluctuations automatically. What AWS services should be used meet these requirements?

**Stateless instances for the web and application tier synchronized using ElastiCache Memcached in an autoscaling group monitored with CloudWatch. And RDS with read replicas.**


6.The site performs a **high number of small reads** and writes per second and relies on an eventual consistency model. After comprehensive tests you discover that there is **read contention** on RDS MySQL. Which are the best approaches to meet these requirements? 

* **Deploy ElasticCache in-memory cache running in each availability zone**

* **Add an RDS MySQL read replica in each availability zone**

7.Run 2-tier app with the following: an ELB, three web app server on EC2, and 1 MySQL RDS db. With grown load, db queries take longer and longer and slow down the overall response time for user request. What Options could speed up performance? (Choose 3)


* Create an RDS read-replica and redirect half of the database read request to it

* Cache database queries in amazon ElastiCache
 
* **Shard the database and distribute loads between shards.**

7.A document storage company is deploying their application to AWS and changing their business model to support both free tier and premium tier users. The premium tier users will be allowed to store up to 200GB of data and free tier customers will be allowed to store only 5GB. The customer expects that billions of files will be stored. All users need to be alerted when approaching 75 percent quota utilization and again at 90 percent quota use. To support the free tier and premium tier users, how should they architect their application?

**The company should utilize an amazon simple work flow service (SWF) activity worker that updates the users data counter in amazon dynamo DB. The activity worker will use simple email service to send an email if the counter increases above the appropriate thresholds.**

## AWS DDoS Resiliency 

### Be Ready to Scale to Absorb the Attack


* Auto Scaling & ELB
* EC2 Instance => vertical scaling 
* Enhanced Networking
* Amazon CloudFront
* Route 53

### Questions

1.You are designing a social media site and are considering how to mitigate distributed denial-of-service (DDoS) attacks. Which of the below are viable mitigation techniques? (Choose 3 answers)

* Use an **Amazon CloudFront** distribution for both static and dynamic content.
* Use an **Elastic Load Balancer** with auto scaling groups at the web app and Amazon Relational Database Service (RDS) tiers
* **Add alert Amazon CloudWatch** to look for high Network in and CPU utilization.


