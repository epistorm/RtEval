# https://github.com/kpzoo/EpiFilter/blob/master/R%20files/vignetteCOVID.R
#FUNCTION:
# EpiFilter function: provides formally smoothed and exact estimates
# Method based on Bayesian recursive filtering and smoothing
epiFilter <- function(Rgrid, m, eta, pR0, nday, Lday, Iday, a){

  # Probability vector for R and prior
  pR = matrix(0, nday, m); pRup = pR
  pR[1, ] = pR0; pRup[1, ] = pR0

  # Mean and median estimates
  Rmean = rep(0, nday); Rmed = Rmean
  # 50% and 95% (depends on a) confidence on R
  Rhat = matrix(0, 4, nday)
  # Initialise mean
  Rmean[1] = pR[1, ]%*%Rgrid
  # CDF of prior
  Rcdf0 = cumsum(pR0)
  # Initialise quartiles
  idm = which(Rcdf0 >= 0.5, 1); Rmed[1] = Rgrid[idm[1]]
  id1 = which(Rcdf0 >= a, 1); id2 = which(Rcdf0 >= 1-a, 1)
  id3 = which(Rcdf0 >= 0.25, 1); id4 = which(Rcdf0 >= 0.75, 1)
  Rhat[1, 1] = Rgrid[id1[1]]; Rhat[2, 1] = Rgrid[id2[1]]
  Rhat[3, 1] = Rgrid[id3[1]]; Rhat[4, 1] = Rgrid[id4[1]]

  # Precompute state distributions for R transitions
  pstate = matrix(0, m, m);
  for(j in 1:m){
    pstate[j, ] = dnorm(Rgrid[j], Rgrid, sqrt(Rgrid)*eta)
  }

  # Update prior to posterior sequentially
  for(i in 2:nday){
    # Compute mean from Poisson renewal (observation model)
    rate = Lday[i]*Rgrid
    # Probabilities of observations
    pI = dpois(Iday[i], rate)

    # State predictions for R
    pRup[i, ]  = pR[i-1, ]%*%pstate
    # Update to posterior over R
    pR[i, ] = pRup[i, ]*pI
    pR[i, ] = pR[i, ]/sum(pR[i, ])

    # Posterior mean and CDF
    Rmean[i] = pR[i, ]%*%Rgrid
    Rcdf = cumsum(pR[i, ])

    # Quantiles for estimates
    idm = which(Rcdf >= 0.5, 1); Rmed[i] = Rgrid[idm[1]]
    id1 = which(Rcdf >= a, 1); id2 = which(Rcdf >= 1-a, 1)
    id3 = which(Rcdf >= 0.25, 1); id4 = which(Rcdf >= 0.75, 1)
    Rhat[1, i] = Rgrid[id1[1]]; Rhat[2, i] = Rgrid[id2[1]]
    Rhat[3, i] = Rgrid[id3[1]]; Rhat[4, i] = Rgrid[id4[1]]
  }

  # Main outputs: estimates of R and states
  epiFilter = list(Rmed, Rhat, Rmean, pR, pRup, pstate)
}
#FUNCTION:
recursPredict <- function(Rgrid, pR, Lday, Rmean, a){

  # Grid size and length of time series
  nday = nrow(pR); m = ncol(pR)
  # Test lengths of inputs
  if (length(Rgrid) != m | length(Lday) != nday){
    stop("Input vectors of incorrect dimension")
  }
  # Mean prediction: Lday[i] => Iday[i+1]
  pred = Lday*Rmean; pred = pred[1:length(pred)-1]

  # Discrete space of possible predictions
  Igrid = 0:800; lenI = length(Igrid);

  # Check if close to upper bound
  if (any(pred > 0.9*max(Igrid))){
    stop("Epidemic size too large")
  }

  # Prediction cdf and quantiles (50% and 95%)
  Fpred = matrix(0, nday-1, lenI)
  predInt = matrix(0, 4, nday-1)

  # At every time construct CDF of predictions
  for(i in 1:(nday-1)){
    # Compute rate from Poisson renewal
    rate = Lday[i]*Rgrid
    # Prob of any I marginalised over Rgrid
    pI = rep(0, lenI)

    # Probabilities of observations 1 day ahead
    for(j in 1:lenI){
      # Raw probabilities of Igrid
      pIset = dpois(Igrid[j], rate)
      # Normalised by probs of R
      pI[j] = sum(pIset*pR[i, ])
    }

    # Quantile predictions and CDF at i+1
    Fpred[i, ] = cumsum(pI)/sum(pI)
    id1 = which(Fpred[i, ] >= a); id2 = which(Fpred[i, ] >= 1-a)
    id3 = which(Fpred[i, ] >= 0.25); id4 = which(Fpred[i, ] >= 0.75)

    # Assign prediction results
    predInt[1, i] = Igrid[id1[1]]; predInt[2, i] = Igrid[id2[1]]
    predInt[3, i] = Igrid[id3[1]]; predInt[4, i] = Igrid[id4[1]]
  }
  # Main outputs: mean and 95% predictions
  recursPredict = list(pred, predInt)
}
#FUNCTION:
epiSmoother <- function(Rgrid, m, pR, pRup, nday, pstate, a){

  # Last smoothed distribution same as filtered
  qR = matrix(0, nday, m); qR[nday, ] = pR[nday, ]

  # Main smoothing equation iteratively computed
  for(i in seq(nday-1, 1)){
    # Remove zeros
    pRup[i+1, pRup[i+1, ] == 0] = 10^-8

    # Integral term in smoother
    integ = qR[i+1, ]/pRup[i+1, ]
    integ = integ%*%pstate

    # Smoothed posterior over Rgrid
    qR[i, ] = pR[i, ]*integ
    # Force a normalisation
    qR[i, ] = qR[i, ]/sum(qR[i, ]);
  }

  # Mean, median estimats of R
  Rmean = rep(0, nday); Rmed = Rmean
  # 50% and 95% (depends on a) confidence on R
  Rhat = matrix(0, 4, nday)

  # Compute at every time point
  for (i in 1:nday) {
    # Posterior mean and CDF
    Rmean[i] = qR[i, ]%*%Rgrid
    Rcdf = cumsum(qR[i, ])

    # Quantiles for estimates
    idm = which(Rcdf >= 0.5); Rmed[i] = Rgrid[idm[1]]
    id1 = which(Rcdf >= a, 1); id2 = which(Rcdf >= 1-a, 1)
    id3 = which(Rcdf >= 0.25, 1); id4 = which(Rcdf >= 0.75, 1)
    Rhat[1, i] = Rgrid[id1[1]]; Rhat[2, i] = Rgrid[id2[1]]
    Rhat[3, i] = Rgrid[id3[1]]; Rhat[4, i] = Rgrid[id4[1]]
  }
  # Main outputs: estimates of R and states
  epiSmoother = list(Rmed, Rhat, Rmean, qR)
}

