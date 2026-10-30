ALTER TABLE users
    ADD COLUMN wechat_openid VARCHAR(128) NULL UNIQUE AFTER username;
