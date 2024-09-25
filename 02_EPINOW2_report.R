library(tidyverse)
require(EpiNow2)

url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

# ********************************
case_choice <- 'daily_reports'
# Options: 'Daily Infections', 'Daily Onsets', 'Daily Reports'
# ********************************

rr <- which(colnames(all_data$cases) == case_choice)

# columsn are called `date` and `confirm`
incidence_df = data.frame(
  date = lubridate::make_date(2020, 3, 19) + 1:nrow(all_data$cases),
  confirm = as.vector(all_data$cases[, rr]))

dim(incidence_df)

colnames(incidence_df) <- c('date', 'confirm')
head(incidence_df)
tail(incidence_df)
any(is.na(incidence_df))


####
gi_pmf <- NonParametric(pmf = all_data$serial$Px)
sym_report_delay_pmf <- NonParametric(pmf = all_data$reporting_delay$Px)
incubation_pmf <- NonParametric(pmf = all_data$incubation$Px)

res_epinow <- epinow(
  data = incidence_df,
  generation_time = generation_time_opts(gi_pmf),
  delays = delay_opts(incubation_pmf + sym_report_delay_pmf),
  backcalc = backcalc_opts(prior = 'reports'),
  rt = rt_opts(rw = 1),
  stan = stan_opts(chains = 4, cores = 4)
)

incidence_df$day = all_data$cases$day

y_extract <- rstan::extract(res_epinow$estimates$fit)$R
dim(y_extract)

# y_date = res_epinow$estimates$summarised %>% filter(variable == 'R')
# head(y_date)
# View(res_epinow$samples)



plot_data <- data.frame(
  package = "EpiNow2",
  date = c(all_data$cases$day, max(all_data$cases$day) + 1:7),
  Rt_median = apply(y_extract, 2, quantile, probs = 0.5),
  Rt_lb = apply(y_extract, 2, quantile, probs = 0.025),
  Rt_ub = apply(y_extract, 2, quantile, probs = 0.975)
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

saveRDS(plot_data, "plot_objects/plot_data_EpiNow2_report.RDS")
