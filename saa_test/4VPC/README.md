# AWS VPC

## Courses

1. [The Overview of AWS VPC](1Overview.md)
2. [Hands on creating VPC](2Hands_on_VPC.md)
3. [Nat instances and Nat Gateway](3Hands_on_NAT.md)
4. [Network Access Control List vs Security Group](4Network_ACL.md)
5. [Custom VPC's and ELBs](5ELB_Tip.md)
6. [NAT vs Bastions](6Nat_Bastion.md)
7. [VPC Flow Log](7VPC_flowlog.md)


## Basic Exam Tips

*  Think of a VPC as logical data center in AWS
*  Consists of IGW's (Or virtual Private Gateways), Route Tables, Networks access Control Lists, Subnets, Security Groups
*  1 Subnet = 1 Availability Zone

One AZ can have many subnets,  so this means that the equation is,

```
1 Subnet => 1 Availability Zone (not <=>)
```

* **Can peer VPCs both in the same account and with other accounts, which means peer VPCs within separate account**
* NO TRANSITIVE PEERING
* **Inter-region VPC peering**


## Hands on creating VPC

1. create two subnets [one for public and one for private]
2. create internet gateway and attach to VPC
3. create route table, and add igw to route table, associate **pub subnet** to the route table
4. create EC2 inside public subnet
5. create EC2 inside private subnet with new SG (ssh, mysql, icmp(ping)) 


## NAT Instances

1. When Creating a **NAT instance**, **Disable** `Source/Destination` Check on the instance in **Networking**
2. NAT instance must be in a `public subnet`
3. There must be a route out of the private subnet to the NAT instance, in order for this to work
4. The amount if traffic that NAT instances supports, depends on the instance size. If you are bottlenecking, increase the instance size.
5. You can create **high availability using Autoscaling Groups**, **multiple subnets in different AZ's and a script to automate failover**
6. Behind a Security Group


## NAT Gateway in public subnet

1. Preferred by enterprise
2. **Scale automatically up to 10Gbps**
3. No need to patch
4. **Not associated with security groups**
5. Automatically assigned a public groups
6. Remember to update your route tables
7. No need to disable Source/Destination Checks


## Network ACL'S

1. Your VPC automatically comes a default network ACL and by default it allows all outbound and inbound traffic
2. You can create a custom network ACL. By default, each custom network ACL denies all inbound and outbound traffic until you add rules
3. Each subnet in your VPC must be associated with a network ACL. If you don't explicitly associate a subnet with a network ACL, the subnet is automatically associated with the default network ACL.
4. You can associate a network ACL with multiple subnets; however, a subnet can be associated with only one network ACL at a time. When you associate network ACL with a subnet, the previous association is removed
5. A network ACL contains a numbered list of rules that is evaluated in order, staring with the lowest numbered rule.
6. A network ACL has separate inbound and outbound rules, and each rule can either allow or deny traffic
7. Network ACLs are stateless; responses to allowed inbound traffic are subject to the rules for outbound traffic (and vice versa)
8. Block IP address using network ACL's not security group
9. If you wanna deny(allow) special ip address, put it before(smaller in rule) `0.0.0.0/0` allow(deny)

Security Group  | Network ACL
------------- | -------------
Operates at the instance level  | Operates at the subnet level
Supports allow rules only       | Supports allow rules and deny rules
Is stateful: Return traffic is automatically allowed, regardless of any rules  | Is stateless: Return traffic must be explicitly allowed by rules
We evaluate all rules before deciding whether to allow traffic  | We process rules in number order when deciding whether to allow traffic
Applies to an instance only if someone specifies the security group when launching the instance, or associates the security group with the instance later on  | Automatically applies to all instances in the subnets it's associated with (therefore, you don't have to rely on users to specify the security group)


## Resilient Architecture (ELB)

1. If you want **resiliency**, always have **2 public subnets and 2 private subnets**. Make sure **each subnet is in different availability zones.**
2. With ELB's make sure **they are in 2 public subnets in 2 different availability zones**
3. With Bastions hosts, put them behind an autoscaling group with minimum size of 2. Use Route53 (either round robin or using a health check) to automatically fail over.
4. NAT instances are tricky to make resilient. You need **1 in each public subnet, each with their own public IP address, and you need to write a script to fail between the two**. Instead where possible, use NAT gateways.


## NAT vs Bastions

1. With Bastions hosts, put them **behind an autoscaling group with minimum size of 2**. Use Route53 (either round robin or using a health check) to automatically fail over.
2. NAT instances are tricky to make resilient. **You need 1 in each public subnet**, each with **their own public IP address**, and you need to write a script to fail between the two. **Instead where possible, use NAT gateways**.

## VPC Flow Logs

* You can monitor network traffic within your custom VPC's using VPC Flow Logs


## Choosing Between an ELB and an ALB on AWS

* Application Load Balancer (ALB), a new load balancer allowing developers to direct and configure user traffic to apps in the public AWS cloud.
* The **Application Load Balancer** will process the request. **Not only by receiving port, but also by looking at the destination URL.**
* Multiple services can share a single load balancer using **path-based routing.** 
* The Application Load Balancer **also integrates with EC2 Container Service (ECS) using Service Load Balancing.**
* **Rules** determine what action is taken when a rule matches a client request. Up to 10 URL-based rules can be defined in the ALB.
* The **target group** is used to route requests to registered targets as part of an action for a rule. Target groups specify a protocol and target port. Health checks can be configured per target group. **An ALB can route to multiple target groups.**
* The **condition** is the path pattern you want the ALB to evaluate in order for it to route requests.
* **Priority** tells the ALB in which order to evaluate the rules. Rules are numerically evaluated in order from lowest to highest value.





