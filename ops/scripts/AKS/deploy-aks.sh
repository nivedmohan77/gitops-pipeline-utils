#!/bin/bash
set -e

echo "===================================================="
echo "    Enterprise AKS Infrastructure Control Engine"
echo "===================================================="

# 1. Handle Resource Group and Location Validation Boundaries
read -p "Enter Target Resource Group Name: " RG_NAME
RG_EXISTS=$(az group exists --name "$RG_NAME")

CREATE_RG="false"
RG_LOCATION=""

if [ "$RG_EXISTS" = "true" ]; then
    RG_LOCATION=$(az group show --name "$RG_NAME" --query location -o tsv)
    echo "✅ Existing Resource Group found. Inheriting location: $RG_LOCATION."
else
    echo "❌ WARNING: Resource Group '$RG_NAME' does not exist."
    read -p "Would you like to provision a new Resource Group? (yes/no): " ANSWER
    ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ANSWER" = "yes" ] || [ "$ANSWER" = "y" ]; then
        CREATE_RG="true"
        echo "Examples: centralindia, southindia, eastus, westeurope"
        read -p "Enter Target Azure Region Code: " RG_LOCATION
    else
        echo "Exiting deployment pipeline. No configurations modified."
        exit 0
    fi
fi

# 2. Collect Architecture Performance Presets
echo ""
echo "Select Cluster Pricing Tier Options:"
echo "  1) Free     (No Uptime SLA - Ideal for testing)"
echo "  2) Standard (99.95% Uptime SLA - Recommended for Production)"
read -p "Choose option [2]: " TIER_CHOICE

SKU_TIER="Standard"
if [ "$TIER_CHOICE" = "1" ]; then
    SKU_TIER="Free"
fi

read -p "Enter custom name for this AKS cluster [aks-enterprise-cluster]: " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-aks-enterprise-cluster}

# 3. Trigger Terraform Compilation Execution Phase
echo ""
echo "Initializing Terraform Backend Engine..."
terraform init -reconfigure

echo "Applying Consolidated Kubernetes Architecture Changes..."
terraform apply -auto-approve \
  -var="resource_group_name=$RG_NAME" \
  -var="create_resource_group=$CREATE_RG" \
  -var="location=$RG_LOCATION" \
  -var="cluster_name=$CLUSTER_NAME" \
  -var="sku_tier=$SKU_TIER"

# 4. Post-Execution Pipeline Summary Information
echo ""
echo "===================================================="
echo "✅ SUCCESS: Enterprise Cluster '$CLUSTER_NAME' is Active!"
echo "===================================================="
echo "OIDC Issuer URL and Workload Identity properties are online."
echo "Execute the command below to connect your kubectl tool to the cluster context:"
echo ""
echo "$(terraform output -raw kube_config_command)"
echo ""
