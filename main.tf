provider "azurerm" {
}

resource "azurerm_resource_group" "SOVar_RG" {
  name     	= "${var.prefix}_RG"
  location 	= "${var.location}"
}

module "network" {
	source              	= ".\\modules\\network"
	prefix					= "${var.prefix}"
	location 				= "${var.location}"
	resource_group_name		= "${azurerm_resource_group.SOVar_RG.name}"
	address_space       	= "${var.address_space}"
	address_prefix       	= "${var.address_prefix}"
}

module "dc" {
	source              		= ".\\modules\\dc"
	prefix						= "${var.prefix}"
	location					= "${var.location}"
	resource_group_name			= "${azurerm_resource_group.SOVar_RG.name}"
	
	network_security_group_id	= "${module.network.network_security_group_id}"
	subnet_id					= "${module.network.subnet_id}"

	image_publisher				= "${var.image_publisher}"
	image_offer					= "${var.image_offer}"
	image_sku					= "${var.image_sku}"
	image_version				= "${var.image_version}"

	OSDisk_name					= "${var.OSDisk_name}"
	OSDisk_caching				= "${var.OSDisk_caching}"
	OSDisk_create_option		= "${var.OSDisk_create_option}"
	OSDisk_managed_disk_type	= "${var.OSDisk_managed_disk_type}"

	OS_admin_username			= "${var.OS_admin_username}"
	OS_admin_password			= "${var.OS_admin_password}"
}

module "server" {
	source              		= ".\\modules\\server"
	prefix						= "${var.prefix}"
	location					= "${var.location}"
	resource_group_name			= "${azurerm_resource_group.SOVar_RG.name}"
	
	network_security_group_id	= "${module.network.network_security_group_id}"
	subnet_id					= "${module.network.subnet_id}"

	image_publisher				= "${var.image_publisher}"
	image_offer					= "${var.image_offer}"
	image_sku					= "${var.image_sku}"
	image_version				= "${var.image_version}"

	OSDisk_name					= "${var.OSDisk_name}"
	OSDisk_caching				= "${var.OSDisk_caching}"
	OSDisk_create_option		= "${var.OSDisk_create_option}"
	OSDisk_managed_disk_type	= "${var.OSDisk_managed_disk_type}"

	OS_admin_username			= "${var.OS_admin_username}"
	OS_admin_password			= "${var.OS_admin_password}"
}

module "install_ad" {
  source               = ".\\modules\\run_command"
  resource_group_name  = "${azurerm_resource_group.SOVar_RG.name}"
  virtual_machine_name = "${module.dc.virtual_machine_name}"
  os_type              = "windows"

  script = <<EOF
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
$domainpass = "${var.domain_admin_password}"
$securepass = $domainpass | ConvertTo-SecureString -AsPlainText -Force
Install-ADDSForest -DomainName “${var.domain_name}” -SafeModeAdministratorPassword $securepass -Confirm:$false
EOF
}


## failed attempt
#resource "azurerm_virtual_machine_extension" "server_join_domain" {
#  name                 = "${module.server.virtual_machine_name}_join_domain"
#  location             = "${var.location}"
#  resource_group_name  = "${azurerm_resource_group.SOVar_RG.name}"
#  virtual_machine_name = "${module.server.virtual_machine_name}"
#  publisher            = "Microsoft.Compute"
#  type                 = "JsonADDomainExtension"
#  type_handler_version = "1.0"
#
#  settings = <<SETTINGS
#    {
#        "Name": "${var.domain_name}",
#        "OUPath": "",
#        "User": "${var.domain_name}\\${var.domain_admin_username}",
#        "Restart": "true",
#        "Options": "3"
#    }
#SETTINGS
#
#  protected_settings = <<PROTECTED_SETTINGS
#    {
#        "Password": "${var.domain_admin_password}"
#    }
#PROTECTED_SETTINGS
#}

module "group_user_creation" {
  source               = ".\\modules\\run_command"
  resource_group_name  = "${azurerm_resource_group.SOVar_RG.name}"
  virtual_machine_name = "${module.dc.virtual_machine_name}"
  os_type              = "windows"

  script = <<EOF
New-ADGroup -Name “Varonis Assignment1 Group” -SamAccountName VaronisAssignment1Group  -GroupScope Universal
New-ADUser -Name "Varonis User" -SamAccountName VaronisUser
Add-ADGroupMember -Identity VaronisAssignment1Group -Members VaronisUser
Add-ADGroupMember -Identity Administrators -Members VaronisAssignment1Group
EOF
}





