#========================================================
# UI Constants
#========================================================

ui_constants <- list(

  #------------------------------------------------------
  # Border Radius
  #------------------------------------------------------

  radius_sm = "6px",
  radius_md = "10px",
  radius_lg = "16px",

  #------------------------------------------------------
  # Shadows
  #------------------------------------------------------

  shadow_sm = "0 1px 3px rgba(0,0,0,0.08)",

  shadow_md = "0 4px 12px rgba(0,0,0,0.08)",

  shadow_lg = "0 8px 24px rgba(0,0,0,0.12)",

  #------------------------------------------------------
  # Padding
  #------------------------------------------------------

  padding_xs = "0.25rem",
  padding_sm = "0.50rem",
  padding_md = "1.00rem",
  padding_lg = "1.50rem",
  padding_xl = "2.00rem",

  #------------------------------------------------------
  # Margins
  #------------------------------------------------------

  margin_sm = "0.50rem",
  margin_md = "1.00rem",
  margin_lg = "1.50rem",

  #------------------------------------------------------
  # Card Sizes
  #------------------------------------------------------

  metric_height = "130px",

  chart_height = "350px",

  table_height = "500px",

  sidebar_width = "260px",

  #------------------------------------------------------
  # Typography
  #------------------------------------------------------

  title_size = "2rem",

  subtitle_size = "1.2rem",

  card_title_size = "0.95rem",

  metric_size = "2rem",

  body_size = "0.95rem",

  small_size = "0.80rem",

  #------------------------------------------------------
  # Animations
  #------------------------------------------------------

  transition = "all 0.20s ease"

)

ui_grid <- list(

  gap = "1rem",

  columns = 12,

  sidebar_width = 260,

  content_max_width = 1600

)

#========================================================
# Helper Functions
#========================================================

ui_constant <- function(name) {

  if (!name %in% names(ui_constants)) {
    stop(sprintf("Unknown constant '%s'.", name), call. = FALSE)
  }

  ui_constants[[name]]

}