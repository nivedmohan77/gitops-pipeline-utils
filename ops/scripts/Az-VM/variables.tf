variable "resource_group_name" {
  type        = string
  description = "Name of the target Resource Group."
}

variable "create_resource_group" {
  type        = bool
  description = "Set to true to create a new Resource Group, false to use an existing one."
  default     = true
}

variable "location" {
  type        = string
  description = "Azure region for the deployment (e.g., 'Central India', 'East US')."
  default     = "Central India"
}

variable "vm_name" {
  type        = string
  description = "The name of the Linux Virtual Machine runner."
  default     = "vm-devops-runner"
}

variable "vm_size" {
  type        = string
  description = "Azure Compute SKU size."
  default     = "Standard_E2as_v4" # Cost-efficient high-compute option optimized for engineering workloads
}

variable "admin_username" {
  type        = string
  description = "The administrator username for the Linux VM."
  default     = "azureuser"
}

# Azure DevOps Agent Registration Inputs
variable "azp_url" {
  type        = string
  description = "The full Azure DevOps Organization URL (e.g., https://dev.azure.com/YourOrgName)."
}

variable "azp_token" {
  type        = string
  description = "Personal Access Token (PAT) with 'Agent Pools (Read & Manage)' scope."
  sensitive   = true
}

variable "azp_pool" {
  type        = string
  description = "The name of the target Agent Pool in Azure DevOps."
  default     = "Default"
}
