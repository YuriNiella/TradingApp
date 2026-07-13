ui <- fluidPage(

    theme = bs_theme(
        bootswatch = "darkly"
    ),

    titlePanel("ASX Scanner v2"),

    br(),

    fluidRow(

        column(

            4,

            wellPanel(

                h3("Database"),

                textOutput("db_status")

            )

        )

    )

)

server <- function(input, output, session) {

    con <- database_connect()

    onStop(function(){

        dbDisconnect(con)

    })

    output$db_status <- renderText({

        if(dbIsValid(con)){

            "Connected"

        } else{

            "Disconnected"

        }

    })

}