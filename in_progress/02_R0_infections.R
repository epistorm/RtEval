## ----
## STATUS: UNCLEAR, THIS DOES NOT SEEM TO BE LINING UP
## ----

library(lubridate)
library(R0)

#load the data
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

#change to required incidence format
day_vector <- lubridate::make_date(2020, 3, 19) + all_data$cases$day
incid_vector <- all_data$cases$daily_infections
plot(incid_vector, type = 'l')

#create a named vector for the matrix
incid_new_format <- setNames(incid_vector, day_vector)
incid_new_format
plot(incid_new_format, type = 'l')

# get the day 0 cases
n.t0 = incid_new_format[1]
n.t0

# remove that from the vector
incid_new_format <- incid_new_format[2:length(incid_new_format)]
plot(incid_new_format)


# set the GT interval
## NOTE: Does this need a leading 0? unclear what the convention is
mGT <- generation.time("empirical",
                       val = c(all_data$serial$Px),
                       step = 1,
                       p0 = F)
mGT
all_data$serial$Px
## ok that seems to be the same

#R estimation
# if you don't set end = 60, it only does the first 18 days
TD <- est.R0.TD(epid = incid_new_format,
                GT = mGT,
                #begin = 1,
                end = length(incid_new_format),
                n.t0 = as.numeric(n.t0))
TD$R
length(TD$R)
nrow(TD$conf.int)

#turn R0 into dataframe, replacing date with sequence
## ****
## NOTE: THERE STILL SEEMS TO BE A 3 DAY OFFSET HERE FOR SOME REASON?
DAY_SHIFT = 0
plot_data <- data.frame(
  package = "R0",
  date = 1:60 + DAY_SHIFT, # ADDING AN OFFSET??
  Rt_median = TD$R,
  Rt_lb = TD$conf.int$lower,
  Rt_ub = TD$conf.int$upper
)
# ****

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
  ylab("R(t)") +
  theme(
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 14)
  )

saveRDS(plot_data, "plot_data_R0_infections.RDS")
