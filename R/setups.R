#========================================================
# Trading Setups
#========================================================

#--------------------------------------------------------
# Calculate all setups
#--------------------------------------------------------
calculate_setups <- function(
    prices
){

    validate_prices(prices)

    prices$setup_breakout <-
        setup_breakout(prices)

    prices$setup_emerging_breakout <-
        setup_emerging_breakout(prices)

    prices$setup_pullback <-
        setup_pullback(prices)

    prices

}

#--------------------------------------------------------
# Breakout
#--------------------------------------------------------
setup_breakout <- function(
    prices
){

    prices$trend_up &

        prices$near_high &

        prices$breakout_20 &

        (

            !config$strategy$breakout$require_volume |

            prices$volume_surge

        )

}

#--------------------------------------------------------
# Emerging Breakout
#--------------------------------------------------------
setup_emerging_breakout <- function(
    prices
){

    prices$trend_emerging &

        prices$near_high &

        prices$breakout_20 &

        (

            !config$strategy$emerging_breakout$require_volume |

            prices$volume_surge

        ) &

        (

            !config$strategy$emerging_breakout$require_pullback |

            prices$pullback

        )

}

#--------------------------------------------------------
# Pullback Continuation
#--------------------------------------------------------
setup_pullback <- function(
    prices
){

    prices$trend_up &

        prices$pullback &

        !prices$breakout_20

}