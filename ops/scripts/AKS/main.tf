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

# 2. Network Infrastructure Layer (Isolating Node Interfaces)
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["10.240.0.0/16"]
  location            = local.rg_location
  resource_group_name = local.rg_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/22"] # Provides ample IP addresses for Azure CNI pods
}

# 3. Core Managed AKS Cluster Configuration
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = local.rg_location
  resource_group_name = local.rg_name
  dns_prefix          = var.dns_prefix
  sku_tier            = var.sku_tier

  # Advanced Security Features: OIDC and Workload Identity Authentication Integration
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Primary Core System Node Pool Definition
  default_node_pool {
    name                = "systempool"
    node_count          = var.system_node_count
    vm_size             = var.system_vm_size
    vnet_subnet_id      = azurerm_subnet.subnet.id
    zones               = var.availability_zones # Maps availability zones to system nodes
    os_disk_size_gb     = 50
    os_disk_type        = "Ephemeral"
    auto_scaling_enabled = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 4. Dedicated User Node Pool Allocation
# Stable address map targeting specialized app workloads [cite: 46]
resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name                  = "userworkload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_vm_size
  node_count            = var.user_node_count
  vnet_subnet_id        = azurerm_subnet.subnet.id
  zones                 = var.availability_zones # Maps availability zones to user nodes [cite: 56]
  
  os_disk_size_gb       = 50
  os_disk_type          = "Ephemeral"

  tags = {
    PoolType = "Workloads"
  }
}

# Output parameters to capture OIDC metadata for app deployment integrations
output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the provisioned AKS cluster."
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  description = "The OpenID Connect (OIDC) Issuer URL used to set up Federated Credentials."
}

output "kube_config_command" {
  value       = "az aks get-credentials --resource-group ${local.rg_name} --name ${azurerm_kubernetes_cluster.aks.name}"
  description = "The exact Azure CLI command required to sync your local kubectl configuration context."
}
