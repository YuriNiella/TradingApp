#========================================================
# ASX Scanner v2
# Database Engine
#
# Responsible for:
# - Database connections
# - Database initialisation
# - Safe inserts
# - Health checks
# - Database summaries
#========================================================

#========================================================
# Connection Manager
#========================================================

#--------------------------------------------------------
# Open database connection
#--------------------------------------------------------
database_connect <- function(db_path){

    DBI::dbConnect(
        RSQLite::SQLite(),
        db_path
    )

}

#--------------------------------------------------------
# Close database connection
#--------------------------------------------------------
database_disconnect <- function(con){

    if(DBI::dbIsValid(con)){

        DBI::dbDisconnect(con)

    }

}

#--------------------------------------------------------
# Does database exist?
#--------------------------------------------------------
database_exists <- function(db_path){

    file.exists(db_path)

}

#========================================================
# Bootstrap
#========================================================

#--------------------------------------------------------
# Initialise database
#--------------------------------------------------------
database_initialize <- function(con){

    create_prices_table(con)

    create_signals_table(con)

    create_metadata_table(con)

    create_update_log_table(con)

    create_universe_table(con)

    invisible(TRUE)

}

#========================================================
# Data Operations
#========================================================

#--------------------------------------------------------
# Insert rows safely
#--------------------------------------------------------
safe_insert <- function(con, df){

    if(is.null(df)){

        return(
            make_result(
                success = TRUE,
                message = "No data to insert",
                rows = 0
            )
        )

    }

    if(nrow(df) == 0){

        return(
            make_result(
                success = TRUE,
                message = "No rows to insert",
                rows = 0
            )
        )

    }

    sql <- "

        INSERT OR IGNORE INTO prices_daily(

            ticker,
            date,
            open,
            high,
            low,
            close,
            adj_close,
            volume

        )

        VALUES(?,?,?,?,?,?,?,?)

    "

    stmt <- DBI::dbSendStatement(con, sql)

    on.exit(DBI::dbClearResult(stmt))

    inserted <- 0

    for(i in seq_len(nrow(df))){

        DBI::dbBind(

            stmt,

            list(

                df$ticker[i],

                as.character(df$date[i]),

                df$open[i],

                df$high[i],

                df$low[i],

                df$close[i],

                df$adj_close[i],

                df$volume[i]

            )

        )

        inserted <- inserted +

            DBI::dbGetRowsAffected(stmt)

    }

    make_result(

        success = TRUE,

        message = sprintf("%d rows inserted", inserted),

        rows = inserted

    )

}

#========================================================
# Health & Status
#========================================================

#--------------------------------------------------------
# Database health
#--------------------------------------------------------
database_health <- function(con){

    tables <- DBI::dbListTables(con)

    list(

        connected = DBI::dbIsValid(con),

        prices_table = "prices_daily" %in% tables,

        signals_table = "signals_history" %in% tables,

        metadata_table = "metadata" %in% tables,

        update_log_table = "update_log" %in% tables,

        universe_table = "universe" %in% tables

    )

}

#--------------------------------------------------------
# Database summary
#--------------------------------------------------------
database_summary <- function(con){

    health <- database_health(con)

    if(!health$connected){

        return(NULL)

    }

    list(

        connected = TRUE,

        database = basename(DBI::dbGetInfo(con)$dbname),

        total_rows = DBI::dbGetQuery(
            con,
            "SELECT COUNT(*) AS n FROM prices_daily"
        )$n,

        tickers = DBI::dbGetQuery(
            con,
            "SELECT COUNT(DISTINCT ticker) AS n FROM prices_daily"
        )$n,

        latest_session = DBI::dbGetQuery(
            con,
            "SELECT MAX(date) AS d FROM prices_daily"
        )$d,

        health = health

    )

}

#--------------------------------------------------------
# Database status
#--------------------------------------------------------
database_status <- function(con){

    summary <- database_summary(con)

    if(is.null(summary)){

        return(

            make_result(

                success = FALSE,

                message = "Database unavailable"

            )

        )

    }

    latest_market <- get_latest_market_date()

    latest_database <- get_latest_database_date(con)

    current <-

        !is.null(latest_market) &&

        !is.null(latest_database) &&

        latest_database >= latest_market

    make_result(

        success = TRUE,

        message = if(current)
            "Database current"
        else
            "Database requires update",

        data = list(

            connected = summary$connected,

            current = current,

            database = summary$database,

            rows = summary$total_rows,

            tickers = summary$tickers,

            latest_database_date = latest_database,

            latest_market_date = latest_market,

            last_update = metadata_get(con, "last_update"),

            rows_added = metadata_get(con, "rows_added"),

            processed = metadata_get(con, "tickers_processed"),

            updated = metadata_get(con, "tickers_updated"),

            unchanged = metadata_get(con, "tickers_unchanged"),

            failed = metadata_get(con, "tickers_failed"),

            update_duration_seconds = metadata_get(con, "update_duration_seconds")

        )

    )

}