#Declaring varibales
variable "resource_group_name" {
  description = "booking-rg"

}

variable "location" {
  description = "Australia East"

}

variable "application_name" {
  description = "booking-system"

}


#Deploy RG
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "Terraform Azure"
  }
}

#Deploy virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "book-vnet"
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
}

#Deploy subnet
resource "azurerm_subnet" "subnet" {
  name                 = "book-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = "10.0.10.0/24"
}

#Deploy NIC
resource "azurerm_network_interface" "nic" {
  name                = "book-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "bookipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

#Deploy public IP
resource "azurerm_public_ip" "pip" {
  allocation_method   = "Dynamic"
  name                = "book-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  domain_name_label   = "bookdevops"
}

#Deploy Storage account
resource "azurerm_storage_account" "store" {
  name                     = "bookstore1"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Deploy VM + COnfig VM
resource "azurerm_virtual_machine" "vm" {
  name                  = "bookvm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "book-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "VMBOOK"
    admin_username = "local_admin"
    admin_password = "book123*"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.store.primary_blob_endpoint
  }
}
