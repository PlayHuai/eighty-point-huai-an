CREATE TABLE IF NOT EXISTS password_attempts (
    user_id VARCHAR(64) NOT NULL PRIMARY KEY,
    failures INT UNSIGNED NOT NULL DEFAULT 0,
    locked_until DATETIME(6) NULL,
    CONSTRAINT fk_password_attempts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
