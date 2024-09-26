#####################################
## FUNCTION TO PLOT RESULTS        ##
#####################################
this_plot <- function(pd, title,rt_sim = NULL) {
  # pd is from summarize.rtestimate()
  # title is package/method name
  # rt_sim is data.frame with Day and true rt values, Rt_calc

  plot.res <- ggplot(pd$estimates) +
    geom_hline(yintercept = 1, color = 'grey') +
    geom_ribbon(aes(x = date, ymin = lb, ymax = ub), alpha = 0.25,
                show.legend = F) +
    geom_line(aes(x = date, y = median), linewidth = 0.75,
              show.legend = F) +
    coord_cartesian(ylim = c(0, 2.5)) +
    xlab("Days") +
    ylab(expression(R(t)))

  if (length(rt_sim)) {
    # *******
    # this is the true r(t), back-calculated
    plot.res <- plot.res + geom_line(aes(x = Day, y = Rt_calc), data = rt_sim,
              linewidth= 0.5,
              linetype = '11',
              color="blue") +
    ggtitle(title)
  }

  return(plot.res)
}
