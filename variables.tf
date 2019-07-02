# General variables
variable "prefix" {
  default	= "SOVar"
}
variable "location" {
	type	= "string"
	default = "westeurope"
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
variable "domain_name" {
	type 	= "string"
	default = "SOVar.local"
}
variable "domain_admin_username" {
	type 	= "string"
	default = "SOVarAdmin"
}
variable "domain_admin_password" {
	type 	= "string"
	default = "QWE987qwe!@#"
}