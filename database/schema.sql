CREATE DATABASE IF NOT EXISTS toeic_master CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE toeic_master;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    target_score INT DEFAULT 800,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    part VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_answer CHAR(1) NOT NULL,
    explanation TEXT NOT NULL,
    audio_url VARCHAR(255) NULL
);

CREATE TABLE user_progress (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    studied_words INT DEFAULT 0,
    completed_tests INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    overall_progress FLOAT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO users (full_name, email, password_hash, target_score)
VALUES ('DangQaDucHung', 'student@toeic.com', '$2b$12$abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstuv', 850);

INSERT INTO questions (part, content, option_a, option_b, option_c, option_d, correct_answer, explanation, audio_url)
VALUES
('Part 5', 'The manager asked all employees to submit their weekly reports _____ Friday noon.', 'at', 'by', 'on', 'for', 'B', 'By is used to indicate a deadline.', NULL),
('Part 2', 'Where is the new marketing brochure?', 'On Mr. Lee''s desk.', 'Next Tuesday.', 'For the conference.', 'I will print it.', 'A', 'The correct response answers the location question directly.', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');

INSERT INTO user_progress (user_id, studied_words, completed_tests, current_streak, overall_progress)
VALUES (1, 128, 6, 12, 0.64);
