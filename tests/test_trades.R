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

idea <- result$data$idea

idea_id <- capture_idea(
    con_lab,
    idea
)

trade_id <- create_trade(
    con_lab,
    idea_id,
    idea,
    capital = 20000
)

trade <- get_trade(
    con_lab,
    trade_id
)

trade

update_trade(

    con_lab,

    trade_id,

    planned_entry = 58.20,

    planned_stop = 56.40,

    planned_target = 63.60,

    planned_shares = 95,

    comments = "Waiting for volume confirmation."

)

trade <- get_trade(
    con_lab,
    trade_id
)

trade

open_trade(

    con_lab,

    trade_id,

    actual_entry = 58.18,

    actual_shares = 94,

    actual_stop = 56.35

)

trade <- get_trade(
    con_lab,
    trade_id
)

trade

get_open_trades(con_lab)

open_trade(

    con_lab,

    trade_id,

    actual_entry = 58.20,

    actual_shares = 94

)

close_trade(

    con_lab,

    trade_id,

    actual_exit = 64.20,

    exit_reason = "Target",

    fees = 15

)

trade <- get_trade(
    con_lab,
    trade_id
)

trade

get_closed_trades(con_lab)

close_trade(

    con_lab,

    trade_id,

    actual_exit = 65,

    exit_reason = "Oops"

)

update_trade(

    con_lab,

    trade_id,

    comments = "Changed my mind"

)

trade <- get_trade(
    con_lab,
    trade_id
)

trade

plan <- get_trade_plan(
    con_lab,
    trade_id
)

plan