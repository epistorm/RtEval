# Collabathon: Checking R(t)

# Load required libraries
library(tidyverse)
library(EpiEstim)

# install.packages('EpiEstim', repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))
library(EpiEstim)

## ANNE - to have the backimputation method available
# install.packages('EpiEstim', repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))

# ------------
# Load data
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

# ********************************
case_choice <- "daily_onsets"
# the choices here are daily_infections, daily_onsets, and_daily_reports
# see all_data$cases
# ********************************

get_Rt <- function(case_choice) {
  # Filter case data based on selection
  rr <- which(colnames(all_data$cases) == case_choice)

  incidence_df <- data.frame(
    dates = all_data$cases$day,
    I = as.vector(all_data$cases[, rr])
  )

  colnames(incidence_df) <- c("dates", "I")

  # Serial interval from data PMF
  si_distr <- as.matrix(all_data$serial$Px)
  if (all_data$serial$Day[1] == 1) si_distr <- c(0, si_distr)
  si_distr

  ## *********
  ## ADD RANDOM NOISE
  # add_random <- F
  # if (add_random) {
  #   set.seed(123)
  #   #
  #   nn <- nrow(incidence_df)
  #   incidence_df$I <- incidence_df$I + round(rnorm(nn, mean = 0, sd = 50))
  #   #
  #   nw <- length(si_distr)
  #   pu <- runif(nw, 0.1, 1.9)
  #   si_distr = si_distr * pu
  #   si_distr = si_distr / sum(si_distr)
  # }
  ## *********

  # Estimate R DAILY
  getR_corrected_daily_backimputedearlyI <- EpiEstim::estimate_R(
    incid = incidence_df,
    method = "non_parametric_si",
    config = make_config(list(
      si_distr = si_distr,
      t_start = 2:nrow(incidence_df),
      t_end = 2:nrow(incidence_df)
    )),
    backimputation_window = 10
  )

  # PLOT DATA
  plot_r_corrected_daily_backimputedearlyI <- data.frame( ## ANNE
    package = "EpiEstim",
    date = all_data$cases$day[getR_corrected_daily_backimputedearlyI$R$t_end],
    Rt_median = getR_corrected_daily_backimputedearlyI$R$`Median(R)`,
    Rt_lb = getR_corrected_daily_backimputedearlyI$R$`Quantile.0.025(R)`,
    Rt_ub = getR_corrected_daily_backimputedearlyI$R$`Quantile.0.975(R)`
  )

  plot_r_corrected_daily_backimputedearlyI <-
    as_tibble(plot_r_corrected_daily_backimputedearlyI) %>%
    ggplot() +
    geom_hline(yintercept = 1, linetype = "11") +
    # *******
    # this is the true r(t), back-calculated
    geom_line(aes(x = Day, y = Rt_calc), data = all_data$rt) +
    # *******
    geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
    geom_line(aes(x = date, y = Rt_median, color = package)) +
    coord_cartesian(ylim = c(0, 5)) +
    xlab("Days") +
    ylab("Rt") +
    theme(
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 14)
    )

  return(plot_r_corrected_daily_backimputedearlyI)
}

p2_corrected_daily_inf <- get_Rt("daily_infections")
p2_corrected_daily_ons <- get_Rt("daily_onsets")

library(patchwork)
p2_corrected_daily_inf + ggtitle("Infections") +
  p2_corrected_daily_ons + ggtitle("Onsets") +
  plot_layout(ncol = 1)
