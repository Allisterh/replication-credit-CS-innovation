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
keep if NAICS == "00"                                       // I don't anticipate using industry counts. This may change
drop if NAME == "District of Columbia"                      // My other data do not include