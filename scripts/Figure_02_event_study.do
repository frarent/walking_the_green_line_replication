cap est drop _all

//++++++++++++++++++++++++++++++++++++++++++++
// Figure 2: Event-study estimates — effect of receiving a citation
//           from a government-supported patent on subsequent citation
//           rates of private clean technology patents (CS DiD)
//++++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_event_study", clear

// Construct event-time variable (year of first citation from gvt-supported patent)
gen event_year = year(event_date)
gen y = event_year if treated == 1
replace y = 0 if y == .

// Panel identifiers
egen id = group(patent_id)
xtset id year

// Callaway-Sant'Anna DiD with doubly-robust IPW (dripw)
// long2: use "long" differences relative to period g-1
quietly csdid n_cit, ivar(id) time(year) gvar(y) ///
	method(dripw) wboot rseed(1) long2

// Aggregate to event-study coefficients and store
csdid_estat event, window(-4 5) estore(cs_cit) wboot(reps(10000)) rseed(1)

// Plot event study
csdid_plot, xlabel(-5(1)5) ///
	title("Effect on citation rate — event-study (CS DiD)", size(medium)) ///
	xtitle("Years relative to first citation from government-supported patent") ///
	ytitle("ATT estimate") ///
	yline(0, lcolor(black) lpattern(dash))

graph export "${output_figures}/figure_02_event_study.png", replace width(2000)

est drop _all
