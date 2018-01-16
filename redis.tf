data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "redis_rg" {
    name        = "${var.prefix}-${var.redis_namespace}"
    location    = "${var.location}"
}

# TODO: might be missing some properties. HockeyAppToken, HockeyAppId, Flow_Type, Request_source
resource "azurerm_application_insights" "insights" {
    name        = "Alliance Dev Insights"
    location    = "${var.location}"
    resource_group_name = "${azurerm_resource_group.redis_rg.name}"
    application_type = "Web"
}

output "instrumentation_key" {
  value = "${azurerm_application_insights.insights.instrumentation_key}"
}

output "app_id" {
  value = "${azurerm_application_insights.insights.app_id}"
}

resource "azurerm_redis_cache" "redis" {
  name                = "${var.prefix}" # creates a hostname: alliancedev.redis.cache.windows.net
  location            = "${azurerm_resource_group.redis_rg.location}"
  resource_group_name = "${azurerm_resource_group.redis_rg.name}"
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false

  redis_configuration {}
}

# TODO: get permissions....
resource "azurerm_key_vault" "vault" {
  name                              = "${var.prefix}-vault"
  location                          = "${azurerm_resource_group.redis_rg.location}"
  resource_group_name               = "${azurerm_resource_group.redis_rg.name}"
  enabled_for_deployment            = true
  enabled_for_disk_encryption       = true
  enabled_for_template_deployment   = true
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

    key_permissions = [ "get", "list", "update", "create", "import", "delete", "recover",
      "backup", "restore", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign" ]

    secret_permissions = [ "get", "list", "set", "delete", "recover", "backup", "restore" ]

    certificate_permissions = ["create", "delete", "deleteissuers", "get", "getissuers",
      "import", "list", "listissuers", "managecontacts", "manageissuers", "setissuers", "update" ]
  }

  access_policy {
    tenant_id = "${var.arm_tenant_id}"
    object_id = "${var.arm_user_id}"

    key_permissions = [ "get", "list", "update", "create", "import", "delete", "recover",
      "backup", "restore", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign" ]

    secret_permissions = [ "get", "list", "set", "delete", "recover", "backup", "restore" ]

    certificate_permissions = ["create", "delete", "deleteissuers", "get", "getissuers",
      "import", "list", "listissuers", "managecontacts", "manageissuers", "setissuers", "update" ]
  }
}

# TODO: is not able to create the certificate
resource "azurerm_key_vault_certificate" "wincert" {
  name    = "wincert"
  vault_uri = "${azurerm_key_vault.vault.vault_uri}"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size = 2048
      key_type = "RSA"
      reuse_key = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
        key_usage =[ 
          "cRLSign",
          "dataEncipherment",
          "digitalSignature",
          "keyAgreement",
          "keyCertSign",
          "keyEncipherment",
        ]

        subject           = "CN=My"
        validity_in_months = 12
    }
  }
}

output "vault_id" {
  value = "${azurerm_key_vault.vault.id}"
}
