#' Getting the R(t) estimate from EpiEstim
#'
#' @param daily_incidience_dates, days of reported incidences
#' @param daily_incidence_values, reported incidences, an integer
#' @param daily_si_values, the serial interval
#' @param window_size, the sliding window size in days
#'
#' @return a data frame
#' @export
#'
#' @examples
getEpiNow2_R <- function(daily_incidence_values) {


  require(EpiNow2)

  #
  gi <- EpiNow2::Gamma(mean = 2.6, sd = 1.5, max = 11)

  # # values from epiestim x ern
  # reporting_delay_epinow <- Gamma(mean = 0.3143663,
  #                                 sd = 0.5606837,
  #                                 max = 0.8671758)
  #
  # # values from epiestim x ern
  # incubation_period_epinow <- Gamma(mean = 0.3589284,
  #                                   sd = 0.5991064,
  #                                   max = 1.057728)

  #
  # delay_epinow <- incubation_period_epinow + reporting_delay_epinow

  # from epiestim x ern prior_R0_shape = 2 and prior_R0_rate = 0.5
  # rt_prior_epinow <- list(mean = 4, sd = 2.9)

  # columsn are called `date` and `confirm`
  incidence_df = data.frame(date = daily_incidience_dates,
                            confirm = daily_incidence_values)

  res_epinow <- epinow(
    incidence_df,
    generation_time = generation_time_opts(gi)#,
    #delays = delay_opts(delay_epinow),
    #rt = rt_opts(prior = rt_prior_epinow)
  )

  yy <- rstan::extract(res_epinow$estimates$fit)

  Rt_median = apply(yy$R, 2, median)
  Rt_lb = apply(yy$R, 2, quantile, 0.025)
  Rt_ub = apply(yy$R, 2, quantile, 0.975)

  #
  n_days = length(daily_incidience_dates)
  extra_days = daily_incidience_dates[n_days] + 1:7
  data.frame(
    package = 'EpiNow2',
    date = c(daily_incidience_dates, extra_days),
    Rt_median = Rt_median,
    Rt_lb = Rt_lb,
    Rt_ub = Rt_ub
  )

}
