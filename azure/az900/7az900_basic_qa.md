### Economies of scale

The concept of **economies of scale** is the ability to **reduce costs and gain efficiency when operating at a larger scale** in comparison to operating at a smaller scale.

1. Which of the following describes a benefit of cloud services?
	* **Economies of scale**
	* Fixed workloads
	* Unpredictable costs
	* *Economies of scale. Economies of scale is the ability to do things more cheaply and more efficiently when operating at a larger scale in comparison to operating at a smaller scale.*
2. Which of the following refers to spending money upfront and then deducting that expense over time?
	* **Capital expenditure**
	* Operational expenditures  
	* Supply and demand
	* *Capital expenditure. Capital expenditure refers to spending of money on physical infrastructure up front, and then deducting that expense from your tax bill over time.*
 
3. Which of the following refers to making a service available with no downtime for an extended period of time?
	* Agility
	* Fault tolerance
	* **High availability**  
	* Performance
	* *High Availability. High availability keeps services up and running for long periods of time, with very little downtime, depending on the service in question*.
4. Microsoft Office 365 is an example of? 
	* Software as a Service
5. Which cloud model provides the greatest degree of ownership and control?
	* **Private**
	* *Private. The private cloud provides the greatest degree of ownership and control*.
6. Which cloud model provides the greatest degree of flexibility?
	* **Hybrid**
	* *Hybrid. The hybrid cloud model provides the greatest degree of flexibility, as you have the option to choose either public or private depending on your requirements.*
7. Which of the following describes a public cloud?
	* Is owned and operated by the organization that uses the resources from that cloud.
	* Lets organizations run applicatinos in the cloud or on-premises.
	* **Provides resources and services to multiple organizations and users, who connect through a secure network connection**.
	* *The public cloud provides resources and services to multiple organizations and users, who connect through a secure network connection.*
9. Which of the following describes Platform as a Service (PaaS)?
	* Users are responsible for purchasing, installing, configuring, and managing their own software—operating systems, middleware, and applications.
	* **Users create and deploy applications quickly without having to worry about managing the underlying infrastructure.**
	* Users pay an annual or monthly subscription.
	* *Hybrid cloud. A hybrid cloud is a public and private cloud combined. You can run your newer applications on commodity hardware you rent from the public cloud and maintain your specialized mainframe hardware on-premises*.
10. You have legacy applications that require specialized mainframe hardware and you have newer shared applications. Which cloud deployment model would be best for you?
	* Hybrid cloud
11. Which of the following requires the most user management of the cloud services?
	* Infrastructure as a Service


## Core Azure architectural components

### Azure Resource Manager

* Deploy Application resources
* Organize resources
* Control access and resources

### Azure compute services

* **Azure virtual machines**
* **App services**
	* You can quickly build, deploy, and scale enterprise-grade web, mobile, and API apps running on any platform.
	* **App Services is a platform as a service (PaaS)** offering.
* **Azure Functions**: Concerned only about the code running your service and not the underlying platform or infrastructure.

### Container services

* **Azure Container Instances**
* **Azure Kubernetes Service (AKS)**

### Azure network services

* Azure Virtual Network
* Azure Load Balancer: L4/L3
* VPN gateway
* Azure Application Gateway: L7
* Content Delivery Network

### Azure data categories

* Disk storage
* Containers (Blobs)
* Files
* Queues
* **Tables**
	* **The service is a NoSQL datastore**
	* Storing TBs of **structured data** capable of serving web scale applications.
	* **Storing datasets that don't require complex joins, foreign keys**
	* Quickly querying data using a clustered index.

### Azure database services

* Azure Cosmos DB (**Supports schema-less data**)
* Azure SQL Database
* **Azure Database Migration**: is a fully managed service designed to enable seamless migrations from multiple database sources to Azure data platforms with minimal downtime 

### Internet of Things

* **IoT Central**: is a fully managed **global IoT software as a service (SaaS)** solution that makes it easy to connect, monitor, and manage your IoT assets at scale.
* **Azure IoT Hub**: Acts as a central message hub for communication between your **IoT application and the devices it manages**.

### Big Data and Analytics

