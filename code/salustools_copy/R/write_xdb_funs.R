#' Write SALUS xdb.xml Top Matter
#'
#' This function initializes a SALUS experiment file by creating the file and
#' initializing the <XDB> tag. Subsequent write_xdb_* functions append information
#' about the experiments and rotational components.
#' @param outFile Full file path for the .xdb.xml to create
#' @keywords create xdb
#' @export
#' @examples
#' # desired file path and file name for the output to be created
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # create output
#' write_xdb_topMatter(fileOut)

write_xdb_topMatter <- function(outFile){
  # write first rows, creates file (no append = true)
  cat('<?xml version="1.0" encoding="utf-8"?>\n<XDB>\n',file=outFile)
}

#' Write SALUS xdb.xml Experiment Level Parameters
#'
#' This function writes the experiment arguments. Subsequent write_xdb_* functions append information
#' about the rotational components. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with write_xdb_rotation,
#' write_xdb_m* (rotation management), and write_xdb_bottomMatter functions to complete the Experiment file.
#'
#' All other SALUS Experiment parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param ExpID Sequential ID for experiment
#' @param RunTitle Title for the experiment
#' @param startYear Starting year of the simulation - SYear parameter
#' @param NYrs Number of model years
#' @param startDOY Starting day of year, fills in SDOY parameter
#' @param StationID Weather Station ID
#' @param Weatherfp Filepath to weather station .wdb.xml file. Currently relative to Experiment file
#' @param SoilID Soil ID
#' @param Soilfp Filepath to soil .sdb.xml file. Currently relative to Experiment file
#' @param Cropfp Filepath to crop .cdb.xml database file. Currently relative to Experiment file
#' @keywords create xdb
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append Experiment parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_experiment(fileOut, ExpID = 1, RunTitle = 'Test', startYear = 2006,
#'                      NYrs = 3, startDOY = 270, StationID = 1001,
#'                      Weatherfp = '1001.wdb.xml', SoilID = 'KS1017570',
#'                      Soilfp = 'KS.sdb.xml', Cropfp = 'cropsn29Dec2016.cdb.xml')

write_xdb_experiment <- function(outFile, ExpID, RunTitle, startYear, NYrs, startDOY,
                                 StationID, Weatherfp,SoilID, Soilfp, Cropfp){

  # write Experiment details - appends to previous file
  cat(paste0('  <Experiment ExpID="', ExpID, '" Title="', RunTitle, '" NYrs="',
             NYrs, '" SYear="', startYear, '" SDOY="', startDOY,
             # some defaults
             '" ISwWat="Y" ISwNit="Y" ISwPho="N" Frop="1" Soilfp="',
             # soil, weather, crop files
             Soilfp, '" SoilID="', SoilID, '" Weatherfp="', Weatherfp,
             '" StationID="', StationID, '" Cropfp="', Cropfp,
             # some defaults
             '" NRrepSq="0" MeEvp="R" MeInf="R" kResOrg="3.914E-5" kSloOrg="0.00013699">\n'),
      file=outFile, append=TRUE)
}


#' Write SALUS xdb.xml Rotation Component Level Parameters
#'
#' This function writes the rotation component arguments. Subsequent write_xdb_m* functions append information
#' about management options. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with
#' write_xdb_m* (rotation management), and write_xdb_bottomMatter functions to complete the Experiment file.
#'
#' All other SALUS Rotation Component parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param OrderNum Order of the treatment. Minimum = 1. 1 will initialize the Rotation_components section
#' @param Title Rotation component title, such as 'maize', 'Wheat'
#' @param IIrrI Irrigation management. 'N' - not irrigated; 'A' - auto profile refill; 'F' - auto with fixed amount; 'R' - reported date, 'Y' - reported doy, 'D' - days after planting
#' @param IferI Fertilizer management. 'N' - not irrigated; 'A' - automatic; 'F' - auto with fixed amount; 'R' - reported date, 'Y' - reported doy, 'D' - days after planting
#' @param ITilI Tillage management. 'N' - no tillage; 'A' - automatic; 'R' - reported; 'Y' - reported doy, 'D' - days after planting
#' @param IHarI Harvest management. A: Automatic; D: Days after Planting; G: At Growth Stages; M: At Maturity R: Reported Date W: Harvest when crop reaches given weight Y: Reported Day of Year
#' @param IResI Residue management
#' @keywords create xdb
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_rotation(outFile = fileOut, OrderNum = 1, Title = 'Wheat', IIrrI = 'N',
#'                    IferI = 'R', ITilI = 'R', 'IHarI' = 'R', IResI = 'A')

write_xdb_rotation <- function(outFile, OrderNum, Title, IIrrI, IferI, ITilI,
                               IHarI, IResI){
  # open rotation components section if position == 'first'
  if(OrderNum == 1){
    cat('    <Rotation_Components>\n', file = outFile, append=TRUE)
  }

  # write rotation details - appends to previous file
  cat(paste0('      <Component OrderNum="', OrderNum, '" Title="', Title,
             '" IPltI="R" IIrrI="', IIrrI, '" IferI="', IferI, '" IResI="', IResI,
             '" ITilI="', ITilI, '" IHarI="', IHarI, '" IEnvI="N">\n'),
      file=outFile, append=TRUE)
}


#' Write SALUS xdb.xml Planting Management for Rotation Component
#'
#' This function writes the planting management arguments after write_xdb_rotation has been run. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS planting parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param CropMod Crop model to be used. C = complex, S = simple. Intermediate I still under development
#' @param SpeciesID Species ID
#' @param CultivarID cultivar ID, only needed for complex crop model
#' @param Year Year of planting - if needed -planting on Reported date; XXXX
#' @param DOY day of year of planting; only needed if planting management is 'R' or 'Y'. Valid range: 1-366
#' @param Ppop Plant population at seeding; plants m^-2
#' @param RowSpc Row spacing, cm
#' @param SDepth planting depth, cm
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, planting managment
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_mPlanting(outFile = fileOut, CropMod = 'C', SpeciesID = 'WH', CultivarID = 'P25R40',
#'                    Year = 2006, DOY = 276, Ppop = 494.21, RowSpc = 19.05)

write_xdb_mPlanting <- function(outFile, CropMod, SpeciesID, cultivar, Year,
                                DOY, Ppop, RowSpc, SDepth, closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Planting CropMod="', CropMod, '" SpeciesID="', SpeciesID,
             '" CultivarID="', cultivar, '" Year="', Year, '" DOY="', DOY,
             '" EYear="" EDOY="" Ppop="',Ppop, '" Ppoe="', Ppop, '" PlMe="S" PlDs="R" RowSpc="',RowSpc, '"',
             ' AziR="" SDepth="', SDepth, '" SdWtPl="" SdAge="" ATemp="" PlPH="" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}


#' Write SALUS xdb.xml Fertlizer Management for Rotation Component
#'
#' This function writes the fertilizer management arguments after write_xdb_rotation has been run. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS fertilizer parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param Year Year of fertilization event - if needed (fertilizing on Reported date); XXXX
#' @param DOY day of year of fertilization event; only needed if fert management is 'R' or 'Y'. Valid range: 1-366
#' @param ANfer amount of nitrogen in fertilizer <- 78.47 # kg / ha
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, fertilizer managment
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_mFertilize(outFile = fileOut, Year = 2007, DOY = 75, ANfer = 78.47)

write_xdb_mFertilize <- function(outFile, Year, DOY, ANfer, closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Fertilizer_App Year="', Year, '" DOY="', DOY,
             '" DAP="" IFType="FE010" FerCode="AP001" FInP="100" DFert="5" ACrbFer="0" ANFer="',
             ANfer, '" APFer="0" AKFer="0" ACFer="0" AOFer="0" FOCod="" FerDecRt="0"',
             ' VolN="0" VolNRate="0" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}

#' Write SALUS xdb.xml AUTO Fertlizer Management for Rotation Component
#'
#' This function writes the fertilizer management arguments after write_xdb_rotation has been run. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS fertilizer parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param DSoilN Application depth, cm, required
#' @param NCode Materian code, required
#' @param SoilNC Threshold, N stress factor, percent, required
#' @param SoilNX Amount per application, kg N per ha, required
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, fertilizer managment
#' @export
#' @examples
#' #' # example forthcoming

write_xdb_mFertilize_Auto <- function(outFile, SoilNC, SoilNX, DSoilN = '5',
                                      NCode = "FE010", closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Fertilizer_Auto DSoilN="', DSoilN, '" NCode="', NCode,
             '" NEnd="" SoilNC="', SoilNC,  '" SoilNX="', SoilNX,'" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}

#' Write SALUS xdb.xml Tillage Management for Rotation Component
#'
#' This function writes the tillage management arguments after write_xdb_rotation has been run.
#' See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS tillage parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param Year Year of tillage event - if using fertilizing on Reported date; XXXX
#' @param DOY day of year of tillage event; only needed if till management is 'R' or 'Y'. Valid range: 1-366
#' @param TDep Tillage depth in cm. Defaults to 10.16
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, tillage managment
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_mTillage(outFile = fileOut, Year = 2007, DOY = 75)

write_xdb_mTillage <- function(outFile, Year, DOY, TDep = 10.16, closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Tillage_App Year="', Year, '" DOY="', DOY,
             '" DAP="" TImpl="TI002" TDep="', TDep, '" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}


#' Write SALUS xdb.xml Irrigation Management for Rotation Component: Auto
#'
#' This function writes the irrigation management arguments after write_xdb_rotation has been run.
#' See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS tillage parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param AIrAm Amount per irrigation if fixed in mm; defaults to "" empty quotes
#' @param DSoil Management depth for irrig. cm. Defaults to 20 cm
#' @param ThetaC Threshold for automatic appl.- percent of max. available w. Defaults to 50
#' @param IAMe Method for automatic appl. defaults to 'IR004' for sprinkler
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, tillage managment
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_mTillage(outFile = fileOut)

write_xdb_mIrrigate_Auto <- function(outFile, AIrAm = '', DSoil = 20, ThetaC = 50,
                                     IAMe = 'IR004', closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Irrigation_Auto AIrAm="', AIrAm, '" DSoil="', DSoil,
             '" EffIrr="" IAMe="', IAMe, '" IEPt="" IOff="" ThetaC="',
              ThetaC, '" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}




#' Write SALUS xdb.xml Harvest Management for Rotation Component: At Maturity
#'
#' This function writes the harvest management arguments after write_xdb_rotation has been run. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS fertilizer parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param HKnDnPc Harvest knock-down percent between 0 and 100. Defaults to 100. Percent of stalk/leaves knocked down at harvest.
#' @param HBPc Percent of byproduct harvested between 0 and 100. Defaults to 0. basically how much of the leaves/stem to you want to remove from the field
#' @param HPc Harvest percentage between 0 and 100. Defaults to 100.
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, fertilizer managment
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_mHarvest(outFile = fileOut)


write_xdb_mHarvest_maturity <- function(outFile, HKnDnPc = 100, HBPc = 0, HPc = 100, closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Harvest_App Year="" DOY="" DAP="" HStg="" HCom="H" ',
             'HSiz="" HPc="',HPc, '" HBmin="0" HBPc="', HBPc, '" HKnDnPc="', HKnDnPc, '" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}



#' Write SALUS xdb.xml Harvest Management for Rotation Component: Reported Date
#'
#' This function writes the harvest management arguments after write_xdb_rotation has been run. See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. This function should be followed with additional
#' write_xdb_m* (rotation managements), and write_xdb_bottomMatter functions to complete the Experiment file.
#' Includes an option to close the rotation compoment if this is the last management specified.
#'
#' All other SALUS fertilizer parameters are set currently as default.
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param Year Year of harvest event - if needed (harvesting on Reported date); XXXX
#' @param DOY day of year of harvest event; only needed if harvest management is 'R' or 'Y'. Valid range: 1-366
#' @param closeComponent 'Y' or 'N' . Should the rotation component be closed? defaults to 'N'
#' @keywords create xdb, fertilizer managment
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_mHarvest(outFile = fileOut, Year = 2007, DOY = 178)

write_xdb_mHarvest_reported <- function(outFile, Year, DOY, closeComponent = 'N'){
  # write management details - appends to previous file
  cat(paste0('        <Mgt_Harvest_App Year="', Year, '" DOY="', DOY,
             '" DAP="" HStg="" HCom="H" HSiz="" HPc="100" HBmin="0" HBPc="0" HKnDnPc="100" />\n'),
      file=outFile, append=TRUE)

  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }
}

#' Close SALUS xdb.xml by writing end elements
#'
#'This
#'
#' This functioncloses elements and/or writes version control information after the
#' rotation and management has been written See http://salusmodel.glg.msu.edu/salus.ddb.xml for more
#' information about SALUS parameter options. Can be used to close the file completely, or close a
#' component or Experiment before writing additional ones.
#'
#' @param outFile Full file path for an existing .xdb.xml to appended to, created with write_xdb_topMatter
#' @param closeComponent Close out a rotation component. 'Y' or 'N'; default is 'N'
#' @param closeRotation Close out a rotation. 'Y' or 'N'; default is 'N'
#' @param closeExperiment Close out an Experiment. 'Y' or 'N'; default is 'N'
#' @param writeVersion write the version control elements. 'Y' or 'N'; default is 'N'
#' @param closeXDB Close out the XDB file. 'Y' or 'N'; default is 'N'
#' @keywords create xdb, close xdb, experiment file
#' @export
#' @examples
#' # file path to existing .xdb.xml file created by write_xdb_topMatter
#' fileOut <- 'C:/Users/deinesji/1PhdJill/test.xdb.xml'
#'
#' # append rotation component parameters to .xdb.xml; numeric parameters can be character or numeric
#' write_xdb_bottomMatter(outFile = fileOut, closeComponent = 'N', closeRotation = 'N',
#'                        closeExperiment = 'N', writeVersion = 'N', closeXDB = 'N')

write_xdb_bottomMatter<- function(outFile, closeComponent = 'N', closeRotation = 'N',
                                  closeExperiment = 'N', writeVersion = 'N',
                                  closeXDB = 'N'){
  # close component if specified
  if(closeComponent == 'Y'){
    cat('      </Component>\n', file=outFile, append=TRUE)
  }

  # close rotation if specified
  if(closeRotation == 'Y'){
    cat('    </Rotation_Components>\n', file=outFile, append=TRUE)
  }

  # close experiment if specified
  if(closeExperiment == 'Y'){
    cat('  </Experiment>\n', file=outFile, append=TRUE)
  }

  # add version control info if specified
  if(writeVersion == 'Y'){
    cat(paste0('  <Version_Control>\n', '    <Version Number="1">\n',
               '      <ReleaseDate>1999-11-26</ReleaseDate>\n',
               '      <Notes>Initial release, beta version.</Notes>\n',
               '    </Version>\n','    <Version Number="1.1">\n',
               '      <ReleaseDate>1999-11-27</ReleaseDate>\n',
               '      <Notes>testing...</Notes>\n',
               '    </Version>\n','    <Version Number="1.2">\n',
               '      <ReleaseDate>2011-06-07</ReleaseDate>\n',
               '      <Notes>Added harvest parameters HBpc and Hbmin</Notes>\n',
               '    </Version>\n','    <Version Number="1.3">\n',
               '      <ReleaseDate>2012-12-13</ReleaseDate>\n',
               '      <Notes>Added Relative File Path Flag (RelPath) -- B.D. Baer </Notes>\n',
               '    </Version>\n','    <Version Number="X_1.1">\n',
               '      <ReleaseDate>2014-03-20</ReleaseDate>\n',
               '      <Notes>Automatically converted from Access DB by salus_access2xml program.</Notes>\n',
               '    </Version>\n','  </Version_Control>\n'),
        file=outFile, append=TRUE)
  }

  # close XDB
  if(closeXDB == 'Y'){
    cat('</XDB>\n', file=outFile, append=TRUE)
  }

}

