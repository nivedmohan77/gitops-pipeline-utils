# Azure Container Registry (ACR) GitOps Utility

This directory contains an enterprise-standard, interactive automation tool designed to provision a globally unique **Azure Container Registry (ACR)** using Terraform and an intelligent Bash wrapper script.

---

## 🚀 Features

* **Interactive Safeguards:** Automatically verifies if your target Azure Resource Group exists before running Terraform.
* **Dynamic Resource Group Creation:** If a Resource Group does not exist, it alerts the operator and requests confirmation before spinning up a new one.
* **Inherited Location Pattern:** Enforces architectural consistency by automatically mapping the ACR's region to its parent Resource Group's location.
* **Input Validation:** Validates the uniqueness and naming conventions of the ACR (alphanumeric only, 5–50 characters) at runtime to prevent cloud API deployment errors.
* **Security Best Practices:** Disables the standard administrator admin user keys by default (`admin_enabled = false`) and deploys using a standard "Standard" pricing tier SKU to mirror Portal defaults.

---

## 📂 File Architecture

The deployment is split into distinct, single-responsibility files following standard HashiCorp design patterns:

```text
ops/scripts/
├── providers.tf      # Configures the AzureRM provider & semantic version pinning
├── variables.tf      # Declares inputs and handles regex naming validations
├── main.tf           # Implements conditional resource group blocks and ACR definitions
└── deploy-acr.sh     # The interactive Bash wrapper script (Entry Point)
```
## 🛠️ Prerequisites

Before executing the deployment engine, ensure you have the following packages installed on your terminal host (e.g., Ubuntu 24.04 LTS):

 * Azure CLI: To authenticate against your active subscriptions.

 * Terraform CLI: (Minimum version v1.5.0+).

 * Active Session: An authenticated Azure session with contributor rights.

```Bash
# Verify your local software prerequisites
az --version
terraform --version

# Authenticate your terminal session to Microsoft Azure
az login
```
## 💻 How to Run the Script

The entire execution lifecycle is driven by the Bash wrapper script. Follow these quick steps to launch the interactive prompt:

###  1. Set Executable Permissions

Navigate to your ops/scripts/ directory and grant execution rights to the tool:

```Bash
chmod +x deploy-acr.sh
```
### 2. Launch the Automated Execution Prompt

Run the script to begin entering your configuration parameters:

```Bash
./deploy-acr.sh
```
3. Respond to the Interactive Shell Prompts

The terminal will guide you through the execution boundaries:

  * Scenario A (Existing Resource Group): Enter your target group name. The engine locates it, inherits its deployment geography, and skips duplicate resource group creation.
  * Scenario B (Missing Resource Group): If the group name is not found, the script flags a warning and requests approval to create a new group. It will display a list of common valid locations (e.g., centralindia, eastus) for your input.

## ⚙️ Core Engineering Design Details

 ### Implicit Architecture Constraints (main.tf)

The resource mapping architecture isolates state management elements by translating runtime user responses into a localized lookup structure:

```Bash
# Abstracts resource parameters dynamically between existing or newly created objects
locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.rg[0].name : data.azurerm_resource_group.existing_rg[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.rg[0].location : data.azurerm_resource_group.existing_rg[0].location
}
```
### Note: This prevents pipeline crashes or target resource overwrites by verifying live cloud infrastructure telemetry boundaries before mutating state records.

