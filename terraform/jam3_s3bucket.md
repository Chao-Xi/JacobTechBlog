# Jam AWS Object Store (S3 Bucket)

**There are two bucketss in this project**

## `var.tf`

```
variable "JAM_INSTANCE" {}
variable "region" {}
variable "VPC_ID" {}

variable "route_table_ids" {
  type = "list"
}
```



## `docconversion` and `objectstore` S3 Bucket



* `aws_s3_bucket`
* `aws_iam_user`
* `aws_iam_access_key`
* `aws_iam_user_policy`


##  `docconversion.tf`

### `aws_s3_bucket`

```
resource "aws_s3_bucket" "docconversion" {
  bucket = "${var.JAM_INSTANCE}-docconversion"
  region = "${var.region}"
  
  lifecycle_rule {
    id      = "2-day expiration"
    prefix  = ""
    enabled = true

    noncurrent_version_expiration {
      days = 2
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}
```

####  `lifecycle_rule` - (Optional) A configuration of object lifecycle management

* `id` - (Optional) Unique identifier for the rule.
* `prefix` - (Optional) Object key prefix identifying one or more objects to which the rule applies.
* `enabled` - (Required) Specifies lifecycle rule status.
* `noncurrent_version_expiration` - (Optional) Specifies when noncurrent object versions expire (documented below).
 * `days` (Optional) Specifies the number of days after object creation when the specific rule action takes effect.


####` server_side_encryption_configuration` - (Optional) A configuration of server-side encryption configuration 

* `rule` - (required) **A single object for server-side encryption by default configuration**.
 * `apply_server_side_encryption_by_default` - (required) **A single object for setting server-side encryption by default.**
 	 * `sse_algorithm` - (required) The server-side encryption algorithm to use. Valid values are 	`AES256` and `aws:kms `

```
server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
```

* `versioning` - (Optional) A state of versioning 

![Alt Image Text](images/jam2_1.png "body image")

### [`aws_iam_user`](https://www.terraform.io/docs/providers/aws/r/iam_user.html)

```
resource "aws_iam_user" "docconversion" {
  name = "${aws_s3_bucket.docconversion.id}"
}
```

**`integration702-docconversion`**


* `name` - (Required) **The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces**. You can also include any of the following characters: `=,.@-_..` User names are not distinguished by case. For example, you cannot create users named both "TESTUSER" and "testuser".


### `[aws_iam_access_key](https://www.terraform.io/docs/providers/aws/r/iam_access_key.html)`

Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.

```
resource "aws_iam_access_key" "docconversion" {
  user = "${aws_iam_user.docconversion.name}"
}
```


* `user` - (Required) The IAM user to associate with this access key.


### `[aws_iam_user_policy](https://www.terraform.io/docs/providers/aws/r/iam_user_policy.html)`

```
resource "aws_iam_user_policy" "docconversion_policy" {
  name = "${aws_s3_bucket.docconversion.id}"
  user = "${aws_iam_user.docconversion.name}"


  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Sid": "VisualEditor0",
		"Effect": "Allow",
		"Action": ["s3:ListAllMyBuckets", "s3:HeadBucket"],
		"Resource": "*"
	}, {
		"Sid": "VisualEditor1",
		"Effect": "Allow",
		"Action": "s3:*",
		"Resource": ["${aws_s3_bucket.docconversion.arn}", "${aws_s3_bucket.docconversion.arn}/*"]
	}, {
		"Sid": "VisualEditor2",
		"Effect": "Deny",
		"Action": ["s3:PutAccountPublicAccessBlock", "s3:GetAccountPublicAccessBlock", "s3:ListAllMyBuckets", "s3:HeadBucket"],
		"Resource": "*",
		"Condition": {
			"StringNotEqualsIfExists": {
				"aws:SourceVpc": "${var.VPC_ID}"
			}
		}
	}, {
		"Sid": "VisualEditor3",
		"Effect": "Deny",
		"Action": "s3:*",
		"Resource": ["${aws_s3_bucket.docconversion.arn}", "${aws_s3_bucket.docconversion.arn}/*"],
		"Condition": {
			"StringNotEqualsIfExists": {
				"aws:SourceVpc": "${var.VPC_ID}"
			}
		}
	}]
}
EOF
}
```

