# Terraform Data Sources

* `data.tf`
	* Data Source: `aws_availability_zones`
	* Data Source: `"aws_caller_identity"`
	* Data Source: `aws_vpc`
	* Data Source: `aws_subnet`
	* Data Source: `aws_route_table`
	* Data Source: `aws_security_group`
* **Local Values**
* **Conditional Expressions**

`Data sources` allow data to be fetched or computed for use elsewhere in Terraform configuration. 

**Use of data sources allows a Terraform configuration to make use of information defined outside of Terraform, or defined by another separate Terraform configuration.**

## `data.tf`

```
data "aws_availability_zones" "available" {
  state                = "available"
  blacklisted_zone_ids = ["apne1-az3"]
}

data "aws_caller_identity" "current" {}

locals {
  cluster_name = var.gardener_namespace == null ? var.JAM_INSTANCE : "shoot--${var.gardener_namespace}--${var.JAM_INSTANCE}"
}


data "aws_vpc" "vpc" {
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
  }
}

data "aws_subnet" "private_subnet" {
  count             = min(3, length(data.aws_availability_zones.available.names))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
    "kubernetes.io/role/internal-elb"             = "use"
  }
}

data "aws_route_table" "private_route" {
  count = min(3, length(data.aws_availability_zones.available.names))

  subnet_id = data.aws_subnet.private_subnet[count.index].id
}

data "aws_security_group" "node" {
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
  }
}
```

## Data Source: `aws_availability_zones`

```
data "aws_availability_zones" "available" {
  state                = "available"
  blacklisted_zone_ids = ["apne1-az3"]
}
```

The Availability Zones data source allows access to the list of AWS Availability Zones which can be accessed by an AWS account within the region configured in the provider.

This is different from the `aws_availability_zone` (singular) data source, which provides some details about a specific availability zone.

* `blacklisted_names` - (Optional) List of blacklisted Availability Zone names.
* `stat` - (Optional) Allows to filter list of Availability Zones based on their current state. Can be either `"available"`, `"information"`, `"impaired"` or `"unavailable"`. 

By default the list includes a complete set of Availability Zones to which the underlying AWS account has access, regardless of their state.

### Attributes Reference

* `names` - A list of the Availability Zone names available to the account.
* `zone_ids` - A list of the Availability Zone IDs available to the account.

## Data Source: `"aws_caller_identity"`

Use this data source to get the access to the effective Account ID, User ID, and ARN in which Terraform is authorized.

```
data "aws_caller_identity" "current" {}
```

### Example 

```
data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}
```


## Local Values

A local value assigns a name to an expression, allowing it to be used multiple times within a module without repeating it.

```
locals {
  cluster_name = var.gardener_namespace == null ? var.JAM_INSTANCE : "shoot--${var.gardener_namespace}--${var.JAM_INSTANCE}"
}
```

### Declaring a Local Value

**For example**

[Local Values](https://www.terraform.io/docs/configuration/locals.html)

```
locals {
  service_name = "forum"
  owner        = "Community Team"
}
```

```
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
```

```
resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}
```

## Conditional Expressions

```
cluster_name = var.gardener_namespace == null ? var.JAM_INSTANCE : "shoot--${var.gardener_namespace}--${var.JAM_INSTANCE}"
```

[A conditional expression uses the value of a bool expression to select one of two values.](https://www.terraform.io/docs/configuration/expressions.html#conditional-expressions)

A `conditional expression` uses the value of a bool expression to select one of two values.

The syntax of a conditional expression is as follows:

```
condition ? true_val : false_val
```

If `condition` is `true` then the result is `true_val`. If `condition` is `false` then the result is `false_val`.

A common use of conditional expressions is to define defaults to replace invalid values:

```
var.a != "" ? var.a : "default-a"
```

If `var.a` is an `empty string` then the result is `"default-a"`, but otherwise it is the actual value of `var.a`.


## Data Source: `aws_vpc`

`aws_vpc` provides details about a specific VPC.

This resource can prove useful when a module accepts a vpc id as an input variable and needs to, for example, determine the CIDR block of that VPC.

```
data "aws_vpc" "vpc" {
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
  }
}
```

`tags` - (Optional) A mapping of tags, each pair of which must exactly match a pair on the desired VPC.

More complex filters can be expressed using one or more `filter` sub-blocks, which take the following arguments:


## Data Source: `aws_subnet`

[Data Source: aws_subnet](https://www.terraform.io/docs/providers/aws/d/subnet.html)

`aws_subnet` provides details about a specific VPC subnet.

This resource can prove useful when a module accepts a subnet id as an input variable and needs to, for example, determine the id of the VPC that the subnet belongs to.

```
data "aws_subnet" "private_subnet" {
  count             = min(3, length(data.aws_availability_zones.available.names))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
    "kubernetes.io/role/internal-elb"             = "use"
  }
}
```

*  `count = min(3, length(data.aws_availability_zones.available.names))`
*  `length(data.aws_availability_zones.available.names))`
*  `availability_zone = data.aws_availability_zones.available.names[count.index]`



### Example

```
# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

# e.g. Create subnets in the first two available availability zones

resource "aws_subnet" "primary" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  # ...
}

resource "aws_subnet" "secondary" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  # ...
}
```

## Data Source:`aws_route_table`

[`aws_route_table` provides details about a specific Route Table.](https://www.terraform.io/docs/providers/aws/d/route_table.html)

This resource can prove useful when a module accepts a Subnet id as an input variable and needs to, for example, add a route in the Route Table.


```
data "aws_route_table" "private_route" {
  count = min(3, length(data.aws_availability_zones.available.names))

  subnet_id = data.aws_subnet.private_subnet[count.index].id
}
```

* `data.aws_subnet.private_subnet[count.index].id`
* `subnet_id` - (Optional) The id of a Subnet which is connected to the Route Table (not exported if not passed as a parameter).

## Data Source:`aws_security_group`

[`aws_security_group` provides details about a specific Security Group](https://www.terraform.io/docs/providers/aws/d/security_group.html).

This resource can prove useful when a module accepts a Security Group id as an input variable and needs to, for example, determine the id of the VPC that the security group belongs to.

```
data "aws_security_group" "node" {
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
  }
}
```

* `tags` - (Optional) A mapping of tags, each pair of which must exactly match a pair on the desired security group.


## Tags 

Why Need this tags, [5 things you need to know to add worker nodes in the AWS EKS cluster]()


### `data "aws_vpc"`

```
tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
  }
```

### `data "aws_subnet"`

```
 tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
    "kubernetes.io/role/internal-elb"             = "use"
  }
```

### `data "aws_security_group"`

```
tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "1"
  }
```