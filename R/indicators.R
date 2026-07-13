#========================================================
# Technical Indicators
#========================================================

#--------------------------------------------------------
# Exponential Moving Average
#--------------------------------------------------------
calculate_ema <- function(
    prices,
    period
){

    validate_prices(prices)

    if(period < 1){

        stop(

            "Period must be greater than zero.",

            call. = FALSE

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

    validate_prices(
        prices
    )

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

    avg_volume <- zoo::rollapply(

        prices$volume,

        width = period,

        FUN = mean,

        align = "right",

        fill = NA,

        partial = FALSE

    )

    prices$volume / avg_volume

}

#--------------------------------------------------------
# Average True Range
#--------------------------------------------------------
calculate_atr <- function(
    prices,
    period
){

    validate_prices(prices)

    atr <- TTR::ATR(

        prices[, c("high", "low", "close")],

        n = period

    )

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

    prices$close /

        dplyr::lag(

            prices$close,

            n = period

        ) - 1

}
