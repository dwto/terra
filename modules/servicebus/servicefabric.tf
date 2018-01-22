resource "azurerm_template_deployment" "servicefabric" {
  name                          = "${var.loc}${var.env}${var.sf_namespace}"
  resource_group_name           = "${azurerm_resource_group.service_bus_rg.name}"
  deployment_mode               = "Incremental"

  #depends_on                    = ["module.redis.certificate_thumbprint"]

  template_body = <<DEPLOY
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json",
  "contentVersion": "1.0.0.0",

  "parameters": {
    "clusterName": {
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
      "allowedValues": [
        "My"
      ],
      "type": "String",
      "metadata": {
        "description": "The store name where the cert will be deployed in the virtual machine"
      }
    },
    "supportLogStorageAccountName": {
      "type": "String",
      "metadata": {
        "description": "Name for the storage account that contains support logs from the cluster"
      }
    },
    "supportLogStorageBlobEndPoint": {
      "type": "String"
    },
    "supportLogStorageQueueEndPoint": {
      "type": "String"
    },
    "supportLogStorageTableEndPoint": {
      "type": "String"
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
          "blobEndpoint": "[parameters('supportLogStorageBlobEndPoint')]",
          "protectedAccountKeyName": "StorageAccountKey1",
          "queueEndpoint": "[parameters('supportLogStorageQueueEndPoint')]",
          "storageAccountName": "[parameters('supportLogStorageAccountName')]",
          "tableEndpoint": "[parameters('supportLogStorageTableEndPoint')]"
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
    "outputs": {
      "clusterEndpoint": {
        "type": "string",
        "value": "[reference(parameters('clusterName')).clusterEndpoint]"
      }
    }
}
  DEPLOY

  parameters {
    "clusterName"                       = "${var.loc}${var.env}${var.sf_namespace}"
    "clusterLocation"                   = "${azurerm_resource_group.service_bus_rg.location}"
    "certificateThumbprint"             = "${var.cert_thumb}"
    "certificateStoreValue"             = "My"
    "supportLogStorageBlobEndPoint"     = "${azurerm_storage_account.supportLogStorageAccount.primary_blob_endpoint}"
    "supportLogStorageQueueEndPoint"    = "${azurerm_storage_account.supportLogStorageAccount.primary_queue_endpoint}"
    "supportLogStorageTableEndPoint"    = "${azurerm_storage_account.supportLogStorageAccount.primary_table_endpoint}"
    "supportLogStorageAccountName"      = "${azurerm_storage_account.supportLogStorageAccount.name}"
    "vmNodeType0Name"                   = "${var.ss_namespace}"
    "lbIPName"                          = "${azurerm_public_ip.loadbalancer_publicip.fqdn}"

    #"clusterProtectionLevel"         = "EncryptAndSign"
    #"nt0fabricHttpGatewayPort"       = "${azurerm_lb_rule.LBHttpRule.frontend_port}"
    #"nt0applicationEndPort"          = 30000
    #"nt0applicationStartPort"        = "20000"
    #"nt0fabricTcpGatewayPort"        = "${azurerm_lb_rule.LBRule.frontend_port}"
    #"nt0ephemeralEndPort"            = "65534"
    #"nt0ephemeralStartPort"          = "49152"
    #"nt0InstanceCount"               = 3
  }
}
