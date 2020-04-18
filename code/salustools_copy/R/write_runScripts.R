#' Make HPCC Shell Files to Run R Scripts for Prep and Run Summaries
#'
#' This function makes a shell script to execute the 03.00_salusXdb_experimentWriter
#' script for MSU's High Performance Computing Cluster -HPCC-. This bash script
#' loads the proper version of R, sets the R library path, and executes the r file.
#' The R file -experiment writer- writes the salus xdb.xml's for the run based on
#' the run parameter file and the set of unique experiments.
#'
#' @param outDir Directory in which to save the output shell sh file. the sh filename is pulled from run filename
#' @param runname Run name for the set of files
#' @param scriptTypeName appended to filename
#' @param hpcBaseDir Directory on HPCC within which are subdirectories for each run
#' @param scriptName Name of R script to run
#' @param walltime For HPCC - how long you expect the job to run. Format HH:MM:SS
#' @param memory For HPCC - how much memory the job will need. ie, '2gb' or '2000mb'
#' @keywords HPCC preparation shell sh
#' @export
#' @examples
#' #set variables

write_HPC_shell_R <- function(outDir, runname, scriptTypeName, hpcBaseDir, scriptName, walltime, memory){
  # set output file to binary encoding (no windows end of lines)
  outFile <- file(paste0(outDir,'/',runname,'_', scriptTypeName, '.sh'), 'wb')

  # PBS stuff
  cat(paste0('#!/bin/sh -login\n',
             '#PBS -l nodes=1:ppn=1,walltime=', walltime, ',mem=', memory, '\n',
             '# Give the job a name.\n',
             '#PBS -N ', runname, '\n',
             '# Send an email when the job is aborted\n',
             '#PBS -m a\n',
             '# Make output and error files the samefile.\n',
             '#PBS -j oe\n',
             '\n',
             '# Change directory to the working directory where your code is located.\n',
             'cd ',hpcBaseDir,'/',runname,'/\n\n',
             '# swap and load the version of R you want.\n',
             'module swap R R/3.2.0\n',
             'export R_LIBS_USER=~/R/library\n\n',
             '# Run R Script without loading or saving workspaces\n',
             'R --vanilla < ', scriptName, '\n'
  ),
  file = outFile)

  close(outFile)
}
