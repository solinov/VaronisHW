data "azurerm_subscription" "current" {}

output "target_azure_subscription" {
  value = "${data.azurerm_subscription.current.display_name}"
}

output "resource-group-name" {
  value = "${azurerm_resource_group.sovar.name}"
}