* **Azure SQL Data Warehouse**: **Leverages MPP to run complex queries quickly across petabytes of data.**
* **Azure HDInsight**: open-source analytics service: Apache Spark, Apache Hadoop supports extraction, transformation, and loading (ETL);
* **Azure Data Lake Analytics**: On-demand analytics job service that simplifies big data.

### Artificial Intelligence

* **Azure Machine Learning Service**: Provides a cloud-based environment you can use to develop, train, test, deploy, manage, and track machine learning models. 
* **Azure Machine Learning Studio**: is a collaborative, drag-and-drop visual workspace where you can build, test, and deploy machine learning solutions without needing to write code.

### Serverless Computing

* Azure Functions
* **Azure Logic Apps**: Automate and orchestrate tasks, business processes, and workflows when you need to integrate apps, data, systems
	* Logic Apps are designed in a web-based designer and can **execute logic triggered by Azure services without writing any code.**
* **Azure Event Grid**:  Allows you to easily build applications with **event-based architectures**.

### DevOps

* **DevOps Services**: provides development collaboration tools including high-performance pipelines, free private Git repositories, configurable Kanban boards
* **Azure Lab Services**: is a service that helps **developers and testers quickly** create environments in Azure, while **minimizing waste and controlling cost**
	* **With DevTest Labs you can scale up your load testing by provisioning multiple test agents and create pre-provisioned environments for training and demos.**  

### Azure Management Tools

* Azure Portal
* Azure PowerShell

> Note: PowerShell Core is a cross-platform version of PowerShell that runs on Windows Linux or macOS.

* Azure Command Line Interface (CLI): `Cross platform` means that it can be run on Windows, Linux, or macOS.
* Azure Cloud Shell: **browser-based scripting environment in your portal**
	* Linux users can opt for a Bash experience,
	* Windows users can opt for PowerShell.
* Azure Mobile App

### Azure Advisor

**Provides recommendations on high availability, security, performance, and cost**


1. Which of the following ensures **data-residency and compliance needs** are met for customers who need to keep their data and applications close?
	* **Geographies**  
	* Regions
	* Zones
	* *Geographies. Geographies allow customers with specific data-residency and compliance needs to keep their data and applications close. Geographies ensure that data residency, sovereignty, compliance, and resiliency requirements are honored within geographical boundaries.*
2. As a best practice, all resources that are part of an application and share the same lifecycle should exist in the same?
	* Availability set  
	* Region
	* **Resource group**
	* *Resource group. For ease of management, resources that are part of an application and share its lifecycle should be placed in the same resource group.*
3. Which Azure compute resource can you use to deploy to manage a set of identical virtual machines?
	* Virtual machine availability sets  
	* Virtual machine availability zones 
	*  **Virtual machine scale sets**
	*  *Virtual machine scale sets. Virtual machine scale sets let you deploy and manage a set of identical virtual machines*.
4. Which of the following should you use when you are concerned only about the code running your service and not the underlying platform or infrastructure?
	* Azure App Service
	* Azure Container Instances  
	* **Azure Functions**
	* *Azure Functions. Azure Functions are ideal when you're concerned only about the code running your service and not the underlying platform or infrastructure.*
5. Azure Resource Manager templates use which format?
	* HTML  
	* **JSON**  
	* XML
	* *JSON. `Resource Manager templates are JSON files` that define the resources you need to deploy for your solution. You can `use template to easily re-create multiple versions` of your infrastructure, such as staging and production.*
6. Which of the following services is a distributed network of servers that can efficiently deliver web content to users?
	 * Azure Content Delivery Network
	 * *Azure Content Delivery Network. A Content Delivery Network is a distributed network of servers that can efficiently deliver web content to users.*
7. Which of the following is optimized for storing massive amounts of unstructured data, such as videos and images?
	* Blobs
	* Azure Machine Learning service. Machine Learning service provides a cloud-based environment that you can use to develop, train, test, deploy, manage, and track machine learning models.
8. Which of the following is part of the Azure Artificial Intelligence service?
	* Azure Machine Learning service
