# Code for the R(t) Collabathon 2024

`00_Simulate.Rmd`: See the live link [here](https://mobslab.shinyapps.io/simulate_infection_data/)

`02_<package>_infections.R` compares each package to infections data

`02_<package>_reports.R` compares each package to reporting data

`03_plot.R` plots

`04_eval.R` starter evaluation code


# SETUP

First make sure you have the correct R installed
```
required_version <- "4.0.0"
  if (getRversion() < required_version) {
    stop(paste("Your R version is", getRversion(), ". Please update to version", required_version, "or higher."))
  } else {
    cat(paste("R version is sufficient:", getRversion(), "\n"))
  }
```


Then you need these packages
```
install.packages( "rmarkdown", "shiny" ,    
"knitr",     "plotly",    "purrr" ,
"splines" ,  "tidyverse", "readr",    
 "EpiLPS",  "EpiNow2",
 "lubridate", "rstan"  ,   "cmdstanr" , "R0" ,       "remotes" ,   
 "ggpubr" ,   "ggtext" ,   "lemon" ,    "patchwork")
 
remotes::install_github("dajmcdon/rtestim")

install.packages('EpiEstim', repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))
```


