#========================================================
# Features Engine
#========================================================

#--------------------------------------------------------
# Calculate all features
#--------------------------------------------------------
calculate_features <- function(prices){

    validate_prices(prices)

    prices$trend_up <-
        feature_trend_up(prices)

    prices$trend_strength <-
        feature_trend_strength(prices)

    prices$trend_emerging <-
        feature_trend_emerging(prices)

    prices$near_high <-
        feature_near_high(prices)

    prices$breakout_20 <-
        feature_breakout(prices)

    prices$volume_surge <-
        feature_volume_surge(prices)

    prices$pullback <-
        feature_pullback(prices)

    prices

}

feature_trend_up <- function(prices){

    ema_short <- prices[[paste0("ema_", config$indicators$ema_short)]]
    ema_long  <- prices[[paste0("ema_", config$indicators$ema_long)]]

    ema_short > ema_long

}

feature_trend_emerging <- function(prices){

    ema_short <- prices[[paste0("ema_", config$indicators$ema_short)]]

    !prices$trend_up &

        prices$close > ema_short &

        prices$return_5 > 0

}

feature_trend_strength <- function(prices){

    ema_short <- prices[[paste0("ema_", config$indicators$ema_short)]]
    ema_long  <- prices[[paste0("ema_", config$indicators$ema_long)]]


    pmax(

    (ema_short - ema_long) / ema_long,

    0

)

}

features = list(

    near_high_pct = 0.02,

    volume_surge = 1.5,

    pullback_pct = 0.03

)

feature_near_high <- function(prices){

    prices$close >=
        prices$high_20 *
        (1 - config$features$near_high_pct)

}

feature_breakout <- function(prices){

    prices$close >

        dplyr::lag(

            prices$high_20

        )

}

feature_volume_surge <- function(prices){

    prices$rvol_20 >=

        config$features$volume_surge

}

feature_pullback <- function(prices){

    abs(

        prices$distance_ema_20

    ) <=

    config$features$pullback_pct

}