9. Which of the following cloud services provides development collaboration tools including high-performance pipelines, free private Git repositories, and configurable Kanban boards?
	* Azure DevOps Services
	* *Azure DevOps Services. Azure DevOps Services includes development collaboration tools including high-performance pipelines, free private Git repositories, and configurable Kanban boards.*
9. Microsoft Azure datacenters are organized and made available by?
	* Geographies  
	* **Regions**
	* Zones
	* *Regions. Microsoft Azure datacenters are organized and made available by region.*

## Security, Privacy, Compliance and Trust

### Securing network connectivity

### Azure Firewall

A Firewall is a service that **grants server access based on the originating IP address** of each request. 

**Firewall rules**

* Specify **ranges of IP addresses**. Only clients from these granted IP addresses will be allowed to access the server.
* Include **specific network protocol and port information**

**Azure Firewall provides many features, including:**

* Built-in high availability.
* Unrestricted cloud scalability.
* **Inbound and outbound filtering rules**.
* **Azure Monitor logging**.

> Note:

**Azure Application Gateway** also provides a **firewall**, called the **Web Application Firewall (WAF)**. WAF provides **centralized, inbound protection for your web applications against common exploits and vulnerabilities**.

### Azure DDoS Protection

**DDoS standard protection**

* Volumetric attacks.
* Protocol attacks.
* Resource (application) layer attacks. 

### Network Security Groups (NSG)

An NSG can contain multiple inbound and outbound security rules that enable you to **filter traffic to and from resources by source and destination IP address, port, and protoco**l.

Attributes: 

* Name
* Priority
* Source or Destination
* Protocol
* Port Range
* Action: **Allow or Deny**.

### Application Security Groups (ASG)

This feature allows you to reuse your security policy at scale without manual **maintenance of explicit IP addresses**

**Without IP address, only have like WebServers, AppServers, DbServers**

### Choosing Azure network security solutions

**Perimeter layer**

* DDoS Protection
* Azure Firewall 

**Networking layer**

 NSGs to create rules about inbound and outbound communication at this laye
 
**Combining services**

* Network security groups and Azure Firewal
* Application Gateway WAF and Azure Firewall

### Core Azure identity services

> Authentication is sometimes shortened to `AuthN`, and authorization is sometimes shortened to `AuthZ`.

### Azure Active Directory (Azure AD)

**Azure Active Directory** is a Microsoft cloud-based **identity and access management service.** Azure AD helps employees of an organization sign in and access resources: Internal resource / External resources 

Azure AD provides services such as:

* Authentication
* Single-Sign-On (SSO)
* Application management.
* Business to business (B2B) identity services
* Business-to-Customer (B2C) identity services.
* Device Management

### Azure Security Center

**Monitoring service that provides threat protection across all of your services both in Azure, and on-premises**. 

* Provide security recommendations
* Monitor security settings across on-premises and cloud workloads,
* Perform automatic security assessments to identify potential vulnerabilities before they can be exploited.
* Use machine learning to detect and block malware from being installed on your virtual machines and services.
* Analyze and identify potential inbound attacks 
* Provide just-in-time access control for ports, reducing your attack surface by ensuring the network only allows traffic that you require.

Azure Security Center Versions

* Free
* Standard: 
	* continuous monitoring, 
	* threat detection, 
	* just-in-time access control for ports,

### Key Vault

* Secrets management.
* Key management.
* Certificate management.
* Store secrets backed by hardware security modules (HSMs)

### Azure Information Protection (AIP)

Helps organizations classify and (optionally) **protect its documents and emails by applying labels**. 

Labels can be applied **automatically (by administrators who define rules and conditions), manually (by users), or with a combination of both (where users are guided by recommendations).**

### Azure Advanced Threat Protection (ATP)

Identifies, detects, and helps you **investigate advanced threats, compromised identities, and malicious insider actions directed at your organization.**

Azure ATP components

* **Azure ATP portal**. Monitor and respond to suspicious activity.
* **Azure ATP sensor**. Azure ATP sensors are installed directly on your domain controllers
* **Azure ATP cloud service.**

### Azure Policy

These policies enforce different rules and effects over your resources, so **those resources stay compliant with your corporate standards and service-level agreements (SLAs)**.

