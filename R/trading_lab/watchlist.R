#========================================================
# Trading Lab Watchlist
#========================================================

create_watchlist_table <- function(con){

    DBI::dbExecute(con, "

        CREATE TABLE IF NOT EXISTS watchlist (

            watchlist_id INTEGER PRIMARY KEY AUTOINCREMENT,

            ticker TEXT NOT NULL,

            setup TEXT,

            score REAL,

            confidence REAL,

            reason TEXT,

            added_date TEXT,

            notes TEXT

        )

    ")

}

add_watchlist <- function(con, setup){

    exists <- DBI::dbGetQuery(

        con,

        "
        SELECT COUNT(*) AS n
        FROM watchlist
        WHERE ticker = ?
        ",

        params = list(setup$ticker)

    )

    if(exists$n > 0){

        return(FALSE)

    }

    DBI::dbWriteTable(

        con,

        "watchlist",

        data.frame(

            ticker = setup$ticker,

            setup = setup$closest_setup,

            score = setup$setup_score,

            confidence = setup$confidence,

            reason = setup$reason,

            added_date = as.character(Sys.Date()),

            notes = "",

            stringsAsFactors = FALSE

        ),

        append = TRUE

    )

    TRUE

}

#========================================================
# Delete from Watchlist
#========================================================

delete_watchlist <- function(con, ticker){

    DBI::dbExecute(

        con,

        "
        DELETE FROM watchlist
        WHERE ticker = ?
        ",

        params = list(ticker)

    )

}

get_watchlist <- function(con){

    DBI::dbGetQuery(

        con,

        "
        SELECT *
        FROM watchlist
        ORDER BY score DESC
        "

    )

}