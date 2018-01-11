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
    name                         = "LoadBalancerIP"
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

/*
resource "azurerm_lb_probe" "FabricHttpGatewayProbe" {
  resource_group_name   = "${azurerm_resource_group.service_bus_rg.name}"
  loadbalancer_id       = "${azurerm_lb.Loadbalancer.id}"
  name                  = "FabricHttpGateWayProbe"
  port                  = 19080 
  protocol              = "Http" 
  number_of_probes      = 2
  interval_in_seconds   = 5
}
*/

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

# Blob storage accounts
resource "azurerm_storage_account" "sbstrgacc" {
  name                        = "servicebusstorageaccount"
  resource_group_name         = "${azurerm_resource_group.service_bus_rg.name}"
  location                    = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier                = "Standard"
  #access_tier                 = "Cold"
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
  name                      = "sfstorageaccount03"
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

# TODO: virtualMachineScaleSets, hanging.....
# azurerm_virtual_machine_scale_set.vmScaleSet: Still creating... (1h49m0s elapsed)
# azurerm_virtual_machine_scale_set.vmScaleSet: Still creating... (1h49m10s elapsed)
# azurerm_virtual_machine_scale_set.vmScaleSet: Still creating... (1h49m20s elapsed)
# azurerm_virtual_machine_scale_set.vmScaleSet: Still creating... (1h49m30s elapsed)
resource "azurerm_virtual_machine_scale_set" "vmScaleSet" {
  name                      = "vmScaleSet"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  #TODO: change this to automatic afterwards
  #upgrade_policy_mode       = "Automatic"
  upgrade_policy_mode       = "Automatic"
  overprovision             = false
  depends_on = ["azurerm_template_deployment.servicefabric"]

  sku {
    name        = "Standard_D1_v2"
    tier        = "Standard"
    capacity    = 3
  }

  # ServiceFabric extension
  # TODO double check if thumbprint is the same as version number
  extension { 
    name                        = "alapi01"
    publisher                   = "Microsoft.Azure.ServiceFabric"
    type                        = "ServiceFabricNode"
    type_handler_version        = "1.0"
    auto_upgrade_minor_version  = true
    settings                    = <<SETTINGS
      {
        "clusterEndpoint": "alsvccl01.clusterEndpoint",
        "nodeTypeRef": "alapi01",
        "dataPath": "D:\\\\SvcFab",
        "durabilityLevel": "Bronze",
        "enableParallelJobs": true,
        "nicPrefixOverride": "10.0.0.0/24",
        "certificate": {
            "thumbprint": "8CA41E743D57371896842C2AD3F81D607224CDA2",
            "x509StoreName": "My"
        }
      }

      SETTINGS
    protected_settings = <<PROTECTEDSETTINGS
      {
        "StorageAccountKey1": "${azurerm_storage_account.supportLogStorageAccount.primary_access_key}",
        "StorageAccountKey2": "${azurerm_storage_account.supportLogStorageAccount.secondary_access_key}" 
      }
    PROTECTEDSETTINGS
  }
  
  # TODO: Add in the second extension VMDiagnosticsVmExt?
  #extension {
  #  name              = "VMDiagnosticsVmExt_vmNodeType0Name"
  #  publisher         = "Microsoft.Azure.Diagnostics"
  #  type              = "IaaSDiagnostics"
  #  type_handler_version = "1.5"
  #}
  extension { 
    name                        = "VMDiagnosticsVmExt_vmNodeType0Name"
    publisher                   = "Microsoft.Azure.Diagnostics"
    type                        = "IaaSDiagnostics"
    type_handler_version        = "1.5"
    auto_upgrade_minor_version  = true
    settings                    = <<SETTINGS
      {
        "WadCfg": {
          "DiagnosticMonitorConfiguration": {
              "overallQuotaInMB": "50000",
              "EtwProviders": {
                  "EtwEventSourceProviderConfiguration": [
                      {
                          "provider": "Microsoft-ServiceFabric-Actors",
                          "scheduledTransferKeywordFilter": "1",
                          "scheduledTransferPeriod": "PT5M",
                          "DefaultEvents": {
                              "eventDestination": "ServiceFabricReliableActorEventTable"
                          }
                      },
                      {
                          "provider": "Microsoft-ServiceFabric-Services",
                          "scheduledTransferPeriod": "PT5M",
                          "DefaultEvents": {
                              "eventDestination": "ServiceFabricReliableServiceEventTable"
                          }
                      }
                  ],
                  "EtwManifestProviderConfiguration": [
                      {
                          "provider": "cbd93bc2-71e5-4566-b3a7-595d8eeca6e8",
                          "scheduledTransferLogLevelFilter": "Information",
                          "scheduledTransferKeywordFilter": "4611686018427387904",
                          "scheduledTransferPeriod": "PT5M",
                          "DefaultEvents": {
                              "eventDestination": "ServiceFabricSystemEventTable"
                          }
                      }
                  ]
              }
            }
          },
        "StorageAccount": "appdiagstrg"
      }
    SETTINGS
  }

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
      certificate_url           = "${azurerm_key_vault.vault.vault_uri}secrets/${azurerm_key_vault_certificate.dwto-windowscert.name}/215e32b8cd25456b9d558e74f8ae4d7a"

      # This is giving some weird value... even though it suppose to be returning the version number.......
      #certificate_url           = "${azurerm_key_vault.vault.vault_uri}secrets/${azurerm_key_vault_certificate.windowscert.name}/${azurerm_key_vault_certificate.windowscert.version}"
      #certificate_url           = "${azurerm_key_vault_certificate.windowscert.id}"
      certificate_store       = "My"
    }
  }

  storage_profile_os_disk {
    name              = "vmssosdisk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    vhd_containers    = ["${azurerm_storage_account.sf_storage_account01.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account02.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account03.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account04.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}",
                       "${azurerm_storage_account.sf_storage_account05.primary_blob_endpoint}${azurerm_storage_container.sb_storage_container.name}" ] 
  }
}


