# Module Azure CDN 

* [`azurerm_cdn_profile`](https://www.terraform.io/docs/providers/azurerm/r/cdn_profile.html)
* [`azurerm_cdn_endpoint`](https://www.terraform.io/docs/providers/azurerm/r/cdn_endpoint.html)

### `var.tf`

```
variable "JAM_INSTANCE" {}
variable "region" {}
variable "gardener_namespace" {}
variable "DNS_ZONE" {}
variable "resource_group_name" {}
```

## main.tf

```
resource "azurerm_cdn_profile" "cdn" {
  name                = "${var.JAM_INSTANCE}-cdn"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = var.JAM_INSTANCE
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = var.region
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_cdn_profile.cdn]

  origin {
    name      = "origin-0"
    host_name = "${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
  }
}
```

### `azurerm_cdn_profile`

Manages a CDN Profile to create a collection of CDN Endpoints.


* `sku` - (Required) The pricing related information of current CDN profile. Accepted values are `Standard_Akamai`, `Standard_ChinaCdn`, `Standard_Microsoft`, `Standard_Verizon` or `Premium_Verizon`.


### `azurerm_cdn_endpoint`

A CDN Endpoint is the entity within a CDN Profile containing configuration information regarding caching behaviors and origins. The CDN Endpoint is exposed using the URL format `.azureedge.net`.

* `profile_name` - (Required) The CDN Profile to which to attach the CDN Endpoint.
* `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
* `depends_on = [azurerm_cdn_profile.cdn]` Tells Terraform that this `azurerm_cdn_endpoint` must be created only after the `azurerm_cdn_profile` has been created.
* The `origin` block supports:
	* `host_name` - (Required) A string that determines the hostname/IP address of the origin server. This string can be a domain name, Storage Account endpoint, Web App endpoint, IPv4 address or IPv6 address. Changing this forces a new resource to be created.


### Depends on 

[Resource Dependencies](https://learn.hashicorp.com/terraform/getting-started/dependencies.html)

### `outputs.tf`

```
output "cdn_domain_name" {
  value = azurerm_cdn_endpoint.cdn_endpoint.host_name
}
```