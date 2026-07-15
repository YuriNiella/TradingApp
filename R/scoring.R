#========================================================
# Scoring Engine
#========================================================

#========================================================
# Continuous scores 
#========================================================
score_trend_quality <- function(prices){

    score <- pmin(

        prices$trend_strength / 0.05,

        1

    )

    sanitize_quality(score)

}

score_emerging_quality <- function(prices){

    score <- ifelse(

        prices$trend_emerging,

        1,

        0

    )

    sanitize_quality(score)

}

score_volume_quality <- function(prices){

    score <- pmin(

        prices$rvol_20 / 2,

        1

    )

    sanitize_quality(score)

}

score_near_high_quality <- function(prices){

    distance <-

        (prices$high_20 - prices$close) /

        prices$high_20

    score <- pmax(

        1 -

        distance /

        config$features$near_high_pct,

        0

    )

    sanitize_quality(score)

}

score_pullback_quality <- function(prices){

    distance <-

        abs(

            prices$distance_ema_20

        )

    score <-

        1 -

        abs(

            distance - 0.02

        ) / 0.05

    score <- pmax(

        pmin(score,1),

        0

    )

    sanitize_quality(score)

}

score_breakout_quality <- function(prices){

    score <- numeric(nrow(prices))

    score[prices$breakout_20] <- 1

    sanitize_quality(score)

}

sanitize_quality <- function(score){

    score[!is.finite(score)] <- 0

    pmin(
        pmax(score, 0),
        1
    )

}

#--------------------------------------------------------
# Calculate all scores
#--------------------------------------------------------
calculate_scores <- function(
    prices
){

    validate_prices(prices)

    prices$score_breakout <-

        score_breakout(prices)

    prices$score_emerging_breakout <-

        score_emerging_breakout(prices)

    prices$score_pullback <-

        score_pullback(prices)

    prices

}

#--------------------------------------------------------
# Breakout Score
#--------------------------------------------------------
score_breakout <- function(prices){

    round(

        30 * score_trend_quality(prices) +

        25 * score_volume_quality(prices) +

        25 * score_breakout_quality(prices) +

        20 * score_near_high_quality(prices)

    )

}

#--------------------------------------------------------
# Emerging Breakout Score
#--------------------------------------------------------
score_emerging_breakout <- function(prices){

    round(

        25 * as.numeric(prices$trend_emerging) +

        25 * score_near_high_quality(prices) +

        25 * score_breakout_quality(prices) +

        25 * score_volume_quality(prices)

    )

}

#--------------------------------------------------------
# Pullback Score
#--------------------------------------------------------
score_pullback <- function(prices){

    round(

        35 * score_trend_quality(prices) +

        35 * score_pullback_quality(prices) +

        20 * score_near_high_quality(prices) +

        10 * (1 - score_volume_quality(prices))

    )

}
