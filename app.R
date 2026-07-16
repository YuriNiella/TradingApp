library(shiny)

source("global.R")

source("R/load_modules.R")

ui <- dashboard_ui()

server <- function(input, output, session){

    dashboard_server(
        input,
        output,
        session
    )

}

shinyApp(ui, server)