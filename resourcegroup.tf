resource "azurerm_resource_group" "rg" {
  name     = "rg-dwto"
  location = "${var.location}"
}
