#========================================================
# Yahoo Engine
#========================================================

#--------------------------------------------------------
# Download one ticker from Yahoo
#--------------------------------------------------------
fetch_yahoo <- function(ticker, from){

    symbol <- paste0(ticker, ".AX")

    message(sprintf("Downloading %-8s", symbol))

    x <- tryCatch(

        suppressWarnings(

            quantmod::getSymbols(
                Symbols = symbol,
                src = "yahoo",
                from = from,
                auto.assign = FALSE,
                warnings = FALSE
            )

        ),

        error = function(e){

            message("Failed: ", ticker)
            message("Reason: ", conditionMessage(e))

            return(NULL)

        }

    )

    if(is.null(x))
        return(NULL)

    # Remove incomplete rows immediately
    x <- x[stats::complete.cases(x), ]

    if(NROW(x) == 0){

        message("No valid rows returned for ", ticker)

        return(NULL)

    }

    data.frame(

        ticker = ticker,

        date = as.Date(zoo::index(x)),

        open = as.numeric(quantmod::Op(x)),

        high = as.numeric(quantmod::Hi(x)),

        low = as.numeric(quantmod::Lo(x)),

        close = as.numeric(quantmod::Cl(x)),

        adj_close = as.numeric(quantmod::Ad(x)),

        volume = as.numeric(quantmod::Vo(x)),

        stringsAsFactors = FALSE

    )

}


#--------------------------------------------------------
# Latest market date (Yahoo)
#--------------------------------------------------------
get_latest_market_date <- function(reference_ticker = "CBA"){

    symbol <- paste0(reference_ticker, ".AX")

    x <- tryCatch(

        quantmod::getSymbols(
            symbol,
            src = "yahoo",
            auto.assign = FALSE
        ),

        error = function(e) NULL

    )

    if(is.null(x)){

        return(NULL)

    }

    max(as.Date(zoo::index(x)))

}


#--------------------------------------------------------
# Download company metadata
#--------------------------------------------------------
download_metadata <- function(ticker){

    stop("Not implemented.")

}

#--------------------------------------------------------
# Download historical prices
#--------------------------------------------------------
download_history <- function(
    ticker,
    from,
    to = Sys.Date()
){

    stop("Not implemented.")

}

#--------------------------------------------------------
# Download latest quote
#--------------------------------------------------------
download_latest <- function(ticker){

    stop("Not implemented.")

}

#--------------------------------------------------------
# Download multiple securities
#--------------------------------------------------------
download_multiple <- function(
    tickers,
    FUN,
    ...
){

    stop("Not implemented.")

}

#--------------------------------------------------------
# Yahoo symbol
#--------------------------------------------------------
yahoo_symbol <- function(
    ticker,
    exchange = "ASX"
){

    switch(

        exchange,

        ASX = paste0(ticker, ".AX"),

        ticker

    )

}