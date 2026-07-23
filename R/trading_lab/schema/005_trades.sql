--======================================================
-- Trades
--======================================================

CREATE TABLE IF NOT EXISTS trades (

    trade_id INTEGER PRIMARY KEY AUTOINCREMENT,

    idea_id INTEGER NOT NULL,

    created_datetime TEXT NOT NULL,

    updated_datetime TEXT NOT NULL,

    status TEXT NOT NULL,

    scanner_setup TEXT,

    scanner_score REAL,

    scanner_entry REAL,

    scanner_stop REAL,

    scanner_target REAL,

    atr REAL,

    atr_multiplier REAL,

    risk_reward REAL,

    planned_entry REAL,

    planned_stop REAL,

    planned_target REAL,

    capital REAL,

    planned_shares INTEGER,

    actual_shares INTEGER,

    actual_entry REAL,

    actual_exit REAL,

    actual_stop REAL,

    fees REAL,

    entry_datetime TEXT,

    exit_datetime TEXT,

    exit_reason TEXT,

    profit REAL,

    profit_pct REAL,

    R_multiple REAL,

    comments TEXT,

    FOREIGN KEY (idea_id)
        REFERENCES ideas(idea_id)
        ON DELETE CASCADE

);
