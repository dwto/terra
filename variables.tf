variable "prefix" {
  default = "dwto-dev"
}

variable "arm_subscription_id" {
  type = "string"
}

variable "arm_client_id" {
  type = "string"
}

variable "arm_client_secret" {
  type = "string"
}

variable "arm_tenant_id" {
  type = "string"
}

variable "search_namespace" {
  default = "alsearch01"
}

variable "db_namespace" {
  default = "azsql01"
}

variable "redis_namespace" {
  default = "redis01"
}

variable "sb_blob" {
  default = "alstr01"
}
variable "sb_namespace" {
  default = "alsb01"
}

variable "location" {
  default = "East US"
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
  #Basic: dd6d99bb-f193-4ec1-86f2-43d3bccbc49c 
  #Standard (S0): f1173c43-91bd-4aaa-973c-54e79e15235b 
  #Standard (S1): 1b1ebd4d-d903-4baa-97f9-4ea675f5e928 
  #Standard (S2): 455330e1-00cd-488b-b5fa-177c226f28b7 
  #Standard (S3): 789681b8-ca10-4eb0-bdf2-e0b050601b40 
  #Premium (P1): 7203483a-c4fb-4304-9e9f-17c71c904f5d 
  #Premium (P2): a7d1b92d-c987-4375-b54d-2b1d0e0f5bb0 
  #Premium (P3): a7c4c615-cfb1-464b-b252-925be0a19446
}

# TODO: find the vault value
variable "vaultValue"{
  default = ""
}
