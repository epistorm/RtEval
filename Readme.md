# README

See the live link [here](https://mobslab.shinyapps.io/simulate_infection_data/)

1. `00_Simulate.Rmd` : The first step is to simulated case data
2. EpiEstim
3. EpiNow2

#### Collabathon tasks

- **Task 1:** All packages should do a good job of re-creating the red curve, because we are giving them the exact case data and serial interval that were used to create the data. So for your chosen package, what is the best you can do at estimating the calculated R(t) for the simulated data? (See EpiEstim.R for an example)

- **Task 2:** In reality both have noise. What happens when you introduce some random noise into estimated cases and serial interval?. How well do the they do now? What would you do to tune them in order to perform better?

- **Task 3:** You will also recieve information at different times:
* what to do next to look at how the models are performing differently at different time points. * at the same time point with different amounts of data available)



* how well does it do
* there is some back-calculation in 
* how fast is it giving you the answer

* Compute R(t) based on the dates on report


(1)
* shifting by the mean
-- this wont change the mean estimate, whether you change the estimate or the bias

but it will change the precision
and it will change the confidence about wehther R is >1 or <1
which is important
and maybe by artificially reducing the precision of R(t)
 
tradeoff is computational time vs precision 
* what is the computational cost
* what are the hidden assumptions
 
How do I parameterize EpiNow2 to recover the black line to recover the black line exactly

 
 
* how do we deal with the fact that we don't observe infections
* do we shift or do we something more fancy: 
https://www.sciencedirect.com/science/article/pii/S1755436524000458 Figure4

(2)
 How do we specify what level of temporal smoothing is needed, and if its user
 specified how do we control it
 
(3)
what is the estimate at the end of the tail
* this is a function of the incubation distribution
* also a function of the number of cases

and also at slices

(4)
would my assessment change depending on the method i use / the data i have available

are there scenarios that R(t) is above or below 1 at different time points

What do you do, and how to interpret these outputs and how differently will your
team respond to this epidemic if they see X vs Y

(5)
Can we use tools like EpiLPS and EpiNow2
to do more systematic 1 at a 1 analysis

is there a way i can switch off some features to see how much each feature
if i just change one

Can i start to understand what are the things that matter, what are the things
that change my assessment. its an all in 1 thing

i wouldnt feel comfortable using EpiNow2, of all of the features, what is the influence of these 

if i had mis-specified one of these, how screwed would i be

i don't understand where we go from here, 
* people are already saying epinow2 is too slow
* can some of these be more simplistic
* and then do we start with something simpler

where do we go from here: we have a tree of tools
* and there is a common ancestor

One option is we don't talk to eachother and keep branching off and we'll lose the
every branch comes with complexity and we might go into places with increased complexity. all we are doing is adding and adding

and so its still viable to systematically compare them.
tool X has this feature definitely performs better, but computational time is awful
but we need to invest time and resources into making this feature
more efficient.

and then for other features it doesn't add very much.

A sort of guidance for which things we want, and which things we will never 
compromise again.

A roadmap for what are the features that we need that don't rely on 

the status quo is people use features that are in their tools. and they are not
critically thinking about is this a necessary feature other than by gut.
what i want is a quantitative assessent of how needed each feature is so we can 
make more informed decisions about how necessary each feature is and what we 
need moving forwards.

We owe it to the users of these tools to be clearer about which ones they should use/
so even before thinking of more development, we are not clear about which
tool should be used for what.

We will have an amazing team for grant application. for a funder this incentivizing
stop funding 3 different teams. we'll have a bit of time where we are comparing less 

***
* to what extent can different information be included (inside the packages) 
>> A simple pipeline that doesn't include stochastic
>> the input is delayed data
* how easily is able to be included
* how easily can you tell what difference it makes in precision
>> the metrics for precision are probably in the things that Sam, and Kaitlyn have sent
* what is the cost in terms computational time of adding a new feature
>> in terms of the entire pipeline
>>> what is the timescale for the simulation (300 days?) & population bounds (10,000 peole?)

***





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

