# ELB Network Load Balancer

Network Load Balancer operates at the connection level (Layer 4), routing connections to targets – **EC2 instances, containers and IP addresses** based on IP protocol data.

## Features

* High Availability
* High Throughput
* Low Latency
* Preserve source IP address
* Static IP support
* Elastic IP support
* Health Checks

### DNS Fail-over

* integrates with Route 53
* Route 53 will direct traffic to load balancer nodes **in other AZs**, if there are no healthy targets with NLB or if the NLB itself is unhealthy
* if NLB is unresponsive, Route 53 will remove the unavailable load balancer IP address from service and direct traffic to an alternate Network Load Balancer in another region.


## Integration with AWS Services

Robust Monitoring and Auditing
Central API Support
Enhanced Logging
Zonal Isolation
Load Balancing using IP addresses as Targets

### Attaching/Detaching ELB with Auto Scaling Group

Auto Scaling integrates with Elastic Load Balancing and enables to **attach one or more load balancers to an existing Auto Scaling group**

**ELB registers the EC2 instance using its IP address and routes requests to the primary IP address of the primary interface (eth0) of the instance.**

If connection draining is enabled, ELB waits for in-flight requests to complete before deregistering the instances.

### High Availability & Redundancy

Auto Scaling can span across multiple AZs, within the same region

**spanning Auto Scaling groups across multiple AZs within a region and then setting up ELB to distribute incoming traffic across those AZs.**

### Questions

1.A company is building a two-tier web application to serve dynamic transaction-based content. The data tier is leveraging an Online Transactional Processing (OLTP) database. What services should you leverage to enable an elastic and scalable web tier?

**Elastic Load Balancing, Amazon EC2, and Auto Scaling**

2.You have been given a scope to deploy some AWS infrastructure for a large organization. The requirements are that you will have a lot of EC2 instances but may need to add more when the average utilization of your Amazon EC2 fleet is high and conversely remove them when CPU utilization is low. Which AWS services would be best to use to accomplish this?

**Auto Scaling, Amazon CloudWatch and Elastic Load Balancing**

3.A user has configured ELB with Auto Scaling. **The user suspended the Auto Scaling AddToLoadBalancer**, which adds instances to the load balancer. process for a while. What will happen to the instances launched during the suspension period?

**The instances will not be registered with ELB and the user has to manually register when the process is resumed**

4.You have an Auto Scaling group associated with an Elastic Load Balancer (ELB). You have noticed that instances launched via the Auto Scaling group are being marked unhealthy due to an ELB health check, but these unhealthy instances are not being terminated. What do you need to do to ensure trial instances marked unhealthy by the ELB will be terminated and replaced?

**Add an Elastic Load Balancing health check to your Auto Scaling group**

5.What is the order of most-to-least rapidly-scaling (fastest to scale first)? A) EC2 + ELB + Auto Scaling B) Lambda C) RDS

**B, A, C (Lambda is designed to scale instantly. EC2 + ELB + Auto Scaling require single-digit minutes to scale out. RDS will take at least 15 minutes, and will apply OS patches or any other updates when applied.)**


## AWS ELB Monitoring


### Elastic Load Balancer access logs

**Elastic Load Balancing provides access logs that capture detailed information about all requests sent to your load balancer.**


### Questions

1.A customer needs to capture all client connection information from their load balancer every five minutes. The company wants to use this data for analyzing traffic patterns and troubleshooting their applications. Which of the following options meets the customer requirements?

**Enable access logs on the load balancer.**

2.Your supervisor has requested a way to analyze traffic patterns for your application. You need to capture all connection information from your load balancer every 10 minutes. Pick a solution from below. Choose the correct answer:

**Enable access logs on the load balancer**


## AWS Elastic Load Balancer – ELB

Elastic Load Balancing allows the incoming traffic to be distributed automatically across multiple healthy EC2 instances.

**Load Balancers only work across AZs within a region**


### Health Checks

* InService
* OutOfService


### Connection Draining

* By default, if an registered EC2 instance with the ELB is deregistered or becomes unhealthy, the load balancer immediately closes the connection

