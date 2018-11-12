# NAT vs Bastions

## Exam Tips - NAT vs Bastions

####  A NAT is used to provide `internet traffic` to EC2 instances in private subnets

#### A Bastion is used to securely administer EC2 instances *using SSH or RDP) in private subnets. In Australia we call them jump boxes

## Exam Tips

1. With Bastions hosts, put them behind an autoscaling group with minimum size of 2. Use Route53 (either round robin or using a health check) to automatically fail over.
2. NAT instances are tricky to make resilient. You need **1 in each public subnet, each with their own public IP address, and you need to write a script to fail between the two**. Instead where possible, use NAT gateways.