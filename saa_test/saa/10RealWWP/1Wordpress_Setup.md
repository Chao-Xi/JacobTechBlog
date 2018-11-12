# Building A fault Tolerant Wordpress Site: Lab1 - Get SetUp

## Network Diagram

![Alt Image Text](images/1_1.jpg "body image")

## Create IAM Role with `AmazonS3FullAccess` policy

![Alt Image Text](images/1_2.jpg "body image")

## Create two Security Group


### web instance security group

![Alt Image Text](images/1_3.jpg "body image")

#### Add inbound rules 

![Alt Image Text](images/1_4.jpg "body image")

```
Type    Port Range   source
ssh       22         0.0.0.0/0
http      80         0.0.0.0/0
```
### RDS instance security group

![Alt Image Text](images/1_5.jpg "body image")

#### Add inbound rules 

![Alt Image Text](images/1_6.jpg "body image")

```
Type         Port Range   source
Mysql(3306)   3306        web-sg
```


## Create two S3 Buckets one for code and one for media

![Alt Image Text](images/1_7.jpg "body image")

## Create `Web CloudFront` for `media` S3 Bucket

[Introduction to S3 CDN & CloudFront](../5S3/4CDN_Cloudfront.md)

![Alt Image Text](images/1_9.jpg "body image")

### Point `cloudFront distribution` to `media S3 Bucket`

![Alt Image Text](images/1_8.jpg "body image")

![Alt Image Text](images/1_10.jpg "body image")

## Create RDS (mysql) instance

### Select MySQL Engine

### Specify DB Details

![Alt Image Text](images/1_11.jpg "body image")

### Configure Advanced Settings

```
Public Accessible: No
VPC SG: rds-sg 
```
![Alt Image Text](images/1_12.jpg "body image")


## Create Load Balancer

![Alt Image Text](images/1_13.jpg "body image")

### Put load balancer inside `Web SG`

![Alt Image Text](images/1_14.jpg "body image")

### Configure Health check

```
ping path: /health.html
unhealthy threshold:  2
health threshold:     3
```
![Alt Image Text](images/1_15.jpg "body image")


## Create Route53 and set record sets

### Enable Alias and point to ELB

![Alt Image Text](images/1_16.jpg "body image")





