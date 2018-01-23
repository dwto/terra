variable "loc" {}
variable "env" {}
variable "location" {}

resource "azurerm_resource_group" "cdn_rg" {
    name        = "${var.loc}-${var.env}-${var.cdn_namespace}"
    location    = "${var.location}"
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "${var.loc}${var.env}${var.cdn_namespace}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cdn_rg.name}"
  #TODO: original value is premium_version
  sku                 = "Standard_verizon"
}

resource "azurerm_storage_account" "cdn_storage_account" {
  name                      = "${var.loc}${var.env}${var.cdn_namespace}"
  resource_group_name       = "${azurerm_resource_group.cdn_rg.name}"
  location                  = "${azurerm_resource_group.cdn_rg.location}"
  account_kind              = "Storage"
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  enable_blob_encryption    = true
  enable_https_traffic_only = true
  account_encryption_source = "Microsoft.Storage"
}

data "external" "CORS" {
  program       = ["Powershell.exe", "./modules/cdn/CORS.ps1"]
  query         = {
    key = "${azurerm_storage_account.cdn_storage_account.primary_access_key}"
    name = "${azurerm_storage_account.cdn_storage_account.name}"
  }
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "${var.loc}${var.env}${var.cdn_namespace}"
  profile_name        = "${azurerm_cdn_profile.cdn_profile.name}"
  location            = "${azurerm_resource_group.cdn_rg.location}"
  resource_group_name = "${azurerm_resource_group.cdn_rg.name}"

  origin {
    name      = "${var.loc}${var.env}${var.cdn_namespace}-blob-core-windows-net"
    host_name = "${var.loc}${var.env}${var.cdn_namespace}.blob.core.windows.net"
  }

  origin_path           = "/cdn"
  origin_host_header    = "${var.loc}${var.env}${var.cdn_namespace}.blob.core.windows.net"
}


