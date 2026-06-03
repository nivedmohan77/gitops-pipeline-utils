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
  description = "Default deployment region. If using an existing Resource Group, this will be dynamically overridden by the wrapper script to match the RG location name."
  default     = "Central India"
}

variable "cluster_name" {
  type        = string
  description = "The name of the AKS managed cluster."
  default     = "aks-enterprise-cluster"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the cluster API server endpoint."
  default     = "aksent"
}

variable "sku_tier" {
  type        = string
  description = "The pricing tier for the AKS cluster. Options are 'Free' (for testing) or 'Standard' (recommended for production SLA)."
  default     = "Standard"
  
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "The SKU tier must be either 'Free' or 'Standard'."
  }
}

# Node Pool Infrastructure Configurations
variable "system_node_count" {
  type        = number
  description = "Initial number of nodes for the default system node pool."
  default     = 2
}

variable "system_vm_size" {
  type        = string
  description = "The VM size for the mandatory system node pool."
  default     = "Standard_E2as_v4" # Cost-efficient high-compute option [cite: 40]
}

variable "user_node_count" {
  type        = number
  description = "Initial number of nodes for the dedicated user workload node pool."
  default     = 2
}

variable "user_vm_size" {
  type        = string
  description = "The VM size for the secondary user workload node pool."
  default     = "Standard_E4as_v4" # Higher memory footprint for running core services
}

variable "availability_zones" {
  type        = list(string)
  description = "The Availability Zones to distribute nodes across for high availability. E.g., ['1', '2', '3']."
  default     = ["1", "2", "3"] # Enforces cross-zone high availability [cite: 56]
}
