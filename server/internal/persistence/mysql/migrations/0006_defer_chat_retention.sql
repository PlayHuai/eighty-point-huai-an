UPDATE chat_messages
SET expires_at = NULL
WHERE room_id IS NULL AND expires_at IS NOT NULL;
