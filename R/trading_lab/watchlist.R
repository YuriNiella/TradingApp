#========================================================
# Trading Lab Watchlist
#========================================================

create_watchlist_table <- function(con){

    DBI::dbExecute(con, "

        CREATE TABLE IF NOT EXISTS watchlist (

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            ticker TEXT NOT NULL UNIQUE,

            setup TEXT,

            score REAL,

            confidence REAL,

            reason TEXT,

            added_date TEXT,

            status TEXT DEFAULT 'Active',

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
          AND status = 'Active'
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

            added_date = Sys.Date(),

            status = "Active",

            notes = "",

            stringsAsFactors = FALSE

        ),

        append = TRUE

    )

    TRUE

}

get_watchlist <- function(con){

    DBI::dbGetQuery(

        con,

        "SELECT * FROM watchlist
         WHERE status = 'Active'
         ORDER BY score DESC"

    )

}