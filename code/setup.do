clear all
do globals.do                                 // Get relative file paths

loc import_external 0                         // Set this to 1 if you downloaded the data file for the first time

************************************************ EXECUTE *******************************************************************
if `import_external' == 1 do "import.do"      // Populate the external data
do "clean-raw-data.do"
