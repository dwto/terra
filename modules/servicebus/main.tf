variable "loc" {}
variable "env" {}
variable "location" {}
variable "arm_tenant_id" {}
variable "vault_uri" {}
variable "vault_id" {}

resource "azurerm_resource_group" "service_bus_rg" {
    name        = "${var.loc}-${var.env}-${var.sb_namespace}"
    location    = "${var.location}"
}