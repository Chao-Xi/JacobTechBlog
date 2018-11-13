# Exam Tips

## Billing Alerts Reference

* You can monitor your estimated AWS charges using Amazon CloudWatch. 
* When you enable the monitoring of estimated charges for your AWS account, the estimated charges are calculated and sent several times daily to CloudWatch as metric data.


## Enable Billing Alerts

* You must be signed in using AWS account **root user credentials**; **IAM users cannot enable billing alerts for your AWS account**.
* **For consolidated billing accounts**, billing data for each linked account can be found by **logging in as the paying account**.


## IAM

### IAM consists of the following

* Users
* Groups (A way to group our users and apply polices to them collectively)  
* Roles 
* Policy Documents.

```
{"Version": "2012-10-17",
 "Statement": 
[ 
  {"Effect": "Allow", 
   "Action": "*", 
   "Resource": "*"}       # WildCard
]
}
```

### IAM is universal. It does not apply to regions at this time. 
### The "root account" is simply the account created when first setup your AWS account. It has complete Admin access. 
### New Users have NO permissions when first created. 
### New Users are assigned `Access Key ID & Secret Access Keys` when first created. 
### These are not the same as a password, and you cannot use the Access key ID & Secret Access Key to Login in to the console. You can use this to access AWS via the APIs and Command Line however. 

### You only get to view these once. If you lose them, you have to regenerate them. So save them in a secure location.

## what should we do?

### Always setup Multi-factor Authentication on your root account. 
### You can create and customize your own password rotation policies. 





