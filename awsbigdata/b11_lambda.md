# AWS Lambda

### Objective

* Describe AWS Lamdba 
* Define the Benefits and Features of AWS Lambda 

### Let's consider a scenario: 

If you have to write down the code for the images uploaded in one of the S3 buckets to convert them into the thumbnails and save them in another S3 bucket: 

* Create a trigger in S3 
* The images have to sent to some server where you will deploy your code which will convert those images into thumbnails 
* Once again connect with S3 and put it in to another S3 bucket 

A server / an IDE where you will write your code, deployables of that code, etc. should be set up. 

* AWS Lambda lets you run code without any provisioning or managing servers. 
* Pay only for the compute time you consume; there is no charge when your code is not running. 


### AWS Lambda： Benefits

* No Servers to manage 
* Continuous scaling 
* Sub second metering 

### AWS Lambda： Triggers

**Events trigger Lambda function. **

Following are the events that trigger AWS Lambda function: 
 
 * DynamoDB 
 * AWS S3 
 * AWS Kinesis 
 * AWS CloudWatch 


### AWS Lambda: Additional Benefits

**AWS Lambda is a compute service with which you need not worry about**: 

* Servers 
* Under/over capacity 
* Scaling and fault tolerance 
* OS or Language updates
* Metrics and logging 

**With Lambda you can easily**: 

* Bring your own code including native libraries 
* Run code parallely 
* Create backends, event handlers 
* Pay for what you use 


### Integration with Big Data Services

After you upload your code to AWS Lambda, you can associate your function with specific AWS resources such as: 

* Amazon S3 bucket 
* Amazon DynamoDB 
* Amazon Kinesis stream 
* Amazon SNS notification

 
When the resource changes, Lambda will execute your function and manage the compute resources as needed in order to keep up with incoming requests. 

#### Languages support

* Node.js
* Python, Java
* C#
* Go

### AWS Lambda: Features

* Build custom back-end services 
* Extend other AWS services with custom logic 
* Built-in Fault Tolerance 
* Completely Automated Administration 
* Automatic Scaling 
* Bring Your Own Code 
* Integrated Security Model
* Pay Per Use 
* Flexible Resource Model 


#### Build custom back-end services

For the applications that are triggered by Lambda APIs, those can be used to create backend services. 

#### Extend other AWS services with custom logic

One can customize AWS services using Lambda's ability to add more custom logics. 

#### Built-in Fault Tolerance

AWS Lambda maintains compute capacity across multiple Availability Zones in each region to help protect your code against individual machine or data center facility failures. 

#### Completely Automated Administration 

No infra management headaches, no worries about OS and software upgrades. 

#### Automatic Scaling 

When needed, invokes your code and take care of scalability

#### Bring Your Own Code 

One can bring in one's own code without bothering to learn complex frameworks

#### Integrated Security Model

Allows your code to securely access other AWS services through its built-in AWS SDK and integration with IAM. 

#### Pay Per Use 

Pay per use model removes teh burden of upfront infra cost

#### Flexible Resource Model 

You can decide on how much memory your program requires. AWS Lambda allocates proportional CPU power, network bandwidth, and disk I/O. 



