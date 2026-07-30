#========================================================
# Market Structure Engine
#========================================================
#
# Responsible for:
# - Detect swing highs/lows
# - Determine support & resistance
# - Classify market structure
#
# Outputs new columns added to prices:
#
# swing_high
# swing_low
# last_swing_high
# last_swing_low
# recent_support
# recent_resistance
# highest_20
# lowest_20
# market_structure
#
#========================================================


#--------------------------------------------------------
# Main
#--------------------------------------------------------

MIN_SWING_DISTANCE_ATR <- 0.75

calculate_market_structure <- function(
    prices,
    swing_window = 2,
    lookback = 20
){

    prices <-
        identify_swings(
            prices,
            swing_window
        )

    prices <-
        calculate_structure(
            prices,
            lookback
        )

    prices

}

get_trading_settings <- function(){

    list(

        account_size = 4200,

        risk_percent = 1,

        brokerage = 20,

        r_multiple = 3

    )

}

#========================================================
# Detect swing highs & lows
#========================================================

identify_swings <- function(
    prices,
    window = 2
){

    n <- nrow(prices)

    prices$swing_high <- FALSE
    prices$swing_low  <- FALSE

    if(n < (window * 2 + 1))
        return(prices)

    for(i in (window + 1):(n - window)){

        highs <-
            prices$high[(i-window):(i+window)]

        lows <-
            prices$low[(i-window):(i+window)]

        ##------------------------------------------------
        ## Swing High
        ##------------------------------------------------

        if(

            prices$high[i] == max(highs) &&
            sum(highs == prices$high[i]) == 1

        ){

            prices$swing_high[i] <- TRUE

        }

        ##------------------------------------------------
        ## Swing Low
        ##------------------------------------------------

        if(

            prices$low[i] == min(lows) &&
            sum(lows == prices$low[i]) == 1

        ){

            prices$swing_low[i] <- TRUE

        }

    }

    prices

}

accept_new_swing <- function(current, previous, atr){

    if(is.na(previous))
        return(TRUE)

    if(is.na(atr))
        return(TRUE)

    abs(current - previous) > (MIN_SWING_DISTANCE_ATR * atr)

}

#========================================================
# Market Structure
#========================================================

calculate_structure <- function(
    prices,
    lookback = 20
){

    n <- nrow(prices)

    prices$last_swing_high <- NA_real_
    prices$last_swing_low  <- NA_real_

    prices$recent_support    <- NA_real_
    prices$recent_resistance <- NA_real_

    prices$highest_lookback <- NA_real_
    prices$lowest_lookback  <- NA_real_

    prices$market_structure <- "Unknown"

    last_high <- NA_real_
    previous_high <- NA_real_

    last_low <- NA_real_
    previous_low <- NA_real_

    for(i in seq_len(n)){

        #--------------------------------------------
        # Rolling High / Low
        #--------------------------------------------

        start <- max(
            1,
            i - lookback + 1
        )

        history <- prices[start:i, ]

        prices$highest_lookback[i] <-
            max(
                history$high,
                na.rm = TRUE
            )

        prices$lowest_lookback[i] <-
            min(
                history$low,
                na.rm = TRUE
            )

        #--------------------------------------------
        # Update Swing High
        #--------------------------------------------

        if(isTRUE(prices$swing_high[i])){

            if(

                accept_new_swing(

                    current = prices$high[i],

                    previous = last_high,

                    atr = prices$atr_14[i]

                )

            ){

                previous_high <- last_high
                last_high <- prices$high[i]

            }

        }

        #--------------------------------------------
        # Update Swing Low
        #--------------------------------------------

        if(isTRUE(prices$swing_low[i])){

            if(

                accept_new_swing(

                    current = prices$low[i],

                    previous = last_low,

                    atr = prices$atr_14[i]

                )

            ){

                previous_low <- last_low
                last_low <- prices$low[i]

            }

        }

        prices$last_swing_high[i] <- last_high
        prices$last_swing_low[i]  <- last_low

        #--------------------------------------------
        # Support & Resistance
        #--------------------------------------------

        prices$recent_resistance[i] <- last_high
        prices$recent_support[i]    <- last_low

        #--------------------------------------------
        # Trend Classification
        #--------------------------------------------

        if(

            !is.na(previous_high) &&
            !is.na(previous_low) &&
            !is.na(last_high) &&
            !is.na(last_low)

        ){

            higher_high <- last_high > previous_high
            higher_low  <- last_low  > previous_low

            lower_high <- last_high < previous_high
            lower_low  <- last_low  < previous_low

            prices$market_structure[i] <-

                dplyr::case_when(

                    higher_high & higher_low ~

                        "Uptrend",

                    lower_high & lower_low ~

                        "Downtrend",

                    TRUE ~

                        "Range"

                )

        }

    }

    prices

}

#========================================================
# Convenience
#========================================================

latest_market_structure <- function(prices){

    prices[nrow(prices),

        c(

            "last_swing_high",

            "last_swing_low",

            "recent_support",

            "recent_resistance",

            "highest_20",

            "lowest_20",

            "market_structure"

        )

    ]

}