# 02 — RBAC Minimal Scope

## Goal

Assign the minimum required Azure RBAC permissions for GitHub Actions OIDC authentication.

This step grants access for:

- workload resource deployment
- Terraform backend storage access

This step does **not** change the GitHub Actions workflow yet.  
It only ensures the Service Principal has the correct authorization scope.

---

## 1) Why RBAC Is Needed

OIDC solves **authentication**.

RBAC solves **authorization**.

That means:

- GitHub Actions can authenticate to Azure via OIDC
- but Terraform still cannot do anything unless the Service Principal has the correct RBAC roles

This is a critical separation of concerns.

---

## 2) Scopes Used in This Runbook

The Service Principal needs access to two different scopes:

| Scope | Purpose | Role |
|---|---|---|
| Workload Resource Group | deploy / read Terraform-managed resources | `Contributor` |
| Backend Storage Account | read / write Terraform state | `Storage Blob Data Contributor` |
| Backend Storage Account | read backend metadata | `Reader` |

---

## 3) Get Required Resource IDs

Get the workload resource group ID:

```powershell
$rgWlId = az group show -n rg-workload-runbook --query id -o tsv
$rgWlId
```

Get the backend storage account ID:

```powershell
$saId = az storage account show -g rg-tfstate-runbook -n sttfstate260221me01 --query id -o tsv
$saId
```

Expected:

- both IDs are returned successfully
- scope paths begin with /subscriptions/...

---

## 4) Assign Contributor on Workload Resource Group

Grant Contributor to the Service Principal on the workload resource group:

```powershell
az role assignment create `
  --assignee-object-id $spId `
  --assignee-principal-type ServicePrincipal `
  --role "Contributor" `
  --scope $rgWlId
  ```

  Expected:

- role assignment is created successfully
- Service Principal can manage workload resources in rg-workload-runbook

---

## 5) Assign Storage Blob Data Contributor on Backend Storage

Grant Storage Blob Data Contributor on the backend storage account:

```powershell
az role assignment create `
  --assignee-object-id $spId `
  --assignee-principal-type ServicePrincipal `
  --role "Storage Blob Data Contributor" `
  --scope $saId
  ```

  Expected:

- role assignment is created successfully
- Service Principal can access Terraform state blobs

---

## 6) Assign Reader on Backend Storage

Grant Reader on the backend storage account:

```powershell
az role assignment create `
  --assignee-object-id $spId `
  --assignee-principal-type ServicePrincipal `
  --role "Reader" `
  --scope $saId
  ``` 

  Expected:

- role assignment is created successfully
- Service Principal can read backend storage metadata

---

## 7) Verify RBAC Assignments

Verify workload resource group RBAC:

```powershell
az role assignment list `
  --assignee-object-id $spId `
  --scope $rgWlId `
  --query "[].{role:roleDefinitionName, scope:scope}" `
  -o table
  ```

  Expected:

  - Contributor

  Verify backend storage RBAC:

  ```powershell
  az role assignment list `
  --assignee-object-id $spId `
  --scope $saId `
  --query "[].{role:roleDefinitionName, scope:scope}" `
  -o table
  ```

  Expected:

  - Storage Blob Data Contributor

  - Reader

  ---

  8) Why These Roles Were Needed

  During implementation, the following issue occurred:

  - OIDC login succeeded
  - but Terraform backend access still failed

  Root cause:

  - authentication was working
  - authorization was incomplete

  Key lesson:

  - Contributor on the workload resource group is not enough
  - Terraform backend access requires separate storage-scope permissions

  ---

  ## Proofs

  Recommended screenshots for this step:

  - Contributor role on workload resource group
  - Storage Blob Data Contributor on backend storage
  - Reader role on backend storage

  Suggested files:

- [03_rbac_contributor_workload_rg.png](../../proofs/cicd/v1.2-oidc-pipeline/03_rbac_contributor_workload_rg.png)
- [04_rbac_storage_blobdatacontributor.png](../../proofs/cicd/v1.2-oidc-pipeline/04_rbac_storage_blobdatacontributor.png)

  ---

  Notes

- Workload scope and backend scope should remain separate.
- This is a better design than assigning broad subscription-level permissions.
- Storage Blob Data Contributor is required for Terraform state operations.
- Reader was required so Terraform could correctly access backend storage metadata.
- In larger environments, these assignments should ideally be handled via IaC or centrally managed RBAC.


---

Completion Criteria

Before proceeding to Step 03:

- Service Principal has Contributor on workload resource group
- Service Principal has Storage Blob Data Contributor on backend storage
- Service Principal has Reader on backend storage
- RBAC verification commands return the expected roles

