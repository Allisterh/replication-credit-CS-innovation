clear all
do globals

import fred A939RX0Q048SBEA USRECD, clear
ren A gdpcap
keep if !mi(gdp)
gen dateq = qofd(daten)
format dateq %tq
gen peak = _n if USREC[_n] == 0 & USREC[_n+1] == 1
drop if _n < 8
replace peak = peak[_n-1] if mi(peak)
bysort peak (dateq): gen index = log(gdpcap/gdpcap[1]) * 100
bysort peak (dateq): gen qsincepeak = _n - 1
tw line index qsincepeak if peak == 293 || line index qsincepeak if peak == 244 || line index qsincepeak if peak == 217 ///
|| line index qsincepeak if peak == 175, legend(pos(6) lab(1 "Covid") lab(2 "GFC") lab(3 "Tech Bubble") lab(4 "Clinton") cols(4)) yline(0,lc(black%30)) ///
xtitle("Quarters Since Peak") ytitle("Real GDP Per Capita (Log Deviations from Peak)", size(small)) xlab(0(4)52, labsize(small)) xtick(0(4)52)

graph export "$output/gdp_per_cap.pdf", replace