# 1. Terraform Introduction

**Terraform is a DevOps tool for declarative infrastructure—infrastructure as code. It simplifies and accelerates the configuration of cloud-based environments.**

In this course, it shows how to use Terraform to deploy resources and set up immutable infrastructure in **Azure**, **Amazon Web Services**, and **Google Cloud Platform**. 

Learn how to deploy **servers**, **virtual machines**, and **clusters**, and understand the nuances of each cloud services platform. 

Discover how to use **Terraform CLI commands** and **string** together Terraform executions with **variables**. Also includes a chapter on patterns, best practices, and workflow steps that will keep your infrastructure and Terraform projects manageable and shows how to extend Terraform with plugins and the HashiCrop open-source tooling suite.

## What you should know

* TCP/IP networking 
* Linux/Unix system commands 
* Scripting language constructs 
* Basic knowledge of Azure, Google Cloud Platform (GCP), and Amazon Web Services (AWS) 
* Cross platform 


## Prerequisite Tooling

### CLI tools and accounts for AWS, GCP, and Azure 

* Azure — `https://docs.microsoft.conn/en-us/cli/azure/install-azure-cli?view=azure-ch-latest` 
* AWS — `https://aws.amazon.com/cli` 
* GCP — `https://cloud.google.com/sdk` 
* GitHub — a GitHub account 

### Example install GCP on Linux

`https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu`


## Terraform vs. comparable tooling

### Terraform

As described on HashiCorp's site, Terraform is an opensource tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

### Ansible

Ansible is a tool that helps provision, deploy, and apply compliance of infrastructure through **configuration management**. Sounds a little similar, right? It was purchased by Red Hat recently, and is offered in their stable of tools.

### Puppet

**Puppet provides discovery, management of infrastructure, and mutable updates and changes to that infrastructure.** The Puppet suite is made up of a number of tools and products, so it's not just one single thing, like with Terraform, where it's a single executable that does all the work for us.

### Chef

Chef is one of the leading companies that helped to start and push the DevOps narrative in the industry. **It's a tool that provides a programmatic DSL, configuration in related ways to create and manage one's infrastructure.** Chef, similarly to Puppet, is also made up of a number of individual tools and products.

### CloudFormation

AWS CloudFormation uses configuration to set up infrastructure through execution and compilation of those configuration file

## Terraform vs Others

Terraform, in comparison to these tools, has some specific notable differences. 

* For one, the **configuration management tools**, like Chef and Puppet, Terraform uses provisioners to set up resources, such as **network, instances, and other things within the cloud platform**. 
* Since Terraform operates at this **higher, abstract level than the other platforms**, it provides a way for Terraform to work alongside or in place of those other tools. It gives it the ability, as a very lightweight executable, to take the place of any of the other ones, or simply work within the pipeline of a Chef automation, or a Puppet automation, of infrastructure. 

###  Terraform vs Cloudformation

In relation to CloudFormation, **the differences start out with cross platform and multi-cloud platform capabilities being a strong point in Terraform and relatively impossible to do multi-cloud in CloudFormation**, because it's a propriety AWS-only infrastructure tool.

