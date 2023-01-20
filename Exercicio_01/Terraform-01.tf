resource "azurerm_resource_group" "RG" {
  name     = "rg-UniversidadeTerraform"
  location = "East US"
}

resource "azurerm_virtual_network" "VNET" {
  name                = "vnet-universidadeterraform"
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_subnet" "SNET" {
  name                 = "snet-universidadeterraform"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.100.1.0/24"]
}

resource "azurerm_network_interface" "NIC" {
  name                = "nic-vm01"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SNET.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "RANDOM_PASSWORD" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_linux_virtual_machine" "VM01" {
  name                = "VM01"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_B2S"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.NIC.id,
  ]

    os_profile {
     computer_name = "VM01"
     admin_username = "admin"
     admin_password = random_password.password.result
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