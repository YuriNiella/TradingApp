--======================================================
-- Idea History
--======================================================

CREATE TABLE IF NOT EXISTS idea_history (

    history_id INTEGER PRIMARY KEY AUTOINCREMENT,

    idea_id INTEGER NOT NULL,

    snapshot_datetime TEXT NOT NULL,

    close REAL,

    setup TEXT,

    score REAL,

    triggered INTEGER,

    reason TEXT,

    FOREIGN KEY (idea_id)
        REFERENCES ideas(idea_id)
        ON DELETE CASCADE

);
