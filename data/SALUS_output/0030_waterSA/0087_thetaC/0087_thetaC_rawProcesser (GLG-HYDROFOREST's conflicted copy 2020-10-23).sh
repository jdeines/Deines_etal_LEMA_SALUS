#!/bin/sh -login
#PBS -l nodes=1:ppn=1,walltime=02:10:00,mem=18000mb
# Give the job a name.
#PBS -N 0087_thetaC
# Send an email when the job is aborted
#PBS -m a
# Make output and error files the samefile.
#PBS -j oe

# Change directory to the working directory where your code is located.
cd /mnt/ufs18/home-013/deinesji/salus//0087_thetaC/

# swap and load the version of R you want.
module swap R R/3.2.0
export R_LIBS_USER=~/R/library

# Run R Script without loading or saving workspaces
R --vanilla < 03.70_salusResultsProcesser_rawToSpatial.R
