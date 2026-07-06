# myEA — Virtual EA Platform (monorepo)

Single mono-repo containing the typed contracts, database migrations, n8n workflows, and infra-as-code for the Virtual EA platform.

## Structure

| Path | Purpose |
|------|---------|
| `contracts/` | Typed JSON contract schemas (message envelopes, registries) |
| `migrations/` | Ordered SQL migrations for the `ea_state` Postgres database |
| `workflows/` | Exported n8n workflow JSON |
| `infra/` | Cloud SQL / Cloud Run infrastructure-as-code |
| `docs/` | Architecture notes and runbooks |

## Conventions

- **Resource naming:** `ea-*` service accounts, `my-ea-500409-*` buckets, `n8nea-*` platform resources.
- **Labels:** `app=virtual-ea`, `env=prod`, `component=<x>`.
- **Correlation:** every run carries a `run_id` for tracing.

## Environment

- GCP project: `my-ea-500409` (region `europe-west1`)
- Cloud SQL: `n8nea-pg` (PostgreSQL 18.4), database `ea_state`
- Control plane: Cloud Run `n8nea-n8n`, SA `ea-n8n-control-plane@my-ea-500409.iam.gserviceaccount.com`
