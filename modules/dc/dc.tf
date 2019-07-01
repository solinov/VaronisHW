resource "azurerm_public_ip" "public_ip" {
  name							= "${var.prefix}_DC_PublicIP"
  location 						= "${var.location}"
  resource_group_name 			= "${var.resource_group_name}"
  allocation_method 			= "Dynamic"
  idle_timeout_in_minutes 		= 30
}

resource "azurerm_network_interface" "network_interface" {
  name                		= "${var.prefix}_DC_NIC"
  location            		= "${var.location}"
  resource_group_name 		= "${var.resource_group_name}"
  network_security_group_id	= "${var.network_security_group_id}"

  ip_configuration {
    name                          	= "${var.prefix}_DC_NIC_IPConf"
    subnet_id                     	= "${var.subnet_id}"
    private_ip_address_allocation 	= "dynamic"
	public_ip_address_id 			= "${azurerm_public_ip.public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                  = "${var.prefix}_DC"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids	= ["${azurerm_network_interface.network_interface.id}"]
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