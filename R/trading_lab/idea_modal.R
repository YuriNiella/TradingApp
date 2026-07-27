#========================================================
# Idea Details Modal
#========================================================

comparison_row <- function(label, original, current){

    tags$tr(

        tags$th(
            style = "width:25%;",
            label
        ),

        tags$td(original),

        tags$td(current)

    )

}


show_idea_modal <- function(
    original,
    current,
    session
){

    showModal(

        modalDialog(

            title = paste0(
                original$ticker,
                " (",
                original$status,
                ")"
            ),

            size = "l",

            easyClose = TRUE,

            tags$table(

                class = "table table-bordered table-hover",

                tags$thead(

                    tags$tr(

                        tags$th("Metric"),

                        tags$th("Original"),

                        tags$th("Current")

                    )

                ),

                tags$tbody(

                    comparison_row(

                        "Date",

                        format(
                            as.POSIXct(original$created_datetime),
                            "%d %b %Y %H:%M"
                        ),

                        format(
                            current$date,
                            "%d %b %Y %H:%M"
                        )

                    ),

                    comparison_row(

                        "Setup",

                        original$current_setup,

                        current$setup

                    ),

                    comparison_row(

                        "Score",

                        round(
                            original$current_score,
                            0
                        ),

                        round(
                            current$score,
                            0
                        )

                    ),

                    comparison_row(

                        "Reason",

                        original$current_reason,

                        current$reason

                    ),

                    comparison_row(

                        "Entry",

                        sprintf(
                            "$%.2f",
                            original$planned_entry
                        ),

                        sprintf(
                            "$%.2f",
                            current$entry
                        )

                    ),

                    comparison_row(

                        "Stop",

                        sprintf(
                            "$%.2f",
                            original$planned_stop
                        ),

                        sprintf(
                            "$%.2f",
                            current$stop
                        )

                    ),

                    comparison_row(

                        "Target",

                        sprintf(
                            "$%.2f",
                            original$planned_target
                        ),

                        sprintf(
                            "$%.2f",
                            current$target
                        )

                    ),

                    comparison_row(

                        "Planner",

                        original$planner,

                        current$planner

                    )

                )

            ),

            tags$hr(),

            tags$h4("Notes"),

            tags$p(

                ifelse(
                    is.na(original$notes),
                    "",
                    original$notes
                )

            ),

            footer = tagList(

                modalButton("Close"),

                actionButton(

                    session$ns("btn_update_selected_idea"),

                    "Update Idea",

                    class = "btn-primary"

                ),

                actionButton(

                    session$ns("btn_execute_trade"),

                    "Execute Trade",

                    class = "btn-success"

                )

            )

        )

    )

}