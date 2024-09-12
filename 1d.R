

all_data <- readRDS("rds/all_data.RDS")
head(all_data$rt)

get_Rt <- function(m, w, remove_burnin = NA) {

  R_rev <- vector('numeric', length(m))
  S <- length(w)
  tmax = length(m)

  for(t in 2:tmax) {

    tau_end = min(S, t - 1)

    # reverse the renewal equation to get the actual R(t)
    # given the data
    c_mat <- w[1:tau_end] %*% m[t - 1:tau_end]

    R_rev[t] <- solve(t(c_mat) %*% c_mat) %*% t(c_mat) %*% m[t]

  }

  if(!is.na(remove_burnin)) R_rev[1:remove_burnin] <- NA

  return(R_rev)

}


head(all_data$cases)

x <- get_Rt(
  m = unname(all_data$cases$`Daily Infections`),
  w = unname(all_data$serial$Px))
x

#x <- x[2:length(x)]
x
plot(x, type = 'p', ylim = c(0, 5))

lines(all_data$rt$Rt[0:nrow(all_data$rt)], col = 'blue')

plot(Rmatrix[,1], type = 'l', col = 'red', ylim = c(0, 5))
lines(R_this[, 1], col = 'blue')


