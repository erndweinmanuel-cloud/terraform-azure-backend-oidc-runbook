# 03 — Migrate Local State to Remote Backend (azurerm)

## Goal

Move `terraform.tfstate` from local disk to an Azure Storage backend to make the setup:
- team-ready
- CI-ready
- lock-safe (Azure Blob lease)

Workdir:
`infra/workload/01-local-state`

Backend values (from Step 01):
- RG: `rg-tfstate-runbook`
- Storage: `sttfstate260221me01`
- Container: `tfstate`
- Key: `runbook.tfstate`

---

## 1) Create backend.tf (in the workload folder)

File: `infra/workload/01-local-state/backend.tf`

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-runbook"
    storage_account_name = "sttfstate260221me01"
    container_name       = "tfstate"
    key                  = "runbook.tfstate"
  }
}
```

Verify file exists:

```powershell
Get-ChildItem
type .\backend.tf
```

---

## 2) Reconfigure backend (no migration yet)

Terraform CLI does not allow -reconfigure and -migrate-state together.

```powershell
terraform init -reconfigure
```

---

## 3) Migrate local state to remote

```powershell
terraform init -migrate-state
```

Confirm with yes when prompted

---


## 4) Verify blob exists (Azure CLI)

```powershell
az storage blob exists `
  --account-name sttfstate260221me01 `
  --container-name tfstate `
  --name runbook.tfstate `
  --auth-mode login `
  -o json
  ```

  Expected:

```json
   { "exists": true }
```

---

## 5) Verify Terraform reads remote state

```powershell
terraform state pull | Select-Object -First 10
terraform plan
```

Expected:

- state pull returns JSON (remote state content)

- plan shows No changes

--

## 6) Remove local tfstate (after migration proof)

```powershell
Remove-Item -Force .\terraform.tfstate, .\terraform.tfstate.backup -ErrorAction SilentlyContinue
```

Verify:

```powershell
Get-ChildItem -Force
```

Expected:

- no terraform.tfstate anymore

- .terraform/ and .terraform.lock.hcl remain

---

# Completion Criteria

Before proceeding to Step 04:

- runbook.tfstate exists in Azure Blob container tfstate

- terraform state pull works

- local terraform.tfstate removed