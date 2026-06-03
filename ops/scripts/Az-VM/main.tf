# 1. Resource Group Evaluation Logic
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

data "azurerm_resource_group" "existing_rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.existing_rg[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.existing_rg[0].location
}

# 2. Network Infrastructure Dependencies
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.rg_location
  resource_group_name = local.rg_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = local.rg_location
  resource_group_name = local.rg_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Note: In production, narrow this down to your specific office/home IP range
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = local.rg_location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 3. Dynamic SSH Key Generation for VM Access
resource "tlv_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 4. Linux Virtual Machine Deployment
resource "azurerm_linux_virtual_machine" "runner_vm" {
  name                = var.vm_name
  resource_group_name = local.rg_name
  location            = local.rg_location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tlv_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Injects DevOps tools & Azure pipeline binaries cleanly into Base64 format string
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    azp_url   = var.azp_url
    azp_token = var.azp_token
    azp_pool  = var.azp_pool
    azp_user  = var.admin_username
  }))

  lifecycle {
    ignore_changes = [user_data] # Prevents VM re-creations if token/metadata updates later
  }
}

# Output variables to capture connection details cleanly post deployment
output "public_ip_address" {
  value       = azurerm_public_ip.pip.ip_address
  description = "The public IP to access the DevOps agent via SSH."
}

output "private_ssh_key" {
  value       = tlv_private_key.ssh_key.private_key_pem
  sensitive   = true
  description = "Private SSH Key block required to login to the VM instance."
}
