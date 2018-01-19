output "template_out" {
  value           = "${module.servicebus.template_out}"
}

output "vault_uri" {
  value           = "${module.redis.vault_uri}"
}

output "vault_id" {
  value           = "${module.redis.vault_id}"
}

output "certificate_version" {
  value           = "${module.redis.certificate_version}"
}

output "certificate_thumbprint" {
  value           = "${module.redis.certificate_thumbprint}"
}