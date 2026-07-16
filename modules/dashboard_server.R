dashboard_server <- function(
    input,
    output,
    session
){

    con <- connect_database()

    onSessionEnded(function(){

        DBI::dbDisconnect(con)

    })

    scan <- eventReactive(

        input$scan,

        {

            scan_market(

                con,

                min_score = input$min_score,

                triggered_only = input$triggered,

                setups = input$setup

            )

        }

    )

    output$scan_table <- DT::renderDT({

        req(scan())

        scan()$data$scan

    })

}