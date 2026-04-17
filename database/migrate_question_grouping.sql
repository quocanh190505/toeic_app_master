USE toeic_master;

SET @db_name = DATABASE();

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'section'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN section VARCHAR(20) NULL AFTER part'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'group_key'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN group_key VARCHAR(100) NULL AFTER section'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'question_order'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN question_order INT NOT NULL DEFAULT 1 AFTER group_key'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'instructions'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN instructions TEXT NULL AFTER question_order'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'shared_content'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN shared_content TEXT NULL AFTER instructions'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'shared_audio_url'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN shared_audio_url VARCHAR(500) NULL AFTER shared_content'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND COLUMN_NAME = 'shared_image_url'
    ),
    'SELECT 1',
    'ALTER TABLE questions ADD COLUMN shared_image_url VARCHAR(500) NULL AFTER shared_audio_url'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND INDEX_NAME = 'idx_questions_section'
    ),
    'SELECT 1',
    'CREATE INDEX idx_questions_section ON questions (section)'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    EXISTS(
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = @db_name
          AND TABLE_NAME = 'questions'
          AND INDEX_NAME = 'idx_questions_group_key'
    ),
    'SELECT 1',
    'CREATE INDEX idx_questions_group_key ON questions (group_key)'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE questions
SET
    section = CASE
        WHEN part BETWEEN 1 AND 4 THEN 'listening'
        ELSE 'reading'
    END,
    question_order = COALESCE(question_order, 1)
WHERE section IS NULL OR section = '';

-- Gan audio demo ngau nhien cho cac part nghe.
-- Part 1 dung file U2 va gan truc tiep tung cau.
UPDATE questions
SET audio_url = ELT(
    1 + FLOOR(RAND(id * 17) * 3),
    '/uploads/audio/U2 File (4).mp3',
    '/uploads/audio/U2 File (6).mp3',
    '/uploads/audio/U2 File (7).mp3'
)
WHERE part = 1;

-- Part 2 dung file U4 va gan truc tiep tung cau.
UPDATE questions
SET audio_url = ELT(
    1 + FLOOR(RAND(id * 29) * 4),
    '/uploads/audio/U4 File (2).MP3',
    '/uploads/audio/U4 File (3).MP3',
    '/uploads/audio/U4 File (5).mp3',
    '/uploads/audio/U4 File (6).mp3'
)
WHERE part = 2;

-- Part 3-4 dung file U8. Neu cau hoi co group_key thi gan shared_audio_url
-- cho ca nhom de 3 cau trong cung mot doan nghe dung chung audio.
UPDATE questions q
JOIN (
    SELECT
        group_key,
        ELT(
            1 + FLOOR(RAND(CRC32(group_key)) * 4),
            '/uploads/audio/A- U8- File 03.mp3',
            '/uploads/audio/A- U8- File 04.mp3',
            '/uploads/audio/A- U8- File 05.mp3',
            '/uploads/audio/A- U8- File 06.mp3'
        ) AS picked_audio
    FROM questions
    WHERE part IN (3, 4)
      AND group_key IS NOT NULL
      AND group_key <> ''
    GROUP BY group_key
) grouped_audio
    ON q.group_key = grouped_audio.group_key
SET q.shared_audio_url = grouped_audio.picked_audio
WHERE q.part IN (3, 4);

-- Truong hop part 3-4 khong co group_key thi van gan audio_url de demo.
UPDATE questions
SET audio_url = ELT(
    1 + FLOOR(RAND(id * 41) * 4),
    '/uploads/audio/A- U8- File 03.mp3',
    '/uploads/audio/A- U8- File 04.mp3',
    '/uploads/audio/A- U8- File 05.mp3',
    '/uploads/audio/A- U8- File 06.mp3'
)
WHERE part IN (3, 4)
  AND (group_key IS NULL OR group_key = '');
