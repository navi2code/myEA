-- 0003_triage.sql
-- Sprint 2: low-value triage and routing schema (Sarvam supervisor + specialist output).
-- Run against database: ea_state
-- Idempotent; safe to re-run.
BEGIN;

-- Durable record of every triage decision emitted by the supervisor/specialist.
CREATE TABLE IF NOT EXISTS triage_decisions (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
email_id BIGINT NOT NULL REFERENCES normalized_email(id),
dedupe_key TEXT NOT NULL,
run_id TEXT,
correlation_id TEXT,
message_id TEXT,
triage_category TEXT NOT NULL,
confidence NUMERIC NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
routing_action TEXT NOT NULL,
risk_flags JSONB NOT NULL DEFAULT '[]'::jsonb,
is_valid_output BOOLEAN NOT NULL DEFAULT true,
raw_output JSONB,
model TEXT,
decided_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_triage_dedupe ON triage_decisions(dedupe_key);

CREATE INDEX IF NOT EXISTS idx_triage_category ON triage_decisions(triage_category);
CREATE INDEX IF NOT EXISTS idx_triage_action ON triage_decisions(routing_action);
CREATE INDEX IF NOT EXISTS idx_triage_decided_at ON triage_decisions(decided_at);

-- Queue of triage decisions routed to a human for manual review.
CREATE TABLE IF NOT EXISTS manual_review_queue (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
email_id BIGINT NOT NULL REFERENCES normalized_email(id),
dedupe_key TEXT NOT NULL,
triage_decision_id BIGINT REFERENCES triage_decisions(id),
reason TEXT NOT NULL,
confidence NUMERIC,
risk_flags JSONB NOT NULL DEFAULT '[]'::jsonb,
status TEXT NOT NULL DEFAULT 'pending',
enqueued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
resolved_at TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_review_dedupe ON manual_review_queue(dedupe_key);
CREATE INDEX IF NOT EXISTS idx_review_status ON manual_review_queue(status);

-- Analytics views over triage decisions (used by monitoring / daily briefing).
CREATE OR REPLACE VIEW v_triage_category_distribution AS
SELECT triage_category,
count(*) AS n,
round(100.0 * count(*) / NULLIF(sum(count(*)) OVER (), 0), 2) AS pct
FROM triage_decisions
GROUP BY triage_category
ORDER BY count(*) DESC;

CREATE OR REPLACE VIEW v_triage_confidence_bands AS
SELECT CASE
WHEN confidence >= 0.9 THEN '0.90-1.00'
WHEN confidence >= 0.7 THEN '0.70-0.89'
WHEN confidence >= 0.5 THEN '0.50-0.69'
ELSE '<0.50'
END AS band,
count(*) AS n
FROM triage_decisions
GROUP BY 1
ORDER BY 1 DESC;

CREATE OR REPLACE VIEW v_triage_invalid_output_rate AS
SELECT count(*) FILTER (WHERE NOT is_valid_output) AS invalid_n,
count(*) AS total_n,
round(100.0 * count(*) FILTER (WHERE NOT is_valid_output) / NULLIF(count(*), 0), 2) AS invalid_pct
FROM triage_decisions;

COMMIT;
