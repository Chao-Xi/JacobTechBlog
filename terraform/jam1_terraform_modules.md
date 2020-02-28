# Jam Terraform Projects

## 1.Module 让 Terraform 使用更简单

为了使整个架构的逻辑可以更加清楚的展示在模板中，我们可以考虑，对资源进行分类，将每一类资源用一个单独的目录进行管理，最后用一个模板来管理所有的目录，进而完成对所有资源及资源关系的串联，如下所示：

```
$ tree terraform/
terraform/
├── aws
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   ├── terraform.tfvars.example
│   └── var.tf
└── modules
    ├── bucket
    │   ├── docconversion.tf
    │   ├── objectstore.tf
    │   ├── output.tf
    │   ├── var.tf
    │   └── vpce.tf
    ├── cdn
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── var.tf
    ├── certificate
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── var.tf
    ├── database
    │   ├── main.tf
    │   ├── output.tf
    │   └── var.tf
    └── eks
        ├── eks.tf
        ├── iam.tf
        ├── nat_gatway.tf
        ├── node_subnet.tf
        ├── output.tf
        ├── private_subnet.tf
        ├── public_subnet.tf
        ├── security_group.tf
        ├── var.tf
        └── vpc.tf
```

将该架构中的资源分为`Buckets`，`cdn`，`certificate`, `eks`，数据库（RDS) `database`这几类，然后将上文模板中的资源分别在对应的目录中予以实现。

接下来，用统一的模版`main.tf`将这些目录关联起来，如下所示：

```
terraform {
  backend "s3" {
    bucket         = "jam-terraform-backend"
    key            = "tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform_lock"
  }
}

module "database" {
  source             = "../modules/database"
  JAM_INSTANCE       = "${var.JAM_INSTANCE}"
  region             = "${var.region}"
  VPC_ID             = var.VPC_ID == null ? data.aws_vpc.vpc.id : var.VPC_ID
  GARDENER_SG_ID     = var.GARDENER_SG_ID == null ? data.aws_security_group.node.id : var.GARDENER_SG_ID
  ADMIN_PASSWORD     = "${var.ADMIN_PASSWORD}"
  availability_zones = data.aws_availability_zones.available
}
module "bucket" {
  source          = "../modules/bucket"
  JAM_INSTANCE    = "${var.JAM_INSTANCE}"
  region          = "${var.region}"
  VPC_ID          = var.VPC_ID == null ? data.aws_vpc.vpc.id : var.VPC_ID
  route_table_ids = length(var.route_table_ids) == 0 ? data.aws_route_table.private_route.*.id : var.route_table_ids
}

module "certificate" {
  source       = "../modules/certificate"
  JAM_INSTANCE = "${var.JAM_INSTANCE}"
  DNS_ZONE     = "${var.DNS_ZONE}"
}


module "cdn" {
  providers = {
    aws = "aws.cdn"
  }
  source          = "../modules/cdn"
  JAM_INSTANCE    = "${var.JAM_INSTANCE}"
  DNS_ZONE        = "${var.DNS_ZONE}"
  certificate_arn = "${var.cdn_certificate_arn}"
}

module "eks" {
  source              = "../modules/eks"
  JAM_INSTANCE        = "${var.JAM_INSTANCE}"
  region              = "${var.region}"
  min_worker_count    = var.min_worker_count
  max_worker_count    = var.max_worker_count
  target_worker_count = var.target_worker_count
  instance_type       = var.instance_type
  availability_zones  = data.aws_availability_zones.available
  cluster_admin_arns  = var.eks_cluster_admin_arns
}

```
可以看出，`main.tf`中资源的结构更加清楚，更加接近于架构图。

同时，大家已经注意到了，main.tf引入了一个 `module`，通过`module`将资源目录串联起来。


## 什么是Module

