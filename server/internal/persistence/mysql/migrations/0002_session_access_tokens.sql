ALTER TABLE sessions
    ADD COLUMN access_token_hash BINARY(32) NULL AFTER token_hash,
    ADD COLUMN access_expires_at TIMESTAMP(6) NULL AFTER expires_at,
    ADD UNIQUE KEY uq_sessions_refresh_token (token_hash),
    ADD UNIQUE KEY uq_sessions_access_token (access_token_hash);
