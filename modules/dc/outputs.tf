output "network_security_group_id" {
  value = "${azurerm_network_security_group.network_security_group.id}"
}

output "subnet_id" {
  value = "${azurerm_subnet.subnet.id}"
}

output "virtual_machine_name" {
  value = "${azurerm_virtual_machine.virtual_machine.name}"
}