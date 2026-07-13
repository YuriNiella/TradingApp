#========================================================
# Yahoo Engine
#========================================================

#--------------------------------------------------------
# Download one ticker from Yahoo
#--------------------------------------------------------
fetch_yahoo <- function(
    ticker,
    from
){

    symbol <- paste0(ticker, ".AX")

    message(sprintf(

        "Downloading %-8s",

        symbol

    ))

    x <- suppressWarnings(tryCatch(

        quantmod::getSymbols(
            symbol,
            src = "yahoo",
            from = from,
            auto.assign = FALSE
        ),

        error = function(e){

            message("Failed: ", ticker)
            message("Reason: ", conditionMessage(e))

            NULL

        }

    ))

    if(anyNA(x)){

        message("Missing values detected for ", ticker)

    }

    if(is.null(x)){

        return(NULL)

    }

    x <- na.omit(x)

    if(nrow(x) == 0){

        message("No rows returned for ", ticker)

        return(NULL)

    }

    data.frame(

        ticker=ticker,

        date=as.Date(zoo::index(x)),

        open=as.numeric(quantmod::Op(x)),

        high=as.numeric(quantmod::Hi(x)),

        low=as.numeric(quantmod::Lo(x)),

        close=as.numeric(quantmod::Cl(x)),

        adj_close=as.numeric(quantmod::Ad(x)),

        volume=as.numeric(quantmod::Vo(x))

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