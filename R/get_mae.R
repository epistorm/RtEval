######################################################
## FUNCTION TO CALCULATE THE MAE FOR VECTOR OF RT   ##
######################################################
get_mae <- function(pd,rt_sim){
  # pd is summarize.rtestimate object
  # rt_sim is true values of rt

  return(mean(abs(pd$estimates$median-rt_sim$Rt_calc)))

}
