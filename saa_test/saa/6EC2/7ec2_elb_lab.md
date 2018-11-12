# Elastic Load Balancer - LAB

## Define Load Balancer

![Alt Image Text](images/7_1.jpg "body image")

### Create `internal load balancer` whether it's internet facing or not

## Assign Security Group

![Alt Image Text](images/7_2.jpg "body image")

## Configure Health check

![Alt Image Text](images/7_3.jpg "body image")

### Unhealthy Threshold:

**The number of consecutive failed health checks that must occur before declaring an EC2 instance unhealthy.**

### Healthy Threshold

**The number of consecutive successful health checks that must occur before declaring an EC2 instance healthy.**

If the health checks exceed **UnhealthyThresholdCount** consecutive **failures**, the load balancer takes the instance out of service. When the health checks exceed **HealthyThresholdCount** consecutive **successes**, the load balancer puts the instance back in service.

## Add Instance to ELB


![Alt Image Text](images/7_4.jpg "body image")

#### Enable Connection Draining 

In AWS, when you enable `Connection Draining` on a load balancer, **any back-end instances that you deregister will complete requests** that are in progress before deregistration


## Instance `In Service` 

![Alt Image Text](images/7_5.jpg "body image")


## ELB only has DNS, No ip address

![Alt Image Text](images/7_6.jpg "body image")


## Exam Tips

#### In service or Out of Service
#### Health Check
#### Have their own DNS name. You are never given an IP address

