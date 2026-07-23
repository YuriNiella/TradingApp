#========================================================
# Technical Indicators
#========================================================

#--------------------------------------------------------
# Check sufficient history
#--------------------------------------------------------
check_history <- function(prices, period){

    validate_prices(prices)

    required <- c("high", "low", "close")

    complete_rows <- sum(
        complete.cases(prices[, required])
    )

    complete_rows >= (period + 1)

}

#--------------------------------------------------------
# Exponential Moving Average
#--------------------------------------------------------
calculate_ema <- function(
    prices,
    period
){

    validate_prices(prices)

    if(!check_history(prices, period)){

        return(

            rep(

                NA_real_,

                nrow(prices)

            )

        )

    }

    TTR::EMA(

        prices$close,

        n = period

    )

}

#--------------------------------------------------------
# Rolling Highest High
#--------------------------------------------------------
calculate_high <- function(
    prices,
    period
){

    validate_prices(prices)

    if(!check_history(prices, period)){

        return(

            rep(

                NA_real_,

                nrow(prices)

            )

        )

    }

    zoo::rollapply(

        prices$high,

        width = period,

        FUN = max,

        align = "right",

        fill = NA,

        partial = FALSE

    )

}

#--------------------------------------------------------
# Relative Volume
#--------------------------------------------------------
calculate_rvol <- function(
    prices,
    period
){

    validate_prices(prices)

    if(!check_history(prices, period)){

        return(

            rep(

                NA_real_,

                nrow(prices)

            )

        )

    }

    volume <- as.numeric(prices$volume)

    avg_volume <- zoo::rollapply(

        volume,

        width = period,

        FUN = mean,

        align = "right",

        fill = NA,

        partial = FALSE

    )

    rvol <- volume / avg_volume

    rvol[!is.finite(rvol)] <- 0

    rvol
}

#--------------------------------------------------------
# Average True Range
#--------------------------------------------------------
calculate_atr <- function(prices, period){

    validate_prices(prices)

    if(!check_history(prices, period)){
        return(rep(NA_real_, nrow(prices)))
    }

    atr <- tryCatch(

        TTR::ATR(
            prices[, c("high", "low", "close")],
            n = period
        ),

        error = function(e) NULL

    )

    if(is.null(atr)){
        return(rep(NA_real_, nrow(prices)))
    }

    atr[, "atr"]

}

#--------------------------------------------------------
# Distance from EMA
#--------------------------------------------------------
calculate_distance_ema <- function(
    prices,
    ema
){

    (prices$close - ema) / ema

}

#--------------------------------------------------------
# 5-day return
#--------------------------------------------------------
calculate_return_pct <- function(
    prices,
    period
){

    validate_prices(prices)

    if(nrow(prices) <= period){

        return(

            rep(

                NA_real_,

                nrow(prices)

            )

        )

    }

    prices$close /

        dplyr::lag(

            prices$close,

            n = period

        ) - 1

}