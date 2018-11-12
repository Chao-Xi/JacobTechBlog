# AWS Command Line Lab

#### Creating an new instance without IAM role attached to it



## Creating an new user and group


![Alt Image Text](images/9_1.jpg "body image")

#### download credentials


### create new group with policy

![Alt Image Text](images/9_2.jpg "body image")

### attach the user to group

![Alt Image Text](images/9_3.jpg "body image")


## Use AWS CLI with credentials

![Alt Image Text](images/9_4.jpg "body image")


#### aws s3 ls  => error

![Alt Image Text](images/9_5.jpg "body image")



#### aws configure  <= downloaded credential

![Alt Image Text](images/9_6.jpg "body image")


#### aws s3 ls  => success

![Alt Image Text](images/9_7.jpg "body image")


```
$ cd .aws/
$ ls
config		credentials
```


## Exam Tips:

#### 1. You can only assign an IAM role to an instance when you creating a new ec2 instance. You cannot assign latter, after you already created it
#### 2. For protection: use role rather than credentials

