---

# Remote State & Locking — Runbook

This repository documents a complete, reproducible setup of:

- Azure Storage backend for Terraform
- Migration from local state to remote state
- Azure Blob lease–based state locking validation

---

## Runbook Navigation

Follow the steps in order:

1. [00 — Prerequisites](runbook/00-prerequisites.md)  
2. [01 — Backend Bootstrap (Azure Storage)](runbook/01-remote-state-backend-bootstrap.md)  
3. [02 — Local State Baseline](runbook/02-local-state-create.md)  
4. [03 — Migrate to Remote State](runbook/03-migrate-to-remote-state.md)  
5. [04 — State Locking Test](runbook/04-locking-test.md)

---

## Backend Architecture

Terraform backend configuration:

- Backend: `azurerm`
- Resource Group: `rg-tfstate-runbook`
- Storage Account: `sttfstate260221me01`
- Container: `tfstate`
- Key: `runbook.tfstate`
- Versioning: enabled
- Soft delete: enabled
- Public access: disabled

---

## Evidence

All verification screenshots are stored here:

- proofs/remote-state/v1.1-remote-state-locking/


Evidence includes:

- Private container validation
- azurerm backend configuration
- Remote state pull + drift check
- Azure Blob lease lock enforcement

---

## Security Design Decisions

- No public blob access
- TLS 1.2 minimum
- Dedicated backend resource group
- Separate state from workload resources
- State locking enforced via Azure Blob lease

---

## Lifecycle

✅ Validated remote state + locking  
✅ Workload resources destroyed (cost control)  
✅ Backend resources destroyed after evidence capture

---

## Status

**v1.1 — Remote Terraform State (Azure Backend)**  
Status: ✅ Completed

---