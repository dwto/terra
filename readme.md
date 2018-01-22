# Terraform example

# Install
* `choco install terrafrom -y`

# Generate Service Principle RBAC 
* `az login`
* `az account set --subscription 'your subscription name'` # if you have multiple subscriptions
* `az ad sp create-for-rbac`
*
* Set service principal values in setenv.template.ps1
* `.\setenv.template.ps1`
* `terraform init`


# Verify
`terraform plan`

# Run
`Terraform apply`

#Note, May need to run terraform apply twice. module.redis.azurerm_key_vault.vault fails in the first run but
#is resolved in the second one.

# Destroy
`Terraform destroy -force`