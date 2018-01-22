variable "loc" {}
variable "env" {}
variable "location" {}
variable "arm_tenant_id" {}
variable "arm_user_id" {}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "redis_rg" {
    name        = "${var.loc}${var.env}${var.redis_namespace}"
    location    = "${var.location}"
}