[Module](https://www.terraform.io/docs/configuration/modules.html) 是 Terraform 为了管理单元化资源而设计的，是子节点，子资源，子架构模板的整合和抽象。

正如本文架构中提到的，在实际复杂的技术架构中，涉及到的资源多种多样，资源与资源之间的关系错综复杂，资源模版的编写，扩展，维护等多个问题的成本都会不断增加。将多种可以复用的资源定义为一个`module`，通过对 `module` 的管理简化模板的架构，降低模板管理的复杂度，这就是`module`的作用。

除此之外，对开发者和用户而言，只需关心 `module` 的 `input` 参数即可，无需关心`module`中资源的定义，参数，语法等细节问题，抽出更多的时间和精力投入到架构设计和资源关系整合上。

### `provider.tf` 

```
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

provider "aws" {
  alias      = "cdn"                    #Special aws provider  alias = "cdn"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.cdn_region}"
}
```


## `outpus.tf`

```
output "mysql_hostname" {
  value       = "${module.database.mysql_hostname}"
  description = "The hostname for mysql, need to be configured in k8s yaml file."
}

output "docconversion_access_key_id" {
  value       = "${module.bucket.docconversion_access_key_id}"
  description = "The access key for docconversion bucket, need to be configured in secrets."
}

output "docconversion_access_secret" {
  value       = "${module.bucket.docconversion_access_secret}"
  sensitive   = true
  description = "The access key secret for docconversion bucket, need to be configured in secrets."
}

output "objectstore_access_key_id" {
  value       = "${module.bucket.objectstore_access_key_id}"
  description = "The access key for objectstore bucket, need to be configured in secrets."
}

output "objectstore_access_secret" {
  value       = "${module.bucket.objectstore_access_secret}"
  sensitive   = true
  description = "The access key secret for objectstore bucket, need to be configured in secrets."
}

output "aws_acm_certificate_arn" {
  value       = "${module.certificate.aws_acm_certificate_arn}"
  description = "The arn of certificate, need to run <aws acm describe-certificate --certificate-arn $CERT_ARN> and process DNS validation on ccloud."
}

output "cdn_domain_name" {
  value       = "${module.cdn.cdn_domain_name}"
  description = "The domain name of CDN needed to be configured in Converged Cloud DNS resolving"
}
```

## Terraform Variable

### Type Constraints

**The `type` argument in a `variable` block allows you to restrict the type of value that will be accepted as the value for a variable**. 

If no type constraint is set then a value of any type is accepted.

**While type constraints are optional, we recommend specifying them;** they serve as easy reminders for users of the module, and allow Terraform to return a helpful error message if the wrong type is used.

Type constraints are created from a mixture of type keywords and type constructors. The supported type keywords are:

* string
* number
* bool

The type constructors allow you to specify complex types such as collections:

* list(<TYPE>)
* set(<TYPE>)
* map(<TYPE>)
* object({<ATTR NAME> = <TYPE>, ... })
* tuple([<TYPE>, ...])

### Our variable includes:

* `variable "JAM_INSTANCE"`
* `variable "VPC_ID"`
* `variable "ADMIN_PASSWORD"`
* `variable "DNS_ZONE"`
* `variable "GARDENER_SG_ID"`
* `variable "region"`
* `variable "cdn_region"`
* `variable "aws_access_key"`
* `variable "aws_secret_key"` 
* `variable "cdn_certificate_arn"`
* `variable "route_table_ids"`
* `variable "min_worker_count" `
* `variable "max_worker_count"` 
* `variable "target_worker_count"`
* `variable "instance_type"`
* `variable "eks_cluster_admin_arns"`
* `variable "gardener_namespace"`

### Our variable types:

* `type = string`
* `type = "list"`
* `type = number`
* `type = list(string)`

### `var.tf`

```
variable "JAM_INSTANCE" {}
variable "VPC_ID" {
  type    = string
  default = null
}
variable "ADMIN_PASSWORD" {}
variable "DNS_ZONE" {
  default = "sapjam-integration"
}
variable "GARDENER_SG_ID" {
  type    = string
  default = null
}
variable "region" {
  default = "eu-central-1"
}
variable "cdn_region" {
  default = "us-east-1"
}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cdn_certificate_arn" {}
variable "route_table_ids" {
  type    = "list"
  default = []
}
variable "min_worker_count" {
  type    = number
  default = 3
}

variable "max_worker_count" {
  type    = number
  default = 9
}

variable "target_worker_count" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "m5.4xlarge"
}

variable "eks_cluster_admin_arns" {
  type    = list(string)
  default = []
}

variable "gardener_namespace" {
  type    = string
  default = null
}


variable "rds_cpu_threshold" {
  type    = number
  default = 80
}

variable "rds_memory_threshold" {
  type    = number
  default = 512000000 # 512MB
}

variable "rds_storage_threshold" {
  type    = number
  default = 1024000000 # 10GB
}

variable "rds_connection_threshold" {
  type    = number
  default = 1000 # current max_connections is 624 need to be changed to 1024 lately
}

variable "rds_dbloadcpu_threshold" {
  type    = number
  default = 3 # current vCPU is 2, set 3 as alert threshold
}

```



### `terraform.tfvar.example`

```
# region for your cluster
region         = "eu-central-1"
# CDN region for your cluster
cdn_region     = "us-east-1"

# Created in AWS UI
aws_access_key = "AKIAXXXXXXXXXXXX"
aws_secret_key = "SECRETXXXXXXXXXX"

JAM_INSTANCE   = "integration701"
# root password for db, need be filled in `kustomize/templates/filled_secrets/$JAM_INSTANCE/db-admin.yaml`.
ADMIN_PASSWORD = "rootPassw0rd"
# sapjam for production and sapjam-integration for integration/stage
DNS_ZONE = "sapjam-integration"

# Set up Inbound Connections Rule to DB
# By default, the RDS will not allow inbound connections. First, obtain the Security Group generated by Gardener: aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID Name=group-name,Values=shoot--$GARDENER_NAMESPACE--$JAM_INSTANCE-nodes --query "SecurityGroups[*].GroupId"
# Result:
#  [
#   "sg-xxxxxxxxxxx"
#  ]
# Or alternatively in the UI:
# (EC2 -> Security Groups -> search with VPC_ID:$VPC_ID and Security group for nodes as search parameters
# export GARDENER_SG_ID=<sg-xxxxxxxxxxx>

GARDENER_SG_ID      = "sg-0f..."

# `aws ec2 describe-vpcs` to get VPC of your Jam instance.

VPC_ID              = "vpc-04..."

# CDN certificate, you can find the arn at https://${cdn_region}.console.aws.amazon.com/acm/home
# If you are creating a Jam with URL "http://${JAM_INSTANCE}.sapjam-integration.com", you should find a certificate for "*.sapjam-integration.com".
# You can create a new certificate if there is no certificate you can use.
cdn_certificate_arn = "arn:aws:acm:us-east-1:..."

# aws ec2 describe-route-tables --filters Name=tag:Name,Values="shoot--sap-jam--$JAM_INSTANCE-private-eu-central-1a","shoot--sap-jam--$JAM_INSTANCE-private-eu-central-1b","shoot--sap-jam--$JAM_INSTANCE-private-eu-central-1c" | grep RouteTableId | sed 's/^[ \t]*//g' | uniq
route_table_ids = ["rtb-01..", "rtb-03...", "rtb-0d..."]

# The arn of cluster admin, only needed for EKS cluster
eks_cluster_admin_arns = ["arn:aws:iam::3"]
# The namespace of gardener, "sap-jam" by default
gardener_namespace = "sap-jam"
```






