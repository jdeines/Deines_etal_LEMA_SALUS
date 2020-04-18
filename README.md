# Deines, Kendall, Butler, Basson, & Hyndman 2019
## Model files, derived data, and analysis code

18 April 2020  
Code by: Jillian Deines  
Contact: jillian.deines@gmail.com  

## Contents

### Data
All data needed to reproduce the figures and results presented in the manuscript can be found in the `data` folder.

**Data included**

* `data/SALUS_output`: SALUS crop model output for the simulations used for the yield validation, BAU, and LEMA scenarios. Results files were generated from raw SALUS output with the template script `code/salus_hpcc/processing/03.70_salusResultsProcesser_rawToSpatial.R`; model specific run files can be found in `SALUS_model/model_scenarios`
* `data/tabular`: Data from USDA NASS, including crop type summaries, state yields, and commodity prices
* `data/tabular/wellData`: Data on groundwater pumping derived from the WIMAS database maintained by the Kansas Division of Water Resources

### Code
* Code to perform all paper analyses and generate figures in the paper 

Script filenames are numbered in sequential order of use. Processing is done using [R Markdown](https://rmarkdown.rstudio.com/) within an R project structure. Operational scripts have extension .Rmd; knitted outputs in .md (for easing viewing on Github) and .html (for desktop viewing) are also provided.

### Figure
Figure output from scripts used to generate figures in the main text.

### SALUS model
Materials to run the SALUS simulations. Includes:

* XML input files, including crop database parameters (cdb.xml), soil properties derived from gSSURGO (KS.sdb.xml), and weather data (wdb.xml's inside the tar.gz)
* Cell-based crop rotation experiments defined in 1_Experiments_SD6_top7_aimhpa_20180618.rds
* Scripts to generate batch model runs for execution on a High Performance Computer Cluster for the model scenarios presented in the manuscript, including the baseline yield validation (0018_thetaC), business-as-usual BAU scenario (0054_thetaC), and LEMA scenario (0086_thetaC). Scenario folders include crop parameters to be used when generating individual SALUS simulations, including annual planting dates derived from NASS median statistics as well as irrigation parameters
