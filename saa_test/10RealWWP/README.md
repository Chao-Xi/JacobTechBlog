# Real World Wordpress setup on AWS 

1. [Building A fault Tolerant Wordpress Site: Lab1 - Get SetUp](1Wordpress_Setup.md)
2. [Building A fault Tolerant Wordpress Site: Lab2 - Setting Up EC2](2Wordpress_EC2Setup.md)
3. [Building A fault Tolerant Wordpress Site: Lab3 - Automation & Setting up our AMI](3Wordpress_CDN_AMI.md)
4. [Building A fault Tolerant Wordpress Site: Lab4 - Autoscaling & Load Testing](4Wordpress_AutoScaling.md)
5. [Building A fault Tolerant Wordpress Site: Lab5 - CloudFormation](5Wordpress_CloudFormation.md)


## Whole Procedure

### SetUp generally

1.Create `IAM Role` with `AmazonS3FullAccess` policy

2.Create **web instance security group** with inbound:

```
Type    Port Range   source
ssh       22         0.0.0.0/0
http      80         0.0.0.0/0
```

3.Create **RDS instance security group** with inbound:

```
Type         Port Range   source
Mysql(3306)   3306        web-sg
```

4.Create **two S3 Buckets** one for code and one for media

5.Create **Web CloudFront** for **media S3 Bucket**

6.Point **cloudFront distribution** to **media S3 Bucket**

7.Create **RDS (mysql) instance** with **MySQL Engine**

```
Public Accessible: No
VPC SG: rds-sg 
```
8.Create **Load Balancer** in **SG Web SG**

9.Create **Route53 and set record sets** and point to ELB

### Setting Up EC2

1.Create EC2 instance with **IAM role `s3role`**

2.Configure instance inside **Web-SG**

3.Add web Instance to ELB

4.Add `RDS Endpoint` to `Worldpress Database host`


### Setting Up Automation

1.**Redirect Wordpress image read** from `CloudFront` rather than `EC2 instance`

2.check **cloudfront distributions** `domain name`

3.add `domain name` to `/var/www/html/.htaccess` and and copy to **rewriterule**

4.in `/etc/crontab`, add **Cronjob** **automatically upload images and code to S3 bucket** and **download code to EC2 instance from S3**

5.Create AMI Image for web instance

### Autoscaling & Load Testing

1.Create **Launch Configuration** for ASG

2.Assign SG to to **Launch Configuration** and **retrieve traffic from ELB**

### CloudFormation
