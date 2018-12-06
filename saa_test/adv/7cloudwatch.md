# AWS CloudWatch

* In addition to monitoring the **built-in metrics** that come with AWS, **custom metrics** can also be monitored
* CloudWatch stores the **log data indefinitely**,
* CloudWatch Alarm history is stored for only 14 days

### Namespaces

**CloudWatch namespaces are containers for metrics.**

**There is no default namespace. Each data element put into CloudWatch must specify a namespace**

### Dimensions

**A dimension is a name/value pair** that uniquely identifies a metric.

### Time Stamps

### Units

### Statistics

### Periods

### Aggregation

**CloudWatch does not aggregate data across regions.**

### Alarms

#### Action can be a

* SNS notification
* Auto Scaling policies
* EC2 action – stop or terminate EC2 instances

#### An alarm has three possible states:

* **OK** — The metric is within the defined threshold
* **ALARM** — The metric is outside of the defined threshold
* **INSUFFICIENT_DATA** — Alarm has just started, the metric is not available, or not enough data is available for the metric to determine the alarm state

**Alarms exist only in the region in which they are created.**

### Accessing CloudWatch

* AWS CloudWatch console
* CloudWatch CLI
* AWS CLI
* CloudWatch API
* AWS SDKs

### Questions

1.A company needs to monitor the read and write IOPs metrics for their AWS MySQL RDS instance and send real-time alerts to their operations team. Which AWS services can accomplish this? Choose 2 answers

* Amazon CloudWatch
* Amazon Simple Notification Service

2.A customer needs to capture all client connection information from their load balancer every five minutes. The company wants to use this data for analyzing traffic patterns and troubleshooting their applications. Which of the following options meets the customer requirements?

**Enable access logs on the load balancer.**

3.A user is running a batch process on EBS backed EC2 instances. The batch process starts a few instances to process Hadoop Map reduce jobs, which can run between 50 – 600 minutes or sometimes for more time. The user wants to configure that the instance gets terminated only when the process is completed. How can the user configure this with CloudWatch?

**Setup the CloudWatch action to terminate the instance when the CPU utilization is less than 5%**

4.A user has two EC2 instances running in two separate regions. The user is running an internal memory management tool, which captures the data and sends it to CloudWatch in US East, using a CLI with the same namespace and metric. Which of the below mentioned options is true with respect to the above statement?

**CloudWatch will receive and aggregate the data based on the namespace and metric**

5.A user has a weighing plant. The user measures the weight of some goods every 5 minutes and sends data to AWS CloudWatch for monitoring and tracking. Which of the below mentioned parameters is mandatory for the user to include in the request list?

**Namespace**

6.A user has launched an EC2 instance. The user is planning to setup the CloudWatch alarm. Which of the below mentioned actions **is not supported** by the CloudWatch alarm?

**Notify the Auto Scaling launch config to scale up**

7.A user has setup a CloudWatch alarm on an EC2 action when the CPU utilization is above 75%. The alarm sends a notification to SNS on the alarm state. If the user wants to simulate the alarm action how can he achieve this?

**The user can set the alarm state to ‘Alarm’ using CLI**

8.A user is publishing custom metrics to CloudWatch. Which of the below mentioned statements will help the user understand the functionality better?

**The user should be able to see the data in the console after around 15 minutes**


