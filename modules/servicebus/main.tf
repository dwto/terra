variable "prefix" {}
variable "location" {}
variable "arm_tenant_id" {}
variable "vault_uri" {}
variable "vault_id" {}
variable "cert_thumb" {}
variable "cert_ver" {}

resource "azurerm_resource_group" "service_bus_rg" {
    name        = "${var.prefix}-${var.sb_namespace}"
    location    = "${var.location}"
}