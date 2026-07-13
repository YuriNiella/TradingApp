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

#========================================================
# Dashboard
#========================================================

source("modules/dashboard/ui.R")
source("modules/dashboard/server.R")