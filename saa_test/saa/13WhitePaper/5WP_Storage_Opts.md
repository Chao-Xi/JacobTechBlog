# Storage Options in the Cloud White Paper

## Summary

![Alt Image Text](images/5_1.jpg "body image")


## Each Section Contains 

* Summary 
* deal Usage Patterns 
* Performance 
* Durability and Availability 
* Cost Model 
* Scalability & Elasticity 
* Interfaces 
* Anti-Patterns 


## Import / Export

### AWS Import/Export accelerates moving large amounts of data into and out of AWS using portable storage devices for transport. 

### AWS transfers your data directly onto and off of storage devices using Amazon's high-speed internal network and bypassing the Internet. 

For significant datasets, AWS Import/Export is often faster than Internet transfer and more cost effective than upgrading your connectivity. 


## Import/Export Price Model 

### With AWS Import/Export, you pay only for what you use. AWS Import/Export has three pricing components: 

* A per-device fee, 
* A data load time charge (per data-loading-hour), 
* Possible return shipping charges (for expedited shipping, or shipping to destinations not local to that AWS Import/Export region). 

## Storage Gateway

#### AWS Storage Gateway is a service that connects an on-premises software appliance with cloud-based storage to provide seamless and secure integration between an organization's on-premises IT environment and AWS's storage infrastructure. 

The service enables you to securely store data to the AWS cloud for scalable and cost-effective storage. 

**AWS Storage Gateway's software appliance is available for download as a virtual machine (VM) image that you install on a host in your datacenter.**

Once you've installed your gateway and associated it with your AWS account through our activation process, you can use the AWS Management Console to create either `gateway-cached` or `gateway-stored` volumes that can be mounted as iSCSI devices by your on-premises
applications.


## Storage Gateway - gateway-cached

`Gateway-cached` volumes allow you to utilize `Amazon S3` for your primary data, **while retaining some portion of it locally in a cache for frequently accessed data**. 

These volumes minimize the need to scale your on-premises storage infrastructure, while still providing your application with low-latency access to their frequently accessed data. You can create storage volumes up to `32 TBs` in size and mount them as iSCSI devices from your on-premises application servers. 

#### Data written to these volumes is stored in Amazon S3, with only a cache of recently written and recently read data stored locally on your on-premises storage hardware. 


## Storage Gateway - gateway-stored

**Gateway-stored volumes store your primary data locally,** while `asynchronously backing up` that data to AWS. 

These volumes provide your on-premises applications with low-latency access to their entire datasets, while providing durable, off-site backups. **You can create storage volumes up to 1 TB in size and mount them as iSCSI devices from your on-premises application servers.** 

#### Data written to your gateway-stored volumes is stored on your on-premises storage hardware, and asynchronously backed up to Amazon S3 in the form of Amazon EBS snapshots. 


## Storage Gateway pricing

### With AWS Storage Gateway, you pay only for what you use. AWS Storage Gateway has four pricing components: 

* gateway usage (per gateway per month), 
* snapshot storage usage (per GB per month), 
* volume storage usage (per GB per month), 
* data transfer out (per GB per month). 



