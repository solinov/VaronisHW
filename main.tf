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

locals {
	folder_path			= "C:\\TempFolder"
	new_folder			= "New-Item -Path '${local.folder_path}' -ItemType Directory"
	file_path			= "C:\\TempFolder\tempfile.txt"
	new_file			= "New-Item -Path '${local.file_path}' -ItemType File"
	#powershell_command  = "${local.new_folder}; ${local.new_file}"
	powershell_command  = "calc.exe"
}

resource "azurerm_virtual_machine_extension" "run_command" {
	name                       = "${module.dc.virtual_machine_name}_run_command"
	location                   = "${var.location}"
	resource_group_name        = "${azurerm_resource_group.SOVar_RG.name}"
	virtual_machine_name       = "${module.dc.virtual_machine_name}"
	publisher            = "Microsoft.Compute"
	type                 = "CustomScriptExtension"
	type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}