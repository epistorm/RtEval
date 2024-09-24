
library(EpiLPS)

url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))
case_choice <- "daily_infections"


# discrete dist
si_spec <- Idist(probs = all_data$serial$Px)

# incidence
incidence = all_data$cases$daily_infections

#
LPSfit <- estimR(incidence = incidence, si = si_spec$pvec)

#
plot_data <- data.frame(
  package = "EpiLPS",
  date = all_data$cases$day,
  Rt_median = LPSfit$RLPS$Rq0.50,
  Rt_lb = LPSfit$RLPS$Rq0.025,
  Rt_ub = LPSfit$RLPS$Rq0.975
)

library(tidyverse)
as_tibble(plot_data) %>%
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

saveRDS(plot_data, "plot_objects/plot_data_EpiLPS_infections.RDS")
