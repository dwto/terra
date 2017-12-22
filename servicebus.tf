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
    name        = "servicebus"
    location    = "${var.location}"
    resource_group_name = "${azurerm_resource_group.service_bus_rg}"
    sku         = "basic"
}

resource "azurerm_virtal_network" "vnet" {
    name                = "vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
}

#? azurerm network interface azurerm_subnet

resource "azurerm_public_ip" "loadbalancer_publicip" {
    name                         = "LBIP"
    location                     = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name          = "${azurerm_resource_group.service_bus_rg.name}"
    public_ip_address_allocation = "static"
    domain_name_label            = "${azurerm_resource_group.test.name}"

}

