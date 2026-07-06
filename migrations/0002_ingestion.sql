-- 0002_ingestion.sql
-- Sprint 1: trigger layer + Gmail ingestion pipeline schema.
-- Run against database: ea_state
BEGIN;

-- Registry of documented trigger definitions (Cloud Scheduler jobs, manual, etc.).
CREATE TABLE IF NOT EXISTS trigger_registry (
trigger_id TEXT PRIMARY KEY,
run_type TEXT NOT NULL CHECK (run_type IN ('scheduled','gmail','calendar','manual')),
scheduler_job TEXT,
schedule_cron TEXT,
enabled BOOLEAN NOT NULL DEFAULT true,
description TEXT,
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Correlation + run-type context on each run for the workflow envelope.
ALTER TABLE run_registry ADD COLUMN IF NOT EXISTS run_type TEXT;
ALTER TABLE run_registry ADD COLUMN IF NOT EXISTS correlation_id TEXT;
ALTER TABLE run_registry ADD COLUMN IF NOT EXISTS trigger_id TEXT REFERENCES trigger_registry(trigger_id);
ALTER TABLE run_registry ADD COLUMN IF NOT EXISTS envelope JSONB NOT NULL DEFAULT '{}'::jsonb;

-- Durable normalized email records (HTML stripped, quotes trimmed, attachments staged to GCS).
CREATE TABLE IF NOT EXISTS normalized_email (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
dedupe_key TEXT NOT NULL UNIQUE,
run_id TEXT NOT NULL REFERENCES run_registry(run_id),
correlation_id TEXT NOT NULL,
message_id TEXT NOT NULL,
thread_id TEXT,
rfc822_message_id TEXT,
category TEXT NOT NULL DEFAULT 'primary' CHECK (category = 'primary'),
received_at TIMESTAMPTZ NOT NULL,
from_email TEXT NOT NULL,
from_name TEXT,
subject TEXT,
body_text TEXT,
has_attachments BOOLEAN NOT NULL DEFAULT false,
attachments JSONB NOT NULL DEFAULT '[]'::jsonb,
labels JSONB NOT NULL DEFAULT '[]'::jsonb,
payload JSONB NOT NULL DEFAULT '{}'::jsonb,
ingested_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_normalized_email_run_id ON normalized_email(run_id);
CREATE INDEX IF NOT EXISTS idx_normalized_email_thread_id ON normalized_email(thread_id);
CREATE INDEX IF NOT EXISTS idx_normalized_email_received_at ON normalized_email(received_at);
CREATE INDEX IF NOT EXISTS idx_run_registry_correlation_id ON run_registry(correlation_id);

COMMIT;
