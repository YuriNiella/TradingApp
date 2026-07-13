#--------------------------------------------------------
# prices_daily
#--------------------------------------------------------
create_prices_table <- function(con){

  DBI::dbExecute(con, "

    CREATE TABLE IF NOT EXISTS prices_daily(

      ticker TEXT NOT NULL,

      date TEXT NOT NULL,

      open REAL,

      high REAL,

      low REAL,

      close REAL,

      adj_close REAL,

      volume INTEGER,

      PRIMARY KEY(ticker,date)

    )

  ")

  DBI::dbExecute(con, "

    CREATE INDEX IF NOT EXISTS idx_prices_ticker_date

    ON prices_daily(ticker,date)

  ")

}


#--------------------------------------------------------
# signals_history
#--------------------------------------------------------
create_signals_table <- function(con){

  DBI::dbExecute(con, "

    CREATE TABLE IF NOT EXISTS signals_history(

      ticker TEXT,

      scan_date TEXT,

      setup_type TEXT,

      lifecycle TEXT,

      score REAL,

      market_regime TEXT,

      trend_score REAL,

      momentum_score REAL,

      volume_score REAL,

      risk_score REAL,

      entry_price REAL,

      exit_price REAL,

      return_1d REAL,

      return_3d REAL,

      return_5d REAL,

      return_10d REAL,

      mfe REAL,

      mae REAL,

      PRIMARY KEY(ticker,scan_date)

    )

  ")

}


#--------------------------------------------------------
# metadata
#--------------------------------------------------------
create_metadata_table <- function(con){

  DBI::dbExecute(con, "

    CREATE TABLE IF NOT EXISTS metadata(

      key TEXT PRIMARY KEY,

      value TEXT

    )

  ")

}


#--------------------------------------------------------
# update_log
#--------------------------------------------------------
create_update_log_table <- function(con){

  DBI::dbExecute(con, "

    CREATE TABLE IF NOT EXISTS update_log(

      timestamp TEXT,

      ticker TEXT,

      status TEXT,

      rows INTEGER,

      message TEXT

    )

  ")

}

#--------------------------------------------------------
# Universe table
#--------------------------------------------------------
create_universe_table <- function(con){

    DBI::dbExecute(

        con,

        "

        CREATE TABLE IF NOT EXISTS universe(

            ticker TEXT PRIMARY KEY,

            company_name TEXT,

            industry_group TEXT,

            listing_date TEXT,

            market_cap REAL,

            active INTEGER DEFAULT 1,

            updated_at TEXT

        )

        "

    )

}