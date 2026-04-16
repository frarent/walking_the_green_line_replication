
//+++++++++++++++++++++++++++++++++++++++++++
// (1) DBS FOR TABLES AND FIGURES IN THE MAIN TEXT
//+++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++
// (1.a) FULL SAMPLE 
//+++++++++++++++++++++++++++++++++++++++++++

import delimited "${raw_data_path}/db_full.csv", varnames(1) encoding(ISO-8859-2) ///
	case(preserve) clear

label var id "patent id (random) i"
label var id_applicant "applicant id (random) j"
label var n_pat "# of patents for applicant j"
label var gvtRD "whether patent i has received gvt funding"
label var nb_applicants "# of applicants for patent i"
label var nb_inventors "# of inventors for patent i"
label var fwd_cits5 "# of five-year forward citations"
label var fwd_cits7 "# of seven-year forward citations"
label var originality "originality index (Hall et al., 2001)"
label var amount_tot "amount og gvt R&D received ($)"
label var granting_year "grant year"
label var filing_year2 "filing year"
label var cit7_noself_nostrict "# of seven-year forward citations removing self-citations"
label var cit7_noself_strict "# cit removing any applicant citation"
label var cit7_out_nostrict "# cit from non gvt funded applicants"
label var cit7_out_strict "# cit from non gvt funded applicants removing any applicant citation"
label var cit7_country_breadth "# of applicant’s countries of the citing patents"
label var cit7_US "=1 if all five-year citations come from US applicants"
label var cit5_noself_nostrict "# of five-year forward citations removing self-citations"
label var cit5_noself_strict "# cit removing any applicant citation"
label var cit5_out_nostrict "# cit from non gvt funded applicants"
label var cit5_out_strict "# cit from non gvt funded applicants removing any applicant citation"
label var cit5_country_breadth "# of applicant’s countries of the citing patents"
label var cit5_US "=1 if all seven-year citations come from US applicants"
label var d_ei "=1 if clean-tech patent"
label var d_ei_4dig_Y02A "=1 if CPC 4 digit is Y02A - adaptation to CC" 
label var d_ei_4dig_Y02B "=1 if CPC 4 digit is Y02B - CCMT buildings"
label var d_ei_4dig_Y02C "=1 if CPC 4 digit is Y02C - GHG sequestration"
label var d_ei_4dig_Y02D "=1 if CPC 4 digit is Y02D - CCMT for ICT"
label var d_ei_4dig_Y02E "=1 if CPC 4 digit is Y02E - GHG reduction for energy"
label var d_ei_4dig_Y02P "=1 if CPC 4 digit is Y02P - CCMT for production"
label var d_ei_4dig_Y02T "=1 if CPC 4 digit is Y02T - CCMT for transportation"
label var d_ei_4dig_Y02W "=1 if CPC 4 digit is Y02W - CCMT for waste"
label var d_ei_4dig_Y04S "=1 if CPC 4 digit is Y04S - ICT for energy"
label var d3_A01 "=1 if CPC 3 digit is A01 (same for the others)"


compress
save "${temp_path}/db_full.dta",replace

//+++++++++++++++++++++++++++++++++++++++++++
// (1.b) CLEAN-TECH SAMPLE 
//+++++++++++++++++++++++++++++++++++++++++++

keep if d_ei == 1
drop d_ei d3_*

compress
save "${data_path}/db_for_restat_green.dta",replace


//+++++++++++++++++++++++++++++++++++++++++++
// (1.c) DBS FOR IPW
//+++++++++++++++++++++++++++++++++++++++++++
use "${data_path}/db_for_restat_green.dta",clear

*keep obs only on common support and trim to 5%
qui xi: psmatch2 gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, ///
	out(fwd_cits5) ate common trim(5)
keep if _support==1

//alternative weights preserving proportions between treated and untreated
	//groups

*1.control group weight
qui summarize gvtRD 
local p=r(mean)
generate w1=cond(gvtRD,`p'/(1-`p'),_ps/(1-_ps)) 

*2.treated group weight
qui summarize gvtRD 
local p=r(mean)
generate w2=cond(gvtRD,(1-_ps)/_ps*`p'/(1-`p'),1)


*3.stabilised ipw
qui summarize gvtRD 
local p=r(mean)
generate w3=cond(gvtRD,`p'/_ps,(1-`p')/(1-_ps))


drop _*

compress
save "${data_path}/db_for_restat_green_ipw.dta",replace

//+++++++++++++++++++++++++++++++++++++++++++
// (1.d) DB FOR CEM
//+++++++++++++++++++++++++++++++++++++++++++
use "${data_path}/db_for_restat_green.dta",clear

*5.coarsened exact matching

recode filing_year2 (1999/2005=1) (2006/2008=2) (2009/2010=3) ///
	(2011/max=4),g(filing_year2_rec)

qui tab filing_year2_rec,g(d_filing_year_rec)


qui cem originality nb_inventors nb_applicants $cpc_4d_green ///
	d_filing_year_rec1 d_filing_year_rec2 d_filing_year_rec3 ///
	d_filing_year_rec4 , treatment(gvtRD)


drop filing_year2_rec d_filing_year_rec1 d_filing_year_rec2 ///
	d_filing_year_rec3 d_filing_year_rec4 cem_strata cem_matched

compress
save "${data_path}/db_for_restat_green_cem.dta",replace



//+++++++++++++++++++++++++++++++++++++++++++
// (1.c) DB AT APPLICANT LEVEL FOR TREATMENT HETEROGENEITY ROB CHECK 
//+++++++++++++++++++++++++++++++++++++++++++
use "${temp_path}/db_full.dta",clear
	
keep if d_ei == 1

drop if amount_tot==0|amount_tot==.


replace amount_tot=amount_tot/1000000000

gen count=1


collapse (sum) count  amount_tot  fwd_cits5 (mean) ///
	amount_tot_avg=amount_tot  fwd_cits5_avg=fwd_cits5 ///
	nb_inventors nb_applicants originality $cpc_4d_green , by(id_applicant)

compress
save "${data_path}/db_for_restat_treat_het.dta",replace

//+++++++++++++++++++++++++++++++++++++++++++
// (2) DBS FOR TABLES AND FIGURES IN THE APPENDIX
//+++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++
// (2.a) GREEN SAMPLE STRINGENT DEFINITION
//+++++++++++++++++++++++++++++++++++++++++++
use "${temp_path}/db_full.dta",clear


g d2=1 if d_ei_4dig_Y02B==1| d_ei_4dig_Y02C==1| d_ei_4dig_Y02E==1| d_ei_4dig_Y02T==1
keep if d2==1
drop d2


qui xi: psmatch2 gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, out(fwd_cits5) ate common trim(5)

keep if _support==1

qui summarize gvtRD 
local p=r(mean)
generate w1=cond(gvtRD,`p'/(1-`p'),_ps/(1-_ps)) //preserve proportions and weights applied to control group only

drop _* d_ei d3_*

compress
save "${data_path}/db_for_restat_green_strict.dta",replace

