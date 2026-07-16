#========================================================
# Risk Management
#========================================================

#--------------------------------------------------------
# Stop loss
#--------------------------------------------------------
calculate_stop_loss <- function(
    entry,
    atr,
    atr_multiplier = config$risk$default_atr_multiplier
){

    stopifnot(

        is.numeric(entry),
        length(entry) == 1,

        is.numeric(atr),
        length(atr) == 1,

        atr > 0,

        atr_multiplier > 0

    )

    entry - atr * atr_multiplier

}

#--------------------------------------------------------
# Take profit
#--------------------------------------------------------
calculate_take_profit <- function(
    entry,
    stop,
    risk_reward = config$risk$default_risk_reward
){

    stopifnot(

        entry > stop,

        risk_reward > 0

    )

    risk <- entry - stop

    entry + risk * risk_reward

}

#--------------------------------------------------------
# Dollar risk per share
#--------------------------------------------------------
calculate_risk_per_share <- function(
    entry,
    stop
){

    stopifnot(

        entry > stop

    )

    entry - stop

}

#--------------------------------------------------------
# Dollar reward per share
#--------------------------------------------------------
calculate_reward_per_share <- function(
    entry,
    target
){

    stopifnot(

        target > entry

    )

    target - entry

}

#--------------------------------------------------------
# Position size
#--------------------------------------------------------
calculate_position_size <- function(
    capital,
    entry,
    stop,
    risk_percent = config$risk$default_risk_percent
){

    stopifnot(

        is.numeric(capital),
        length(capital) == 1,
        capital > 0,

        is.numeric(entry),
        length(entry) == 1,
        entry > 0,

        is.numeric(stop),
        length(stop) == 1,
        stop > 0,
        stop < entry,

        is.numeric(risk_percent),
        length(risk_percent) == 1,
        risk_percent > 0

    )

    # Maximum dollar risk
    dollar_risk <-

        capital *

        risk_percent /

        100

    # Dollar risk per share
    risk_per_share <-

        calculate_risk_per_share(

            entry,

            stop

        )

    # Maximum shares allowed by risk
    shares_risk <-

        floor(

            dollar_risk /

            risk_per_share

        )

    # Maximum shares affordable
    shares_capital <-

        floor(

            capital /

            entry

        )

    # Final position size
    min(

        shares_risk,

        shares_capital

    )

}

#--------------------------------------------------------
# Trade value
#--------------------------------------------------------
calculate_trade_value <- function(
    shares,
    entry
){

    stopifnot(

        shares >= 0,

        entry > 0

    )

    shares * entry

}

#--------------------------------------------------------
# Total trade risk
#--------------------------------------------------------
calculate_trade_risk <- function(
    shares,
    entry,
    stop
){

    shares *

        calculate_risk_per_share(

            entry,

            stop

        )

}

#--------------------------------------------------------
# Total trade reward
#--------------------------------------------------------
calculate_trade_reward <- function(
    shares,
    entry,
    target
){

    shares *

        calculate_reward_per_share(

            entry,

            target

        )

}

#--------------------------------------------------------
# Risk : Reward ratio
#--------------------------------------------------------
calculate_risk_reward <- function(
    entry,
    stop,
    target
){

    calculate_reward_per_share(

        entry,

        target

    ) /

    calculate_risk_per_share(

        entry,

        stop

    )

}

#--------------------------------------------------------
# R Multiple
#--------------------------------------------------------
calculate_R_multiple <- function(
    entry,
    stop,
    exit
){

    (exit - entry) /

        calculate_risk_per_share(

            entry,

            stop

        )

}

#--------------------------------------------------------
# Trade profit
#--------------------------------------------------------
calculate_trade_profit <- function(
    shares,
    entry,
    exit,
    fees = 0
){

    (exit - entry) *

        shares -

        fees

}

#--------------------------------------------------------
# Profit (%)
#--------------------------------------------------------
calculate_profit_percent <- function(
    entry,
    exit
){

    (exit - entry) /

        entry *

        100

}

#--------------------------------------------------------
# Trade plan
#--------------------------------------------------------
create_trade_plan <- function(
    capital,
    entry,
    atr,
    atr_multiplier = config$risk$default_atr_multiplier,
    risk_percent = config$risk$default_risk_percent,
    risk_reward = config$risk$default_risk_reward
){

    stop <-

        calculate_stop_loss(

            entry,

            atr,

            atr_multiplier

        )

    target <-

        calculate_take_profit(

            entry,

            stop,

            risk_reward

        )

    shares <-

        calculate_position_size(

            capital,

            entry,

            stop,

            risk_percent

        )

    list(

        entry = entry,

        stop = stop,

        target = target,

        shares = shares,

        trade_value = calculate_trade_value(

            shares,

            entry

        ),

        risk = calculate_trade_risk(

            shares,

            entry,

            stop

        ),

        reward = calculate_trade_reward(

            shares,

            entry,

            target

        ),

        risk_reward = calculate_risk_reward(

            entry,

            stop,

            target

        )

    )

}




