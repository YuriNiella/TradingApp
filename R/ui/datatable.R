#========================================================
# UI DataTables
#========================================================

library(DT)

#========================================================
# Default Options
#========================================================

ui_table_options <- list(

  pageLength = 10,

  lengthChange = FALSE,

  searching = TRUE,

  ordering = TRUE,

  info = TRUE,

  autoWidth = TRUE,

  responsive = TRUE,

  scrollX = TRUE,

  stateSave = TRUE,

  dom = "tip",

  language = list(

    emptyTable = "No data available.",

    search = "",

    searchPlaceholder = "Search..."

  )

)

#========================================================
# Generic Table
#========================================================

ui_table <- function(
    data,
    selection = "single",
    options = list(),
    rownames = FALSE,
    escape = FALSE
){

    DT::datatable(

        data,

        rownames = rownames,

        escape = escape,

        selection = selection,

        class = "compact hover stripe",

        options = modifyList(
            ui_table_options,
            options
        )

    )

}

#========================================================
# Hide Columns
#========================================================

ui_hide_columns <- function(
    dt,
    columns
){

    DT::formatStyle(

        dt,

        columns,

        target = "column",

        visible = FALSE

    )

}

#========================================================
# Prices
#========================================================

ui_format_price <- function(
    dt,
    columns
){

    DT::formatRound(

        dt,

        columns,

        digits = 2

    )

}

#========================================================
# Currency
#========================================================

ui_format_currency <- function(
    dt,
    columns,
    currency = "$"
){

    DT::formatCurrency(

        dt,

        columns,

        currency = currency,

        digits = 2

    )

}

#========================================================
# Shares
#========================================================

ui_format_shares <- function(
    dt,
    columns
){

    DT::formatRound(

        dt,

        columns,

        digits = 0

    )

}

#========================================================
# Percentages
#========================================================

ui_format_percent <- function(
    dt,
    columns,
    digits = 1
){

    DT::formatPercentage(

        dt,

        columns,

        digits = digits

    )

}

#========================================================
# Dates
#========================================================

ui_format_date <- function(
    dt,
    columns,
    format = "%d-%b-%Y"
){

    DT::formatDate(

        dt,

        columns,

        method = "toLocaleDateString"

    )

}

#========================================================
# Risk Reward
#========================================================

ui_format_rr <- function(
    dt,
    columns
){

    DT::formatRound(

        dt,

        columns,

        digits = 2

    )

}

#========================================================
# Colour Positive / Negative
#========================================================

ui_colour_profit_loss <- function(
    dt,
    columns
){

    DT::formatStyle(

        dt,

        columns,

        color = DT::styleInterval(

            0,

            c(
                ui_colour("loss"),
                ui_colour("profit")
            )

        )

    )

}

#========================================================
# Colour Status
#========================================================

ui_colour_status <- function(
    dt,
    column = "status"
){

    DT::formatStyle(

        dt,

        column,

        color = DT::styleEqual(

            c(
                "Open",
                "Closed",
                "Planned"
            ),

            c(
                ui_colour("profit"),
                ui_colour("text_muted"),
                ui_colour("warning")
            )

        ),

        fontWeight = "600"

    )

}

#========================================================
# Centre Columns
#========================================================

ui_align_center <- function(
    dt,
    columns
){

    DT::formatStyle(

        dt,

        columns,

        textAlign = "center"

    )

}

#========================================================
# Right Align
#========================================================

ui_align_right <- function(
    dt,
    columns
){

    DT::formatStyle(

        dt,

        columns,

        textAlign = "right"

    )

}

#========================================================
# Left Align
#========================================================

ui_align_left <- function(
    dt,
    columns
){

    DT::formatStyle(

        dt,

        columns,

        textAlign = "left"

    )

}

#========================================================
# Bold Columns
#========================================================

ui_bold <- function(
    dt,
    columns
){

    DT::formatStyle(

        dt,

        columns,

        fontWeight = "600"

    )

}