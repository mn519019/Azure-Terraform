terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rick_group" {
  name     = "rick-test"
  location = "Canada Central"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "rick_network" {
  name                = "test1_group"
  resource_group_name = azurerm_resource_group.rick_group.name
  location            = azurerm_resource_group.rick_group.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "rick_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rick_group.name
  virtual_network_name = azurerm_virtual_network.rick_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "rick_publicIP" {
  count               = 2
  name                = "acceptanceTestPublicIp-${count.index}"
  resource_group_name = azurerm_resource_group.rick_group.name
  location            = azurerm_resource_group.rick_group.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "rick_nic" {
  count               = 2
  name                = "example-nic-${count.index}"
  location            = azurerm_resource_group.rick_group.location
  resource_group_name = azurerm_resource_group.rick_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = element(azurerm_subnet.rick_subnet[*].id, 0)
    #private_ip_address            = element(var.subnet1_ips[*].id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rick_publicIP["${count.index}"].id
  }
}

resource "azurerm_linux_virtual_machine" "rick_vm" {
  count               = 2
  name                = "rick-test-machine-${count.index}"
  resource_group_name = azurerm_resource_group.rick_group.name
  location            = azurerm_resource_group.rick_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.rick_nic["${count.index}"].id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
