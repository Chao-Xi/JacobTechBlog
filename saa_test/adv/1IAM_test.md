# IAM Questions

## IAM Access Management

1.IAM’s Policy Evaluation Logic always starts with a default ______Deny______ for every request, except for those that use the AWS account’s root security credentials

2.An organization has created 10 IAM users. The organization wants each of the IAM users to have access to a separate DynamoDB table. All the users are added to the same group and the organization wants to setup a group level policy for this. How can the organization achieve this?

**Create a DynamoDB table with the same name as the IAM user name and define the policy rule which grants access based on the DynamoDB ARN using a variable**

3.An organization has setup multiple IAM users. The organization wants that each IAM user accesses the IAM console **only within the organization and not from outside**. How can it achieve this?

**Create an IAM policy with a condition which denies access when the IP address range is not from the organization**


4.Can I attach more than one policy to a particular entity?  **Yes always**

5.A ____policy_____ is a document that provides a formal statement of one or more permissions.

6.A _____permission_____ is the concept of allowing (or disallowing) an entity such as a user, group, or role some type of access to one or more resources.

7.True or False: When using IAM to control access to your RDS resources, the key names that can be used are case sensitive. For example, aws:CurrentTime is NOT equivalent to AWS:currenttime. **FALSE**   **key names are not case sensitive**

8.Which of the following are correct statements with **policy evaluation logic in AWS Identity and Access Management**? Choose 2 answers.

* By default, all requests are denied
* An explicit allow overrides default deny

9.IAM provides several policy templates you can use to automatically assign permissions to the groups you create. The   **Administrator Access**  policy template gives the Admins group permission to access all account resources, except your AWS account information

10.Every user you create in the IAM system starts with ____No permissions_____.

11.Groups can’t ____be nested at all____.

12.When assessing an organization AWS use of AWS API access credentials which of the following three credentials should be evaluated? Choose 3 answers

* Console passwords
* Access keys
* Signing certificates

13.An organization has created 50 IAM users. The organization wants that each user **can change their password but cannot change their access keys**. How can the organization achieve this?

**Root account owner can set the policy from the IAM console under the password policy screen**

14.Your organization’s security policy requires that all privileged users either **use frequently rotated passwords or one-time access credentials in addition to username/password**. Which two of the following options would allow an organization to enforce this policy for AWS users?

* Configure multi-factor authentication for privileged IAM users
* Create IAM users for privileged accounts (can set password policy)

15.Your organization is preparing for a security assessment of your use of AWS. In preparation for this assessment, which two IAM best practices should you consider implementing? Choose 2 answers.

* Configure MFA on the root account and for privileged IAM users
* Assign IAM users and groups configured with policies granting least privilege access

16.A company needs to deploy services to an AWS region which they have not previously used. The company currently has an AWS identity and Access Management (IAM) role for the Amazon EC2 instances, which permits the instance to have access to Amazon DynamoDB. The company wants their EC2 instances in the new region to have the same privileges. How should the company achieve this?

**Assign the existing IAM role to the Amazon EC2 instances in the new region(no region restricted)**

13.After creating a new IAM user which of the following must be done before they can successfully make API calls?

**Create a set of Access Keys for the user**


17.An organization is planning to create a user with IAM. They are trying to understand the limitations of IAM so that they can plan accordingly. Which of the below mentioned statements is not true with respect to the limitations of IAM?

**One IAM user can be a part of a maximum of 5 groups**

18.Within the IAM service a GROUP is regarded as a:

**A collection of users.**

19.Is there a limit to the number of groups you can have?

**Yes for all users**

20.What is the default maximum number of MFA devices in use per AWS account (at the root account level)?

**1**

21.When you use the AWS Management Console to delete an IAM user, **IAM also deletes any signing certificates and any access keys belonging to the user.**

**TRUE**


22.You are setting up a blog on AWS. In which of the following scenarios will you need AWS credentials? (Choose 3)

* **Sign in to the AWS management console to launch an Amazon EC2 instance**
* Sign in to the running instance to install some software (needs ssh keys)
* **Launch an Amazon RDS instance**
* Log into your blog’s content management system to write a blog post (need to authenticate using blog authentication)
* **Post pictures to your blog on Amazon S3**

23.An organization has 500 employees. The organization wants to set up AWS access for each department. Which of the below mentioned options is a possible solution?

**Create IAM groups based on the permission and assign IAM users to the groups**


24.An organization has hosted an application on the EC2 instances. **There will be multiple users connecting to the instance for setup and configuration of application**. The organization is planning to implement certain security best practices. Which of the below mentioned pointers will not help the organization achieve better security arrangement?

**Allow only IAM users to connect with the EC2 instances with their own secret access key**.


## AWS IAM Role

1.A company is building software on AWS that requires access to various AWS services. Which configuration should be used to **ensure that AWS credentials (i.e., Access Key ID/Secret Access Key combination) are not compromised?**

**Assign an IAM role to the Amazon EC2 instance.**

2.A company is preparing to give AWS Management Console access to developers. Company policy mandates identity federation and role-based access control. Roles are currently assigned using groups in the **corporate Active Directory**. What combination of the following will give developers access to the AWS console? (Select 2) Choose 2 answers

* **AWS Directory Service AD Connector（AD Connector using for existing on-premises directory while Simple AD is aws cloud-based directory ）**
* **AWS identity and Access Management roles**  (not group, or user)

3.Which of the following items are required to allow an application deployed on an EC2 instance to write data to a DynamoDB table? Assume that no security keys are allowed to be stored on the EC2 instance.

* Create an IAM Role that allows write access to the DynamoDB table
* Add an IAM Role to a running EC2 instance. (With latest enhancement from AWS, IAM role can be assigned to a running EC2 instance)

3.A user has created an application which will be hosted on EC2. T**he application makes calls to DynamoDB to fetch certain data**. The application is using the DynamoDB SDK to connect with from the EC2 instance. Which of the below mentioned statements is true with respect to the best practice for security in this scenario?

**The user should attach an IAM role with DynamoDB access to the EC2 instance**


## AWS IAM Roles vs Resource Based Policies

1.What are the two permission types used by AWS?

**User-based and Resource-based**

2.What’s the policy used for cross account access? (Choose 2)

**Trust policy**

**Permissions Policy**

## AWS IAM Best Practices

### Root Account -Don’t use & Lock away access keys
### User – Create individual IAM users
### Groups – Use groups to assign permissions to IAM users
### Permission – Grant least privilege (no permissions)
### Passwords – Enforce strong password policy for users
### MFA – Enable MFA for privileged users
### Role – Use roles for applications that run on EC2 instances
### Sharing – Delegate using roles
### Rotation – Rotate credentials regularly
### Track – Remove unnecessary credentials
### Conditions – Use policy conditions for extra security
### Auditing – Monitor activity in the AWS account

CloudTrail, S3, CloudFront in AWS to determine the actions users have taken in the account and the resources that were used.


1.What are the recommended best practices for IAM?

* **Grant least privilege**
* **Use Mutli-Factor Authentication (MFA)**
* **Rotate credentials regularly**

2.Which of the below mentioned options is not a best practice to securely manage the AWS access credentials?

**Create strong access key and secret access key and attach to the root account**

3.Your CTO is very worried about the security of your AWS account. How best can you prevent hackers from completely hijacking your account?

**Use MFA on all users and accounts, especially on the root account.**

4.__CloudTrail__ helps us **track AWS API calls and transitions**, __AWS Config__ helps to **understand what resources we have now**, and __IAM Credential Reports__ allows **auditing credentials and logins.**

