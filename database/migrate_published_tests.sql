CREATE TABLE IF NOT EXISTS published_tests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    test_type VARCHAR(20) NOT NULL DEFAULT 'full',
    part INT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'published',
    total_questions INT NOT NULL DEFAULT 0,
    created_by INT NOT NULL,
    published_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_published_tests_created_by FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_published_tests_status (status),
    INDEX idx_published_tests_test_type (test_type),
    INDEX idx_published_tests_published_at (published_at)
);

CREATE TABLE IF NOT EXISTS published_test_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    published_test_id INT NOT NULL,
    question_id INT NOT NULL,
    display_order INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_published_test_items_test FOREIGN KEY (published_test_id) REFERENCES published_tests(id) ON DELETE CASCADE,
    CONSTRAINT fk_published_test_items_question FOREIGN KEY (question_id) REFERENCES questions(id),
    CONSTRAINT uq_published_test_question UNIQUE (published_test_id, question_id),
    CONSTRAINT uq_published_test_order UNIQUE (published_test_id, display_order),
    INDEX idx_published_test_items_test (published_test_id),
    INDEX idx_published_test_items_question (question_id)
);
