#' RT check objectg
#'
#' What you really want is to run through all of them,
#  just wrapping isn't that useful
#'
#' @param daily_incidience_dates, days of reported incidences
#' @param daily_incidence_values, reported incidences, an integer
#' @param daily_si_values, the serial interval
#' @param ...
#'
#' @return a list of dataframes for each package
#' @export
#'
#' @examples
rtcheck <- function(daily_incidience_dates = vector(),
                    daily_incidence_values = vector(),
                    daily_si_values = vector(),
                    ... ) {

  # -------------------------------------------
  # all have a length
  stopifnot(length(daily_incidience_dates) > 0)
  stopifnot(length(daily_incidence_values) > 0)
  stopifnot(length(daily_si_values) > 0)

  # class checks
  stopifnot(all(class(daily_incidience_dates) == 'Date'))
  stopifnot(all(class(daily_incidence_values) == 'integer'))
  stopifnot(all(class(daily_si_values) == 'numeric'))

  # length check
  stopifnot(length(daily_incidience_dates) == length(daily_incidence_values))

  # values checks
  for(i in 2:length(daily_incidience_dates)) {
    stopifnot(daily_incidience_dates[i] - daily_incidience_dates[i - 1] == 1)
  }
  stopifnot(all(daily_incidence_values >= 0))
  stopifnot(all(daily_si_values >= 0))
  stopifnot(all(daily_si_values < 1))

  # additional parameters, these are checked in each individual function
  params <- list(...)
  for (name in names(params) ) {
    assign(name, params[[name]])
  }

  # -------------------------------------------
  inputs = list(
    'daily_incidence_values' = daily_incidence_values,
    'daily_incidience_dates' = daily_incidience_dates,
    'daily_si_values' = daily_si_values
  )
  for (name in names(params) ) {
    inputs[[name]] = params[[name]]
  }

  Rt_ests = list(
    #
    'EpiEstim' = getEpiEstim_R(daily_incidience_dates, daily_incidence_values,
                               daily_si_values, window_size),
    #
    'EpiNow2' = getEpiNow2_R(daily_incidence_values)
  )

  list('inputs' = inputs, 'Rt_ests' = Rt_ests)

}

