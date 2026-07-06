-- 0001_init.sql
-- Initial schema for the ea_state database (Virtual EA platform).
-- Run against database: ea_state

BEGIN;

-- Registry of every pipeline run for correlation and idempotency.
CREATE TABLE IF NOT EXISTS run_registry (
    run_id       TEXT PRIMARY KEY,
    source       TEXT NOT NULL,
    status       TEXT NOT NULL DEFAULT 'started',
    started_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at  TIMESTAMPTZ,
    metadata     JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- Registry of individual messages/items ingested, with dedupe support.
CREATE TABLE IF NOT EXISTS message_registry (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    run_id       TEXT NOT NULL REFERENCES run_registry(run_id),
    dedupe_key   TEXT NOT NULL,
    source       TEXT NOT NULL,
    received_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    payload      JSONB NOT NULL,
    UNIQUE (dedupe_key)
);

CREATE INDEX IF NOT EXISTS idx_message_registry_run_id ON message_registry(run_id);
CREATE INDEX IF NOT EXISTS idx_run_registry_status ON run_registry(status);

COMMIT;
