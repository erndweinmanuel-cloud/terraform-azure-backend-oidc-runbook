# 03 — GitHub Actions Variables

## Goal

Configure the repository-level variables required for GitHub Actions OIDC authentication.

This step prepares the GitHub side of the trust setup by storing:

- Azure Client ID
- Azure Tenant ID
- Azure Subscription ID

These values are consumed by the workflow during Azure login and Terraform execution.

This step does **not** yet run the workflow.  
It only provides the required configuration values.

---

## 1) Why Variables Are Needed

GitHub Actions needs a small set of Azure identifiers to request an OIDC token and authenticate against Microsoft Entra ID.

These values are **not secrets** in the traditional sense, but they are still configuration inputs that should be stored centrally in the repository settings.

Used values:

| Variable | Purpose |
|---|---|
| `AZURE_CLIENT_ID` | identifies the App Registration / Service Principal |
| `AZURE_TENANT_ID` | identifies the Microsoft Entra tenant |
| `AZURE_SUBSCRIPTION_ID` | identifies the Azure subscription used by Terraform |

---

## 2) Get the Required Azure Values

Get the current subscription and tenant:

```powershell
az account show --query "{subscriptionId:id, tenantId:tenantId}" -o json
```

Expected:

- Subscription ID is returned
- Tenant ID is returned

The Client ID was already created in Step 01:

```powershell
$appId
```

Expected:

- Application (client) ID is available

## 3) Open GitHub Repository Variables

In GitHub, navigate to:

- Repository → Settings
- Secrets and variables
- Actions
- Variables
- New repository variable
- Use repository variables, not environment variables, for this setup.

---

## 4) Create Repository Variables

Create the following variables:

Variable 1

Name:

```text
AZURE_CLIENT_ID
```

Value:

- Application (client) ID of the App Registration

---

Variable 2

Name:

```text
AZURE_TENANT_ID
```

Value:

- Tenant ID from az account show


--- 

Variable 3

Name:

```text
AZURE_SUBSCRIPTION_ID
```
Value:

- Subscription ID from az account show

---

## 5) Verify Variables Exist

After creation, the repository variables page should show:

- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

These variables are later referenced inside the workflow as:

```YAML
${{ vars.AZURE_CLIENT_ID }}
${{ vars.AZURE_TENANT_ID }}
${{ vars.AZURE_SUBSCRIPTION_ID }}
```

---

## 6) Why Variables Instead of Secrets

This implementation uses OIDC and therefore avoids storing any client secret in GitHub.

That means:

- no AZURE_CLIENT_SECRET
- no password-based authentication
- no secret rotation burden for this pipeline

** Only identity references are needed. ** 

Key point:

- OIDC removes the need for a client secret
- the actual authentication token is exchanged dynamically at runtime

---

## Proofs

Recommended screenshots for this step:

- GitHub Actions repository variables page
- variables created successfully

Suggested files:

- [10_github_actions_repository_variables.png](../../proofs/cicd/v1.2-oidc-pipeline/10_github_actions_repository_variables.png)

If you do not want to expose full values publicly, redact them before committing screenshots.

---

Notes

- Repository variables are sufficient for this setup.
- Environment variables are not required unless you want separate environments later.
- Client ID is not a password, but it may still be partially redacted in public proof artifacts.
- Do not create a client secret just to “make it work” — that would defeat the purpose of this OIDC setup.

---

Completion Criteria

Before proceeding to Step 04:

- AZURE_CLIENT_ID exists in repository variables
- AZURE_TENANT_ID exists in repository variables
- AZURE_SUBSCRIPTION_ID exists in repository variables
- values match the Azure identity created in Step 01