#========================================================
# Database Engine Test
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
    config$database$path
)

database_initialize(con)

print(database_health(con))

print(database_summary(con))

print(metadata_list(con))

database_disconnect(con)


cat("\nLatest database date:\n")

print(
    get_latest_database_date(con)
)

cat("\nLatest CBA date:\n")

print(
    get_latest_ticker_date(con, "CBA")
)

cat("\nDatabase empty?\n")

print(
    database_is_empty(con)
)


cat("\nLatest market date:\n")
print(get_latest_market_date())

cat("\nDatabase needs update?\n")
print(database_needs_update(con))

cat("\nFetch CBA:\n")

df <- fetch_yahoo(
    "CBA",
    Sys.Date()-30
)

str(df)

result <- update_ticker(

    con,

    "CBA"

)

str(result)


progress_console <- function(current, total, ticker){

    cat(
        sprintf(
            "[%d/%d] Updating %s\n",
            current,
            total,
            ticker
        )
    )

}

result <- update_database(

    con,

    c(
        "CBA",
        "BHP",
        "CSL"
    ),

    progress_callback = progress_console

)

cat("\nSummary\n")
print(result$data$summary)

cat("\nMessage\n")
print(result$message)

cat("\nMetadata\n")
print(metadata_list(con))


cat("\nDatabase Status\n")

status <- database_status(con)

str(status)

print(status$data)


cat("\nMetadata types\n")

print(class(metadata_get(con,"rows_added")))

print(class(metadata_get(con,"tickers_updated")))

print(class(metadata_get(con,"latest_database_date")))

print(class(metadata_get(con,"last_update")))


# Test database








