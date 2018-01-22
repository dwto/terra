variable "sb_blob" {
  default = "alstr01"
}

variable "sb_namespace" {
  default = "alsb01"
}

variable "sf_namespace" {
  default = "alsvccl01"
}

variable "ss_namespace" {
  default = "alapi01"
}

variable "adminusername" {
  default = "octoadmin"
}

variable "adminpassword" {
  default = "TopSecretPassw0rd"
}

variable "vmsize" {
  default = "Standard_DS2_v2"
}

variable "servicelevel" {
  default = "dd6d99bb-f193-4ec1-86f2-43d3bccbc49c"
}

data "external" "certificate_thumbprint" {
  program = ["PowerShell.exe", "./modules/servicebus/cert_thumbprint.ps1"]
}
