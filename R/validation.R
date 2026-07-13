#========================================================
# Application Validation
#========================================================

#--------------------------------------------------------
# Validate application
#--------------------------------------------------------

validate_application <- function(ctx){

    validate_configuration(ctx)

    validate_database(ctx)

    validate_cache(ctx)

    invisible(TRUE)

}

#--------------------------------------------------------
# Validate database
#--------------------------------------------------------

validate_database <- function(ctx){

    health <- database_health(ctx$con)

    failed <- names(Filter(isFALSE, health))

    if(length(failed) > 0){

        stop(

            paste(

                "Database validation failed:",

                paste(failed, collapse = ", ")

            ),

            call. = FALSE

        )

    }

}

#--------------------------------------------------------
# Validate cache
#--------------------------------------------------------

validate_cache <- function(ctx){

    required <- c(

        config$paths$cache,

        file.path(config$paths$cache, "yahoo"),
        file.path(config$paths$cache, "yahoo", "metadata")

    )

    missing <- required[!dir.exists(required)]

    if(length(missing) > 0){

        stop(

            paste(
                "Missing cache directories:",
                paste(missing, collapse = ", ")
            ),

            call. = FALSE

        )

    }

    invisible(TRUE)

}

#--------------------------------------------------------
# Validate configuration
#--------------------------------------------------------

validate_configuration <- function(ctx){

    required <- c(

        "app",

        "database",

        "market",

        "universe",

        "indicators",

        "strategy",

        "update",

        "paths"

    )

    stopifnot(is.character(ctx$config$app$name))
    stopifnot(is.character(ctx$config$market$timezone))
    stopifnot(is.numeric(ctx$config$universe$price_min))

    missing <- setdiff(

        required,

        names(ctx$config)

    )

    if(length(missing)>0){

        stop(

            paste(

                "Missing configuration:",

                paste(missing, collapse=", ")

            ),

            call.=FALSE

        )

    }

}

