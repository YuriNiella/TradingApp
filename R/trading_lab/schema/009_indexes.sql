--======================================================
-- Indexes
--======================================================

CREATE INDEX idx_ideas_status
ON ideas(status);

CREATE INDEX idx_ideas_ticker
ON ideas(ticker);

CREATE INDEX idx_history_idea
ON idea_history(idea_id);

CREATE INDEX idx_history_date
ON idea_history(snapshot_datetime);

CREATE INDEX idx_trades_status
ON trades(status);

CREATE INDEX idx_trades_idea
ON trades(idea_id);

CREATE INDEX idx_notes_trade
ON trade_notes(trade_id);

CREATE INDEX idx_snapshots_idea
ON snapshots(idea_id);
