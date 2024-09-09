#' Getting the R(t) estimate from EpiEstim
#'
#' @param daily_incidience_dates, days of reported incidences
#' @param daily_incidence_values, reported incidences, an integer
#' @param daily_si_values, the serial interval
#'
#' @return a data frame
#' @export
#'
#' @examples
getEpiEstim_R <- function(daily_incidience_dates,
                          daily_incidence_values,
                          daily_si_values,
                          window_size) {

  require(EpiEstim)

  # creates the incidence df
  incidence_df = data.frame(dates = daily_incidience_dates,
                            I = daily_incidence_values)

  # serial interval from data
  si_sample <- as.matrix(daily_si_values)

  # window size
  stopifnot(class(window_size) == 'integer')
  stopifnot(window_size >= 2)
  stopifnot(window_size <= (nrow(incidence_df) - 2))

  # estimate R
  # t_start has to start with 2
  # and the end is inclusive
  t_start = (0 + 2):(nrow(incidence_df) - (window_size - 1))
  t_end = ((window_size - 1) + 2):nrow(incidence_df)
  getR <- EpiEstim::estimate_R(incidence_df,
                               method = 'si_from_sample',
                               si_sample = si_sample,
                               config = make_config(list(
                                 t_start = t_start,
                                 t_end = t_end
                               )))

  # output
  # the R(t) estimate is defined at the end of the window
  n_days = length(daily_incidience_dates)
  data.frame(
    package = 'EpiEstim',
    date = daily_incidience_dates[(2 + (window_size - 1)):n_days],
    Rt_median = getR$R$`Median(R)`,
    Rt_lb = getR$R$`Quantile.0.025(R)`,
    Rt_ub = getR$R$`Quantile.0.975(R)`
  )

}
