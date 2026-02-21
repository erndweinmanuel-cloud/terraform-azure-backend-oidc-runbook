# 02 — Create a Local-State Workload (baseline)

## Goal

Create a tiny Terraform workload with **local state first**.

Why:
- We need a known local `terraform.tfstate` before we migrate it to Azure backend.
- This makes the migration step reproducible and verifiable.

Workdir:
`infra/workload/01-local-state`

---

## Files

### providers.tf

```hcl
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```
---

### main.tf

```hcl
resource "azurerm_resource_group" "workload" {
  name     = "rg-workload-runbook"
  location = "westeurope"
}
```

---

Run (local state)

```powershell
cd C:\Git\terraform-azure-backend-oidc-runbook\infra\workload\01-local-state

terraform init
terraform apply
```

Confirm with yes if prompted.

--- 

Verify local state exists

```powershell
Get-ChildItem -Force
```

Expected to see:

- .terraform/

- .terraform.lock.hcl

- terraform.tfstate

# Completion Criteria

Before proceeding to Step 03:

- Azure resource group rg-workload-runbook exists

- Local terraform.tfstate exists in the workdir



