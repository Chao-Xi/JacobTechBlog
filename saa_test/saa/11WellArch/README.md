# Well-Architected Framework

## Courses List

1. [Well Architected Framework](1FrameWork.md)
2. [Well Architected Framework - Pillar One Security](2FrameWork-Security.md)
3. [Well Architected Framework - Pillar Two Reliability](3FrameWork-Reliability.md)
4. [Well Architected Framework - Pillar Three Performance Efficiency](4FrameWork-PerformanceEff.md)
5. [Well Architected Framework - Pillar Four Cost Optimization](5FrameWork-CostOpt.md)


## Exam Tips

### 4 Pillars of the Well 

* Security 
* Reliability 
* Performance Efficiency 
* Cost Optimization 

### Structure of each pillar 

* Design Principles 
* Definition 
* Best Practices 
* Key AWS Services 



## Security in the cloud consists of 4 areas;  

* **Data protection** 
* **Privilege management** 
* **Infrastructure protection**
* **Detective controls**

## Exam Tips - Security Pillar -Questions

### Data Protection Questions 

* How are you encrypting and protecting your data at rest? 
* How are you encrypting and protecting your data in transit? (SSL) 

### Privilege Management Questions 

#### How are you protecting access to and use of the AWS root account credentials? 

```
Enable Multi-Factor Authentication(MFA) in your account
```

#### How are you defining roles and responsibilities of system users to control human access to the AWS Management Console and APIs?

```
SET GROUPS
group: system admin
group: tools
Exp: Separate groups for HR to access s3 bucket other than system admin
```

#### How are you limiting automated access (such as from applications, scripts, or third-party tools or services) to AWS resources? 

```
IAM roles
```

#### How are you managing keys and credentials? 

```
AWS Key Management Service (KMS)
```

### Infrastructure Protection Questions 

#### How are you enforcing network and host-level boundary protection? 

```
VPC / sg / ACL / public subnet / private subnet / bastion host
```

#### How are you enforcing AWS service level protection?

```
IAM
user account, group for users, password protection, password rotation policy
```

#### How are you protecting the integrity of the operating systems on your Amazon EC2 instances? 

```
Anti-virus installed?
```

### Detective Control Questions 

#### How are you capturing and analyzing AWS logs? 

```
log trails turns on  other logs management system
```

## Exam Tips: Reliability Pillar


### Reliability in the cloud consists of 3 areas; 

* **Foundations** 
* **Change management** 
* **Failure management** 

### Reliability Pillar Questions

#### Foundations

* How are you managing AWS service limits for your account?

```
someone on is in change of its
someone raise tickets for change control process
```

* How are you planning your network topology on AWS? 
* Do you have an escalation path to deal with technical issues? 

#### Change Management

* How does your system adapt to changes in demand? 
* How are you monitoring AWS resources? 
* How are you executing change management? 

#### Failure Management

* How are you backing up your data? 
* How does your system withstand component failures? 
* How are you planning for recovery?

## Exam Tips - Performance Efficiency

Performance Efficiency in the cloud consists of 4 areas; 

* **Compute** 
* **Storage** 
* **Database** 
* **Space-time trade-off** 

### Best Practices - Compute Questions 

* How do you select the appropriate instance type for your system? 
* How do you ensure that you continue to have the most appropriate instance type as new instance types and features are introduced? 
* How do you monitor your instances post launch to ensure they are performing as expected?
* How do you ensure that the quantity of your instances matches demand? 


### Best Practices - Storage Questions 

* How do you select the appropriate storage solution for your system? 
* How do you ensure that you continue to have the most appropriate storage solution as new storage solutions and features are launched?  
* How do you monitor your storage solution to ensure it is performing as expected? 
* How do you ensure that the capacity and throughput of your storage solutions matches demand?


### Best Practices - Database Question

* How do you select the appropriate database solution for your system? 
* How do you ensure that you continue to have the most appropriate database solution and features as new database solution and features are launched?
* How do you monitor your databases to ensure performance is as expected?
* How do you ensure the capacity and throughput of your databases matches demand? 

### Best Practices - Space-Time trade-off Question

* How do you select the appropriate proximity and caching solutions for your system? 
* How do you ensure that you continue to have the most appropriate proximity and caching solutions as new solutions are launched? 
* How do you monitor your proximity and caching solutions to ensure performance is as expected? 
* How do you ensure that the proximity and caching solutions you have matches demand? 


## Exam Tips: Cost Optimization Pillar

Cost Optimization in the cloud consists of 4 areas;
 
* **Matched supply and demand** 
* **Cost-effective resources**
* **Expenditure awareness**
* **Optimizing over time** 


### Best Practices - Matched supply and demand Questions 

* How do you make sure your capacity matches but does not substantially exceed what you need?
* How are you optimizing your usage of AWS services? 


### Best Practices - Cost-Effective Resources Questions 

* Have you selected the **appropriate resource** types to meet your cost targets?
* Have you selected the **appropriate pricing** model to meet your cost targets? 
* Are there managed services (higher-level services than Amazon EC2, Amazon EBS, and Amazon S3) that you can use to improve your ROI? 


### Best Practices - Expenditure Awareness Questions

* What access controls and procedures do you have in place to govern AWS costs? 
* How are you **monitoring usage and spending**? 
* How do you **decommission resources that you no longer need**, or **stop resources that are temporarily not needed**? 
* How do you consider data-transfer charges when designing your architecture? 

### Well-Architected Framework - Optimizing Over Time

* How do you manage and/or consider the adoption of new services?