# TODO: servicefabric clusters MISSING? https://github.com/terraform-providers/terraform-provider-azurerm/issues/541
resource "azurerm_template_deployment" "servicefabric" {
  name                          = "${var.prefix}-servicefabric"
  resource_group_name           = "${azurerm_resource_group.service_bus_rg.name}"
  template_body = <<DEPLOY
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
  "contentVersion": "1.0.0.0",

  "parameters": {
    "clusterName": {
      "defaultValue": "Cluster",
      "type": "String",
      "metadata": {
        "description": "Name of your cluster - Between 3 and 23 characters. Letters and numbers only"
      }
    },
    "clusterLocation": {
      "type": "String",
      "metadata": {
        "description": "Location of the Cluster"
      }
    },
    "certificateThumbprint": {
      "type": "String",
      "metadata": {
        "description": "Certificate Thumbprint"
      }
    },
    "certificateStoreValue": {
      "defaultValue": "My",
      "allowedValues": [
        "My"
      ],
      "type": "String",
      "metadata": {
        "description": "The store name where the cert will be deployed in the virtual machine"
      }
    },
    "supportLogStorageAccountName": {
      "defaultValue": "supportlogstorageaccount",
      "type": "String",
      "metadata": {
        "description": "Name for the storage account that contains support logs from the cluster"
      }
    },
    "clusterProtectionLevel": {
      "defaultValue": "EncryptAndSign",
      "allowedValues": [
        "None",
        "Sign",
        "EncryptAndSign"
      ],
      "type": "String",
      "metadata": {
        "description": "Protection level.Three values are allowed - EncryptAndSign, Sign, None. It is best to keep the default of EncryptAndSign, unless you have a need not to"
      }
    },
    "nt0fabricHttpGatewayPort": {
      "defaultValue": 19080,
      "type": "Int"
    },
    "vmNodeType0Name": {
      "defaultValue": "alapi01",
      "maxLength": 9,
      "type": "String"
    },
    "nt0applicationEndPort": {
      "defaultValue": 30000,
      "type": "Int"
    },
    "nt0applicationStartPort": {
      "defaultValue": 20000,
      "type": "Int"
    },
    "nt0fabricTcpGatewayPort": {
      "defaultValue": 19000,
      "type": "Int"
    },
    "nt0ephemeralEndPort": {
      "defaultValue": 65534,
      "type": "Int"
    },
    "nt0ephemeralStartPort": {
      "defaultValue": 49152,
      "type": "Int"
    },
    "nt0InstanceCount": {
      "defaultValue": 3,
      "type": "Int",
      "metadata": {
        "description": "Instance count for node type"
      }
    },
    "lbIPName": {
      "type": "String"
    }
  },

  "variables": {
    "storageApiVersion":  "2016-01-01"
  },

  "resources": [
    {
      "type": "Microsoft.ServiceFabric/clusters",
      "name": "[parameters('clusterName')]",
      "apiVersion": "2017-07-01-preview",
      "location": "[parameters('clusterLocation')]",
      "tags": {
        "resourceType": "Service Fabric",
        "clusterName": "[parameters('clusterName')]"
      },
      "properties": {
        "addonFeatures": [ "DnsService" ],
        "certificate": {
          "thumbprint": "[parameters('certificateThumbprint')]",
          "x509StoreName": "[parameters('certificateStoreValue')]"
        },
        "clientCertificateCommonNames": [],
        "clientCertificateThumbprints": [],
        "clusterState": "Default",
        "diagnosticsStorageAccountConfig": {
          "blobEndpoint": "[reference(concat('Microsoft.Storage/storageAccounts/', parameters('supportLogStorageAccountName')), variables('storageApiVersion')).primaryEndpoints.blob]",
          "protectedAccountKeyName": "StorageAccountKey1",
          "queueEndpoint": "[reference(concat('Microsoft.Storage/storageAccounts/', parameters('supportLogStorageAccountName')), variables('storageApiVersion')).primaryEndpoints.queue]",
          "storageAccountName": "[parameters('supportLogStorageAccountName')]",
          "tableEndpoint": "[reference(concat('Microsoft.Storage/storageAccounts/', parameters('supportLogStorageAccountName')), variables('storageApiVersion')).primaryEndpoints.table]"
        },
        "fabricSettings": [
          {
            "parameters": [
              {
                "name": "ClusterProtectionLevel",
                "value": "[parameters('clusterProtectionLevel')]"
              }
            ],
            "name": "Security"
          }
        ],
        "managementEndpoint": "[concat('https://',parameters('lbIPName'),':',parameters('nt0fabricHttpGatewayPort'))]",
        "nodeTypes": [
          {
            "name": "[parameters('vmNodeType0Name')]",
            "applicationPorts": {
              "endPort": "[parameters('nt0applicationEndPort')]",
              "startPort": "[parameters('nt0applicationStartPort')]"
            },
            "clientConnectionEndpointPort": "[parameters('nt0fabricTcpGatewayPort')]",
            "durabilityLevel": "Bronze",
            "ephemeralPorts": {
              "endPort": "[parameters('nt0ephemeralEndPort')]",
              "startPort": "[parameters('nt0ephemeralStartPort')]"
            },
            "httpGatewayEndpointPort": "[parameters('nt0fabricHttpGatewayPort')]",
            "isPrimary": true,
            "vmInstanceCount": "[parameters('nt0InstanceCount')]"
          }
        ],
        "provisioningState": "Default",
        "reliabilityLevel": "Bronze",
        "upgradeMode": "Automatic",
        "vmImage": "Windows"
      }
    }
    ],
    "outputs": {}
}
  DEPLOY

