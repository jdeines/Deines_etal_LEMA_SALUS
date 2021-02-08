# Generate SALUS Experiment Files (.xdb.xml)
# Jill Deines
# June 15, 2018

# Goal: make SALUS experiment files based on:
#    - physical characteristics (soil/climate/crop/irrigation) from 02.20....Rmd
#    - management parameters (planting densities, irrigation thresholds)

# Output: 
  # 1 experiment .xdb.xml file for every 1000 experiments
  # the HPCC shell script (.sh)
  # the HPCC batch script (.bat)

# To Use:
  # This is designed to run on the HPCC to quickly create the .xdb.xml's
  # Each parameter run shall have a saved 03.XX script and parameter file matched
    # to the run name to preserve parameters
  # Parameters set and csv exported from 02.90_salusParameters.Rmd
  # .xdb.xml's are created in a temp folder on HPCC and not auto-saved

# Notes
  # most functions bundled into a salustools package

# End Top Matter ---------------------------------------------------------------

# R Packages Needed
library(dplyr)
library(stringr)
library(readr)
#library(devtools)
#install_github("jdeines/salustools")
library(salustools) # from Jill's github
library(lubridate)

#-------------------------------------------------------------------------------
# User Parameters 
#-------------------------------------------------------------------------------

# run name (this should also be parameter set name)
 runName <- '0040_thetaC'

# shouldn't need to change below?

# hpcc directory containing static salus files
salusBaseDir <- '/mnt/home/deinesji/salus/'

# hpcc run directory
runBaseDir <- paste0(salusBaseDir,runName,'/')

parameterDir <- runBaseDir
parameterFileNoExt <- runName

# make scratch directories
# create output directories
scratchSalus <- '/mnt/scratch/deinesji/salus/'
runFolder <- paste0(scratchSalus,runName)

# scratch run folder
dir.create(runFolder, showWarnings = FALSE)
dir.create(paste0(runFolder,'/results'), showWarnings = FALSE)

# hpcc scratch output directory to hold xdb.xml's
outDir <- paste0(scratchSalus,parameterFileNoExt,'/')

# salus crop database cdb.xml
cropfile <- 'cropsn29Dec2016_SGttMatrFixed_whIB1099_sd6.cdb.xml'
cropfileNoExt <- 'cropsn29Dec2016_SGttMatrFixed_whIB1099_sd6'  # cdb.xml file, no extension

# experiment dir and unique combos
experimentDir <- salusBaseDir
exptCombos <- '1_Experiments_SD6_top7_aimhpa_20180618.rds'

## RUN NAME AND TIME SPECS
runTitle <- runName
startDOY <- 1
startYear <- 2006   # winter wheat will be adjusted to be planted in late 2005
endYear <- 2017

## HPCC Folders and SH info
xdbDir <- outDir  # find xdb's in the output dir
xdbOut <- xdbDir  # write the Sh scripts to same directory

# hpcc directory containing salus static files
hpcHomeDir <- salusBaseDir

# hpcc directory containing created xdb.xml's and .sh scripts for this run
hpcXdbDir <- xdbDir

# hpcc directory for salus results files (stored in scratch for future processing)
hpcOutDir <- paste0(xdbDir, '/results/')

# arguments for shell script writers: be mindful of extensions
sdb <- "KS"  # sdb.xml, no extension
wdbZip <- 'gridmet_4kgrid_20050101_20171231.tar.gz'   # tarballed weather xdb.xml's


#-------------------------------------------------------------------------------
# Process Vars / END USER INPUT
#-------------------------------------------------------------------------------

# adjust start year for winter wheat planting
wheatStart <- startYear -1

# calculate number of years in run (including wheat pre-planting)
Nyrs <- endYear - startYear + 2

# load parameters
parameters <- read_csv(paste0(parameterDir,parameterFileNoExt,'_parameters.csv'))

# define crop key to link exp codes with management
cropkey <- data.frame(cropCode = c('001','004','005','024','036','061','176'),
                      crop = c('CORN','SORGHUM','SOYBEANS','WHEAT','ALFALFA',
                               'FALLOW','GRASS'))

