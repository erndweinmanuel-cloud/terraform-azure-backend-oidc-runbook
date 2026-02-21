# 00 — Prerequisites

## Goal

Prepare local tooling and Azure access to build:

- Azure Terraform remote state backend (azurerm)
- State migration from local → remote
- Locking validation (Azure Blob lease)

This step only verifies environment readiness.  
No Azure resources are created here.

---

## 1) Local Tooling

Ensure the following tools are installed:

- Azure CLI (`az`)
- Terraform (`terraform`)
- Git (`git`)
- PowerShell (Windows)

Verify versions:

```powershell
az version
terraform version
git --version
``` 

Expected:

- Azure CLI installed

- Terraform ≥ 1.6

- Git installed

---

## 2) Azure Authentication

Login and verify active subscription:
```powershell
az login
az account show --query "{name:name, id:id, user:user.name}" -o json
```

Ensure

- Correct subscription is selected
- You have permission to create resources

If needed:

```powershell
az account list -o table
az account set --subscription "<SUBSCRIPTION_NAME_OR_ID>"
``` 

---

## 3) Naming & Region Used in This Runbook

The following values are used consistently across all steps:

| Component               | Value                 |
| ----------------------- | --------------------- |
| Region                  | `westeurope`          |
| Backend Resource Group  | `rg-tfstate-runbook`  |
| Storage Account         | `sttfstate260221me01` |
| Container               | `tfstate`             |
| State Key               | `runbook.tfstate`     |
| Workload Resource Group | `rg-workload-runbook` |

You may change names, but they must remain consistent throughout the runbook.

---

## 4) Expected Folder Structure

Repository structure:

terraform-azure-backend-oidc-runbook/
├── infra/
│   └── workload/
│       └── 01-local-state/
├── proofs/
│   └── remote-state/
└── runbook/

Workload directory used later:

infra/workload/01-local-state

# Completion Criteria

- Before proceeding to Step 01:

- Azure CLI is authenticated

- Correct subscription is active

- Terraform is installed

- Git repository is initialized