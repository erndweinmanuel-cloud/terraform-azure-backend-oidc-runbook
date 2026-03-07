# 01 — App Registration and Federation

## Goal

Create the Azure identity foundation for secretless GitHub Actions authentication.

This step prepares:

- Microsoft Entra ID App Registration
- Service Principal
- Federated Credential for GitHub Actions OIDC

This step does **not** deploy workload resources yet.  
It only establishes the identity and trust relationship required for CI/CD.

---

## 1) Variables Used in This Runbook

The following values are used consistently in this module:

| Component | Value |
|---|---|
| GitHub Repo | `erndweinmanuel-cloud/terraform-azure-backend-oidc-runbook` |
| App Registration Name | `gha-tf-runbook-oidc` |
| Federated Credential Name | `github-main` |
| GitHub Branch | `main` |
| OIDC Issuer | `https://token.actions.githubusercontent.com` |
| OIDC Audience | `api://AzureADTokenExchange` |

You may change these values, but they must remain consistent in later steps.

---

## 2) Create App Registration

Create the App Registration in Microsoft Entra ID:

```powershell
$repo = "erndweinmanuel-cloud/terraform-azure-backend-oidc-runbook"
$appName = "gha-tf-runbook-oidc"

$appId = az ad app create --display-name $appName --query appId -o tsv
$appId
```

---

## 3) Create Service Principal

Create the Service Principal for the App Registration:

```powershell
$spId = az ad sp create --id $appId --query id -o tsv
$spId
``` 

Expected:

- Service Principal is created successfully
- An object ID is returned

---

## 4) Create Federated Credential (GitHub OIDC Trust)

Create the GitHub OIDC trust for branch main.

Create a file named federated-credential.json:

```json
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:erndweinmanuel-cloud/terraform-azure-backend-oidc-runbook:ref:refs/heads/main",
  "description": "GitHub Actions OIDC for terraform-azure-backend-oidc-runbook",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
```

Apply it:

```powershell
az ad app federated-credential create --id $appId --parameters .\federated-credential.json
```

Expected:

- Federated Credential is created successfully
- GitHub Actions can later exchange an OIDC token for Azure access

---

## 5) Verify App Registration

Verify the App Registration exists:

```powershell
az ad app show --id $appId --query "{displayName:displayName, appId:appId}" -o json
```

Verify the Service Principal exists:

```powershell
az ad sp show --id $spId --query "{displayName:displayName, appId:appId, id:id}" -o json
```

Expected:

- App Registration exists
- Service Principal exists
- Returned IDs match the created identity

---

## 6) Verify Federated Credential

Verify the GitHub federation trust exists:

```powershell
az ad app federated-credential list --id $appId -o table
```

Expected:

- Name: github-main
- Issuer: https://token.actions.githubusercontent.com

Subject matches:
- repo:erndweinmanuel-cloud/terraform-azure-backend-oidc-runbook:ref:refs/heads/main

---

## Proofs

Recommended screenshots for this step:

- App Registration overview
- Service Principal CLI output
- Federated Credential overview / CLI output

Suggested files:

- proofs/cicd/v1.2-oidc-pipeline/00_app-registration_overview.png
- proofs/cicd/v1.2-oidc-pipeline/02_service-principal_created.png
- proofs/cicd/v1.2-oidc-pipeline/05_federated_credential_github.png

---

## Notes

- This setup uses OIDC federation, not client secrets.
- The subject must exactly match repo and branch.
- Authentication and authorization are separate:
  this step creates the identity and trust, but not RBAC access.
- federated-credential.json should not be kept in the public repo long-term unless intentionally documented.
- Add federated-credential.json to .gitignore.

## Completion Criteria

Before proceeding to Step 02:

- App Registration exists
- Service Principal exists
- Federated Credential exists
- GitHub repo + branch trust is configured correctly