# Install EKS with terraform

* EKS VPC `vpc.tf` (`aws_vpc`, `aws_internet_gateway`)
* EKS `public_subnet.tf`(`aws_subnet`, `aws_route_table`, `aws_route_table_association)`
* EKS `nat_gatway.tf`(`aws_eip`,`aws_nat_gateway`)
* EKS `prviate_subnet.tf`(`aws_subnet`,`aws_route_table`,`aws_route_table_association`)	
* EKS `node_subnet.tf` (`aws_subnet`,`node_subnet_route`)
* EKS `security_group.tf`(`aws_security_group`,`aws_security_group_rule`)
* `iam.tf`(`aws_iam_role`,`aws_iam_role_policy_attachment`,`aws_iam_policy_document`,`aws_iam_policy`)
* `eks.tf`
	* `aws_eks_cluster`
	* `data "aws_ami"`
	* `aws_launch_configuration`
	* `aws_autoscaling_group`
	* `depends_on` 

## Main directory (main module)

### `main.tf` for EKS

```
...
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


### `var.tf` for EKS

```
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
```

## EKS Module


### EKS VPC `vpc.tf`


* [`aws_vpc`](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [`aws_internet_gateway`](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)

```
resource "aws_vpc" "vpc" {
  cidr_block           = "10.250.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-vpc"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.JAM_INSTANCE}-igw"
  }
}
```

* `cidr_block` - (Required) The CIDR block for the VPC.
* **`enable_dns_support`** - (Optional) A boolean flag to enable/disable DNS support in the VPC. **Defaults true**.
* `enable_dns_hostnames` - (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. **Defaults false**.
* `"kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"`


`vpc_id` - (Required) The VPC ID to create in.


### `public_subnet.tf`

*  [`aws_subnet`](https://www.terraform.io/docs/providers/aws/r/subnet.html)
*  [`aws_route_table`](https://www.terraform.io/docs/providers/aws/r/route_table.html): Provides a resource to create a VPC routing table.
*  [`aws_route_table_association`](https://www.terraform.io/docs/providers/aws/r/route_table_association.html): Provides a resource to create an **association between a route table and a subnet** or **a route table and an internet gateway or virtual private gateway**.



```
resource "aws_subnet" "public" {
  count = min(3, length(var.availability_zones.names))

  availability_zone = "${var.availability_zones.names[count.index]}"
  cidr_block        = "10.250.96.${count.index * 64}/26"
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-public-z${count.index}"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
    "kubernetes.io/role/elb"                    = 1
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-public"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }
}

resource "aws_route_table_association" "public_subnet_route" {
  count = length(aws_subnet.public)

  subnet_id      = "${aws_subnet.public[count.index].id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}
```

#### `aws_subnet`

* `count = min(3, length(var.availability_zones.names))`
* `availability_zone` (Optional) The AZ for the subnet.
* `cidr_block`: (Required) The CIDR block for the subnet.
* `"kubernetes.io/role/elb"  = 1`:  Public Subnet Tagging Option for External Load Balancers

#### `aws_route_table`

* `vpc_id` - (Required) The VPC ID.
* `route` - (Optional) A list of route objects.
	* `cidr_block` - (Required) The CIDR block of the route.
	* `gateway_id` - (Optional) Identifier of a VPC internet gateway or a virtual private gateway.

#### public subnet `route => igw`

```
gateway_id = "${aws_internet_gateway.igw.id}"
```

#### `aws_route_table_association`: `subnet_id`+`route_table_id`

*  `count = length(aws_subnet.public)`
*  `subnet_id` - (Optional) The subnet ID to create an association. Conflicts with `gateway_id`.
*  `route_table_id` - (Required) The ID of the routing table to associate with.

### `nat_gatway.tf`

* [`aws_eip`](https://www.terraform.io/docs/providers/aws/r/eip.html#vpc): Provides an Elastic IP resource.
* [`aws_nat_gateway`](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html): Provides a resource to create a VPC NAT Gateway.

```
resource "aws_eip" "eip" {
  count = length(aws_subnet.public)

  vpc = true
  tags = {
    Name                                        = "${var.JAM_INSTANCE}-${var.availability_zones.names[count.index]}"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "gw" {
  count = length(aws_subnet.public)

  allocation_id = "${aws_eip.eip[count.index].id}"
  subnet_id     = "${aws_subnet.public[count.index].id}"

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-natgw-z${count.index}"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }
}
```

* `vpc = true`: Boolean if the EIP is in a VPC or not.
* `depends_on = ["aws_internet_gateway.igw"]`: eip depends on IGW

#### `aws_nat_gateway`

* `allocation_id` - (Required) The Allocation ID of the **Elastic IP address for the gateway**.
* `subnet_id` - (Required) The Subnet ID of the subnet in which to place the gateway.


### `private_subnet.tf`


```
resource "aws_subnet" "private" {
  count = min(3, length(var.availability_zones.names))

  availability_zone = "${var.availability_zones.names[count.index]}"
  cidr_block        = "10.250.112.${count.index * 64}/26"
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-private-z${count.index}"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
    "kubernetes.io/role/internal-elb"           = "use"
  }
}

resource "aws_route_table" "private_route_table" {
  count = length(aws_subnet.private)

  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw[count.index].id}"
  }

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-private-${var.availability_zones.names[count.index]}"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }
}

