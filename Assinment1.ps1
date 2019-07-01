cd D:\VaronisHW

terraform init

terraform apply -target azurerm_resource_group.SOVar_RG --auto-approve
terraform apply -target module.network --auto-approve
terraform apply -target module.dc --auto-approve



#terraform apply -target module.server --auto-approve

Pause