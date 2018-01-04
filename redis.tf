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


resource "azurerm_key_vault" "vault" {
  name            = "vault"
  location        = "${azurerm_resource_group.redis_rg.location}"
  resource_group_name = "${azurerm_resource_group.redis_rg.name}"
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment= true

  sku {
    name = "standard"
  }

  tenant_id = "${var.arm_tenant_id}"

  access_policy {
    tenant_id = "${var.arm_tenant_id}"
    object_id = "${var.arm_client_id}"

    key_permissions = [
      "get",
      "list",
      "update",
      "create",
      "import",
      "delete",
      #"recover",
      #"backup",
      #"restore"
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
      "recover",
      "backup",
      "restore"
    ]

    certificate_permissions = [
      "get",
      "list",
      "update",
      "create",
      "import",
      "delete",
      #"recover",
      #"backup",
      #"restore"
    ]
  }



}

