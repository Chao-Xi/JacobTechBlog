# Module Azure Resource Group

[`azurerm_resource_group`](https://www.terraform.io/docs/providers/azurerm/r/resource_group.html)


### `var.tf`


```
variable "JAM_INSTANCE" {}
variable "region" {}
variable "gardener_namespace" {}
variable "resource_group_name" {}
```

## `main.tf`

```
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.region
}
```

* **location** - (Required) The location where the resource group should be created. For a list of all Azure locations, please consult this link or run 	`az account list-locations --output table`.


### `output.tf`

```
output "resource_groupname" {
  value = azurerm_resource_group.main.name
}
```
