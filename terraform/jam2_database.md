# Jam AWS Database (RDS-Mysql)

## `main.tf`

### RDS Subnet and Subnet group

```
resource "aws_subnet" "subnet1" {
  vpc_id            = "${var.VPC_ID}"
  cidr_block        = "10.250.64.0/19"
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.JAM_INSTANCE}-1a"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id            = "${var.VPC_ID}"
  cidr_block        = "10.250.128.0/19"
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.JAM_INSTANCE}-1b"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.JAM_INSTANCE}"
  subnet_ids = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
}
```




#### Argument Reference:


**`resource "aws_subnet"  "subnet_name"`**

* `vpc_id` (Required) The VPC ID.
* `cidr_block`  (Required) The CIDR block for the subnet.
* `availability_zone` (Optional) The AZ for the subnet.
* `tags` (Optional) A mapping of tags to assign to the resource.


#### Import

```
terraform import aws_subnet.public_subnet subnet-9d4a7b6c
```


**`resource "aws_db_subnet_group" "db_subnet_group"`**

* `name`:  (Optional, Forces new resource) The name of the DB subnet group. If omitted, Terraform will assign a random, unique name.
* `subnet_ids`: (Required) A list of VPC subnet IDs.



### RDS Security Group

[`aws_security_group`](https://www.terraform.io/docs/providers/aws/r/security_group.html)

```
resource "aws_security_group" "security-group" {
  name        = "${var.JAM_INSTANCE}"
  description = "${var.JAM_INSTANCE}"
  vpc_id      = "${var.VPC_ID}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.GARDENER_SG_ID}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

* `name` - (Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name
* `description` - (Optional, Forces new resource) The security group description. Defaults to "Managed by Terraform". Cannot be "". NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags.
* `vpc_id` - (Optional, Forces new resource) The VPC ID.

* `ingress` - (Optional) **Can be specified multiple times for each ingress rule**. Each ingress block supports fields documented below.   
	* `from_port` - (Required) The start port (or ICMP type number if protocol is "icmp")
  * `to_port` - (Required) The end range port (or ICMP code if protocol is "icmp").
  * `protocol` - (Required) The protocol. If you select a protocol of `"-1"` (semantically equivalent to "`all`", which is not a valid value here), you must specify a "from_port" and "to_port" equal to `0`. If not icmp, tcp, udp, or `"-1"` use the protocol number
  * `security_groups` - (Optional) List of security group Group Names if using EC2-Classic, or Group IDs if using a VPC.


* `egress` - (Optional, VPC only) Can be specified multiple times for each egress rule. Each egress block supports fields documented below.
  * `from_port` - (Required) The start port (or ICMP type number if protocol is "icmp") 
  * `to_port` - (Required) The end range port (or ICMP code if protocol is "icmp").
  * `protocol` - (Required) The protocol. If you select a protocol of "-1" (semantically equivalent to "all", which is not a valid value here), you must specify a "from_port" and "to_port" equal to `0`. If not icmp, tcp, udp, or `"-1"` use the protocol number
  * `cidr_blocks` - (Optional) List of CIDR blocks.



## RDS 

```
resource "aws_db_instance" "db" {
  name                      = "${var.JAM_INSTANCE}".     # db_name
  identifier                = "${var.JAM_INSTANCE}-db".  # db_instance_identifier
  allocated_storage         = 100
  instance_class            = "db.m5.large"              # db_instance_class
  engine                    = "mysql"
  availability_zone         = "${var.region}a"       
  username                  = "jam"                      # master_username
  password                  = "${var.ADMIN_PASSWORD}"
  multi_az                  = false
  engine_version            = "5.7.22"
  publicly_accessible       = false
  db_subnet_group_name      = "${aws_db_subnet_group.db_subnet_group.name}"
  vpc_security_group_ids    = ["${aws_security_group.security-group.id}"]
  final_snapshot_identifier = "${var.JAM_INSTANCE}-snapshot"
}
```

**[Data Source: aws_db_instance](https://www.terraform.io/docs/providers/aws/d/db_instance.html)**

* `name` - (Optional) The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance. Note that this does not apply for Oracle or SQL Server engines. 
* `identifier` - (Optional, Forces new resource) The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier.
* `allocated_storage` - Specifies the allocated storage size specified in gigabytes.
* `instance_class` - (Required) The instance type of the RDS instance.
* `engine` - The database engine.
* `availability_zone` - (Optional) The AZ for the RDS instance.
* `username` - The master username for the database.
* `password` - (Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file.
* `multi_az` - (Optional) Specifies if the RDS instance is multi-AZ
* `engine_version` - (Optional) The engine version to use. If auto_minor_version_upgrade is enabled, you can provide a prefix of the version such as 5.7 (for 5.7.10) and this attribute will ignore differences in the patch version automatically (e.g. 5.7.17).
* `publicly_accessible` - (Optional) Bool to control if instance is publicly accessible. Default is false.
* `db_subnet_group_name` - (Optional) Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC, or in EC2 Classic, if available. When working with read replicas, it should be specified only if the source database specifies an instance in another AWS Region
* `vpc_security_group_ids` - (Optional) List of VPC security groups to associate.
* `final_snapshot_identifier` - (Optional) The name of your final DB snapshot when this DB instance is deleted. Must be provided if `skip_final_snapshot` is set to `false`.
* `skip_final_snapshot `- (Optional) Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from `final_snapshot_identifier`. Default is `false.`

### Variables

```
resource "aws_subnet" "subnet1" {
  vpc_id            = "${var.VPC_ID}"
  cidr_block        = "10.250.64.0/19"
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.JAM_INSTANCE}-1a"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id            = "${var.VPC_ID}"
  cidr_block        = "10.250.128.0/19"
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.JAM_INSTANCE}-1b"
  }
}