* Create a policy definition
	* Allowed Storage Account SKUs. 
	* Allowed Resource Type. 
	* Allowed Locations. 
	* Allowed Virtual Machine SKUs. 
* Assign a definition to a scope of resources
* Review the policy evaluation results

### Policy Initiatives

An initiative definition is a set of policy definitions to help track your compliance state for a larger goal.

like:

* Monitor unencrypted SQL Database in Security Center 
* Monitor OS vulnerabilities in Security Center

An initiative assignment is an initiative definition assigned to a specific scope.

**This scope could also range from a management group to a resource group.**

### Resource locks
 
You can set the lock level to **CanNotDelete** or **ReadOnly**

### Azure Blueprints

enable cloud architects to define a **repeatable set of Azure resources** that implement and adhere to an **organization's standards, patterns, and requirement**

* Role assignments
* Policy assignments
* **Azure Resource Manager templates**
* Resource groups

###  **Subscription governance**

* **Billing**
* **Access Control**:
* **Subscription Limit**: For example, the maximum number of Express Route circuits per subscription is 10. 

**management groups** which manage **access, policies, and compliance across multiple Azure subscription**.

### Tags

Tag Limitations:

* Not all resource types support tags.
* maximum of 50 tag name/value pairs; Storage accounts only support 15 tag

**You can use `Azure Policy` to enforce tagging values and rules on resources.**

### Azure Monitor

**Diagnostic settings**

* **Activity Logs** record when resources are created or modified.
* **Metrics** tell you how the resource is performing and the resources that it's consuming.

**Enabling diagnostics**

* Enable guest-level monitoring
* **Performance counters:** collect performance data
* **Event Logs**: enable various event logs
* **Crash Dumps**: enable or disable
* **Sinks**: send your diagnostic data to other services for more analysis
* **Agent**: configure agent settings

### Azure Health Service

**Provide personalized guidance and support when issues with Azure services affect you.** 

* It can notify you, help you understand the impact of issues,
*  Help you prepare for planned maintenance and changes 

Azure Service Health is composed

* Azure Status
* Service Health 
* Resource Health

### Monitoring applications and services

* **Application Insights** is a service that monitors the availability, performance, and usage of your web applications,
* **Azure Monitor** for containers is a service that is designed to monitor the performance of container workloads
* **Azure Monitor for VMs** is a service that monitors your Azure VMs at scale,

**Respond:** Alerts / Autoscale

**Visualize**: Dashboards / Views / Power BI

## Privacy, Compliance and Data Protection standards

### Microsoft Privacy Statement

The **Microsoft privacy statement** explains **what personal data Microsoft processes, how Microsoft processes it, and for what purposes**.


### Trust Center

**Containing information and details about how Microsoft implements and supports** security, privacy, compliance, and transparency in all Microsoft cloud products and services. 

### Service Trust Portal

**The Service Trust Portal (STP)** hosts the **Compliance Manager service**, and is the Microsoft public site for **publishing audit reports and other compliance-related information** relevant to Microsoft’s cloud services.

* download audit reports
* gain insight from Microsoft-authored reports

STP is a companion feature to the Trust Center, and allows you to:

* **Access audit reports**
* Access compliance guides 
* **Access trust documents**

### Compliance Manager
 
**A workflow-based risk assessment dashboard within the Trust Portal** that enables you to **track, assign, and verify your organization's regulatory compliance activities** related to Microsoft professional services and Microsoft cloud services such as **Office 365, Dynamics 365, and Azure.**

> Compliance Manager is a dashboard that provides a summary of your data protection and compliance stature, and recommendations to improve data protection and compliance.

### Azure Government services

* Azure Government
* Azure China 21Vianet

1. Which of the following could grant or deny access based on the originating IP address?

	* Azure Active Directory  
	* **Azure Firewall**
	* VPN Gateway
2. Which of the following could require both a password and a security question for full authentication?

	*  Azure Firewall
	*  Application Gateway
	*  **Multi-Factor Authentication**
	* *Multi-Factor Authentication (MFA). MFA can require two or more elements for full authentication.*

