# Launch our first EC2 instance

## Check `free tier only` to use free EC2 AMI

![Alt Image Text](images/2_1.jpg "body image")

### AMI Types:

1. HVM: Hardware Virtual Machine (HVM).
2. PV:  Paravirtual (PV)


## Request Spot Instance

![Alt Image Text](images/2_2.jpg "body image") 

## Tag Instance

![Alt Image Text](images/2_3.jpg "body image") 


## Add Storage

### 1. IOPS = SIZE * 3   (3 * 8G = 24)
### 2. Root storage => setting for operating system is not encrypted by default


## Create New Security Group

### Security Group is like a virtual fire wall

![Alt Image Text](images/2_4.jpg "body image") 

Like `SSH`, `HTTP`

## Create New Key Pair for New EC2

![Alt Image Text](images/2_5.jpg "body image") 


## New EC2 Created with Public IP

![Alt Image Text](images/2_6.jpg "body image") 


### SSH to EC2 Instance with key

```
$ chmod 600 MyEC2Key.pem
$ ssh ec2-user@public-ip -i MyEC2Key.pem
```

![Alt Image Text](images/2_7.jpg "body image") 


## How to terminate an Instance with `Termination Protection Open`

![Alt Image Text](images/2_8.jpg "body image") 

### Disable it firstly

![Alt Image Text](images/2_9.jpg "body image") 


## Exam Tips

1. Termination Protection is turned off by default, you must turn it on
2. On an EBS-backed instance, the default action is for the root EBS volume to be deleted when instance is terminated
3. **Root Volumes cannot be encrypted by default, you need a third party tool (such as bit locker etc) to encrypt the root volume**
4. **Additional volumes can be encrypted.**


