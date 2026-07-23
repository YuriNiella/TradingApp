#========================================================
# Database Status Service
#========================================================

library(DBI)

#--------------------------------------------------------
# Get database status
#--------------------------------------------------------

get_database_status <- function(con) {

  meta <- DBI::dbGetQuery(
    con,
    "SELECT key, value FROM metadata"
  )

  meta <- stats::setNames(meta$value, meta$key)

  latest_database_date <- as.Date(meta["latest_database_date"])
  last_update <- as.POSIXct(
    meta["last_update"],
    tz = Sys.timezone()
  )

  status <- if (latest_database_date >= (Sys.Date() - 1)) {
    "Up to date"
  } else {
    "Out of date"
  }

  list(
    status = status,
    latest_database_date = latest_database_date,
    last_update = last_update,
    tickers = as.integer(meta["tickers_processed"]),
    tickers_updated = as.integer(meta["tickers_updated"]),
    tickers_failed = as.integer(meta["tickers_failed"]),
    rows_added = as.integer(meta["rows_added"]),
    update_duration = as.numeric(meta["update_duration_seconds"]),
    version = meta["version"]
  )
}