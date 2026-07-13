#========================================================
# ASX Scanner v2
# Configuration
#
# Central configuration for the application.
# No functions should be defined in this file.
#========================================================

config <- list(

  #======================================================
  # Application
  #======================================================

  app = list(

    name = "ASX Scanner",

    version = "2.0.0"

  ),

  #======================================================
  # Paths
  #======================================================

  paths = list(

      database = "data/asx_scanner.sqlite",

      universe = "data/universe.csv",

      raw = "raw",

      cache = "cache",

      logs = "logs"

  ),

  #======================================================
  # Market
  #======================================================

  market = list(

    exchange = "ASX",

    timezone = "Australia/Sydney",

    reference_ticker = "CBA",

    market_close = "16:00",

    update_delay_minutes = 30

  ),

  #======================================================
  # Trading Universe
  #======================================================

  universe = list(

    price_min = 1,

    price_max = 30,

    min_volume = 500000,

    min_dollar_volume = 1000000

  ),

  #======================================================
  # Technical Indicators
  #======================================================

  indicators = list(

    ema_short = 20,

    ema_long = 50,

    high_period = 20,

    rvol_period = 20

  ),

  #======================================================
  # Strategy
  #======================================================

  strategy = list(

    breakout_lookback = 20,

    hold_days = 5

  ),

  #======================================================
  # Database Update
  #======================================================

  update = list(

    history_days = 730,

    retry_attempts = 3,

    batch_size = 100

  ),

  parallel = list(

      enabled = TRUE,

      workers = max(
          1,
          parallel::detectCores(logical = FALSE) - 1
      )
  ),

  #======================================================
  # Metadata Schema
  #======================================================

  metadata_schema = list(

    version = list(
      type = "character",
      default = "2.0.0"
    ),

    latest_database_date = list(
      type = "Date",
      default = NA
    ),

    latest_market_date = list(
      type = "Date",
      default = NA
    ),

    last_update = list(
      type = "POSIXct",
      default = NA
    ),

    rows_added = list(
      type = "integer",
      default = 0L
    ),

    tickers_processed = list(
      type = "integer",
      default = 0L
    ),

    tickers_updated = list(
      type = "integer",
      default = 0L
    ),

    tickers_unchanged = list(
      type = "integer",
      default = 0L
    ),

    tickers_failed = list(
      type = "integer",
      default = 0L
    ),

    update_duration_seconds = list(
      type = "numeric",
      default = 0
    )

  ),

  #======================================================
  # Cache
  #======================================================

  cache = list(

    enabled = TRUE,

    path = "cache",

    metadata_days = 30

  )

)