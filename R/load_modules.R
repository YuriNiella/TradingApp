#========================================================
# ASX Scanner v2
# Module Loader
#========================================================

message("Loading application modules...")

#========================================================
# Core Utilities
#========================================================

source("R/helpers.R")

#========================================================
# Database
#========================================================

source("R/database_schema.R")
source("R/database_queries.R")
source("R/database.R")
source("R/metadata.R")

#========================================================
# Market Data
#========================================================

source("R/yahoo.R")
source("R/update.R")
source("R/universe.R")
source("R/market.R")
source("R/indicators.R")

#========================================================
# Infrastructure
#========================================================

source("R/cache.R")
source("R/validation.R")
source("R/app_context.R")
source("R/universe_builder.R")
source("R/indicators.R")
source("R/indicators_engine.R")
source("R/features.R")
source("R/setups.R")
source("R/scoring.R")
source("R/market_structure.R")
source("R/scanner.R")

#========================================================
# Trading Lab
#========================================================
source("R/trading_lab/database.R")
source("R/trading_lab/ideas.R")
source("R/trading_lab/history.R")
source("R/trading_lab/workflow.R")
source("R/trading_lab/snapshots.R")
source("R/trading_lab/constants.R")
source("R/trading_lab/risk.R")
source("R/trading_lab/trades.R")
source("R/trading_lab/watchlist.R")
source("R/trading_lab/promotion.R")
source("R/trading_lab/trade_planner.R")
source("R/trading_lab/idea_modal.R")

#========================================================
# Services
#========================================================
source("R/services/database_status.R")

#========================================================
# Dashboard
#========================================================
source("R/ui/constants.R")
source("R/ui/colours.R")
source("R/ui/theme.R")
source("R/ui/css.R")
source("R/ui/cards.R")
source("R/ui/icons.R")
source("R/ui/datatable.R")






