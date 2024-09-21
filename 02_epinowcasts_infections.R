install.packages(
  "epinowcast", repos = "https://epinowcast.r-universe.dev"
)

# if you not yet installed `epinowcast`, or you installed it without `Suggests` dependencies
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
# once `cmdstanr` is installed:
cmdstanr::install_cmdstan()
