# remotes::install_github("dajmcdon/rtestim")
library(rtestim)
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))


#rt estimation
rr <- 2:nrow(all_data$cases)

rtestim <- cv_estimate_rt(
  observed_counts = all_data$cases$daily_reports[rr],
  x = all_data$cases$day[rr],
  delay_distn = all_data$serial$Px
)

#approximate confidence bands
rtestim_cb <- onfband(rtestim, lambda = "lambda.1se")
#lambda: the selected lambda. May be a scalar value,
# or in the case of cv_poisson_rt objects, "lambda.min" or "lambda.max"

INCUBATION_SHIFT = round(weighted.mean(x = all_data$incubation$Day,
                                       w = all_data$incubation$Px))

REPORTINGDELAY_SHIFT = round(weighted.mean(x = all_data$reporting_delay$Day,
                                           w = all_data$reporting_delay$Px))

#create dataframe
plot_rtestim <- data.frame(
  package = "rtEstim",
  date = all_data$cases$day[rr] - INCUBATION_SHIFT - REPORTINGDELAY_SHIFT,
  Rt_median = rtestim_cb$fit,
  Rt_lb = rtestim_cb$`2.5%`,
  Rt_ub = rtestim_cb$`97.5%`
)

library(tidyverse)

as_tibble(plot_rtestim) %>%
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

saveRDS(plot_rtestim, file = 'plot_objects/plot_data_rtestim_reports.RDS')
