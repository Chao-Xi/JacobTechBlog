# AWS Web Services

## Courses List

1. [SQS (Amazon Simple Queue Service)](1SQS.md)
2. [Simple Workflow Service](2SWF.md)
3. [Simple Notification Service](3SNS.md)
4. [Elastic Transcoder](4ElasticTranscoder.md)

## SQS Exam Tips

#### `Amazon SQS` is a `web service` that gives you access to a `message queue` that can be used to store messages while waiting for a computer to process them. 

Amazon SQS is a **distributed queue system** that enables web service applications to quickly and reliably queue messages that **one component in the application generates to be consumed by another component**.

#### A queue is a `temporary repository` for messages that are awaiting processing.

* **Does not offer FIFO** (first in, first out)

* 12 hours visibility time out
 
* Amazon SQS is engineered to provide "at least once" delivery of all messages in its queues. Although most of the time each message will be delivered to your application exactly once, you should design your system so that processing a message more than once does not create any errors or inconsistencies. 

* `$0.50` per 1 million `Amazon SQS Requests` per month thereafter ($0.00000050 per SQS Request)

* A single request can have from 1 to 10 messages, up to a maximum total payload of 256KB.

* **Each 64KB 'chunk' of payload is billed as 1 request.** For example, a single API call with a 256KB payload will be billed as **four** requests.


 

## Simple Workflow Service

Amazon Simple Workflow Service (Amazon SWF) is a web service that makes it easy to coordinate work across distributed application components.

## SWF vs SQS (Exam Tips)

* **SQS** has a retention period of **14 days**, **SWF** up to **1 year for workflow executions**.(exam tip)
* Amazon **SWF presents a task-oriented API**, whereas **Amazon SQS offers a message-oriented API**.
* **Amazon SWF ensures that a task is assigned only once and is never duplicated.** With **Amazon SQS, you need to handle duplicated message** and may also need to ensure that a message is processed only once.
* Amazon SWF **keeps track of all the tasks and events in an application**. With Amazon SQS, you need to **implement your own application-level tracking**, especially if your application uses multiple queues. 


## SWF Actors 

### 1.Workflow Starters:

**An application that can initiate (start) a workflow**. Could be your e-commerce website when placing an order or a mobile app searching for bus times.

### 2.Deciders 

**Control the flow of activity tasks in a workflow execution**. If something has finished in a workflow (or fails) a Decider decides what to do next.

### 3.Activity Workers

Carry out the activity tasks 

## Simple Notification Service

Amazon Simple Notification Service (Amazon SNS) is a web service that makes it easy to set up, operate, and **send notifications from the cloud**.

### can-dos:

1. **pushing cloud notifications** directly to mobile devices
2. deliver notifications by **SMS text message** or **email**
3. deliver notifications to **Amazon Simple Queue Service (SQS) queues**, or to **any HTTP endpoint**.
4. SNS notifications can also trigger Lambda functions.
5. Send the message to other AWS services


### SNS Subscribers

* HTTP 
* HTTPS 
* Email 
* Email-JSON 
* SQS 
* Application 
* Lambda  

## SNS VS SQS

#### Both Messaging Services in AWS 
#### SNS - Push
#### SQS - Polls (Pulls) [SQS download message and do the task]

#### SNS Pricing:

* Users pay `$0.50` per 1 million Amazon SNS Requests
* `$0.06` per 100,000 Notification deliveries over HTTP
* `$0.75` per 100 Notification deliveries over SMS
* `$2.00` per 100,000 Notification deliveries over Email

cost: sms > email > http notification


## What is Elastic Transcoder? 

**Transcoder in the cloud. Convert media files from their original source format in to different formats that will play on smartphones, tablets, PC's etc.** 

Provides transcoding presets for popular output formats, which means that you don't need to guess about which settings work best on particular devices. 

Pay based on the minutes that you transcode and the resolution at which you transcode. 

