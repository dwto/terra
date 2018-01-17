# virtualmachine scale set
# service bus
# N storage accounts
# load balancer
# Public IP address 
# Virtual network

resource "azurerm_resource_group" "service_bus_rg" {
    name        = "${var.prefix}-${var.sb_namespace}"
    location    = "${var.location}"
}

resource "azurerm_servicebus_namespace" "service_bus" {
    name        = "${var.prefix}-servicebus"
    location    = "${var.location}"
    resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
    sku         = "basic"
}