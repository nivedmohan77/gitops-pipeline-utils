#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Direct non-interactive environment execution guardrails
export DEBIAN_FRONTEND=noninteractive

echo "===================================================="
echo " Starting Automated DevOps Tooling & Agent Bootstrap"
echo "===================================================="

# 1. System Updates & Core Packages Installation
apt-get update -y
apt-get upgrade -y
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    unzip \
    jq \
    python3 \
    python3-pip \
    python3-venv

# 2. Native Docker CE Engine Repository Setup & Installation
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Assign permissions to the admin user and system service contexts
usermod -aG docker ${azp_user}
systemctl enable docker
systemctl start docker

# 3. Microsoft Azure CLI Installation
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 4. HashiCorp Terraform CLI Deployment
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update -y && apt-get install -y terraform

# 5. Dedicated Self-Hosted Azure DevOps Pipelines Agent Architecture Setup
AGENT_DIR="/home/${azp_user}/azagent"
mkdir -p $AGENT_DIR
cd $AGENT_DIR

# Programmatically pull down the absolute latest version path of Linux x64 agent package components
AZ_AGENT_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r '.tag_name' | sed 's/v//')
curl -lsLO "https://vstsagentpackage.azureedge.net/agent/$AZ_AGENT_VERSION/vsts-agent-linux-x64-$AZ_AGENT_VERSION.tar.gz"
tar -zxvf vsts-agent-linux-x64-$AZ_AGENT_VERSION.tar.gz

# Set host user context ownership rules safely across the working folder
chown -R ${azp_user}:${azp_user} $AGENT_DIR

# Run non-interactive agent configuration under the custom admin user context layer
su - ${azp_user} -c "cd $AGENT_DIR && ./config.sh --unattended \
  --url \"${azp_url}\" \
  --auth pat \
  --token \"${azp_token}\" \
  --pool \"${azp_pool}\" \
  --agent \"\$(hostname)-runner\" \
  --replace \
  --acceptTeeEula"

# Configure the agent engine as a continuous systemd native service block running at root tier
cd $AGENT_DIR
./svc.sh install ${azp_user}
./svc.sh start

echo "===================================================="
echo "    DevOps Runner Agent Pipeline Initialization Clear "
echo "===================================================="
