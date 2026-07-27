#========================================================
# Trade Planner
#========================================================

build_trade_plan <- function(summary, analysis){

    setup <- summary$closest_setup

    switch(

        setup,

        Breakout = plan_breakout(summary, analysis),

        "Emerging Breakout" = plan_emerging_breakout(summary, analysis),

        Pullback = plan_pullback(summary, analysis),

        default_trade_plan(summary, analysis)

    )

}


#--------------------------------------------------------
# Default
#--------------------------------------------------------

default_trade_plan <- function(summary, analysis){

    close <- summary$close
    atr <- analysis$atr_14

    create_trade_plan(

        entry = close,

        stop = close - atr,

        target = close + (2 * atr),

        planner = "Default"

    )

}


#--------------------------------------------------------
# Breakout
#--------------------------------------------------------

plan_breakout <- function(summary, analysis){

    entry <- analysis$high * 1.001

    stop <- max(

        analysis$ema_20,

        analysis$close - (2 * analysis$atr_14),

        na.rm = TRUE

    )

    create_trade_plan(

        entry = entry,

        stop = stop,

        target = entry + (2 * (entry - stop)),

        planner = "Breakout"

    )

}


#--------------------------------------------------------
# Emerging Breakout
#--------------------------------------------------------

plan_emerging_breakout <- function(summary, analysis){

    entry <- analysis$close

    stop <- min(

        analysis$ema_20,

        analysis$close - analysis$atr_14,

        na.rm = TRUE

    )

    create_trade_plan(

        entry = entry,

        stop = stop,

        target = entry + (2 * (entry - stop)),

        planner = "Emerging Breakout"

    )

}


#--------------------------------------------------------
# Pullback
#--------------------------------------------------------

plan_pullback <- function(summary, analysis){

    entry <- analysis$close

    stop <- min(

        analysis$ema_20,

        analysis$close - analysis$atr_14,

        na.rm = TRUE

    )

    create_trade_plan(

        entry = entry,

        stop = stop,

        target = entry + (2 * (entry - stop)),

        planner = "Pullback"

    )

}


#--------------------------------------------------------
# Constructor
#--------------------------------------------------------

create_trade_plan <- function(

    entry,

    stop,

    target,

    planner,

    risk_percent = 1,

    position_size = NA_real_

){

    risk <- abs(entry - stop)

    reward <- abs(target - entry)

    r_multiple <-

        if(risk > 0)

            reward / risk

        else

            NA_real_

    list(

        planned_entry = round(entry, 2),

        planned_stop = round(stop, 2),

        planned_target = round(target, 2),

        risk_percent = risk_percent,

        planned_position_size = position_size,

        planned_r_multiple = round(r_multiple, 2),

        planner = planner

    )

}