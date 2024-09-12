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
all_data <- readRDS("rds/flu_data.RDS")

# ********************************
# Define input variables (replacing Shiny inputs)
epimax_day <- 40 # Max day for analysis
window_size <- 7 # Size of the modeling window
case_choice <- 'Daily Infections' # Options: 'Daily Infections', 'Daily Onsets', 'Daily Reports'

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

incidence_df <- data.frame(dates = all_data$cases$day,
                           I = as.vector(all_data$cases[, rr]))



colnames(incidence_df) <- c('dates', 'I')

# Filter based on max day
incidence_df <- incidence_df %>% filter(dates <= epimax_day)

# Remove leading and trailing zeros
head(incidence_df)
tail(incidence_df, 10)

# remove non-continusou dates
# do this manually
#incidence_df <- incidence_df[1:82, ] ## ANNE:  NOT NEEDED

head(incidence_df)
tail(incidence_df)

incidence_df$dates

## THERE IS A GAP IN DATES !!!!!!
## THAT IS WHAT IS GOING ON !!!!!
##

# Serial interval from data
si_sample <- as.matrix(all_data$serial$Px) ## ANNE:  seems more like a pmf than a sample?
if (all_data$serial$Day[1] == 1) si_sample <- c(0, si_sample)
si_sample

# Estimate R
# set up the window size
t_start <- (0 + 2):(nrow(incidence_df) - (window_size - 1))
t_end <- ((window_size - 1) + 2):nrow(incidence_df)

getR <- EpiEstim::estimate_R(incidence_df, method = 'si_from_sample', ## ANNE: this does not look correct
                             si_sample = si_sample,## ANNE: this does not look correct
                             config = make_config(list(t_start = t_start, t_end = t_end))) ## ANNE: note you can let the default config do the t_start and t_end calculation for you

## ANNE: corrected version (I think)
getR_corrected <- EpiEstim::estimate_R(incidence_df, method = 'non_parametric_si',
                             config = make_config(list(si_distr = si_sample, t_start = t_start, t_end = t_end))) ## ANNE: note you can let the default config do the t_start and t_end calculation for you

## ANNE: corrected version using daily windows
getR_corrected_daily <- EpiEstim::estimate_R(incidence_df, method = 'non_parametric_si',
                                       config = make_config(list(si_distr = si_sample,
                                                                 t_start = 2:nrow(incidence_df),
                                                                 t_end = 2:nrow(incidence_df))))

## ANNE: corrected version using daily windows and backimputation method for early curve
getR_corrected_daily_backimputedearlyI <- EpiEstim::estimate_R(incidence_df, method = 'non_parametric_si',
                                             config = make_config(list(si_distr = si_sample,
                                                                       t_start = 2:nrow(incidence_df),
                                                                       t_end = 2:nrow(incidence_df))),
                                             backimputation_window = 10)


plot_r <- data.frame(
  package = 'EpiEstim',
  date = all_data$cases$day[(2 + (window_size - 1)):(nrow(incidence_df))],
  Rt_median = getR$R$`Median(R)`,
  Rt_lb = getR$R$`Quantile.0.025(R)`,
  Rt_ub = getR$R$`Quantile.0.975(R)`
)

plot_r_corrected <- data.frame( ## ANNE
  package = 'EpiEstim',
  date = all_data$cases$day[getR_corrected$R$t_end],
  Rt_median = getR_corrected$R$`Median(R)`,
  Rt_lb = getR_corrected$R$`Quantile.0.025(R)`,
  Rt_ub = getR_corrected$R$`Quantile.0.975(R)`
)

plot_r_corrected_daily <- data.frame( ## ANNE
  package = 'EpiEstim',
  date = all_data$cases$day[getR_corrected_daily$R$t_end],
  Rt_median = getR_corrected_daily$R$`Median(R)`,
  Rt_lb = getR_corrected_daily$R$`Quantile.0.025(R)`,
  Rt_ub = getR_corrected_daily$R$`Quantile.0.975(R)`
)

plot_r_corrected_daily_backimputedearlyI <- data.frame( ## ANNE
  package = 'EpiEstim',
  date = all_data$cases$day[getR_corrected_daily_backimputedearlyI$R$t_end],
  Rt_median = getR_corrected_daily_backimputedearlyI$R$`Median(R)`,
  Rt_lb = getR_corrected_daily_backimputedearlyI$R$`Quantile.0.025(R)`,
  Rt_ub = getR_corrected_daily_backimputedearlyI$R$`Quantile.0.975(R)`
)

plot(getR, 'R')
plot(getR_corrected, 'R') ## ANNE
plot(getR_corrected_daily, 'R') ## ANNE
plot(getR_corrected_daily_backimputedearlyI, 'R') ## ANNE

# Generate the plots
p1 <- as_tibble(all_data$cases) %>%
  rename(y = case_choice) %>%
  ggplot() +
  geom_line(aes(x = day, y = y)) +
  xlab('Days') + ylab(case_choice) +
  geom_vline(xintercept = epimax_day, color = 'purple') +
  coord_cartesian(xlim = c(0, 82)) +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))

p2 <- as_tibble(plot_r) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = '11') +
  # *******
  # this is the true r(t)
  geom_line(aes(x = Day, y = Rt), data = all_data$rt) +
  # *******
  geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
  geom_line(aes(x = date, y = Rt_median, color = package)) +
  geom_vline(xintercept = epimax_day, color = 'purple') +
  coord_cartesian(xlim = c(0, 82)) +
  xlab('Days') + ylab('Rt') +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))

p2_corrected <- as_tibble(plot_r_corrected) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = '11') +
  # *******
  # this is the true r(t)
  geom_line(aes(x = Day, y = Rt), data = all_data$rt) +
  # *******
  geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
  geom_line(aes(x = date, y = Rt_median, color = package)) +
  geom_vline(xintercept = epimax_day, color = 'purple') +
  coord_cartesian(xlim = c(0, 82)) +
  xlab('Days') + ylab('Rt') +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))

p2_corrected_daily <- as_tibble(plot_r_corrected_daily) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = '11') +
  # *******
  # this is the true r(t)
  geom_line(aes(x = Day, y = Rt), data = all_data$rt) +
  # *******
  geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
  geom_line(aes(x = date, y = Rt_median, color = package)) +
  geom_vline(xintercept = epimax_day, color = 'purple') +
  coord_cartesian(xlim = c(0, 82)) +
  xlab('Days') + ylab('Rt') +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))

p2_corrected_daily_backimputedearlyI <- as_tibble(plot_r_corrected_daily_backimputedearlyI) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = '11') +
  # *******
  # this is the true r(t)
  geom_line(aes(x = Day, y = Rt), data = all_data$rt) +
  # *******
  geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package), alpha = 0.25) +
  geom_line(aes(x = date, y = Rt_median, color = package)) +
  geom_vline(xintercept = epimax_day, color = 'purple') +
  coord_cartesian(xlim = c(0, 82)) +
  xlab('Days') + ylab('Rt') +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))

library(patchwork)
p1 + p2 + plot(getR, 'R') + plot_layout(ncol = 1)
p1 + p2_corrected + plot(getR_corrected, 'R') + plot_layout(ncol = 1) ## ANNE
p1 + p2_corrected_daily + plot(getR_corrected_daily, 'R') + plot_layout(ncol = 1) ## ANNE
p1 + p2_corrected_daily_backimputedearlyI + plot(getR_corrected_daily_backimputedearlyI, 'R') + plot_layout(ncol = 1) ## ANNE


## so the things you can change are
## * window size
## * and the max date to see how it does with more data
## * the choice of options of wether its infects or cases or onset
