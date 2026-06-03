terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Pinning version within safe semantic ranges
    }
  }
}

provider "azurerm" {
  features {}
}
