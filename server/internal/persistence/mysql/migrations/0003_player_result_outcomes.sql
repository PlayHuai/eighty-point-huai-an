ALTER TABLE point_ledger
    ADD COLUMN won BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE point_ledger
SET won = delta > 0;
