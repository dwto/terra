output "vault_uri" {
  value = "${azurerm_key_vault.vault.vault_uri}"
}

output "vault_id" {
  value = "${azurerm_key_vault.vault.id}"
}

data "external" "certificate_thumbprint" {
  program = ["PowerShell.exe", "./modules/redis/cert_thumbprint.ps1"]
}

output "certificate_thumbprint" {
  value = "${data.external.certificate_thumbprint.result.thumbprint}"
}

output "certificate_version" {
  value = "${data.external.certificate_thumbprint.result.version}"
}
