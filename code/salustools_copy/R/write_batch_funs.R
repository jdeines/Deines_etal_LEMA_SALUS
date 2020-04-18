#' Make HPCC Shell Files to Run Xdbs
#'
#' This function makes a shell script to defining experiment runs for MSU's High
#' Performance Computing Cluster (HPCC). This bash script copies the files needed
#' to run SALUS (salus_gnu, gdb, cdb, sdb, xdb, and wdb files) to the current
#' directory. Then the bash script will run SALUS. Then the bash script will remove
#' the SALUS files from the current directories.Then the bash script will copy
#' the SALUS results to your scratch directory. Modified from python writeTorque
#' function by Brian Baer and Lydia Rill.
#'
#' Recommended to follow this with the `write_HPCC_bat` function in order to
#' generate the batch bat file that will submit multiple shell files to the HPCC queue.
#'
#' @param shDir Directory in which to save the output shell sh file. the sh filename is pulled from xdb filename
#' @param hpcHomeDir Directory on HPCC in which source files reside for this run (sdb, xdb, zipped weather, etc). Should end in a forward slash
#' @param hpcOutDir Directory on HPCC to write results to, Should end in a forward slash
#' @param Nflag '-w' or '-wn'.  -w runs SALUS without considerations of N stress
#' @param xdb filename of the experiment file, without extension. sh name will be pulled from this.
#' @param sdb filename of the soil file (no path, no .sdb.xml extension)
#' @param wdbZip filename of the zipped weather file. Script will unzip on the node
#' @param DayVars CSV string of SALUS daily variables to return
#' @param SeaVars CSV string of SALUS seasonal variables to return
#' @param walltime For HPCC - how long you expect the job to run. Format HH:MM:SS
#' @param memory For HPCC - how much memory the job will need. ie, '2gb' or '2000mb'
#' @param cdb filename of the crop cdb.xml file, without the extension
#' @keywords HPCC preparation shell sh
#' @export
#' @examples
#' #set variables
#' shDir <- 'C:/Users/deinesji/Dropbox/1PhdJill/hpa/LEMAs/SALUS/testHPCCrun'
#' hpcHomeDir <- '/mnt/home/deinesji/Example_SALUS_wheat/'
#' hpcOutDir <- '/mnt/home/deinesji/Example_SALUS_wheat/results/'
#' xdb <- 'lema_wheat_continuous'
#' sdb <- "KS"
#' wdbZip <- 'testHPCCrun.tar.gz'
#' DayVars <- 'ExpID,Title,SpeciesID,GWAD,IRRC,CWAD,DRNC,PREC,LAI'
#' SeaVars <- 'ExpID,Title,SpeciesID,GWAD,IRRC,CWAD,DRNC,PREC'
#' walltime <- '01:00:00'
#' memory <- '2000mb'
#'
#' write_HPC_shell(shDir, hpcHomeDir, hpcOutDir, xdb, sdb, wdbZip, DayVars,
#'                 SeaVars, walltime, memory)

write_HPC_shell <- function(shDir, hpcHomeDir, hpcXdbDir, hpcOutDir, Nflag, xdb,
                            sdb,wdbZip,DayVars,SeaVars, walltime, memory, cdb){
  # set output file to binary encoding (no windows end of lines)
  outFile <- file(paste0(shDir,'/',xdb,'.sh'), 'wb')

  # PBS stuff
  cat(paste0('#!/bin/sh -login\n',
             '#PBS -l nodes=1:ppn=1,walltime=', walltime, ',mem=', memory, '\n',
             '# Give the job a name.\n',
             '#PBS -N ', xdb, '\n',
             '# Send an email when the job is aborted\n',
             '#PBS -m a\n',
             '# Make output and error files the samefile.\n',
             '#PBS -j oe\n',
             '\n',
             '# Change directory to the TMPDIR which is the local temp disk storage unique to each node and each job.\n',
             'cd ${TMPDIR}\n',
             'module load GNU/5.2\n\n',
             '# Copy the config files to the node\n',
             'cp -r -L ', hpcHomeDir, 'salus_gnu .\n',
             'cp -r -L ', hpcHomeDir, 'salus.gdb.xml .\n',
             'cp -r -L ', hpcHomeDir, cdb, '.cdb.xml .\n',
             'cp -r -L ', hpcHomeDir, sdb, '.sdb.xml .\n',
             'cp -r -L ', hpcHomeDir, wdbZip, ' .\n',
             'tar -xzf ', wdbZip,'\n',
             'cp -r -L ', hpcXdbDir, xdb, '.xdb.xml .\n\n',
             '# Run SALUS\n',
             './salus_gnu ', Nflag, ' xdb="', xdb, '.xdb.xml" file1="', xdb, '_daily.csv" ',
             'freq1="1" vars1="', DayVars, '" file2="', xdb, '_seasonal.csv" ',
             'freq2="season" vars2="', SeaVars, '" msglevel="status" > "',
             xdb, '_salus.log"\n\n',
             '# Remove the config files from the node (everything except the results). This may not be necessary since the TMPDIR is deleted after the job.\n',
             'rm salus_gnu\n',
             'rm salus.gdb.xml\n',
             'rm ', cdb, '.cdb.xml\n',
             'rm ', sdb, '.sdb.xml\n',
             'rm *.wdb.xml\n',
             'rm ', wdbZip, '\n',
             'rm ', xdb, '.xdb.xml\n\n',
             '# Move the result files to the output directory.\n',
             'mv ', xdb, '_daily.csv ', hpcOutDir, '\n',
             'mv ', xdb, '_seasonal.csv ', hpcOutDir, '\n',
             'mv ', xdb, '_salus.log ', hpcOutDir, '\n'
             ),
      file = outFile)

  close(outFile)
}



#' Make HPCC Batch Files to run all experiments in run
#'
#' This function makes a bash script to execute queue submissions to MSU's High
#' Performance Computing Cluster (HPCC).
#'
#' @param sh_vector A vector of sh shellscripts written by
#' @param outFile Path and filename with which to save the output bat file
#' @keywords HPCC preparation batch bat
#' @export
#' @examples
#' # function arguments
#' shNames <- paste0('test_',1:10,'.sh')
#' fileOut <- 'C:/Users/deinesji/Dropbox/1PhdJill/hpa/LEMAs/SALUS/testHPCCrun/test.bat'
#'
#' # write out .bat file
#' write_HPC_bat(shNames, fileOut)

write_HPC_bat <- function(sh_vector, outFile){
  fileCon <- file(outFile, 'wb')

  # write one qsub command per line
  cat(paste('qsub ', sh_vector, '\n', sep='', collapse=''),
      file = fileCon)

  close(fileCon)
}


