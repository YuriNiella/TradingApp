#========================================================
# Trades
#========================================================

#--------------------------------------------------------
# Create trade
#--------------------------------------------------------
create_trade <- function(
    con_lab,
    idea_id,
    idea,
    capital
){

    stopifnot(

        idea_exists(
            con_lab,
            idea_id
        )

    )

    entry <- idea$summary$close

    atr <- idea$analysis$atr_14

    plan <-

        create_trade_plan(

            capital = capital,

            entry = entry,

            atr = atr

        )

    now <- as.character(Sys.time())

    DBI::dbExecute(

        con_lab,

        "

        INSERT INTO trades (

            idea_id,

            created_datetime,

            updated_datetime,

            status,

            scanner_setup,

            scanner_score,

            scanner_entry,

            scanner_stop,

            scanner_target,

            atr,

            atr_multiplier,

            risk_reward,

            planned_entry,

            planned_stop,

            planned_target,

            capital,

            planned_shares

        )

        VALUES (

            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?

        )

        ",

        params = list(

            idea_id,

            now,

            now,

            "Planned",

            idea$summary$closest_setup,

            idea$summary$setup_score,

            plan$entry,

            plan$stop,

            plan$target,

            atr,

            config$risk$default_atr_multiplier,

            config$risk$default_risk_reward,

            plan$entry,

            plan$stop,

            plan$target,

            capital,

            plan$shares

        )

    )

    DBI::dbGetQuery(

        con_lab,

        "SELECT last_insert_rowid() AS trade_id"

    )$trade_id[[1]]

}

#--------------------------------------------------------
# Get trade
#--------------------------------------------------------
get_trade <- function(
    con_lab,
    trade_id
){

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT *

        FROM trades

        WHERE trade_id = ?

        ",

        params = list(

            trade_id

        )

    )

}

#--------------------------------------------------------
# Get all trades
#--------------------------------------------------------
get_trades <- function(
    con_lab
){

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT *

        FROM trades

        ORDER BY created_datetime DESC

        "

    )

}

#--------------------------------------------------------
# Open trades
#--------------------------------------------------------
get_open_trades <- function(
    con_lab
){

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT *

        FROM trades

        WHERE status = 'Open'

        ORDER BY created_datetime DESC

        "

    )

}

#--------------------------------------------------------
# Closed trades
#--------------------------------------------------------
get_closed_trades <- function(
    con_lab
){

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT *

        FROM trades

        WHERE status = 'Closed'

        ORDER BY exit_datetime DESC

        "

    )

}

#--------------------------------------------------------
# Trade exists
#--------------------------------------------------------
trade_exists <- function(
    con_lab,
    trade_id
){

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT COUNT(*) AS n

        FROM trades

        WHERE trade_id = ?

        ",

        params = list(

            trade_id

        )

    )$n[[1]] > 0

}

#--------------------------------------------------------
# Count trades
#--------------------------------------------------------
count_trades <- function(
    con_lab
){

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT COUNT(*) AS n

        FROM trades

        "

    )$n[[1]]

}

