#========================================================
# Trading Lab Workflows
#========================================================

#--------------------------------------------------------
# Capture idea
#--------------------------------------------------------
capture_idea <- function(
    con,
    idea
){

    DBI::dbBegin(con)

    success <- FALSE

    on.exit({

        if(!success){

            DBI::dbRollback(con)

        }

    }, add = TRUE)

    idea_id <-

        create_idea(
            con,
            idea
        )

    add_idea_history(
        con,
        idea_id,
        idea
    )

    add_snapshot(
        con,
        idea_id,
        idea
    )

    DBI::dbCommit(con)

    success <- TRUE

    invisible(idea_id)

}

#--------------------------------------------------------
# Refresh idea
#--------------------------------------------------------
refresh_idea <- function(
    con,
    idea_id,
    idea
){

    DBI::dbBegin(con)

    success <- FALSE

    on.exit({

        if(!success){

            DBI::dbRollback(con)

        }

    }, add = TRUE)

    refresh_idea_record(
        con,
        idea_id,
        idea
    )

    add_idea_history(
        con,
        idea_id,
        idea
    )

    add_snapshot(
        con,
        idea_id,
        idea
    )

    DBI::dbCommit(con)

    success <- TRUE

    invisible(TRUE)

}