# 04 — Workflow YAML

## Goal

Define the GitHub Actions workflow that authenticates to Azure via OIDC and runs Terraform non-interactively.

This step adds:

- GitHub Actions workflow file
- Azure login via OIDC
- Terraform init / validate / plan
- repository variable usage
- working-directory configuration for the Terraform workload

This step does **not** yet focus on troubleshooting.  
It documents the intended, final workflow definition.

---

## 1) Workflow File Location

Create the workflow file here:

```text
.github/workflows/terraform.yml
```

This repository uses a single workflow for:

- Terraform plan on push
- manual workflow execution via workflow_dispatch

---

## 2) Why This Workflow Matters

The workflow connects all previous steps:

- App Registration
- Service Principal
- Federated Credential
- GitHub repository variables
- RBAC
- Terraform backend configuration

Without the workflow, OIDC remains only a configured identity.
This file turns that setup into an actual CI/CD execution path.

---

## 3) Final Workflow YAML

Use this workflow definition:

```YAML
name: terraform-oidc

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

env:
  TF_IN_AUTOMATION: true
  TF_INPUT: false

jobs:
  plan:
    name: plan
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: infra/workload/01-local-state
        shell: bash
    env:
      ARM_USE_OIDC: true
      ARM_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
      ARM_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
      ARM_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.2

      - name: Terraform fmt (check)
        run: terraform fmt -check -recursive

      - name: Terraform init
        run: terraform init -input=false

      - name: Terraform validate
        run: terraform validate

      - name: Terraform plan
        run: terraform plan -input=false -no-color

  apply:
    name: apply
    runs-on: ubuntu-latest
    needs: plan
    if: github.event_name == 'workflow_dispatch'
    environment: apply
    defaults:
      run:
        working-directory: infra/workload/01-local-state
        shell: bash
    env:
      ARM_USE_OIDC: true
      ARM_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
      ARM_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
      ARM_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.14.2

      - name: Terraform init
        run: terraform init -input=false

      - name: Terraform apply
        run: terraform apply -auto-approve -input=false -no-color
```

---

## 4) Key Design Choices

permissions: 

```YAML
permissions:
  id-token: write
  contents: read
```

Why:

- id-token: write is required so GitHub Actions can request an OIDC token
- contents: read is required so the workflow can read repository content

Without these permissions, Azure OIDC login will fail.

---

working-directory:

```YAML
working-directory: infra/workload/01-local-state
```

Why:

- Terraform files live in infra/workload/01-local-state
- running Terraform from repo root would fail or target the wrong location

---

ARM_USE_OIDC

```YAML
ARM_USE_OIDC: true
```

Why:

- Terraform must use OIDC/Azure AD authentication
- without this, the backend may fall back to key-based auth or incompatible auth behavior

---

## Repository Variables

Used variables:

- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

These are consumed in two places:

- Azure Login step
- Terraform environment variables

---

5) Why terraform fmt -check Is Included

The workflow includes:

```bash
terraform fmt -check -recursive
```

Purpose:

- enforce consistent Terraform formatting
- catch formatting drift before plan/apply

This step caused an early pipeline failure during implementation and was kept intentionally as a quality gate.

---

## 6) Apply Job Behavior

The apply job is intentionally restricted:

```YAML
if: github.event_name == 'workflow_dispatch'
environment: apply
```

Why:

- prevent accidental apply on every push
- allow manual execution only
- support environment approval later if desired

This keeps the pipeline safer and more production-minded.

---

## 7) Verify Workflow File Exists

Verify the file is tracked:

```powershell
git status
```

Expected:

- .github/workflows/terraform.yml is present and committed

You can also verify in GitHub:

- Repository → .github/workflows/terraform.yml

---

Proofs

Recommended screenshots for this step:

- workflow YAML visible in repository
- successful workflow run overview
- successful plan job

Suggested files:

- proofs/cicd/v1.2-oidc-pipeline/09_github_actions_workflow_success_overview.png

Optional additional screenshot:

- repository view of .github/workflows/terraform.yml


## Notes

- The workflow depends on all previous module steps being completed first.
- terraform fmt -check can fail the pipeline even if Azure auth is correct.
- apply is intentionally manual and gated.
- The workflow is designed for reproducibility, not maximum complexity.
- For larger projects, plan/apply separation, artifacts, or reusable workflows may be added later.

---

## Completion Criteria

Before proceeding to Step 05:

- workflow file exists in .github/workflows/terraform.yml
- repository variables are configured
- Azure OIDC login step is defined
- Terraform init / validate / plan steps are present
- workflow structure matches the intended final design
        
    
        
        