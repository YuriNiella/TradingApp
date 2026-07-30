#========================================================
# Trade Planner
#========================================================

build_trade_plan <- function(
    summary,
    analysis,
    settings
){

    setup <- summary$closest_setup

    levels <-

        switch(

            setup,

            Breakout = plan_breakout(summary, analysis),

            "Emerging Breakout" = plan_emerging_breakout(summary, analysis),

            Pullback = plan_pullback(summary, analysis),

            default_trade_plan(summary, analysis)

        )

    calculate_trade_metrics(

        levels = levels,

        settings = settings

    )

}


#========================================================
# TECHNICAL PLANS
#========================================================

default_trade_plan <- function(summary, analysis){

    list(

        entry = summary$close,

        stop = summary$close - analysis$atr_14,

        planner = "Default"

    )

}


plan_breakout <- function(summary, analysis){

    entry <- analysis$high * 1.001

    ## TODO:
    ## Replace with recent swing low once available

    stop <- min(

        analysis$low,
        analysis$ema_20,
        na.rm = TRUE

    )

    list(

        entry = entry,

        stop = stop,

        planner = "Breakout"

    )

}


plan_emerging_breakout <- function(summary, analysis){

    entry <- analysis$close

    stop <- min(

        analysis$low,
        analysis$ema_20,
        na.rm = TRUE

    )

    list(

        entry = entry,

        stop = stop,

        planner = "Emerging Breakout"

    )

}


plan_pullback <- function(summary, analysis){

    entry <- analysis$close

    stop <- min(

        analysis$low,
        analysis$ema_20,
        na.rm = TRUE

    )

    list(

        entry = entry,

        stop = stop,

        planner = "Pullback"

    )

}


#========================================================
# RISK ENGINE
#========================================================

calculate_trade_metrics <- function(

    levels,
    settings

){

    risk_per_share <-

        levels$entry - levels$stop

    target <-

        levels$entry +

        settings$r_multiple *

        risk_per_share

    max_risk_dollars <-

        settings$account_size *

        settings$risk_percent / 100

    max_position_size <-

        floor(

            max_risk_dollars /

            risk_per_share

        )

    capital_required <-

        max_position_size *

        levels$entry

    feasible <-

        capital_required <= settings$account_size

    gross_profit <-

        max_position_size *

        (target - levels$entry)

    gross_loss <-

        max_position_size *

        (levels$entry - levels$stop)

    net_profit <-

        gross_profit -

        settings$brokerage

    net_loss <-

        gross_loss +

        settings$brokerage

    create_trade_plan(

        entry = levels$entry,

        stop = levels$stop,

        target = target,

        planner = levels$planner,

        risk_percent = settings$risk_percent,

        position_size = max_position_size,

        capital_required = capital_required,

        gross_profit = gross_profit,

        gross_loss = gross_loss,

        net_profit = net_profit,

        net_loss = net_loss,

        brokerage = settings$brokerage,

        feasible = feasible,

        r_multiple = settings$r_multiple

    )

}


#========================================================
# CONSTRUCTOR
#========================================================

create_trade_plan <- function(

    entry,
    stop,
    target,
    planner,
    risk_percent,
    position_size,
    capital_required,
    gross_profit,
    gross_loss,
    net_profit,
    net_loss,
    brokerage,
    feasible,
    r_multiple

){

    list(

        planned_entry = round(entry,2),

        planned_stop = round(stop,2),

        planned_target = round(target,2),

        risk_percent = risk_percent,

        planned_position_size = position_size,

        planned_r_multiple = r_multiple,

        planner = planner,

        capital_required = round(capital_required,2),

        gross_profit = round(gross_profit,2),

        gross_loss = round(gross_loss,2),

        brokerage = brokerage,

        net_profit = round(net_profit,2),

        net_loss = round(net_loss,2),

        feasible = feasible

    )

}