#========================================================
# Trading Setups
#========================================================

sanitize_setup <- function(setup){

    setup[is.na(setup)] <- FALSE

    setup

}

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

    setup <- prices$trend_up &

        prices$near_high &

        prices$breakout_20 &

        (

            !config$strategy$breakout$require_volume |

            prices$volume_surge

        )

    sanitize_setup(setup)

}

#--------------------------------------------------------
# Emerging Breakout
#--------------------------------------------------------
setup_emerging_breakout <- function(
    prices
){

    setup <- prices$trend_emerging &

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

    sanitize_setup(setup)

}

#--------------------------------------------------------
# Pullback Continuation
#--------------------------------------------------------
setup_pullback <- function(
    prices
){

    setup <- prices$trend_up &

        prices$pullback &

        prices$near_high &

        !prices$breakout_20

    sanitize_setup(setup)

}