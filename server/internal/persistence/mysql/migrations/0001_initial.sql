CREATE TABLE users (
    id VARCHAR(64) NOT NULL PRIMARY KEY,
    phone VARCHAR(32) NULL UNIQUE,
    email VARCHAR(254) NULL UNIQUE,
    username VARCHAR(64) NULL UNIQUE,
    password_hash VARBINARY(255) NOT NULL,
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB;

CREATE TABLE player_profiles (
    user_id VARCHAR(64) NOT NULL PRIMARY KEY,
    nickname VARCHAR(64) NOT NULL,
    avatar VARCHAR(512) NOT NULL DEFAULT '',
    points BIGINT NOT NULL DEFAULT 0,
    rank VARCHAR(32) NOT NULL DEFAULT '青铜',
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT chk_player_profiles_points CHECK (points >= 0),
    CONSTRAINT fk_player_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sessions (
    id VARCHAR(64) NOT NULL PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    token_hash BINARY(32) NOT NULL,
    expires_at TIMESTAMP(6) NOT NULL,
    revoked_at TIMESTAMP(6) NULL,
    device_id VARCHAR(128) NOT NULL DEFAULT '',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    INDEX idx_sessions_user (user_id, expires_at),
    CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE friendships (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    friend_id VARCHAR(64) NOT NULL,
    status VARCHAR(16) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    UNIQUE KEY uq_friendships_pair (user_id, friend_id),
    CONSTRAINT chk_friendships_pair CHECK (user_id <> friend_id),
    CONSTRAINT chk_friendships_status CHECK (status IN ('PENDING', 'ACCEPTED', 'BLOCKED')),
    CONSTRAINT fk_friendships_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_friendships_friend FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rooms (
    id VARCHAR(64) NOT NULL PRIMARY KEY,
    hall_id VARCHAR(32) NOT NULL,
    owner_id VARCHAR(64) NOT NULL,
    status VARCHAR(16) NOT NULL,
    settings_json JSON NOT NULL,
    version BIGINT UNSIGNED NOT NULL DEFAULT 0,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    INDEX idx_rooms_hall_status_updated (hall_id, status, updated_at),
    CONSTRAINT chk_rooms_status CHECK (status IN ('WAITING', 'PLAYING', 'CLOSED')),
    CONSTRAINT fk_rooms_owner FOREIGN KEY (owner_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE room_members (
    room_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    seat_no TINYINT UNSIGNED NULL,
    role VARCHAR(16) NOT NULL,
    joined_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (room_id, user_id),
    UNIQUE KEY uq_room_members_seat (room_id, seat_no),
    CONSTRAINT chk_room_members_seat CHECK (seat_no IS NULL OR seat_no BETWEEN 1 AND 4),
    CONSTRAINT chk_room_members_role CHECK (role IN ('PLAYER', 'SPECTATOR')),
    CONSTRAINT fk_room_members_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    CONSTRAINT fk_room_members_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE game_sessions (
    id VARCHAR(64) NOT NULL PRIMARY KEY,
    room_id VARCHAR(64) NOT NULL,
    config_version BIGINT UNSIGNED NOT NULL,
    status VARCHAR(16) NOT NULL,
    player_mapping JSON NOT NULL,
    state_version BIGINT UNSIGNED NOT NULL DEFAULT 0,
    snapshot LONGBLOB NOT NULL,
    started_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ended_at TIMESTAMP(6) NULL,
    INDEX idx_game_sessions_room_status (room_id, status),
    CONSTRAINT chk_game_sessions_status CHECK (status IN ('ACTIVE', 'SETTLED', 'ABORTED')),
    CONSTRAINT fk_game_sessions_room FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB;

CREATE TABLE hands (
    id VARCHAR(64) NOT NULL PRIMARY KEY,
    game_session_id VARCHAR(64) NOT NULL,
    hand_no INT UNSIGNED NOT NULL,
    status VARCHAR(16) NOT NULL,
    state_version BIGINT UNSIGNED NOT NULL DEFAULT 0,
    snapshot LONGBLOB NOT NULL,
    started_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ended_at TIMESTAMP(6) NULL,
    UNIQUE KEY uq_hands_session_no (game_session_id, hand_no),
    CONSTRAINT chk_hands_status CHECK (status IN ('ACTIVE', 'COMPLETED')),
    CONSTRAINT fk_hands_session FOREIGN KEY (game_session_id) REFERENCES game_sessions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE game_events (
    game_session_id VARCHAR(64) NOT NULL,
    seq BIGINT UNSIGNED NOT NULL,
    hand_id VARCHAR(64) NULL,
    event_type VARCHAR(64) NOT NULL,
    payload JSON NOT NULL,
    actor_id VARCHAR(64) NULL,
    request_id VARCHAR(128) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (game_session_id, seq),
    UNIQUE KEY uq_game_events_request (game_session_id, request_id),
    CONSTRAINT fk_game_events_session FOREIGN KEY (game_session_id) REFERENCES game_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_game_events_hand FOREIGN KEY (hand_id) REFERENCES hands(id),
    CONSTRAINT fk_game_events_actor FOREIGN KEY (actor_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE match_results (
    game_session_id VARCHAR(64) NOT NULL PRIMARY KEY,
    winner VARCHAR(16) NOT NULL,
    level_difference TINYINT UNSIGNED NOT NULL,
    end_type VARCHAR(32) NOT NULL,
    hall_multiplier_bp INT UNSIGNED NOT NULL,
    config_version BIGINT UNSIGNED NOT NULL,
    request_hash BINARY(32) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT chk_match_results_winner CHECK (winner IN ('DEALER', 'DEFENDER')),
    CONSTRAINT chk_match_results_level_difference CHECK (level_difference BETWEEN 1 AND 12),
    CONSTRAINT fk_match_results_session FOREIGN KEY (game_session_id) REFERENCES game_sessions(id)
) ENGINE=InnoDB;

CREATE TABLE point_ledger (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    game_session_id VARCHAR(64) NOT NULL,
    user_id VARCHAR(64) NOT NULL,
    delta BIGINT NOT NULL,
    balance_after BIGINT NOT NULL,
    rank VARCHAR(32) NOT NULL,
    config_version BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UNIQUE KEY uq_point_ledger_game_user (game_session_id, user_id),
    INDEX idx_point_ledger_user_created (user_id, created_at),
    CONSTRAINT chk_point_ledger_balance CHECK (balance_after >= 0),
    CONSTRAINT fk_point_ledger_session FOREIGN KEY (game_session_id) REFERENCES game_sessions(id),
    CONSTRAINT fk_point_ledger_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE chat_messages (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    room_id VARCHAR(64) NULL,
    sender_id VARCHAR(64) NOT NULL,
    recipient_id VARCHAR(64) NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    INDEX idx_chat_room_created (room_id, created_at),
    INDEX idx_chat_private_created (sender_id, recipient_id, created_at),
    CONSTRAINT fk_chat_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
    CONSTRAINT fk_chat_sender FOREIGN KEY (sender_id) REFERENCES users(id),
    CONSTRAINT fk_chat_recipient FOREIGN KEY (recipient_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE config_versions (
    version BIGINT UNSIGNED NOT NULL,
    config_key VARCHAR(128) NOT NULL,
    value JSON NOT NULL,
    effective_at TIMESTAMP(6) NOT NULL,
    operator_id VARCHAR(64) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (version, config_key),
    CONSTRAINT fk_config_versions_operator FOREIGN KEY (operator_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE outbox_events (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(64) NOT NULL,
    aggregate_id VARCHAR(64) NOT NULL,
    payload JSON NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    published_at TIMESTAMP(6) NULL,
    INDEX idx_outbox_unpublished (published_at, id)
) ENGINE=InnoDB;
