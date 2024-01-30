clear all
do globals

use "$data/descriptive-analysis.dta", clear
gen samp1 = inrange(year, 1982, 2001) & !inlist(state, "South Dakota", "Delaware")
gen samp2 = inrange(year, 1980, 2001) & !inlist(state, "South Dakota", "Delaware")
gen samp_rec = inrange(year, 1990, 2001) & !inlist(state, "South Dakota", "Delaware")
gen time_branching_allowed = max(min(1990 - branch_reform + 1, 9),0)
gen time_merger_allowed = max(min(1990 - interstate_reform + 1, 9), 0)
gen dereg_score = time_branching_allowed + time_merger_allowed

************************************************************
* First let's see which states were the most aggressive deregulators
frame copy default bars, replace
frame change bars
collapse (mean) dereg_score time_* if samp1, by(state state_abb)
qui summ dereg_score, d // I will use this in the next section where I look at state aggregates
glo med = `r(p50)'
la var dereg_score "Deregulation Score"

* Take a look at the overall distribution
hist dereg_score, frequency xlab(0/18,labsize(small)) discrete fcolor(ebblue) color(black) lw(vthin) name(hist_dereg_score)

* Now, what states are behind these frequencies?
loc barcolors ""
foreach i of numlist 1/48 {
    loc barcolors = "`barcolors' bar(`i', color(black) fcolor(ebblue) lw(vthin))"
}

graph bar dereg_score, over(state_abb, sort(dereg_score) label(angle(45) labsize(small))) ytitle("Deregulation Score") ylab(, labsize(small)) ///
`barcolors' name(state_dereg_scores)

graph combine hist_dereg_score state_dereg_scores, rows(2) cols(1) name(score_summary)
graph drop hist_dereg_score
graph drop state_dereg_scores

************************************************************
* Next, lets look at trends in credit aggregates by treatment groups
frame copy default credit, replace
frame change credit
frame drop bars
keep if samp2
gen low = dereg_score <= $med
collapse (mean) loans_net, by(year low)
bysort low (year): gen indexed = loans/loans[1]
tw scatter indexed year if low == 0, ms(Dh) c(direct) || scatter indexed year if low == 1, ms(Dh) c(direct) ///
legend(lab(1 "Early Deregulators") lab(2 "Late Deregulators") ring(0) pos(11)) ytitle("Total Loans (Indexed to 1980 Value)") ///
xlab(1980(2)2001, angle(45) labsize(small)) xtitle("") name(credit_aggregate_by_dereg)

frame change default
frame drop credit
************************************************************
* Now study the firm dynamics outcomes - a lot of the action here happens in flows and rate rather than levels. So I won't be looking at
* levels indexed to their peak values.
frame copy default fd, replace
frame change fd
keep if samp_rec
gen low = dereg_score <= $med
collapse (sum) EMP JOB_CREATION JOB_DESTRUCTION NET_JOB_CREATION ESTABS_ENTRY ESTABS_EXIT, by(year low)
gen NET_ESTAB_ENTRY = ESTABS_ENTRY - ESTABS_EXIT
loc outcomes "EMP"
loc labels "Total Employees"
loc length = wordcount("`outcomes'")
foreach i of numlist 1/`length' {
    loc var_name: word `i' of `outcomes'
    loc var_lab: word `i' of "`labels'"
    bysort low (year): gen indexed_`var_name' = log(`var_name'/`var_name'[1])
    tw scatter indexed_`var_name' year if low == 0, c(direct) ms(Dh) || scatter indexed_`var_name' year if low == 1, c(direct) ms(Dh) ///
    name(`var_name'_indexed) ytitle("`var_lab'") legend(lab(1 "Early Deregulators") lab(2 "Late Deregulators") pos(6)) xtitle("") xlab(1990(2)2001, angle(45) labsize(small)) ///
    yline(0,lc(black%50))
    drop indexed_`var_name' 
}

loc outcomes "ESTABS_ENTRY ESTABS_EXIT NET_ESTAB_ENTRY JOB_CREATION JOB_DESTRUCTION NET_JOB_CREATION"
loc labels "Establishment Entry (Thousands)" "Establishment Exit (Thousands)" "Net Establishment Entry (Thousands)" "Job Creation (Thousands)" "Job Destruction (Thousands)" "Net Job Creation (Thousands)"
loc length = wordcount("`outcomes'")
foreach i of numlist 1/`length' {
    loc var_name: word `i' of `outcomes'
    loc var_lab: word `i' of "`labels'"
    replace `var_name' = `var_name'/10^3
    tw scatter `var_name' year if low == 0, c(direct) ms(Dh) || scatter `var_name' year if low == 1, c(direct) ms(Dh) ///
    name(`var_name') ytitle("`var_lab'") legend(lab(1 "Early Deregulators") lab(2 "Late Deregulators") pos(6)) xtitle("") xlab(1990(2)2001, angle(45) labsize(small)) ///
    yline(0,lc(black%50))
    drop `var_name'
}

* Let's look at these series in rates now
frame copy default fd, replace
keep if samp_rec
gen low = dereg_score <= $med
gen NET_ESTAB_RATE = ESTABS_ENTRY_RATE - ESTABS_EXIT_RATE
collapse (mean) *_RATE [fw=EMP], by(year low)

tw scatter NET_ESTAB_RATE year if low == 0, c(direct) ms(Dh) || scatter NET_ESTAB_RATE year if low == 1, c(direct) ms(Dh) ///
name(NET_ESTAB_RATE) ytitle("Net Est. Entry Rate") legend(lab(1 "Early Deregulators") lab(2 "Late Deregulators") pos(6)) xtitle("") xlab(1990(2)2001, angle(45) labsize(small))

tw scatter NET_JOB_CREATION_RATE year if low == 0, c(direct) ms(Dh) || scatter NET_JOB_CREATION_RATE year if low == 1, c(direct) ms(Dh) ///
name(NET_JOB_CREATION_RATE) ytitle("Net Job Creation Rate") legend(lab(1 "Early Deregulators") lab(2 "Late Deregulators") pos(6)) xtitle("") xlab(1990(2)2001, angle(45) labsize(small))

graph combine NET_ESTAB_RATE NET_JOB_CREATION_RATE, cols(1) rows(2) name(fd_rates)
*********************************************************** save graphs
loc graphs "score_summary credit_aggregate_by_dereg fd_rates"

foreach gph in `graphs' {
    graph export "$output/`gph'.pdf", replace name(`gph')
}
