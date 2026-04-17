CREATE DATABASE IF NOT EXISTS toeic_master
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE toeic_master;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS user_studied_words;
DROP TABLE IF EXISTS vocabulary_words;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS published_test_items;
DROP TABLE IF EXISTS published_tests;
DROP TABLE IF EXISTS question_workflows;
DROP TABLE IF EXISTS question_groups;
DROP TABLE IF EXISTS user_bookmarks;
DROP TABLE IF EXISTS test_attempt_answers;
DROP TABLE IF EXISTS test_attempts;
DROP TABLE IF EXISTS user_progress;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    target_score INT DEFAULT 750,
    membership_plan VARCHAR(20) NOT NULL DEFAULT 'basic',
    premium_started_at DATETIME NULL,
    premium_expires_at DATETIME NULL,
    premium_cancel_at_period_end BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_email (email),
    INDEX idx_users_role (role),
    INDEX idx_users_membership_plan (membership_plan),
    INDEX idx_users_premium_expires_at (premium_expires_at)
);

CREATE TABLE questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    part INT NOT NULL,
    section VARCHAR(20) NULL,
    question_group_id INT NULL,
    difficulty VARCHAR(20) NOT NULL DEFAULT 'medium',
    approval_status VARCHAR(20) NOT NULL DEFAULT 'approved',
    group_key VARCHAR(100) NULL,
    question_order INT NOT NULL DEFAULT 1,
    instructions TEXT NULL,
    shared_content TEXT NULL,
    shared_audio_url VARCHAR(500) NULL,
    shared_image_url VARCHAR(500) NULL,
    content TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_answer VARCHAR(10) NOT NULL,
    explanation TEXT NULL,
    audio_url VARCHAR(500) NULL,
    image_url VARCHAR(500) NULL,
    review_note TEXT NULL,
    source_hash VARCHAR(64) NULL UNIQUE,
    submitted_by INT NULL,
    approved_by INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_questions_part (part),
    INDEX idx_questions_section (section),
    INDEX idx_questions_question_group_id (question_group_id),
    INDEX idx_questions_group_key (group_key),
    INDEX idx_questions_difficulty (difficulty),
    INDEX idx_questions_approval_status (approval_status),
    INDEX idx_questions_submitted_by (submitted_by),
    INDEX idx_questions_approved_by (approved_by),
    CONSTRAINT fk_questions_submitted_by FOREIGN KEY (submitted_by) REFERENCES users(id),
    CONSTRAINT fk_questions_approved_by FOREIGN KEY (approved_by) REFERENCES users(id)
);

CREATE TABLE question_groups (
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

ALTER TABLE questions
    ADD CONSTRAINT fk_questions_question_group
        FOREIGN KEY (question_group_id) REFERENCES question_groups(id);

CREATE TABLE question_workflows (
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

CREATE TABLE user_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    studied_words INT DEFAULT 0,
    completed_tests INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    overall_progress FLOAT DEFAULT 0,
    total_questions_answered INT DEFAULT 0,
    total_correct_answers INT DEFAULT 0,
    highest_score INT DEFAULT 0,
    average_score FLOAT DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_progress_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE test_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    test_type VARCHAR(20) NOT NULL DEFAULT 'mini',
    total_questions INT NOT NULL,
    correct_count INT NOT NULL DEFAULT 0,
    score INT NOT NULL DEFAULT 0,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_test_attempts_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_test_attempts_user_id (user_id),
    INDEX idx_test_attempts_submitted_at (submitted_at)
);

CREATE TABLE published_tests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    test_type VARCHAR(20) NOT NULL DEFAULT 'full',
    part INT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'published',
    total_questions INT NOT NULL DEFAULT 0,
    created_by INT NOT NULL,
    published_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_published_tests_created_by
        FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_published_tests_status (status),
    INDEX idx_published_tests_test_type (test_type),
    INDEX idx_published_tests_published_at (published_at)
);

