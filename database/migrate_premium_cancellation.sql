ALTER TABLE users
    ADD COLUMN premium_cancel_at_period_end BOOLEAN NOT NULL DEFAULT FALSE AFTER premium_expires_at;
