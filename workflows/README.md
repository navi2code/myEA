# workflows/

Exported n8n workflow definitions (JSON) for the Virtual EA platform.

## Conventions

- One file per workflow, named after the workflow (e.g. `gmail-primary-ingestion.json`).
- Export via **n8n > workflow > ... > Download** and commit the raw JSON.
- Do **not** commit credentials — n8n exports reference credentials by id only; secrets stay in n8n / Secret Manager.
- Each workflow should propagate the `run_id` correlation id end-to-end.

## Current workflows (control plane: n8nea-n8n)

| Workflow | Status | Notes |
|----------|--------|-------|
| My workflow 2 | active | primary pipeline |
| Bucketizer Rule Learning (Weekly) | inactive | scheduled learning job |

> Import: in n8n use **Import from File** and re-map credentials after import.
