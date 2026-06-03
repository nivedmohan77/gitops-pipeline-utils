# GitOps & Platform Engineering Pipeline Utilities

Welcome to the **GitOps Pipeline Utilities** repository. This repository serves as a centralized, enterprise-standard framework designed to provision, secure, and manage cloud infrastructure using **Infrastructure as Code (IaC)**, automated system bootstrap hooks, and interactive shell guardrails.

The toolsets contained herein bridge the gap between declarative definitions and runtime operations, implementing **Site Reliability Engineering (SRE)** principles such as environment isolation, explicit dependencies, naming conventions, and automated platform state mechanics.

---

## 📂 Repository Architecture

The project is structured with single-responsibility modular blocks to isolate application lifecycles and backend scopes:

```text
gitops-pipeline-utils/
└── ops/
    └── scripts/
        ├── providers.tf         # Global Terraform engine & provider constraints
        │
        ├── deploy-acr.sh        # Interactive Azure Container Registry deployment engine
        ├── main-acr.tf          # Declarative definition for the secure private registry
        ├── variables-acr.tf     # Strict alphanumeric validation inputs for ACR namespaces
        │
        ├── deploy-vm.sh         # Interactive Self-Hosted DevOps Runner engine
        ├── main-vm.tf           # Provisioning rules for computing nodes, VNets, & firewalls
        ├── variables-vm.tf      # Configuration settings for virtual machine runners
        ├── userdata.sh          # Cloud-Init system daemon setup script (set -e compliant)
        │
        ├── deploy-aks.sh        # Interactive Managed Kubernetes (AKS) engine
        ├── main-aks.tf          # High-Availability multi-zone cluster layout architecture
        └── variables-aks.tf     # Configurable knobs for Pricing Tiers and Node Pools
```
## 🚀 Core Engineering Component Capabilities

1. Interactive Automation Wrappers (deploy-*.sh)

To bypass the natural interactive limitations of declarative engines, all deployments are driven by intelligent shell guardrails. These scripts query the live cloud environment using the Azure CLI before execution:
  
  * Automatic Resource Group Lookup: Verifies whether a targeted Resource Group exists in the active subscription. If found, it automatically maps dependencies and bypasses duplicate resource mapping blocks.
  
  * Consent Gates: If a target Resource Group is missing, the script catches the exception, outputs location recommendations (e.g., centralindia, eastus), and requests explicit operator authorization before creating it.
  
  * Variable Injection: Dynamically feeds runtime parameters straight into the underlying Terraform compiler runtime without relying on static variable files.

2. High-Availability Managed Kubernetes (AKS)

Provisions an enterprise-grade Kubernetes cluster utilizing Azure CNI networking topologies:

  * Multi-Zone Redundancy: Spreads underlying system nodes and user workloads evenly across isolated Availability Zones (['1', '2', '3']) to protect against regional cloud out-of-band events.
  
  * Separated Node Pools: Isolates cluster management pods inside a locked systempool while delegating heavy software microservices onto a dedicated userworkload node pool.
  
  * Modern Identity Profiles: Explicitly activates the native OIDC Issuer and Workload Identity options, allowing pods to safely securely fetch cloud assets via federated credentials instead of static client secrets.

3. Self-Hosted DevOps Runner Linux Nodes (VM)

Sets up an ephemeral, self-updating compute node configured as an active background daemon process runner for build orchestration:

  * Hardened Bootstrapping (userdata.sh): Implements set -e to ensure the boot pipeline halts instantly on upstream package distribution failures.
  
  * Pre-baked Utility Runtimes: Seamlessly downloads and registers the official Microsoft Pipelines agent binaries, Docker Engine container virtualization environments, Python 3 environments, Git, and pinned HashiCorp Terraform binaries during initial kernel setup phases.

4. Secure Private Artifact Storage (ACR)

Deploys a centralized private registry matching standard corporate portal policies:

  * Global Name Safeguards: Employs regex pattern matching within the variable processing layer to block non-alphanumeric characters, underscores, or dashes before they hit cloud network endpoints.
  * Principle of Least Privilege: Disables global administrative account keys (admin_enabled = false) by default, pushing token-based container security mechanics.

🛠️ Local Machine Prerequisites

Ensure your host control platform (e.g., Ubuntu 24.04 LTS, macOS, or WSL2) has the minimum management frameworks active:

  * Terraform CLI: v1.5.0+
  * Azure CLI: Latest stable distribution
  * Access Level: Contributor or Owner role on your active subscription target scope

```Bash
# 1. Authenticate your command-line workspace
az login

# 2. Verify engine connectivity footprints
az account show --output table
terraform version
```
## 💻 Operational Execution Guide

Bypass standard terraform plan or terraform apply commands completely. Run the orchestration wrapper matching your target deployment scope:

  Deploying the Azure Container Registry:
  ```Bash
  cd ops/scripts/
  chmod +x deploy-acr.sh
  ./deploy-acr.sh
  ```
  Deploying the Self-Hosted DevOps Agent Node:

  ```Bash
cd ops/scripts/
chmod +x deploy-vm.sh
./deploy-vm.sh
  ```
  Note: This execution loop will request your organization URL and Personal Access Token (PAT) to execute automatic pool enrollment routines. It securely exports your SSH private validation key to runner_private_key.pem upon completion.

  Deploying the Enterprise AKS Cluster:
  ```Bash
cd ops/scripts/
chmod +x deploy-aks.sh
./deploy-aks.sh
  ```
Note: Upon a successful rollout, the system output prints out the exact context synchronization string required to instantly link your local kubectl profile directly to the newly provisioned secure cluster endpoint.

## 🛡️ SRE Design Constraints

  * State Isolation Practice: Do not unify these modules into a single execution root block. Keep networking resources, compute nodes, and orchestrators broken into distinct state timelines to limit blast radiuses.
  * Immutable Location Pattern: Avoid passing structural location flags explicitly down to cluster objects. The wrapper framework ensures that all subordinate components natively inherit geographical configurations directly from their verified parent Resource Group parameters (resourcegroup.location.name).
  * No Code Hardcoding: All environment variables, computing SKUs, pricing definitions, and tokens remain explicitly parametrized. Changes must be driven dynamically via the execution runtime shells.
