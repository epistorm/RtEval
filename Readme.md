# Code for the R(t) Collabathon 2024

`00_Simulate.Rmd`: See the live link [here](https://mobslab.shinyapps.io/simulate_infection_data/)

`02_<package>_infections.R` compares each package to infections data

`02_<package>_reports.R` compares each package to reporting data

`03_plot.R` plots data in `plot_data_<package>_infections.RData` objects

`04_eval.R` starter evaluation code

the `in_progress` folder contains files in progress for `R0`, `EpiFilter`, and `EpiNowcast`


# Slides:

* [Folder](https://drive.google.com/drive/u/1/folders/1_lisRVP_FA5-gtz8zENxp6w6YDEKtXCm)
* [Developer/Implementor](https://docs.google.com/presentation/d/1ByTkzhI2t_2KcS-55ySd3TeVHUMyiln42DxMmJ0KAbg/edit#slide=id.g3047e1edbf3_0_0)
* [User/Evaluator](https://docs.google.com/presentation/d/1yjTKHkPsqzm8Gkqo-h_gAlxmGWh1EALgbcxQD4Bdsps/edit#slide=id.p)
* [Decision Maker](https://docs.google.com/presentation/d/1tCqI534oVKZItKZAoXjhsge81GmVOZx51pd5JKZ8oxI/edit#slide=id.p)
* [Workshop slides](https://docs.google.com/presentation/d/1mMpiTd7DUJr-_YpjISa9u-2vcSEz7xP9/edit#slide=id.p1)

And here is the link to join the slack workspace [link](https://join.slack.com/t/epicollabathon2024/shared_invite/zt-2r1oytrvr-omdMDJVzWOnW1faACxLeDQ)

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
install.packages( c("rmarkdown", "shiny" ,    
"knitr",     "plotly",    "purrr" ,
"splines" ,  "tidyverse", "readr",    
 "EpiLPS",  "EpiNow2",
 "lubridate", "rstan"  ,   "cmdstanr" , "R0" ,       "remotes" ,   
 "ggpubr" ,   "ggtext" ,   "lemon" ,    "patchwork"))
 
remotes::install_github("dajmcdon/rtestim")

install.packages('EpiEstim', repos = c('https://mrc-ide.r-universe.dev', 'https://cloud.r-project.org'))
```


