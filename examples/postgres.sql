-- OpenOutbox v1 (Draft) - Reference PostgreSQL schema

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'openoutbox_status') THEN
    CREATE TYPE openoutbox_status AS ENUM ('PENDING', 'DELIVERING', 'DELIVERED', 'DEAD');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS openoutbox_events (
  event_id        UUID PRIMARY KEY,
  event_type      TEXT NOT NULL,
  occurred_at     TIMESTAMPTZ NOT NULL,
  partition_key   TEXT NOT NULL,

  payload         JSONB NOT NULL,
  headers         JSONB NOT NULL DEFAULT '{}'::jsonb,

  status          openoutbox_status NOT NULL DEFAULT 'PENDING',
  attempts        INTEGER NOT NULL DEFAULT 0,

  available_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  locked_by       TEXT NULL,
  locked_at       TIMESTAMPTZ NULL,

  last_error      TEXT NULL,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Claim queue efficiency
CREATE INDEX IF NOT EXISTS idx_openoutbox_claim
  ON openoutbox_events (status, available_at, created_at);

-- Optional: ordering/debugging per key
CREATE INDEX IF NOT EXISTS idx_openoutbox_partition
  ON openoutbox_events (partition_key, created_at);

-- Optional: quickly find stuck deliveries
CREATE INDEX IF NOT EXISTS idx_openoutbox_delivering_locked_at
  ON openoutbox_events (locked_at)
  WHERE status = 'DELIVERING';
