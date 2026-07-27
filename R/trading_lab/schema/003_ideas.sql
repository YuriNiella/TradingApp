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

    current_setup TEXT,

    current_score REAL,

    current_reason TEXT,

    current_price REAL,

    planned_entry REAL,

    planned_stop REAL,

    planned_target REAL,

    risk_percent REAL,

    planned_position_size REAL,

    planned_r_multiple REAL,

    planner TEXT,

    notes TEXT

);
