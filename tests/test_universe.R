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

database_initialize(con)

get_universe(con)


DBI::dbExecute(con, "DROP TABLE IF EXISTS universe")

create_universe_table(con)

result <- update_universe(con)

print(result)

get_universe(con)

latest_prices(
    con,
    get_universe(con)
)

u <- get_universe(con)

str(u)

head(u)


u <- download_asx_directory()

names(u)

dim(u)

head(u)


result <- build_universe()

print(result$message)

head(result$data$universe)

str(result$data$universe)


result <- update_database(con)

result$message


