# VirtualMachine Scale Set
resource "azurerm_virtual_machine_scale_set" "vmScaleSet" {
  name                      = "alsvccl01"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  upgrade_policy_mode       = "Automatic"
  overprovision             = false
  depends_on = ["azurerm_template_deployment.servicefabric"]

  sku {
    name        = "Standard_D1_v2"
    tier        = "Standard"
    capacity    = 3
  }

  # ServiceFabric extension
  extension { 
    name                        = "alapi01_ServiceFabricNode"
    publisher                   = "Microsoft.Azure.ServiceFabric"
    type                        = "ServiceFabricNode"
    type_handler_version        = "1.0"
    auto_upgrade_minor_version  = true

    settings                    = <<SETTINGS
      {
        "clusterEndpoint":      "${azurerm_template_deployment.servicefabric.outputs["clusterEndpoint"]}",
        "nodeTypeRef":          "alapi01",
        "dataPath":             "D:\\SvcFab",
        "durabilityLevel":      "Bronze",
        "enableParallelJobs":   true,
        "nicPrefixOverride":    "10.0.0.0/24",
        "certificate": {
            "thumbprint":      "${var.cert_thumbprint}",
            "x509StoreName":   "My"
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
  
  # Diagnostics Extension
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

    protected_settings        = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "[${azurerm_storage_account.appdiagstrg.name}]",
      "storageAccountKey": "[${azurerm_storage_account.appdiagstrg.primary_access_key}]",
      "storageAccountEndPoint": "${azurerm_storage_account.appdiagstrg.primary_blob_endpoint}"
    }
    PROTECTED_SETTINGS

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

  os_profile_windows_config {
    provision_vm_agent = true
    winrm = {
      protocol            = "https"
      certificate_url     = "${azurerm_key_vault.vault.vault_uri}secrets/wincert/${var.cert_version}"
    }
  }

  os_profile_secrets {
    source_vault_id = "${azurerm_key_vault.vault.id}"
    vault_certificates {
      certificate_url           = "${azurerm_key_vault.vault.vault_uri}secrets/wincert/${var.cert_version}"
      certificate_store         = "My"
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
