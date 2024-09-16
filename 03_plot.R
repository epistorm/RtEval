
url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))

plot_data <- rbind(
  readRDS("plot_data_EpiEstim.RDS"),
  readRDS("plot_data_EpiLPS.RDS"),
  readRDS("plot_data_EpiNow2.RDS")
)

library(ggpubr)
library(lemon)
library(tidyverse)

as_tibble(plot_data) %>%
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
  facet_rep_wrap(~package, repeat.tick.labels = 'y') +
  # *******
  theme(
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 14),
    strip.background = element_blank(),
    strip.text = element_text(face = 'bold')
  )

dev.size()
ggsave(
  'comparison_plot_v1.png', width = 11/1.25, height = 3.9/1.25, dpi = 600
)


