# AWS Web Services

## Courses List

1. [SQS (Amazon Simple Queue Service)](1SQS.md)
2. [Simple Workflow Service](2SWF.md)
3. [Simple Notification Service](3SNS.md)
4. [Elastic Transcoder](4ElasticTranscoder.md)

## SQS Exam Tips

#### `Amazon SQS` is a `web service` that gives you access to a `message queue` that can be used to store messages while waiting for a computer to process them. 

* Does not offer FIFO (first in, first out)

* 12 hours visibility time out
 
* Amazon SQS is engineered to provide "at least once" delivery of all messages in its queues. Although most of the time each message will be delivered to your application exactly once, you should design your system so that processing a message more than once does not create any errors or inconsistencies. 

* `256kb` message size now available 
* Billed at `64kb` "Chunks" 
* A `256kb` message will be `4 x 64kb` "chunks"


 

#### Amazon Simple Workflow Service (Amazon SWF) is a web service that makes it easy to coordinate work across distributed application components.

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


## SNS Subscribers

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

## What is Elastic Transcoder? 

**Transcoder in the cloud. Convert media files from their original source format in to different formats that will play on smartphones, tablets, PC's etc.** 

Provides transcoding presets for popular output formats, which means that you don't need to guess about which settings work best on particular devices. 

Pay based on the minutes that you transcode and the resolution at which you transcode. 

