#========================================================
# App Test
#========================================================

# Setting up testing
R
setwd("/Users/yuriniella/Documents/GitHub/TradingApp")
quit()
n

shiny::runApp()


# Testing starts
source("config.R")
source("global.R")
source("R/load_modules.R")

con <- database_connect(
    config$paths$database
)

prices <- load_prices(con, "BHP")

prices <- calculate_indicators(prices)

prices <- calculate_market_structure(prices)

names(prices)

library(ggplot2)

ggplot(prices, aes(date, close)) +

  geom_line(colour = "grey70", linewidth = 0.6) +

  geom_point(
    aes(colour = market_structure),
    size = 2
  ) +

  scale_colour_manual(
    values = c(
      "Uptrend" = "forestgreen",
      "Downtrend" = "firebrick",
      "Range" = "orange",
      "Unknown" = "grey60"
    )
  ) +

  geom_text(
    data = subset(prices, swing_high),
    aes(label = "H"),
    colour = "red",
    nudge_y = 0.5
) +

geom_text(
    data = subset(prices, swing_low),
    aes(label = "L"),
    colour = "blue",
    nudge_y = -0.5
) +

  theme_bw()


