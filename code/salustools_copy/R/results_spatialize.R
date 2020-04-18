#' Spatialize SALUS Results
#'
#' Takes the processed annual results from SALUS and turns into a spatial raster,
#' based on the Experiment IDs - EXpID - and gridcell keys. Requires tidyverse,
#' raster, and rgdal
#' @param expt_df Data.frame containing SALUS annual results in long format, loaded with readr::read_csv
#' @param variable Variable to process
#' @param year Year to process
#' @param gridkey data.frame key linking ExpID and template gridcell
#' @param template raster template
#' @param aoi Area of interest to clip to defined by a spdf
#' @keywords spatialize results
#' @export
#' @examples
#' # load formatted results output
#' library(readr)
#' resultsDir <- 'C:/Users/deinesji/Dropbox/1PhdJill/hpa/LEMAs/data/salus/experiments/LEMA_historical_autoIrrigation_v02/results'
#' runname <- 'lema_historic_auto_v02'
#' expt_df <- read_csv(paste0(resultsDir, '/', runname, '.csv'))
#'
#' # template raster
#' library(raster)
#' aeaProj <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
#' template <- raster(nrow = 4359, ncol = 7108, crs = aeaProj,
#'                    xmn = -522870, xmx = -309630, ymn = 1777860,
#'                    ymx = 1908630)
#' template[] <- 1:ncell(template)
#'
#' # variable wanted
#' variable <- 'IRRC_mm'
#'
#' year <- 2006
#'
#' # load my grid key from r data...
#' comboDir <- 'C:/Users/deinesji/Dropbox/1PhdJill/hpa/LEMAs/data/salus/combinationGrids/spatialFilters'
#' load(file = paste0(comboDir,'/uniqueExperiments_gmd4p_Sheridan6_top6.RData'))
#' gridkey <- gridExps
#'
#' rasterData <- spatialize(expt_df, variable, year, gridkey, template, aoi)

spatialize <- function(expt_df, variable, year, gridkey, template, aoi){
  # extract 1 variable and spread to wide
  var.annual <- expt_df %>%
    mutate(Year = paste0('x',Year)) %>%
    rename_('variable' = variable ) %>%
    dplyr::select(c(ExpID, Year, variable)) %>%
    spread(key = Year, value = variable)

  # add grid cell ids to results
  gridkey$ExpID <- as.character(gridkey$ExpID)
  var.annual2 <- var.annual %>%
    left_join(gridkey, by = 'ExpID')  %>%
    mutate(gridcell = as.integer(gridcell))

  # template to vector
  templateVector <- getValues(template)

  # join results to template vector
  template.df <- data.frame(gridcell = templateVector)
  resVectors <-  template.df %>%
    left_join(var.annual2, by = 'gridcell')

  # rasterize data vector
  outRas <- template
  yearCol <- paste0('x',year)
  outRas[] <- resVectors[,yearCol]

  outRasClip <- crop(outRas, aoi)

  return(outRasClip)
}

#' Spatialize wrapper: apply to multiple years
#'
#' Function to apply the spatialize function to all years, and export rasters, optionally
#' @param expt_df Data.frame containing SALUS annual results in long format, loaded with readr::read_csv
#' @param variable Variable to process
#' @param yearsWanted vector of years to process
#' @param gridkey data.frame key linking ExpID and template gridcell
#' @param template raster template
#' @param aoi Area of interest to clip to defined by a spdf
#' @param writeOut Y or N
#' @param outFolder Needed if writeOut = 'Y'
#' @keywords spatialize results all years
#' @export
#' @examples
#' #' # example forthcoming

# returns a raster stack for value
spatializeAll <- function(expt.df, variable, yearsWanted, gridkey, template, aoi,
                          writeOut = 'N', outFolder = ''){
  rasList <- list()
  for(year in yearsWanted){
    rasName <- as.character(year)
    ras <- salustools::spatialize(expt.df, variable, year,
                                  gridkey, template,aoi)
    if(writeOut == 'Y'){
      fname <- paste0(outFolder, '/',variable, '_',year, '.tif')
      writeRaster(ras, file = fname)
    }
    rasList[[rasName]] <- ras
  }
  rasStack <- stack(rasList, quick = TRUE)
}


#' Annual Yield Stats from Spatialized Results
#'
#' Function to extract annual total and summary stats from stacks of annual
#' maps for the specified variable. Returns a data frame with annual totals and
#' per area stats for all years for the specified variable and irrigation status
#' @param cropCode code for crop desired: MZ, WH, SG, SB, AL
#' @param yieldList List of stacks - 1 stack for each crop which includes all years
#' @param irrigationStatus Y or N - needs to be manually matched in input yield list
#' @keywords summarize results yields
#' @export
#' @examples
#' # example forthcoming

# returns data frame
summarizeYieldStacks <- function(cropCode, yieldList, irrigationStatus){
  # extract crop
  yieldStack <- yieldList[[cropCode]]
  # convert to kg per pixel (900m2) to be able to sum total
  yield30 <- yieldStack / 10000 * 900
  totals <- cellStats(yield30, stat = 'sum',na.rm=TRUE)

  # get summary stats kg.ha
  summaryStats <- t(cellStats(yieldStack, stat = 'summary',  na.rm=TRUE))

  # format
  outdf <- data.frame(year = yearsWanted,
                      irrigated = irrigationStatus,
                      crop = cropCode,
                      yield_total_kg = totals,
                      yield_min_kgha = summaryStats[,'Min.'],
                      yield_Q1_kgha = summaryStats[,'1st Qu.'],
                      yield_median_kgha = summaryStats[,'Median'],
                      yield_mean_kgha = summaryStats[,'Mean'],
                      yield_Q3_kgha = summaryStats[,'3rd Qu.'],
                      yield_max_kgha = summaryStats[,'Max.'],
                      stringsAsFactors = FALSE)
  row.names(outdf) <- 1:nrow(outdf)
  return(outdf)
}

#' Annual Water Stats from Spatialized Results
#'
#' Function to extract annual total and summary stats from stacks of annual
#' maps for the specified variable. Returns a data frame with annual totals and
#' per area stats for all years for the specified variable and irrigation status
#' @param varStack stack of annual rasters for variable of interest
#' @param varName name of variable
#' @keywords summarize results water
#' @export
#' @examples
#' # example forthcoming

# returns data frame
summarizeWaterStacks <- function(varStack, varName){

  # convert volumetric raster in cubic meters
  volStack <- varStack / 1000 * 900
  totals <- cellStats(volStack, stat = 'sum',na.rm=TRUE)

  # get summary stats (in orignal mm)

  # if irrigation, don't count 0's
  if(varName == 'irrigation'){
    varStack[varStack == 0] <- NA
  }

  summaryStats <- t(cellStats(varStack, stat = 'summary',  na.rm=TRUE))

  # format
  outdf <- data.frame(year = yearsWanted,
                      variable = varName,
                      totalVolume_m3 = totals,
                      totalVolume_km3 = totals * 1e-6,
                      depth_min_mm = summaryStats[,'Min.'],
                      depth_Q1_mm = summaryStats[,'1st Qu.'],
                      depth_median_mm = summaryStats[,'Median'],
                      depth_mean_mm = summaryStats[,'Mean'],
                      depth_Q3_mm = summaryStats[,'3rd Qu.'],
                      depth_max_mm = summaryStats[,'Max.'],
                      stringsAsFactors = FALSE)
  row.names(outdf) <- 1:nrow(outdf)
  return(outdf)
}






