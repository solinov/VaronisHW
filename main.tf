provider "azurerm" {
}

resource "azurerm_resource_group" "SOVar_RG" {
  name     	= "${var.prefix}_RG"
  location 	= "${var.location}"
}

resource "azurerm_virtual_network" "SOVar_VN" {
  name                	= "${var.prefix}_VN"
  resource_group_name 	= "${var.RGName}"
  location            	= "${var.location}"
  address_space       	= "${var.address_space}"
}

resource "azurerm_subnet" "SOVar_IntSubnet" {
  name                 	= "${var.prefix}_IntSub"
  resource_group_name  	= "${var.RGName}"
  virtual_network_name 	= "${azurerm_virtual_network.SOVar_VN.name}"
  address_prefix       	= "${var.address_prefix}"
}

resource "azurerm_network_security_group" "SOVar_NetSecGroup1" {
  name                = "${var.prefix}_NetSecGroup1"
  location            = "${var.location}"
  resource_group_name = "${var.RGName}"
}

resource "azurerm_network_security_rule" "SOVar_NetSecRule1" {
  name                        = "${var.prefix}_InBound_RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.RGName}"
  network_security_group_name = "${azurerm_network_security_group.SOVar_NetSecGroup1.name}"
}

resource "azurerm_public_ip" "SOVar_DCPubIP" {
  name							= "${var.prefix}_DC_PublicIP"
  location 						= "${var.location}"
  resource_group_name 			= "${var.RGName}"
  allocation_method 			= "Dynamic"
  idle_timeout_in_minutes 		= 30
}

resource "azurerm_network_interface" "SOVar_DCNetInt" {
  name                		= "${var.prefix}_DC_NIC"
  location            		= "${var.location}"
  resource_group_name 		= "${var.RGName}"
  network_security_group_id	= "${azurerm_network_security_group.SOVar_NetSecGroup1.id}"

  ip_configuration {
    name                          	= "${azurerm_virtual_network.SOVar_VN.name}_IPConf"
    subnet_id                     	= "${azurerm_subnet.SOVar_IntSubnet.id}"
    private_ip_address_allocation 	= "dynamic"
	public_ip_address_id 			= "${azurerm_public_ip.SOVar_DCPubIP.id}"
  }
}

resource "azurerm_virtual_machine" "SOVar_DCVM" {
  name                  = "${var.prefix}_DC"
  location              = "${var.location}"
  resource_group_name   = "${var.RGName}"
  network_interface_ids	= ["${azurerm_network_interface.SOVar_DCNetInt.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher	= "${var.image_publisher}"
    offer     	= "${var.image_offer}"
    sku       	= "${var.image_sku}"
    version   	= "${var.image_version}"
  }

  storage_os_disk {
    name              	= "${var.OSDisk_name}1_DC"
    caching           	= "${var.OSDisk_caching}"
    create_option     	= "${var.OSDisk_create_option}"
    managed_disk_type	= "${var.OSDisk_managed_disk_type}"
  }

  os_profile {
    computer_name      = "DC"
    admin_username     = "${var.OS_admin_username}"
    admin_password     = "${var.OS_admin_password}"

  }

  os_profile_windows_config {
	provision_vm_agent = true
  }
}

resource "azurerm_public_ip" "SOVar_ServerPublicIP" {
  name							= "${var.prefix}_ServerPublicIP"
  location 						= "${var.location}"
  resource_group_name 			= "${var.RGName}"
  allocation_method 			= "Dynamic"
  idle_timeout_in_minutes 		= 30
}

resource "azurerm_network_interface" "SOVar_ServerNetInt" {
  name                		= "${var.prefix}_Server_NIC"
  location            		= "${var.location}"
  resource_group_name 		= "${var.RGName}"
  network_security_group_id	= "${azurerm_network_security_group.SOVar_NetSecGroup1.id}"

  ip_configuration {
    name                          	= "${azurerm_virtual_network.SOVar_VN.name}_IPConf"
    subnet_id                     	= "${azurerm_subnet.SOVar_IntSubnet.id}"
    private_ip_address_allocation 	= "dynamic"
	public_ip_address_id 			= "${azurerm_public_ip.SOVar_ServerPublicIP.id}"
  }
}

resource "azurerm_virtual_machine" "SOVar_ServerVM" {
  name                  = "${var.prefix}_Server"
  location              = "${var.location}"
  resource_group_name   = "${var.RGName}"
  network_interface_ids	= ["${azurerm_network_interface.SOVar_ServerNetInt.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher	= "${var.image_publisher}"
    offer     	= "${var.image_offer}"
    sku       	= "${var.image_sku}"
    version   	= "${var.image_version}"
  }

  storage_os_disk {
    name              	= "${var.OSDisk_name}1_Server"
    caching           	= "${var.OSDisk_caching}"
    create_option     	= "${var.OSDisk_create_option}"
    managed_disk_type	= "${var.OSDisk_managed_disk_type}"
  }

  os_profile {
    computer_name      = "Server"
    admin_username     = "${var.OS_admin_username}"
    admin_password     = "${var.OS_admin_password}"

  }

  os_profile_windows_config {
	provision_vm_agent = true
  }
}

resource "azurerm_virtual_machine_extension" "SOVar_ServerDomainJoin" {
  name                 = "${var.prefix}_ServerDomainJoin"
  location             = "${var.location}"
  resource_group_name  = "${var.RGName}"
  virtual_machine_name = "${azurerm_virtual_machine.SOVar_ServerVM.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.0"

  settings = <<SETTINGS
    {
        "Name": "${var.Domain_name}",
        "OUPath": "",
        "User": "${var.Domain_name}\\${var.Domain_admin_username}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "${var.Domain_admin_password}"
    }
PROTECTED_SETTINGS
}