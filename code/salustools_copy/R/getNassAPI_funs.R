#' State Fips Lookup
#'
#' joins table of Fips by either stateName or stateAbbrev. requires dplyr. 
#' 
#' @param statesWanted data frame with a column either 'StateName' or 'StateAbbrev' for states of interest
#' @export
#' @examples
#' 

getStateFips <- function(statesWanted){
  library(dplyr)
  output <- statesWanted %>% left_join(stateFipsLookup)
  return(output)
}




#' Extract NASS data by county from API
#'
#' Downloads NASS crop data by requested county, program source, and short desc
#' 
#' @param apiKey Personal key; Obtained from http://quickstats.nass.usda.gov/api
#' @param program 'CENSUS' or 'SURVEY'
#' @param shortDesc short description of desired data field; aka 'Data Item'
#' @param state state 2 digit fips
#' @param county county 3-digit ANSI code. To get all counties in state, set to NA.
#' @param year year to start getting data - gets all subsequent years. default is 1996 to get all Census
#' @keywords NASS county
#' @export
#' @examples
#' 
#' 
#' # set up variables for data calls
#' apiKey <- '28EAA9E6-8062-34A4-981A-B2ED4692228A' # my code, modified
#' program = 'CENSUS'
#' shortDesc <- 'AG LAND, CROPLAND - ACRES'
#' state <- '08'
#' county <- '001'
#' 
#' # simple example
#' oneCounty <- getNassCounty(apiKey, program, shortDesc, state, county)
#' 
#' # data frame of states and counties:
#' # make empty list to populate, and loop through counties
#' nass.list <- list()
#' for(i in 1:nrow(counties)){
#'   nass.list[[i]] <- getNASS(apiKey, program, sector, group, shortDesc, aggregation, 
#'                                 state = counties$abb[i],
#'                                 county = counties$COUNTYFP[i])
#' }
#' # convert list of data frames to 1 giant dataframe
#' nass.df <- do.call("rbind",nass.list) 
#' 

getNassCounty_short <- function(apiKey, program, shortDesc, state, county, year = 1996){
  library(httr)
  library(jsonlite)
  # build URL query
  baseurl <- 'http://quickstats.nass.usda.gov/api/api_GET'
  format = 'JSON'
  
  # if county supplied, download by specified counties
  if(!is.na(county)){
    GETrequest <- paste0(baseurl,
                         '/?key=',apiKey,
                         '&source_desc=',program,
                         '&short_desc=', shortDesc,
                         '&agg_level_desc=','COUNTY',
                         '&state_fips_code=', state,
                         '&county_ansi=', county,
                         '&year__GE=',year,
                         '&format=',format)
  } else if (is.na(county)){
    GETrequest <- paste0(baseurl,
                         '/?key=',apiKey,
                         '&source_desc=',program,
                         '&short_desc=', shortDesc,
                         '&agg_level_desc=','COUNTY',
                         '&state_fips_code=', state,
                         '&year__GE=',year,
                         '&format=',format)
  }
    
  # if present, replace commas and spaces in url with encodings
  if(grepl(" ", GETrequest))  GETrequest <- gsub(" ", "%20", GETrequest)
  if(grepl(",", GETrequest))  GETrequest <- gsub(",", "%2C", GETrequest)
  
  # retrive data
  req <- GET(GETrequest)
  # check status and throw stop/error: 200 means successful
  stop_for_status(req)
  # extract content
  json <- content(req, as = 'text', encoding = 'UTF-8')
  # convert from JSON and extract df from list object
  outputdf <- fromJSON(json)[[1]]
}


#' Extract NASS data by county from API - the whole shebang
#'
#' Downloads NASS crop data by requested county, program source. Intended to retrieve 
#' all of the field crop data for a county, to be parsed by user.
#' 
#' @param apiKey Personal key; Obtained from http://quickstats.nass.usda.gov/api
#' @param program 'CENSUS' or 'SURVEY'
#' @param sector ie 'CROPS'
#' @param group ie 'FIELD CROPS'
#' @param state state 2 digit fips
#' @param county county 3-digit ANSI code
#' @keywords NASS county
#' @export
#' @examples

getNassCounty_fc <- function(apiKey, program = 'CENSUS', sector = 'CROPS', group = 'FIELD CROPS', state, county){
  library(httr)
  library(jsonlite)
  
  # build URL query
  baseurl <- 'http://quickstats.nass.usda.gov/api/api_GET'
  format = 'JSON'
  GETrequest <- paste0(baseurl,
                       '/?key=',apiKey,
                       '&source_desc=',program,
                       '&sector_desc=',sector,
                       '&group_desc=',group,
                       '&agg_level_desc=','COUNTY',
                       '&state_fips_code=', state,
                       '&county_ansi=', county,
                       '&format=',format)
  
  # if present, replace commas and spaces in url with encodings
  if(grepl(" ", GETrequest))  GETrequest <- gsub(" ", "%20", GETrequest)
  if(grepl(",", GETrequest))  GETrequest <- gsub(",", "%2C", GETrequest)
  
  # retrive data
  req <- GET(GETrequest)
  # check status and throw stop/error: 200 means successful
  stop_for_status(req)
  # extract content
  json <- content(req, as = 'text', encoding = 'UTF-8')
  # convert from JSON and extract df from list object
  outputdf <- fromJSON(json)[[1]]
}