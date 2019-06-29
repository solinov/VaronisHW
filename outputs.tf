output "SOVar_PublicIP" {
	value = "${azurerm_public_ip.SOVar_DCPubIP.ip_address}"
	description = "Use port 3389 to RDP to SOVar_DC."
}