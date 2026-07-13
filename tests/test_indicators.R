#========================================================
# Indicators Test
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

result <- scan_ticker(
    con,
    "CBA"
)

result$success

result$data$summary

result$data$analysis

result <- scan_market(

    con,

    tickers = c(

        "CBA",
        "BHP",
        "CSL",
        "MQG",
        "XRO"

    )

)

scan_ticker(
     con,
     "BHP"
 )$data$analysis