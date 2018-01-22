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

variable "loc" {
  #default = "eus"
  type = "string"
}

variable "env" {
  #default = "dev"
  type = "string"
}

variable "location" {
  #default = "East US"
  type = "string"
}

########### namespaces ######################
variable "search_namespace" {
  default = "alsearch01"
}

variable "db_namespace" {
  default = "azsql01"
}