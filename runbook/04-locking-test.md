# 04 — State Locking Test (Azure Blob Lease)

## Goal

Prove that remote state locking is enforced (Azure Blob lease).
Parallel Terraform runs must be prevented.

Workdir:
`infra/workload/01-local-state`

---

## Setup

Open **two terminals**.

Both terminals must run in the same directory:

```powershell
cd C:\Git\terraform-azure-backend-oidc-runbook\infra\workload\01-local-state
``` 

---

# Terminal 1 — Hold the lock (refresh-only apply)

```powershell
terraform apply -refresh-only -auto-approve -lock-timeout=0s
```

As soon as you see:

- Acquiring state lock...

Immediately run Terminal 2.

---

# Terminal 2 — Attempt plan (should fail)

```powershell
terraform plan -lock-timeout=0s
```

Expected Result:

Terminal 2 must fail with a lock error, e.g.:

- Error acquiring the state lock

- state blob is already locked

This confirms state locking is working.

---

# Evidence

Store screenshots in:

proofs/remote-state/v1.1-remote-state-locking/

Recommended screenshot order:

1. Container is private

2. Backend config

3. Remote state pull + plan (no drift)

4. Locking error (state blob already locked)

---

# Completion Criteria

- Locking error reproduced reliably

- Evidence screenshots stored in the proof folder