#--------------------------------------------------------
# Delete trade
#--------------------------------------------------------
delete_trade <- function(
    con_lab,
    trade_id
){

    DBI::dbExecute(

        con_lab,

        "

        DELETE

        FROM trades

        WHERE trade_id = ?

        ",

        params = list(

            trade_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Update trade
#--------------------------------------------------------
update_trade <- function(
    con_lab,
    trade_id,
    planned_entry = NULL,
    planned_stop = NULL,
    planned_target = NULL,
    planned_shares = NULL,
    comments = NULL,
    fees = NULL
){

    if(!trade_exists(con_lab, trade_id))
        stop("Trade does not exist.")

    trade <- get_trade(
        con_lab,
        trade_id
    )

    if(!(trade$status %in% c("Planned", "Open")))
        stop("Closed trades cannot be modified.")

    updates <- character()

    params <- list()

    add_update <- function(column, value){

        if(!is.null(value)){

            updates <<- c(
                updates,
                paste0(column, " = ?")
            )

            params <<- c(
                params,
                list(value)
            )

        }

    }

    add_update("planned_entry", planned_entry)
    add_update("planned_stop", planned_stop)
    add_update("planned_target", planned_target)
    add_update("planned_shares", planned_shares)
    add_update("comments", comments)
    add_update("fees", fees)

    if(length(updates) == 0){

        return(invisible(FALSE))

    }

    updates <- c(
        updates,
        "updated_datetime = ?"
    )

    params <- c(
        params,
        list(as.character(Sys.time()))
    )

    params <- c(
        params,
        list(trade_id)
    )

    DBI::dbExecute(

        con_lab,

        paste0(

            "

            UPDATE trades

            SET

            ",

            paste(
                updates,
                collapse = ", "
            ),

            "

            WHERE trade_id = ?

            "

        ),

        params = params

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Open trade
#--------------------------------------------------------
open_trade <- function(
    con_lab,
    trade_id,
    actual_entry,
    actual_shares,
    actual_stop = NULL,
    entry_datetime = Sys.time()
){

    if(!trade_exists(con_lab, trade_id))
        stop("Trade does not exist.")

    trade <- get_trade(
        con_lab,
        trade_id
    )

    if(trade$status != "Planned")
        stop("Only planned trades can be opened.")

    DBI::dbExecute(

        con_lab,

        "

        UPDATE trades

        SET

            status = ?,

            actual_entry = ?,

            actual_shares = ?,

            actual_stop = ?,

            entry_datetime = ?,

            updated_datetime = ?

        WHERE trade_id = ?

        ",

        params = list(

            "Open",

            actual_entry,

            actual_shares,

            actual_stop,

            as.character(entry_datetime),

            as.character(Sys.time()),

            trade_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Close trade
#--------------------------------------------------------
close_trade <- function(
    con_lab,
    trade_id,
    actual_exit,
    exit_reason,
    fees = 0,
    exit_datetime = Sys.time()
){

    if(!trade_exists(con_lab, trade_id))
        stop("Trade does not exist.")

    trade <- get_trade(
        con_lab,
        trade_id
    )

    if(trade$status != "Open")
        stop("Only open trades can be closed.")

    profit <-

        calculate_trade_profit(

            shares = trade$actual_shares,

            entry = trade$actual_entry,

            exit = actual_exit,

            fees = fees

        )

    profit_pct <-

        calculate_profit_percent(

            entry = trade$actual_entry,

            exit = actual_exit

        )

    R_multiple <-

        calculate_R_multiple(

            entry = trade$planned_entry,

            stop = trade$planned_stop,

            exit = actual_exit

        )

    DBI::dbExecute(

        con_lab,

        "

        UPDATE trades

        SET

            status = ?,

            actual_exit = ?,

            exit_datetime = ?,

            exit_reason = ?,

            fees = ?,

            profit = ?,

            profit_pct = ?,

            R_multiple = ?,

            updated_datetime = ?

        WHERE trade_id = ?

        ",

        params = list(

            "Closed",

            actual_exit,

            as.character(exit_datetime),

            exit_reason,

            fees,

            profit,

            profit_pct,

            R_multiple,

            as.character(Sys.time()),

            trade_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Trade plan
#--------------------------------------------------------
get_trade_plan <- function(
    con_lab,
    trade_id
){

    if(!trade_exists(con_lab, trade_id))
        stop("Trade does not exist.")

    DBI::dbGetQuery(

        con_lab,

        "

        SELECT

            trade_id,

            idea_id,

            status,

            scanner_setup,

            planned_entry,

            planned_stop,

            planned_target,

            planned_shares

        FROM trades

        WHERE trade_id = ?

        ",

        params = list(

            trade_id

        )

    )

}


#========================================================
# Count planned trades
#========================================================

count_planned_trades <- function(con_lab){

  DBI::dbGetQuery(
    con_lab,
    "
    SELECT COUNT(*) AS n
    FROM trades
    WHERE status = 'Planned'
    "
  )$n

}

#========================================================
# Count open trades
#========================================================

count_open_trades <- function(con_lab){

  DBI::dbGetQuery(
    con_lab,
    "
    SELECT COUNT(*) AS n
    FROM trades
    WHERE status = 'Open'
    "
  )$n

}

#========================================================
# Count closed trades
#========================================================

count_closed_trades <- function(con_lab){

  DBI::dbGetQuery(
    con_lab,
    "
    SELECT COUNT(*) AS n
    FROM trades
    WHERE status = 'Closed'
    "
  )$n

}