/*
  parameters {
    "clusterName"                    = "alsvccl01"
    "clusterLocation"                = "eastus"
    "certificateThumbprint"          = "BEC1586E4328B1B6CD1E92830A12032B53314497"
    "certificateStoreValue"          = "My"
    "supportLogStorageAccountName"   = "sflogsalsvccl012584"
    "clusterProtectionLevel"         = "EncryptAndSign"
    "nt0fabricHttpGatewayPort"       = "19080"
    "vmNodeType0Name"                = "alapi01"
    "nt0applicationEndPort"          = "30000"
    "nt0applicationStartPort"        = "20000"
    "nt0fabricTcpGatewayPort"        = "19000"
    "nt0ephemeralEndPort"            = "65534"
    "nt0ephemeralStartPort"          = "49152"
    "nt0InstanceCount"               = "3"
  }
*/

  parameters {
    "clusterName"                    = "alsvccl01"
    "clusterLocation"                = "${azurerm_resource_group.service_bus_rg.location}"
    "certificateThumbprint"          = "${azurerm_key_vault_certificate.dwto-windowscert.version}"
    "certificateStoreValue"          = "My"
    "supportLogStorageAccountName"   = "${azurerm_storage_account.supportLogStorageAccount.name}"
    #"clusterProtectionLevel"         = "EncryptAndSign"
    #"nt0fabricHttpGatewayPort"       = "${azurerm_lb_rule.LBHttpRule.frontend_port}"
    #"vmNodeType0Name"                = "alapi01"
    #"nt0applicationEndPort"          = 30000
    #"nt0applicationStartPort"        = "20000"
    #"nt0fabricTcpGatewayPort"        = "${azurerm_lb_rule.LBRule.frontend_port}"
    #"nt0ephemeralEndPort"            = "65534"
    #"nt0ephemeralStartPort"          = "49152"
    #"nt0InstanceCount"               = 3
    "lbIPName"                      =  "${azurerm_public_ip.loadbalancer_publicip.fqdn}"
  }

  deployment_mode = "Incremental"

}