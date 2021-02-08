runname <- '0053_thetaC'

# Master Results Processer: Salus Raw Results to Maps and Spatial Summaries
# Jill Deines
# June 24 2018

# Goal: Take the SALUS raw daily output and derive:
  # annual summaries for yield, irrigation, drainage, ET... for each experiment
  # spatialize results by connecting experiments back to spatial grid cell key
  # summarize regional results
  # output includes tabular summaries and annual variable maps (as RData files)

# Packages Required
library(dplyr)
library(tidyr)
library(readr)
library(sp)
library(raster)
library(salustools)

# user variables -----------------------------------------------------------

# raw salus output directory (run will be subdirectory)
salusScratch <- '/mnt/scratch/deinesji/salus/'
salusHome <- '/mnt/home/deinesji/salus/'

startYear <- 2006 # excluding wheat planting, aka first year of harvest
endYear <- 2017

# aoi - sheridan, in aea
aoi <- readRDS(paste0(salusHome,'sheridan6_aea.rds'))



# Crops in runs:
crops <- c('MZ','WH','SG','SB','AL')

# end user vars ------------------------------------------------------------

# raw results dir
rawDir <- paste0(salusScratch, runname, '/results')
outDir <- paste0(salusHome, runname,'/results')

# vector of years wanted
yearsWanted <- startYear:endYear

# step 1: raw to annual -------------------------------------------------------- 

#convert daily results to annual values, combining all experiments into 1 csv
# includes export
runResults <- salusRawToAnnual(rawDir, outDir, runname, startYear)

# step 2: expt to spatial ------------------------------------------------------

# directory of processed results
workingDir <- outDir

# load unique experiments and grid cell to Experiment code key
gridKey <- readRDS(
  paste0(salusHome,'1_Experiments_gridCellKey_SD6_top7_aimhpa_20180618.rds'))
expts <- readRDS(
  paste0(salusHome,'1_Experiments_SD6_top7_aimhpa_20180618.rds'))

# gmd4+ template raster grid (based on CDL clipped to study region boundary)
aeaProj <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
template <- raster(nrow = 4359, ncol = 7108, crs = aeaProj,
                   xmn = -522870, xmx = -309630, ymn = 1777860, 
                   ymx = 1908630) 
template[] <- 1:ncell(template)
templateVector <- getValues(template)


# Yield - Break down by crop and irrigation status

# salus variable name for yield
yield <- 'GWAD'

# irrigated
irrCrops <- runResults %>% filter(irrigation == 'Y') 

irrCropsList <- list()
for(m in 1:length(crops)){
  # subset results for crop
  crop <- crops[m]
  cropdf <- irrCrops %>% filter(SpeciesID == crop)
  cropStack <- spatializeAll(cropdf, yield, yearsWanted, gridKey,
                             template, aoi, writeOut = 'N', outFolder = workingDir)
  irrCropsList[[crop]] <- cropStack
}

# save as RData
saveRDS(irrCropsList, file = paste0(workingDir, '/All_IrrigatedCrops_YieldMaps.rds'))


# rainfed
rainCrops <- runResults %>% filter(irrigation == 'N') 

rainCropsList <- list()
for(m in 1:length(crops)){
  # subset results for crop
  crop <- crops[m]
  cropdf <- rainCrops %>% filter(SpeciesID == crop)
  cropStack <- spatializeAll(cropdf, yield, yearsWanted, gridKey,
                             template, aoi, writeOut = 'N', outFolder = workingDir)
  rainCropsList[[crop]] <- cropStack
}

# save as RData
saveRDS(rainCropsList, file = paste0(workingDir, '/All_RainfedCrops_YieldMaps.rds'))

### Irrigation

irrStack <- spatializeAll(runResults, 'IRRC_mm', yearsWanted, gridKey,
                          template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(irrStack, file = paste0(workingDir,'/Irr_stack.rds'))

### Precip
pcpStack <- spatializeAll(runResults, 'PREC_mm', yearsWanted, gridKey,
                          template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(pcpStack, file = paste0(workingDir,'/Pcpt_stack.rds'))

### Recharge

rchStack <- spatializeAll(runResults, 'DRNC_mm', yearsWanted, gridKey,
                          template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(rchStack, file = paste0(workingDir,'/Rch_stack.rds'))

### ET

ETStack <- spatializeAll(runResults, 'ETAC_mm', yearsWanted, gridKey,
                          template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(ETStack, file = paste0(workingDir,'/etac_stack.rds'))

### soil evap

et2Stack <- spatializeAll(runResults, 'ESAC_mm', yearsWanted, gridKey,
                         template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(et2Stack, file = paste0(workingDir,'/esac_stack.rds'))

### plant transipriation

et3Stack <- spatializeAll(runResults, 'EPAC_mm', yearsWanted, gridKey,
                          template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(et3Stack, file = paste0(workingDir,'/epac_stack.rds'))

### runoff

runStack <- spatializeAll(runResults, 'ROFC_mm', yearsWanted, gridKey,
                          template, aoi, writeOut = 'N', outFolder = workingDir)
saveRDS(runStack, file = paste0(workingDir,'/ROFC_runoff_stack.rds'))



# step 3: summarize spatial maps into data tables -----------------------------


# precip is averaged over the domain and kept in mm
# irrigation includes total volumetric water and mean depth
# drainage includes total volumetric water and mean depth
  # also etac, esac, and epac, rofc
# yields - summed by crop type and irrigation status, as totals and regional stats

# summarize irrigation and recharge
irrSummary <- summarizeWaterStacks(irrStack, 'irrigation')
rchSummary <- summarizeWaterStacks(rchStack, 'recharge')
etacSummary <- summarizeWaterStacks(ETStack, 'etac')
esacSummary <- summarizeWaterStacks(et2Stack, 'esac')
epacSummary <- summarizeWaterStacks(et3Stack, 'epac')
rofcSummary <- summarizeWaterStacks(runStack, 'rofc')


# get total ppt  over time - mean mm
pcpByYear <- data.frame(year = yearsWanted,
                        variable = 'precip',
                        depth_mean_mm = cellStats(pcpStack, stat = 'mean', na.rm=TRUE),
                        stringsAsFactors = FALSE)

# combine
waterVars <- irrSummary %>%
  bind_rows(rchSummary,pcpByYear, etacSummary, esacSummary, epacSummary, rofcSummary)

# export water variables
write.csv(waterVars, row.names = FALSE,
          file = paste0(workingDir,'/WaterVars_meansTotals.csv'))



### Yields
# summary stats for active pixels by class and regional totals. rbinds are 
# ugly but get the job done. oops.

yieldStats <- NA

# rainfed crops
for(crop in crops) {
  # calculate totals, means, and summary stats
  sumStats <- summarizeYieldStacks(cropCode = crop, yieldList = rainCropsList,
                                   irrigationStatus = 'N')
  # add to master data frame
  yieldStats <- rbind(yieldStats, sumStats)
}

# irrigated crops
for(crop in crops) {
  # calculate totals, means, and summary stats
  sumStats <- summarizeYieldStacks(cropCode = crop, yieldList = irrCropsList,
                                   irrigationStatus = 'Y')
  # add to master data frame
  yieldStats <- rbind(yieldStats, sumStats)
}

# remove na row
yieldStats2 <- yieldStats %>%
  filter(!is.na(yield_mean_kgha)) 

write.csv(yieldStats2, row.names=FALSE,
          file = paste0(workingDir,'/yields_statsAndTotals.csv'))






