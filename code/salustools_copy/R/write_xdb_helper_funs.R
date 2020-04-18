#' Make Experiment Master Table
#'
#' This function extracts Experiment level parameters from experiment combination
#' strings that have been parsed into soil and weather parameters. Inputs are
#' vectors of the same length, or single values to be repeated for all experiments.
#' Outputs a data frame containing arguments needed for `write_xdb_experiment`.
#' See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options.
#'
#' All other SALUS Experiment parameters are set currently as default.
#' @param runTitle Name of overall run scenario
#' @param ExpID Sequential ID for experiment
#' @param mukey soil mukey from SSURGO
#' @param wthID weather station ID
#' @param ExpCode text string denoting sequence of annual climate-soil-crop-irrigation rotations, separated by '_'
#' @param startyear year to start experiment
#' @param Nyears Number of years in experiment
#' @param startDOY Starting day of year, fills in SDOY parameter
#' @param cropfp Filepath to crop .cdb.xml database file.
#' @param state state, 2-letter abbreviation. defaults to 'KS'
#' @keywords preparation to write experiment parameters
#' @export
#' @examples
#' # Prepare the input using output from 02.21, GetExperiments
#' # Essentially df of ExpID and continuous management string
#' lemaExps <- lemaExps %>%
#'   mutate(nldas = str_sub(ExpCode, start = 10, end = 13),
#'         state = str_sub(ExpCode, start = 1, end = 3),
#'         mukey = str_sub(ExpCode, start = 3, end = 9),
#'         static = str_sub(ExpCode, start = 1, end = 13))
#'
#' # translate mukey, expid, and nldas info into data.frame of Experiment parameters
#' exp_master <- makeExperimentTable('run title', lemaExps$ExpID, lemaExps$mukey,
#'                                   lemaExps$nldas, lemaExps$ExpCode, 2005, 11, 265,
#'                                   'cropsn29Dec2016_SGttMatrFixed.cdb.xml')


makeExperimentTable <- function(runTitle, ExpID, mukey, wthID, ExpCode,
                                startyear, Nyears, startDOY, cropfp,
                                state = 'KS'){
  exptab <- data.frame(ExpID = ExpID,
                       runTitle = runTitle,
                       soilId = paste0(state,mukey),
                       soilfp = paste0(state,'.sdb.xml'),
                       weather = wthID,
                       weatherfp = paste0(wthID,'.wdb.xml'),
                       startYear = startyear,
                       Nyrs = Nyears,
                       startDOY = startDOY,
                       cropfp = cropfp,
                       ExpCode = ExpCode)
  return(exptab)
}


#' Parse Crop Rotations from Experiment String Code
#'
#' This function extracts rotation and management level parameters for
#' one experiment. Outputs a data frame containing year, crop,
#' and irrigation status, along with nldas and soil codes.
#'
#' @param ExpCode One text string denoting sequence of annual climate-soil-crop-irrigation rotations, separated by '_'
#' @param startyear year to start experiment
#' @param cropkey Look up table for CDL crop codes. column names should be 'cropCode' and 'crop'
#' @keywords preparation to write rotation parameters
#' @export
#' @examples
#' # make inputs
#' expCode <- '20266874911230010_20266874911230010_20266874911230010_20266874911231760_20266874911230010_20266874911230610_20266874911230010_20266874911230040_20266874911230240_20266874911230240_20266874911230611'
#' sYear <- 2006
#' cropkey <- data.frame(cropCode = c('001','004','005','024','061','176'),
#'                       crop = c('CORN','SORGHUM','SOYBEANS','WHEAT',
#'                                    'FALLOW','GRASS'))
#'
#' rotations <- parseRotationStrings(expCode, sYear, cropkey)

parseRotationStrings <- function(ExpCode, startyear, cropkey){
  # split experiment string by year
  yearCode <- strsplit(ExpCode, '_')

  # parse year codes into a df of year, crop, management, nldas, soil

  # extract vars
  soil <- substr(yearCode[[1]], start = 1, stop = 9)
  weather <- substr(yearCode[[1]], start = 10, stop = 13)
  crop <- substr(yearCode[[1]], start = 14, stop = 16)
  irr <- substr(yearCode[[1]], start = 17, stop = 17)

  # format into a table
  endyear <- startyear + length(soil) - 1
  outdf <- data.frame(year = startyear:endyear,
                      cropCode = crop,
                      irrStatus = irr,
                      weather = weather,
                      soilkey = soil)
  # add crop name
  outdf2 <- merge(outdf, cropkey, by = 'cropCode')
  # format
  outdf3 <- outdf2[order(outdf2$year),]
  rownames(outdf3) <- 1:nrow(outdf3)
  outdf4 <- outdf3[,c('year','crop','irrStatus','weather','soilkey')]

  # # change grassland to fallow if it's embedded in a crop rotation sequence
  # if(sum(outdf4$crop == 'GRASS') < length(soil)/3){
  #   outdf4[outdf4$crop == 'GRASS','crop'] <- 'FALLOW'
  # }

  # convert crop to character
  outdf4$crop <- as.character(outdf4$crop)

  return(outdf4)

}


