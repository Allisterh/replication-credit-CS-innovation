clear all
do globals.do                                 // Get relative file paths
do programs.do                                // Load in some programs
set timeout1 3600                             // Allow Stata up to an hour to establish a connection
set timeout2 3600                             // Allow Stata up to an hour to download data

************************************************ EXECUTE *******************************************************************
/************
The following just create the dtas that we will later merge together for analysis.
*************/
import_data 0 0                                    // I don't use this data, no need to do anything here.
generate_dta_census 0
clean_balance_sheet 1

/*************
The following merges the datasets generated above and creates new variables to produce the datasets that will be used in 
my regressions.
***************/
merge_dtas 0

