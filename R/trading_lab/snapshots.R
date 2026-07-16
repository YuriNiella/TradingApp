#========================================================
# Snapshots
#========================================================

#--------------------------------------------------------
# Add snapshot
#--------------------------------------------------------
add_snapshot <- function(
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

    snapshot_json <-

        jsonlite::toJSON(

            idea,

            dataframe = "rows",

            auto_unbox = TRUE,

            null = "null"

        )

    DBI::dbExecute(

        con,

        "

        INSERT INTO snapshots (

            idea_id,

            snapshot_datetime,

            snapshot_json

        )

        VALUES (

            ?, ?, ?

        )

        ",

        params = list(

            idea_id,

            as.character(Sys.time()),

            snapshot_json

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Get snapshot
#--------------------------------------------------------
get_snapshot <- function(
    con,
    snapshot_id
){

    snapshot <-

        DBI::dbGetQuery(

            con,

            "

            SELECT *

            FROM snapshots

            WHERE snapshot_id = ?

            ",

            params = list(

                snapshot_id

            )

        )

    if(nrow(snapshot) == 0){

        return(NULL)

    }

    snapshot$snapshot_json <-

        jsonlite::fromJSON(

            snapshot$snapshot_json[[1]],

            simplifyDataFrame = TRUE

        )

    snapshot

}

#--------------------------------------------------------
# Latest snapshot
#--------------------------------------------------------
latest_snapshot <- function(
    con,
    idea_id
){

    snapshot <-

        DBI::dbGetQuery(

            con,

            "

            SELECT *

            FROM snapshots

            WHERE idea_id = ?

            ORDER BY snapshot_datetime DESC

            LIMIT 1

            ",

            params = list(

                idea_id

            )

        )

    if(nrow(snapshot) == 0){

        return(NULL)

    }

        snapshot$snapshot <-

        list(

            jsonlite::fromJSON(
                snapshot$snapshot_json[[1]]
            )

        )

    snapshot

}

#--------------------------------------------------------
# Delete snapshots
#--------------------------------------------------------
delete_snapshots <- function(
    con,
    idea_id
){

    DBI::dbExecute(

        con,

        "

        DELETE

        FROM snapshots

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )

    invisible(TRUE)

}

#--------------------------------------------------------
# Count snapshots
#--------------------------------------------------------
count_snapshots <- function(
    con,
    idea_id
){

    DBI::dbGetQuery(

        con,

        "

        SELECT COUNT(*) AS n

        FROM snapshots

        WHERE idea_id = ?

        ",

        params = list(

            idea_id

        )

    )$n[[1]]

}

#--------------------------------------------------------
# Restore snapshots
#--------------------------------------------------------
restore_snapshot <- function(snapshot){

    jsonlite::fromJSON(
        snapshot$snapshot_json[[1]]
    )

}