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

get_idea(
    con_lab,
    idea_id
)

get_idea_history(
    con_lab,
    idea_id
)

idea$status <- "Ready"
idea$summary$setup_score <- 82
idea$summary$confidence <- "★★★★"
idea$summary$reason <- "Breakout confirmed"

refresh_idea(
    con_lab,
    idea_id,
    idea
)

get_idea(
    con_lab,
    idea_id
)

get_idea_history(
    con_lab,
    idea_id
)