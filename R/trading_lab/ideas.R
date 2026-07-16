#========================================================
# Ideas
#========================================================

#--------------------------------------------------------
# Insert idea
#--------------------------------------------------------
insert_idea <- function(
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

            initial_setup,

            initial_score,

            initial_reason,

            initial_price,

            notes

        )

        VALUES (

            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?

        )

        ",

        params = list(

            idea$ticker,

            now,

            now,

            idea$source,

            "Watching",

            idea$summary$closest_setup,

            idea$summary$setup_score,

            idea$summary$reason,

            idea$summary$close,

            NA_character_

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