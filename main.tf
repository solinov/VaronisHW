provider "azurerm" {
}

resource "azurerm_resource_group" "sovar" {
  name     = "${var.prefix}-rg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "sovar" {
  name                = "${var.prefix}-vn"
  resource_group_name = "${azurerm_resource_group.sovar.name}"
  location            = "${azurerm_resource_group.sovar.location}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sovar-internal" {
  name                 = "intsub"
  resource_group_name  = "${azurerm_resource_group.sovar.name}"
  virtual_network_name = "${azurerm_virtual_network.sovar.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "sovar" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.sovar.location}"
  resource_group_name = "${azurerm_resource_group.sovar.name}"

  ip_configuration {
    name                          = "${var.prefix}-nicconf"
    subnet_id                     = "${azurerm_subnet.sovar-internal.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "sovarDC1" {
  name                  = "${var.prefix}-DC1"
  location              = "${azurerm_resource_group.sovar.location}"
  resource_group_name   = "${azurerm_resource_group.sovar.name}"
  network_interface_ids = ["${azurerm_network_interface.sovar.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "DC1OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
}
  
}