resource "aws_route_table_association" "private_subnet_route" {
  count = length(aws_subnet.private)

  subnet_id      = "${aws_subnet.private[count.index].id}"
  route_table_id = "${aws_route_table.private_route_table[count.index].id}"
}
```

* `cidr_block  = "10.250.112.${count.index * 64}/26"`
* `"kubernetes.io/role/internal-elb" = "use"`: Private Subnet Tagging Requirement for Internal Load Balancers

#### Different between private and public (route => nat-gateway)

```
nat_gateway_id = "${aws_nat_gateway.gw[count.index].id}"
```

* `nat_gateway_id` - (Optional) Identifier of a VPC NAT gateway.



### `node_subnet.tf`

```
resource "aws_subnet" "node" {
  count = min(3, length(var.availability_zones.names))

  availability_zone = "${var.availability_zones.names[count.index]}"
  cidr_block        = "10.250.0.${count.index * 64}/26"
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-node-z${count.index}"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }
}

resource "aws_route_table_association" "node_subnet_route" {
  count = length(aws_subnet.node)

  subnet_id      = "${aws_subnet.node[count.index].id}"
  route_table_id = "${aws_route_table.private_route_table[count.index].id}"
}
```

### `security_group.tf`

*  [`aws_security_group`](https://www.terraform.io/docs/providers/aws/r/security_group.html)Provides a security group resource.
*  [`aws_security_group_rule`](https://www.terraform.io/docs/providers/aws/r/security_group_rule.html): Provides a security group rule resource. Represents a single `ingress` or `egress` group rule, which can be added to external Security Groups.

```
resource "aws_security_group" "master-cluster" {
  name        = "${var.JAM_INSTANCE}-master"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.JAM_INSTANCE}-master"
  }
}

resource "aws_security_group" "security_group" {
  name        = "${var.JAM_INSTANCE}-nodes"
  description = "Security group for nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    cidr_blocks = concat(
      ["0.0.0.0/0"],
      aws_subnet.node.*.cidr_block,
      aws_subnet.public.*.cidr_block,
      aws_subnet.private.*.cidr_block
    )
  }

  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "udp"
    cidr_blocks = concat(
      ["0.0.0.0/0"],
      aws_subnet.node.*.cidr_block,
      aws_subnet.public.*.cidr_block,
      aws_subnet.private.*.cidr_block
    )
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.master-cluster.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.JAM_INSTANCE}-nodes"
    "kubernetes.io/cluster/${var.JAM_INSTANCE}" = "1"
  }
}


# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "master-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.master-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.master-cluster.id
  source_security_group_id = aws_security_group.security_group.id
  to_port                  = 443
  type                     = "ingress"
}
```

#### `master-cluster`

`egress` - (Optional, VPC only) Can be specified multiple times for each egress rule

```
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

