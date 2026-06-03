#!/bin/bash
set -e

echo "===================================================="
echo "   Interactive Azure DevOps Agent Runner Deployment"
echo "===================================================="

# 1. Evaluate Resource Group Location Constraints
read -p "Enter Target Resource Group Name: " RG_NAME
RG_EXISTS=$(az group exists --name "$RG_NAME")

CREATE_RG="false"
RG_LOCATION=""

if [ "$RG_EXISTS" = "true" ]; then
    RG_LOCATION=$(az group show --name "$RG_NAME" --query location -o tsv)
    echo "✅ Resource Group '$RG_NAME' identified at position region: $RG_LOCATION."
else
    echo "❌ WARNING: Resource Group '$RG_NAME' does not exist."
    read -p "Create new Resource Group entry block? (yes/no): " ANSWER
    ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ANSWER" = "yes" ] || [ "$ANSWER" = "y" ]; then
        CREATE_RG="true"
        echo "Examples: centralindia, southindia, eastus, westeurope"
        read -p "Enter Azure Region: " RG_LOCATION
    else
        echo "Deployment Aborted."
        exit 0
    fi
fi

# 2. Fetch Azure DevOps Agent Pool Parameters
read -p "Enter Azure DevOps Org URL (https://dev.azure.com/Org): " AZP_URL
read -sp "Enter Azure DevOps PAT Token: " AZP_TOKEN
echo ""
read -p "Enter Target Agent Pool Name [Default]: " AZP_POOL
AZP_POOL=${AZP_POOL:-Default}

# 3. Deploy Platform Blocks Via Clean Variable Injection Mapping
echo "Initializing System Architecture Assets..."
terraform init -reconfigure

echo "Deploying Cloud Infrastructure Infrastructure Components..."
terraform apply -auto-approve \
  -var="resource_group_name=$RG_NAME" \
  -var="create_resource_group=$CREATE_RG" \
  -var="location=$RG_LOCATION" \
  -var="azp_url=$AZP_URL" \
  -var="azp_token=$AZP_TOKEN" \
  -var="azp_pool=$AZP_POOL"

# 4. Extract Private Access Keys securely post success phase execution
terraform output -raw private_ssh_key > runner_private_key.pem
chmod 400 runner_private_key.pem

echo ""
echo "✅ SUCCESS: Virtual Machine Runner instance is online and running bootstrap!"
echo "The SSH private key has been saved locally as: runner_private_key.pem"
echo "To connect: ssh -i runner_private_key.pem azureuser@$(terraform output -raw public_ip_address)"
