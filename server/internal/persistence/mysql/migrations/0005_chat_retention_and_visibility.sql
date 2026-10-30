ALTER TABLE chat_messages
    ADD COLUMN expires_at TIMESTAMP(6) NULL AFTER created_at,
    ADD COLUMN reported_at TIMESTAMP(6) NULL AFTER expires_at;

UPDATE chat_messages
SET expires_at = DATE_ADD(created_at, INTERVAL 30 DAY)
WHERE room_id IS NULL AND expires_at IS NULL;

CREATE TABLE IF NOT EXISTS chat_message_hides (
    message_id BIGINT UNSIGNED NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    hidden_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (message_id, user_id),
    CONSTRAINT fk_chat_message_hides_message FOREIGN KEY (message_id)
        REFERENCES chat_messages(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_message_hides_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chat_message_reports (
    message_id BIGINT UNSIGNED NOT NULL,
    reporter_id VARCHAR(64) NOT NULL,
    reason VARCHAR(1000) NOT NULL DEFAULT '',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (message_id, reporter_id),
    CONSTRAINT fk_chat_message_reports_message FOREIGN KEY (message_id)
        REFERENCES chat_messages(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_message_reports_reporter FOREIGN KEY (reporter_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
