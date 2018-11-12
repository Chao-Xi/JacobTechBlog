# VPC Flow Log 

## Create flow log for 'myVPC'

![Alt Image Text](images/7_1.jpg "body image")


### Create IAM flow log role

**Name**: `flowlogsRole` with `default policy`


![Alt Image Text](images/7_2.jpg "body image")



### Create `log group` from `CloudWatch log` 

![Alt Image Text](images/7_3.jpg "body image")

![Alt Image Text](images/7_4.jpg "body image")

**Name**: `myCustomVPCLogs`


### Create log stream Name `myLogStream`


![Alt Image Text](images/7_6.jpg "body image")


### Create flow log for 'myVPC'

![Alt Image Text](images/7_5.jpg "body image")

### Reload public IP to the instance

![Alt Image Text](images/7_7.jpg "body image")

![Alt Image Text](images/7_8.jpg "body image")


## Exam Tips

* You can monitor network traffic within your custom VPC's using VPC Flow Logs