3. Which of the following services would you use to filter internet traffic in your Azure virtual network?

	*  Azure Firewall
	*  **Network Security Group**  
	*  VPN Gateway
4. Which of the following lets you store passwords in Azure so you can centrally manage them for your services and applications?

	* Azure Advanced Threat Protection  
	* **Azure Key Vault**
	* Azure Security Center
5. Which of the following should you use to download published audit reports and how Microsoft builds and operates its cloud services?
	* Azure Policy
	* Azure Service Health  
	* **Service Trust Portal**
	* *Service Trust Portal (STP). Service Trust Portal is the Microsoft public site for publishing audit reports and other compliance-related information relevant to Microsoft’s cloud services. STP users can download audit reports produced by external auditors and gain insight from Microsoft-authored reports that provide details on how Microsoft builds and operates its cloud services.*
6. Which of the following provides information about planned maintenance and changes that could affect the availability of your resources?
	* Azure Monitor
	* Azure Security Center  
	* **Azure Service Health**
	* *Azure Service Health. Azure Service Health is a suite of experiences that provide personalized guidance and support when issues with Azure services affect you. It can notify you, help you understand the impact of issues, and keep you updated as the issue is resolved. Azure Service Health can also help you prepare for planned maintenance and changes that could affect the availability of your resources.*
7. Where can you **obtain details about the personal data Microsoft processes, how Microsoft processes it**, and for what purposes?
	
	* **Microsoft Privacy Statement**  
	* Compliance Manager
	* Azure Service Health
8. Which of the following can be used to help you enforce resource tagging so you can manage billing?
	*  **Azure Policy**
	*  Azure Service Health  
	*  Compliance Manager
	*  *Azure Policy. Azure Policy can be used to enforce tagging values and rules on resources.*
9. Which of the following can be used to define a **repeatable set** of Azure resources that implement organizational requirements?
	* **Azure Blueprint**
	* Azure Policy
	* Azure Resource Groups
	* *Azure Blueprints. Azure Blueprints enable cloud architects to define a repeatable set of Azure resources that implement and adhere to an organization's standards, patterns, and requirements. Azure Blueprint enables development teams to rapidly build and deploy new environments with the knowledge that they're building within organizational compliance with a set of built-in components that speed up development and delivery.*
10. Which of the following lets you grant users only the rights they need to perform their jobs?s
	* Azure Policy
	* Compliance Manager
	* **Role-Based Access Control**

## Azure Pricing and Support

### Azure Subscriptions

Azure subscription which provides you with **authenticated and authorized access to Azure products and services and allows you to provision resources**. 

An Azure subscription is a **logical unit of Azure services that links to an Azure account, which is an identity in Azure Active Directory**

There are two types of subscription boundaries

* Billing boundary.
* Access control boundary.

**Subscriptions Offers**

* **A free account**. Get started with **12 months of popular free services**, **`$200` credit to explore any Azure service for 30 days**, and 25+ services that are always freeand 25+ services that are always free. 
	* Your Azure services are disabled when the trial ends or when your credit expires for paid products, unless you upgrade to a paid subscription. 
* Pay-As-You-Go
* Member offers

### Management Groups

**Management groups** =>  **subscriptions** => **resource groups** => **resources**. 

* **Management groups**: These are containers that help you manage access, policy, and compliance for multiple subscriptions.
	* All subscriptions in a management group automatically inherit the conditions applied to the management group.

* **Subscriptions:** **A subscription groups together user accounts and the resources that have been created by those user accounts**. For each subscription, there are limits or quotas on the amount of Azure Subscriptions resources you can create and use.
	* Organizations can use subscriptions to manage costs and the
resources that are created by users, teams, or projects.

* **Resource groups: A resource group is a logical container into which Azure resources** like web apps, databases, and storage accounts are deployed and managed

### Purchasing Azure products and services

**customer types**

* Enterprise
* Web direct.
* **Cloud Solution Provider.** Cloud Solution Provider (CSP) typically are Microsoft partner

**Factors affecting costs**

* Usage meters
* Resource type
* Services
* Location

**Zones for billing purposes**

