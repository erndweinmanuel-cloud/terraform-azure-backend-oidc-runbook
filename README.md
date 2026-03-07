# Terraform Azure Backend + OIDC CI/CD Runbook

Practical Terraform backend and CI/CD foundations for Azure — built with Terraform, GitHub Actions, and Microsoft Entra ID, designed to be reproducible, secure, and portfolio-ready.

---

## Why this repo exists

I wanted a Terraform setup that is not only functional on a local machine, but also production-oriented:

- remote state stored securely in Azure
- state locking validated
- CI/CD authentication without client secrets
- least-privilege RBAC instead of over-scoped access

This repository documents the full path from local Terraform state to a remote Azure backend, and from there to a secretless GitHub Actions pipeline using OIDC.

---

## What’s inside

This repo is organized into two modules:

1. **Module 01 — Remote State (Azure Storage Backend + Locking)**
2. **Module 02 — GitHub Actions CI/CD with OIDC**

Each module contains:

- reproducible runbook steps
- validation steps
- proof artifacts (screenshots)
- real-world learnings and troubleshooting notes

---

## Modules

### Module 01 — Remote State (Azure Storage Backend + Locking)

This module establishes a secure Terraform backend in Azure Storage and validates state locking using Azure Blob lease behavior.

Runbook steps:

1. [00 — Prerequisites](runbook/module-01-remote-state/00-prerequisites.md)
2. [01 — Backend Bootstrap](runbook/module-01-remote-state/01-backend-bootstrap.md)
3. [02 — Local State Baseline](runbook/module-01-remote-state/02-local-state-baseline.md)
4. [03 — Migrate to Remote State](runbook/module-01-remote-state/03-migrate-to-remote-state.md)
5. [04 — State Locking Test](runbook/module-01-remote-state/04-locking-test.md)

Proofs:

- `proofs/remote-state/v1.1-remote-state-locking/`

Validated outcomes:

- Azure Storage backend created successfully
- local Terraform state migrated to remote backend
- backend container verified as private
- blob lease locking verified through parallel execution test

---

### Module 02 — GitHub Actions CI/CD with OIDC

This module adds secretless authentication from GitHub Actions to Azure using OpenID Connect (OIDC), plus least-privilege RBAC for workload deployment and backend access.

Runbook steps:

### Module 02 — GitHub Actions CI/CD with OIDC

Runbook steps:

1. [00 — App Registration and Federation](runbook/module-02-ci-cd-oidc/00-app-registration-and-federation.md)
2. [01 — RBAC Minimal Scope](runbook/module-02-ci-cd-oidc/01-rbac-minimal-scope.md)
3. [02 — GitHub Actions Variables](runbook/module-02-ci-cd-oidc/02-github-actions-variables.md)
4. [03 — Workflow YAML](runbook/module-02-ci-cd-oidc/03-workflow-yaml.md)
5. [04 — Successful Plan Run](runbook/module-02-ci-cd-oidc/04-successful-plan-run.md)
6. [05 — Learnings and Pitfalls](runbook/module-02-ci-cd-oidc/05-learnings-and-pitfalls.md)

Proofs:

- `proofs/cicd/v1.2-oidc-pipeline/`

Validated outcomes:

- Microsoft Entra ID App Registration created
- Service Principal created and assigned minimal RBAC
- Federated Credential configured for GitHub Actions
- Azure login via OIDC succeeded without client secret
- Terraform init / validate / plan succeeded in GitHub Actions
- current workflow status is healthy

---

## Design principles

- **Security-first**  
  No client secrets, no public blob access, minimum necessary RBAC.

- **Evidence-first**  
  Both modules include proof artifacts and verification steps.

- **Reproducible**  
  The runbooks document the exact implementation path step by step.

- **Separation of concerns**  
  Workload resources and backend/state resources are deliberately separated.

- **Production-minded**  
  Real implementation issues and fixes are documented instead of hidden.

---

## Repository structure

```text
.github/workflows/terraform.yml

infra/
  workload/
    01-local-state/

runbook/
  module-01-remote-state/
    00-prerequisites.md
    01-backend-bootstrap.md
    02-local-state-baseline.md
    03-migrate-to-remote-state.md
    04-locking-test.md

  module-02-ci-cd-oidc/
    01-app-registration-and-federation.md
    02-rbac-minimal-scope.md
    03-github-actions-variables.md
    04-workflow-yaml.md
    05-successful-plan-run.md
    06-learnings-and-pitfalls.md

proofs/
  remote-state/
    v1.1-remote-state-locking/
  cicd/
    v1.2-oidc-pipeline/
 ```
   ---

## Backend architecture

Terraform backend configuration:

- Backend: `azurerm`
- State storage: Azure Storage Account
- State container: private blob container
- State key: `runbook.tfstate`
- Versioning: enabled
- Soft delete: enabled
- Public access: disabled
- Azure AD backend auth: enabled via `use_azuread_auth = true`

---

## Security design decisions

- No public blob access
- TLS 1.2 minimum
- Dedicated backend resource group
- Separate backend and workload scopes
- State locking enforced via Azure Blob lease
- GitHub → Azure trust via OIDC only
- No client secret authentication
- Minimal RBAC for:
  - workload resource group access
  - backend storage access

---

## Learnings & pitfalls

During implementation, several real-world issues occurred and were resolved:

- Terraform backend initially attempted key-based authentication instead of Azure AD authentication
- `use_azuread_auth = true` had to be explicitly enabled in `backend.tf`
- Contributor role alone was not sufficient for backend access
- Backend access required correct storage-scope RBAC
- Authentication (OIDC) and authorization (RBAC) had to be solved separately
- `terraform fmt -check` failed the pipeline until formatting was fixed
- Workflow variables and permissions had to be configured correctly for GitHub Actions OIDC

These issues are documented in:

- [Module 02 — Learnings and Pitfalls](runbook/module-02-ci-cd-oidc/06-learnings-and-pitfalls.md)

---

## Lifecycle

✅ Remote state backend validated  
✅ State locking validated  
✅ OIDC authentication validated  
✅ GitHub Actions Terraform plan validated  

Workload resources can be destroyed and recreated independently.  
The backend is intended to remain available for CI/CD use.

---

## Current status

### v1.1 — Remote Terraform State (Azure Backend)
Status: ✅ Completed

### v1.2 — GitHub Actions CI/CD with OIDC
Status: ✅ Completed

---

## Why this repository matters

This repository does not only show Terraform basics.

It demonstrates:

- secure remote state handling
- state locking validation
- secretless CI/CD authentication
- least-privilege RBAC design
- real troubleshooting and production-style fixes

This makes the project relevant for junior cloud engineering roles focused on Azure, Terraform, secure automation, and platform delivery pipelines.
