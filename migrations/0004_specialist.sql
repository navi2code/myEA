-- 0004_specialist.sql
-- Sprint 3: specialist work lane - grouped summaries, research digests, review-ready drafts.
-- Run against database: ea_state
-- Idempotent; safe to re-run.
BEGIN;

-- Durable summary + research-digest artifacts produced by the specialist lane.
CREATE TABLE IF NOT EXISTS summary_outputs (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
email_id BIGINT NOT NULL REFERENCES normalized_email(id),
triage_decision_id BIGINT REFERENCES triage_decisions(id),
dedupe_key TEXT NOT NULL,
run_id TEXT,
correlation_id TEXT,
source_class TEXT NOT NULL,
summary_depth TEXT NOT NULL DEFAULT 'shallow' CHECK (summary_depth IN ('shallow','deep')),
group_section TEXT,
summary_text TEXT,
digest JSONB,
is_valid_output BOOLEAN NOT NULL DEFAULT true,
model TEXT,
token_input INTEGER,
token_output INTEGER,
latency_ms INTEGER,
raw_output JSONB,
notion_page_id TEXT,
synced_to_notion BOOLEAN NOT NULL DEFAULT false,
created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_summary_dedupe ON summary_outputs(dedupe_key);
CREATE INDEX IF NOT EXISTS idx_summary_class ON summary_outputs(source_class);
CREATE INDEX IF NOT EXISTS idx_summary_depth ON summary_outputs(summary_depth);
CREATE INDEX IF NOT EXISTS idx_summary_created_at ON summary_outputs(created_at);

-- Review-ready draft artifacts (draft-only; never auto-sent) queued for human review.
CREATE TABLE IF NOT EXISTS draft_artifacts (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
email_id BIGINT NOT NULL REFERENCES normalized_email(id),
triage_decision_id BIGINT REFERENCES triage_decisions(id),
dedupe_key TEXT NOT NULL,
run_id TEXT,
correlation_id TEXT,
draft_type TEXT NOT NULL DEFAULT 'reply' CHECK (draft_type IN ('reply','forward','new')),
subject TEXT,
draft_body TEXT NOT NULL,
rationale TEXT,
status TEXT NOT NULL DEFAULT 'pending_review' CHECK (status IN ('pending_review','approved','rejected','sent')),
is_valid_output BOOLEAN NOT NULL DEFAULT true,
model TEXT,
token_input INTEGER,
token_output INTEGER,
latency_ms INTEGER,
raw_output JSONB,
notion_page_id TEXT,
synced_to_notion BOOLEAN NOT NULL DEFAULT false,
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
reviewed_at TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_draft_dedupe ON draft_artifacts(dedupe_key);
CREATE INDEX IF NOT EXISTS idx_draft_status ON draft_artifacts(status);
CREATE INDEX IF NOT EXISTS idx_draft_created_at ON draft_artifacts(created_at);

COMMIT;
