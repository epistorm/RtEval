remotes::install_github("dajmcdon/rtestim")
library(rtestim)
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))
case_choice <- "daily_infections"

#rt estimation
rtestim <- estimate_rt(
  observed_counts = all_data$cases$daily_infections,
  x = all_data$cases$day,
  delay_distn = all_data$serial$Px
)

#approximate confidence bands
rtestim_cb <- confband(rtestim, lambda = rtestim$lambda[37])
#lambda: the selected lambda. May be a scalar value,
# or in the case of cv_poisson_rt objects, "lambda.min" or "lambda.max"

#create dataframe
plot_rtestim <- data.frame(
  package = "rtEstim",
  date = all_data$cases$day,
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

saveRDS(plot_rtestim, file = 'plot_data_rtestim_infections.RDS')