resource "aws_security_group" "security-group" {
  name        = "${var.JAM_INSTANCE}"
  description = "${var.JAM_INSTANCE}"
  vpc_id      = "${var.VPC_ID}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.GARDENER_SG_ID}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.JAM_INSTANCE}"
  subnet_ids = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"] 
}

resource "aws_db_instance" "db" {
  name                      = "${var.JAM_INSTANCE}"
  identifier                = "${var.JAM_INSTANCE}-db"
  allocated_storage         = 100
  instance_class            = "db.m5.large"
  engine                    = "mysql"
  availability_zone         = "${var.region}a"
  username                  = "jam"
  password                  = "${var.ADMIN_PASSWORD}"
  multi_az                  = false
  engine_version            = "5.7.22"
  publicly_accessible       = false
  db_subnet_group_name      = "${aws_db_subnet_group.db_subnet_group.name}"
  vpc_security_group_ids    = ["${aws_security_group.security-group.id}"]
  final_snapshot_identifier = "${var.JAM_INSTANCE}-snapshot"
}
```

* `subnet_ids = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]`
* `db_subnet_group_name      = "${aws_db_subnet_group.db_subnet_group.name}"`
* `vpc_security_group_ids    = ["${aws_security_group.security-group.id}"]`


## `var.tf`

```
variable "JAM_INSTANCE" {}
variable "VPC_ID" {}
variable "ADMIN_PASSWORD" {}
variable "GARDENER_SG_ID" {}
variable "region" {}
```

## `output.tf`

In addition to all arguments above, the following attributes are exported:

```
output "mysql_hostname" {
  value = "${aws_db_instance.db.address}"
}
```

* `address` - The hostname of the RDS instance. See also `endpoint` and `port`.


```
terraform apply  --target=module.database


$ terraform apply  --target=module.database
var.route_table_ids
  Enter a value: []

