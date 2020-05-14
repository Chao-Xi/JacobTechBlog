# Module Azure Storage Account

[`azurerm_storage_account`](https://www.terraform.io/docs/providers/azurerm/r/storage_account.html)

### `var.tf`

```
variable "JAM_INSTANCE" {}
variable "region" {}
variable "gardener_namespace" {}
variable "resource_group_name" {}
variable "subnet_id" {}
```

## `objectstore.tf`

* [Azure Private Link vs Azure Service Endpoints](../az_network/3PrivateLink_Svce.md)
* [`azurerm_private_endpoint`](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)

```
resource "azurerm_storage_account" "objectstore" {
  name                     = "${var.JAM_INSTANCE}object"
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.subnet_id]
  }
}

resource "azurerm_private_endpoint" "private_storage_endpoint" {
  name                = "${var.JAM_INSTANCE}_private_storage_endpoint"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  depends_on          = [azurerm_storage_account.objectstore]

  private_service_connection {
    name                           = "${var.JAM_INSTANCE}_endpoint_connection"
    private_connection_resource_id = azurerm_storage_account.objectstore.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}
```

* `account_kind` - (Optional) Defines the Kind of account. Valid options are `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. Changing this forces a new resource to be created. Defaults to `StorageV2`.
* `account_tier` - (Required) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created.
* `account_replication_type` - (Required) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS` and `ZRS`.
* `access_tier` - (Optional) Defines the access tier for `BlobStorage`, `FileStorage` and `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`.
* `subresource_names  = ["blob"]`: **A list of subresource names which the Private Endpoint is able to connect to**.


## `output.tf`

* `"docconversion_access_key_id"`: ` azurerm_storage_account.objectstore.name`
* `"docconversion_access_secret"`: `azurerm_storage_account.objectstore.primary_access_key`
* `objectstore_access_key_id`: `azurerm_storage_account.objectstore.name`
* `objectstore_access_secret`:`azurerm_storage_account.objectstore.primary_access_key`

```
output "docconversion_access_key_id" {
  value = azurerm_storage_account.objectstore.name
}

output "docconversion_access_secret" {
  value = azurerm_storage_account.objectstore.primary_access_key
  sensitive = true
}

output "objectstore_access_key_id" {
  value = azurerm_storage_account.objectstore.name
}

output "objectstore_access_secret" {
  value = azurerm_storage_account.objectstore.primary_access_key
  sensitive = true
}
```