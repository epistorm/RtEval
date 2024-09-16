# README

Welcome to the Collabathon 

1. `00_Simulate.Rmd` : The first step is to simulated case data
2. EpiEstim
3. EpiNow2

#### Collabathon tasks

- **Task 1:** All packages should do a good job of re-creating the red curve, because we are giving them the exact case data and serial interval that were used to create the data. So for your chosen package, what is the best you can do at estimating the calculated R(t) for the simulated data? (See EpiEstim.R for an example)

- **Task 2:** In reality both have noise. What happens when you introduce some random noise into estimated cases and serial interval?. How well do the they do now? What would you do to tune them in order to perform better?

#### Standardizing inputs

- In the service of standardizing inputs to all r(t) packages, what should be allowed?


#### Remaining todos

- The plot resolution in 00_simulate could be higher. in fact, it seems to be good for plotly but not good for the gplot images. I don't quite know how to solve this. I tried [this hack](https://stackoverflow.com/questions/51409188/how-to-use-display-a-plot-with-high-resolution-in-a-shiny-app) but didn't really seem worth it. Open to other ideas

- add random noise

-- Other packages to test:

 * [CM] EpiNow2
 * [CM] EpiEstim
 * [CM] EpiLPS
 * ern
 * R0
 * EarlyR
 * EpiTrix
 * RtEstim
 * 
 

 


#### Vizualzation

- what to do next to look at how the models are performing differently at different time points. (or at the same time point with different amounts of data available)
