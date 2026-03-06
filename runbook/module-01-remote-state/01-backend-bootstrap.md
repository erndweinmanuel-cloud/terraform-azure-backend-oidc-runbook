# 01 — Remote State Backend Bootstrap (Azure Storage)

## Goal

Create a secure Azure Storage backend for Terraform state.

This includes:

- Dedicated backend resource group
- Storage Account (StorageV2)
- Private blob container
- Blob versioning enabled
- Soft delete enabled
- Optional RBAC for CLI access

---

## 1) Create Backend Resource Group

```powershell
az group create `
  -n rg-tfstate-runbook `
  -l westeurope `
  -o table
  ```

  --- 

## 2) Create Storage Account (secure defaults)
```powershell
az storage account create `
-g rg-tfstate-runbook `
-n sttfstate260221me01 `
-l westeurope `
--sku Standard_LRS `
--kind StorageV2 `
--https-only true `
--allow-blob-public-access false `
--min-tls-version TLS1_2 `
-o table
```

Security decisions:

- HTTPS only
- Public blob access disabled
- Minimum TLS 1.2

  --- 

 ## 3) Create Private Blob Container
 ```poweshell
 az storage container create `
  --name tfstate `
  --account-name sttfstate260221me01 `
  --auth-mode login `
  -o table
  ```

  ---

  ## 4) Enable Versioning + Soft Delete
  ```powershell
  az storage account blob-service-properties update `
  --account-name sttfstate260221me01 `
  --enable-versioning true `
  --enable-delete-retention true `
  --delete-retention-days 7 `
  -o table
  ``` 

  Why:
  - Versioning protects state history
  - Soft delete protects from accidental deletion

  ---

  ## 5) Verify Container is Private
´´´powershell
az storage container show `
  --name tfstate `
  --account-name sttfstate260221me01 `
  --auth-mode login `
  --query "{name:name, publicAccess:properties.publicAccess}" `
  -o json
  ```

 Expected:

 ```json
 {
  "name": "tfstate",
  "publicAccess": null
}
 ```

---

publicAccess = null means the container is private.

## 6) Optional — RBAC (If CLI Shows Permission Error)

If you see:

"You do not have the required permissions needed to perform this operation"

Assign Storage Blob Data Contributor at storage account scope:

```powershell
$me  = az ad signed-in-user show --query id -o tsv

$saId = az storage account show `
  -g rg-tfstate-runbook `
  -n sttfstate260221me01 `
  --query id -o tsv

az role assignment create `
  --assignee-object-id $me `
  --assignee-principal-type User `
  --role "Storage Blob Data Contributor" `
  --scope $saId
  ```

  Wait 1–2 minutes for RBAC propagation.

  ---

  # Completion Criteria

 Before proceeding to Step 02:

- Resource group exists

- Storage account exists

- Container tfstate exists

- Blob versioning enabled

- Public access disabled
