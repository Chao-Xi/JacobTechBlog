# Manage Azure Subscriptions and Resources

## The new Azure exams and certifications

### Az-103 Azure Administrator

![Alt Image Text](images/1_1.png "Body image")

### Exam Question Format

* **Technical Scenario**

"You're an administor"


* **Requirments or Problem Statement**

"The virtual machine must"

* **Goal Statement**

"You must/need ..."


* **Question Statement**

"What do you need to do"


### Exam Overview 

* 40-60 questions 

Answer all of the questions, no penalty for guessing 

* 180 minutes-150 minutes for the exam 

* Variety of question types 
	* Performance based and drag and drop 
* Case studies 


## Manage Azure subscriptions

### Enterprise level breaking down

* Broken down into **departments**
* Break departments down by **location**
* Break departments down by **function**

**departments** -> **accountts** -> **subscriptions** -> **Azure Resources**

![Alt Image Text](images/1_2.png "Body image")

### Administrator Roles 

* Classic (deprecated)
* Azure role-based access control (RBAC) 
* **Azure Active Directory (AD) (administrative roles)**

### Role-based Access Contorl (RBAC)

* 70 built-in roles 
* **User Access Administrator** 
* **Custom roles** 

![Alt Image Text](images/1_3.png "Body image")

> Exam: Should be aware of **how to create a custom role**

### Top Three RBAC Roles

* **Owner** 
	* Full access to all resources 

* **Contributor** 
	* Cannot delegate access to other users but can create and manage resources 

* **Reader** 
	* View Azure resources only 


### Assign RBAC Administrative Permissions

![Alt Image Text](images/1_4.png "Body image")

* **Do at the subscription level.**
* Select the role (**Owner, Contributor, Reader or  70 built-in roles**)
* Assign access to Azure AD user, group, or application 
* Select user 

### User Access Administor

**Special account that allows you access to all the Azure resources at the `root scope`**

* Special account 
* Privilege at the root scope (`/`) 
* Temporary access only (recommended)
* Azure AD, not subscription 


![Alt Image Text](images/1_5.png "Body image")

**Properties** => **Access Management for Azure resources**

### Configure Cost Center Quotas (`Exam`)

<span style="color:red">**Subscription level** => **Usage & Quotas** => **Current usage of resources**</span>

### Resource Tags 

* Sort resources based on tag 
* Name and value 
	* Finance: Production; Finance: Dev 
* **Fifteen tags per resource** 
* Write access is required to apply tags to a resource 


### Apply tags using PowerShell by simply using the command line

**Color Formatting - HTML**

```
# Apply tags to a Resource without tags 
Set-AzureRmResourceGroup -Name RGName -Tag @{ Dept "IT"; Environment "Prod" } 

# Remove Tags from a resource group 
Set-AzureRmResourceGroup -Tag @{} -Name RGName 
```
### Azure Policies

* Set of rules to ensure compliancy 
* **Scan resources and provide reporting** 
* Used to ensure SLAs and corporate policies are met 
* Applied to subscriptions and resources 

![Alt Image Text](images/1_6.png "Body image")

### Azure Policy Assignment Options 

* Policy 
	* Individual polices 

* Initiative 
	* Groups of individual polices 

### Three components of policy (Policy & Initiative)

#### 1.Policy and Initiative Definition

**Conditions that the policy or initiative will report on and enforce if configured to do so**

![Alt Image Text](images/1_7.png "Body image")

#### 2.Policy and Initiative Assignment

* Applying the initiative or policy **to a scope**
* Assignments are **inherited by all child resources**

![Alt Image Text](images/1_8.png "Body image")

#### 3.Policy and Initiative Parameter

* **Reduce the number of definitions** 
* Use generic values 
* Example: locations allowed 

![Alt Image Text](images/1_9.png "Body image")


### Key Points

* Know where to enable the User Access Administrator
* Understand the components of a policy 
* Know how to use tags for reporting 
* Be familiar with RBAC and how it is used to control access to Azure resources 

## Analyze resource utilization

### Configure Diagnostic Settings on Resources 

* Diagnostic logs 
	* **Tenant logs** 
	* **Resource logs** 

