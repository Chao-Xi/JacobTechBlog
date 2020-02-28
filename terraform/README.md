# Learning Terraform

![Alt Image Text](images/0_1.png "Body image")

### 1.Introduction and Setting up Terraform

1. [Terraform Introduction](1Introduction.md)
2. [Setting up Terraform](2SetupTerraform.md)


### 2. Building Your Ecosystem

1. [Build Ecosystem one (Add aws subnet and Azure subnet)](3BuildEcosystem1.md)
2. [Build Ecosystem two (Add gcp subnet, instance, k8s cluster and aws instance)](3BuildEcosystem2.md)


### 3. Terraform syntax deep dive

1. [Terraform Cli command](4TerraformCli.md)
2. [Terraform Variables(variables, output and input variables)](5TerraformVar.md)



### 4. Terraform best practice

1. [Patterns and practices](6Patterns_practices.md)
2. [Workflow](7Workflow.md)
3. [Project practices, Debugging and testing](8Proj_practice.md)


### 5. Extending Terraform with plugins

1. [Customizing and Extending Terraform](9Customizing_Extending_Terraform.md)


## Jam Terraform

* [0. JAM Terraform S3 Backend with dynamodb](jam0_terraform_backend.md)
* [1. Terraform Data Sources](jam1_terraform_Dataresource.md)
* [2. Jam Terraform Projects](jam1_terraform_modules.md)
	* Module 让 Terraform 使用更简单
	* Terraform Variable
* [3. Jam AWS Database (RDS-Mysql)](jam2_database.md)
* [3. AWS DB Monitoring, logs output and Alerts](jam2_db_monitoring_and_logs.md)
* [4. Jam AWS Object Store (S3 Bucket)](jam3_s3bucket.md)
* [5. Jam AWS ACM Certiftcate and DNS](jam4_acm_certificate.md)
* [6. Jam AWS Cloud Distribution](jam5_cloudfront_cdn.md)
* [7. Jam `Force_MFA` IAM user group](jam6_mfa_iam_group.md)
* [8. Jam Cloudtrail IAM user group (Using Workspaces)](jam7_aws_cloudtrial.md)
* [9. 5 things you need to know to add worker nodes in the AWS EKS cluster](jam_aws_eks1.md)
* [10. Install EKS with terraform](jam_aws_eks2.md)
	* `vpc.tf` (`aws_vpc`, `aws_internet_gateway`)
	* `public_subnet.tf`(`aws_subnet`, `aws_route_table`, `aws_route_table_association)`
	* `nat_gatway.tf`(`aws_eip`,`aws_nat_gateway`)
	* `prviate_subnet.tf`(`aws_subnet`,`aws_route_table`,`aws_route_table_association`)
	* `node_subnet.tf` (`aws_subnet`,`node_subnet_route`)
	* `security_group.tf`(`aws_security_group`,`aws_security_group_rule`) 
	* `iam.tf`
		* `aws_iam_role`,
		* `aws_iam_role_policy_attachment`,
		* `aws_iam_policy_document`,
		* `aws_iam_policy`
	* `eks.tf`
		* `aws_eks_cluster`
		* `data "aws_ami"`
		* `aws_launch_configuration`
		* `aws_autoscaling_group`
		* `depends_on` 

