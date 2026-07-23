#========================================================
# Trading Lab UI
#========================================================

trading_lab_ui <- function(id){

  ns <- NS(id)

  tagList(

    #----------------------------------------------------
    # Trading Lab title
    #----------------------------------------------------

    h2("Trading Lab"),

    br(),

    #----------------------------------------------------
    # KPI Cards
    #----------------------------------------------------

    layout_columns(

        ui_metric_card(

            title = "Ideas",

            value = textOutput(ns("n_ideas")),

            icon = ui_icon("ideas"),

            subtitle = "Scanner ideas",

            colour = "primary"

        ),

        ui_metric_card(

            title = "Planned",

            value = textOutput(ns("n_planned")),

            icon = ui_icon("planned"),

            subtitle = "Ready to trade",

            colour = "warning"

        ),

        ui_metric_card(

            title = "Open",

            value = textOutput(ns("n_open")),

            icon = ui_icon("open"),

            subtitle = "Active positions",

            colour = "profit"

        ),

        ui_metric_card(

            title = "Closed",

            value = textOutput(ns("n_closed")),

            icon = ui_icon("closed"),

            subtitle = "Completed trades",

            colour = "secondary"

        )

    ),

    br(),

    #----------------------------------------------------
    # Tabs
    #----------------------------------------------------

    navset_card_tab(

      id = ns("tabs"),

      #==================================================
      # Dashboard
      #==================================================

      nav_panel(

        "Dashboard",

        #------------------------------------------------
        # Today's Workflow
        #------------------------------------------------

        h4("Today's Workflow"),

        layout_columns(

          col_widths = c(6, 6),

          ui_card(

            title = "Database",

            icon = ui_icon("database"),

            tags$div(

              class = "status-list",

              tags$p(
                tags$strong("Status"),
                textOutput(ns("db_status"), inline = TRUE)
              ),

              tags$p(
                tags$strong("Market Date"),
                textOutput(ns("db_latest_market_date"), inline = TRUE)
              ),

              tags$p(
                tags$strong("Database Date"),
                textOutput(ns("db_latest_database_date"), inline = TRUE)
              ),

              tags$p(
                tags$strong("Last Update"),
                textOutput(ns("db_last_update"), inline = TRUE)
              ),

              tags$p(
                tags$strong("Tickers"),
                textOutput(ns("db_nstocks"), inline = TRUE)
              ),

              actionButton(
                  ns("btn_update_database"),
                  "Update Prices",
                  icon = ui_icon("database"),
                  class = "btn-primary"
              )

            )

          ),

          ui_card(

            title = "Scanner",

            icon = ui_icon("scanner"),

            tags$div(

              class = "status-list",

              actionButton(
                  ns("btn_run_scanner"),
                  "Run Scanner",
                  icon = ui_icon("scanner"),
                  class = "btn-success"
              )

            )

          )

        ),

        br(),

        #------------------------------------------------
        # Today's Opportunities
        #------------------------------------------------

        card(

          full_screen = TRUE,

          card_header("Today's Opportunities"),

          layout_columns(

              col_widths = c(3,3,3,3),

              actionButton(
                  ns("btn_create_idea"),
                  "Create Idea",
                  icon = ui_icon("ideas"),
                  class = "btn-primary"
              ),

              actionButton(
                  ns("btn_add_watchlist"),
                  "Add Watchlist",
                  icon = ui_icon("watchlist"),
                  class = "btn-secondary"
              ),

              actionButton(
                  ns("btn_view_chart"),
                  "View Chart",
                  icon = ui_icon("chart"),
                  class = "btn-info"
              ),

              div(
                  style="text-align:right;padding-top:8px;",
                  textOutput(ns("scanner_summary"))
              )

          ),

          br(),

          DTOutput(ns("todays_setups"))

      ),

        br(),

        #------------------------------------------------
        # Open Positions
        #------------------------------------------------

        card(

          full_screen = TRUE,

          card_header("Open Positions"),

          DTOutput(ns("open_trades"))

        )

      ),

      #==================================================
      # Ideas
      #==================================================

      nav_panel(

        "Ideas",

        card(

          full_screen = TRUE,

          card_header("Ideas"),

          DTOutput(ns("ideas_table"))

        )

      ),

      #==================================================
      # Journal
      #==================================================

      nav_panel(

        "Journal",

        card(

          full_screen = TRUE,

          card_header("Trading Journal"),

          DTOutput(ns("journal_table"))

        )

      ),

      #==================================================
      # Statistics
      #==================================================

      nav_panel(

        "Statistics",

        layout_columns(

          card(

            card_header("Win Rate"),

            h2(textOutput(ns("win_rate")))

          ),

          card(

            card_header("Total Profit"),

            h2(textOutput(ns("total_profit")))

          ),

          card(

            card_header("Average R"),

            h2(textOutput(ns("average_r")))

          )

        ),

        br(),

        card(

          card_header("Performance"),

          p("Charts coming soon.")

        )

      )

    )

  )

}