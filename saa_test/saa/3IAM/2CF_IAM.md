# Cloudformation Create IAM Role


## Managed Policies and Inline Policies for IAM Role


### AWS Managed Policies

When you need to set the permissions for an identity in IAM, you must decide whether to use an AWS managed policy, a customer managed policy, or an inline policy. 

**An AWS managed policy is a standalone policy that is created and administered by AWS. Standalone policy means that the policy has its own Amazon Resource Name (ARN) that includes the policy name. For example, arn:aws:iam::aws:policy/IAMReadOnlyAccess is an AWS managed policy.**


**AWS managed policies are designed to provide permissions for many common use cases.** There are AWS managed policies that define typical permissions for service administrators and grant full access to the service

### Customer Managed Policies

You can create standalone policies that you administer in your own AWS account, which we refer to as **customer managed policies**. **You can then attach the policies to multiple principal entities in your AWS account**. 

**When you attach a policy to a principal entity, you give the entity the permissions that are defined in the policy.**


### Inline Policies

**An inline policy is a policy that's embedded in a principal entity**(a user, group, or role)—that is, **the policy is an inherent part of the principal entity**. You can create a policy and embed it in a principal entity, either when you create the principal entity or later.


### Choosing Between Managed Policies and Inline Policies

**The different types of policies are for different use cases. In most cases, we recommend that you use managed policies instead of inline policies.**


### Reference: 

