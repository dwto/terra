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
    resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
    sku         = "basic"
}

resource "azurerm_virtual_network" "vnet" {
    name                = "vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
}

resource "azurerm_subnet" "subnet0" {
    name    = "Subnet-0"
    resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
    virtual_network_name = "${azurerm_virtual_network.vnet.name}"
    address_prefix = "10.0.0.0/24"
}


# Virtual Network
resource "azurerm_public_ip" "loadbalancer_publicip" {
    name                         = "LBIP"
    location                     = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name          = "${azurerm_resource_group.service_bus_rg.name}"
    public_ip_address_allocation = "static"
    domain_name_label            = "${azurerm_resource_group.service_bus_rg.name}"

}

# Load Balancer
resource "azurerm_lb" "Loadbalancer" {
    name            = "LoadBalancer"
    location        = "${azurerm_resource_group.service_bus_rg.location}"
    resource_group_name          = "${azurerm_resource_group.service_bus_rg.name}"
    
    frontend_ip_configuration {
        name        = "LoadBalancerIP"
        public_ip_address_id = "${azurerm_public_ip.loadbalancer_publicip.id}"
    }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id     = "${azurerm_lb.Loadbalancer.id}"
  name                = "LBBEAddressPool"
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

resource "azurerm_lb_probe" "FabricHttpGatewayProbe" {
  resource_group_name   = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id       = "${azurerm_lb.Loadbalancer.id}"
  name                  = "FabricGateWayProbe"
  port                  = 19080 
  protocol              = "Http" 
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
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Blob storage accounts
resource "azurerm_storage_account" "sbstrgacc" {
  name                        = "servicebusstorageaccount"
  resource_group_name         = "${azurerm_resource_group.service_bus_rg.name}"
  location                    = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier                = "Standard"
  access_tier                 = "Cool"
  enable_blob_encryption      = true
  account_replication_type    = "RAGRS"

}

resource "azurerm_storage_container" "sb_storage_container" {
  name            = "vhds"
  resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
  storage_account_name = "${azurerm_storage_account.sbstrgacc.name}"
  container_access_type = "private" #TODO review this value
}

# Blob storage
resource "azurerm_storage_blob" "sb_blob" {
  name = "${var.prefix}-${var.sb_blob}"
  resource_group_name = "${azurerm_resource_group.service_bus_rg.name}"
  storage_account_name = "${azurerm_storage_account.sbstrgacc.name}"
  storage_container_name = "${azurerm_storage_container.sb_storage_container.name}"
}

# supportLogStorageAccount
resource "azurerm_storage_account" "supportLogStorageAccount" {
  name                      = "supportlogstorageaccount"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

# applicationDiagnosticsStorageAccountType 
resource "azurerm_storage_account" "appdiagstrg" {
  name                      = "appdiagstrg" # lowercase only
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

# 5 separate storage accounts for application.....
resource "azurerm_storage_account" "sf_storage_account01" {
  name                      = "sfstorageaccount01"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}
resource "azurerm_storage_account" "sf_storage_account02" {
  name                      = "sfstorageaccount02"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}
resource "azurerm_storage_account" "sf_storage_account03" {
  name                      = "sftorageaccount03"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}
resource "azurerm_storage_account" "sf_storage_account04" {
  name                      = "sfstorageaccount04"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}
resource "azurerm_storage_account" "sf_storage_account05" {
  name                      = "sfstorageaccount05"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

# TODO: virtualMachineScaleSets
resource "azurerm_virtual_machine_scale_set" "vmScaleSet" {
  name                      = "vmScaleSet"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  upgrade_policy_mode       = "Automatic"
  overprovision             = false

  sku {
    name        = "Standard_D1_v2"
    tier        = "Standard"
    capacity    = 3
  }

  extension { 
    name                        = "alapi01"
    publisher                   = "Microsoft.Azure.ServiceFabric"
    type                        = "ServiceFabricNode"
    type_handler_version        = "1.0"
    auto_upgrade_minor_version  = true
    #settings                    =
    protected_settings = "{StorageAccountKey1:\"${azurerm_storage_account.supportLogStorageAccount.primary_access_key}\", StorageAccountKey2: \"${azurerm_storage_account.supportLogStorageAccount.secondary_access_key}\" }"

    # TODO fill in the cluster name and certificate ..... has to be created from ARM template because its not supported by terraform
    # specified as a JSON object in a string 
    #settings                = "{ \"clusterEndpoint\" : \"\" \"nodeTypeRef\" : \"alapi01\" \"dataPath\" : \"D:\\\\SvcFab\" \"durabilityLevel\" : \"Bronze\" \"enableParallelJobs\" : true \"nicePrefixOverride\" : \"Subnet-0\" \"certificate\" : { tumbprint : \"\" x509StoreName : \"\" } }"
  }
  
  # TODO: Add in the second extension VMDiagnosticsVmExt?
  #extension {
  #  name              = "VMDiagnosticsVmExt_vmNodeType0Name"
  #  publisher         = "Microsoft.Azure.Diagnostics"
  #  type              = "IaaSDiagnostics"
  #  type_handler_version = "1.5"
  #}

  network_profile {
    name    = "NIC-0"
    primary = true

    ip_configuration {
      name                                   = "NIC-0"
      subnet_id                              = "${azurerm_subnet.subnet0.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.lb_backend.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.LoadBalancerBEAddressNatPool.*.id, count.index)}"]
    }
  }

  storage_profile_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name_prefix = "alapi01"
    admin_username       = "${var.adminusername}"
    admin_password       = "${var.adminpassword}"
  }

  #TODO:  double check the vaule
  os_profile_secrets {
    source_vault_id = "${azurerm_key_vault.vault.id}"
    vault_certificates {
      certificate_url         = "${azurerm_key_vault.vault.vault_uri}"
      certificate_store       = "My"
    }
  }

  storage_profile_os_disk {
    name              = "vmssosdisk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    vhd_containers = ["${azurerm_storage_account.sf_storage_account01.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account02.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account03.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account04.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account05.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}" ] 
  }


# TODO: servicefabric clusters MISSING? https://github.com/terraform-providers/terraform-provider-azurerm/issues/541

}