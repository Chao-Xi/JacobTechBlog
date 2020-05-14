# Azure Database for MySQL server

[`azurerm_mysql_server`](https://www.terraform.io/docs/providers/azurerm/r/mysql_server.html)

## Database Module

### `var.tf`

```
variable "JAM_INSTANCE" {}
variable "ADMIN_USERNAME" {}
variable "ADMIN_PASSWORD" {}
variable "region" {}
variable "gardener_namespace" {}
variable "resource_group_name" {}
variable "subnet_id" {}
```

### `main.tf`



```
resource "azurerm_mysql_server" "db" {
  name                = var.JAM_INSTANCE
  resource_group_name = var.resource_group_name
  location            = var.region

  sku_name = "GP_Gen5_2"

  storage_profile {
    storage_mb            = 102400
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.ADMIN_USERNAME
  administrator_login_password = var.ADMIN_PASSWORD
  version                      = "5.7"
  ssl_enforcement              = "Disabled"
}


<!--resource "azurerm_mysql_firewall_rule" "db_fw_rule" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = var.resource_group_name
  server_name         = var.JAM_INSTANCE
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  depends_on          = [azurerm_mysql_server.db]
}
-->

resource "azurerm_private_endpoint" "private_mysql_endpoint" {
  name                = "${var.JAM_INSTANCE}_private_mysql_endpoint"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  depends_on          = [azurerm_mysql_server.db]

  private_service_connection {
    name                           = "${var.JAM_INSTANCE}_mysql_endpoint_connection"
    private_connection_resource_id = azurerm_mysql_server.db.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

```

* `resource_group_name` - (Required) The name of the resource group in which to create the SQL Server.
* `sku_name`: (Required) Specifies the SKU Name for this MySQL Server. The name of the SKU, follows the `tier` + `family` + `cores` pattern (e.g. `B_Gen4_1`, `GP_Gen5_8`).
* `storage_profile` - (Required) A storage_profile block as defined below.
	* `storage_mb` - (Required) Max storage allowed for a server. Possible values are between `5120 MB`(5GB) and `1048576 MB`(1TB) for the Basic SKU and between `5120 MB(5GB)` and `4194304 MB(4TB)` for General `Purpose/Memory` Optimized SKUs.  
	* `backup_retention_days `- (Optional) **Backup retention days for the server, supported values are between 7 and 35 days**.
	* `geo_redundant_backup` - (Optional) Enable Geo-redundant or not for server backup. Valid values for this property are `Enabled` or `Disabled`, not supported for the `basic tier`.
* `administrator_login` - (Required) The Administrator Login for the `MySQL Server`. Changing this forces a new resource to be created.
* `administrator_login_password` - (Required) The Password associated with the `administrator_login` for the MySQL Server.
* `version` - (Required) Specifies the version of MySQL to use. Valid values are `5.6`, `5.7`, and `8.0`. Changing this forces a new resource to be created.
* `ssl_enforcement` - (Required) Specifies if SSL should be enforced on connections. Possible values are `Enabled` and `Disabled`.


### `azurerm_mysql_firewall_rule`

[`azurerm_mysql_firewall_rule`](https://www.terraform.io/docs/providers/azurerm/r/mysql_firewall_rule.html)

```
resource "azurerm_mysql_firewall_rule" "db_fw_rule" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = var.resource_group_name
  server_name         = var.JAM_INSTANCE
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  depends_on          = [azurerm_mysql_server.db]
}
```

* `server_name` - (Required) Specifies the name of the MySQL Server. Changing this forces a new resource to be created.
* `resource_group_name` - (Required) The name of the resource group in which the MySQL Server exists. Changing this forces a new resource to be created.
* `start_ip_address` - (Required) Specifies the **Start IP Address associated with this Firewall Rule**. Changing this forces a new resource to be created.
* `end_ip_address` - (Required) Specifies the **End IP Address associated with this Firewall Rule**. Changing this forces a new resource to be created.


### `azurerm_private_endpoint`

* [Azure Private Link vs Azure Service Endpoints](../az_network/3PrivateLink_Svce.md)
* [`azurerm_private_endpoint`](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* **Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link.**
* **Private Endpoint** uses a private IP address from your VNet, effectively bringing the service into your VNet. **The service could be an Azure service such as Azure Storage, SQL, etc. or your own Private Link Service.** 

```
resource "azurerm_private_endpoint" "private_mysql_endpoint" {
  name                = "${var.JAM_INSTANCE}_private_mysql_endpoint"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  depends_on          = [azurerm_mysql_server.db]

  private_service_connection {
    name                           = "${var.JAM_INSTANCE}_mysql_endpoint_connection"
    private_connection_resource_id = azurerm_mysql_server.db.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}
```

A `private_service_connection` supports the following:

* `private_connection_resource_id` - (Required) The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to. Changing this forces a new resource to be created.
* `is_manual_connection= false` - (Required) Does the Private Endpoint require Manual Approval from the remote resource owner? 
* `subresource_names = ["sqlServer"]` - (Optional) **A list of subresource names which the Private Endpoint is able to connect to**. `subresource_names` corresponds to `group_id`. Changing this forces a new resource to be created.

## `output.tf`

```
output "mysql_hostname" {
  value = azurerm_mysql_server.db.fqdn
}
```