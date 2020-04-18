#' Spatialize SALUS Results: Grassland override
#'
#' Takes the processed annual results from SALUS and turns into a spatial raster,
#' based on the Experiment IDs - EXpID - and gridcell keys. Requires tidyverse,
#' raster, and rgdal. Then overrides all grassland classes with 1% of annual precip.
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

spatializeGrass <- function(expt_df0, variable, year, gridkey, template, aoi){

  # replace all grass species (PA) and NA's (??) recharge with 1% of precip
  expt_df <- expt_df0 %>%
    rename(drncOrig = DRNC_mm) %>%
    mutate(grassDrnc = PREC_mm * 0.01) %>%
    mutate(DRNC_mm = if_else(SpeciesID == 'PA' | is.na(SpeciesID), grassDrnc, drncOrig)) %>%
    # reorder columns
    dplyr::select(c(ExpID, Year, SpeciesID, GWAD, IRRC_mm, DRNC_mm, PREC_mm, ETAC_mm,
                    ESAC_mm, EPAC_mm, ROFC_mm, irrigation))

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
spatializeAll_grass <- function(expt.df, variable, yearsWanted, gridkey, template, aoi,
                          writeOut = 'N', outFolder = ''){
  rasList <- list()
  for(year in yearsWanted){
    rasName <- as.character(year)
    ras <- salustools::spatializeGrass(expt.df, variable, year,
                                  gridkey, template,aoi)
    if(writeOut == 'Y'){
      fname <- paste0(outFolder, '/',variable, '_',year, '.tif')
      writeRaster(ras, file = fname)
    }
    rasList[[rasName]] <- ras
  }
  rasStack <- stack(rasList, quick = TRUE)
}




