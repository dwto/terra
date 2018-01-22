# Blob storage accounts
resource "azurerm_storage_account" "sbstrgacc" {
  name                        = "${var.loc}${var.env}${var.sb_namespace}stgacc"
  resource_group_name         = "${azurerm_resource_group.service_bus_rg.name}"
  location                    = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier                = "Standard"
  enable_blob_encryption      = true
  account_replication_type    = "RAGRS"
}

resource "azurerm_storage_container" "sb_storage_container" {
  name                      = "${var.loc}${var.env}${var.sb_namespace}vhds"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  storage_account_name      = "${azurerm_storage_account.sbstrgacc.name}"
  container_access_type     = "private" 
}

# Blob storage
resource "azurerm_storage_blob" "sb_blob" {
  name                      = "${var.loc}${var.env}${var.sb_namespace}${var.sb_blob}"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  storage_account_name      = "${azurerm_storage_account.sbstrgacc.name}"
  storage_container_name    = "${azurerm_storage_container.sb_storage_container.name}"
}

# supportLogStorageAccount
resource "azurerm_storage_account" "supportLogStorageAccount" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}logacc"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

# applicationDiagnosticsStorageAccountType 
resource "azurerm_storage_account" "appdiagstrg" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}diag" 
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

# 5 separate storage accounts for application
resource "azurerm_storage_account" "sf_storage_account01" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}stg01"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_account" "sf_storage_account02" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}stg02"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_account" "sf_storage_account03" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}stg03"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_account" "sf_storage_account04" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}stg04"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_account" "sf_storage_account05" {
  name                      = "${var.loc}${var.env}${var.sf_namespace}stg05"
  resource_group_name       = "${azurerm_resource_group.service_bus_rg.name}"
  location                  = "${azurerm_resource_group.service_bus_rg.location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}