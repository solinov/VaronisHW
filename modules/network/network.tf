resource "azurerm_virtual_network" "virtual_network" {
  name                	= "${var.prefix}_VN"
  resource_group_name 	= "${var.resource_group_name}"
  location            	= "${var.location}"
  address_space       	= "${var.address_space}"
}

resource "azurerm_subnet" "subnet" {
  name                 	= "${var.prefix}_IntSub"
  resource_group_name  	= "${var.resource_group_name}"
  virtual_network_name 	= "${azurerm_virtual_network.virtual_network.name}"
  address_prefix       	= "${var.address_prefix}"
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = "${var.prefix}_NetSecGroup1"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "network_security_rule1" {
  name                        = "${var.prefix}_InBound_RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.network_security_group.name}"
}