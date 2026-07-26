#========================================================
# Promote Watchlist -> Idea
#========================================================

promote_watchlist_to_idea <- function(
    con,
    summary,
    analysis,
    source = "Watchlist"
){


    DBI::dbBegin(con)

    tryCatch({

        #----------------------------------------
        # Create idea object
        #----------------------------------------

        idea <- create_idea_object(

            summary = summary,

            analysis = analysis,

            source = source

        )

        #----------------------------------------
        # Save idea
        #----------------------------------------

        idea_id <- create_idea(

            con,

            idea

        )

        #----------------------------------------
        # Create first history snapshot
        #----------------------------------------

        add_idea_history(

            con,

            idea_id,

            idea

        )

        #----------------------------------------
        # Remove from watchlist
        #----------------------------------------

        delete_watchlist(

            con,

            summary$ticker

        )

        DBI::dbCommit(con)

        return(idea_id)

    }, error = function(e){

        DBI::dbRollback(con)

        stop(e)

    })

}