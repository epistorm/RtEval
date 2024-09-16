# Collabathon: Checking R(t)
# Author: Chad Milando, PhD (Boston University, Environmental Health)
#         Laura White, PhD (Boston University, Biostatistics)
# Date: 2024-09-24

## ANNE - to have the backimputation method available
# install.packages('EpiEstim', repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))

# Load required libraries
library(plotly)
library(purrr)
library(splines)
library(tidyverse)
library(EpiEstim)
library(patchwork)

# Load data
all_data <- readRDS("all_data.RDS")

# ********************************
# Define input variables (replacing Shiny inputs)
epimax_day <- 40 # Max day for analysis
window_size <- 7 # Size of the modeling window
case_choice <- "daily_infections" # Options: 'Daily Infections', 'Daily Onsets', 'Daily Reports'

## so the things you can change are
## * window size
## * and the max date to see how it does with more data
## * the choice of options of wether its infects or cases or onset
# ********************************

# Estimate R function
library(EpiEstim)
library(tidyverse)

# Filter case data based on selection
rr <- which(colnames(all_data$cases) == case_choice)
rr

incidence_df <- data.frame(
  dates = all_data$cases$day,
  I = as.vector(all_data$cases[, rr])
)

colnames(incidence_df) <- c("dates", "I")

# Filter based on max day
incidence_df <- incidence_df %>% filter(dates <= epimax_day)

# Serial interval from data PMF
## ANNE:  seems more like a pmf than a sample?
si_distr <- as.matrix(all_data$serial$Px)
if (all_data$serial$Day[1] == 1) si_distr <- c(0, si_distr)
si_distr

## ADD RANDOM NOISE
add_random <- T
if (add_random) {
  set.seed(123)
  #
  nn <- nrow(incidence_df)
  incidence_df$I <- incidence_df$I + round(rnorm(nn, mean = 0, sd = 50))
  #
  nw <- length(si_distr)
  pu <- runif(nw, 0.1, 1.9)
  si_distr = si_distr * pu
  si_distr = si_distr / sum(si_distr)
}

# Estimate R
# set up the window size
t_start <- (0 + 2):(nrow(incidence_df) - (window_size - 1))
t_end <- ((window_size - 1) + 2):nrow(incidence_df)

getR_corrected_daily <- EpiEstim::estimate_R(incidence_df,
  method = "non_parametric_si",
  config = make_config(list(
    si_distr = si_distr,
    t_start = 2:nrow(incidence_df),
    t_end = 2:nrow(incidence_df)
  ))
)

plot_r_corrected_daily <- data.frame( ## ANNE
  package = "EpiEstim",
  date = all_data$cases$day[getR_corrected_daily$R$t_end],
  Rt_median = getR_corrected_daily$R$`Median(R)`,
  Rt_lb = getR_corrected_daily$R$`Quantile.0.025(R)`,
  Rt_ub = getR_corrected_daily$R$`Quantile.0.975(R)`
)

p2_corrected_daily <- as_tibble(plot_r_corrected_daily) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = "11") +
  # *******
  # this is the true r(t)
  geom_line(aes(x = Day, y = Rt_calc), data = all_data$rt) +
  # *******
  geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
  geom_line(aes(x = date, y = Rt_median, color = package)) +
  # geom_vline(xintercept = epimax_day, color = 'purple') +
  coord_cartesian(ylim = c(0, 5)) +
  xlab("Days") +
  ylab("Rt") +
  theme(
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 14)
  )

p2_corrected_daily