CREATE TABLE published_test_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    published_test_id INT NOT NULL,
    question_id INT NOT NULL,
    display_order INT NOT NULL DEFAULT 1,
    CONSTRAINT uq_published_test_question UNIQUE (published_test_id, question_id),
    CONSTRAINT uq_published_test_order UNIQUE (published_test_id, display_order),
    CONSTRAINT fk_published_test_items_test
        FOREIGN KEY (published_test_id) REFERENCES published_tests(id) ON DELETE CASCADE,
    CONSTRAINT fk_published_test_items_question
        FOREIGN KEY (question_id) REFERENCES questions(id),
    INDEX idx_published_test_items_test (published_test_id),
    INDEX idx_published_test_items_question (question_id)
);

CREATE TABLE test_attempt_answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_answer VARCHAR(10) NULL,
    correct_answer VARCHAR(10) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    part INT NOT NULL,
    CONSTRAINT uq_attempt_question UNIQUE (attempt_id, question_id),
    CONSTRAINT fk_test_attempt_answers_attempt
        FOREIGN KEY (attempt_id) REFERENCES test_attempts(id),
    CONSTRAINT fk_test_attempt_answers_question
        FOREIGN KEY (question_id) REFERENCES questions(id),
    INDEX idx_test_attempt_answers_attempt_id (attempt_id),
    INDEX idx_test_attempt_answers_question_id (question_id)
);

CREATE TABLE user_bookmarks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_bookmark_question UNIQUE (user_id, question_id),
    CONSTRAINT fk_user_bookmarks_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_bookmarks_question
        FOREIGN KEY (question_id) REFERENCES questions(id),
    INDEX idx_user_bookmarks_user_id (user_id),
    INDEX idx_user_bookmarks_question_id (question_id)
);

CREATE TABLE topics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    image_url VARCHAR(500) NULL
);

CREATE TABLE vocabulary_words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    word VARCHAR(255) NOT NULL UNIQUE,
    meaning TEXT NOT NULL,
    example TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    topic_id INT NULL,
    CONSTRAINT fk_vocabulary_words_topic
        FOREIGN KEY (topic_id) REFERENCES topics(id),
    INDEX idx_vocabulary_words_word (word),
    INDEX idx_vocabulary_words_topic_id (topic_id)
);

CREATE TABLE user_studied_words (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    word_id INT NOT NULL,
    studied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_word UNIQUE (user_id, word_id),
    CONSTRAINT fk_user_studied_words_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_studied_words_word
        FOREIGN KEY (word_id) REFERENCES vocabulary_words(id),
    INDEX idx_user_studied_words_user_id (user_id),
    INDEX idx_user_studied_words_word_id (word_id)
);

CREATE TABLE refresh_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(1000) NOT NULL UNIQUE,
    is_revoked BOOLEAN DEFAULT FALSE,
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refresh_tokens_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_refresh_tokens_user_id (user_id),
    INDEX idx_refresh_tokens_token (token(255))
);

INSERT INTO users (id, full_name, email, password_hash, role, target_score)
VALUES
    (
        1,
        'Admin TOEIC',
        'admin@toeic.com',
        '$2b$12$kkg/a91Ps0ldr796/XnjK.5sfbuy4sef1fnjrst/gKz7BXEuX5Y9G',
        'admin',
        900
    ),
    (
        2,
        'Nguyen Van A',
        'student@toeic.com',
        '$2b$12$kkg/a91Ps0ldr796/XnjK.5sfbuy4sef1fnjrst/gKz7BXEuX5Y9G',
        'user',
        750
    ),
    (
        3,
        'Teacher TOEIC',
        'teacher@toeic.com',
        '$2b$12$kkg/a91Ps0ldr796/XnjK.5sfbuy4sef1fnjrst/gKz7BXEuX5Y9G',
        'teacher',
        850
    ),
    (
        4,
        'Moderator TOEIC',
        'moderator@toeic.com',
        '$2b$12$kkg/a91Ps0ldr796/XnjK.5sfbuy4sef1fnjrst/gKz7BXEuX5Y9G',
        'moderator',
        850
    );

