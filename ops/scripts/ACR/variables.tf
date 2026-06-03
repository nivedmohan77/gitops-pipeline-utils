variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group. If it exists, Terraform will deploy into it; if not, it will be created."
}

variable "create_resource_group" {
  type        = bool
  description = "Set to true if the Resource Group does not exist and needs to be created. Set to false to use an existing one."
  default     = true
}

variable "location" {
  type        = string
  description = "The Azure Region to deploy resources. Examples: 'Central India', 'South India', 'East US', 'West Europe', 'Southeast Asia'."
  default     = "Central India"
}

variable "acr_name" {
  type        = string
  description = "The unique name of the Azure Container Registry. Must be globally unique, alphanumeric only, and 5-50 characters."
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "The ACR name must be between 5 and 50 characters, globally unique, and contain alphanumeric characters only (no hyphens or underscores)."
  }
}