**Bandwidth** refers to data moving in and out of **Azure datacenters**. 

* Some **inbound data transfers**, such as data going into **Azure datacenters, are free**. 
* For **outbound data transfers**, such as data going out of **Azure datacenters, data transfer pricing is based on Zones**.

**Zone for billing purposes** is not the same as an **Availability Zone**.


### Pricing Calculator

The pricing calculator **provides estimates**, **not actual price quotes.** Actual prices may vary depending upon the date of purchase, the payment currency you are using, and the type of Azure customer you are.

### Total Cost of Ownership Calculator

The Total Cost of Ownership Calculator（TCO) is a **tool that you use to estimate cost savings you can realize by migrating to Azure**.

* Define your workloads
	* Servers
	* Databases.
	* Storage
	* Networking
* Adjust assumptions
* View the report

### Minimizing costs

* Perform cost analyses (Azure Pricing and Total Cost of Ownership (TCO) calculator)
* Monitor usage with Azure Advisor
* Use spending limits
	*  The spending limit feature is not available for customers who aren't using credit-based subscriptions, such as Pay-As-You-Go subscribers.
* Azure Reservations (72% LOW than pay-as-you-go)
	* **To get a discount, you reserve products and resources by paying in advance.**  
* Choose low-cost locations and regions
* Research available cost-saving offers
* Apply tags to identify cost owners

### Azure Cost Management

**Cost Management** is an Azure product that provides a set of tools for **monitoring, allocating, and optimizing your Azure costs**.

* Reporting
* Data enrichment
* Budgets
* Alerting
* Recommendations
* Price


### Support plan options

### Knowledge Center

**The Knowledge Center** is a searchable database that contains answers to common support questions, from a community of Azure experts, developers, customers, and users.

### Azure Service Level Agreements (SLAs)

A typical SLA specifics performance-target commitments that range from 99.9 percent (“three nines”) to 99.99 percent ("four nines")

**Service Credits**

For example, **customers may have a discount applied to their Azure bill, as compensation for an under-performing Azure product or service**. The table below explains this example in more detail.

> Azure does not provide SLAs for many services under the Free or Shared tiers. Also, free products such as Azure Advisor do not typically have a SLA.

### Service Lifecycle in Azure

**Public and private preview features**

* Private Preview.
* Public Preview

**Accessing Azure Portal Preview**

`https://preview.portal.azure.com`

**General Availability (GA)**

Once a feature is evaluated and tested successfully, it may be released to customers as part of Azure's default product, service or feature set.

### Monitoring service and feature updates

### Review Questions

1. Which of the following provides a set of tools for monitoring, allocating, and optimizing your Azure costs?
	* **Azure Cost Management**
	* Azure Pricing Calculator
	* Total Cost of Ownership Calculator
2. Which of the following can be used to manage governance across multiple Azure subscriptions?
	* Azure Initiatives
	* **Management Groups**  
	* Resource Groups
	* *Management Groups. Management groups facilitate the hierarchical ordering of Azure resources into collections, at a level of scope above subscriptions. Distinct governance conditions can be applied to each management group, with Azure Policy and Azure RBACs, to manage Azure subscriptions effectively. The resources and subscriptions assigned to a management group automatically inherit the conditions applied to the management group.*
3. Which of the following defines performance targets, like uptime, for an Azure product or service?
	* **Service Level Agreements**  
	* Support Plans
	* Usage Meters
4. Which of the following is a logical unit of Azure services that links to an Azure account?
	* **Azure Subscription**  
	* Management Group  
	* Resource Group
	* *Azure subscription. Azure subscription is a logical unit of Azure services that links to an Azure account.*
5. Which of the following support plans **does not** offer 24x7 access to Support Engineers by email and phone?
	* 	**Developer**(only by email) Basic (neither of both)
	* Standard 
	* Professional Direct
6. An Azure Reservations offers discounted prices if you?
	* **pay in advance.**
	* provision a certain number of resources.
	* use spending limits.
	* *Pay in advance. Azure Reservations offers discounted prices if you pay in advance. To get a discount, you reserve products and resources by paying in advance. You can prepay for one or three year's use of certain Azure resources.*
