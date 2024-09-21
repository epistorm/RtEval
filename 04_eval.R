
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

true_rt = all_data$rt
# Rt = the expected value
# Rt_calc = the actual Rt that created the data

##

plot_data <- rbind(
  readRDS("plot_data_EpiEstim_infections.RDS"),
  readRDS("plot_data_EpiLPS_infections.RDS"),
  readRDS("plot_data_EpiNow2_infections.RDS"),
  readRDS("plot_data_R0_infections.RDS"),
  readRDS("plot_data_rtestim_infections.RDS")
)

##

plot_data <- rbind(
  readRDS("plot_data_EpiEstim_reports.RDS"),
  readRDS("plot_data_EpiLPS_reports.RDS"),
  readRDS("plot_data_EpiNow2_reports.RDS"),
  readRDS("plot_data_rtestim_reports.RDS")
)

summary(plot_data)