#### Nodes `security_group`

`concat` Function

```
concat(["a", ""], ["b", "c"])
[
  "a",
  "",
  "b",
  "c",
]
```
```
cidr_blocks = concat(
  ["0.0.0.0/0"],
  aws_subnet.node.*.cidr_block,
  aws_subnet.public.*.cidr_block,
  aws_subnet.private.*.cidr_block
)
```

* `self` - (Optional) If true, the security group itself will be added as a source to this ingress rule.
* `security_groups = ["${aws_security_group.master-cluster.id}"]`:(Optional) List of security group Group Names if using EC2-Classic, or Group IDs if using a VPC.


#### Allow workstation to communicate with the cluster

```
resource "aws_security_group_rule" "master-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.master-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
```

#### Allow pods to communicate with the cluster API Server

```
resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.master-cluster.id
  source_security_group_id = aws_security_group.security_group.id
  to_port                  = 443
  type                     = "ingress"
}
```

### `iam.tf`


[`aws_iam_policy_document`](https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html)

Generates an IAM policy document in JSON format.


```
resource "aws_iam_role" "eks-iam" {
  name = "${var.JAM_INSTANCE}-eks-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-iam-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-iam.name}"
}

resource "aws_iam_role_policy_attachment" "eks-iam-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-iam.name}"
}

resource "aws_iam_role" "woker-iam" {
  name = "${var.JAM_INSTANCE}-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.woker-iam.name
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.woker-iam.name
}

resource "aws_iam_role_policy_attachment" "node_groups_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.woker-iam.name
}

resource "aws_iam_role_policy_attachment" "node_groups_AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.woker-iam.name
}

resource "aws_iam_instance_profile" "worker_iam_profile" {
  name = "${var.JAM_INSTANCE}-profile"
  role = "${aws_iam_role.woker-iam.name}"
}

data "aws_iam_policy_document" "eks-admin-assume-role" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.cluster_admin_arns
    }
  }
}

resource "aws_iam_role" "eks-admin" {
  name = "${var.JAM_INSTANCE}-eks-admin"

  assume_role_policy = data.aws_iam_policy_document.eks-admin-assume-role.json
}

resource "aws_iam_policy" "cluster_admin_access" {
  name        = "${var.JAM_INSTANCE}ClusterAdminAccess"
  description = "Admin Access for ${var.JAM_INSTANCE}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "eks:DescribeCluster",
      "Effect": "Allow",
      "Resource": "${aws_eks_cluster.eks.arn}"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "eks-admin-policy-attach" {
  role       = "${aws_iam_role.eks-admin.name}"
  policy_arn = "${aws_iam_policy.cluster_admin_access.arn}"
}
```

* `aws_iam_role`: `eks-iam` => `eks-master`
	* `aws_iam_role_policy_attachment`: `AmazonEKSClusterPolicy`,`AmazonEKSServicePolicy`
* `aws_iam_role`: `worker-iam` = `worker` 
	* `aws_iam_role_policy_attachment`: `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`,`AutoScalingFullAccess`
* `aws_iam_instance_profile`: `Provides an IAM instance profile.`
* `aws_iam_policy_document`: `eks-admin-assume-role`
* `aws_iam_role`: `eks-admin` => `eks-admin`
	* `data.aws_iam_policy_document`
	*  `"aws_iam_policy" "cluster_admin_access"` 
	*  `"aws_iam_role_policy_attachment" "eks-admin-policy-attach" `



## `eks.tf`