url <- "https://raw.githubusercontent.com/cmilando/RtEval/main/all_data.RDS"
all_data <- readRDS(url(url))
case_choice <- "daily_infections"
#incidence and dates
Iday = all_data$cases$daily_infections
dates = all_data$cases$day
nday = length(dates); tday = 1:nday
#serial interval distribution
wdist <- ########

# Total infectiousness
Lday = rep(0, nday)
for(i in 2:nday){
  # Total infectiousness
  Lday[i] = sum(Iday[seq(i-1, 1, -1)]*wdist[1:(i-1)])
}
# Setup grid and noise parameters
Rmin = 0.01; Rmax = 10; eta = 0.1
# Uniform prior over grid of size m
m = 61; pR0 = (1/m)*rep(1, m)
# Delimited grid defining space of R
Rgrid = seq(Rmin, Rmax, length.out = m)
# Filtered (causal) estimates as list [Rmed, Rhatci, Rmean, pR, pRup, pstate]
# Filtered (causal) estimates as list [Rmed, Rhatci, Rmean, pR, pRup, pstate]
#Rfilt = epiFilter(Rgrid, m, eta, pR0, nday, Lday[tday], Iday[tday], 0.025)
# Causal predictions from filtered estimates [pred predci]
#Ifilt = recursPredict(Rgrid, Rfilt[[4]], Lday[tday], Rfilt[[3]], 0.025)
