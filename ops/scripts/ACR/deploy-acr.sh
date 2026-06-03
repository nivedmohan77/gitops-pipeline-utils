#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "===================================================="
echo "      Interactive Azure ACR Deployment Script"
echo "===================================================="

# 1. Get the Resource Group Name from the user
read -p "Enter the Resource Group Name: " RG_NAME

# 2. Check Azure to see if the Resource Group exists
echo "Checking if Resource Group '$RG_NAME' exists in your subscription..."
RG_EXISTS=$(az group exists --name "$RG_NAME")

CREATE_RG="false"
RG_LOCATION=""

if [ "$RG_EXISTS" = "true" ]; then
    # Fetch the location of the existing resource group automatically
    RG_LOCATION=$(az group show --name "$RG_NAME" --query location -o tsv)
    echo "✅ Resource Group '$RG_NAME' found in location: $RG_LOCATION."
else
    # The Resource Group does not exist. Inform the user and ask permission.
    echo "❌ WARNING: Resource Group '$RG_NAME' does not exist."
    read -p "Would you like to create a new Resource Group with this name? (yes/no): " ANSWER
    
    # Convert answer to lowercase
    ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ANSWER" = "yes" ] || [ "$ANSWER" = "y" ]; then
        CREATE_RG="true"
        echo ""
        echo "Common Azure Location Examples:"
        echo "  - centralindia  (Central India)"
        echo "  - southindia    (South India)"
        echo "  - eastus        (East US)"
        echo "  - westeurope    (West Europe)"
        echo "  - southeastasia (Southeast Asia)"
        echo ""
        read -p "Enter the target Azure Location name: " RG_LOCATION
    else
        echo "Exiting deployment. No infrastructure was changed."
        exit 0
    fi
fi

# 3. Get the Unique Registry Name
echo ""
read -p "Enter a globally unique name for your ACR (Alphanumeric only): " ACR_NAME

# 4. Initialize and Execute Terraform with the collected variables
echo ""
echo "Initializing Terraform..."
terraform init -reconfigure

echo "Executing Terraform Plan..."
terraform apply -auto-approve \
  -var="resource_group_name=$RG_NAME" \
  -var="create_resource_group=$CREATE_RG" \
  -var="location=$RG_LOCATION" \
  -var="acr_name=$ACR_NAME"