* Connection draining can help the load balancer to complete the in-flight requests made while keeping the existing connections open, and preventing any new requests being sent to the instances that are de-registering or unhealthy.


### Questions

1.A user has configured an HTTPS listener on an ELB. The user has not configured any security policy which can help to negotiate SSL between the client and ELB. What will ELB do in this scenario?

**By default ELB will select the latest version of the policy**

2.A user has configured ELB with SSL using a security policy for secure negotiation between the client and load balancer. Which of the below mentioned security policies is supported by ELB?

**Predefined Security Policy**

3.A user has configured ELB with SSL using a security policy for secure negotiation between the client and load balancer. Which of the below mentioned SSL protocols is not supported by the security policy?

**TLS 1.3**

4.A user has configured ELB with a TCP listener at ELB as well as on the back-end instances. The user wants to enable a proxy protocol to capture the source and destination IP information in the header. Which of the below mentioned statements helps the user understand a proxy protocol with TCP configuration?

**If the end user is requesting behind a proxy server then the user should not enable a proxy protocol on ELB**


5.A user has enabled session stickiness with ELB. The user does not want ELB to manage the cookie; instead he wants the application to manage the cookie. What will happen when the server instance, which is bound to a cookie, crashes?

**The session will not be sticky until a new cookie is inserted**

6.A user has created an ELB with Auto Scaling. Which of the below mentioned offerings from ELB helps the user to stop sending new requests traffic from the load balancer to the EC2 instance when the instance is being deregistered while continuing in-flight requests?

**ELB connection draining**

7.When using an Elastic Load Balancer to serve traffic to web servers, which one of the following is true?

**ELB and EC2 instances must be in the same VPC**

8.A user has created an ELB with the availability zone us-east-1. The user wants to add more zones to ELB to achieve High Availability. How can the user add more zones to the existing ELB?

**The user can add zones on the fly from the AWS console**

9.A user has launched an ELB which has 5 instances registered with it. The user deletes the ELB by mistake. What will happen to the instances?

**Instances will keep running**

10.A user has setup connection draining with ELB to allow in-flight requests to continue while the instance is being deregistered through Auto Scaling. If the user has not specified the draining time, how long will ELB allow inflight requests traffic to continue?

**300 seconds**

11.A user has created an ELB with three instances. How many security groups will ELB create by default?

**2 (One for ELB to allow inbound and Outbound to listener and health check port of instances and One for the Instances to allow inbound from ELB)**

12.Your web application front end consists of multiple EC2 instances behind an Elastic Load Balancer. You configured ELB to perform health checks on these EC2 instances, if an instance fails to pass health checks, which statement will be true?

**The ELB stops sending traffic to the instance that failed its health check**

13.You are designing an SSL/TLS solution that requires HTTPS clients to be authenticated by the Web server using client certificate authentication. The solution must be resilient. Which of the following options would you consider for configuring the web server infrastructure?

* Configure ELB with TCP listeners on TCP/443. And place the Web servers behind it. (terminate SSL on the instance using client-side certificate)
* Configure your Web servers with EIPs. Place the Web servers in a Route53 Record Set and configure health checks against all Web servers. 


14.A user has configured ELB with two instances running in separate AZs of the same region? Which of the below mentioned statements is true?

**Multi AZ instances will provide HA with ELB (ELB provides HA to route traffic to healthy instances only it does not provide scalability)**

15.An ELB is diverting traffic across 5 instances. One of the instances was unhealthy only for 20 minutes. What will happen after 20 minutes when the instance becomes healthy?

**ELB starts sending traffic to the instance once it is healthy**

16.A user has configured a website and launched it using the Apache web server on port 80. The user is using ELB with the EC2 instances for Load Balancing. What should the user do to ensure that the EC2 instances accept requests only from ELB?

**Configure the security group of EC2, which allows access to the ELB source security group**


17.AWS Elastic Load Balancer supports SSL termination.

**For all regions**

18.User has launched five instances with ELB. How can the user add the sixth EC2 instance to ELB?

**The user can add the sixth instance on the fly.**

