#========================================================
# Idea History
#========================================================

#--------------------------------------------------------
# Add history record
#--------------------------------------------------------
add_idea_history <- function(
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

    summary <- idea$summary

    DBI::dbExecute(

        con,

        "

        INSERT INTO idea_history (

            idea_id,

            snapshot_datetime,

            close,

            setup,

            score,

            confidence,

            setup_count,

            triggered_setup,

            status,

            reason

        )

        VALUES (

            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?

        )

        ",

        params = list(

            idea_id,

            as.character(Sys.time()),

            summary$close,

            summary$closest_setup,

            summary$setup_score,

            summary$confidence,

            summary$setup_count,

            summary$triggered_setup,

            idea$status,

            summary$reason

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Get history
#--------------------------------------------------------
get_idea_history <- function(
    con,
    idea_id
){

    DBI::dbGetQuery(

        con,

        "

        SELECT *

        FROM idea_history

        WHERE idea_id = ?

        ORDER BY snapshot_datetime

        ",

        params = list(

            idea_id

        )

    )

}

#--------------------------------------------------------
# Latest history
#--------------------------------------------------------
latest_idea_history <- function(
    con,
    idea_id
){

    DBI::dbGetQuery(

        con,

        "

        SELECT *

        FROM idea_history

        WHERE idea_id = ?

        ORDER BY snapshot_datetime DESC

        LIMIT 1

        ",

        params = list(

            idea_id

        )

    )

}

#--------------------------------------------------------
# Delete history
#--------------------------------------------------------
delete_idea_history <- function(
    con,
    idea_id
){

    DBI::dbExecute(

        con,

        "

        DELETE

        FROM idea_history

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Count history
#--------------------------------------------------------
count_idea_history <- function(
    con,
    idea_id
){

    DBI::dbGetQuery(

        con,

        "

        SELECT COUNT(*) AS n

        FROM idea_history

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )$n[[1]]

}