#========================================================
# Ideas
#========================================================

#--------------------------------------------------------
# Insert idea
#--------------------------------------------------------
create_idea <- function(
    con,
    idea
){

    stopifnot(

        is.data.frame(idea$summary),

        nrow(idea$summary) == 1

    )

    now <- as.character(Sys.time())

    DBI::dbExecute(

        con,

        "

        INSERT INTO ideas (

            ticker,

            created_datetime,

            updated_datetime,

            source,

            status,

            current_setup,

            current_score,

            current_reason,

            current_price,

            planned_entry,

            planned_stop,

            planned_target,

            risk_percent,

            planned_position_size,

            planned_r_multiple,

            planner,

            notes

        )

        VALUES (

            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?

        )

        ",

        params = list(

            idea$ticker,

            now,                     

            now,                     

            idea$source,

            idea$status,

            idea$summary$closest_setup,

            idea$summary$setup_score,

            idea$summary$reason,

            idea$summary$close,

            idea$trade_plan$planned_entry,

            idea$trade_plan$planned_stop,

            idea$trade_plan$planned_target,

            idea$trade_plan$risk_percent,

            idea$trade_plan$planned_position_size,

            idea$trade_plan$planned_r_multiple,

            idea$trade_plan$planner,

            NA_character_              # notes

        )

    )

    DBI::dbGetQuery(

        con,

        "

        SELECT last_insert_rowid() AS idea_id

        "

    )$idea_id[[1]]

}

#--------------------------------------------------------
# Get idea
#--------------------------------------------------------
get_idea <- function(
    con,
    idea_id
){

    DBI::dbGetQuery(

        con,

        "

        SELECT *

        FROM ideas

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )

}

#--------------------------------------------------------
# Get ideas
#--------------------------------------------------------
get_ideas <- function(
    con,
    status = NULL
){

    if(is.null(status)){

        return(

            DBI::dbGetQuery(

                con,

                "

                SELECT *

                FROM ideas

                ORDER BY created_datetime DESC

                "

            )

        )

    }

    DBI::dbGetQuery(

        con,

        "

        SELECT *

        FROM ideas

        WHERE status = ?

        ORDER BY created_datetime DESC

        ",

        params = list(

            status

        )

    )

}

#--------------------------------------------------------
# Update idea
#--------------------------------------------------------
update_idea <- function(
    con,
    idea_id,
    status = NULL,
    notes = NULL
){

    if(!idea_exists(
        con,
        idea_id
    )){

        stop(

            "Idea does not exist.",

            call. = FALSE

        )

    }

    now <- as.character(Sys.time())

    if(!is.null(status)){

        DBI::dbExecute(

            con,

            "

            UPDATE ideas

            SET

                status = ?,

                updated_datetime = ?

            WHERE idea_id = ?

            ",

            params = list(

                status,

                now,

                idea_id

            )

        )

    }

    if(!is.null(notes)){

        DBI::dbExecute(

            con,

            "

            UPDATE ideas

            SET

                notes = ?,

                updated_datetime = ?

            WHERE idea_id = ?

            ",

            params = list(

                notes,

                now,

                idea_id

            )

        )

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Update status
#--------------------------------------------------------
update_idea_status <- function(
    con,
    idea_id,
    status
){

    update_idea(

        con,

        idea_id,

        status = status

    )

}

#--------------------------------------------------------
# Delete idea
#--------------------------------------------------------
delete_idea <- function(
    con,
    idea_id
){

    if(!idea_exists(
        con,
        idea_id
    )){

        stop(

            "Idea does not exist.",

            call. = FALSE

        )

    }

    DBI::dbExecute(

        con,

        "

        DELETE

        FROM ideas

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Idea exists
#--------------------------------------------------------
idea_exists <- function(
    con,
    idea_id
){

    DBI::dbGetQuery(

        con,

        "

        SELECT COUNT(*) AS n

        FROM ideas

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )$n[[1]] > 0

}

#--------------------------------------------------------
# Count ideas
#--------------------------------------------------------
count_ideas <- function(
    con,
    status = NULL
){

    if(is.null(status)){

        return(

            DBI::dbGetQuery(

                con,

                "

                SELECT COUNT(*) AS n

                FROM ideas

                "

            )$n[[1]]

        )

    }

    DBI::dbGetQuery(

        con,

        "

        SELECT COUNT(*) AS n

        FROM ideas

        WHERE status = ?

        ",

        params = list(

            status

        )

    )$n[[1]]

}

#========================================================
# Idea Object
#========================================================

create_idea_object <- function(
    summary,
    analysis,
    source = "Scanner"
){

    stopifnot(

        nrow(summary) == 1,

        nrow(analysis) == 1

    )

    plan <- build_trade_plan(summary, analysis)

    list(

        ticker = summary$ticker,

        created_datetime = Sys.time(),

        market_date = summary$date,

        source = source,

        status = "Watching",

        summary = summary,

        analysis = analysis,

        trade_plan = plan

    )

}

#--------------------------------------------------------
# Refresh idea record
#--------------------------------------------------------
refresh_idea_record <- function(
    con,
    idea_id,
    idea
){

    stopifnot(

        idea_exists(
            con,
            idea_id
        )

    )

    now <- as.character(Sys.time())

    DBI::dbExecute(

        con,

        "

        UPDATE ideas

        SET

            updated_datetime = ?,

            status = ?,

            current_setup = ?,

            current_score = ?,

            current_reason = ?,

            current_price = ?

        WHERE idea_id = ?

        ",

        params = list(

            now,

            idea$status,

            idea$summary$closest_setup,

            idea$summary$setup_score,

            idea$summary$reason,

            idea$summary$close,

            idea_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Get active ideas
#--------------------------------------------------------
get_active_ideas <- function(
    con,
    statuses = IDEA_STATUS$active
){

    stopifnot(

        length(statuses) > 0

    )

    placeholders <-

        paste(

            rep("?", length(statuses)),

            collapse = ", "

        )

    query <- paste0(

        "

        SELECT *

        FROM ideas

        WHERE status IN (",

        placeholders,

        ")

        ORDER BY

            current_score DESC,

            updated_datetime DESC

        "

    )

    DBI::dbGetQuery(

        con,

        query,

        params = as.list(statuses)

    )

}

#--------------------------------------------------------
# Get inactive ideas
#--------------------------------------------------------
get_inactive_ideas <- function(
    con,
    statuses = IDEA_STATUS$inactive
){

    get_active_ideas(

        con,

        statuses = statuses

    )

}