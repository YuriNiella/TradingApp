#========================================================
# Trading Lab Server
#========================================================

trading_lab_server <- function(id, con_lab){

  moduleServer(id, function(input, output, session){

    #----------------------------------------------------
    # KPI Cards
    #----------------------------------------------------

    output$n_ideas <- renderText({

      count_ideas(con_lab)

    })

    output$n_planned <- renderText({

      count_planned_trades(con_lab)

    })

    output$n_open <- renderText({

      count_open_trades(con_lab)

    })

    output$n_closed <- renderText({

      count_closed_trades(con_lab)

    })

    #----------------------------------------------------
    # Database Status
    #----------------------------------------------------

    db_status <- reactiveVal({

      get_database_status(con_scanner)

    })

    output$db_status <- renderText({
      db_status()$status
    })

    output$db_latest_market_date <- renderText({
      format(db_status()$latest_market_date, "%d %b %Y")
    })

    output$db_latest_database_date <- renderText({
      format(db_status()$latest_database_date, "%d %b %Y")
    })

    output$db_last_update <- renderText({
      format(db_status()$last_update, "%d %b %Y %H:%M")
    })

    output$db_nstocks <- renderText({
      format(db_status()$tickers, big.mark = ",")
    })

    # Update database
    observeEvent(input$btn_update_database, {

      withProgress(

          message = "Updating market data...",

          value = 0,

          {

              result <- update_database(

                  con = con_scanner,

                  progress_callback = function(current, total, ticker){

                      incProgress(

                          1 / 1836

                      )

                  }

              )
              
              summary <- result$data$summary

          }

      )

      # db_refresh(db_refresh() + 1)

      showModal(
        modalDialog(
            title = "Database Update Complete",

            tags$table(
                class = "table table-sm",

                tags$tr(
                    tags$th("Processed"),
                    tags$td(format(summary$processed, big.mark = ","))
                ),

                tags$tr(
                    tags$th("Updated"),
                    tags$td(format(summary$updated, big.mark = ","))
                ),

                tags$tr(
                    tags$th("Unchanged"),
                    tags$td(format(summary$unchanged, big.mark = ","))
                ),

                tags$tr(
                    tags$th("Failed"),
                    tags$td(format(summary$failed, big.mark = ","))
                ),

                tags$tr(
                    tags$th("Rows Added"),
                    tags$td(format(summary$rows_added, big.mark = ","))
                ),

                tags$tr(
                    tags$th("Duration"),
                    tags$td(sprintf("%.1f s", summary$duration_seconds))
                )

            ),

            easyClose = TRUE,

            footer = modalButton("Close")
        )
    )

  })

  #----------------------------------------------------
  # Scanner
  #----------------------------------------------------

  scan_results <- reactiveVal(NULL)
  scan_summary <- reactiveVal(NULL)

  observeEvent(input$btn_run_scanner, {

    withProgress(

        message = "Scanning market...",

        value = 0,

        {

            result <- scan_market(

                con = con_scanner,

                progress_callback = function(current, total, batch){

                    incProgress(

                        1 / total

                    )

                }

            )

        }

    )

    scan_results(result$data$scan)
    scan_summary(result$data$summary)

    scan_summary <- result$data$summary


      showModal(

          modalDialog(

              title = "Scanner Complete",

              tags$table(

                  class = "table table-sm",

                  tags$tr(
                      tags$th("Tickers Scanned"),
                      tags$td(scan_summary$scanned)
                  ),

                  tags$tr(
                      tags$th("Triggered"),
                      tags$td(scan_summary$triggered)
                  ),

                  tags$tr(
                      tags$th("Highest Score"),
                      tags$td(scan_summary$max_setup_score)
                  ),

                  tags$tr(
                      tags$th("Duration"),
                      tags$td(sprintf("%.1f s",
                          scan_summary$duration_seconds))
                  )

              ),

              easyClose = TRUE,

              footer = modalButton("Close")

          )

      )

  })

  output$todays_setups <- renderDT({

      req(scan_results())

      ui_table(

          scan_results(),

          selection = "single",

          options = list(

              pageLength = 15

          )

      )

  }) 

  output$scanner_summary <- renderText({

      req(scan_summary())

      sprintf(
          "Scanned: %d • Setups: %d",
          scan_summary()$scanned,
          scan_summary()$triggered
      )

  })

    selected_setup <- reactive({

      req(input$todays_setups_rows_selected)

      scan_results() |>

          slice(

              input$todays_setups_rows_selected

          )

  })

  # Action buttons
  observeEvent(

    input$btn_create_idea,

    {

        req(selected_setup())

        print(selected_setup())

    }

)

  observeEvent(

    input$btn_add_watchlist,

    {

        req(selected_setup())

        print("Watchlist")

    }

)

  observeEvent(

    input$btn_view_chart,

    {

        req(selected_setup())

        print(selected_setup()$ticker)

    }

)

    #----------------------------------------------------
    # Dashboard
    #----------------------------------------------------

    output$open_trades <- DT::renderDT({

        df <- get_open_trades(con_lab)

        ui_table(df) |>

            ui_format_price(c(
                "planned_entry",
                "planned_stop",
                "planned_target",
                "actual_entry",
                "actual_stop"
            )) |>

            ui_format_shares("actual_shares") |>

            ui_colour_status("status")

    })


    #----------------------------------------------------
    # Ideas
    #----------------------------------------------------

    output$ideas_table <- renderDT({

        df <- get_ideas(con_lab)

        ui_table(df)

    })


    #----------------------------------------------------
    # Journal
    #----------------------------------------------------

    output$journal_table <- renderDT({

      get_trades(con_lab) |>

        dplyr::select(

          trade_id,

          status,

          scanner_setup,

          planned_entry,

          planned_stop,

          planned_target,

          actual_entry,

          actual_exit,

          profit,

          R_multiple

        )

    },
    rownames = FALSE,
    options = list(

      pageLength = 15,
      scrollX = TRUE

    ))


    #----------------------------------------------------
    # Statistics (placeholder)
    #----------------------------------------------------

    output$win_rate <- renderText({

      "Coming Soon"

    })

    output$total_profit <- renderText({

      "Coming Soon"

    })

    output$average_r <- renderText({

      "Coming Soon"

    })

  })

}