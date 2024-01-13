clear all
do globals.do                                 // Get relative file paths
do programs.do                                // Load in some programs
set timeout1 3600                             // Allow Stata up to an hour to establish a connection
set timeout2 3600                             // Allow Stata up to an hour to download data

************************************************ EXECUTE *******************************************************************
import_data 0 0                                    // I don't use this data, no need to do anything here.
generate_dtas_patentsview 1                        // If it is your first time runnning after cloning, change the 0 to 1
generate_dta_census 1
do "clean-raw-data.do"
