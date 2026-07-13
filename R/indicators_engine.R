#========================================================
# Indicators Engine
#========================================================

#--------------------------------------------------------
# Validate prices
#--------------------------------------------------------
validate_prices <- function(
    prices
){

    required <- c(

        "date",

        "open",

        "high",

        "low",

        "close",

        "volume"

    )

    missing <- setdiff(

        required,

        names(prices)

    )

    if(length(missing) > 0){

        stop(

            paste(

                "Missing columns:",

                paste(missing, collapse = ", ")

            ),

            call. = FALSE

        )

    }

    if(anyDuplicated(prices$date)){

        stop(

            "Duplicate dates detected.",

            call. = FALSE

        )

    }

    if(is.unsorted(prices$date)){

        stop(

            "Prices must be sorted by date.",

            call. = FALSE

        )

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Calculate all indicators
#--------------------------------------------------------
calculate_indicators <- function(prices){

    validate_prices(prices)

    #----------------------------------------------------
    # Trend
    #----------------------------------------------------

    prices$ema_20 <- calculate_ema(
        prices,
        config$indicators$ema_short
    )

    prices$ema_50 <- calculate_ema(
        prices,
        config$indicators$ema_long
    )

    #----------------------------------------------------
    # Price
    #----------------------------------------------------

    prices[[paste0("high_", config$indicators$high_period)]] <-
        calculate_high(
            prices,
            config$indicators$high_period
        )

    #----------------------------------------------------
    # Volume
    #----------------------------------------------------

    prices[[paste0("rvol_", config$indicators$rvol_period)]] <-
        calculate_rvol(
            prices,
            config$indicators$rvol_period
        )

    #----------------------------------------------------
    # Volatility
    #----------------------------------------------------

    prices[[paste0("atr_", config$indicators$atr_period)]] <-
        calculate_atr(
            prices,
            config$indicators$atr_period
        )

    #----------------------------------------------------
    # Derived indicators
    #----------------------------------------------------

    prices[[paste0(
        "distance_ema_",
        config$indicators$ema_short
    )]] <-
            calculate_distance_ema(
                prices,
                prices$ema_20
            )

    prices[[paste0(
        "return_",
        config$indicators$return_period
    )]] <-
        calculate_return_pct(
            prices,
            config$indicators$return_period
        )

    prices

}