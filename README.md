[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4271209.svg)](https://doi.org/10.5281/zenodo.4271209)

# Deines, Kendall, Butler, Basso, & Hyndman 2021, WRR
## Model files, derived data, and analysis code

6 February 2021  
Code by: Jillian Deines  
Contact: jillian.deines@gmail.com  

This codebase accompanies the paper:

Deines, JM, AD Kendall, JJ Butler Jr., B Basso, & DW Hyndman. 2021. Combining remote sensing and crop models to assess the sustainability of stakeholder-driven groundwater management in the US High Plains Aquifer. Water Resources Research, https://doi.org/10.1029/2020WR027756.

## Contents

### Manuscript
The preprint version of the manuscript (post-revisions, pre-formatting) and supplement 

### Data
All data needed to reproduce the figures and results presented in the manuscript can be found in the `data` folder. Other input data are available at their respective sources as described in the manuscript.

**Data included**

* `data/SALUS_output`: SALUS crop model output for the simulations used for the yield validation, irrigation parameter sensitivity analysis, and BAU and LEMA scenarios. Results files were generated from raw SALUS output with the template script `code/salus_hpcc/processing/03.70_salusResultsProcesser_rawToSpatial.R`; model specific run files can be found in `SALUS_model/model_scenarios`
* `data/tabular`: Data from USDA NASS, including crop type summaries, state yields, and commodity prices
* `data/tabular/wellData`: Data on groundwater pumping derived from the WIMAS database maintained by the Kansas Division of Water Resources
* `data/tabular/energy_McCarthy`: Data from [McCarthy et al. 2021](https://pubs.acs.org/doi/abs/10.1021/acs.est.0c02897) on pumping energy 
* `data/gis`: GIS input files including (1) AIM-HPA annual irrigation maps, filtered with KS place-of-use tracts and clipped to study area, and (2) Cropland Data Layer maps, cleaned for speckle and clipped to study area
* `data/ET_validation`: datasets for the ET validation between SALUS and PML v2 (a satellite-based product)

### Code
* Code to perform all paper analyses and generate figures in the paper 

Script filenames are numbered in sequential order of use. Processing is done using [R Markdown](https://rmarkdown.rstudio.com/) within an R project structure. Operational scripts have extension .Rmd; notebook style docs (code + outputs) in .md (for easing viewing on Github) and .html (for desktop viewing) are also provided.

### Figure
Figure output from scripts used to generate figures in the main text.

### SALUS model
Materials to run the SALUS simulations. Includes:

* XML input files, including crop database parameters (cdb.xml), soil properties derived from gSSURGO (KS.sdb.xml), and weather data (wdb.xml's inside the tar.gz)
* Cell-based crop rotation experiments defined in 1_Experiments_SD6_top7_aimhpa_20180618.rds
* Scripts to generate batch model runs for execution on a High Performance Computer Cluster for the model scenarios presented in the manuscript, including the baseline yield validation (0018_thetaC), business-as-usual BAU scenario (0054_thetaC), and LEMA scenario (0086_thetaC). Scenario folders include crop parameters to be used when generating individual SALUS simulations, including annual planting dates derived from NASS median statistics as well as irrigation parameters