7. Which of the following give **all Azure customers** a chance to test beta and other pre-release features?
	*  General Availability  
	*  Private Preview
	*  **Public Preview**
8. You have two services with different SLAs. The composite SLA is determined by?
	* Adding the SLAs percentages together
	* **Multiplying the SLAs percentages together **
	* Taking the lowest SLA percentage
9. Releasing a feature to all Azure customers is called?
	* **General Availability**
	* General Preview
	* Public Preview
10. Which of the following can be used to estimate cost savings when migrating to Azure?
	* Pricing calculator
	* **Total Cost of Ownership calculator**  
	* Usage meter
	* *Total Cost of Ownership (TCO) calculator. The TCO calculator is a tool that you use to estimate cost savings you can realize by migrating to Azure.*
 

## QA Conclusion

### Azure Apps

* **Azure Batch**

	* Azure Batch creates and manages a pool of compute nodes (virtual machines), installs the applications you want to run, and schedules jobs to run on the nodes.
	* Developers can use Batch as a **platform service** to build SaaS applications or client apps where large-scale execution is required.

* **Azure Advisor**: A tool that provides guidance and recommendations to improve an Azure environment
* **Azure Cognitive Services**: A simplified tool to build intelligent Artificial Intelligence (AI)
* **Azure Application Insights**: Applications Monitors web applications
* **Azure DevOps**: An integrated solution for the deployment of code

* **Azure Resource Manager templates**： Automate the creation of the Azure resources
* **Azure Resource Manager**： Provide a common platform for deploying objects to a cloud infrastructure and for implementing consistency across the Azure environment.
* **Azure DevTest Labs**: Azure DevTest Labs enables developers on teams to efficiently self-manage virtual machines (VMs) and PaaS resources without waiting for approvals.
* **Azure Traffic Manager profile**: Azure Traffic Manager is a DNS-based traffic load balancer that enables you to distribute traffic optimally to services across global Azure regions, while providing high availability and responsiveness.

* **Virtual network gateway**: A virtual network gateway defines the Azure network side of a site-to-site virtual private network.

*  **Azure HDInsight**: An open-source framework for the distributed processing and analysis of big data sets in clusters (Apache Hadoop)

* **Azure Firewall**: provides inbound protection for non-HTTP/S protocols. Examples of non-HTTP/S protocols include: Remote Desktop Protocol (RDP), Secure Shell (SSH), and File Transfer Protocol (FTP) **(So No Encrypt)**

### Security management

* **Management Groups**. From the Microsoft Documentation: Azure Management Groups are containers for **managing access, policies and compliance across multiple Azure subscriptions**.

* **Azure Information Protection**: by protecting **sensitive information such as emails and documents with encryption**, restricted access and rights, and integrated security in Office apps

* The **Azure Activity log**: is a **platform log** that provides insight into **subscription-level events** that have occurred in Azure

### Compliance 

* **Azure Government**: An organization that defines standards used by the **United States government**.
* **GDPR**: **A European policy** that regulates data privacy and data protection.
* **ISO**: An organization that defines **international standards** across all industries.
* **NIST**: A dedicated **public cloud for federal and state agencies** in the United States.


### Data Lakes VS. Data Warehouses

**A data warehouse** is a database optimized to **analyze relational data** coming from transactional systems and line of business applications. 

* **The data structure, and schema are defined in advance to optimize for fast SQL queries**, where the results are typically used for operational reporting and analysis. 
* **Data is cleaned, enriched, and transformed** so it can act as the “single source of truth” that users can trust.
* A cloud-based service that leverages **massively parallel processing (MPP) to quickly run complex queries** across petabytes of data in a **relational database**

**Data Lakes**

**A data lake is different**, because it stores **relational data from line of business applications**, and **non-relational data** from mobile apps, IoT devices, and social media. 

* **The structure of the data or schema is not defined** when data is captured. This means you can store all of your data without careful design or the need to know what questions you might need answers for in the future.
*  Different types of analytics on your data like **SQL queries, big data analytics, full text search, real-time analytics**, and machine learning can be used to uncover insight