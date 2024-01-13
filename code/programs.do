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
    The USPTO data is large. So I am going to load it chunks and merge the chunks. I also only look at utility patents. If you want to include a broader
    set of patents, this is the place you can change that.

    Note: You will need to
    > ssc install chunky
    */
    args YesOrNo

    if `YesOrNo' {
        
    }

end

program generate_dta_census

    args YesOrNo
    
    if `YesOrNo' {
        * Census business dynamics
        import delimited "$data/BDSTIMESERIES.BDSGEO-Data.csv", clear
        cap drop v32                                                // Random empty column at the end?

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
        drop if NAME == "District of Columbia"                      // My other data do not include
        save "$data/census-clean.dta", replace
    }

    end
end