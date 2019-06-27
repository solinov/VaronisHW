provider "azurerm" {
}

resource "azurerm_resource_group" "sovar" {
  name     	= "${var.prefix}-rg"
  location 	= "${var.location}"
}

resource "azurerm_virtual_network" "sovar" {
  name                	= "${var.prefix}-vn"
  resource_group_name 	= "${azurerm_resource_group.sovar.name}"
  location            	= "${var.location}"
  address_space       	= ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sovar-internal" {
  name                 	= "${var.prefix}-intsub"
  resource_group_name  	= "${azurerm_resource_group.sovar.name}"
  virtual_network_name 	= "${azurerm_virtual_network.sovar.name}"
  address_prefix       	= "10.0.2.0/24"
}

resource "azurerm_public_ip" "sovar-external" {
  name							= "${var.prefix}-dc1-public"
  location 						= "${var.location}"
  resource_group_name 			= "${azurerm_resource_group.sovar.name}"
  allocation_method 			= "Dynamic"
  idle_timeout_in_minutes 		= 30
}

resource "azurerm_network_interface" "sovar" {
  name                	= "${var.prefix}-dc1-main"
  location            	= "${azurerm_resource_group.sovar.location}"
  resource_group_name 	= "${azurerm_resource_group.sovar.name}"

  ip_configuration {
    name                          	= "${azurerm_virtual_network.sovar.name}-ipconf"
    subnet_id                     	= "${azurerm_subnet.sovar-internal.id}"
    private_ip_address_allocation 	= "dynamic"
	public_ip_address_id 			= "${azurerm_public_ip.sovar-external.id}"
  }
}

resource "azurerm_virtual_machine" "sovarDC1" {
  name                  = "${var.prefix}-DC1"
  location              = "${azurerm_resource_group.sovar.location}"
  resource_group_name   = "${azurerm_resource_group.sovar.name}"
  network_interface_ids	= ["${azurerm_network_interface.sovar.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher	= "MicrosoftWindowsServer"
    offer     	= "WindowsServer"
    sku       	= "2016-Datacenter"
    version   	= "latest"
  }

  storage_os_disk {
    name              	= "DC1Disk1"
    caching           	= "ReadWrite"
    create_option     	= "FromImage"
    managed_disk_type	= "Standard_LRS"
  }

  os_profile {
    computer_name      = "DC1"
    admin_username     = "${var.admin_username}"
    admin_password     = "${var.admin_password}"

  }

  os_profile_windows_config {
	provision_vm_agent = true
  }
}

locals {
  import_command 		= "Import-Module ADDSDeployment"
  password_command 		= "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  install_ad_command 	= "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command 	= "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2016 -DomainName ${var.domain} -DomainNetbiosName ${var.netbios} -ForestMode Win2016 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command 		= "shutdown -r -t 10"
  exit_code_hack 		= "exit 0"
  pscommand 			= "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

resource "azurerm_virtual_machine_extension" "sovarForest" {
  name 					= "${var.prefix}-forest"
  location 				= "${var.location}"
  resource_group_name 	= "${azurerm_resource_group.sovar.name}"
  virtual_machine_name	= "${azurerm_virtual_machine.sovarDC1.name}"
  publisher 			= "Microsoft.Compute"
  type 					= "CustomScriptExtension"
  type_handler_version 	= "1.9"
  
  settings = <<SETTINGS
    {
		"commandToExecute": "powershell.exe -Command \"${local.pscommand}\""
	}
  SETTINGS
}


