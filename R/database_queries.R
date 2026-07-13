#--------------------------------------------------------
# Is the database empty?
#--------------------------------------------------------
database_is_empty <- function(con){

    res <- DBI::dbGetQuery(

        con,

        "
        SELECT COUNT(*) AS n
        FROM prices_daily
        "

    )

    res$n == 0

}

#--------------------------------------------------------
# Latest date stored in database
#--------------------------------------------------------
get_latest_database_date <- function(con){

    if(database_is_empty(con)){

        return(NULL)

    }

    res <- DBI::dbGetQuery(

        con,

        "
        SELECT MAX(date) AS latest
        FROM prices_daily
        "

    )

    as.Date(res$latest)

}

#--------------------------------------------------------
# Latest date for a ticker
#--------------------------------------------------------
get_latest_ticker_date <- function(con, ticker){

    res <- DBI::dbGetQuery(

        con,

        "
        SELECT MAX(date) AS latest

        FROM prices_daily

        WHERE ticker = ?

        ",

        params = list(ticker)

    )

    if(nrow(res) == 0 || is.na(res$latest)){

        return(NULL)

    }

    as.Date(res$latest)

}

#--------------------------------------------------------
# Latest dates for all tickers
#--------------------------------------------------------
get_latest_ticker_dates <- function(con){

    latest <- DBI::dbGetQuery(

        con,

        "

        SELECT

            ticker,

            MAX(date) AS latest_date

        FROM prices_daily

        GROUP BY ticker

        "

    )

    latest$latest_date <- as.Date(
        latest$latest_date
    )

    latest

}

#--------------------------------------------------------
# Load price history
#--------------------------------------------------------
load_prices <- function(
    con,
    ticker,
    from = NULL,
    to = NULL
){

    sql <- "

        SELECT

            date,
            open,
            high,
            low,
            close,
            adj_close,
            volume

        FROM prices_daily

        WHERE ticker = ?

        ORDER BY date

    "

    prices <- DBI::dbGetQuery(

        con,

        sql,

        params = list(ticker)

    )

    prices$date <- as.Date(
        prices$date
    )

    prices

}
