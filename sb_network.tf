# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                        = "vnet"
    address_space               = ["10.0.0.0/16"]
    location                    = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name         = "${azurerm_resource_group.service_bus_rg.name}"
}

resource "azurerm_subnet" "subnet0" {
    name                        = "Subnet-0"
    resource_group_name         = "${azurerm_resource_group.service_bus_rg.name}"
    virtual_network_name        = "${azurerm_virtual_network.vnet.name}"
    address_prefix              = "10.0.0.0/24"
}

resource "azurerm_public_ip" "loadbalancer_publicip" {
    name                         = "LoadBalancerIP"
    location                     = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name          = "${azurerm_resource_group.service_bus_rg.name}"
    public_ip_address_allocation = "static"
    domain_name_label            = "${azurerm_resource_group.service_bus_rg.name}"
}

# Load Balancer
resource "azurerm_lb" "Loadbalancer" {
    name                            = "LoadBalancer"
    location                        = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name             = "${azurerm_resource_group.service_bus_rg.name}"
    
    frontend_ip_configuration {
        name                        = "LoadBalancerIP"
        public_ip_address_id        = "${azurerm_public_ip.loadbalancer_publicip.id}"
    }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id           = "${azurerm_lb.Loadbalancer.id}"
  name                      = "LBBEAddressPool"
}

# LoadBalancing Rules
resource "azurerm_lb_rule" "LBRule" {
  resource_group_name            = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id                = "${azurerm_lb.Loadbalancer.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 19000
  backend_port                   = 19000 
  frontend_ip_configuration_name = "LoadBalancerIP"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb_backend.id}"
  probe_id                       = "${azurerm_lb_probe.FabricGateWayProbe.id}"
  enable_floating_ip             = false  
}

resource "azurerm_lb_rule" "LBHttpRule" {
  resource_group_name            = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id                = "${azurerm_lb.Loadbalancer.id}"
  name                           = "LBHttpRule"
  protocol                       = "Tcp"
  frontend_port                  = 19080
  backend_port                   = 19080
  frontend_ip_configuration_name = "LoadBalancerIP"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb_backend.id}"
  probe_id                       = "${azurerm_lb_probe.FabricHttpGateWayProbe.id}"
  enable_floating_ip             = false  
}


# Probes
resource "azurerm_lb_probe" "FabricGateWayProbe" {
  resource_group_name   = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id       = "${azurerm_lb.Loadbalancer.id}"
  name                  = "FabricGateWayProbe"
  port                  = 19000 
  protocol              = "Tcp"
  number_of_probes      = 2
  interval_in_seconds   = 5
}

resource "azurerm_lb_probe" "FabricHttpGateWayProbe" {
  resource_group_name   = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id       = "${azurerm_lb.Loadbalancer.id}"
  name                  = "FabricHttpGateWayProbe"
  port                  = 19080 
  protocol              = "Tcp" 
  number_of_probes      = 2
  interval_in_seconds   = 5
}

# inboundNatPools
resource "azurerm_lb_nat_pool" "LoadBalancerBEAddressNatPool" {
  resource_group_name            = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id                = "${azurerm_lb.Loadbalancer.id}"
  name                           = "LoadBalancerBEAddressNatPool"
  protocol                       = "Tcp"
  frontend_port_start            = 3389
  frontend_port_end              = 4500
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerIP"
}