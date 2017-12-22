resource "azurerm_resource_group" "db_rg" {
    name        = "${var.prefix}-${var.db_namespace}"
    location    = "${var.location}"
}
resource "azurerm_sql_server" "sql_server" {
    name                = "${azurerm_resource_group.db_rg.name}"
    resource_group_name = "${azurerm_resource_group.db_rg.name}"
    location            = "${azurerm_resource_group.db_rg.location}"
    version             = "12.0"
    administrator_login = "${var.adminusername}"
    administrator_login_password = "${var.adminpassword}"

}

resource "azurerm_sql_database" "sql_db" {
    name                 = "${azurerm_sql_server.sql_server.name}-db01"
    resource_group_name  = "${azurerm_resource_group.db_rg.name}"
    location = "${azurerm_resource_group.db_rg.location}"
    server_name = "${azurerm_sql_server.sql_server.name}"

}