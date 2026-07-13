#========================================================
# Universe Builder
#========================================================

#--------------------------------------------------------
# Download ASX listed companies
#--------------------------------------------------------
download_asx_directory <- function(

    save_raw = TRUE

){

    url <-
        "https://asx.api.markitdigital.com/asx-research/1.0/companies/directory/file"

    message("Downloading ASX directory...")

    universe <- read.csv(

        url,

        stringsAsFactors = FALSE,

        check.names = FALSE

    )

    if(save_raw){

        if(!dir.exists(config$paths$raw)){

            dir.create(

                config$paths$raw,

                recursive = TRUE

            )

        }

        write.csv(

            universe,

            file.path(

                config$paths$raw,

                "asx_directory_raw.csv"

            ),

            row.names = FALSE

        )

    }

    universe

}

#--------------------------------------------------------
# Clean Universe
#--------------------------------------------------------
clean_universe <- function(universe){

    names(universe) <- c(

        "ticker",

        "company_name",

        "industry_group",

        "listing_date",

        "market_cap"

    )

    universe$ticker <-

        trimws(universe$ticker)

    universe$company_name <-

        trimws(universe$company_name)

    universe$industry_group <-

        trimws(universe$industry_group)

    universe$listing_date <-

        as.Date(

            universe$listing_date,

            format = "%d/%m/%Y"

        )

    #----------------------------------------------------
    # Market Cap
    #----------------------------------------------------

    market_cap <- trimws(universe$market_cap)

    market_cap[market_cap %in% c("", "-", "N/A")] <- NA

    market_cap <- gsub(",", "", market_cap)

    universe$market_cap <- suppressWarnings(
        as.numeric(market_cap)
    )

    missing_market_cap <- sum(is.na(universe$market_cap))

    if (missing_market_cap > 0) {

        message(
            sprintf(
                "%d securities have no market cap.",
                missing_market_cap
            )
        )

    }

    universe <- universe[

        nzchar(universe$ticker),

    ]

    universe <- universe[

        !duplicated(universe$ticker),

    ]

    universe$active <- 1L

    universe$updated_at <-

        Sys.time()

    universe

}

#--------------------------------------------------------
# Save Universe
#--------------------------------------------------------
save_universe <- function(
    universe,
    file = config$paths$universe
){

    #----------------------------------------------------
    # Create destination folder if required
    #----------------------------------------------------

    dir.create(

        dirname(file),

        recursive = TRUE,

        showWarnings = FALSE

    )

    #----------------------------------------------------
    # Save CSV
    #----------------------------------------------------

    write.csv(

        universe,

        file,

        row.names = FALSE,

        na = ""

    )

    #----------------------------------------------------
    # Return result
    #----------------------------------------------------

    make_result(

        success = TRUE,

        message = sprintf(

            "%d securities written to %s",

            nrow(universe),

            basename(file)

        ),

        rows = nrow(universe),

        data = list(

            file = normalizePath(file),

            columns = names(universe)

        )

    )

}

#--------------------------------------------------------
# Build universe
#--------------------------------------------------------
build_universe <- function(
    output_file = config$paths$universe
){

    universe <- download_asx_directory()

    message("Cleaning universe...")

    universe <- clean_universe(universe)

    message("Saving universe...")

    result <- save_universe(

        universe,

        output_file

    )

    result$data$universe <- universe

    result

}

#--------------------------------------------------------
# Syncronise universe
#--------------------------------------------------------
sync_universe <- function(con){

    result <- build_universe()

    if(!result$success){

        return(result)

    }

    update_universe(con)

}


