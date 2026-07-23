#========================================================
# Universe Engine
#========================================================

#--------------------------------------------------------
# Update Universe
#--------------------------------------------------------
update_universe <- function(
    con,
    file = config$paths$universe
){

    update_universe_csv(

        con,

        file

    )

}

#--------------------------------------------------------
# Import universe from CSV
#--------------------------------------------------------
update_universe_csv <- function(
    con,
    file
){

    if(!file.exists(file)){

        stop("Universe CSV not found.")

    }

    universe <- read.csv(
        file,
        stringsAsFactors = FALSE
    )

    #----------------------------------------------------
    # Required columns
    #----------------------------------------------------

    required <- c(

        "ticker",

        "company_name",

        "industry_group",

        "listing_date",

        "market_cap"

    )

    missing <- setdiff(

        required,

        names(universe)

    )

    if(length(missing) > 0){

        stop(

            paste(

                "Missing required columns:",

                paste(missing, collapse = ", ")

            )

        )

    }

    #----------------------------------------------------
    # Optional columns
    #----------------------------------------------------

    if(!"active" %in% names(universe)){

        universe$active <- 1L

    }

    universe$updated_at <-

        format(

            Sys.time(),

            "%Y-%m-%d %H:%M:%S"

        )

    #----------------------------------------------------
    # Replace existing universe
    #----------------------------------------------------

    DBI::dbExecute(

        con,

        "DELETE FROM universe"

    )

    # Get table columns
    table_cols <- DBI::dbListFields(con, "universe")

    # Keep only matching columns
    universe <- universe[, intersect(names(universe), table_cols), drop = FALSE]

    DBI::dbWriteTable(
        con,
        "universe",
        universe,
        append = TRUE,
        row.names = FALSE
    )

    make_result(

        success = TRUE,

        message = sprintf(

            "%d securities imported.",

            nrow(universe)

        ),

        rows = nrow(universe)

    )

}

#--------------------------------------------------------
# Get Universe
#--------------------------------------------------------
get_universe <- function(
    con,
    active_only = TRUE
){

    sql <- "

    SELECT
        *
    FROM universe

    "

    universe <- DBI::dbGetQuery(
        con,
        sql
    )

    if(active_only){

        universe <- universe[
            universe$active == 1,
        ]

    }

    latest <- get_latest_prices(con)

    universe <- merge(
        universe,
        latest,
        by = "ticker",
        all.x = TRUE,
        sort = FALSE
    )

    universe

}

get_universe_tickers <- function(
    con,
    active_only = TRUE
){

    sql <- "

        SELECT ticker

        FROM universe

    "

    if(active_only){

        sql <- paste0(

            sql,

            " WHERE active = 1"

        )

    }

    DBI::dbGetQuery(

        con,

        sql

    )$ticker

}

#--------------------------------------------------------
# Apply universe filters
#--------------------------------------------------------
build_scan_universe <- function(con){

    sql <- "
    WITH latest AS (
        SELECT
            p.*,
            ROW_NUMBER() OVER (
                PARTITION BY ticker
                ORDER BY date DESC
            ) AS rn
        FROM prices_daily p
    )
    SELECT
        u.ticker,
        l.close,
        l.volume,
        l.close * l.volume AS dollar_volume
    FROM universe u
    JOIN latest l
        ON u.ticker = l.ticker
    WHERE
        u.active = 1
        AND l.rn = 1
    "

    latest <- DBI::dbGetQuery(con, sql)

    latest |>
        dplyr::filter(
            close >= config$universe$price_min,
            close <= config$universe$price_max,
            volume >= config$universe$min_volume,
            dollar_volume >= config$universe$min_dollar_volume
        ) |>
        dplyr::pull(ticker)
}

#--------------------------------------------------------
# Load Market
#--------------------------------------------------------
load_market <- function(
    con,
    active_only = TRUE
){

    market <- get_universe(
        con,
        active_only = active_only
    )

    #----------------------------------------------------
    # Convert dates
    #----------------------------------------------------

    market$date <- as.Date(
        market$date
    )

    market$updated_at <- as.POSIXct(
        market$updated_at,
        tz = config$market$timezone
    )

    #----------------------------------------------------
    # Dollar Volume
    #----------------------------------------------------

    market$dollar_volume <-

        market$close *

        market$volume

    #----------------------------------------------------
    # Tradable
    #----------------------------------------------------

    market$price_ok <-

        market$close >= config$universe$price_min &

        market$close <= config$universe$price_max

    market$liquidity_ok <-

        market$dollar_volume >=

        config$universe$min_dollar_volume

    market$tradable <-

        market$price_ok &

        market$liquidity_ok

    market

}

#--------------------------------------------------------
# Market Summary
#--------------------------------------------------------
market_summary <- function(
    market
){

    list(

        securities = nrow(market),

        tradable = sum(
            market$tradable,
            na.rm = TRUE
        ),

        average_price = mean(
            market$close,
            na.rm = TRUE
        ),

        average_dollar_volume = mean(
            market$dollar_volume,
            na.rm = TRUE
        )

    )

}

#--------------------------------------------------------
# Latest Prices
#--------------------------------------------------------
get_latest_prices <- function(
    con,
    tickers = NULL
){

    sql <- "

    SELECT p.*

    FROM prices_daily p

    INNER JOIN (

        SELECT

            ticker,

            MAX(date) AS latest_date

        FROM prices_daily

        GROUP BY ticker

    ) latest

    ON p.ticker = latest.ticker

    AND p.date = latest.latest_date

    "

    prices <- DBI::dbGetQuery(
        con,
        sql
    )

    if(!is.null(tickers)){

        prices <- prices[
            prices$ticker %in% tickers,
        ]

    }

    prices

}

#--------------------------------------------------------
# Price History
#--------------------------------------------------------
price_history <- function(
    con,
    ticker
){

    stop("Not implemented.")

}