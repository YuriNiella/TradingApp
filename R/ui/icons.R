#========================================================
# UI Icons
#========================================================

library(fontawesome)

#========================================================
# Icon Registry
#========================================================

ui_icons <- list(

  #------------------------------------------------------
  # Navigation
  #------------------------------------------------------

  dashboard = fa("gauge-high"),

  scanner = fa("magnifying-glass-chart"),

  ideas = fa("lightbulb"),

  journal = fa("book-open"),

  statistics = fa("chart-column"),

  database = fa("database"),

  settings = fa("gear"),

  profile = fa("user"),

  #------------------------------------------------------
  # Trading
  #------------------------------------------------------

  watchlist = bsicons::bs_icon("bookmark-star"),

  planned = fa("clipboard-check"),

  watching = fa("binoculars"),

  open = fa("arrow-trend-up"),

  closed = fa("circle-check"),

  buy = fa("cart-shopping"),

  sell = fa("money-bill-trend-up"),

  trade = fa("chart-line"),

  portfolio = fa("briefcase"),

  risk = fa("triangle-exclamation"),

  reward = fa("trophy"),

  profit = fa("arrow-up"),

  loss = fa("arrow-down"),

  stop = fa("hand"),

  target = fa("bullseye"),

  #------------------------------------------------------
  # Market
  #------------------------------------------------------

  bull = fa("arrow-up-right-dots"),

  bear = fa("arrow-down-wide-short"),

  neutral = fa("minus"),

  volatility = fa("wave-square"),

  trend = fa("chart-line"),

  volume = fa("chart-simple"),

  calendar = fa("calendar"),

  clock = fa("clock"),

  #------------------------------------------------------
  # Actions
  #------------------------------------------------------

  add = fa("plus"),

  edit = fa("pen"),

  delete = fa("trash"),

  refresh = fa("rotate"),

  save = fa("floppy-disk"),

  download = fa("download"),

  upload = fa("upload"),

  search = fa("magnifying-glass"),

  filter = fa("filter"),

  sort = fa("arrow-down-wide-short"),

  clear = fa("eraser"),

  copy = fa("copy"),

  export = fa("file-export"),

  import = fa("file-import"),

  #------------------------------------------------------
  # Status
  #------------------------------------------------------

  success = fa("circle-check"),

  warning = fa("triangle-exclamation"),

  error = fa("circle-xmark"),

  info = fa("circle-info"),

  loading = fa("spinner"),

  #------------------------------------------------------
  # Misc
  #------------------------------------------------------

  home = fa("house"),

  star = fa("star"),

  heart = fa("heart"),

  bell = fa("bell"),

  eye = fa("eye"),

  hide = fa("eye-slash"),

  folder = fa("folder"),

  file = fa("file"),

  chart = fa("chart-area")

)

#========================================================
# Helper
#========================================================

ui_icon <- function(name){

  if (!name %in% names(ui_icons)) {

    stop(
      sprintf("Unknown icon '%s'.", name),
      call. = FALSE
    )

  }

  ui_icons[[name]]

}