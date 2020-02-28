# Jam Cloudtrail IAM user group (Using Workspaces)



## Modules: `cloudtrial`

### `var.tf`

```
variable "region" {}
```

### `var.tf`

```
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "jam-${terraform.workspace}-cloudtrail-logs"
  region = "${var.region}"

  lifecycle_rule {
    enabled = true
    id      = "jam-awsorgcloudtrail-rule"

    tags = {
      "rule"       = "cloudtrail-rule"
      "autoclean"  = "true"
      "department" = "jam"
      "team"       = "devops"
      "purpose"    = "cloudtrail"
      "env"        = "${terraform.workspace}"
    }

    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }

  }

  tags = {
    "department" = "jam"
    "team"       = "devops"
    "purpose"    = "cloudtrail"
    "env"        = "${terraform.workspace}"
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::jam-${terraform.workspace}-cloudtrail-logs"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::jam-${terraform.workspace}-cloudtrail-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
} 
POLICY
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket" {

  bucket              = "${aws_s3_bucket.cloudtrail_bucket.id}"
  block_public_acls   = true
  block_public_policy = true
  
}

resource "aws_cloudtrail" "jam_cloudtrail" {
  name                          = "jam-${terraform.workspace}-cloudtrail"
  s3_bucket_name                = "${aws_s3_bucket.cloudtrail_bucket.id}"
  include_global_service_events = true
  is_multi_region_trail         = true
  tags = {
    "department" = "jam"
    "team"       = "devops"
    "env"        = "${terraform.workspace}"
    "owner"      = "jam-devops"
    "region"     = "gloabl"
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
}

```

### 1. `data "aws_caller_identity" "current" {}`

Data Source: `aws_caller_identity`

**Use this data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.**

[Current Workspace Interpolation](https://www.terraform.io/docs/state/workspaces.html#current-workspace-interpolation)

Within your Terraform configuration, you may include the name of the current workspace using the `${terraform.workspace}` interpolation sequence


#### Usage

```
"Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::jam-${terraform.workspace}-cloudtrail-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
```
### 2. `resource "aws_s3_bucket" "cloudtrail_bucket"`

[Amazon S3 Bucket Policy for CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::myBucketName"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::myBucketName/[optional prefix]/AWSLogs/myAccountID/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
```

### 3 `resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket"`

[`aws_s3_bucket_public_access_block`](https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html)

Manages S3 bucket-level Public Access Block configuration. For more information about these settings, 

* `block_public_acls` - (Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to `false`. Enabling this setting does not affect existing policies or ACLs. When set to `true` causes the following behavior:

	* `PUT` Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access.
	* PUT Object calls will fail if the request includes an object ACL.

* `block_public_policy `- (Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to `false.` Enabling this setting does not affect the existing bucket policy. When set to true causes Amazon S3 to:	
	* Reject calls to PUT Bucket policy if the specified bucket policy allows public access.

### 4.`resource "aws_cloudtrail" "jam_cloudtrail" `

[aws_cloudtrail](https://www.terraform.io/docs/providers/aws/r/cloudtrail.html#include_management_events)

### `output.tf`

```
output "cloudtrail_bucket_id" {
  value = "${aws_s3_bucket.cloudtrail_bucket.id}"
}

output "cloudtrail_id" {
  value = "${aws_cloudtrail.jam_cloudtrail.id}"
}
```

## terraform(aws security) main directory

### `main.tf`

```

module "cloudtrail" {
  region = "${var.region}"
  source = "./modules/cloudtrail"
}
```

### `terraform.tfvars`

```
# region for your resource 
region = "us-west-2"

# AWS aws_access_key and aws_secret_key, can be fetched from ~/.aws/credentials
aws_access_key = ""
aws_secret_key = ""
```

### `var.tf`

```
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "us-west-2"
}
```

### `output.tf`

```

output "cloudtrail_bucket_name" {
  value       = "${module.cloudtrail.cloudtrail_bucket_id}"
  description = "This bucket name need to be attahced to newly created AWS Cloudtrail in both stage and prod account."
}

output "cloudtrail_name" {
  value       = "${module.cloudtrail.cloudtrail_id}"
  description = "This will output the the name of newly created AWS Cloudtrail"
}
```

## terraform apply the module(default workspace)


### For stage account

```
$ cd terraform/
$ terraform workspace new stage  # If this workspace doesn't exist
$ terraform workspace select stage
Switched to workspace "stage".

# input correct stage `aws_access_key` and `aws_secret_key` in `terraform.tfvars`
$ terraform apply --target=module.cloudtrail
```

This terraform module will generate two resource s3 bucket and cloudtrail in stage account

* `cloudtrail_bucket_name` = jam-stage-cloudtrail-logs
* `cloudtrail_name` = jam-stage-cloudtrail


### For prod account


```
$ cd terraform/
$ terraform workspace new prod  # If this workspace doesn't exist
$ terraform workspace select prod
Switched to workspace "prod".

# input correct prod `aws_access_key` and `aws_secret_key` in `terraform.tfvars`
$ terraform apply --target=module.cloudtrail
```

This terraform module will generate two resource s3 bucket and cloudtrail in prod account

* `cloudtrail_bucket_name` = jam-prod-cloudtrail-logs
* `cloudtrail_name` = jam-prod-cloudtrail


```
$ tree .
├── terraform.tfstate.d
│   ├── prod
│   │   ├── terraform.tfstate
│   │   └── terraform.tfstate.backup
│   └── stage
│       ├── terraform.tfstate
│       └── terraform.tfstate.backup
```