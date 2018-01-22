provider "azurerm" {
  subscription_id = "${var.arm_subscription_id}"
  client_id       = "${var.arm_client_id}"
  client_secret   = "${var.arm_client_secret}"
  tenant_id       = "${var.arm_tenant_id}"
}

module "redis"{
  loc             = "${var.loc}"
  env             = "${var.env}"
  source          = "./modules/redis"
  arm_tenant_id   = "${var.arm_tenant_id}"
  arm_user_id     = "${var.arm_user_id}"
  location        = "${var.location}"
}

module "servicebus" {
  loc             = "${var.loc}"
  env             = "${var.env}"
  source          = "./modules/servicebus"
  arm_tenant_id   = "${var.arm_tenant_id}"
  location        = "${var.location}"
  vault_uri       = "${module.redis.vault_uri}"
  vault_id        = "${module.redis.vault_id}"
}

module "cdn"{
  loc             = "${var.loc}"
  env             = "${var.env}"
  source          = "./modules/cdn"
  location        = "${var.location}"
}