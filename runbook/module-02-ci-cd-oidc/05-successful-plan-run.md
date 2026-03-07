# 05 — Successful Plan Run

## Goal

Validate that the GitHub Actions workflow can successfully authenticate to Azure via OIDC and execute Terraform plan against the remote backend.

This step proves that:

- GitHub Actions OIDC login works
- Terraform can access the Azure backend
- Terraform init succeeds
- Terraform validate succeeds
- Terraform plan succeeds

This is the first full end-to-end proof of the CI/CD setup.

---

## 1) Trigger the Workflow

The workflow can be triggered in two ways:

### Option A — Automatic on push

Push a commit to `main`:

```powershell
git add .
git commit -m "trigger workflow"
git push
```

Option B — Manual run

In GitHub:

- Repository → Actions
- Select workflow: terraform-oidc
- Click Run workflow

---

## 2) Expected Workflow Path

A successful run should show:

- Checkout
- Azure Login (OIDC)
- Setup Terraform
- Terraform fmt (check)
- Terraform init
- Terraform validate
- Terraform plan

The plan job should end with a green checkmark.

---

## 3) What Was Validated in This Repo

The successful workflow run proved that all previous setup steps were correct:

- App Registration exists
- Service Principal exists
- Federated Credential matches repo + branch
- Repository variables are configured correctly
- OIDC token exchange works
- Terraform backend uses Azure AD authentication
- RBAC roles are sufficient
- Terraform can read remote state and evaluate infrastructure

---

## 4) Verify Successful OIDC Login

Within the workflow run, the Azure Login (OIDC) step should show:

- GitHub issued federated token
- Azure CLI login succeeded
- Subscription was selected successfully

A successful log includes lines similar to:

```text
Azure CLI login succeeds by using OIDC.
```

This is the strongest proof that no client secret was used.

---

## 5) Verify Successful Terraform Plan

The Terraform plan step should complete successfully.

In this repo, the successful result showed:

```text
No changes. Your infrastructure matches the configuration.
```

This confirms:

Terraform backend access is working

state can be read successfully

plan execution is healthy

current infrastructure matches configuration

---

## 6) Why This Was a Key Milestone

This was the point where the full path became operational:

- local Terraform setup
- remote Azure backend
- GitHub Actions workflow
- OIDC-based authentication
- RBAC authorization
- Terraform plan execution

This is the actual handoff point from local-only Terraform to CI-capable Terraform.

---

## 7) Workflow Health Interpretation

The repository contains earlier failed runs during implementation.

That is expected.

Why:

- initial RBAC was incomplete
- backend auth needed adjustment
- terraform fmt -check initially failed
- workflow variables had to be configured correctly

What matters is:

- the newest workflow run is green
- the final workflow configuration is stable
- the troubleshooting path is documented

This reflects real implementation work, not a perfect one-shot lab.

---

## Proofs

Recommended screenshots for this step:

- successful plan job overview
- Terraform plan output
- successful OIDC login output
- workflow overview with latest green run

Suggested files:

- proofs/cicd/v1.2-oidc-pipeline/06_github_actions_terraform_plan_success.png
- proofs/cicd/v1.2-oidc-pipeline/07_github_actions_terraform_plan_output.png
- proofs/cicd/v1.2-oidc-pipeline/08_github_actions_oidc_login_success.png
- proofs/cicd/v1.2-oidc-pipeline/09_github_actions_workflow_success_overview.png

---

## Notes

- Older failed runs should not be deleted; they document the troubleshooting process.
- The final green run is the valid operational reference point.
- For recruiter/readability purposes, screenshots should focus on the latest healthy run.
- This setup currently validates plan; apply remains intentionally manual.

---

## Completion Criteria

Before proceeding to Step 06:

- at least one successful green workflow run exists
- Azure Login (OIDC) succeeded
- Terraform init succeeded
- Terraform validate succeeded
- Terraform plan succeeded
- proof screenshots were captured