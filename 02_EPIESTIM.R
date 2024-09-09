# Collabathon: Checking R(t)
# Author: Chad Milando, PhD (Boston University, Environmental Health)
#         Laura White, PhD (Boston University, Biostatistics)
# Date: 2024-09-24

# Load required libraries
library(plotly)
library(purrr)
library(splines)
library(tidyverse)
library(EpiEstim)
library(patchwork)

# Load data
all_data <- readRDS("~/Downloads/all_data.RDS")

# Define input variables (replacing Shiny inputs)
epimax_day <- 64 # Max day for analysis
window_size <- 7 # Size of the modeling window
case_choice <- 'Daily Infections' # Options: 'Daily Infections', 'Daily Onsets', 'Daily Reports'

# Estimate R function
epiestim_dat <- function(epimax_day, window_size, case_choice) {
  # Filter case data based on selection
  rr <- which(colnames(all_data$cases) == case_choice)

  incidence_df <- data.frame(dates = all_data$cases$day, I = as.vector(all_data$cases[, rr]))
  colnames(incidence_df) <- c('dates', 'I')

  # Filter based on max day
  incidence_df <- incidence_df %>% filter(dates <= epimax_day)

  # Remove leading and trailing zeros
  incidence_df <- incidence_df %>% filter(I != 0)

  # Serial interval from data
  si_sample <- as.matrix(all_data$serial$Px)
  if (all_data$serial$Day[1] == 1) si_sample <- c(0, si_sample)

  # Estimate R
  t_start <- (0 + 2):(nrow(incidence_df) - (window_size - 1))
  t_end <- ((window_size - 1) + 2):nrow(incidence_df)

  getR <- EpiEstim::estimate_R(incidence_df, method = 'si_from_sample',
                               si_sample = si_sample,
                               config = make_config(list(t_start = t_start, t_end = t_end)))

  data.frame(
    package = 'EpiEstim',
    date = all_data$cases$day[(2):(nrow(incidence_df) - (window_size - 1))],
    Rt_median = getR$R$`Median(R)`,
    Rt_lb = getR$R$`Quantile.0.025(R)`,
    Rt_ub = getR$R$`Quantile.0.975(R)`
  )
}

# Generate the plots
pp <- function(epimax_day, case_choice) {

  p1 <- as_tibble(all_data$cases) %>%
    rename(y = case_choice) %>%
    ggplot() +
    geom_line(aes(x = day, y = y)) +
    xlab('Days') + ylab(case_choice) +
    coord_cartesian(xlim = c(0, epimax_day)) +
    theme(axis.text = element_text(size = 10),
          axis.title = element_text(size = 14))

  p2 <- as_tibble(epiestim_dat(epimax_day, window_size, case_choice)) %>%
    ggplot() +
    geom_hline(yintercept = 1, linetype = '11') +
    geom_line(aes(x = Day, y = Rt), data = all_data$rt) +
    geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
    geom_line(aes(x = date, y = Rt_median, color = package)) +
    coord_cartesian(xlim = c(0, epimax_day)) +
    xlab('Days') + ylab('Rt') +
    theme(axis.text = element_text(size = 10),
          axis.title = element_text(size = 14))

  p1 + p2 + plot_layout(ncol = 1)
}

# Render the plot
plot <- pp(epimax_day, case_choice)

# Display the plot
print(plot)