* [`aws_eks_cluster`](https://www.terraform.io/docs/providers/aws/r/eks_cluster.html)
* [`Data Source: aws_ami`](https://www.terraform.io/docs/providers/aws/d/ami.html)
* [Local Values](https://www.terraform.io/docs/configuration/locals.html)
* [Resource: `aws_launch_configuration`](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)
* [Resource: `aws_autoscaling_group`](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)

```
resource "aws_eks_cluster" "eks" {
  name     = "${var.JAM_INSTANCE}"
  role_arn = "${aws_iam_role.eks-iam.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.master-cluster.id}"]
    subnet_ids         = aws_subnet.node.*.id
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-iam-cluster-policy",
    "aws_iam_role_policy_attachment.eks-iam-service-policy",
  ]
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority[0].data}' '${var.JAM_INSTANCE}'
USERDATA

}

resource "aws_launch_configuration" "worker" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.worker_iam_profile.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m5.4xlarge"
  name_prefix                 = "${var.JAM_INSTANCE}"
  security_groups             = [aws_security_group.security_group.id]
  user_data_base64            = base64encode(local.node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  desired_capacity     = var.target_worker_count
  launch_configuration = aws_launch_configuration.worker.id
  max_size             = var.max_worker_count
  min_size             = var.min_worker_count
  name                 = "${var.JAM_INSTANCE}-asg"
  vpc_zone_identifier  = aws_subnet.node.*.id
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.JAM_INSTANCE}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.JAM_INSTANCE}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.JAM_INSTANCE}"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_groups_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_groups_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_groups_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_groups_AutoScalingFullAccess,
  ]
}
```

### `aws_eks_cluster`

```
resource "aws_eks_cluster" "eks" {
  name     = "${var.JAM_INSTANCE}"
  role_arn = "${aws_iam_role.eks-iam.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.master-cluster.id}"]
    subnet_ids         = aws_subnet.node.*.id
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-iam-cluster-policy",
    "aws_iam_role_policy_attachment.eks-iam-service-policy",
  ]
}
```

* `role_arn`: `eks-master`
* `vpc_config` : (Required) Nested argument for the VPC associated with your cluster. Amazon EKS VPC resources have specific requirements to work properly with Kubernetes.
	* `security_group_ids` – (Optional) List of security group IDs for the cross-account elastic network interfaces that Amazon EKS creates to use to allow communication between your worker nodes and the Kubernetes control plane.
	* `subnet_ids `– (Required) **List of subnet IDs.** Must be in at least two different availability zones. Amazon EKS creates cross-account elastic network interfaces in these subnets to allow communication between your worker nodes and the Kubernetes control plane.



* `depends_on`: 
	* `"aws_iam_role_policy_attachment.eks-iam-cluster-policy`
	* `aws_iam_role_policy_attachment.eks-iam-service-policy`


* `data "aws_ami" "eks-worker"`

```
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}
```

```
locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority[0].data}' '${var.JAM_INSTANCE}'
USERDATA

}
```

### `aws_launch_configuration`

* `associate_public_ip_address = false` - (Optional) Associate a public ip address with an instance in a VPC.
* `iam_instance_profile = aws_iam_instance_profile.worker_iam_profile.name` :  (Optional) The name attribute of the IAM instance profile to associate with launched instances.
* `image_id  = data.aws_ami.eks-worker.id`:  (Required) The EC2 image ID to launch.
* `instance_type = "m5.4xlarge"`: (Optional) The name attribute of the IAM instance profile to associate with launched instances.
* `user_data_base64  = base64encode(local.node-userdata)`: (Optional) Can be used instead of `user_data` to pass `base64-encoded` binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, `gzip-encoded` user data must be `base64-encoded` and passed via this argument to avoid corruption.

```
lifecycle {
    create_before_destroy = true
  }
```

### `aws_autoscaling_group`

```
tag {
    key                 = "Name"
    value               = "${var.JAM_INSTANCE}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.JAM_INSTANCE}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.JAM_INSTANCE}"
    value               = "owned"
    propagate_at_launch = true
  }
```

`propagate_at_launch = true` - (Required) Enables propagation of the tag to Amazon EC2 instances launched via this ASG

### `depends_on`

* `node_groups_AmazonEKSWorkerNodePolicy`
* `node_groups_AmazonEKS_CNI_Policy`
* `node_groups_AmazonEC2ContainerRegistryReadOnly`
* `node_groups_AutoScalingFullAccess`