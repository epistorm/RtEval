# RtEval

## Structure

## Set-up

To run the code in this repository you'll need at least R version 4.0.0:

```r
required_version <- "4.0.0"
if (getRversion() < required_version) {
  stop(paste("Your R version is", getRversion(), ". Please update to version", required_version, "or higher."))
} else {
  cat(paste("R version is sufficient:", getRversion(), "\n"))
}
```

You will also need these packages:

```r
install.packages(c("rmarkdown", "shiny", "knitr", "plotly", "purrr", "splines", "tidyverse", "readr", "EpiLPS", "EpiNow2", "lubridate", "rstan", "cmdstanr", "R0", "remotes", "ggpubr", "ggtext", "lemon", "patchwork"))

remotes::install_github("dajmcdon/rtestim")

install.packages("EpiEstim", repos = c("https://mrc-ide.r-universe.dev", "https://cloud.r-project.org"))
```
