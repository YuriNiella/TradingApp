#========================================================
# Trading Lab Test
#========================================================

# Setting up testing
R
setwd("/Users/yuriniella/Documents/GitHub/TradingApp")
quit()
n

shiny::runApp()


# Testing starts
source("config.R")
source("global.R")
source("R/load_modules.R")

con <- database_connect(
    config$paths$database
)

recreate_trading_lab()

con_lab <- connect_trading_lab()

result <- scan_ticker(
    con,
    "BHP"
)

idea_id <- capture_idea(
    con_lab,
    result$data$idea
)

count_ideas(con_lab)

count_idea_history(
    con_lab,
    idea_id
)

count_snapshots(
    con_lab,
    idea_id
)

snapshot <- latest_snapshot(
    con_lab,
    idea_id
)

snapshot$snapshot_json

idea <- decode_snapshot(snapshot)