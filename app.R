#========================================================
# ASX Scanner v2
#
# Main Application
#========================================================

library(shiny)

#--------------------------------------------------------
# Load configuration
#--------------------------------------------------------
source("config.R")

#--------------------------------------------------------
# Load packages
#--------------------------------------------------------
source("global.R")

#--------------------------------------------------------
# Load engines and modules
#--------------------------------------------------------
source("R/load_modules.R")


#--------------------------------------------------------
# Opening message
#--------------------------------------------------------
message(

    config$app$name,

    " v",

    config$app$version

)

#--------------------------------------------------------
# Create application context
#--------------------------------------------------------
ctx <- create_app_context()

result <- validate_application(ctx)
if (!result$success) {
    stop(result$message, call. = FALSE)
}

#--------------------------------------------------------
# User Interface
#--------------------------------------------------------
ui <- fluidPage(

  dashboard_ui("dashboard")

)

#--------------------------------------------------------
# Server
#--------------------------------------------------------
server <- function(input, output, session) {

  # Close database connection when app exits
  session$onSessionEnded(function() {

      database_disconnect(app_context$con)

  })

  dashboard_server(
        id = "dashboard",
        context = ctx

    )

}

#--------------------------------------------------------
# Launch application
#--------------------------------------------------------
shinyApp(ui, server)