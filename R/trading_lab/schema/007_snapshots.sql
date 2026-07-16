--======================================================
-- Snapshots
--======================================================

CREATE TABLE IF NOT EXISTS snapshots (

    snapshot_id INTEGER PRIMARY KEY AUTOINCREMENT,

    idea_id INTEGER,

    trade_id INTEGER,

    snapshot_datetime TEXT NOT NULL,

    snapshot_json TEXT NOT NULL,

    FOREIGN KEY (idea_id)
        REFERENCES ideas(idea_id)
        ON DELETE CASCADE,

    FOREIGN KEY (trade_id)
        REFERENCES trades(trade_id)
        ON DELETE CASCADE

);
