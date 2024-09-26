# RtEval

## Outline

* The goal of this repository is to evaluate software packages for estimating the effective reproduction number.
* We do this by fitting models from a range of software packages to simulated and real data
* In the future, these data will be stored in another repository ("`rtdata`")
* In the future, we will summarise the output of each package consistently using the [`summrt`](https://github.com/EpiForeSITE/summrt) R package
* We hope that this repository will contain evaluations which are run semi-regularly using [GitHub actions](https://docs.github.com/en/actions) so as to serve as a living, rather than static, comparison

## Live vignettes

The following vignettes (which are hosted under the [vignettes](vignettes) folder) were automatically built using GitHubActions:

- epiestim: <https://epistorm.github.io/RtEval/epiestim_vignette.html>
- EpiLPS: <https://epistorm.github.io/RtEval/EpiLPS_vignette.html>
- EpiNow2: <https://epistorm.github.io/RtEval/EpiNow2_vignette.html>
- RtEstim: <https://epistorm.github.io/RtEval/RtEstim_vignette.html>
- Joint: <https://epistorm.github.io/RtEval/eval_vignette.html>

## Structure

Remains to scope!

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
install.packages(
  c(
    "rmarkdown", "shiny", "knitr", "plotly",
    "purrr", "splines", "tidyverse", "readr",
    "EpiLPS", "EpiNow2", "lubridate", "rstan",
    "cmdstanr", "R0", "remotes", "ggpubr",
    "ggtext", "lemon", "patchwork"
  )
)

remotes::install_github("dajmcdon/rtestim")

install.packages("EpiEstim", repos = c("https://mrc-ide.r-universe.dev", "https://cloud.r-project.org"))
```

## Rt Collabathon 2024

This work is a part of the [Epistorm Rt Collabathon](https://www.epistorm.org/collabathon2024).

<details>
  <summary>Participants in the workshop may be interested in these links:</summary>

* [Folder](https://drive.google.com/drive/u/1/folders/1_lisRVP_FA5-gtz8zENxp6w6YDEKtXCm)
* [Developer/Implementor](https://docs.google.com/presentation/d/1ByTkzhI2t_2KcS-55ySd3TeVHUMyiln42DxMmJ0KAbg/edit#slide=id.g3047e1edbf3_0_0)
* [User/Evaluator](https://docs.google.com/presentation/d/1yjTKHkPsqzm8Gkqo-h_gAlxmGWh1EALgbcxQD4Bdsps/edit#slide=id.p)
* [Decision Maker](https://docs.google.com/presentation/d/1tCqI534oVKZItKZAoXjhsge81GmVOZx51pd5JKZ8oxI/edit#slide=id.p)
* [Workshop slides](https://docs.google.com/presentation/d/1mMpiTd7DUJr-_YpjISa9u-2vcSEz7xP9/edit#slide=id.p1)
* [Join the Slack workspace](https://join.slack.com/t/epicollabathon2024/shared_invite/zt-2r1oytrvr-omdMDJVzWOnW1faACxLeDQ)
* [Synthetic GLEAM data from Jessica Davis, Ph.D](https://github.com/epistorm/rt-collabathon-2024)  

</details>