[Managed Policies and Inline Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

## Cloudformation Create IAM Role (managed policy)


### Step one: create customer managed policy for common s3 application Role

**S3ReadWrite.yaml**

```
Description:
    This template create a policy and attaches it to a list of role.
    Used for jenkins master and slaves read and write to s3.
    s3 bucket name bbmobile-jenkins-archive
Parameters:
    RoleList:
        Description: All the roles this policy attaches to
        Type: CommaDelimitedList
    PolicyName:
        Description: Name of the policy
        Type: String
Resources:
  JenkinsS3Policy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: !Ref PolicyName
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Action:
          - s3:ListBucket
          Resource: "arn:aws:s3:::bbmobile-jenkins-archive"
        - Effect: Allow
          Action:
          - s3:PutObject
          - s3:GetObject
          - s3:PutObjectAcl
          - s3:PutObjectTagging
          - s3:PutObjectVersionAcl
          Resource:
          - "arn:aws:s3:::bbmobile-jenkins-archive/*"
      Roles: !Ref RoleList
Outputs:
    JenkinsS3Policy:
        Description: A reference to the created Policy
        Value: !Ref JenkinsS3Policy
```


```
0.
JenkinsS3Policy:
    Type: AWS::IAM::ManagedPolicy

1.
Resource: "arn:aws:s3:::bbmobile-jenkins-archive"
Action: s3:ListBucket

2.
Resource: "arn:aws:s3:::bbmobile-jenkins-archive/*"
Action: s3:PutObject s3:GetObject s3:PutObjectAcl s3:PutObjectTagging s3:PutObjectVersionAcl

3.
ManagedPolicyName: !Ref PolicyName
Roles: !Ref RoleList
```

**S3ReadWrite_params.json**

```
  {
    "ParameterKey": "PolicyName",
    "ParameterValue": "BbmobileJenkinsS3Policy"
  },
  {
    "ParameterKey": "RoleList",
    "ParameterValue": "us-east-1-bbmobile-feedback-ui-server,us-east-1-bbmobile-jenkins-master,us-east-1-bbmobile-release-server,..."
  }
]
```

```
"ParameterKey": "RoleList"
"ParameterValue" : All IAM roles attached, you wanna use this policy
```


### Couldformation Create this customer managed role first time

```
aws cloudformation create-stack --stack-name S3ReadWritePolicy --template-body file:///.../common_policies/S3ReadWrite.yaml  --parameters file:///.../common_policies/S3ReadWrite_param.json --capabilities CAPABILITY_NAMED_IAM --region=us-east-1
```

### Couldformation update this customer managed role

**Sometimes you wanna attach new entities to the role list, you need update this managed role**

```
aws cloudformation create-change-set --stack-name S3ReadWritePolicy --change-set-name UpdateRoleAttach0601 --template-body file:///.../common_policies/3ReadWrite.yaml  --parameters file:///.../common_policies/S3ReadWrite_params.json --capabilities CAPABILITY_NAMED_IAM --region=us-east-1
```

### Attention

1. when you use `create-change-set` to update the `cloudformation changeset`, you need pay attention to the `--stack-name`. Wrong name, especially already exists name, may cause a big problem。 You need double check the `changeset`, before execute it

2. Add special tags for ` --change-set-name` like date, version, reason, etc, like `UpdateRoleAttach0601` for easily trace 

3. Take care of `Replacement` of  `create-change-set`. If it is `True`, please double check before you execute. If it's not, it is easy to change it back



## Cloudformation Create IAM Role (Inline policy)

### create inline policy role named "Mbaas"


**BbmobileMbaasBuilderRole.yaml**

```
Description:
    This template create role for mbaas release server
Parameters:
    RoleName:
        Description: Name of the role
        Type: String
    PolicyName:
        Description: Name of the policy
        Type: String
Resources:
  RootRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Join [ "-", [ !Ref 'AWS::Region', !Ref RoleName ]]
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Principal:
            Service:
            - ec2.amazonaws.com
          Action:
          - sts:AssumeRole
      Path: "/"
  RolePolicies:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: !Ref PolicyName
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
        - Effect: Allow
          Action:
          - ec2:Describe*
          Resource: "*"
      Roles:
      - !Ref RootRole
Outputs:
    RootRole:
        Description: A reference to the created RootRole
        Value: !Ref RootRole
    RolePolicies:
        Description: A reference to the created RolePolicies
        Value: !Ref RolePolicies
```
```
0.
RootRole:
    Type: AWS::IAM::Role

RolePolicies:
    Type: AWS::IAM::Policy


1. 
"RoleName": "bbmobile-mbaas-builder"
"PolicyName": "bbmobile-mbaas-policy"
```

**BbmobileMbaasBuilderRole_param.json**

```
[
   {
    "ParameterKey": "RoleName",
    "ParameterValue": "bbmobile-mbaas-builder"
   },
   {
    "ParameterKey": "PolicyName",
    "ParameterValue": "bbmobile-mbaas-policy"
   }
]
```

### Couldformation Create this IAM role first time

```
aws cloudformation create-stack --stack-name MbaasRole --template-body file:///.../mbaas_builder/BbmobileMbaasBuilderRole.yaml --parameters file:///.../mbaas_builder/BbmobileMbaasBuilderRole_param.json --region us-east-1 --capabilities CAPABILITY_NAMED_IAM
```


## Cloudformation Create Mbaas EC2 instance attached new mbass IAM role

**BbmobileMbaasBuilderInstance.yaml**

```
Description:
    This template deploys a mbaas builder server
Parameters:
    InstanceName:
        Description: An environment name that will be prefixed to resource names
        Type: String
    JenkinsRole:
        Description: This jenkins is master or agent
        Type: String
        Default: agent
    JenkinsVPC:
        Description: VPC ID of this instance
        Type: AWS::EC2::VPC::Id
    JenkinsMasterId:
        Description: Jenkins master name of this agent
        Type: String
    ImageIDParameter:
        Description: Image id to launch the instance
        Type: AWS::EC2::Image::Id
        Default: ami-a22323d8
    InstanceTypeParameter:
      Type: String
      Default: t2.small
      AllowedValues:
        - t2.micro
        - t2.small
        - m4.large
      Description: Enter t2.micro, or t2.small. Default is t2.small
    SubnetIDParameter:
      Type: AWS::EC2::Subnet::Id
      Default: subnet-******
      AllowedValues:
        - subnet-******
        - subnet-******
    Department:
      Description: Should always be BbMobile
      Type: String
      Default: BbMobile
    Environment:
      Description: dev or test or stage or prod
      Type: String
      Default: dev
    GroupName:
      Description: Group name of the instance
      Type: String
    Product:
      Description: Project
      Type: String
    cmapplication:
      Description: Cost Manager
      Type: String
    cmenv:
      Description: Cost Manager
      Type: String
    cmlayer:
      Description: Cost Manager
      Type: String
    InstancePofileRoleParameter:
      Description: Instance Profile Role ID
      Type: String
    SecurityGroupIdParameter:
      Description: SecurityGroupId of this instance
      Type: AWS::EC2::SecurityGroup::Id
Resources:
  InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Path: "/"
      Roles:
      - !Ref InstancePofileRoleParameter
  Instance:
    Type: "AWS::EC2::Instance"
    Properties:
      BlockDeviceMappings:
        -
          DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 100
      DisableApiTermination: false
      EbsOptimized: false
      IamInstanceProfile: !Ref InstanceProfile
      ImageId: !Ref ImageIDParameter
      InstanceInitiatedShutdownBehavior: stop
      InstanceType: !Ref InstanceTypeParameter
      KeyName: DevOpsKey
      Monitoring: false
      SecurityGroupIds:
        - !Ref SecurityGroupIdParameter
      SubnetId: !Ref SubnetIDParameter
      Tags:
        -
          Key: Name
          Value: !Ref InstanceName
        - Key: ManagedServiceLevel
          Value: MiP Enhanced
        - Key: cmapplication
          Value: !Ref cmapplication
        - Key: cmenv
          Value: !Ref cmenv
        - Key: cmlayer
          Value: !Ref cmlayer
        - Key: product
          Value: !Ref Product
        - Key: Department
          Value: !Ref Department
        - Key: Environment
          Value: !Ref Environment
        - Key: GroupName
          Value: !Ref GroupName
        - Key: JenkinsRole
          Value: !Ref JenkinsRole
        - Key: JenkinsVPC
          Value: !Ref JenkinsVPC
        - Key: JenkinsMasterId
          Value: !Ref JenkinsMasterId
Outputs:
    Instance:
        Description: A reference to the created Instance
        Value: !Ref Instance

```


```
Roles:
      - !Ref InstancePofileRoleParameter
```

**BbmobileMbaasBuilderInstance_param.json**

```
[
   {
     "ParameterKey": "JenkinsRole",
     "ParameterValue": "agent"
   },
   {
     "ParameterKey": "JenkinsVPC",
     "ParameterValue": "vpc-*****"
   },
   {
     "ParameterKey": "JenkinsMasterId",
     "ParameterValue": "bbmobile-ci-jenkins"
   },
   {
    "ParameterKey": "cmapplication",
    "ParameterValue": "mbaas"
   },
   {
    "ParameterKey": "cmenv",
    "ParameterValue": "Development"
   },
   {
    "ParameterKey": "cmlayer",
    "ParameterValue": "Infra"
   },
   {
    "ParameterKey": "Department",
    "ParameterValue": "501"
   },
   {
    "ParameterKey": "Environment",
    "ParameterValue": "Development"
   },
   {
    "ParameterKey": "GroupName",
    "ParameterValue": "jenkins-slave-ci"
   },
   {
    "ParameterKey": "ImageIDParameter",
    "ParameterValue": "ami-a22323d8"
   },
   {
    "ParameterKey": "InstanceName",
    "ParameterValue": "bbmobile-mbaas-builder"
   },
   {
    "ParameterKey": "InstanceTypeParameter",
    "ParameterValue": "m4.large"
   },
   {
    "ParameterKey": "Product",
    "ParameterValue": "mbaas"
   },
   {
    "ParameterKey": "SubnetIDParameter",
    "ParameterValue": "subnet-*****"
   },
   {
    "ParameterKey": "SecurityGroupIdParameter",
    "ParameterValue": "sg-*****"
   },
   {
    "ParameterKey": "InstancePofileRoleParameter",
    "ParameterValue": "us-east-1-bbmobile-mbaas-builder"
   }
]
```

```
"InstancePofileRoleParameter": "us-east-1-bbmobile-mbaas-builder"
```

### Couldformation Create ec2 instance

```
aws cloudformation create-stack --stack-name BbmobileMbaasBuilderInstance --template-body file:///.../mbaas_builder/BbmobileMbaasBuilderInstance.yaml --parameters file:///.../mbaas_builder/BbmobileMbaasBuilderInstance_param.json --region us-east-1 --capabilities CAPABILITY_NAMED_IAM
```




