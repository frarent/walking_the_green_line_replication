cap est drop _all

//++++++++++++++++++++++++++++++++++++++++++++
// TABLE 4 - SSIV: Effect of government-sponsored R&D on clean
//           technology spillovers (shift-share IV estimates)
//++++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_SSIV", clear

foreach y of varlist fwd_cits5 cit5_out_nostrict cit5_out_strict ///
	cit5_noself_strict cit5_noself_nostrict cit5_US cit5_country_breadth {

	di in red "**********"
	di in red "***`y'***"
	di in red "**********"

	qui ivreghdfe `y' (procured = SSIV) [w=ipw], ///
		absorb(id_ipc filing_year) vce(robust) first

	est store e_`y'
	estadd scalar obs    = e(N):e_`y'
	estadd local  ipc    "Yes":e_`y'
	estadd local  year   "Yes":e_`y'
	estadd local  reweight "IPW":e_`y'
	estadd local  iv     "SSIV":e_`y'

}

esttab e_* using "${output_tables}/table_04_SSIV.${tab_fmt}", align(center) ///
	keep(procured) ///
	starlevels(+ 0.1 * 0.05 ** 0.01) ///
	order(procured) ///
	varlabels(procured "Gvt R&D (instrumented)") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3))) legend collabels(, none) ///
	stats(ipc year reweight iv obs, labels( ///
	"IPC class FE" "Filing year FE" "Weighting scheme" "Instrument" ///
	"N (Patents)") ///
	fmt(0 0 0 0 0)) ///
	nogaps onecell ///
	title("Table 4: Shift-share IV estimates — effect of government-sponsored R&D on clean technology spillovers") ///
	mtitles("Fwd cit." "Out nostrict" "Out strict" "Noself strict" ///
	"Noself nostrict" "Cit US" "Country breadth") ///
	$tex replace

est drop _all