* `name` - (Optional) The name of the policy. If omitted, Terraform will assign a random, unique name.
* `user` - (Required) IAM user to which to attach this policy.
* `policy` - (Required) The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform


##  `objectstore.tf`

```
resource "aws_s3_bucket" "objectstore" {
  bucket = "${var.JAM_INSTANCE}-objectstore"
  region = "${var.region}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_iam_user" "objectstore" {
  name = "${aws_s3_bucket.objectstore.id}"
}

resource "aws_iam_access_key" "objectstore" {
  user = "${aws_iam_user.objectstore.name}"
}

resource "aws_iam_user_policy" "objectstore_policy" {
  name = "${aws_s3_bucket.objectstore.id}"
  user = "${aws_iam_user.objectstore.name}"


  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Sid": "VisualEditor0",
		"Effect": "Allow",
		"Action": ["s3:ListAllMyBuckets", "s3:HeadBucket"],
		"Resource": "*"
	}, {
		"Sid": "VisualEditor1",
		"Effect": "Allow",
		"Action": "s3:*",
		"Resource": ["${aws_s3_bucket.objectstore.arn}", "${aws_s3_bucket.objectstore.arn}/*"]
	}, {
		"Sid": "VisualEditor2",
		"Effect": "Deny",
		"Action": ["s3:PutAccountPublicAccessBlock", "s3:GetAccountPublicAccessBlock", "s3:ListAllMyBuckets", "s3:HeadBucket"],
		"Resource": "*",
		"Condition": {
			"StringNotEqualsIfExists": {
				"aws:SourceVpc": "${var.VPC_ID}"
			}
		}
	}, {
		"Sid": "VisualEditor3",
		"Effect": "Deny",
		"Action": "s3:*",
		"Resource": ["${aws_s3_bucket.objectstore.arn}", "${aws_s3_bucket.objectstore.arn}/*"],
		"Condition": {
			"StringNotEqualsIfExists": {
				"aws:SourceVpc": "${var.VPC_ID}"
			}
		}
	}]
}
EOF
}
```

##  `output.tf`


```
output "docconversion_access_key_id" {
  value = "${aws_iam_access_key.docconversion.id}"
}

output "docconversion_access_secret" {
  value = "${aws_iam_access_key.docconversion.encrypted_secret}"
}

output "objectstore_access_key_id" {
  value = "${aws_iam_access_key.objectstore.id}"
}

output "objectstore_access_secret" {
  value = "${aws_iam_access_key.objectstore.encrypted_secret}"
}
```

* `encrypted_secret` - The encrypted secret, base64 encoded, if `pgp_key` was specified. 

> NOTE: The encrypted secret may be decrypted using the command line, for example: 

```
terraform output encrypted_secret | base64 --decode | keybase pgp decrypt
```

### `vpce.tf`

Provides a VPC Endpoint resource.

[aws_vpc_endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html)

```
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${var.VPC_ID}"
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = "${var.route_table_ids}"
}
```

* `vpc_id` - (Required) The ID of the VPC in which the endpoint will be used.
* `service_name` - (Required) The service name, in the form `com.amazonaws.region.service` for AWS services.
* `route_table_ids` - (Optional) One or more route table IDs. Applicable for endpoints of type Gateway.



### VPC Endpoints Overview

* VPC endpoint enables creation of a private connection between your VPC and another AWS service using its private IP address
* VPC Endpoint does not require a public IP address, access over the Internet, NAT device, a VPN connection or AWS Direct Connect
* Endpoints are virtual devices. They are horizontally scaled, redundant, and highly available VPC components that allow communication between instances in your VPC and AWS services without imposing availability risks or bandwidth constraints on your network traffic.
* Endpoints currently do not support cross-region requests
* SUPPORT S3 and DynamoDB

**Limitations**

* Endpoint cannot be created between a VPC and an AWS service in a different region.
* Endpoint cannot be tagged
* Endpoint cannot be transferred from one VPC to another, or from one service to another
* Endpoint connections cannot be extended out of a VPC i.e. resources across the VPN connection, VPC peering connection, AWS Direct Connect connection cannot use the endpoint