module.database.aws_subnet.subnet2: Refreshing state... [id=subnet-0cc65c343076d425f]
module.database.aws_subnet.subnet1: Refreshing state... [id=subnet-050d5f791313e4923]
module.database.aws_security_group.security-group: Refreshing state... [id=sg-0de27eced693faed0]
module.database.aws_db_subnet_group.db_subnet_group: Refreshing state... [id=integration702]
module.database.aws_db_instance.db: Refreshing state... [id=integration702-db]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.database.aws_db_instance.db will be updated in-place
  ~ resource "aws_db_instance" "db" {
        address                               = "integration702-db.cxqgj1loe4x0.eu-central-1.rds.amazonaws.com"
        allocated_storage                     = 100
        arn                                   = "arn:aws:rds:eu-central-1:(sensitive value):db:integration702-db"
        auto_minor_version_upgrade            = true
        availability_zone                     = "eu-central-1a"
        backup_retention_period               = 0
        backup_window                         = "00:48-01:18"
        ca_cert_identifier                    = "rds-ca-2015"
        copy_tags_to_snapshot                 = false
        db_subnet_group_name                  = "integration702"
        deletion_protection                   = false
        enabled_cloudwatch_logs_exports       = []
        endpoint                              = "integration702-db.cxqgj1loe4x0.eu-central-1.rds.amazonaws.com:3306"
        engine                                = "mysql"
      ~ engine_version                        = "5.7.26" -> "5.7.22"
      + final_snapshot_identifier             = "integration702-snapshot"
        hosted_zone_id                        = "Z1RLNUO7B9Q6NB"
        iam_database_authentication_enabled   = false
        id                                    = "integration702-db"
        identifier                            = "integration702-db"
        instance_class                        = "db.m5.large"
        iops                                  = 0
        license_model                         = "general-public-license"
        maintenance_window                    = "mon:21:27-mon:21:57"
        max_allocated_storage                 = 0
        monitoring_interval                   = 0
        multi_az                              = false
        name                                  = "integration702"
        option_group_name                     = "default:mysql-5-7"
        parameter_group_name                  = "default.mysql5.7"
        password                              = (sensitive value)
        performance_insights_enabled          = false
        performance_insights_retention_period = 0
        port                                  = 3306
        publicly_accessible                   = false
        replicas                              = []
        resource_id                           = "db-(sensitive value)"
        security_group_names                  = []
      ~ skip_final_snapshot                   = true -> false
        status                                = "available"
        storage_encrypted                     = false
        storage_type                          = "gp2"
        tags                                  = {}
        username                              = "jam"
        vpc_security_group_ids                = [
            "sg-0de27eced693faed0",
        ]
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: no

Apply cancelled.
```


## `main.tf` updated


Since some AWS region includes **constrained** AZ(`apne1-az3`), which cannot be used to launch instance 

> As Availability Zones grow over time, our ability to expand them can become constrained. If this happens, we might restrict you from launching an instance in a constrained Availability Zone unless you already have an instance in that Availability Zone. Eventually, we might also remove the constrained Availability Zone from the list of Availability Zones for new accounts. Therefore, your account might have a different number of available Availability Zones in a Region than another account"


```
data "aws_availability_zones" "available" {
  state = "available"
  blacklisted_zone_ids = ["apne1-az3"]
}

resource "aws_subnet" "dbsubnet" {
  count = min(2, length(data.aws_availability_zones.available.names))

  vpc_id            = "${var.VPC_ID}"
  cidr_block        = "10.250.${(count.index + 1) * 64}.0/19"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  tags = {
    Name = "${var.JAM_INSTANCE}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_security_group" "security-group" {
  name        = "${var.JAM_INSTANCE}"
  description = "${var.JAM_INSTANCE}"
  vpc_id      = "${var.VPC_ID}"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.GARDENER_SG_ID}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.JAM_INSTANCE}"
  subnet_ids = aws_subnet.dbsubnet.*.id
}

resource "aws_db_instance" "db" {
  name                      = "${var.JAM_INSTANCE}"
  identifier                = "${var.JAM_INSTANCE}-db"
  allocated_storage         = 100
  instance_class            = "db.m5.large"
  engine                    = "mysql"
  availability_zone         = data.aws_availability_zones.available.names[0]
  username                  = "jam"
  password                  = "${var.ADMIN_PASSWORD}"
  multi_az                  = false
  engine_version            = "5.7.22"
  publicly_accessible       = false
  db_subnet_group_name      = "${aws_db_subnet_group.db_subnet_group.name}"
  vpc_security_group_ids    = ["${aws_security_group.security-group.id}"]
  final_snapshot_identifier = "${var.JAM_INSTANCE}-snapshot"
}
```

```

data "aws_availability_zones" "available" {
  state = "available"
  blacklisted_zone_ids = ["apne1-az3"]
}
```

## Data Sources

Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration. Use of data sources allows a Terraform configuration to make use of information defined outside of Terraform, or defined by another separate Terraform configuration.

```
resource "aws_subnet" "dbsubnet" {
  count = min(2, length(data.aws_availability_zones.available.names))

  vpc_id            = "${var.VPC_ID}"
  cidr_block        = "10.250.${(count.index + 1) * 64}.0/19"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  tags = {
    Name = "${var.JAM_INSTANCE}-${data.aws_availability_zones.available.names[count.index]}"
  }
}
```

*  `"10.250.${(count.index + 1) * 64}.0/19"`: `"10.250.64.0/19"`
* `availability_zone = "${data.aws_availability_zones.available.names[count.index]}"`
* `availability_zone = "eu-central-1a"`
*  `availability_zone = "eu-central-1b"`


```
tags = {
	"Name" = "integration702-eu-central-1a"
}

tags = {
   "Name" = "integration702-eu-central-1b"
}
```
        
```
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.JAM_INSTANCE}"
  subnet_ids = aws_subnet.dbsubnet.*.id
}
```        
        

```
availability_zone = data.aws_availability_zones.available.names[0]
```














