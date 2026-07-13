#========================================================
# Scoring Engine
#========================================================

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
score_breakout <- function(
    prices
){

    score <- numeric(nrow(prices))

    score <- score +

        ifelse(

            prices$trend_up,

            config$scoring$breakout$trend_up,

            0

        )

    score <- score +

        ifelse(

            prices$near_high,

            config$scoring$breakout$near_high,

            0

        )

    score <- score +

        ifelse(

            prices$breakout_20,

            config$scoring$breakout$breakout,

            0

        )

    score <- score +

        ifelse(

            prices$volume_surge,

            config$scoring$breakout$volume,

            0

        )

    score <- score +

        ifelse(

            prices$pullback,

            config$scoring$breakout$pullback,

            0

        )

    pmin(score, 100)

}

#--------------------------------------------------------
# Emerging Breakout Score
#--------------------------------------------------------
score_emerging_breakout <- function(
    prices
){

    score <- numeric(nrow(prices))

    score <- score +

        ifelse(

            prices$trend_emerging,

            config$scoring$emerging_breakout$trend_emerging,

            0

        )

    score <- score +

        ifelse(

            prices$near_high,

            config$scoring$emerging_breakout$near_high,

            0

        )

    score <- score +

        ifelse(

            prices$breakout_20,

            config$scoring$emerging_breakout$breakout,

            0

        )

    score <- score +

        ifelse(

            prices$volume_surge,

            config$scoring$emerging_breakout$volume,

            0

        )

    score <- score +

        ifelse(

            prices$pullback,

            config$scoring$emerging_breakout$pullback,

            0

        )

    pmin(score, 100)

}

#--------------------------------------------------------
# Pullback Score
#--------------------------------------------------------
score_pullback <- function(prices){

    score <- numeric(nrow(prices))

    score <- score +

        ifelse(
            prices$trend_up,
            40,
            0
        )

    score <- score +

        ifelse(
            prices$pullback,
            30,
            0
        )

    score <- score +

        ifelse(
            prices$near_high,
            20,
            0
        )

    score <- score +

        ifelse(
            !prices$breakout_20,
            10,
            0
        )

    score

}