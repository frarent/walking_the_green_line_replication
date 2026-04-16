cap est drop _all
//++++++++++++++++++++++++++++++++++++++++++++
// Figure C 1: Multivariate and local imbalance measures before and after
//	coarsened exact matching
//
// Figure C 2: : Comparison of variable means before and after
//	coarsened exact matching.
//++++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_green.dta",clear

cap drop cem_weights

recode filing_year2 (1999/2005=1) (2006/2008=2) (2009/2010=3) ///
	(2011/max=4),g(filing_year2_rec)

qui tab filing_year2_rec,g(d_filing_year_rec)


qui imb originality nb_inventors nb_applicants $cpc_4d_green ///
	d_filing_year_rec*, treatment(gvtRD)

	mat A=r(imbal)
	scalar imb_multi_before=r(L1)
	svmat A

	ren A1 imb_before
	ren A2 mean_before
	drop A3-A7
	
	
qui cem originality nb_inventors nb_applicants $cpc_4d_green ///
	d_filing_year_rec1 d_filing_year_rec2 d_filing_year_rec3 ///
	d_filing_year_rec4 , treatment(gvtRD)

	mat A=r(imbal)
	scalar imb_multi_after=r(L1)
	svmat A

	ren A1 imb_after
	ren A2 mean_after
	drop A3-A7
	g vars=""
	replace vars="originality" in 1 
	replace vars="nb_inventors" in 2
	replace vars="nb_applicants" in 3 
	replace vars="d_ei_4dig_Y02A" in 4 
	replace vars="d_ei_4dig_Y02B" in 5 
	replace vars="d_ei_4dig_Y02C" in 6 
	replace vars="d_ei_4dig_Y02D" in 7 
	replace vars="d_ei_4dig_Y02E" in 8 
	replace vars="d_ei_4dig_Y02P" in 9 
	replace vars="d_ei_4dig_Y02T" in 10 
	replace vars="d_ei_4dig_Y02W" in 11 
	replace vars="d_ei_4dig_Y04S" in 12 
	replace vars="d_filing_year_rec1" in 13 
	replace vars="d_filing_year_rec2" in 14 
	replace vars="d_filing_year_rec3" in 15 
	replace vars="d_filing_year_rec4" in 16 

keep vars imb_* mean_*
keep if imb_before!=.

encode vars,g(vars_enc)


lab def vars_enc2 1 "Y02A - adaptation to CC" 2 "Y02B - CCMT buildings" ///
	3 "Y02C - GHG sequestration" 4 "Y02D - CCMT for ICT" ///
	5 "Y02E - GHG reduction for energy" 6"Y02P - CCMT for production" ///
	7"Y02T - CCMT for transportation" 8"Y02W - CCMT for waste" ///
	9"Y04S - ICT for energy" 10"fil_1999_2005" 11"fil_2006_2008" ///
	12"fil_2009_2010" 13"fil_2011_2014" 14"# of applicants" ///
	15"team size" 16"originality",replace
	

lab values vars_enc vars_enc2

*figure C3
graph bar imb_before imb_after,over(vars_enc,label(angle(25) labsize(vsmall))) ///
	 ytitle("imbalance measure",size(small)) legend(label(1 "before cem") label(2 "after cem") pos(6) row(1))

graph export "${output_figures}/figure_C01.png",wid(2000) replace

*figure C4
graph bar mean_before mean_after,over(vars_enc,label(angle(25) labsize(vsmall))) ///
	 ytitle("difference in means",size(small)) legend(label(1 "before cem") label(2 "after cem") pos(6) row(1))

graph export "${output_figures}/figure_C02.png",wid(2000) replace

	
