#========================================================
# Promote Watchlist -> Idea
#========================================================

promote_watchlist_to_idea <- function(
    con,
    idea
){


   DBI::dbBegin(con)

    tryCatch({

        idea_id <- create_idea(
            con,
            idea
        )

        add_idea_history(
            con,
            idea_id,
            idea
        )

        delete_watchlist(
            con,
            idea$ticker
        )

        DBI::dbCommit(con)

        idea_id

    }, error = function(e){

        DBI::dbRollback(con)

        stop(e)

    })

}