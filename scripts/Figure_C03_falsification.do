cap est drop all
//++++++++++++++++++++++++++++++++++++++++++++
// Figure 2: Falsification test with randomly assigned treatment
//++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_green.dta",clear

set seed 10121492

matrix falsification = J(100,3,.) 

forvalues i = 1(1)100 {
	di in red "+++ Rep `i' +++"
	preserve
	generate random`i' = runiform()
	egen rank`i' = rank(random`i')
	gen rand_gvtRD`i' = 0
	qui count if gvtRD == 1
	recode rand_gvtRD`i' (0=1) if  rank`i' <= r(N)

	qui xi: psmatch2 rand_gvtRD`i' originality nb_inventors nb_applicants ///
		$cpc_4d_green i.filing_year2, out(fwd_cits5) ate common trim(5)

	keep if _support==1
	qui summarize rand_gvtRD`i' 
	local p=r(mean)
	generate w1=cond(rand_gvtRD`i',`p'/(1-`p'),_ps/(1-_ps)) 

	qui reghdfe fwd_cits5 1.rand_gvtRD`i' originality nb_inventors ///
		nb_applicants $cpc_4d_green i.filing_year2 [aw=w1], ///
		absorb(id_applicant) vce(robust)

	mat A = e(b)
	mat V = e(V)
	matrix falsification[`i',1] = A[1,1] 
	matrix falsification[`i',2] = sqrt(V[1,1]) 
	matrix falsification[`i',3] = A[1,1]/sqrt(V[1,1]) 
	svmat falsification 
	keep falsification*
	compress
	save "${temp_path}/false_`i'.dta",replace
	restore
} 


use "${temp_path}/false_1.dta",clear
forvalues i=2(1)100 {
	append using "${temp_path}/false_`i'.dta"

}


use "${temp_path}/false_100.dta",clear

rename falsification1 beta 
rename falsification2 std 
rename falsification3 t_stat 

keep beta std t_stat 
keep if beta != . 
gen replication = _n
gen significant = 0
recode significant (0=1) if t_stat < -1.96 | t_stat > 1.96

twoway bar beta replication if significant==1, || bar beta replication if significant==0, legend(off) xtitle("Replication #") ytitle("Betas for randomised gvt R&D") note("Blue bars: significant at 5% level") 

graph export "${output_figures}/figure_C03.png", replace width(2000)

** house-keeping
forvalues i=1(1)100 {
	erase "${temp_path}/false_`i'.dta"

}

