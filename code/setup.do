do globals.do     // Get relative file paths

capture {         // Create the data directory
    mkdir $data
}

do import.do      // Populate the data directory