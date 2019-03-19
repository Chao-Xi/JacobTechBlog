# Project practices, Debugging and testing


### 1.`variables.tf`

```
variable "vpc_name" {
  description = "The name of the VPC network."
}

variable "s3_terraform_bucket" {}

variable "environment" {}
variable "region" {}

variable "availability_zones" {
  type = "map"

  default = {
    zone1 = "us-west-2a"
    zone2 = "us-west-2b"
    zone3 = "us-west-2c"
  }
}

variable "cidrblock" {
  default = "10.0.0.0/16"
}

variable "coffee_type" { 
	default = "nothing" 
	description = "Identifying what coffee level the appication needs." 
} 
```


### 2.`starter.tfvars` can call the variable from `terraform.tfvars` 

**`terraform.tfvars`**

```
vpc_name = "newvpc"
s3_terraform_bucket = "terraformbucket"
environment = "env"
region = "us-west-2"

coffee_type = "dark"
```

**`starter.tfvars`**

```
vpc_name = "newvpc"
s3_terraform_bucket = "terraformbucket"
environment = "env"
region = "us-west-2"

coffee_type = "${ver.coffee_type}"
```

### 3.`instances.tf` 

```
data "aws_ami" "ubuntu" { 
	most_recent = true 
	
	fitter { 
		name = "name" 
		values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
	} 

	filter { 
		name = "virtualization-type" 
		values = ["hvm"] 
	} 
	
	owners = ["099720109477"]
} 

resource "aws_instance" "newest_web_server" { 
	ami 			 = "${data.aws_ami.ubuntu.id}" 
	instance_type = "t2.micro" 
	
	tags { 
		name = "Our favorite server"
	} 
   
   subnet_id = "${aws_subnet.subnet2.id}"
} 
```

* `$ terraform validate`
* `$ terraform fmt`
* `$ terraform plan`
* `$ terraform apply`

##### `starter.sh`

```
#!/usr/bin/env bash

terraform fmt

terraform plan -var-file="starter.tfvars"

echo "yes" | terraform apply -var-file="starter.tfvars"
```


## Debugging and testing

```
$ vi ~/.bashrc

export TF_LOG = TRACE

$ source ~/.bashrc

$ terraform apply
```






