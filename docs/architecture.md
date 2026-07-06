# Architecture

High-level design for the Virtual EA platform.

## Overview

The platform ingests items from multiple sources, wraps them in a standard
message envelope, deduplicates, and processes them through n8n workflows,
persisting state in a hardened Cloud SQL Postgres database.

## Components

- **Trigger layer** — Cloud Scheduler triggers plus event-driven entry points (Gmail, Calendar, manual).
- **Ingestion** — Gmail primary ingestion with a rolling 24-hour lookback; normalization, HTML stripping, quote trimming, metadata annotation, attachment staging.
- **Control plane** — n8n on Cloud Run (`n8nea-n8n`) orchestrating workflows.
- **State** — Cloud SQL `ea_state` with `run_registry` and `message_registry` tables.
- **Contracts** — typed JSON schemas in `/contracts` shared across workflows.

## Idempotency & correlation

- Every run gets a `run_id` used for correlation across all steps.
- Every ingested item carries a `dedupe_key`; `message_registry` enforces uniqueness so re-runs are safe.
- Bounded dedupe / retry behavior keeps the pipeline idempotent.

## Data flow

```
Trigger -> Envelope creation -> Dedupe check (message_registry)
        -> Normalize/stage -> Persist -> Downstream workflows
```

## Security posture

- IAM database authentication for the control-plane service account (least privilege via GRANTs).
- pgAudit enabled; password policy enforced; deletion protection on.
- Secrets held in n8n / Secret Manager, never committed to this repo.
