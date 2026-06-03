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

variable "cluster_name" {
  type        = string
  description = "The name of the AKS cluster."
  default     = "aks-devops-cluster"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the managed cluster."
  default     = "aksdevops"
}

variable "node_vm_size" {
  type        = string
  description = "The Azure SKU size for the Kubernetes worker nodes."
  default     = "Standard_E2
