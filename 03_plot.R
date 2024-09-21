
library(ggpubr)
library(lemon)
library(tidyverse)
library(ggtext)

url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

this_plot <- function(pd, title) {
  as_tibble(pd) %>%
    ggplot() + theme_classic2() +
    geom_hline(yintercept = 1, color = 'grey') +
    geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub,
                    fill = package), alpha = 0.25,show.legend = F) +
    geom_line(aes(x = date, y =
                    Rt_median, color = package), linewidth = 0.75,
              show.legend = F) +
    coord_cartesian(ylim = c(0, 2.5)) +
    xlab("Days") +
    ylab(expression(R(t))) +
    # *******
    # this is the true r(t), back-calculated
    geom_line(aes(x = Day, y = Rt_calc), data = all_data$rt,
              linewidth= 0.5,
              linetype = '11') +
    facet_rep_wrap(~package, repeat.tick.labels = 'y', nrow = 3) +
    # *******
    theme(
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 14),
      strip.background = element_blank(),
      strip.text = element_text(face = 'bold'),
      plot.title = element_markdown()
    ) + ggtitle(title)
}

plot_data <- rbind(
  readRDS("plot_data_EpiEstim_reports.RDS"),
  readRDS("plot_data_EpiLPS_reports.RDS"),
  readRDS("plot_data_EpiNow2_reports.RDS"),
  readRDS("plot_data_rtestim_reports.RDS")
)

p1 <- this_plot(plot_data, "Instanteous R(t) of infections from **reported case data**")
p1

plot_data <- rbind(
  readRDS("plot_data_EpiEstim_infections.RDS"),
  readRDS("plot_data_EpiLPS_infections.RDS"),
  readRDS("plot_data_EpiNow2_infections.RDS"),
  #readRDS("plot_data_R0_infections.RDS"),
  readRDS("plot_data_rtestim_infections.RDS")
)

p2 <- this_plot(plot_data, "Instanteous R(t) of infections from **infections data**")
p2
library(patchwork)

p2 + p1

dev.size()
ggsave(
  'comparison_plot_v1.png', width = 9.291667*2/1.25, height = 8.402778/1.25, dpi = 600
)


