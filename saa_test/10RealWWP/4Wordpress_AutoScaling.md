# Building A fault Tolerant Wordpress Site: Lab4 - Autoscaling & Load Testing

## Create Launch Configuration for ASG

![Alt Image Text](images/4_1.jpg "body image")

### create launch configuration and user data

```
#!/bin/bash
yum update -y
aws s3 sync --delete s3://s3code_bucket /var/www//html
```
![Alt Image Text](images/4_2.jpg "body image")

* IAM: S3role

### Assign SG to to `Launch Configuration`

![Alt Image Text](images/4_3.jpg "body image")



## Create ASG

![Alt Image Text](images/4_4.jpg "body image")

* start with 2 instances
* with all subnet

### retrieve traffic from ELB

![Alt Image Text](images/4_5.jpg "body image")

* Health Check: ELB


## Create Alarm for ASG

### Alarm one: CPU >= 60%

![Alt Image Text](images/4_6.jpg "body image")


### Alarm two: CPU <= 20%

![Alt Image Text](images/4_6.jpg "body image")

### Actions

![Alt Image Text](images/4_7.jpg "body image")


![Alt Image Text](images/4_8.jpg "body image")


## Put stress CPU on one instance 

### already `install stress` and stress CPU to 100%

```
sudo stress --cpu 100
```
![Alt Image Text](images/4_9.jpg "body image")

![Alt Image Text](images/4_10.jpg "body image")


### provisioning new instance

![Alt Image Text](images/4_11.jpg "body image")





