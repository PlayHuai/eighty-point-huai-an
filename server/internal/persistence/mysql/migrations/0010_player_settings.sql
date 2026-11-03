ALTER TABLE player_profiles ADD COLUMN show_hand_to_spectators BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN settings_version BIGINT UNSIGNED NOT NULL DEFAULT 1;
CREATE TABLE player_settings_requests (
    user_id VARCHAR(64) NOT NULL,
    request_id VARCHAR(64) NOT NULL,
    expected_version BIGINT UNSIGNED NOT NULL,
    show_hand BOOLEAN NOT NULL,
    result_version BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, request_id),
    CONSTRAINT fk_settings_requests_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
