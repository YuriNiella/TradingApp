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

    stopifnot(

        is.list(idea),

        !is.null(idea$ticker),

        !is.null(idea$summary),

        !is.null(idea$analysis)

    )

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

    if(exists("add_snapshot")){

        add_snapshot(

            con,

            idea_id,

            idea

        )

    }

    DBI::dbCommit(con)

    success <- TRUE

    invisible(idea_id)

}

#--------------------------------------------------------
# Refresh idea
#--------------------------------------------------------
refresh_idea <- function(
    con_lab,
    idea_id,
    idea
){

    DBI::dbBegin(con_lab)

    success <- FALSE

    on.exit({

        if(!success){

            DBI::dbRollback(con_lab)

        }

    }, add = TRUE)

    refresh_idea_record(

        con_lab,

        idea_id,

        idea

    )

    add_idea_history(

        con_lab,

        idea_id,

        idea

    )

    if(exists("add_snapshot")){

        add_snapshot(

            con_lab,

            idea_id,

            idea

        )

    }

    DBI::dbCommit(con_lab)

    success <- TRUE

    invisible(TRUE)

}