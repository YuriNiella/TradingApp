dashboard_server <- function(id, context){
    
    ctx <- context
    con <- ctx$con
    config <- ctx$config

    moduleServer(

        id,

        function(input, output, session){

            status <- reactiveVal(
                database_status(con)
            )

            output$db_status <- renderUI({

                s <- status()

                if(!s$success){

                    return(

                        tags$div(

                            tags$h4("🔴 Database unavailable")

                        )

                    )

                }

                d <- s$data

                tagList(

                    tags$b("Status:"),

                    if(d$current){

                        tags$span(
                            style="color:green;",
                            " Current"
                        )

                    }else{

                        tags$span(
                            style="color:red;",
                            " Update Required"
                        )

                    },

                    tags$hr(),

                    tags$b("Database"),

                    br(),

                    d$database,

                    br(), br(),

                    tags$b("Latest Database"),

                    br(),

                    as.character(d$latest_database_date),

                    br(), br(),

                    tags$b("Latest Market"),

                    br(),

                    as.character(d$latest_market_date),

                    br(), br(),

                    tags$b("Rows"),

                    br(),

                    format(d$rows, big.mark=","),

                    br(), br(),

                    tags$b("Tickers"),

                    br(),

                    d$tickers,

                    br(), br(),

                    tags$b("Last Update"),

                    br(),

                    as.character(d$last_update)

                )

            })

            output$market_status <- renderText({

                "Waiting..."

            })

            output$universe_status <- renderText({

                "Waiting..."

            })

            output$scanner_status <- renderText({

                "Ready"

            })

            observeEvent(

                input$update_db,

                {

                    withProgress(

                        message = "Updating database",

                        value = 0,

                        {

                            callback <- function(current, total, ticker){

                                incProgress(

                                    1 / total,

                                    detail = ticker

                                )

                            }

                            tickers <- get_universe()

                            result <- update_database(

                                con,

                                tickers = tickers,

                                progress_callback = callback

                            )

                        }

                    )

                    status(
                        database_status(con)
                    )

                    showNotification(

                        result$message,

                        type = if(result$success) "message" else "error"

                    )

                }

            )

            observeEvent(input$run_scan,{

                showNotification(

                    "Scanner not implemented yet.",

                    type="message"

                )

            })

        }

    )

}