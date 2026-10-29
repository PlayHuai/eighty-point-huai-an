ALTER TABLE chat_messages
    ADD COLUMN request_id VARCHAR(128) NULL AFTER recipient_id,
    ADD UNIQUE KEY uq_chat_sender_request (sender_id, request_id);
