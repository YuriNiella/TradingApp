#========================================================
# Trading Lab Database
#========================================================

DB_TRADING_LAB <-
    config$paths$trading_lab

TRADING_LAB_SCHEMA <-
    "R/trading_lab/schema.sql"

#--------------------------------------------------------
# Connect
#--------------------------------------------------------
connect_trading_lab <- function(

    db_path = DB_TRADING_LAB

){

    con <- DBI::dbConnect(
        RSQLite::SQLite(),
        db_path
    )

    DBI::dbExecute(
        con,
        "PRAGMA foreign_keys = ON;"
    )

    con

}

#--------------------------------------------------------
# Disconnect
#--------------------------------------------------------
disconnect_trading_lab <- function(
    con
){

    if(

        !is.null(con) &&

        DBI::dbIsValid(con)

    ){

        DBI::dbDisconnect(
            con
        )

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Database exists
#--------------------------------------------------------
trading_lab_exists <- function(

    db_path = DB_TRADING_LAB

){

    file.exists(
        db_path
    )

}

#--------------------------------------------------------
# Create database
#--------------------------------------------------------
create_trading_lab <- function(

    db_path = DB_TRADING_LAB

){

    dir.create(

        dirname(db_path),

        recursive = TRUE,

        showWarnings = FALSE

    )

    if(

        !trading_lab_exists(
            db_path
        )

    ){

        initialise_trading_lab(
            db_path
        )

    }

    invisible(TRUE)

}

execute_sql_file <- function(
    con,
    file
){

    sql <-

        paste(

            readLines(
                file,
                warn = FALSE
            ),

            collapse = "\n"

        )

    statements <-

        strsplit(
            sql,
            ";"
        )[[1]]

    statements <-

        trimws(
            statements
        )

    statements <-

        statements[
            nzchar(
                statements
            )
        ]

    for(i in seq_along(statements)){

        statement <- trimws(statements[[i]])

        if(statement == "")
            next

        cat("\n====================\n")
        cat(i, "\n")
        cat("====================\n")
        cat(statement)
        cat("\n\n")

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Initialise database
#--------------------------------------------------------
initialise_trading_lab <- function(

    db_path = DB_TRADING_LAB,

    schema_dir = "R/trading_lab/schema"

){

    message("Initialising Trading Lab...")

    if(!dir.exists(schema_dir)){

        stop(

            "Trading Lab schema directory not found.",

            call. = FALSE

        )

    }

    con <- connect_trading_lab(db_path)

    on.exit(

        disconnect_trading_lab(con),

        add = TRUE

    )

    sql_files <-

        list.files(

            schema_dir,

            pattern = "\\.sql$",

            full.names = TRUE

        )

    sql_files <-

        sort(sql_files)

    if(length(sql_files) == 0){

        stop(

            "No SQL schema files found.",

            call. = FALSE

        )

    }

    for(file in sql_files){

        message(

            "Executing: ",

            basename(file)

        )

        sql <-

            paste(

                readLines(

                    file,

                    warn = FALSE

                ),

                collapse = "\n"

            )

        DBI::dbExecute(

            con,

            sql

        )

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Database version
#--------------------------------------------------------
trading_lab_version <- function(
    con
){

    DBI::dbGetQuery(

        con,

        "

        SELECT value

        FROM metadata

        WHERE key = 'schema_version'

        "

    )$value

}

#--------------------------------------------------------
# Database health
#--------------------------------------------------------
trading_lab_health <- function(
    con
){

    required_tables <- c(

        "metadata",

        "ideas",

        "idea_history",

        "trades",

        "trade_notes",

        "snapshots",

        "settings"

    )

    tables <-

        DBI::dbListTables(
            con
        )

    setNames(

        required_tables %in% tables,

        required_tables

    )

}

#--------------------------------------------------------
# Validate database
#--------------------------------------------------------
validate_trading_lab <- function(
    con
){

    health <-

        trading_lab_health(
            con
        )

    failed <-

        names(

            Filter(

                isFALSE,

                health

            )

        )

    if(

        length(failed) > 0

    ){

        stop(

            paste(

                "Trading Lab database validation failed:",

                paste(

                    failed,

                    collapse = ", "

                )

            ),

            call. = FALSE

        )

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Backup database
#--------------------------------------------------------
backup_trading_lab <- function(

    db_path = DB_TRADING_LAB,

    backup_dir = "backups"

){

    if(

        !trading_lab_exists(
            db_path
        )

    ){

        stop(

            "Trading Lab database does not exist.",

            call. = FALSE

        )

    }

    dir.create(

        backup_dir,

        recursive = TRUE,

        showWarnings = FALSE

    )

    backup_file <-

        file.path(

            backup_dir,

            paste0(

                "asx_trading_lab_",

                format(

                    Sys.time(),

                    "%Y%m%d_%H%M%S"

                ),

                ".sqlite"

            )

        )

    success <-

        file.copy(

            db_path,

            backup_file,

            overwrite = TRUE

        )

    if(

        !success

    ){

        stop(

            "Failed to create Trading Lab backup.",

            call. = FALSE

        )

    }

    backup_file

}

#--------------------------------------------------------
# Open database
#--------------------------------------------------------
open_trading_lab <- function(){

    create_trading_lab()

    con <-

        connect_trading_lab()

    validate_trading_lab(
        con
    )

    con

}

#--------------------------------------------------------
# Recreate database
#--------------------------------------------------------
recreate_trading_lab <- function(

    db_path = DB_TRADING_LAB

){

    if(file.exists(db_path)){

        unlink(db_path)

    }

    create_trading_lab(db_path)

    invisible(TRUE)

}