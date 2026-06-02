# Kubernetes Manifest Automation &amp; Bootstrap Toolkit
A collection of production-ready Bash utility scripts designed to automate
Kubernetes manifest updates and credential management within CI/CD pipelines. This
repository serves as a practical reference architecture for DevOps and Site
Reliability Engineering (SRE) workflows.
## 🚀 Core Features
* **Dynamic Manifest Updating:** Automatically updates container image registries,
repository names, and version tags within Kubernetes YAML manifests using
lightweight text processing (`sed`/`awk`).
* **Automated Credential Management:** Scripted commands to cleanly generate,
update, and replace Kubernetes Image Pull Secrets (`docker-registry`) for private
container registries like Azure Container Registry (ACR).
* **Idempotent Execution:** Scripts are designed to safely run multiple times
without causing duplicate configurations or breaking existing pipeline states.
---
## 📁 Repository Structure
```text
├── scripts/
│ ├── update-manifest-image.sh # Script to patch image names &amp; tags
│ └── create-image-pull-secret.sh # Script to handle ACR secret generation
├── templates/
│ └── deployment.tmpl.yaml # Sample manifest template used for validation
└── README.md
```
---
## 🛠️ Detailed Script Overview
### 1. Image Update Automation (`update-manifest-image.sh`)
This script bridges the gap between your build pipeline (e.g., GitHub Actions,
GitLab CI, or Azure Pipelines) and your deployment manifests. It dynamically parses
target YAML files and replaces placeholder values with the newly built artifact
metadata.

* **Key Logic Used:** Safe string substitution using standardized delimiters to
handle complex registry URLs.
* **Pipeline Integration:** Accepts parameters directly from environment variables
or positional arguments (`$1`, `$2`, `$3`).
### 2. Automated Secret Creation (`create-image-pull-secret.sh`)
To pull images from a private Azure Container Registry (ACR), Kubernetes nodes
require authentication. This script completely automates secret provisioning.
* **Idempotency Handling:** Automatically checks if a secret already exists,
deletes the stale credentials, and creates a fresh secret to prevent pipeline
execution halts.
* **Multi-Namespace Support:** Easily parameterized to inject secrets across
different staging or production namespaces.
---
## 💻 Quick Start &amp; Usage Examples
### Updating a Manifest Image
Pass the manifest path, your registry URL, application name, and the pipeline build
tag:
```bash
chmod +x ./scripts/update-manifest-image.sh
./scripts/update-manifest-image.sh &quot;templates/deployment.yaml&quot;
&quot;myregistry.azurecr.io&quot; &quot;my-backend-app&quot; &quot;v1.2.3&quot;
```
### Generating an Image Pull Secret
Pass the secret name, target namespace, ACR server, and your service principal
credentials:
```bash
chmod +x ./scripts/create-image-pull-secret.sh
./scripts/create-image-pull-secret.sh &quot;acr-secret&quot; &quot;production&quot;
&quot;myregistry.azurecr.io&quot; &quot;sp-client-id&quot; &quot;sp-client-secret&quot;
```
---
## 🛡️ Best Practices Demonstrated
1. **Strict Error Handling:** Scripts utilize `set -euo pipefail` to ensure
immediate failure visibility if any underlying command or variable pipe breaks
during execution.
2. **No Hardcoded Secrets:** All sensitive information (passwords, service

principal keys) is consumed purely via environment variables injected securely by
the runtime pipeline.
3. **Lightweight Dependencies:** Built using standard POSIX/Bash commands,
eliminating the need to install heavy external binaries or tools inside minimal
pipeline runner agents.
---
�� *Built as an open-source reference tool for automated deployment workflows an
GitOps foundations.*
