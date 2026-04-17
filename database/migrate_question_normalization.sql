CREATE TABLE IF NOT EXISTS question_groups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_key VARCHAR(100) NOT NULL UNIQUE,
    part INT NOT NULL,
    section VARCHAR(20) NULL,
    instructions TEXT NULL,
    shared_content TEXT NULL,
    shared_audio_url VARCHAR(500) NULL,
    shared_image_url VARCHAR(500) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_question_groups_part (part),
    INDEX idx_question_groups_section (section)
);

CREATE TABLE IF NOT EXISTS question_workflows (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    difficulty VARCHAR(20) NOT NULL DEFAULT 'medium',
    approval_status VARCHAR(20) NOT NULL DEFAULT 'approved',
    review_note TEXT NULL,
    source_hash VARCHAR(64) NULL,
    submitted_by INT NULL,
    approved_by INT NULL,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME NULL,
    CONSTRAINT uq_question_workflows_question UNIQUE (question_id),
    CONSTRAINT uq_question_workflows_source_hash UNIQUE (source_hash),
    CONSTRAINT fk_question_workflows_question FOREIGN KEY (question_id) REFERENCES questions(id),
    CONSTRAINT fk_question_workflows_submitted_by FOREIGN KEY (submitted_by) REFERENCES users(id),
    CONSTRAINT fk_question_workflows_approved_by FOREIGN KEY (approved_by) REFERENCES users(id),
    INDEX idx_question_workflows_difficulty (difficulty),
    INDEX idx_question_workflows_approval_status (approval_status),
    INDEX idx_question_workflows_submitted_at (submitted_at)
);

ALTER TABLE questions
    ADD COLUMN question_group_id INT NULL,
    ADD INDEX idx_questions_question_group_id (question_group_id),
    ADD CONSTRAINT fk_questions_question_group
        FOREIGN KEY (question_group_id) REFERENCES question_groups(id);