* Can be **enabled via the resource** or in the **Azure Monitor** 
* Data can be 
	* **archived to a `storage account`**, 
	* **Streamed to an `event hub`**, 
	* Sent to **Log Analytics** 


### PowerShell 

```
#Archive to a Storage Account 
Set-AzureRmDiagnosticSetting -ResourceId [resource id] -StorageAccountId [storage account id] -Enabled $true 

#Stream to an Event Hub 
Set-AzureRmDiagnosticSetting -ResourceId [resource id] -ServiceBusRuleId [Service Bus rule id] -Enabled $true 

#Send to Log Analytics 
Set-AzureRmDiagnosticSetting ResourceId [resource id] -WorkspaceId [resource id of the Log workspace] -Enabled $true 
```

### Create Baseline for Resources 

* Dynamic threshold alerts 
	* **Set in the Azure Monitor** 
	* **Limited public preview** 

* Desired State Configuration (DSC) **Ensure that your servers stay within scope**
	* Portal 
	* PowerShell 

### DSC Configuration Script 

```
configuration IISInstall 
{ 
	node "localhost" { 
		WindowsFeature IIS 
	{ 
		Ensure = "Present" 
		Name   = "Web-Server"
	} 
 } 
} 
```

### Alerts 

* Send notification of changes in the environment 
* Create alerts for 
	* Metric values 
	* Log search queries 
	* Activity Log events 
	* Health of the Azure platform 
	* Website availability 

### Alerts rules components

* **Target resource** — Azure resource 
* **Signal** - metrics, activity log, application insights, or a log 
* **Criteria** - combination of signal and logic 

![Alt Image Text](images/1_10.png "Body image")

### Analyze Alerts and Metrics Across Subscriptions 

* Azure Monitor
* Provide a better unified experience

![Alt Image Text](images/1_11.png "Body image")


### Create Action Group (AWS SNS Subscription)

![Alt Image Text](images/1_12.png "Body image")

**Action Group are used specify:**

* Notification preferences 
* Triggered by an alert
* Name 
* Action type 
* Details 

### Action Group Types 

* Email/SMS/Push/Voice 
	* SMS / 5minuttes
	* Voice / 5minuttes
	* Email 100 an hour
* Azure Function 
* Logic App 
* Webhook 
* ITSM
* Automation Runbook 

### Report on Spend 

* Cost management and billing (preview) 
	* Organization billing and individual billing 

* Cost analysis 
	* Filter costs by subscription, resource, date, or tag Download Usage Report.csv 

* Invoices 
	* Download invoices and view costs by service 

### Azure Advisor 

* Identifies idle and underutilized resources 
* Resizes or shuts down underutilized virtual machines 
* **Eliminates ExpressRoute circuits with a status of Not Provisioned for more than one month** 


### Utilize Log Search Query Functions 

* Azure Monitor 
* Provide insights based on the data 


### Key Points 

* Know how to create a log search query 
* Know how to create an alert 
* Know how to create an action group 
* **<span style="color:blue">Understand how often notifications are sent to an action group</span>**


 
## Manage resource groups

### Create Action Group

* Resource policies can be applied to the resource group 
* Policy then only applies to the resource group, **not the entire subscription** 

![Alt Image Text](images/1_13.png "Body image")

### Resouce Lock 

* Controls access 
* Prevents accidental deletion or modification of resources 
* The lock can be applied 
	* Subscription 
	* Resource group 
	* Resource 


![Alt Image Text](images/1_14.png "Body image")

### Types of Locks 

* <span style="color:red">`CanNotDelete`</span> 

Read and modify but not delete a resource 

* <span style="color:red">`ReadOnly`</span> 

Read but not modify, delete, or update a resource Can lead to unexpected results 

>  When you use a ReadOnly lock, it can lead to unexpected results when applied to some resources because the resource itself may need additional actions to function. 


### Lock Hierarchy 

* **Parent-child relationship** 

	* Locks applied at the parent scope affect all resources within that scope 
	* **Most restrictive lock takes precedence** 

### Permissions Required to Apply a Lock 

* `Microsoft.Authorization/*` 
* `MicrosoftAuthorization/locks/*` 
* Owner 
* User Access Administrator 


