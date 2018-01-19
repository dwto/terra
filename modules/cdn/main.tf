variable "prefix" {}
variable "location" {}

resource "azurerm_resource_group" "cdn_rg" {
    name        = "${var.header}${var.cdn_namespace}"
    location    = "${var.location}"
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "${var.header}${var.cdn_namespace}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cdn_rg.name}"
  #TODO FIX THIS VALUE
  #sku                 = "Premium_Verizon"
  sku                 = "Standard_verizon"
}

resource "azurerm_storage_account" "cdn_storage_account" {
  name                      = "${var.header}${var.cdn_namespace}"
  resource_group_name       = "${azurerm_resource_group.cdn_rg.name}"
  location                  = "${azurerm_resource_group.cdn_rg.location}"
  account_kind              = "Storage"
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  enable_blob_encryption    = true
  enable_https_traffic_only = true
  account_encryption_source = "Microsoft.Storage"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "${var.header}${var.cdn_namespace}"
  profile_name        = "${azurerm_cdn_profile.cdn_profile.name}"
  location            = "${azurerm_resource_group.cdn_rg.location}"
  resource_group_name = "${azurerm_resource_group.cdn_rg.name}"

  # change here
  origin {
    name      = "${var.header}${var.cdn_namespace}-blob-core-windows-net"
    host_name = "${var.header}${var.cdn_namespace}.blob.core.windows.net"
    #name      = "exampleCdnOrigin"
    #host_name = "www.example.com"
  }

  origin_path           = "/cdn"
  origin_host_header    = "${var.header}${var.cdn_namespace}.blob.core.windows.net"
}


