program import_data

    args USPTO PatentsView

    /*****************
    Import US Patent data. The downside to unzipping files in Stata is that I can only unzip to the current
    directory. I hope this changes in the future!
    *****************/
    if `USPTO' {
        cd $data
        unzipfile "https://bulkdata.uspto.gov/data/patent/assignment/economics/2022/dta.zip", replace
        cd $code
    }

    * Import the Patentsview data
    if `PatentsView' {
        cd $data
        unzipfile "https://s3.amazonaws.com/data.patentsview.org/download/g_patent.tsv.zip", replace
        unzipfile "https://s3.amazonaws.com/data.patentsview.org/download/g_location_disambiguated.tsv.zip", replace
        unzipfile "https://s3.amazonaws.com/data.patentsview.org/download/g_assignee_disambiguated.tsv.zip", replace
        cd $code
    }
end

program generate_dtas_patentsview

    /* 
    The USPTO data is large. So I am going to load it chunks and merge the chunks.

    You will need xframeappend and chunky installed:
    > ssc install xframeappend
    > ssc install chunky
    */
    args YesOrNo
    loc chunksize 0.2 GB
    
    if `YesOrNo' {

        chunky using "$data/g_patent.tsv", replace chunksize(`chunksize') header(include) ///
        stub("$data/g_patent_chunk")

        chunky using "$data/g_inventor_disambiguated.tsv", replace chunksize(`chunksize') head(include) ///
        stub("$data/g_inventor_chunk")

        /* 
        Now, for every inventor file, loop through every patent file, exectuting a merge at each step. To analyze
        the success of the total merge, I need to save the number of matches at each loop and keep a running
        tally.
        */
        
        clear frames                  // Resetting the frames memory
        loc matched = 0
        loc inventor_files: dir "$data" files "g_inventor_chunk*"
        loc patent_files: dir "$data" files "g_patent_chunk*"
        frame create chunk
        foreach inventor_file in `inventor_files' {

            frame chunk {

                import delimited "$data/`inventor_file'", clear varnames(1)

                foreach patent_file in `patent_files' {

                    merge m:1 patent_id using "$data/`patent_file'", keep(1 3)
                    qui summ _merge if _merge == 3
                    loc mathced = `matched' + `r(N)'
                    drop _merge
                }
            }

            xframeappend chunk, fast
            di "Appended `inventor_file'"
        }
        
    }
end

program generate_dta_census

    args YesOrNo
    
    if `YesOrNo' {

        /************************************************************************************************
        This code cleans up the census data by state.
        ************************************************************************************************/
        * Census business dynamics
        import delimited "$data/BDSTIMESERIES.BDSGEO-Data.csv", clear
        cap drop v32                                                // Random empty column at the end

        * The first row are varnames and the second are  the corresponding labels. Let's clean this up a bit
        ds
        loc varcount: word count `r(varlist)'
        di `varcount'
        foreach i of numlist 1/`varcount' {

            loc varname = v`i'[1]
            loc varlab  = v`i'[2]
            
            
            ren v`i' `varname'
            lab var `varname' "`varlab'"

        }
        keep if _n > 2                                              // No longer need these

        * Now let's fix the data types
        ds GEO_ID NAME NAICS NAICS_LABEL METRO METRO_LABEL, not
        foreach i in `r(varlist)' {
            destring `i', replace force
        }
        keep if NAICS == "00"                                       // Keep only the all industry totals
        order NAME time
        save "$data/census-geography-clean.dta", replace

        /************************************************************************************************
        Depending on how the project evolves, below this will clean the firm/establishment data by
        different conditioning (age,size,init age)
        ************************************************************************************************/
    }

end

program clean_balance_sheet

    args YesOrNo

    if `YesOrNo' {
        
        use "$data/call-report.dta", clear
        
        * Format dates
        tostring RSSD9999, replace
        ren RSSD9999 datestr
        gen dated = date(datestr,"YMD")
        format dated %td
        la var dated "Date"
        drop datestr
        gen year = yofd(dated)
        gen dateq = qofd(dated)
        format dateq %tq

        tostring RSSD9950, replace
        ren RSSD9950 dateopen_str
        gen dated_open = date(dateopen_str, "YMD")
        format dated_open %td
        la var dated_open "Opening Date"
        drop dateopen_str

        * Some other identifiers
        ren RSSD9010 entity_name
        la var entity_name ""
        ren RSSD9130 entity_city
        la var entity_city ""
        ren RSSD9200 state_abb
        la var state_abb ""
        ren RSSD9220 entity_zipcode
        la var entity_zipcode ""
        ren RSSD9001 id
        
        * I will make some time series following "notes on making consistent time series."
        gen loans = RCFD1400
        replace loans = loans + RCFD2165 if dateq < tq(1984q1)

        gen loans_net = RCFD2122
        replace loans_net = loans_net + RCFD2165 if dateq < tq(1984q1)

        gen CI_loans = RCFD1600

        gen quarter = substr(string(dateq, "%tq"),6,1)
        keep if quarter == "3" // I keep the 3rd quarter because this is when the economy went into recession in 1990.

        collapse (sum) loans loans_net CI_loans, by(state_abb year)
        drop if inlist(state_abb,"XX","PI")
        loc vars "loans loans_net CI_loans"
        foreach i in `vars' {
            replace `i' = `i'/10^6
        }
        la var loans "Total Bank Lending (Gross, Millions $)"
        la var loans_net "Total Bank Lending (Net, Millions $)"
        la var CI_loans "Total Commercial and Indsutrial Lending (Millions $)"

        save "$data/call-report-clean.dta", replace
    }
end

program merge_dtas

    args DeregAndReallocation

    if `DeregAndReallocation' {
        use "$data/census-geography-clean.dta", clear
        ren NAME state_name
        merge m:1 state_name using "$data/reforms.dta", nogen
        ren state state_abb
        ren state_name state
        ren time year
        order state state_abb year branch_reform interstate_reform
        ds GEO_ID NAICS NAICS_LABEL METRO METRO_LABEL statefip, not
        keep `r(varlist)'

        * Grab NBER recession dates - make sure you have a frekey and set it on your device. See "help import fred"
        frame create NBER
        frame NBER {

            import fred USRECQ
            gen year = yofd(daten)
            egen rectotal = total(USRECQ), by(year)
            gen rec = rectotal > 0
            collapse (mean) rec, by(year)
            la var rec "NBER Recession Year"

        }
        frlink m:1 year, frame(NBER)
        frget rec, from(NBER)
        frame drop NBER
        drop NBER
        order state state_abb year rec branch_reform interstate_reform

        save "$data/descriptive-analysis.dta", replace
    }
end