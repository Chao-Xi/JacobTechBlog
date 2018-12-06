## SQS

### Amazon SQS is a highly available `distributed queue system`

#### SQS Standard Queue Features & Key Points

**makes a best effort to preserve order in messages does not guarantee first in, first out delivery of messages**


### Questions

1.Which AWS service can help design architecture to persist in-flight transactions?

**SQS**

2.A company has a workflow that sends video files from their on-premise system to AWS for transcoding. They use EC2 worker instances that pull transcoding jobs from SQS. Why is SQS an appropriate service for this scenario?


**SQS helps to facilitate horizontal scaling of encoding tasks**

3.Which statement best describes an Amazon SQS use case?

**Create a video transcoding website where multiple components need to communicate with each other, but can’t all process the same amount of work simultaneously**

4.Your company plans to host a large donation website on Amazon Web Services (AWS). You anticipate a large and undetermined amount of traffic that will create many database writes. To be certain that you do not drop any writes to a database hosted on AWS. Which service should you use?

**Amazon Simple Queue Service (SQS) for capturing the writes and draining the queue to write to the database**


5.A user has created a queue named “awsmodule” with SQS. One of the consumers of queue is down for 3 days and then becomes available. Will that component receive message from queue?

**Yes, since SQS by default stores message for 4 days**

6.A user has developed an application, which is required to send the data to a NoSQL database. The user wants to **decouple the data** sending such that the application keeps processing and sending data but does not wait for an acknowledgement of DB. Which of the below mentioned applications helps in this scenario?

**AWS Simple Queue Service**

7.A user has created a photo editing software and hosted it on EC2. The software accepts requests from the user about the photo format and resolution and sends a message to S3 to enhance the picture accordingly. Which of the below mentioned AWS services will help make a scalable software with the AWS infrastructure in this scenario?

**AWS Simple Queue Service**

8.How does Amazon SQS allow multiple readers to access the same message queue without losing messages or processing them many times?

**Amazon SQS queue has a configurable visibility timeout**

9.If a message is retrieved from a queue in Amazon SQS, how long is the message inaccessible to other users by default?

**30 seconds**

10.Which of the following statements about SQS is true?

**Messages will be delivered one or more times and message delivery order is indeterminate**

##SWF

### Questions

1.For which of the following use cases are Simple Workflow Service (SWF) and Amazon EC2 an appropriate solution? Choose 2 answers

* Managing a multi-step and multi-decision checkout process of an e-commerce website
* Orchestrating the execution of distributed and auditable business processes

2.Amazon SWF is designed to help users…

**Coordinate synchronous and asynchronous tasks which are distributed and fault tolerant.**

3.What does a “Domain” refer to in Amazon SWF?

**A collection of related Workflows**

4.Which of the following statements about SWF are true? Choose 3 answers.

* **SWF tasks are assigned once and never duplicated**
* **SWF workflow executions can last up to a year**
* **SWF uses deciders and workers to complete tasks**

### SNS

#### **SNS Supported Transport Protocols**

* HTTP, HTTPS
* Email, Email-JSON
* SQS
* SMS

#### SNS Supported Endpoints

* Email Notifications
* Mobile Push Notifications
* SQS Queues
* SMS Notifications
* HTTP/HTTPS Endpoints
* Lambda


#### Questions

1.Which of the following notification endpoints or clients does Amazon Simple Notification Service support? Choose 2 answers

* Email
* Short Message Service

2.What happens when you create a topic on Amazon SNS?

**An ARN (Amazon Resource Name) is created**

3.A user has deployed an application on his private cloud. The user is using his own monitoring tool. He wants to configure that whenever there is an error, the monitoring tool should notify him via SMS. Which of the below mentioned AWS services will help in this scenario?

**AWS SNS**

4.A user wants to make so that whenever the CPU utilization of the AWS EC2 instance is above 90%, the redlight of his bedroom turns on. Which of the below mentioned AWS services is helpful for this purpose?

**AWS CloudWatch + AWS SNS**

5.Which of the following are valid SNS delivery transports? Choose 2 

* HTTP
* SMS

6.What is the format of structured notification messages sent by Amazon SNS?

**An JSON object containing MessageId, unsubscribeURL, Subject, Message and other values**

7.which of the following are valid arguments for an SNS Publish request? 

* TopicAm
* Subject
* Message