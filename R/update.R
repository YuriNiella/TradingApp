#--------------------------------------------------------
# Determine download window
#--------------------------------------------------------
download_window <- function(

    latest_database_date,

    latest_market_date,

    lookback_days = config$update$history_days

){

    #----------------------------------------------------
    # Unable to determine latest market date
    #----------------------------------------------------

    if(is.null(latest_market_date)){

        return(list(

            required = FALSE,

            reason = "Unable to determine latest market date",

            from = NULL

        ))

    }

    #----------------------------------------------------
    # Ticker not yet in database
    #----------------------------------------------------

    if(length(latest_database_date) == 0 ||

       is.na(latest_database_date)){

        return(list(

            required = TRUE,

            reason = "Ticker not in database",

            from = latest_market_date - lookback_days

        ))

    }

    #----------------------------------------------------
    # Already current
    #----------------------------------------------------

    from <- latest_database_date + 1

    if(from > latest_market_date){

        return(list(

            required = FALSE,

            reason = "Already up to date",

            from = NULL

        ))

    }

    #----------------------------------------------------
    # Update required
    #----------------------------------------------------

    list(

        required = TRUE,

        reason = "New market data available",

        from = from

    )

}

#--------------------------------------------------------
# Download one ticker from Yahoo
#--------------------------------------------------------
download_ticker <- function(
    ticker,
    from
){

    df <- NULL

    for(attempt in seq_len(config$update$retry_attempts)){

        df <- fetch_yahoo(
            ticker,
            from
        )

        if(!is.null(df) && nrow(df) > 0){

            break

        }

        message(
            sprintf(
                "Retry %d/%d: %s",
                attempt,
                config$update$retry_attempts,
                ticker
            )
        )

        Sys.sleep(attempt)
    }

    if(is.null(df) || nrow(df) == 0){

        message(sprintf(
            "Download failed for %s",
            ticker
        ))

        return(

            make_result(

                success = FALSE,

                message = "No data returned from Yahoo",

                data = list(

                    ticker = ticker,

                    from = from,

                    download = NULL

                )

            )

        )

    }

    make_result(

        success = TRUE,

        message = "Downloaded",

        rows = nrow(df),

        data = list(

            ticker = ticker,

            latest_downloaded = max(df$date),

            download = df

        )

    )

}


#--------------------------------------------------------
# Update one ticker
#--------------------------------------------------------
update_ticker <- function(

    con,

    ticker,

    lookback_days = 730

){

    window <- download_window(

        con,

        ticker,

        lookback_days

    )

    if (!window$required) {

        return(

            make_result(

                success = TRUE,

                message = window$reason,

                rows = 0,

                data = list(

                    ticker = ticker,

                    latest_database_date = window$latest_database_date,

                    latest_market_date = window$latest_market_date,

                    latest_downloaded = window$latest_database_date

                )

            )

        )

    }

    df <- fetch_yahoo(

        ticker,

        window$from

    )

    if (is.null(df) || nrow(df) == 0) {

        return(

            make_result(

                success = FALSE,

                message = "No data returned from Yahoo",

                rows = 0,

                data = list(

                    ticker = ticker,

                    latest_database_date = window$latest_database_date,

                    latest_market_date = window$latest_market_date

                )

            )

        )

    }

    result <- safe_insert(

        con,

        df

    )

    result$data <- list(

        ticker = ticker,

        latest_database_date = window$latest_database_date,

        latest_market_date = window$latest_market_date,

        latest_downloaded = max(df$date),

        rows_downloaded = nrow(df)

    )

    result

}

#--------------------------------------------------------
# Download one batch
#--------------------------------------------------------
#--------------------------------------------------------
# Download one batch
#--------------------------------------------------------
download_batch <- function(
    con,
    tickers
){

    latest_market_date <- get_latest_market_date()

    latest_dates <- get_latest_ticker_dates(con)

    latest_lookup <- setNames(

        latest_dates$latest_date,

        latest_dates$ticker

    )

    downloads <- vector(
        "list",
        length(tickers)
    )

    names(downloads) <- tickers

    #----------------------------------------------------
    # Determine which tickers require downloading
    #----------------------------------------------------

    jobs <- data.frame(

        index = integer(),

        ticker = character(),

        from = as.Date(character()),

        stringsAsFactors = FALSE

    )

    for(i in seq_along(tickers)){

        ticker <- tickers[i]

        latest_db <- latest_lookup[ticker]

        window <- download_window(

            latest_database_date = latest_db,

            latest_market_date = latest_market_date

        )

        if(!window$required){

            downloads[[i]] <- make_result(

                success = TRUE,

                message = window$reason,

                rows = 0,

                data = list(

                    ticker = ticker,

                    download = NULL

                )

            )

            next

        }

        jobs <- rbind(

            jobs,

            data.frame(

                index = i,

                ticker = ticker,

                from = window$from,

                stringsAsFactors = FALSE

            )

        )

    }

    #----------------------------------------------------
    # Nothing to download
    #----------------------------------------------------

    if(nrow(jobs) == 0){

        return(downloads)

    }

    #----------------------------------------------------
    # Download required tickers
    #----------------------------------------------------

    if(config$parallel$enabled){

        future::plan(
            future::multisession,
            workers = config$parallel$workers
        )

        on.exit(
            future::plan(future::sequential),
            add = TRUE
        )

        results <- future.apply::future_lapply(

            seq_len(nrow(jobs)),

            function(i){

                download_ticker(

                    ticker = jobs$ticker[i],

                    from = jobs$from[i]

                )

            },

            future.seed = TRUE

        )

    } else {

        results <- lapply(

            seq_len(nrow(jobs)),

            function(i){

                download_ticker(

                    ticker = jobs$ticker[i],

                    from = jobs$from[i]

                )

            }

        )

    }

    #----------------------------------------------------
    # Merge downloads back into original order
    #----------------------------------------------------

    for(i in seq_len(nrow(jobs))){

        downloads[[ jobs$index[i] ]] <- results[[i]]

    }

    downloads

}

