# Well Architected Framework - Pillar three Performance Efficiency

## The Performance Efficiency Pillar 

The Performance Efficiency pillar focuses on how to `use computing resources efficiently to meet your requirements` and how to `maintain that efficiency as demand changes and technology evolves`. 

## Design Principles

* Democratize advanced technologies 
* Go global in minutes 
* Use server-less architectures 


## Definition 

Performance Efficiency in the cloud consists of 4 areas; 

* **Compute** 
* **Storage** 
* **Database** 
* **Space-time trade-off** 


## Best Practices - Compute

When architecting your system it is important to choose the right kind of server. **Some applications require heavy CPU utilization, some require heavy memory utilization etc**. 

With AWS servers are virtualized and at the click of a button (or API call) you can change the type of server in which your environment is running on. **You can even switch to running with no servers at all and use AWS Lambda.** 



## Best Practices - Compute Questions 

* How do you select the appropriate instance type for your system? 
 
* How do you ensure that you continue to have the most appropriate instance type as new instance types and features are introduced?
 
* How do you monitor your instances post launch to ensure they are performing as expected?
 
* How do you ensure that the quantity of your instances matches demand? 


## Best Practices - Storage

The optimal storage solutions for your environment depends on a number of factors.

For example;

* **Access Method** - Block, File or Object 
* **Patterns of Access** - Random or Sequential 
* **Throughput Required** 
* **Frequency of Access** - Online, Offline or Archival 
* **Frequency of Update** - Worm, Dynamic 
* **Availability Constraints** 
* **Durability Constraints** 

## Best Practices - Storage 

At AWS the storage is virtualized. 

* With S3 you can have 11 x 9's durability, Cross Region Replication etc. 

* With EBS you can choose between different storage mediums (such as SSD, Magnetic, PIOPS etc). 

* You can also easily move volumes between the different types of storage 
mediums. 


## Best Practices - Storage Questions 

* How do you select the appropriate storage solution for your system? 
* How do you ensure that you continue to have the most appropriate storage solution as new storage solutions and features are launched?  
* How do you monitor your storage solution to ensure it is performing as expected? 
* How do you ensure that the capacity and throughput of your storage solutions matches demand?

## Best Practices - Database  

The optimal database solution depends on a number of factors. **Do you need database consistency, do you need high availability, do you need No-SQL, do you need DR etc?** 

With AWS you get a LOT of options. **RDS, DynamoDB, Redshift** etc. 

## Best Practices - Database Question

* How do you select the appropriate database solution for your system? 
* How do you ensure that you continue to have the most appropriate database solution and features as new database solution and features are launched?
* How do you monitor your databases to ensure performance is as expected?
* How do you ensure the capacity and throughput of your databases matches demand? 


## Best Practices - Space-Time trade-off 

* Using AWS you can use services such as **RDS to add read replicas**, **reducing the load on your database** and **creating multiple copies of the database. This helps to lower latency**.

* You can use **Direct Connect** to provide predictable latency between your HQ and AWS. 
 
* You can use the global infrastructure to have multiple copies of your environment, in regions that is closest to your customer base. 
 
* You can also use caching services such as `ElastiCache` or `CloudFront` to reduce latency 

## Best Practices - Space-Time trade-off Question

* How do you select the appropriate proximity and caching solutions for your system? 
* How do you ensure that you continue to have the most appropriate proximity and caching solutions as new solutions are launched? 
* How do you monitor your proximity and caching solutions to ensure performance is as expected? 
* How do you ensure that the proximity and caching solutions you have matches demand? 


## Key AWS Services 

### Compute 

Autoscaling 

### Storage 

EBS, S3, Glacier 

### Database 

RDS, DynamoDB, Redshift 

### Space-Time Trade-Off 

CloudFront, ElastiCache, Direct Connect, RDS Read Replicas etc 


## Exam Tips

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