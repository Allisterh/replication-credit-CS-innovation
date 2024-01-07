do globals.do

capture {         // Create the data directory
    mkdir $data
}

do import.do     // Populate the data directory