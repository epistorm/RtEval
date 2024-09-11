library(tidyverse)
require(EpiNow2)

all_data <- readRDS("~/Downloads/flu_data.RDS")

# ********************************
# Define input variables (replacing Shiny inputs)
case_choice <- 'Daily Reports' # Options: 'Daily Infections', 'Daily Onsets', 'Daily Reports'

## so the things you can change are
## * the choice of options of wether its infects or cases or onset
# ********************************

rr <- which(colnames(all_data$cases) == case_choice)

# columsn are called `date` and `confirm`
incidence_df = data.frame(date = lubridate::make_date(2020, 3, 19) +
                            all_data$cases$day,
                          Day = all_data$cases$day,
                          confirm = as.vector(all_data$cases[, rr]))

colnames(incidence_df) <- c('date', 'Day', 'confirm')

####
gi_pmf <- NonParametric(pmf = all_data$generation$Px)

delay_pmf <- NonParametric(pmf = all_data$reporting_delay$Px)

# Actuall takes several minutes
# res_epinow <- epinow(
#   incidence_df,
#   generation_time = generation_time_opts(gi_pmf),
#   delays = delay_opts(delay_pmf),
#   stan = stan_opts(control = list(adapt_delta = 0.9),
#                    chains = 4, cores = 4)
# )
# saveRDS(res_epinow, 'epinow_flu.RDS')
res_epinow <- readRDS("epinow_flu.RDS")

y1 <- as_tibble(res_epinow$estimates$summarised %>%
                  filter(variable == 'R'))

y1

y2 <- as_tibble(res_epinow$estimates$summarised %>%
                  filter(variable == 'reported_cases'))
y2

# Generate the plots
p1 <- incidence_df %>%
  ggplot() +
  geom_line(aes(x = date, y = confirm)) +
  geom_line(data = y2, aes(x = date, y = median), color = 'red') +
  xlab('Days') + ylab(case_choice) +
  #geom_vline(xintercept = epimax_day, color = 'purple') +
  #coord_cartesian(xlim = c(0, 82)) +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))
p1

incidence_df <- incidence_df %>% left_join(all_data$rt)
incidence_df <- incidence_df %>% left_join(y1[, c('date', 'median', 'lower_90', 'upper_90')])
head(incidence_df)

epi2 <- incidence_df

p2 <- as_tibble(incidence_df) %>%
  ggplot() +
  geom_hline(yintercept = 1, linetype = '11') +
  # *******
  # this is the true r(t)
  geom_line(aes(x = Day, y = Rt)) +
  # *******
  geom_ribbon(aes(x = Day,
                  ymin = lower_90,
                  ymax = upper_90),
              fill = 'red', alpha = 0.25) +
  geom_line(aes(x = Day, y = median), color = 'red') +
  xlab('Days') + ylab('Rt') +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 14))
p2
ep2 <- p2

library(patchwork)
p1 + p2 + plot_layout(ncol = 1)
