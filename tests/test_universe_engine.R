#========================================================
# Universe Engine Test
#========================================================

# Setting up testing
R
setwd("/Users/yuriniella/Documents/GitHub/YTA/New App")
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


config$parallel$enabled <- TRUE
config$parallel$workers <- parallel::detectCores() - 1

system.time({

    result <- update_database(

        con,

        tickers = get_universe_tickers(con)

    )

})

result$data$summary

failed <- Filter(

    function(x)!x$success,

    result$data$ticker_results

)

length(failed)

sapply(

    failed,

    function(x)x$data$ticker

)

database_status(con)