#--------------------------------------------------------
# Summarise one downloaded batch
#--------------------------------------------------------
insert_batch <- function(
    con,
    downloads
){

    processed <- length(downloads)

    updated <- 0
    unchanged <- 0
    failed <- 0
    rows_added <- 0

    for(result in downloads){

        if(!result$success){

            failed <- failed + 1

            next

        }

        df <- result$data$download

        if(is.null(df)){

            unchanged <- unchanged + 1

            next

        }

        insert <- safe_insert(
            con,
            df
        )

        rows_added <- rows_added + insert$rows

        if(insert$rows > 0){

            updated <- updated + 1

        }else{

            unchanged <- unchanged + 1

        }

        result$rows <- insert$rows

    }

    list(

        processed = processed,

        updated = updated,

        unchanged = unchanged,

        failed = failed,

        rows_added = rows_added,

        ticker_results = downloads

    )

}


#--------------------------------------------------------
# Update one batch of tickers
#--------------------------------------------------------
update_batch <- function(
    con,
    tickers,
    progress_callback = NULL
){

    if(!is.null(progress_callback)){

        for(i in seq_along(tickers)){

            progress_callback(

                current = i,

                total = length(tickers),

                ticker = tickers[i]

            )

        }

    }

    downloads <- download_batch(

        con,

        tickers

    )

    batch_result <- insert_batch(
        con,

        downloads

    )

    batch_result

}


#--------------------------------------------------------
# Split tickers into batches
#--------------------------------------------------------
split_batches <- function(
    tickers,
    batch_size = config$update$batch_size
){

    split(

        tickers,

        ceiling(seq_along(tickers) / batch_size)

    )

}

#--------------------------------------------------------
# Update database
#--------------------------------------------------------
update_database <- function(
    con,
    tickers = NULL,
    progress_callback = NULL
){

    #----------------------------------------------------
    # Determine universe
    #----------------------------------------------------

    if(is.null(tickers)){
        tickers <- get_universe_tickers(con)
    }

    start_time <- Sys.time()

    ticker_results <- vector("list", length(tickers))

    processed <- 0
    updated <- 0
    unchanged <- 0
    failed <- 0
    rows_added <- 0

    # Download data in batches
    batches <- split_batches(

        tickers,

        config$update$batch_size

    )

    processed <- 0

    updated <- 0

    unchanged <- 0

    failed <- 0

    rows_added <- 0

    ticker_results <- list()

    for(i in seq_along(batches)){

        batch <- batches[[i]]
        
        message(

            sprintf(

                "Batch %d/%d (%d tickers)",

                i,

                length(batches),

                length(batch)

            )

        )

        batch_start <- Sys.time()

        batch_result <- update_batch(

            con,

            batch,

            progress_callback

        )

        batch_time <- round(

            as.numeric(

                difftime(

                    Sys.time(),

                    batch_start,

                    units = "secs"

                )

            ),

            1

        )

        message(

            sprintf(

                "Completed batch %d in %.1f seconds",

                i,

                batch_time

            )

        )

        processed <- processed +

            batch_result$processed

        updated <- updated +

            batch_result$updated

        unchanged <- unchanged +

            batch_result$unchanged

        failed <- failed +

            batch_result$failed

        rows_added <- rows_added +

            batch_result$rows_added

        ticker_results <- c(

            ticker_results,

            batch_result$ticker_results

        )

    }
    
    duration <- round(

        as.numeric(

            difftime(
                Sys.time(),
                start_time,
                units = "secs"
            )

        ),

        1

    )

    summary <- list(

        processed = processed,

        updated = updated,

        unchanged = unchanged,

        failed = failed,

        rows_added = rows_added,

        latest_database_date = get_latest_database_date(con),

        latest_market_date = get_latest_market_date(),

        duration_seconds = duration

    )

    #----------------------------------------------------
    # Persist update metadata
    #----------------------------------------------------

    update_metadata(
        con,
        summary
    )

    #----------------------------------------------------
    # Return structured result
    #----------------------------------------------------

    make_result(

        success = failed == 0,

        message = sprintf(

            "%d processed | %d updated | %d unchanged | %d failed",

            processed,
            updated,
            unchanged,
            failed

        ),

        rows = rows_added,

        data = list(

            summary = summary,

            ticker_results = ticker_results

        )

    )

}
