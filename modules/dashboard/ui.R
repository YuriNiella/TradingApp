dashboard_ui <- function(id){

    ns <- NS(id)

    fluidPage(

        titlePanel("ASX Scanner v2"),

        br(),

        fluidRow(

            status_card(

                "Database",

                uiOutput(
                    ns("db_status")
                )

            ),

            status_card(

                "Market",

                textOutput(
                    ns("market_status")
                )

            ),

            status_card(

                "Universe",

                textOutput(
                    ns("universe_status")
                )

            ),

            status_card(

                "Scanner",

                textOutput(
                    ns("scanner_status")
                )

            )

        ),

        br(),

        fluidRow(

            column(

                width = 3,

                actionButton(

                    ns("update_db"),

                    "Update Database",

                    width = "100%"

                )

            ),

            column(

                width = 3,

                actionButton(

                    ns("run_scan"),

                    "Run Scanner",

                    width = "100%"

                )

            )

        )

    )

}