#========================================================
# Application Theme
#========================================================

library(bslib)

ui_theme <- bs_theme(

  version = 5,

  bootswatch = NULL,

  #------------------------------------------------------
  # Brand colours
  #------------------------------------------------------

  primary   = ui_colour("primary"),
  secondary = ui_colour("secondary"),

  success = ui_colour("profit"),
  warning = ui_colour("warning"),
  danger  = ui_colour("loss"),
  info    = ui_colour("info"),

  bg = ui_colour("background"),
  fg = ui_colour("text"),

  #------------------------------------------------------
  # Typography
  #------------------------------------------------------

  base_font = font_google("Inter"),

  heading_font = font_google("Inter"),

  code_font = font_google("JetBrains Mono")

)