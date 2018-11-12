# Well Architected Framework - Pillar four Cost Optimization

## Design Principles 

* Transparently attribute expenditure 
* Use managed services to reduce cost of ownership 
* Trade capital expense for operating expense 
* Benefit from economies of scale 
* Stop spending money on data center operations 

## Definition

Cost Optimization in the cloud consists of 4 areas;
 
* **Matched supply and demand** 
* **Cost-effective resources**
* **Expenditure awareness**
* **Optimizing over time** 
 
## Best Practices - Matched supply and demand

Try to optimally align supply with demand. Don't over provision or under provision, instead as demand grows, so should your supply of compute resources. Think of things like Autoscaling which scale with demand. Similarly in a server-less context, use services such as Lambda that only execute (or respond) when a request (demand) comes in. 


### Services such as CloudWatch can also help you keep track as to what your demand is.


## Best Practices - Matched supply and demand Questions 

* How do you make sure your capacity matches but does not substantially exceed what you need?
* How are you optimizing your usage of AWS services? 

## Best Practices - Cost-Effective Resources 

Using the correct instance type can be key to cost savings. For example you might have a reporting process that is running on a t2-Micro and it takes 7 hours to complete. That same process could be run on an m4.2xlarge in a manner of minutes. 

**The result remains the same but the t2.micro is more expensive because it ran for longer.** 

**A well architected system will use the most cost efficient resources to reach the end business goal.**

## Best Practices - Cost-Effective Resources Questions 

* Have you selected the appropriate resource types to meet your cost targets?
* Have you selected the appropriate pricing model to meet your cost targets? 
* Are there managed services (higher-level services than Amazon EC2, Amazon EBS, and Amazon S3) that you can use to improve your ROI? 

## Best Practices - Expenditure Awareness 
 
 With cloud you no longer have to go out and get quotes on physical servers, choose a supplier, have those resources delivered, installed, made available etc. You can provision things within seconds, however this comes with its own issues. Many organizations have different teams, each with their own AWS accounts. Being aware of what each team is spending and where is crucial to any well architected system. 
 
### You can use cost allocation tags to track this, billing alerts as well as consolidated billing. 

## Best Practices - Expenditure Awareness Questions

* What access controls and procedures do you have in place to govern AWS costs? 
* How are you **monitoring usage and spending**? 
* How do you **decommission resources that you no longer need**, or **stop resources that are temporarily not needed**? 
* How do you consider data-transfer charges when designing your architecture? 


## Best Practices - Optimizing Over Time 

AWS moves FAST. There are hundreds of new services (and potentially 1000 new services this year). A service that you chose yesterday may not be the best service to be using today. For example consider MySQL RDS, Aurora was launched at re:invent 2014 and is now out of preview. Aurora may be a better option now for your business because of its performance and redundancy. You should keep track of the changes made to AWS and constantly re-evaulate your existing architecture. 

**You can do this by subscribing to the `AWS blog` and by using `services such as Trusted Advisor`.**

## Well-Architected Framework - Optimizing Over Time

How do you manage and/or consider the adoption of new services? 

## Key AWS Services

### Matched supply and demand 

**Autoscaling**

### Cost-effective resources

**EC2 (reserved instances), AWS Trusted Advisor** 

### Expenditure awareness

**CloudWatch Alarms, SNS**

### Optimizing over time

**AWS Blog, AWS Trusted Advisor**



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