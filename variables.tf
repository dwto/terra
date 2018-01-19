######## Variables coming from setenv.ps1 ###########

variable "arm_subscription_id" {
  type = "string"
}

variable "arm_client_id" {
  type = "string"
}

variable "arm_client_secret" {
  type = "string"
}

variable "arm_object_id" {
  type = "string"
}

variable "arm_tenant_id" {
  type = "string"
}

variable "arm_user_id" {
  type = "string"
}
########## Gloablly Used Variables ###############
variable "prefix" {
  default = "dwto-dev"
}

variable "location" {
  default = "East US"
}

########### namespaces ######################
variable "search_namespace" {
  default = "alsearch01"
}

variable "db_namespace" {
  default = "azsql01"
}