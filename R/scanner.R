#========================================================
# Scanner Engine
#========================================================

#--------------------------------------------------------
# Scan market
#--------------------------------------------------------
scan_market <- function(
    con,
    tickers = build_scan_universe(con),
    min_score = 0,
    triggered_only = FALSE,
    setups = NULL,
    progress_callback = NULL
){

    validate_database(con)

    start_time <- Sys.time()

    batches <- split_batches(
        tickers,
        config$scanner$batch_size
    )

    batch_results <- vector(
        "list",
        length(batches)
    )

    for(i in seq_along(batches)){

        if(!is.null(progress_callback)){
            progress_callback(
                current = i,
                total = length(batches),
                batch = i
            )

        }

        cat(
            "Scanning batch",
            i,
            "of",
            length(batches),
            "(",
            length(batches[[i]]),
            "tickers)\n"
        )

        batch_results[[i]] <-

            scan_batch(
                con,
                batches[[i]]
            )

    }

    results <-

        dplyr::bind_rows(
            batch_results
        )


    #----------------------------------------------------
    # Filter scan results
    #----------------------------------------------------

    if(triggered_only){

        results <-

            dplyr::filter(

                results,

                !is.na(triggered_setup)

            )

    }

    if(!is.null(setups)){

        results <-

            dplyr::filter(

                results,

                closest_setup %in% setups

            )

    }

    results <-

        dplyr::filter(

            results,

            setup_score >= min_score

        )

    results <-

        rank_candidates(
            results
        )


    summary <-

        summarise_scan(
            results,
            start_time
        )

    make_result(

        success = TRUE,

        message = paste(
            nrow(results),
            "tickers scanned."
        ),

        rows = nrow(results),

        data = list(

            scan = results,

            summary = summary

        )

    )

}

#--------------------------------------------------------
# Rank candidates
#--------------------------------------------------------
rank_candidates <- function(
    scan
){

    scan |>

        dplyr::arrange(

            dplyr::desc(setup_score),

            dplyr::desc(setup_count),

            ticker

        )

}

#--------------------------------------------------------
# Scan batch
#--------------------------------------------------------
scan_batch <- function(
    con,
    tickers
){

    results <- lapply(

        tickers,

        function(ticker){

            cat("Scanning", ticker, "\n")

            result <- tryCatch({

                scan_ticker(
                    con,
                    ticker
                )

            }, error = function(e){

                message("Failed: ", ticker, " - ", conditionMessage(e))

                NULL

            })

        }

    )

    results <- Filter(Negate(is.null), results)

    if(length(results) == 0){

        return(data.frame())

    }

    dplyr::bind_rows(

        lapply(

            results,

            function(x)

                x$data$summary

        )

    )

}

#--------------------------------------------------------
# Scan ticker
#--------------------------------------------------------
scan_ticker <- function(
    con = NULL,
    ticker
){

    if(is.null(con)){

        con <- connect_database()

        on.exit(
            DBI::dbDisconnect(con),
            add = TRUE
        )

    }

    prices <- load_prices(
        con,
        ticker
    )

    if(nrow(prices) == 0){

        return(

            make_result(

                success = FALSE,

                message = "No price history.",

                data = list(

                    ticker = ticker

                )

            )

        )

    }

    prices <- calculate_indicators(prices)

    prices <- calculate_market_structure(prices)

    prices <- calculate_features(prices)

    prices <- calculate_setups(prices)

    prices <- calculate_scores(prices)

    analysis <-

        prices[nrow(prices), ]

    analysis$ticker <- ticker

    summary <-

        summarise_ticker(
            analysis
        )

    #----------------------------------------------------
    # Trading Lab object
    #----------------------------------------------------

    idea <-

        create_idea_object(

            summary,

            analysis

        )

    make_result(

        success = TRUE,

        message = "Scanned.",

        rows = 1,

        data = list(

            summary = summary,

            analysis = analysis,

            idea = idea

        )

    )

}

#--------------------------------------------------------
# Summarise ticker
#--------------------------------------------------------

summarise_ticker <- function(
    row
){

    scores <- c(

        Breakout = row$score_breakout,

        Emerging_Breakout = row$score_emerging_breakout,

        Pullback = row$score_pullback

    )

    setups <- c(

        Breakout = row$setup_breakout,

        Emerging_Breakout = row$setup_emerging_breakout,

        Pullback = row$setup_pullback

    )

    closest_setup <-

        names(

            which.max(scores)

        )

    setup_score <-

        max(

            scores,

            na.rm = TRUE

        )

    setups[is.na(setups)] <- FALSE

    setup_count <- sum(setups)

    if(any(setups)){

        triggered_setup <-

            names(

                which.max(

                    scores[setups]

                )

            )

    } else {

        triggered_setup <- NA_character_

    }

    confidence <-

        dplyr::case_when(

            setup_score >= 90 ~ "★★★★★",

            setup_score >= 80 ~ "★★★★",

            setup_score >= 70 ~ "★★★",

            setup_score >= 60 ~ "★★",

            TRUE ~ "★"

        )

    #----------------------------------------------------
    # Reason
    #----------------------------------------------------

    if(!is.na(triggered_setup)){

        reason <- switch(

            triggered_setup,

            Breakout =
                "Confirmed breakout",

            Emerging_Breakout =
                "Emerging breakout",

            Pullback =
                "Healthy pullback"

        )

    } else {

        reason <- switch(

            closest_setup,

            Breakout =

                if(isTRUE(row$near_high))

                    "Near breakout, waiting for confirmation"

                else

                    "No active breakout setup",

            Emerging_Breakout =

                if(row$market_structure == "Range")

                    "Potential emerging breakout"

                else

                    "No active emerging breakout",

            Pullback =

                if(!isTRUE(row$trend_up))

                    paste(

                        "Pullback candidate, but market structure is",

                        row$market_structure

                    )

                else

                    "No active pullback setup"

        )

    }

    data.frame(

        ticker = row$ticker,

        date = row$date,

        close = row$close,

        closest_setup = closest_setup,

        triggered_setup = triggered_setup,

        setup_score = setup_score,

        setup_count = setup_count,

        confidence = confidence,

        reason = reason,

        stringsAsFactors = FALSE

    )

}

#--------------------------------------------------------
# Scan summary
#--------------------------------------------------------
summarise_scan <- function(
    results,
    start_time
){

    list(

        scanned = nrow(results),

        triggered = sum(
            results$setup_count > 0,
            na.rm = TRUE
        ),

        max_setup_score = max(
            results$setup_score,
            na.rm = TRUE
        ),

        duration_seconds = round(

            as.numeric(

                difftime(

                    Sys.time(),

                    start_time,

                    units = "secs"

                )

            ),

            1

        )

    )

}
