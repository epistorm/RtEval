library(tidyverse)

all_data <- readRDS("all_data.RDS")

# Rt = the expected value
# Rt_calc = the actual Rt that created the data
true_rt <- all_data$rt

plot_data_infections <- rbind(
  readRDS("plot_data_EpiEstim_infections.RDS"),
  readRDS("plot_data_EpiLPS_infections.RDS"),
  readRDS("plot_data_EpiNow2_infections.RDS"),
  readRDS("plot_data_R0_infections.RDS"),
  readRDS("plot_data_rtestim_infections.RDS")
)

plot_data_reports <- rbind(
  readRDS("plot_data_EpiEstim_reports.RDS"),
  readRDS("plot_data_EpiLPS_reports.RDS"),
  readRDS("plot_data_EpiNow2_reports.RDS"),
  readRDS("plot_data_rtestim_reports.RDS")
)

plot_data_infections |>
  left_join(true_rt, by = join_by(date == Day)) |>
  group_by(package) |>
  summarise(
    mse = mean((Rt_median - Rt)^2, na.rm = TRUE),
    mse_calc = mean((Rt_median - Rt_calc)^2, na.rm = TRUE)
  )