# Extract Unique Combo Experiments ---------------------------------------------
# load experiments and split into sets of 1000 per .xdb.xml

# load experiments
expts <- readRDS(paste0(experimentDir,exptCombos))

# split out pieces
expts2 <- expts %>% 
  mutate(weather = str_sub(ExpCode, start = 10, end = 13),
         state = str_sub(ExpCode, start = 1, end = 2),
         mukey = str_sub(ExpCode, start = 3, end = 9),
         static = str_sub(ExpCode, start = 1, end = 13),
         ExpCode = as.character(ExpCode))

# make a grouping vector
ngroup <- ceiling(nrow(expts)/1000)
groups <- sort(rep(1:ngroup, 1000))[1:nrow(expts2)]

# Assign into groups of 1000, sequentially
lemaExps3 <- expts2 %>% 
  mutate(xdbGroup = groups, xdbCode = paste0('X_',xdbGroup))

##
# write experiment files! ------------------------------------------------------
# writes an experiment file for each 1000-expt group by looping through groups
# and individual rotational components of each expt

# g<-1
# i<-1
# m<-1

# write an experiment file for each xdb group
for(g in 1:ngroup){
  
  expt_set <- lemaExps3 %>% filter(xdbGroup == g)
  
  # translate variables in parameters needed to specify experiment tag
  exp_master <- salustools::makeExperimentTable(runTitle, expt_set$ExpID,
                                                expt_set$mukey, expt_set$weather, expt_set$ExpCode,
                                                wheatStart, Nyrs, startDOY, cropfp = cropfile,
                                                state = 'KS')
  
  ### Write the file! -------------------------------
  outFile2 <- paste0(outDir,expt_set$xdbCode[1], '.xdb.xml')
  
  # initialize the file
  write_xdb_topMatter(outFile2)

  # for each experiment:
  for(i in 1:nrow(exp_master)){  
    # write each set of experiment parameters
    write_xdb_experiment(outFile2, exp_master$ExpID[i], exp_master$runTitle[i], 
                         exp_master$startYear[i], exp_master$Nyrs[i], exp_master$startDOY[i], 
                         exp_master$weather[i], exp_master$weatherfp[i], exp_master$soilId[i], 
                         exp_master$soilfp[i], exp_master$cropfp[i])

    # parse experiment rotations
    rotations <- salustools::parseRotationStrings(as.character(exp_master$ExpCode[i]),
                                                  startyear = exp_master$startYear[i]+1, cropkey)
    # combine with management table
    annualSpecs <- rotations %>% left_join(parameters,by = c("year", "crop"))
    
    # write rotation and management parameters for each year
    for(m in 1:nrow(annualSpecs)){
      
      # reset irrigation method based on null irrigation status
      if (annualSpecs$irrStatus[m] == 0){
        annualSpecs$IIrrI[m] <- 'N'
      } 
      
      # set density column names based on irrigation status
      if (annualSpecs$IIrrI[m] == 'N') {
        ppopCol <- 'Ppop_rain'
        rowsCol <- 'RowSpc'
        cultivarCol <- 'cult_R'
      }  
      if (annualSpecs$IIrrI[m] %in% c('F','A','R','D','Y')){
        ppopCol <- 'Ppop_irr'
        rowsCol <- 'RowSp_irr'
        cultivarCol <- 'cult_I'
      } 
      
      # rotation parameters
      write_xdb_rotation(outFile2, m, annualSpecs$crop[m], annualSpecs$IIrrI[m], 
                         annualSpecs$IferI[m], annualSpecs$ITilI[m], 
                         annualSpecs$IHarI[m], annualSpecs$IResI[m])

      # management: planting
      
      ## adjust KS state median for by planting date adjust param for nw region
      adjPlantDOY <- annualSpecs$plantingDOY_50[m] + annualSpecs$plantDOY_adj[m]
      
      write_xdb_mPlanting(outFile2, annualSpecs$CropMod[m], annualSpecs$SpeciesID[m], 
                          annualSpecs[m,cultivarCol], annualSpecs$plantYear[m], 
                          adjPlantDOY, annualSpecs[m,ppopCol],
                          annualSpecs[m,rowsCol], annualSpecs$Sdepth[m])

      # management: fertilize
      if(annualSpecs$IferI[m] == 'R'){  # specified fert
        # figure out how many events
        for(p in 1:annualSpecs[m,'numFertEvents']){
          # set first fert date based on planting
          fert1Day <- adjPlantDOY
          # but not for wheat
          if(annualSpecs$crop[m] == 'WHEAT') fert1Day <- 75
          
          if(p==1){
            write_xdb_mFertilize(outFile2, annualSpecs$harvYear[m], fert1Day,
                                 annualSpecs$ANFer1[m])
          }
          if(p==2){
            fert2DOY <- adjPlantDOY + 30
            write_xdb_mFertilize(outFile2, annualSpecs$harvYear[m], fert2DOY,
                                 annualSpecs$ANFer2[m])
          }
        }
      }
      
      if(annualSpecs$IferI[m] == 'A'){ # auto fertilization
        write_xdb_mFertilize_Auto(outFile2, annualSpecs$SoilNC[m], annualSpecs$ANFer1[m])
      }

      
      # management: tillage
      if(annualSpecs$ITilI[m] == 'R'){
        write_xdb_mTillage(outFile2, annualSpecs$harvYear[m], 
                           adjPlantDOY-annualSpecs$T_DaysBeforePlanting[m],
                           TDep = annualSpecs$TDep[m])
      }
     
      
      # management: irrigation
      if(annualSpecs$IIrrI[m] == 'F'){
        write_xdb_mIrrigate_Auto(outFile2, 
                                 AIrAm = annualSpecs$AIrAm[m], 
                                 DSoil = annualSpecs$DSoil[m],
                                 ThetaC = annualSpecs$ThetaC[m],
                                 IAMe = annualSpecs$IAMe[m])
      }

      # management: harvest
      if(annualSpecs$IHarI[m] == 'M'){
        write_xdb_mHarvest_maturity(outFile2, closeComponent = 'Y')
      }  
      if(annualSpecs$IHarI[m] == 'R'){
        write_xdb_mHarvest_reported(outFile2, annualSpecs$harvYear[m], 
                                    annualSpecs$harvestedDOY_50[m], closeComponent = 'Y')
      }
   
    }  
    
    # close rotations and experiment
    write_xdb_bottomMatter(outFile2, closeRotation = 'Y', closeExperiment = 'Y')

  }  
  # close out
  write_xdb_bottomMatter(outFile2, writeVersion = 'Y', closeXDB = 'Y')

}


## Make the HPCC scripts -------------------------------------------------------

# Shell script: make 1 sh file for each experiment

# extract xdb name from xmls
xdb <- sapply(strsplit(list.files(xdbDir, pattern='*.xdb.xml'),'.', fixed=TRUE), head, 1)

DayVars <- 'ExpID,Title,SpeciesID,GWAD,IRRC,DRNC,PREC,ETAC,ESAC,EPAC,ROFC'
SeaVars <- 'ExpID,Title,SpeciesID,GWAD'

walltime <- '01:30:00'
memory <- '2000mb'

SALUS_bat_Nflag <- '-w'

# loop over xdbs
for (i in 1:length(xdb)){
  salustools::write_HPC_shell(xdbOut, hpcHomeDir, hpcXdbDir, hpcOutDir, 
                              Nflag = SALUS_bat_Nflag,
                              xdb[i], sdb, wdbZip, DayVars,
                              SeaVars, walltime, memory, cdb = cropfileNoExt)
}  

### HPC bash bat script
# sends the sh files to queue

shNames <- paste0(xdb,'.sh')
fileOut <- paste0(xdbOut, parameterFileNoExt, '.bat')

# write out .bat file
write_HPC_bat(shNames, fileOut)

