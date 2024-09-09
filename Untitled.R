te <- function()  {
library(EpiEstim)
data("Flu2009")

## ----------------------------------
### *****
## PEOPLE WILL GENERATE NEW TRUE R(T)
## generate true R(t)

## OPTIONS

## * two peaks
## * the end of the curve is peaking now
## * sharp peaks versus sloping
## * oscillating

## ALSO SIMULATE reporting and biological delays
##

# *****
## THEN GENERATE NEW CASES FROM THIS CURVES
daily_incidience_dates = Flu2009$incidence$dates
daily_incidence_values = as.integer(Flu2009$incidence$I)
# *****

daily_si_values = result6
# *****

## ----------------------------------
devtools::load_all()
library(RtEval)

## RUN THROUGH THE MACHINE
rt1 <- rtcheck(daily_incidience_dates,
               daily_incidence_values,
               daily_si_values,
               window_size = as.integer(7))

## ----------------------------------
## EVALUATE THE OUTPUT
## * near-realtime, how well is it doing at the end of the curve
## * througout, how well did it do from the beginning
## Frameworks
## * retrospective
## * semi-realtime
## *


plot_rtcheck(rt1)
tail(do.call(rbind, rt1$Rt_ests))
}

