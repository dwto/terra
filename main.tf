provider "azurerm" {
  subscription_id = "${var.arm_subscription_id}"
  client_id       = "${var.arm_client_id}"
  client_secret   = "${var.arm_client_secret}"
  tenant_id       = "${var.arm_tenant_id}"
}

module "redis"{
  source          = "./modules/redis"
  arm_tenant_id   = "${var.arm_tenant_id}"
  arm_user_id     = "${var.arm_user_id}"
  prefix          = "${var.prefix}"
  location        = "${var.location}"
}

module "servicebus" {
  source          = "./modules/servicebus"
  arm_tenant_id   = "${var.arm_tenant_id}"
  prefix          = "${var.prefix}"
  location        = "${var.location}"
  vault_uri       = "${module.redis.vault_uri}"
  vault_id        = "${module.redis.vault_id}"
  cert_thumb      = "${module.redis.certificate_thumbprint}"
  cert_ver        = "${module.redis.certificate_version}"
}

module "cdn"{
  source          = "./modules/cdn"
  prefix          = "${var.prefix}"
  location        = "${var.location}"
}