INSERT INTO user_progress (
    user_id,
    studied_words,
    completed_tests,
    current_streak,
    overall_progress,
    total_questions_answered,
    total_correct_answers,
    highest_score,
    average_score
)
VALUES
    (1, 0, 0, 0, 0, 0, 0, 0, 0),
    (2, 12, 3, 5, 68.5, 40, 27, 9, 8.5),
    (3, 0, 0, 0, 0, 0, 0, 0, 0),
    (4, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO topics (id, name, description, image_url)
VALUES
    (1, 'Office', 'Tá»« vá»±ng thÆ°á»ng gáº·p trong mÃ´i trÆ°á»ng cÃ´ng sá»Ÿ.', NULL),
    (2, 'Travel', 'Tá»« vá»±ng vá» du lá»‹ch, sÃ¢n bay vÃ  khÃ¡ch sáº¡n.', NULL);

INSERT INTO vocabulary_words (id, word, meaning, example, topic_id)
VALUES
    (1, 'deadline', 'háº¡n chÃ³t', 'The final deadline is next Monday.', 1),
    (2, 'proposal', 'báº£n Ä‘á» xuáº¥t', 'She submitted a new proposal this morning.', 1),
    (3, 'boarding pass', 'tháº» lÃªn mÃ¡y bay', 'Please show your boarding pass at the gate.', 2),
    (4, 'itinerary', 'lá»‹ch trÃ¬nh', 'Our travel itinerary changed after the storm.', 2);

INSERT INTO user_studied_words (user_id, word_id)
VALUES
    (2, 1),
    (2, 3);

INSERT INTO questions (
    part,
    content,
    option_a,
    option_b,
    option_c,
    option_d,
    correct_answer,
    explanation,
    audio_url,
    image_url
)
VALUES
    (1, 'What is happening in the picture?', 'A man is loading boxes onto a cart.', 'A woman is checking in at a hotel desk.', 'Several passengers are waiting near the gate.', 'A mechanic is repairing a bicycle.', 'A', 'Đây là câu mô tả tranh Part 1. Hãy chọn phương án khớp nhất với hình ảnh.', NULL, NULL),
    (1, 'What is happening in the picture?', 'Two employees are discussing a chart.', 'A customer is paying for groceries.', 'A chef is serving meals at a counter.', 'A driver is washing a car.', 'B', 'Đây là câu mô tả tranh Part 1. Hãy chọn phương án khớp nhất với hình ảnh.', NULL, NULL),
    (1, 'What is happening in the picture?', 'A woman is arranging flowers on a table.', 'A child is drawing on the wall.', 'A man is climbing a ladder outside.', 'Several chairs are being stacked.', 'C', 'Đây là câu mô tả tranh Part 1. Hãy chọn phương án khớp nhất với hình ảnh.', NULL, NULL),
    (1, 'What is happening in the picture?', 'Workers are paving a road.', 'People are lining up at a ticket booth.', 'A clerk is scanning packages.', 'A musician is tuning a piano.', 'D', 'Đây là câu mô tả tranh Part 1. Hãy chọn phương án khớp nhất với hình ảnh.', NULL, NULL),
    (1, 'What is happening in the picture?', 'A technician is examining computer equipment.', 'Customers are trying on shoes.', 'A cyclist is crossing a bridge.', 'Passengers are boarding a train.', 'A', 'Đây là câu mô tả tranh Part 1. Hãy chọn phương án khớp nhất với hình ảnh.', NULL, NULL),
    (1, 'What is happening in the picture?', 'Someone is watering plants in a greenhouse.', 'A waiter is wiping off a table.', 'An artist is painting a mural.', 'A cashier is opening a register.', 'B', 'Đây là câu mô tả tranh Part 1. Hãy chọn phương án khớp nhất với hình ảnh.', NULL, NULL),
    (2, 'Where should the visitors wait?', 'In the reception area.', 'At half past two.', 'With Mr. Taylor.', 'Because the room is full.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Who approved the budget revision?', 'The finance director did.', 'At the quarterly meeting.', 'By email yesterday.', 'A revised schedule.', 'B', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Why is the printer offline?', 'It ran out of paper.', 'Next to the supply closet.', 'A color brochure.', 'For tomorrow''s event.', 'C', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'When will the shipment arrive?', 'Early Friday morning.', 'On the loading dock.', 'A delivery receipt.', 'Because of traffic.', 'D', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'How do I access the staff portal?', 'Use your employee ID and password.', 'It was updated last week.', 'From the IT department.', 'Near the front entrance.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Where should the visitors wait?', 'In the reception area.', 'At half past two.', 'With Mr. Taylor.', 'Because the room is full.', 'B', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Who approved the budget revision?', 'The finance director did.', 'At the quarterly meeting.', 'By email yesterday.', 'A revised schedule.', 'C', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Why is the printer offline?', 'It ran out of paper.', 'Next to the supply closet.', 'A color brochure.', 'For tomorrow''s event.', 'D', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'When will the shipment arrive?', 'Early Friday morning.', 'On the loading dock.', 'A delivery receipt.', 'Because of traffic.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'How do I access the staff portal?', 'Use your employee ID and password.', 'It was updated last week.', 'From the IT department.', 'Near the front entrance.', 'B', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Where should the visitors wait?', 'In the reception area.', 'At half past two.', 'With Mr. Taylor.', 'Because the room is full.', 'C', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Who approved the budget revision?', 'The finance director did.', 'At the quarterly meeting.', 'By email yesterday.', 'A revised schedule.', 'D', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Why is the printer offline?', 'It ran out of paper.', 'Next to the supply closet.', 'A color brochure.', 'For tomorrow''s event.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'When will the shipment arrive?', 'Early Friday morning.', 'On the loading dock.', 'A delivery receipt.', 'Because of traffic.', 'B', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'How do I access the staff portal?', 'Use your employee ID and password.', 'It was updated last week.', 'From the IT department.', 'Near the front entrance.', 'C', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Where should the visitors wait?', 'In the reception area.', 'At half past two.', 'With Mr. Taylor.', 'Because the room is full.', 'D', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Who approved the budget revision?', 'The finance director did.', 'At the quarterly meeting.', 'By email yesterday.', 'A revised schedule.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Why is the printer offline?', 'It ran out of paper.', 'Next to the supply closet.', 'A color brochure.', 'For tomorrow''s event.', 'B', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'When will the shipment arrive?', 'Early Friday morning.', 'On the loading dock.', 'A delivery receipt.', 'Because of traffic.', 'C', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'How do I access the staff portal?', 'Use your employee ID and password.', 'It was updated last week.', 'From the IT department.', 'Near the front entrance.', 'D', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Where should the visitors wait?', 'In the reception area.', 'At half past two.', 'With Mr. Taylor.', 'Because the room is full.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Who approved the budget revision?', 'The finance director did.', 'At the quarterly meeting.', 'By email yesterday.', 'A revised schedule.', 'B', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'Why is the printer offline?', 'It ran out of paper.', 'Next to the supply closet.', 'A color brochure.', 'For tomorrow''s event.', 'C', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'When will the shipment arrive?', 'Early Friday morning.', 'On the loading dock.', 'A delivery receipt.', 'Because of traffic.', 'D', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (2, 'How do I access the staff portal?', 'Use your employee ID and password.', 'It was updated last week.', 'From the IT department.', 'Near the front entrance.', 'A', 'Câu hỏi Part 2 kiểm tra phản xạ nghe hiểu ngắn về câu hỏi và câu đáp phù hợp.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What will happen next?', 'They will review the contract together.', 'They will take a lunch break.', 'They will tour the warehouse.', 'They will print name badges.', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What are the speakers mainly discussing?', 'A delayed product delivery', 'A restaurant reservation', 'A job interview schedule', 'A parking permit renewal', 'D', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What problem does the woman mention?', 'The conference room is unavailable.', 'Her flight was canceled.', 'The invoice contains an error.', 'The website loads too slowly.', 'A', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'What does the man suggest doing?', 'Contacting the supplier directly', 'Hiring an additional assistant', 'Rescheduling the client visit', 'Reducing the advertising budget', 'B', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (3, 'Why is the speaker calling?', 'To confirm a training session', 'To request a refund', 'To announce a promotion', 'To report a missing package', 'C', 'Câu hỏi Part 3 xoay quanh hội thoại ngắn trong môi trường công việc.', NULL, NULL),
    (4, 'According to the talk, what should listeners do next?', 'Submit the completed form at the front desk.', 'Meet in the cafeteria after lunch.', 'Call customer support for assistance.', 'Return the equipment by Friday.', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is being announced?', 'A change in office hours', 'A new employee discount', 'A postponed inspection', 'A revised sales target', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'Who most likely are the listeners?', 'Newly hired staff members', 'Train station passengers', 'Museum tour guides', 'Apartment residents', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is the purpose of the message?', 'To provide event instructions', 'To apologize for a billing mistake', 'To describe a product feature', 'To invite guests to a ceremony', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What does the speaker emphasize?', 'The deadline must be met.', 'Parking is free on weekends.', 'All meals are included.', 'Printed copies are unavailable.', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'According to the talk, what should listeners do next?', 'Submit the completed form at the front desk.', 'Meet in the cafeteria after lunch.', 'Call customer support for assistance.', 'Return the equipment by Friday.', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is being announced?', 'A change in office hours', 'A new employee discount', 'A postponed inspection', 'A revised sales target', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'Who most likely are the listeners?', 'Newly hired staff members', 'Train station passengers', 'Museum tour guides', 'Apartment residents', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is the purpose of the message?', 'To provide event instructions', 'To apologize for a billing mistake', 'To describe a product feature', 'To invite guests to a ceremony', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What does the speaker emphasize?', 'The deadline must be met.', 'Parking is free on weekends.', 'All meals are included.', 'Printed copies are unavailable.', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'According to the talk, what should listeners do next?', 'Submit the completed form at the front desk.', 'Meet in the cafeteria after lunch.', 'Call customer support for assistance.', 'Return the equipment by Friday.', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is being announced?', 'A change in office hours', 'A new employee discount', 'A postponed inspection', 'A revised sales target', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'Who most likely are the listeners?', 'Newly hired staff members', 'Train station passengers', 'Museum tour guides', 'Apartment residents', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is the purpose of the message?', 'To provide event instructions', 'To apologize for a billing mistake', 'To describe a product feature', 'To invite guests to a ceremony', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What does the speaker emphasize?', 'The deadline must be met.', 'Parking is free on weekends.', 'All meals are included.', 'Printed copies are unavailable.', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'According to the talk, what should listeners do next?', 'Submit the completed form at the front desk.', 'Meet in the cafeteria after lunch.', 'Call customer support for assistance.', 'Return the equipment by Friday.', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is being announced?', 'A change in office hours', 'A new employee discount', 'A postponed inspection', 'A revised sales target', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'Who most likely are the listeners?', 'Newly hired staff members', 'Train station passengers', 'Museum tour guides', 'Apartment residents', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is the purpose of the message?', 'To provide event instructions', 'To apologize for a billing mistake', 'To describe a product feature', 'To invite guests to a ceremony', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What does the speaker emphasize?', 'The deadline must be met.', 'Parking is free on weekends.', 'All meals are included.', 'Printed copies are unavailable.', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'According to the talk, what should listeners do next?', 'Submit the completed form at the front desk.', 'Meet in the cafeteria after lunch.', 'Call customer support for assistance.', 'Return the equipment by Friday.', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is being announced?', 'A change in office hours', 'A new employee discount', 'A postponed inspection', 'A revised sales target', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'Who most likely are the listeners?', 'Newly hired staff members', 'Train station passengers', 'Museum tour guides', 'Apartment residents', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is the purpose of the message?', 'To provide event instructions', 'To apologize for a billing mistake', 'To describe a product feature', 'To invite guests to a ceremony', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What does the speaker emphasize?', 'The deadline must be met.', 'Parking is free on weekends.', 'All meals are included.', 'Printed copies are unavailable.', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'According to the talk, what should listeners do next?', 'Submit the completed form at the front desk.', 'Meet in the cafeteria after lunch.', 'Call customer support for assistance.', 'Return the equipment by Friday.', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is being announced?', 'A change in office hours', 'A new employee discount', 'A postponed inspection', 'A revised sales target', 'C', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'Who most likely are the listeners?', 'Newly hired staff members', 'Train station passengers', 'Museum tour guides', 'Apartment residents', 'D', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What is the purpose of the message?', 'To provide event instructions', 'To apologize for a billing mistake', 'To describe a product feature', 'To invite guests to a ceremony', 'A', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (4, 'What does the speaker emphasize?', 'The deadline must be met.', 'Parking is free on weekends.', 'All meals are included.', 'Printed copies are unavailable.', 'B', 'Câu hỏi Part 4 kiểm tra khả năng nắm ý chính từ bài nói ngắn.', NULL, NULL),
    (5, 'The manager asked everyone to submit the report ____ Friday.', 'at', 'by', 'for', 'from', 'B', '"By" được dùng để chỉ hạn chót hoàn thành công việc.', NULL, NULL),
    (5, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Cấu trúc đúng là "responsible for".', NULL, NULL),
    (5, 'All employees must wear their identification badges while they are ____ duty.', 'on', 'in', 'at', 'to', 'A', 'Cụm đúng là "on duty".', NULL, NULL),
    (5, 'The marketing team needs a more ____ strategy before launching the campaign.', 'system', 'systematic', 'systematically', 'systemize', 'B', 'Sau "a more" cần tính từ để bổ nghĩa cho danh từ strategy.', NULL, NULL),
    (5, 'Because the weather conditions were severe, the outdoor concert was ____.', 'cancel', 'canceled', 'canceling', 'cancellation', 'B', 'Sau "was" cần quá khứ phân từ để tạo câu bị động.', NULL, NULL),
    (5, 'The manager asked everyone to submit the report ____ Friday.', 'at', 'by', 'for', 'from', 'B', '"By" được dùng để chỉ hạn chót hoàn thành công việc.', NULL, NULL),
    (5, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Cấu trúc đúng là "responsible for".', NULL, NULL),
    (5, 'All employees must wear their identification badges while they are ____ duty.', 'on', 'in', 'at', 'to', 'A', 'Cụm đúng là "on duty".', NULL, NULL),
    (5, 'The marketing team needs a more ____ strategy before launching the campaign.', 'system', 'systematic', 'systematically', 'systemize', 'B', 'Sau "a more" cần tính từ để bổ nghĩa cho danh từ strategy.', NULL, NULL),
    (5, 'Because the weather conditions were severe, the outdoor concert was ____.', 'cancel', 'canceled', 'canceling', 'cancellation', 'B', 'Sau "was" cần quá khứ phân từ để tạo câu bị động.', NULL, NULL),
    (5, 'The manager asked everyone to submit the report ____ Friday.', 'at', 'by', 'for', 'from', 'B', '"By" được dùng để chỉ hạn chót hoàn thành công việc.', NULL, NULL),
    (5, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Cấu trúc đúng là "responsible for".', NULL, NULL),
    (5, 'All employees must wear their identification badges while they are ____ duty.', 'on', 'in', 'at', 'to', 'A', 'Cụm đúng là "on duty".', NULL, NULL),
    (5, 'The marketing team needs a more ____ strategy before launching the campaign.', 'system', 'systematic', 'systematically', 'systemize', 'B', 'Sau "a more" cần tính từ để bổ nghĩa cho danh từ strategy.', NULL, NULL),
    (5, 'Because the weather conditions were severe, the outdoor concert was ____.', 'cancel', 'canceled', 'canceling', 'cancellation', 'B', 'Sau "was" cần quá khứ phân từ để tạo câu bị động.', NULL, NULL),
    (5, 'The manager asked everyone to submit the report ____ Friday.', 'at', 'by', 'for', 'from', 'B', '"By" được dùng để chỉ hạn chót hoàn thành công việc.', NULL, NULL),
    (5, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Cấu trúc đúng là "responsible for".', NULL, NULL),
    (5, 'All employees must wear their identification badges while they are ____ duty.', 'on', 'in', 'at', 'to', 'A', 'Cụm đúng là "on duty".', NULL, NULL),
    (5, 'The marketing team needs a more ____ strategy before launching the campaign.', 'system', 'systematic', 'systematically', 'systemize', 'B', 'Sau "a more" cần tính từ để bổ nghĩa cho danh từ strategy.', NULL, NULL),
    (5, 'Because the weather conditions were severe, the outdoor concert was ____.', 'cancel', 'canceled', 'canceling', 'cancellation', 'B', 'Sau "was" cần quá khứ phân từ để tạo câu bị động.', NULL, NULL),
    (5, 'The manager asked everyone to submit the report ____ Friday.', 'at', 'by', 'for', 'from', 'B', '"By" được dùng để chỉ hạn chót hoàn thành công việc.', NULL, NULL),
    (5, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Cấu trúc đúng là "responsible for".', NULL, NULL),
    (5, 'All employees must wear their identification badges while they are ____ duty.', 'on', 'in', 'at', 'to', 'A', 'Cụm đúng là "on duty".', NULL, NULL),
    (5, 'The marketing team needs a more ____ strategy before launching the campaign.', 'system', 'systematic', 'systematically', 'systemize', 'B', 'Sau "a more" cần tính từ để bổ nghĩa cho danh từ strategy.', NULL, NULL),
    (5, 'Because the weather conditions were severe, the outdoor concert was ____.', 'cancel', 'canceled', 'canceling', 'cancellation', 'B', 'Sau "was" cần quá khứ phân từ để tạo câu bị động.', NULL, NULL),
    (5, 'The manager asked everyone to submit the report ____ Friday.', 'at', 'by', 'for', 'from', 'B', '"By" được dùng để chỉ hạn chót hoàn thành công việc.', NULL, NULL),
    (5, 'Ms. Lopez is responsible ____ updating the client database each week.', 'for', 'to', 'with', 'by', 'A', 'Cấu trúc đúng là "responsible for".', NULL, NULL),
    (5, 'All employees must wear their identification badges while they are ____ duty.', 'on', 'in', 'at', 'to', 'A', 'Cụm đúng là "on duty".', NULL, NULL),
    (5, 'The marketing team needs a more ____ strategy before launching the campaign.', 'system', 'systematic', 'systematically', 'systemize', 'B', 'Sau "a more" cần tính từ để bổ nghĩa cho danh từ strategy.', NULL, NULL),
    (5, 'Because the weather conditions were severe, the outdoor concert was ____.', 'cancel', 'canceled', 'canceling', 'cancellation', 'B', 'Sau "was" cần quá khứ phân từ để tạo câu bị động.', NULL, NULL),
    (6, 'Please review the attached file and let me know if any information is ____.', 'miss', 'missing', 'missed', 'misses', 'B', 'Sau động từ "is" cần tính từ hoặc hiện tại phân từ đóng vai trò tính từ.', NULL, NULL),
    (6, 'The hotel recently renovated its lobby, ____ now includes a larger seating area.', 'it', 'that', 'which', 'who', 'C', '"Which" dùng để nối mệnh đề quan hệ không xác định.', NULL, NULL),
    (6, 'Customers are encouraged to keep their receipts ____ they need to exchange an item later.', 'unless', 'in case', 'despite', 'although', 'B', '"In case" phù hợp với nghĩa phòng khi cần dùng đến sau này.', NULL, NULL),
    (6, 'The software update will improve performance and ____ several security issues.', 'address', 'addresses', 'addressing', 'addressed', 'A', 'Sau "will" dùng động từ nguyên mẫu.', NULL, NULL),
    (6, 'Please review the attached file and let me know if any information is ____.', 'miss', 'missing', 'missed', 'misses', 'B', 'Sau động từ "is" cần tính từ hoặc hiện tại phân từ đóng vai trò tính từ.', NULL, NULL),
    (6, 'The hotel recently renovated its lobby, ____ now includes a larger seating area.', 'it', 'that', 'which', 'who', 'C', '"Which" dùng để nối mệnh đề quan hệ không xác định.', NULL, NULL),
    (6, 'Customers are encouraged to keep their receipts ____ they need to exchange an item later.', 'unless', 'in case', 'despite', 'although', 'B', '"In case" phù hợp với nghĩa phòng khi cần dùng đến sau này.', NULL, NULL),
    (6, 'The software update will improve performance and ____ several security issues.', 'address', 'addresses', 'addressing', 'addressed', 'A', 'Sau "will" dùng động từ nguyên mẫu.', NULL, NULL),
    (6, 'Please review the attached file and let me know if any information is ____.', 'miss', 'missing', 'missed', 'misses', 'B', 'Sau động từ "is" cần tính từ hoặc hiện tại phân từ đóng vai trò tính từ.', NULL, NULL),
    (6, 'The hotel recently renovated its lobby, ____ now includes a larger seating area.', 'it', 'that', 'which', 'who', 'C', '"Which" dùng để nối mệnh đề quan hệ không xác định.', NULL, NULL),
    (6, 'Customers are encouraged to keep their receipts ____ they need to exchange an item later.', 'unless', 'in case', 'despite', 'although', 'B', '"In case" phù hợp với nghĩa phòng khi cần dùng đến sau này.', NULL, NULL),
    (6, 'The software update will improve performance and ____ several security issues.', 'address', 'addresses', 'addressing', 'addressed', 'A', 'Sau "will" dùng động từ nguyên mẫu.', NULL, NULL),
    (6, 'Please review the attached file and let me know if any information is ____.', 'miss', 'missing', 'missed', 'misses', 'B', 'Sau động từ "is" cần tính từ hoặc hiện tại phân từ đóng vai trò tính từ.', NULL, NULL),
    (6, 'The hotel recently renovated its lobby, ____ now includes a larger seating area.', 'it', 'that', 'which', 'who', 'C', '"Which" dùng để nối mệnh đề quan hệ không xác định.', NULL, NULL),
    (6, 'Customers are encouraged to keep their receipts ____ they need to exchange an item later.', 'unless', 'in case', 'despite', 'although', 'B', '"In case" phù hợp với nghĩa phòng khi cần dùng đến sau này.', NULL, NULL),
    (6, 'The software update will improve performance and ____ several security issues.', 'address', 'addresses', 'addressing', 'addressed', 'A', 'Sau "will" dùng động từ nguyên mẫu.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is suggested about the customer?', 'He placed an order by phone.', 'He is waiting for a replacement item.', 'He canceled his membership.', 'He requested a price quotation.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'According to the article, what is true about the new branch office?', 'It will open next month.', 'It is located near the airport.', 'It only serves online customers.', 'It replaced the main headquarters.', 'C', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What is indicated about the writer of the email?', 'She recently joined the company.', 'She is requesting schedule approval.', 'She works in the accounting department.', 'She will attend the trade fair.', 'D', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'Why was the notice posted?', 'To explain a temporary closure', 'To introduce a new product', 'To recruit part-time workers', 'To advertise a special discount', 'A', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL),
    (7, 'What can be inferred from the memo?', 'The deadline was extended.', 'The budget has already been approved.', 'The speaker is leaving the company.', 'The training session is mandatory.', 'B', 'Câu hỏi Part 7 dựa trên email, thông báo, bài đọc hoặc biểu mẫu ngắn.', NULL, NULL);
INSERT INTO test_attempts (
    user_id,
    test_type,
    total_questions,
    correct_count,
    score
)
VALUES
    (2, 'mini', 3, 2, 2);

INSERT INTO test_attempt_answers (
    attempt_id,
    question_id,
    selected_answer,
    correct_answer,
    is_correct,
    part
)
VALUES
    (1, 1, 'A', 'A', TRUE, 2),
    (1, 2, 'C', 'B', FALSE, 5),
    (1, 3, 'B', 'B', TRUE, 6);

INSERT INTO user_bookmarks (user_id, question_id)
VALUES
    (2, 2);

ALTER TABLE users AUTO_INCREMENT = 5;
ALTER TABLE topics AUTO_INCREMENT = 3;
ALTER TABLE vocabulary_words AUTO_INCREMENT = 5;
ALTER TABLE questions AUTO_INCREMENT = 201;
ALTER TABLE test_attempts AUTO_INCREMENT = 2;

SET FOREIGN_KEY_CHECKS = 1;
