clear all
do globals

use "$data/descriptive-analysis.dta", clear
gen samp1 = inrange(year, 1982, 2000) & !inlist(state, "South Dakota", "Delaware")
gen time_branching_allowed = max(min(1989 - branch_reform + 1, 7),0)
gen time_merger_allowed = max(min(1989 - interstate_reform + 1, 7), 0)
gen dereg_score = time_branching_allowed + time_merger_allowed

/*******************
QUESTIONS
(1) What did the recovery and expansion from the 1991 recession look like for states conditioning on the proposed
    instrument?
(2) What did the recovery and expansion from the 1982 recession look like for states condition on the proposed
    instrument?

Note: Reigle-Neal was passed in 1994.
*******************/
* First let's see which states were the most aggressive deregulators
frame copy default bars, replace
frame change bars
collapse (mean) dereg_score time_* if samp1, by(state state_abb)
la var dereg_score "Deregulation Score"

* Take a look at the overall distribution
hist dereg_score, frequency xlab(0(1)14,labsize(small)) discrete fcolor(ebblue) color(black) lw(vthin) name(hist_dereg_score)

* Now, what states are behind these frequencies?
loc barcolors ""
foreach i of numlist 1/48 {
    loc barcolors = "`barcolors' bar(`i', color(black) fcolor(ebblue) lw(vthin))"
}

graph bar dereg_score, over(state_abb, sort(dereg_score) label(angle(45) labsize(small))) ytitle("Deregulation Score") ylab(0(1)14, labsize(small)) ///
`barcolors'
