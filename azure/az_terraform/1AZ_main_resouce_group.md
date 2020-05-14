# Azure Main with S3 backend

## Azure Main Module

### Azure provider `azurerm`

```
provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.44.0"

  subscription_id = var.az_subscription_id
  tenant_id       = var.az_tenant_id
}
```


### `main.tf`

*  Backend "s3"
*  module `"resourcegroup"` 
*  module `"database"`
*  module `"storageaccount"`
*  module `"cdn"`

```
# JAM Terraform S3 Backend with dynamodb to store lock

terraform {
  backend "s3" {
    bucket         = "jam-terraform-backend"
    key            = "tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform_lock"
  }
}

module "resourcegroup" {
  source              = "../modules/resourcegroup"
  JAM_INSTANCE        = var.JAM_INSTANCE
  region              = var.region
  gardener_namespace  = var.gardener_namespace
  resource_group_name = var.resource_group_name
}

module "database" {
  source              = "../modules/database"
  JAM_INSTANCE        = var.JAM_INSTANCE
  region              = var.region
  ADMIN_USERNAME      = var.ADMIN_USERNAME
  ADMIN_PASSWORD      = var.ADMIN_PASSWORD
  gardener_namespace  = var.gardener_namespace
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
}

module "storageaccount" {
  source              = "../modules/storageaccount"
  JAM_INSTANCE        = var.JAM_INSTANCE
  region              = var.region
  gardener_namespace  = var.gardener_namespace
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
}

module "cdn" {
  source              = "../modules/cdn"
  JAM_INSTANCE        = var.JAM_INSTANCE
  DNS_ZONE            = var.DNS_ZONE
  region              = var.region
  gardener_namespace  = var.gardener_namespace
  resource_group_name = var.resource_group_name
}
```

### var.tf


* variable `"JAM_INSTANCE"`
* variable `"ADMIN_USERNAME"` for MySQL DB admin
* variable `"ADMIN_PASSWORD"` for MySQL DB admin
* variable `"DNS_ZONE"`
* variable `"region"`
* variable `"cdn_region"`,it would be aligned with the cluster region.
* Azure subscription account info, get it by `'az account show'`
	* variable `"az_subscription_id"` 
	* `"az_tenant_id"`
* variable `"gardener_namespace"`
* `resource_group_name` created by `Gardener`
	* `# shoot--{gardener_namespace}--{JAM_INSTANCE}` 

* variable `"subnet_id"`: The worker nodes subnet id get from az cli

```
$ az network vnet subnet list -g $resource_group_name --vnet-name $vnet
```

```
variable "JAM_INSTANCE" {
  type    = string
  default = "jam99"
}

# Initial MySQL DB admin credential info
variable "ADMIN_USERNAME" {
  type    = string
  default = null
}
variable "ADMIN_PASSWORD" {
  type    = string
  default = null
}

# sapjam for production and sapjam-integration for integration/stage
variable "DNS_ZONE" {
  type    = string
  default = "sapjam-integration"
}

# Azure cluster region
variable "region" {
  type    = string
  default = "westeurope"
}

# Azure CDN region info, it would be aligned with the cluster region.
variable "cdn_region" {
  type    = string
  default = "westeurope"
}

# Azure subscription account info, get it by 'az account show'
variable "az_subscription_id" {
  type    = string
  default = null
}
variable "az_tenant_id" {
  type    = string
  default = null
}

variable "gardener_namespace" {
  type    = string
  default = null
}

# The default resource_group_name created by Gardener follows the convention: 
# shoot--{gardener_namespace}--{JAM_INSTANCE}
variable "resource_group_name" {
  type    = string
  default = null
}

# The worker nodes subnet id get from az cli
# az network vnet subnet list -g $resource_group_name --vnet-name $vnet 
variable "subnet_id" {
  type    = string
  default = null
}
```

### `output.tf`

* output `"mysql_hostname"`: `module.database.mysql_hostname`
* output `"docconversion_access_key_id"`: `module.storageaccount.docconversion_access_key_id`
* output `"docconversion_access_secret"`: `module.storageaccount.docconversion_access_secret`
* output `"objectstore_access_key_id"`: `module.storageaccount.objectstore_access_key_id`
* output `"objectstore_access_secret"`:  `module.storageaccount.objectstore_access_secret`
* output `"cdn_domain_name"`: `module.cdn.cdn_domain_name`


```
output "mysql_hostname" {
  value       = module.database.mysql_hostname
  description = "The hostname for mysql, need to be configured in instance k8s yaml file."
}

output "docconversion_access_key_id" {
  value       = module.storageaccount.docconversion_access_key_id
  description = "The access object id for docconversion storage account container, need to be configured in secrets."
}

output "docconversion_access_secret" {
  value       = module.storageaccount.docconversion_access_secret
  sensitive   = true
  description = "The access key secret for docconversion storage account container, need to be configured in secrets."
}

output "objectstore_access_key_id" {
  value       = module.storageaccount.objectstore_access_key_id
  description = "The access key for objectstore bucket, need to be configured in secrets."
}

output "objectstore_access_secret" {
  value       = module.storageaccount.objectstore_access_secret
  sensitive   = true
  description = "The access key secret for objectstore bucket, need to be configured in secrets."
}

output "cdn_domain_name" {
  value       = module.cdn.cdn_domain_name
  description = "The domain name of CDN needed to be configured in Converged Cloud DNS resolving"
}
```


