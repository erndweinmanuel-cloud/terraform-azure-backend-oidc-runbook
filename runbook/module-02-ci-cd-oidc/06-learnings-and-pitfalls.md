# 06 — Learnings and Pitfalls

## Goal

Document the real implementation issues that occurred during the OIDC + GitHub Actions + Terraform backend setup, including root causes and fixes.

This step is intentionally not just a success summary.

It captures the troubleshooting path that turned the setup into a working, reproducible implementation.

---

## 1) Authentication vs Authorization

### Problem

GitHub Actions was able to authenticate to Azure via OIDC, but Terraform still failed.

### Root cause

Authentication and authorization are separate concerns:

- OIDC solved **authentication**
- RBAC permissions were still missing for **authorization**

### Fix

Assign the required Azure RBAC roles to the Service Principal:

- `Contributor` on the workload resource group
- `Storage Blob Data Contributor` on the backend storage account
- `Reader` on the backend storage account

### Learning

A successful OIDC login does **not** mean Terraform has the required permissions.

---

## 2) Terraform Backend Initially Used the Wrong Auth Path

### Problem

Terraform backend access initially failed even though Azure login succeeded.

### Root cause

The `azurerm` backend did not automatically use Azure AD / OIDC for backend access.

Without explicit configuration, Terraform may fall back to auth behavior that expects key-based access or incompatible backend access patterns.

### Fix

Enable Azure AD backend auth explicitly in `backend.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-tfstate-runbook"
  storage_account_name = "sttfstate260221me01"
  container_name       = "tfstate"
  key                  = "runbook.tfstate"

  use_azuread_auth     = true
}
``` 

### Learning

OIDC for Azure login is not enough by itself.
Terraform backend authentication must also be configured correctly.

---

## 3) Contributor Was Not Enough for Backend Access

### Problem

Terraform backend access still failed after workload permissions were assigned.

### Root cause

Contributor on the workload resource group does not grant blob data access to the backend storage account.

### Fix

Grant Storage Blob Data Contributor on the backend storage account scope.

In this implementation, Reader on the backend storage account was also added so Terraform could correctly access backend metadata.

### Learning

Workload resource permissions and backend storage permissions must be scoped separately.

---

## 4) GitHub Actions Variables Were Required Before the Workflow Could Work

### Problem

The workflow initially failed during Azure login.

### Root cause

The required GitHub repository variables were not fully configured:

- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

### Fix

Add all three repository variables under:

- Repository → Settings
- Secrets and variables
- Actions
- Variables

### Learning

OIDC still requires identity references.
It removes secrets, not configuration.

---

## 5) Workflow Permissions Had to Be Explicit

### Problem

OIDC login would not work unless the workflow had the correct permissions block.

### Root cause

GitHub Actions requires explicit permission to request an OIDC token.

### Fix

Add:

```YAML
permissions:
  id-token: write
  contents: read
```

### Learning

Without id-token: write, GitHub cannot issue the token required for Azure OIDC authentication.

---

## 6) Terraform fmt Became a Real Pipeline Gate

### Problem

The pipeline failed even though Azure auth and Terraform logic were mostly correct.

### Root cause

terraform fmt -check -recursive failed because the Terraform files were not formatted according to standard.

### Fix

Run locally:

```powershell
terraform fmt -recursive
```

Then commit and push again.

### Learning

Formatting checks are real CI gates.
A pipeline can fail for quality reasons even when the infrastructure logic is correct.

---

## 7) Repo / Branch Trust Had to Match Exactly

### Problem

The federated credential setup only works if the subject claim matches the real GitHub repo and branch.

### Root cause

OIDC federation is strict.
The subject must match the exact repository and ref.

### Fix

Use the correct federated credential subject:

```text
repo:erndweinmanuel-cloud/terraform-azure-backend-oidc-runbook:ref:refs/heads/main
```

### Learning

OIDC federation is not fuzzy.
Wrong repo name or wrong branch means authentication failure.

---

## 8) Older Failed Runs Are Not a Weakness

### Problem

Multiple failed workflow runs remained visible in GitHub Actions history.

### Interpretation

This is normal during real implementation work.

The failed runs reflected:

- incomplete RBAC
- incorrect backend auth path
- missing variables
- formatting failure
- iterative fixes

### Final outcome

The newest workflow run became green and stable.

### Learning

A working engineering repo does not need a fake “perfect first try” history.
It is better to document the path from failure to stable implementation.

---

## 9) Why This Module Matters Professionally

This module is more than a simple GitHub Actions demo.

It demonstrates:

- Microsoft Entra identity setup
- federated OIDC trust
- RBAC design
- secure backend access
- CI validation with Terraform
- troubleshooting across identity, RBAC, backend auth, and workflow logic

### Learning

The value of this module is not only the final green workflow run, but the fact that the full chain was understood, implemented, debugged, and documented.

---

## Summary of Key Learnings

- OIDC solves authentication, not authorization

- Terraform backend must be explicitly configured for Azure AD auth

- workload scope and backend storage scope must be separated

- GitHub Actions variables are required even without client secrets

- workflow permissions matter

- formatting checks can block a pipeline

- real troubleshooting improves the engineering value of the project

---

## Notes

Screenshots used in this module should be redacted where needed

especially:

- subscription IDs
- tenant IDs
- object IDs
- client IDs
- full Azure resource IDs
- The final green workflow run is the operational reference point
- Older failed runs remain useful as internal implementation history

## Completion Criteria

This module is complete when:

- the final workflow run is green
- OIDC login is proven
- Terraform plan is proven
- the troubleshooting path is documented
- the repo structure clearly separates remote state and CI/CD concerns