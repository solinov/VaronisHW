# General variables
variable "prefix" {
  default	= "SOVar"
}
variable "location" {
	type	= "string"
	default = "westeurope"
}
variable "RGName" {
	type = "string"
	default = "SOVar_RG"
}

# Network variables
variable "address_space" {
	type 	= "list"
	default = ["10.0.0.0/16"]
}
variable "address_prefix" {
	type 	= "string"
	default = "10.0.2.0/24"
}

# VM variables
variable "image_publisher" {
	type 	= "string"
	default = "MicrosoftWindowsServer"
}
variable "image_offer" {
	type 	= "string"
	default = "WindowsServer"
}
variable "image_sku" {
	type 	= "string"
	default = "2016-Datacenter"
}
variable "image_version" {
	type 	= "string"
	default = "latest"
}
# VM Disk variables
variable "OSDisk_name" {
	type 	= "string"
	default = "OSDisk"
}
variable "OSDisk_caching" {
	type 	= "string"
	default = "ReadWrite"
}
variable "OSDisk_create_option" {
	type 	= "string"
	default = "FromImage"
}
variable "OSDisk_managed_disk_type" {
	type 	= "string"
	default = "Standard_LRS"
}
# VM OS variables
variable "OS_admin_username" {
	type 	= "string"
	default = "OSLocAdmin"
}
variable "OS_admin_password" {
	type 	= "string"
	default = "QWE987qwe!@#"
}

# Domain variables
variable "Domain_name" {
	type 	= "string"
	default = "SOVar.local"
}
variable "NETBIOS" {
	type 	= "string"
	default = "SOVar"
}
variable "Domain_admin_username" {
	type 	= "string"
	default = "SOVarAdmin"
}
variable "Domain_admin_password" {
	type 	= "string"
	default = "QWE987qwe!@#"
}

# VM Extension variables
variable "VMExt_publisher" {
	type 	= "string"
	default = "Microsoft.Compute"
}
variable "VMExt_type" {
	type 	= "string"
	default = "CustomScriptExtension"
}
variable "VMExt_type_handler_version" {
	type 	= "string"
	default = "1.9"
}

# Active Directory variables
variable "AD_import_command" {
	type 	= "string"
	default = "Import-Module ADDSDeployment"
}
variable "AD_password_command" {
	type 	= "string"
	default = "$password = ConvertTo-SecureString 'QWE987qwe!@#' -AsPlainText -Force"
}
variable "AD_install_ad_command" {
	type 	= "string"
	default = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
}
variable "AD_configure_ad_command" {
	type 	= "string"
	default = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2016 -DomainName 'SOVar.local' -DomainNetbiosName 'SOVar' -ForestMode Win2016 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
}
variable "AD_restart_command" {
	type 	= "string"
	default = "shutdown -r -t 10"
}
variable "AD_exit_code" {
	type 	= "string"
	default = "exit 0"
}

