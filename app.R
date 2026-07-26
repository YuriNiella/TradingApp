#========================================================
# ASX Trade Scanner
#========================================================
# setwd("/Users/yuriniella/Documents/GitHub/TradingApp")

library(shiny)
library(bslib)

#--------------------------------------------------------
# Load application
#--------------------------------------------------------

source("global.R")
source("config.R")
source("R/load_modules.R")
source("modules/dashboard/ui.R")
source("modules/dashboard/server.R")

con_lab <- connect_trading_lab()
con_scanner <- database_connect(
    config$paths$database
)
create_watchlist_table(con_lab)

#========================================================
# User Interface
#========================================================

ui <- page_navbar(

  title = "ASX Trade Scanner",

  theme = ui_theme,

  tags$head(

    tags$style(ui_css)

  ),

  #------------------------------------------------------
  # Trading Lab
  #------------------------------------------------------

  nav_panel(

    title = "Trading Lab",

    trading_lab_ui("trading_lab")

  )

  #------------------------------------------------------
  # Future Modules
  #------------------------------------------------------
  #
  # nav_panel(
  #   "Scanner",
  #   scanner_ui("scanner")
  # ),
  #
  # nav_panel(
  #   "Database",
  #   database_ui("database")
  # ),
  #
  # nav_panel(
  #   "Settings",
  #   settings_ui("settings")
  # )

)

#========================================================
# Server
#========================================================

server <- function(input, output, session) {

  trading_lab_server(

    id = "trading_lab",

    con_lab = con_lab

  )

}

#========================================================
# Run Application
#========================================================

shinyApp(ui, server)