ALTER TABLE users
    ADD COLUMN membership_plan VARCHAR(20) NOT NULL DEFAULT 'basic' AFTER target_score,
    ADD COLUMN premium_started_at DATETIME NULL AFTER membership_plan,
    ADD COLUMN premium_expires_at DATETIME NULL AFTER premium_started_at;

ALTER TABLE users
    ADD INDEX idx_users_membership_plan (membership_plan),
    ADD INDEX idx_users_premium_expires_at (premium_expires_at);
