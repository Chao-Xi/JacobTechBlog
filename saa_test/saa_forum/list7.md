### 1.Difference between EBS, Snapshot and AMIs

* **EBS volumes are bound to one AZ**, but can be attached to any EC2 instance in that AZ (but only one instance at a time).
* **Snapshots of EBS volumes are stored in S3**, and are **therefore regional in scope.** They can be used when creating new EBS volumes in any AZ in that region, and can be **copied to other regions.**
* **AMIs are just specially registered snapshots**, and so can also be copied to other regions.

### 2.Questions

1.At the subnet level you have blocked all OB traffic and in instance level also done the same , can the instance be accessed from the internet ?

A. Not possible

B. Need to attach an Elastic IP address

C. Yes , all inbound allowed , so any ip can access

**D. Need to add NAT instance**

2.which of the following can elastic load balancing can do ?

**A. Distribute traffic across AZ**

B. Distribute traffic across regions

**C. Route only check the health of instance**

D. Route request to instances with least number of connections

3.routing table to connect a VPC to the internet

A. 0.0.0.0 >NAT

**B. 0.0.0.0 > internet gateway**

C. 10.0.0.10/16

4.How can a software running can get the ip of an instance ?

**A. Through its metadata**

B. Using another tool

C. Using the Ping command

D. Can not get IP address

5.You have a m1.small instance with 300GB EBS . How will you increase the throughput ?

A. increase bandwidth

B. RAID

C. Auto scaling

**D. None of the above**

6.How to migrate an EBS from one AZ to another ?

A. AWS Import/Export

B. Elastic load balance

**C. Take a snapshot (if the option is not there .. go for ) create an AMI**

D. Not possible

7.If you start an instance through API and do not specify an instance type . Which type is allocated to you ?

A. m1.small instance

B. t1.micro instance

**C. the smallest instance available for your AMI**

D. m1.medium

8.What are the measures to be taken to ensure maximum availability ?

A. Clustering

B. System backup

**C. Autoscaling in different AZs**

D. Daily backup


### 3.When you create a custom VPC, which of the following are created automatically?

When you create a custom VPC, which of the following are created automatically?

### 4.You cannot mount an EBS to an instance in a different AZ


