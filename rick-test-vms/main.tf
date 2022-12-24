# Terraform Infrastructure for Azure 
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

# Create a tag
locals {
  tags = {
    env =var.env
  }
}

# Create a resource group
resource "azurerm_resource_group" "rick_group" {
  name     = "rick-test"
  location = var.resource_group_location
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

}

# Create Network Security Group and rule SSH Connection
resource "azurerm_network_security_group" "rick_security_group" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rick_group.location
  resource_group_name = azurerm_resource_group.rick_group.name

  security_rule {
    name                       = var.security_group_protocol
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.port_protocol
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vm_count
  network_interface_id      = element(azurerm_network_interface.rick_nic[*].id, count.index)
  network_security_group_id = azurerm_network_security_group.rick_security_group.id
}

resource "azurerm_linux_virtual_machine" "rick_vm" {
  count               = var.vm_count
  name                = "rick-test-machine-${count.index}"
  resource_group_name = azurerm_resource_group.rick_group.name
  location            = azurerm_resource_group.rick_group.location
  size                = "Standard_F2"
  admin_username      = var.admin_user
  network_interface_ids = [azurerm_network_interface.rick_nic["${count.index}"].id]

  tags = {
    env = var.env
  }

  admin_ssh_key {
    username   = var.admin_user
    public_key = file("~/.ssh/example.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.ubuntu_version
    version   = "latest"
  }
}
