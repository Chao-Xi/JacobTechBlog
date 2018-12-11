#### 1.EC2 instances types:

HVM and PV

#### 2.Natively encrypts data at rest with AES-256

**Storage Gateway and Glacier**

3.You can only specify one launch configuration for an Auto Scaling group at a time, and **you can't modify a launch configuration after you've created it**. Therefore, **if you want to change the launch configuration for your Auto Scaling group, you must create a launch configuration and then update your Auto Scaling group with the new launch configuration.** 

**When you change the launch configuration for your Auto Scaling group, any new instances are launched using the new configuration parameters, but existing instances are not affected.**"

#### 4.Bucket policy and Bucket ACL

**Bucket policy: Action, Resources, Condition**

**Bucket ACL**
 
*  List object ,   write object , read bucket,   write bucket  
*  aws account , other aws account,  public access , S3 log delivery group


**Object ACL**    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  **No Object Policy**

#### 5. admin access: EC2 EMR BeanStalk Opswork


#### 6.RRS

* Low cost: 1.glacier 2.one zone IA 3.S3-IA
* Best Availability: 1.S3 2.S3-IA 3.OZ-IA 4.Glacier
* Long Retention: 1.Glacier
* Best Retrial time: 1.S3 2.S3-IA 3.OZ-IA 4.**Glacier [3-5 hours]**

**One-Zone IA, designed for 99.50% availability, and data will lost in AZ destruction**

#### 7.realtime e-commerce analysis: EMR

**Kinesis is for aggregating and temporarily storing high volume data.**

EMR is for running app like Hadoop and spark, for analyzing Big data.

**Big data analysis:**

1. **Amazon Athena**: Query Service with **SQL** on the data stored in **S3** which without worrying data formatting
2. **Amazon EMR**: 'sophisticated data processing' **Hadoop, Spark**
3. **Amazon Redshift**: Data warehouse, **complex SQL with multiple join**, need transfer **multiple data resource** into a common format

**Data ETL Service:**

1. **Glue**: ETL Service on a **serverless** Apache Spak env. Move data by to glue **category** by **crawler**.
2. **data pipeline**: launch **EC2** and transfer data to EMR and Redshift
3. **Kinesis**: **Standard SQL** on incoming data and specify destination


#### 8. Recored on who access S3: 

Enable server access log on the bucket

#### 9.Forget create public ip? 

assign the Elastic IP to the instance, and this instance will publicly open

#### 10.Route 53 failover Active-Active: all  Active-passive: primary and second

1. Route 53 geolocation: **compliance and regulatory purpose**
2. Latency Based: performance purpose

#### 11.cloudwatch logs 

enable by installing a `cloud-agent on ec2 instance`

#### 12.Amazon Athena 

Query Service with Standard Sql analyze data in S3, with serverless infrastructure

#### 13.cross-account access: 

**permission policy. Trust policy**


#### 14.EBS Volume: root volume and data volume

only data volume can be created/attached/detached on the fly

#### 15. Purging cached data in cloudfront 

Use Invalidation tab

#### 16. EndpointS: S3 AND DynamoDB using private ip cannot cross-region

#### 17. Information you gathered whether S3 is right choice

The size of individual object => multi-part upload

#### 18. EBS VS. Snapshot VS. AMI

* **EBS Volume are bound to one AZ**
* **snapshot of ebs in S3, SO it's regional**
* AMI are just registered snapshots

#### 19. EC2 cloudwatch default metrics

CPU utilization, Disk read/write, Network In/Out

**YOU CAN CUSTOM memory utilization**

#### 20. Redshift: is fast, scalable data warehouse to analyze data warehouse and data lake or premise data

AWS CLUE: ELT service, organize, load and move data

it's serverless, automatically generate data ETL script, and store in data warehous

#### 21.NACL need ab outbound rule for the high ephermal port range (1024-65535)

#### 22 IOPS

| GP2 | IO1 | SC1 | ST1|
|:------------- |:---------------:| -------------:| -------------:|
| 16000 | 64000 |   250|   500 |

#### 23.S3 performance

* **Upload**: multipart upload
* **Download**: add random prefix to the key names
* **Enhanced network**

#### 24.AWS VPN components

* Virtual Private Gateway &nbsp;&nbsp;  =>  &nbsp;&nbsp; two endponints
* Customer Gateway

#### 25.VPC FLOW logs is storing using Amazon Cloudwatch Logs

#### 26 Nat security

public subnet don't have to add route to nat Instance. Nat instance already set in public subnet

**Edit 'default route table' , and add 'NAT instance' to it. Destination: 0.0.0.0/0, target: nat instance to ensure private subnet connect with internet**

#### 27.AWS two components connect external networks: IGW AND VGW

#### 28.sg and NACL

1. **one instance can be assigned with multiple sgs, up to 5**
2. **default and new sg start with `no inbound` and `all outboud`**
3. **default NANCL `ALLOW all inbound and outbound `**
4. **newly created NACL `DENY ALL inbound and outbound`**
5. **one subnet <=> one NACL**


#### 29.EC2 troubleshooting with connection timeout

* **CPU load on the instance is too high**
* **User key not recognized by server**

#### 30.ENI attach

running <=> hot &nbsp;&nbsp;&nbsp;&nbsp;stopped<=>warm &nbsp;&nbsp;&nbsp;&nbsp;launched<=>cold

#### 31. RDS cloudwatch metrics

```
data transfer /  data storage / i/o request
```

#### 32. RDS backup

1. automated backup and snapshots only support **innoDB** AND store in **S3**
2. **manually created snapshot will `keep` after instance is deleted**


#### 33.RDS mutli-AZ vs Read Replica

1. Maintenance: primary->sandby->maintenance-> sandby &nbsp; &nbsp;  sandby-> primary
2. **mutli-AZ -> syncheonize**
3. **read-replica -> asynchronousely**


#### 34.dynamodb usecase

web sessions     &nbsp; &nbsp;      json document   &nbsp; &nbsp;  metadata data for s3

#### 35. ELB AND ASG

1. ELB Send traffic if instance is health, no traffic if unhealthy
2. user can add instance to elb on fly which can realize asg->elb
3. scaleout: pending-> pending wait -> pending processed -> in service
4. scalein: terminating -> terminating wait -> terminating wait processed -> terminated 
5. inservice -> standby -> pending -> inservce

#### 36.absorb attack

asg&elb &nbsp; &nbsp; ec2 vertical scaling &nbsp; &nbsp; enhanced network &nbsp; &nbsp; cloudfront &nbsp; &nbsp; route 53

#### 37.SWF VS SQS

SQS -> 14 days &nbsp; &nbsp; SWF -> 1 YEAR

#### 38. Storage Options: S3 VS. EFS 

1. **S3**: **Object** storage
2. **EFS**: **can be used as shared drive by mul instances**. & **cannot used as root volume**
3. **EBS**: **Can used as root volume**

#### 39.AWS resource explorer

**System manager**

#### 40. When EC2 is stopped, the only action you can do:

**Change security group and create AMI**

#### 41.Optimizing ASG

1. Modify the asg cool-down time.
2. Modify the Amazon Cloudwatch alarm period that triggers your asg scale down policy

#### 42. Beanstalk USE:

1. Web application using RDS
2. A long running work process






















