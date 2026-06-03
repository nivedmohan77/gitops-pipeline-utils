# 1. Resource Group Logic
# If the user sets create_resource_group to true, this resource block executes.
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
}

# If the user sets create_resource_group to false, Terraform reads the existing RG.
data "azurerm_resource_group" "existing_rg" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

# 2. Local variables to abstract the Resource Group attributes dynamically
locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.existing_rg[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.existing_rg[0].location
}

# 3. Azure Container Registry Deployment
# Following the 'azurerm' naming hierarchy convention: provider_service_component
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = local.rg_name
  location            = local.rg_location # Pulls directly from resourcegroup.location
  sku                 = "Standard"        # Matches Azure Portal default configuration
  admin_enabled       = false             # Disabled by default for standard security practices

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
