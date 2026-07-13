#========================================================
# ASX Scanner v2
# UI Components
#
# Reusable UI elements used throughout the application.
#========================================================

library(bslib)

#--------------------------------------------------------
# Status Card
#
# Generic card for displaying any Shiny output.
#--------------------------------------------------------
status_card <- function(
    title,
    content,
    width = 3
){

    column(

        width = width,

        bslib::card(

            full_screen = FALSE,

            card_header(
                strong(title)
            ),

            card_body(

                content

            )

        )

    )

}

status_badge <- function(current) {

    if (current) {

        tags$span(
            class = "badge bg-success",
            "Current"
        )

    } else {

        tags$span(
            class = "badge bg-warning text-dark",
            "Update Required"
        )

    }

}


#--------------------------------------------------------
# Metric Card
#
# Displays a single metric/value.
#--------------------------------------------------------
metric_card <- function(
    title,
    value,
    width = 3
){

    column(

        width = width,

        bslib::card(

            card_header(
                strong(title)
            ),

            card_body(

                h2(value)

            )

        )

    )

}


#--------------------------------------------------------
# Section Header
#--------------------------------------------------------
section_header <- function(title){

    div(

        style = "
        margin-top:25px;
        margin-bottom:15px;
        ",

        h3(title)

    )

}


#========================================================
# Standard Result Object
#========================================================

make_result <- function(

    success = TRUE,

    message = NULL,

    data = NULL,

    rows = 0,

    warnings = character(),

    errors = character()

){

    list(

        success = success,

        message = message,

        data = data,

        rows = rows,

        warnings = warnings,

        errors = errors,

        timestamp = Sys.time()

    )

}