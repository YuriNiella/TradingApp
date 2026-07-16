--======================================================
-- Trade Notes
--======================================================

CREATE TABLE IF NOT EXISTS trade_notes (

    note_id INTEGER PRIMARY KEY AUTOINCREMENT,

    trade_id INTEGER NOT NULL,

    note_datetime TEXT NOT NULL,

    note TEXT NOT NULL,

    FOREIGN KEY (trade_id)
        REFERENCES trades(trade_id)
        ON DELETE CASCADE

);
