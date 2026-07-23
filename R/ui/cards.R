#========================================================
# UI Cards
#========================================================

library(shiny)
library(bslib)
library(fontawesome)

#========================================================
# Generic Card
#========================================================

ui_card <- function(
    ...,
    title = NULL,
    subtitle = NULL,
    footer = NULL,
    icon = NULL,
    class = NULL,
    full_screen = FALSE
){

    header <- NULL

    if(!is.null(title)){

        header <- div(

            class = "card-title-wrapper",

            div(

                class = "card-title-group",

                div(
                    class = "card-title",
                    title
                ),

                if(!is.null(subtitle))
                    div(
                        class = "card-subtitle",
                        subtitle
                    )

            ),

            if(!is.null(icon))
                div(
                    class = "card-icon",
                    icon
                )

        )

    }

    bslib::card(

        class = paste("dashboard-card", class),

        if(!is.null(header))
            card_header(header),

        ...,

        if(!is.null(footer))
            card_footer(footer),

        full_screen = full_screen

    )

}

#========================================================
# Metric Card
#========================================================

ui_metric_card <- function(
    title,
    value,
    icon = NULL,
    subtitle = NULL,
    colour = "primary"
){

    div(

        class = paste(
            "metric-card",
            paste0("metric-", colour)
        ),

        div(

            class = "metric-top",

            div(

                class = "metric-left",

                div(
                    class = "metric-icon",
                    icon
                ),

                div(
                    class = "metric-title",
                    title
                )

            ),

            div(
                class = "metric-value",
                value
            )

        ),

        if(!is.null(subtitle))

            div(
                class = "metric-subtitle",
                subtitle
            )

    )

}


#========================================================
# Chart Card
#========================================================

ui_chart_card <- function(
    title,
    plot,
    subtitle = NULL,
    icon = NULL,
    footer = NULL
){

    ui_card(

        title = title,
        subtitle = subtitle,
        icon = icon,
        footer = footer,
        class = "chart-card",

        plot

    )

}

#========================================================
# Table Card
#========================================================

ui_table_card <- function(
    title,
    table,
    subtitle = NULL,
    icon = NULL,
    footer = NULL
){

    ui_card(

        title = title,
        subtitle = subtitle,
        icon = icon,
        footer = footer,
        class = "table-card",

        table

    )

}

#========================================================
# Text Card
#========================================================

ui_text_card <- function(
    title,
    ...,
    subtitle = NULL,
    icon = NULL,
    footer = NULL
){

    ui_card(

        title = title,
        subtitle = subtitle,
        icon = icon,
        footer = footer,
        class = "text-card",

        ...

    )

}

#========================================================
# Empty State Card
#========================================================

ui_empty_card <- function(
    title = "Nothing to display",
    message = "There is currently no data available.",
    icon = fa("circle-info")
){

    ui_card(

        class = "empty-card",

        div(

            class = "empty-state",

            div(
                class = "empty-icon",
                icon
            ),

            div(
                class = "empty-title",
                title
            ),

            div(
                class = "empty-message",
                message
            )

        )

    )

}