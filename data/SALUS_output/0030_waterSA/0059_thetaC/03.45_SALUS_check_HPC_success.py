####
# Lydia Rill
# updated 11/07/2017
# python 2.7
#
# This script looks at the scratch directory and checks if all the results (each state, chunk, and scenario) exist.
# It also checks to see if the log file end with "completed" or has been stopped unexpectedly with some error. 
# if the result does not exist or does not have the correct variables or the run stopped unexpectedly, 
#   then qsub <name>.sh is written to the bat file redoRuns.bat
####

# modified by J Deines on 8 December 2017 for Jill's runs

import sys
import os
import csv
import subprocess
import numpy
from subprocess import Popen, PIPE, STDOUT


scrdir = "/mnt/scratch/deinesji/salus/0059_thetaC/results/"
outfile = "/mnt/scratch/deinesji/salus/0059_thetaC/redoRuns.bat"
expts = ['X_'+str(num) for num in numpy.arange(1,49)]

base = "ExpID,RID,RcID,Year,DOY,Title"
Day = "SpeciesID,GWAD,IRRC,DRNC,PREC,ETAC,ESAC,EPAC,ROFC"
Sea = "SpeciesID,GWAD"
SeaVars = base + "," + Sea
DayVars = base + "," + Day

logSuccess = "Run completed."

# loop through all the result files 	
with open(outfile, 'w') as out:
    for exp in expts:
      redo = False
      resultS = os.path.join(scrdir, exp + "_seasonal.csv")
      resultD = os.path.join(scrdir, exp + "_daily.csv")
      log = os.path.join(scrdir, exp + "_salus.log")

      #if "sd_3_SC5" not in resultS:
      # Check Seasonal
      if os.path.isfile(resultS):
          with open(resultS, 'r') as f:
              first_line = f.readline()
              first_line = first_line.replace(" ","")
              first_line = first_line.replace("\n","")
          if first_line != SeaVars:
              print("MISSING VARIABLES: " + resultS )
              print("First line", first_line)
              print("Should be ", SeaVars)
              redo = True
      else:
          print(resultS + " DOES NOT EXIST")
          redo = True	
      
      # Check Daily
      if os.path.isfile(resultD):
          with open(resultD, 'r') as f:
              first_line = f.readline()
              first_line = first_line.replace(" ","")
              first_line = first_line.replace("\n","")
          if first_line != DayVars:
              print("MISSING VARIABLES: " + resultD)
              print("First line", first_line)
              print("Should be ", DayVars)
              redo = True
      else:
          print(resultD + " DOES NOT EXIST")
          redo = True
      
      # Check Log
      if os.path.isfile(log):
          #last_line = subprocess.call(['tail', '-2', log])
          f = subprocess.Popen(['tail', '-2', log], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
          last_line = f.stdout.readline()
          #print(last_line)
          if not logSuccess in last_line:
              print("LOG FILE ERROR: " + log)
              print("Last line", last_line)
              redo = True
      else:
          print(log + " DOES NOT EXIST")
          redo = True

      # Write to redoRuns.bat
      if redo:
          qsubResult = "qsub " + exp + ".sh\n"
          out.write(qsubResult)
