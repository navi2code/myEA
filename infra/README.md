# infra/

Infrastructure-as-code and configuration notes for the Virtual EA platform on GCP.

## Environment

| Resource | Value |
|----------|-------|
| Project | `my-ea-500409` |
| Region | `europe-west1` |
| Cloud SQL instance | `n8nea-pg` (PostgreSQL 18.4, Enterprise, 1 vCPU / ~0.6 GB, 10 GB SSD) |
| Database | `ea_state` |
| Control plane | Cloud Run `n8nea-n8n` |
| Control plane SA | `ea-n8n-control-plane@my-ea-500409.iam.gserviceaccount.com` |

## Hardening applied to n8nea-pg

- Deletion protection: **ON**
- IAM database authentication: **ON**
- pgAudit (`cloudsql.enable_pgaudit`): **enabled**
- Password policy: min length 8, complexity on, disallow username in password, restrict reuse (min 5 changes)
- IAM DB user added: `ea-n8n-control-plane@my-ea-500409.iam.gserviceaccount.com`
- Labels: `app=virtual-ea`, `env=prod`

## Least-privilege grants for the IAM DB user (run as admin against ea_state)

```sql
GRANT CONNECT ON DATABASE ea_state TO "ea-n8n-control-plane@my-ea-500409.iam";
GRANT USAGE ON SCHEMA public TO "ea-n8n-control-plane@my-ea-500409.iam";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "ea-n8n-control-plane@my-ea-500409.iam";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "ea-n8n-control-plane@my-ea-500409.iam";
```
