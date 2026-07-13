#--------------------------------------------------------
# Get metadata value
#--------------------------------------------------------
metadata_get <- function(
    con,
    key,
    default = NULL
){

    res <- DBI::dbGetQuery(

        con,

        "
        SELECT value
        FROM metadata
        WHERE key = ?
        ",

        params = list(key)

    )

    if(nrow(res) == 0){

        if(is.null(default) &&
           key %in% names(config$metadata_schema)){

            default <- config$metadata_schema[[key]]$default

        }

        return(default)

    }

    value <- res$value[1]

    if(!(key %in% names(config$metadata_schema))){

        return(value)

    }

    type <- config$metadata_schema[[key]]$type

    switch(

        type,

        integer = as.integer(value),

        numeric = as.numeric(value),

        character = as.character(value),

        logical = as.logical(value),

        Date = as.Date(value),

        POSIXct = as.POSIXct(value),

        value

    )

}


#--------------------------------------------------------
# Set metadata value
#--------------------------------------------------------
metadata_set <- function(con, key, value){

  DBI::dbExecute(

    con,

    "
    INSERT INTO metadata(key, value)

    VALUES(?, ?)

    ON CONFLICT(key)

    DO UPDATE SET

      value = excluded.value
    ",

    params = list(

      key,

      as.character(value)

    )

  )

  invisible(TRUE)

}


#--------------------------------------------------------
# Delete metadata key
#--------------------------------------------------------
metadata_delete <- function(con, key){

  DBI::dbExecute(

    con,

    "DELETE FROM metadata
     WHERE key = ?",

    params = list(key)

  )

  invisible(TRUE)

}

#--------------------------------------------------------
# Does a metadata key exist?
#--------------------------------------------------------
metadata_exists <- function(con, key){

  res <- DBI::dbGetQuery(

    con,

    "SELECT COUNT(*) AS n
     FROM metadata
     WHERE key = ?",

    params = list(key)

  )

  res$n > 0

}

#--------------------------------------------------------
# Return all metadata
#--------------------------------------------------------
metadata_list <- function(con){

  DBI::dbGetQuery(

    con,

    "SELECT *
     FROM metadata
     ORDER BY key"

  )

}

update_metadata <- function(con, summary){

    metadata_set(con, "latest_database_date", summary$latest_database_date)

    metadata_set(con, "last_update", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))

    metadata_set(con, "rows_added", summary$rows_added)

    metadata_set(con, "tickers_processed", summary$processed)

    metadata_set(con, "tickers_updated", summary$updated)

    metadata_set(con, "tickers_unchanged", summary$unchanged)

    metadata_set(con, "tickers_failed", summary$failed)

    metadata_set(con, "update_duration_seconds", summary$duration_seconds)

}