### Locks Using PowerShell 

```
#Lock a Resource Group 
New-AzureRmResourceLock -LockName NoDelete -LockLevel CanNotDelete -LockNotes "Can not Delete Resources" -ResourceGroupName 'AZ-100' 

#View All Locks in Subscription and Resource Group 
Get-AzureRmResourceLock 
Get-AzureRmResourceLock -ResourceGroupName 'AZ-100' 

#Delete a Lock 
Remove-AzureRmResourceLock -LockName NoDelete -ResourceGroupName 'AZ-100' 
```

### Moving Resource to Another Resource Group


* The location of the resource does not change 
* **Not all resources can be moved** 
* Resources are locked during the move 


![Alt Image Text](images/1_15.png "Body image")

### Moving Resource to Another Subscription

* Must exist **in the same Azure Active Directory** tenant (transfer ownership or add a new Azure subscription) 
* Resource provider must be **registered for the destination subscription** 
* Check to ensure you will **not exceed subscription quotas** 

![Alt Image Text](images/1_16.png "Body image")

### Permissions Required to Move Resources 

* **Source resource group**

Microsoft.Resources/subscriptions/resourceGroups/`moveResources/action` 

* **Destination resource group** 

Microsoft.Resources/subscriptions/resourceGroups/`write`


### Move Resources to Resource Group 

```
#Move Resources to Another Resource Group 

Move-AzureRmResource -DestinationResourceGroupName "NewRGPS" - ResourceId "/subscriptions/81XXXXXXX/resourceGroups/MARGPS/ providers/Microsoft.Network/virtualNetworks/az100vnet" 
```

### Remove Resource Group

* Removes all resources in the resource group 
* **Some resources need to be manually removed before the resource group can be deleted** 

![Alt Image Text](images/1_17.png "Body image")

### Remove Using PowerShell 

```
#Remove a Resource Group 
Remove-AzureRmResourceGroup -Name ResourceGroup 
```

### Key Points 

* Azure policies can be applied to the resource group level instead of the subscription level 
* Know the permissions required to move a resource group 
* Understand the relationship between resources when applying locks
* Know that applying a read-only lock may have unforeseen consequences 


## Manage role-based access control


### RBAC Role

* Azure Active Directory(top level).
* Azure Active Directory manage **Users and Groups** and **assign our Azure Administrative Roles**. 

* **RBAC Roles(subscription level)** 

	* Each subscription contains Resource Groups and Resources. 
	* Your RBAC Roles can be assigned to any of those levels.

![Alt Image Text](images/1_18.png "Body image")

### Azure AD Admin Roles vs. RBAC (difference)

* RBAC roles provide **access management to Azure resources** 
* Azure AD roles used to **manage Azure AD resources** 
	* Manage users 
	* Assign admin roles 
	* Reset passwords 
	* Manage licenses 
	* Manage domains 

### Type of RBAC Roles 

* Owner 
* Contributor 
* Reader 
* User Access Administrator 
* Built-in roles
* Custom roles 

![Alt Image Text](images/1_19.png "Body image")

### RBAC Required Permissions 

* Microsoft.Authorization/roleAssignments/**write**
* Microsoft.Authorization/roleAssignments/**delete** 
	* **User Access** 
	* **Administrator Owner** 

### Before Assigning Access 

* Who needs access to the resource? 
* What permissions do they really need? 
* What resource does access need to be granted to? 


### RBAC Role Assignments 

* **Security principal** 
	* Who or what needs access 

* **Role definition** 
	* Collection of permissions 

* **Scope** 
	* Boundary of the access 
	* What resource is this going to apply to


### Security Principal (Who or what needs access)

* User 
* Group 
* Service principal 
	* **Identity for an application** 
* **Managed identity** 
	* Cloud apps that need to authenticate to Azure AD 


### Role definition (permissions)

* Actions 
* Not actions 


![Alt Image Text](images/1_20.png "Body image")

### Scope 

* Management group 
* Subscription 
* Resource group 
* Resource 
* **Parent-child relationship — Roles are inherited**


![Alt Image Text](images/1_21.png "Body image")

### Putting it together


![Alt Image Text](images/1_22.png "Body image")