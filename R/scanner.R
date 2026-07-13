#========================================================
# Scanner Engine
#========================================================

#--------------------------------------------------------
# Scan market
#--------------------------------------------------------
scan_market <- function(
    con,
    tickers = get_universe_tickers(con),
    min_score = 0,
    triggered_only = FALSE,
    setups = NULL
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

            scan_ticker(

                con,

                ticker

            )

        }

    )

    results <- Filter(

        function(x)

            !is.null(x) && x$success,

        results

    )

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
    con,
    ticker
){

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

    make_result(

        success = TRUE,

        message = "Scanned.",

        rows = 1,

        data = list(

            summary = summary,

            analysis = analysis

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

    setup_count <-

        sum(

            setups,

            na.rm = TRUE

        )

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

    reasons <- character()

    if(row$trend_emerging){

        reasons <- c(
            reasons,
            "Emerging trend"
        )

    }

    if(row$breakout_20){

        if(row$volume_surge){

            reasons <- c(
                reasons,
                "Confirmed breakout"
            )

        } else {

            reasons <- c(
                reasons,
                "Breakout without volume confirmation"
            )

        }

    }

    if(row$pullback){

        reasons <- c(
            reasons,
            "Healthy pullback"
        )

    }

    if(length(reasons) == 0){

        reasons <- "No active setup"

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

        reason = paste(

            reasons,

            collapse = "; "

        ),

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