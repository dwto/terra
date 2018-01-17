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

resource "azurerm_redis_cache" "redis" {
  name                = "${var.prefix}" 
  location            = "${azurerm_resource_group.redis_rg.location}"
  resource_group_name = "${azurerm_resource_group.redis_rg.name}"
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false

  redis_configuration {}
}

output "instrumentation_key" {
  value = "${azurerm_application_insights.insights.instrumentation_key}"
}

output "app_id" {
  value = "${azurerm_application_insights.insights.app_id}"
}