![Alt Image Text](images/jam2_2.png "body image")


## Apply the module

```
$ terraform apply  --target=mod
ule.bucket
var.route_table_ids
  Enter a value: []

module.bucket.aws_s3_bucket.docconversion: Refreshing state... [id=integration702-docconversion]
module.bucket.aws_s3_bucket.objectstore: Refreshing state... [id=integration702-objectstore]
module.bucket.aws_iam_user.docconversion: Refreshing state... [id=integration702-integration702-docconversion]
module.bucket.aws_iam_access_key.docconversion: Refreshing state... [id=AKIAVMZVGAV227FRMSLM]
module.bucket.aws_iam_user_policy.docconversion_policy: Refreshing state... [id=integration702-integration702-docconversion:integration702-integration702-docconversion]
module.bucket.aws_iam_user.objectstore: Refreshing state... [id=integration702-integration702-objectstore]
module.bucket.aws_iam_access_key.objectstore: Refreshing state... [id=AKIAVMZVGAV2ROUXECFZ]
module.bucket.aws_iam_user_policy.objectstore_policy: Refreshing state... [id=integration702-integration702-objectstore:integration702-integration702-objectstore]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  ~ update in-place
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # module.bucket.aws_iam_access_key.docconversion must be replaced
-/+ resource "aws_iam_access_key" "docconversion" {
      + encrypted_secret  = (known after apply)
      ~ id                = "AKIAVMZVGAV227FRMSLM" -> (known after apply)
      + key_fingerprint   = (known after apply)
      ~ secret            = (sensitive value)
      ~ ses_smtp_password = (sensitive value)
      ~ status            = "Active" -> (known after apply)
      ~ user              = "integration702-integration702-docconversion" -> "integrati
on702-docconversion" # forces replacement
    }

  # module.bucket.aws_iam_access_key.objectstore must be replaced
-/+ resource "aws_iam_access_key" "objectstore" {
      + encrypted_secret  = (known after apply)
      ~ id                = "AKIAVMZVGAV2ROUXECFZ" -> (known after apply)
      + key_fingerprint   = (known after apply)
      ~ secret            = (sensitive value)
      ~ ses_smtp_password = (sensitive value)
      ~ status            = "Active" -> (known after apply)
      ~ user              = "integration702-integration702-objectstore" -> "integration
702-objectstore" # forces replacement
    }

  # module.bucket.aws_iam_user.docconversion will be updated in-place
  ~ resource "aws_iam_user" "docconversion" {
        arn           = "arn:aws:iam::371089343861:user/integration702-integration702-d
occonversion"
        force_destroy = false
        id            = "integration702-integration702-docconversion"
      ~ name          = "integration702-integration702-docconversion" -> "integration70
2-docconversion"
        path          = "/"
        tags          = {}
        unique_id     = "AIDAVMZVGAV2VCPMRRHJO"
    }

  # module.bucket.aws_iam_user.objectstore will be updated in-place
  ~ resource "aws_iam_user" "objectstore" {
        arn           = "arn:aws:iam::....:user/integration702-integration702-objectstore"
        force_destroy = false
        id            = "integration702-integration702-objectstore"
      ~ name          = "integration702-integration702-objectstore" -> "integration702-objectstore"
        path          = "/"
        tags          = {}
        unique_id     = "AIDAVMZVGAV2VWJDWJWXL"
    }

  # module.bucket.aws_iam_user_policy.docconversion_policy must be replaced
-/+ resource "aws_iam_user_policy" "docconversion_policy" {
      ~ id     = "integration702-integration702-docconversion:integration702-integration702-docconversion" -> (known after apply)
      ~ name   = "integration702-integration702-docconversion" -> "integration702-docconversion" # forces replacement
        policy = jsonencode(
            {
                Statement = [
                    {
                        Action   = [
                            "s3:ListAllMyBuckets",
                            "s3:HeadBucket",
                        ]
                        Effect   = "Allow"
                        Resource = "*"
                        Sid      = "VisualEditor0"
                    },
                    {
                        Action   = "s3:*"
                        Effect   = "Allow"
                        Resource = [
                            "arn:aws:s3:::integration702-docconversion",
                            "arn:aws:s3:::integration702-docconversion/*",
                        ]
                        Sid      = "VisualEditor1"
                    },
                    {
                        Action    = [
                            "s3:PutAccountPublicAccessBlock",
                            "s3:GetAccountPublicAccessBlock",
                            "s3:ListAllMyBuckets",
                            "s3:HeadBucket",
                        ]
                        Condition = {
                            StringNotEqualsIfExists = {
                                aws:SourceVpc = "vpc-0e65190c879cfecd0"
                            }
                        }
                        Effect    = "Deny"
                        Resource  = "*"
                        Sid       = "VisualEditor2"
                    },
                    {
                        Action    = "s3:*"
                        Condition = {
                            StringNotEqualsIfExists = {
                                aws:SourceVpc = "vpc-0e65190c879cfecd0"
                            }
                        }
                        Effect    = "Deny"
                        Resource  = [
                            "arn:aws:s3:::integration702-docconversion",
                            "arn:aws:s3:::integration702-docconversion/*",
                        ]
                        Sid       = "VisualEditor3"
                    },
                ]
                Version   = "2012-10-17"
            }
        )
      ~ user   = "integration702-integration702-docconversion" -> "integration702-docconversion" # forces replacement
    }

  # module.bucket.aws_iam_user_policy.objectstore_policy must be replaced
-/+ resource "aws_iam_user_policy" "objectstore_policy" {
      ~ id     = "integration702-integration702-objectstore:integration702-integration702-objectstore" -> (known after apply)
      ~ name   = "integration702-integration702-objectstore" -> "integration702-objectstore" # forces replacement
      ~ policy = jsonencode(
          ~ {
              ~ Statement = [
                  ~ {
                        Action    = [
                            "s3:ListAllMyBuckets",
                            "s3:HeadBucket",
                        ]
                      - Condition = {
                          - StringEquals = {
                              - aws:SourceVpc = "vpc-0e65190c879cfecd0"
                            }
                        } -> null
                        Effect    = "Allow"
                        Resource  = "*"
                        Sid       = "VisualEditor0"
                    },
                  ~ {
                        Action    = "s3:*"
                      - Condition = {
                          - StringEquals = {
                              - aws:SourceVpc = "vpc-0e65190c879cfecd0"
                            }
                        } -> null
                        Effect    = "Allow"
                        Resource  = [
                            "arn:aws:s3:::integration702-objectstore",
                            "arn:aws:s3:::integration702-objectstore/*",
                        ]
                        Sid       = "VisualEditor1"
                    },
                  + {
                      + Action    = [
                          + "s3:PutAccountPublicAccessBlock",
                          + "s3:GetAccountPublicAccessBlock",
                          + "s3:ListAllMyBuckets",
                          + "s3:HeadBucket",
                        ]
                      + Condition = {
                          + StringNotEqualsIfExists = {
                              + aws:SourceVpc = "vpc-0e65190c879cfecd0"
                            }
                        }
                      + Effect    = "Deny"
                      + Resource  = "*"
                      + Sid       = "VisualEditor2"
                    },
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + StringNotEqualsIfExists = {
                              + aws:SourceVpc = "vpc-0e65190c879cfecd0"
                            }
                        }
                      + Effect    = "Deny"
                      + Resource  = [
                          + "arn:aws:s3:::integration702-objectstore",
                          + "arn:aws:s3:::integration702-objectstore/*",
                        ]
```

After the bucket is created, make a note of `docconversion_access_key_id` and `objectstore_access_key_id` from output, it will be used at helm. You also need to get the secrets by running


```
$ terraform state show module.b
ucket.aws_iam_access_key.docconversion
# module.bucket.aws_iam_access_key.docconversion:
resource "aws_iam_access_key" "docconversion" {
    id                = "AKIAVMZVGAV227FRMSLM"
    secret            = (sensitive value)
    ses_smtp_password = (sensitive value)
    status            = "Active"
    user              = "integration702-integration702-docconversion"
}
```


