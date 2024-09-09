plot_rtcheck <- function(rtcheck) {

  require(ggplot2)

  rtall <- do.call(rbind, rtcheck$Rt_ests)

  dots = data.frame(
     x = rtcheck$inputs$daily_incidience_dates,
     y = 1
  )

  ggplot(rtall) +
    geom_ribbon(aes(x = date, ymin = Rt_lb, ymax = Rt_ub,
                    fill = package), alpha = 0.25) +
    geom_line(aes(x = date, y = Rt_median, color = package)) +
    xlab('Date') + ylab('R(t)') +
    geom_hline(yintercept = 1, linetype = '11') +
    geom_point(data  = dots, aes(x = x, y = y))
}
