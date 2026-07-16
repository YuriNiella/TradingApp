--======================================================
-- Ideas
--======================================================

CREATE TABLE IF NOT EXISTS ideas (

    idea_id INTEGER PRIMARY KEY AUTOINCREMENT,

    ticker TEXT NOT NULL,

    created_datetime TEXT NOT NULL,

    updated_datetime TEXT NOT NULL,

    source TEXT NOT NULL,

    status TEXT NOT NULL,

    initial_setup TEXT,

    initial_score REAL,

    initial_reason TEXT,

    initial_price REAL,

    notes TEXT

);
