# Simple Workflow Service

## What is SWF? 

**Amazon Simple Workflow Service (Amazon SWF) is a web service that makes it easy to coordinate work across distributed application components.**

Amazon SWF enables applications for a range of use cases, `including media processing`, `web application back-ends`, `business process workflows`, and `analytics pipelines`, to be designed as a **coordination of tasks**. 
 
Tasks represent invocations of various processing steps in an application which can be performed by `executable code`, `web service calls`, `human actions`, and `scripts`.


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


