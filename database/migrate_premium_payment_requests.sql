USE toeic_master;

CREATE TABLE IF NOT EXISTS premium_payment_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    months INT NOT NULL,
    amount INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    transaction_code VARCHAR(100) NULL,
    note TEXT NULL,
    review_note TEXT NULL,
    reviewed_by INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME NULL,
    INDEX idx_premium_payment_requests_user_id (user_id),
    INDEX idx_premium_payment_requests_status (status),
    INDEX idx_premium_payment_requests_transaction_code (transaction_code),
    INDEX idx_premium_payment_requests_reviewed_by (reviewed_by),
    CONSTRAINT fk_premium_payment_requests_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_premium_payment_requests_reviewed_by
        FOREIGN KEY (reviewed_by) REFERENCES users(id)
);
