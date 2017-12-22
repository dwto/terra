resource "azurerm_resource_group" "searchrg" {
  name     = "${var.prefix}-${var.search_namespace}"
  location = "${var.location}"
}

resource "azurerm_search_service" "search_service" {
  name                = "${azurerm_resource_group.searchrg.name}-search01"
  resource_group_name = "${azurerm_resource_group.searchrg.name}"
  location            = "${azurerm_resource_group.searchrg.location}"
  sku                 = "standard"

  tags {
    environment = "staging"
    database    = "test"
  }
}