
# Load required libraries
library(tidyverse)
# install.packages('EpiEstim', repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))
library(EpiEstim)


# Load data
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

case_choice <- "daily_infections"
# the choices here are daily_infections, daily_onsets, and_daily_reports


# Filter case data based on selection
rr <- which(colnames(all_data$cases) == case_choice)

incidence_df <- data.frame(
  dates = all_data$cases$day,
  I = as.vector(all_data$cases[, rr])
)
colnames(incidence_df) <- c('dates', 'I')

head(incidence_df)
tail(incidence_df)
dim(incidence_df)

# Serial interval from data PMF
si_distr <- as.matrix(all_data$serial$Px)
if (all_data$serial$Day[1] == 1) si_distr <- c(0, si_distr)
si_distr

# Estimate R DAILY
getR <- EpiEstim::estimate_R(
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
plot_data <- data.frame( ## ANNE
  package = "EpiEstim",
  date = all_data$cases$day[getR$R$t_end],
  Rt_median = getR$R$`Median(R)`,
  Rt_lb = getR$R$`Quantile.0.025(R)`,
  Rt_ub = getR$R$`Quantile.0.975(R)`
)

as_tibble(plot_data) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = "11") +
  # *******
  # this is the true r(t), back-calculated
  geom_line(aes(x = Day, y = Rt_calc), data = all_data$rt) +
  # *******
  geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub, fill = package),
              alpha = 0.25) +
  geom_line(aes(x = date, y = Rt_median, color = package)) +
  coord_cartesian(ylim = c(0, 5)) +
  xlab("Days") +
  ylab("Rt") +
  theme(
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 14)
  )

saveRDS(plot_data, "plot_data_EpiEstim.RDS")

