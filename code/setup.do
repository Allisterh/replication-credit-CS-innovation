clear all
do globals.do                                 // Get relative file paths
do import.do                                  // I wrote a program for importing parts of the data
set timeout1 3600                             // Allow Stata up to an hour to establish a connection
set timeout2 3600                             // Allow Stata up to an hour to download data

************************************************ EXECUTE *******************************************************************
import_data 0 0                                    // All args should be 1 if you downloaded the data for the first time
do "clean-raw-data.do"
